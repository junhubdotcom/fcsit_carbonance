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
      model: "gemini-1.5-pro", apiKey: AppConstants.TRANSACTION_GEMINI_API_KEY);
  // DatabaseService db = DatabaseService();
  // List<ExpenseItem> expenseItems = [];

  Future<void> generateCarbonApiJson(Expense expense, List<ExpenseItem> expenseItems) async {
    List<Map<String, dynamic>> transactions = [];

    //fetch the ExpenseItem objects from DB using IDs
    // 
    
    for (ExpenseItem item in expenseItems) {
      final prompt = """
Given this item: "${item.name}" under the category "${item.category}", classify it into a Merchant Category Code (MCC) and generate a JSON payload for the Connect Earth API.

Return only the raw JSON object. Do not wrap it in triple backticks (```) or any markdown formatting

The format should be:

{
    "price": ${item.price * item.quantity},
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
      try {
        final generatedText = response.text ?? "";
        final structuredJson = jsonDecode(generatedText);
        transactions.add(structuredJson);
      } catch (e) {
        print("error");
      }
    }
    print("Transactions Json List: $transactions");
    return await sendToCarbonApi(transactions, expenseItems);
  }

  Future<void> sendToCarbonApi(
      List<Map<String, dynamic>> transactions, List<ExpenseItem> expenseItems) async {
    const String url = 'https://api.connect.earth/transaction';
    const Map<String, String> headers = {
      'x-api-key': AppConstants.CARBON_API_KEY,
      'Content-Type': 'application/json',
    };

    for (int i = 0; i < transactions.length; i++) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(transactions[i]),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Success: ${response.body}');
          final carbonData = jsonDecode(response.body);
          double carbonFootprint =
              (carbonData["kg_of_CO2e_emissions"] ?? 0.0).toDouble();
          print("Carbon Footprint: $carbonFootprint");
          if (i < transactions.length) {
            expenseItems[i].carbon_footprint = carbonFootprint;
          }
        } else {
          print('Error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Exception: $e');
      }
    }
  }

  // Future<void> sendToCarbonApi() async {
  //   print("Enter send to carbon api method");
  //   print(AppConstants.CARBON_API_KEY);
  //   // print("Total transactions: ${transactions.length}");

  //   // for (int i = 0; i < transactions.length; i++) {
  //   //   print("Sending transaction ${i + 1} out of ${transactions.length}");

  //   final Map<String, dynamic> body = {
  //     'price': 30.0,
  //     'geo': 'MY',
  //     'categoryType': 'mcc',
  //     'categoryValue': '5499',
  //     'currencyISO': 'MYR',
  //     'transactionDate': '2025-04-02',
  //   };
  //   try {
  //     final response = await http
  //         .post(Uri.parse('https://api.connect.earth/transaction'),
  //             headers: {
  //               "x-api-key": AppConstants.CARBON_API_KEY,
  //               "Content-Type": "application/json",
  //             },
  //             body: jsonEncode(body))

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //     print('Success: ${response.body}');
  //   } else {
  //     print('Error: ${response.statusCode} - ${response.body}');
  //   }

  //     // // Check if the response is empty or not
  //     // if (response.body.isNotEmpty) {
  //     //   print("Response Body: ${response.body}");
  //     // } else {
  //     //   print("Empty Response Body");
  //     // }

  //   //   print("Status Code: ${response.statusCode}");
  //   //   if (response.statusCode == 200 || response.statusCode == 201) {
  //   //   print('Success: ${response.body}');
  //   // }

  //   //   // Check if the response code is 200 (Success)
  //   //   if (response.statusCode == 200) {
  //   //     try {
  //   //       // Try parsing the response body to JSON
  //   //       final carbonData = jsonDecode(response.body);
  //   //       print("Parsed JSON Response: $carbonData");

  //   //       // Extract carbon footprint from the response
  //   //       double carbonFootprint =
  //   //           (carbonData["kg_of_CO2e_emissions"] ?? 0.0).toDouble();
  //   //       print("Carbon Footprint: $carbonFootprint");

  //   //       // Assign carbon footprint to the corresponding item in expense
  //   //       // if (i < expense.items.length) {
  //   //       expense.items[0].carbon_footprint = carbonFootprint;
  //   //       // }
  //   //     } catch (e) {
  //   //       print("Error parsing response body: $e");
  //   //       print("Response Body: ${response.body}");
  //   //     }
  //     // } else {
  //     //   print("Request failed with status: ${response.statusCode}");
  //     //   print("Response Body: ${response.body}");
  //     // }

  //   } catch (e) {
  //     print("Unknown error: $e");

  //   }

  // }
}
