import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:steadypunpipi_vhack/common/constants.dart';

class ConnectEarthInsightsService {
  static const String _baseUrl = 'https://api.connect.earth';

  // Headers for API requests
  Map<String, String> get _headers => {
        'x-api-key': AppConstants.CARBON_API_KEY,
        'Content-Type': 'application/json',
      };

  /// Upload transactions to Connect Earth (required for async insights)
  Future<bool> uploadTransactions(
      List<Map<String, dynamic>> transactions, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/transaction/bulk/upload'),
        headers: _headers,
        body: jsonEncode({
          'geo': 'MY', // Malaysia
          'userId': userId,
          'userType': 'PERSONAL',
          'transactions': transactions
              .map((txn) => {
                    'transactionId': txn['id'] ??
                        'txn_${DateTime.now().millisecondsSinceEpoch}',
                    'categoryType': 'mcc',
                    'categoryValue': _getMCCForCategory(txn['category']),
                    'currencyISO': 'MYR',
                    'price': txn['price'] * (txn['quantity'] ?? 1),
                    'transactionDate': txn['date'] ??
                        DateTime.now().toIso8601String().split('T')[0],
                    'merchant': txn['name'] ?? '',
                    'description': txn['description'] ?? '',
                  })
              .toList(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
            '✅ Successfully uploaded ${transactions.length} transactions to Connect Earth');
        return true;
      } else {
        print('❌ Upload API Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Upload API Exception: $e');
      return false;
    }
  }

  /// Get transactions from Connect Earth
  Future<List<Map<String, dynamic>>> getTransactions(
      String userId, String startDate, String endDate) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/transaction/bulk/upload/get'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'startDate': startDate,
          'endDate': endDate,
          'transactionIds': [], // Empty array to get all transactions
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['transactions'] ?? []);
      } else {
        print(
            '❌ Get Transactions API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Get Transactions API Exception: $e');
      return [];
    }
  }

  /// Delete transactions from Connect Earth
  Future<bool> deleteTransactions(
      String userId, List<String> transactionIds) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/transaction/bulk/delete'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'transactionIds': transactionIds,
          'deleteQuestionnaire': false,
        }),
      );

      if (response.statusCode == 200) {
        print(
            '✅ Successfully deleted ${transactionIds.length} transactions from Connect Earth');
        return true;
      } else {
        print('❌ Delete API Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Delete API Exception: $e');
      return false;
    }
  }

  /// Get pie chart insights for carbon emissions (async - requires uploaded transactions)
  Future<Map<String, dynamic>> getPieChartInsights(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/charts/pie'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            '❌ Pie Chart API Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ Pie Chart API Exception: $e');
      return {};
    }
  }

  /// Get time series insights for trend analysis (async - requires uploaded transactions)
  Future<Map<String, dynamic>> getTimeSeriesInsights(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/charts/timeseries'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            '❌ Time Series API Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ Time Series API Exception: $e');
      return {};
    }
  }

  /// Get monthly insights totals (async - requires uploaded transactions)
  Future<Map<String, dynamic>> getMonthlyInsightsTotals(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/insights/monthly/totals'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'month': DateTime.now().month,
          'year': DateTime.now().year,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            '❌ Monthly Totals API Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ Monthly Totals API Exception: $e');
      return {};
    }
  }

  /// Get personalized recommendations (async - requires uploaded transactions)
  Future<List<Map<String, dynamic>>> getRecommendations(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/insights/recommendations'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['recommendations'] ?? []);
      } else {
        print(
            '❌ Recommendations API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Recommendations API Exception: $e');
      return [];
    }
  }

  /// Get carbon reduction tips (async - requires uploaded transactions)
  Future<List<Map<String, dynamic>>> getCarbonTips(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/insights/tips'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
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
        print('❌ Tips API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Tips API Exception: $e');
      return [];
    }
  }

  /// Get GHG Protocol Report (async - requires uploaded transactions)
  Future<Map<String, dynamic>> getGHGProtocolReport(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/insights/ghg-protocol'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
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
            '❌ GHG Protocol API Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ GHG Protocol API Exception: $e');
      return {};
    }
  }

  /// Submit user questionnaire for personalized insights
  Future<bool> submitQuestionnaire(
      String userId, Map<String, dynamic> answers) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/questionnaire'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'answers': answers,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Questionnaire API Exception: $e');
      return false;
    }
  }

  /// Get user questionnaire responses
  Future<Map<String, dynamic>> getQuestionnaireResponses(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/questionnaire?userId=$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
            '❌ Get Questionnaire API Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('❌ Get Questionnaire API Exception: $e');
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
            '❌ Offset Options API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Offset Options API Exception: $e');
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
      print('❌ Purchase Offset API Exception: $e');
      return false;
    }
  }

  /// Get user's offset purchases
  Future<List<Map<String, dynamic>>> getUserOffsets(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/offset/user?userId=$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['offsets'] ?? []);
      } else {
        print(
            '❌ User Offsets API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ User Offsets API Exception: $e');
      return [];
    }
  }

  /// Get comprehensive insights data (async workflow)
  Future<Map<String, dynamic>> getComprehensiveInsights(String userId) async {
    final results = await Future.wait([
      getPieChartInsights(userId),
      getTimeSeriesInsights(userId),
      getMonthlyInsightsTotals(userId),
      getRecommendations(userId),
      getCarbonTips(userId),
    ]);

    return {
      'pieChart': results[0],
      'timeSeries': results[1],
      'monthlyTotals': results[2],
      'recommendations': results[3],
      'tips': results[4],
    };
  }

  /// Helper method to convert category to MCC code
  String _getMCCForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'restaurant':
        return '5814'; // Fast Food Restaurants
      case 'transport':
      case 'transportation':
        return '4121'; // Taxicabs and Limousines
      case 'shopping':
      case 'retail':
        return '5311'; // Department Stores
      case 'utilities':
      case 'electricity':
        return '4900'; // Utilities
      case 'entertainment':
        return '7832'; // Motion Picture Theaters
      case 'healthcare':
      case 'medical':
        return '8011'; // Doctors
      case 'education':
        return '8220'; // Colleges, Universities, Professional Schools
      default:
        return '5499'; // Miscellaneous Food Stores (default)
    }
  }
}
