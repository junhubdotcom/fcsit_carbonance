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

  Future<void> generateCarbonApiJson(
      Expense expense, List<ExpenseItem> expenseItems) async {
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

  Future<void> sendToCarbonApi(List<Map<String, dynamic>> transactions,
      List<ExpenseItem> expenseItems) async {
    const String url = 'https://api.connect.earth/transaction';
    final Map<String, String> headers = {
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

  /// Enhanced method to get carbon footprint with insights
  Future<Map<String, dynamic>> getCarbonFootprintWithInsights(
      Expense expense, List<ExpenseItem> expenseItems) async {
    // Calculate carbon footprints
    await generateCarbonApiJson(expense, expenseItems);

    // Get insights data
    final insights = await _getInsightsData(expenseItems);

    return {
      'carbonFootprints':
          expenseItems.map((item) => item.carbon_footprint).toList(),
      'insights': insights,
    };
  }

  /// Get pie chart insights for carbon emissions
  Future<Map<String, dynamic>> getPieChartInsights(
      List<ExpenseItem> items) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/charts/pie'),
        headers: _headers,
        body: jsonEncode({
          'transactions': items
              .map((item) => {
                    'category': item.category,
                    'carbon_footprint': item.carbon_footprint,
                    'amount': item.price * item.quantity,
                  })
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Pie Chart API Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('Pie Chart API Exception: $e');
      return {};
    }
  }

  /// Get time series insights for trend analysis
  Future<Map<String, dynamic>> getTimeSeriesInsights(
      List<ExpenseItem> items) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/charts/timeseries'),
        headers: _headers,
        body: jsonEncode({
          'transactions': items
              .map((item) => {
                    'date': DateTime.now().toIso8601String().split('T')[0],
                    'carbon_footprint': item.carbon_footprint,
                    'category': item.category,
                  })
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            'Time Series API Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('Time Series API Exception: $e');
      return {};
    }
  }

  /// Get monthly insights totals
  Future<Map<String, dynamic>> getMonthlyInsightsTotals() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/insights/monthly/totals'),
        headers: _headers,
        body: jsonEncode({
          'month': DateTime.now().month,
          'year': DateTime.now().year,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            'Monthly Totals API Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('Monthly Totals API Exception: $e');
      return {};
    }
  }

  /// Get personalized recommendations
  Future<List<Map<String, dynamic>>> getRecommendations(
      List<ExpenseItem> items) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/insights/recommendations'),
        headers: _headers,
        body: jsonEncode({
          'spending_patterns': items
              .map((item) => {
                    'category': item.category,
                    'amount': item.price * item.quantity,
                    'carbon_footprint': item.carbon_footprint,
                  })
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['recommendations'] ?? []);
      } else {
        print(
            'Recommendations API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Recommendations API Exception: $e');
      return [];
    }
  }

  /// Get carbon reduction tips
  Future<List<Map<String, dynamic>>> getCarbonTips() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/insights/tips'),
        headers: _headers,
        body: jsonEncode({
          'user_preferences': {
            'location': 'MY',
            'lifestyle': 'urban',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['tips'] ?? []);
      } else {
        print('Tips API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Tips API Exception: $e');
      return [];
    }
  }

  /// Get GHG Protocol Report (for professional reporting)
  Future<Map<String, dynamic>> getGHGProtocolReport(
      List<ExpenseItem> items) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/insights/ghg-protocol'),
        headers: _headers,
        body: jsonEncode({
          'transactions': items
              .map((item) => {
                    'category': item.category,
                    'carbon_footprint': item.carbon_footprint,
                    'date': DateTime.now().toIso8601String().split('T')[0],
                    'amount': item.price * item.quantity,
                  })
              .toList(),
          'report_period': {
            'start_date': DateTime.now()
                .subtract(Duration(days: 30))
                .toIso8601String()
                .split('T')[0],
            'end_date': DateTime.now().toIso8601String().split('T')[0],
          },
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            'GHG Protocol API Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('GHG Protocol API Exception: $e');
      return {};
    }
  }

  /// Submit user questionnaire for personalized insights
  Future<bool> submitQuestionnaire(Map<String, dynamic> answers) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/questionnaire'),
        headers: _headers,
        body: jsonEncode({
          'user_id': 'user_123', // Replace with actual user ID
          'answers': answers,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Questionnaire API Exception: $e');
      return false;
    }
  }

  /// Get user questionnaire responses
  Future<Map<String, dynamic>> getQuestionnaireResponses() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/questionnaire?user_id=user_123'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            'Get Questionnaire API Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('Get Questionnaire API Exception: $e');
      return {};
    }
  }

  /// Get carbon offset options
  Future<List<Map<String, dynamic>>> getOffsetOptions() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/offset/auth'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['offset_options'] ?? []);
      } else {
        print(
            'Offset Options API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Offset Options API Exception: $e');
      return [];
    }
  }

  /// Purchase carbon offset
  Future<bool> purchaseOffset(String offsetId, double amount) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/offset/checkout?offset_id=$offsetId&amount=$amount'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Purchase Offset API Exception: $e');
      return false;
    }
  }

  /// Get user's offset purchases
  Future<List<Map<String, dynamic>>> getUserOffsets() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/offset/user?user_id=user_123'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['offsets'] ?? []);
      } else {
        print(
            'User Offsets API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('User Offsets API Exception: $e');
      return [];
    }
  }

  /// Helper method to get comprehensive insights data
  Future<Map<String, dynamic>> _getInsightsData(List<ExpenseItem> items) async {
    final results = await Future.wait([
      getPieChartInsights(items),
      getTimeSeriesInsights(items),
      getMonthlyInsightsTotals(),
      getRecommendations(items),
      getCarbonTips(),
    ]);

    return {
      'pieChart': results[0],
      'timeSeries': results[1],
      'monthlyTotals': results[2],
      'recommendations': results[3],
      'tips': results[4],
    };
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
