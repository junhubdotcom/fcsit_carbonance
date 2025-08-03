import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:steadypunpipi_vhack/common/constants.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';

class CarbonService {
  final _model = GenerativeModel(
      model: "gemini-1.5-pro", apiKey: AppConstants.GEMINI_API_KEY);

  // Base URL for Connect Earth API
  static const String _baseUrl = 'https://api.connect.earth';

  // Headers for API requests
  Map<String, String> get _headers => {
        'x-api-key': AppConstants.CARBON_API_KEY,
        'Content-Type': 'application/json',
      };

  // DatabaseService db = DatabaseService();
  // List<ExpenseItem> expenseItems = [];

  Future<void> generateCarbonApiJson(Expense expense, List<ExpenseItem> expenseItems) async {
    Map<String, dynamic> transaction = {};

    //fetch the ExpenseItem objects from DB using IDs
    
    double totalAmount = expenseItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
      final prompt = """
Given this transaction titled "${expense.transactionName}" and consisting of these items:

${expenseItems.map((e) => "- ${e.name} (${e.category}), quantity: ${e.quantity}, unit price: ${e.price}").join("\n")}

Classify the overall transaction into a single most appropriate Merchant Category Code (MCC), and generate one JSON payload based on this MCC to be used for the Connect Earth API.
"Only return a valid JSON. No explanation, no formatting, no markdown. Do not use triple backticks."

{
    "price": ${totalAmount},
    "geo": "MY",
    "categoryType": "mcc",
    "categoryValue": "MCC_CODE",
    "currencyISO": "MYR",
    "transactionDate": "${expense.dateTime.toDate().toIso8601String().split('T')[0]}"
}

Example response:

{
    "price": 15.0,
    "geo": "MY",
    "categoryType": "mcc",
    "categoryValue": "5814",
    "currencyISO": "MYR",
    "transactionDate": "2025-04-02"
}

""";
      final response = await _model.generateContent([Content.text(prompt)]);
      print("Generated Response: ${response.text}");
      try {
        final generatedText = response.text ?? "";
        final structuredJson = jsonDecode(generatedText);
        transaction = structuredJson;
      } catch (e) {
        print("error");
      }
    
    print("Transaction Json: $transaction");
    return await sendToCarbonApi(transaction, expense);
  }

  Future<void> sendToCarbonApi(
      Map<String, dynamic> transaction, Expense expense) async {
    const String url = 'https://api.connect.earth/transaction';
    final Map<String, String> headers = {
      'x-api-key': AppConstants.CARBON_API_KEY,
      'Content-Type': 'application/json',
    };

  
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(transaction),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Success: ${response.body}');
          final carbonData = jsonDecode(response.body);
          double carbonFootprint =
              (carbonData["kg_of_CO2e_emissions"] ?? 0.0).toDouble();
          print("Carbon Footprint: $carbonFootprint");
          expense.carbonFootprint = carbonFootprint;
          
        } else {
          print('Error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Exception: $e');
      }

  }

}
