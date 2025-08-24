import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:steadypunpipi_vhack/common/constants.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:steadypunpipi_vhack/models/complete_expense.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/models/expense_item.dart';

class ApiService {
  final _model = GenerativeModel(
      model: 'gemini-1.5-pro', apiKey: AppConstants.GEMINI_API_KEY);

  Future<CompleteExpense> generateContent(String imgPath) async {
    try {
      // final image = File(imgPath);
      // final bytes = await image.readAsBytes();
      // final String mimeType = 'image/jpeg';

      // Get google vision result
      final visionResult = await classifyImage(imgPath);
      print(visionResult);
      String visionLabels = "";

      if (visionResult != null) {
        final labels = visionResult['responses'][0]['labelAnnotations'] ?? [];
        visionLabels =
            labels.map((label) => label['description']).take(5).join(", ");
        print(visionLabels);
      }
      Expense expense = await generateGeneralContent(imgPath, visionResult!);
      List<ExpenseItem> expenseItems =
          await generateItemContent(imgPath, visionResult);
      
      
      final CompleteExpense completeExpense =
          CompleteExpense.fromScannedReceipt(expense.toJson(), expenseItems);
      
      return completeExpense;
    } catch (e) {
      throw Exception('Error generating content: $e');
    }
  }

  Future<Expense> generateGeneralContent(
      String imgPath, Map<String, dynamic> visionResult) async {
    try {
      String generalPrompt = '''
You are a financial assistant AI. I will give you the receipt's OCR result. Your job is to analyze both and return a **pure JSON** response with **no explanation or extra text**.

Use the following JSON schema:

{
  "transactionName": String, // If there are multiple items, generate a smart name like "McDonald's Lunch" or "Grocery Shopping"; if only one item, set this to "none"
  "category": String // Determine the major category for the expense based on the items (e.g. "Food", "Housing", "Debt Repayment", "Medical", "Transport", "Utilities", "Shopping", "Tax")
  "paymentMethod": String, //Choose one from: "Cash", "E-Wallet", "Online Banking", "Credit", "Debit"
  "location": String, // Extract location from receipt if available (e.g. merchant address or shop name)
  "dateTime": Timestamp, // Extracted from the receipt if available
  "receiptImagePath": $imgPath
}

Instructions:
- Include payment method (Cash, E-Wallet, Online Banking, Credit, Debit) from the receipt.
- Extract transaction name from the receipt (if multiple items, generate a descriptive name like "Grocery Shopping").
- Assign the correct category strictly from the predefined list: "Food", "Housing", "Debt Repayment", "Medical", "Transport", "Utilities", "Shopping", "Tax".
- Extract location if available (e.g., merchant name or address).
- Estimate the date and time if available from the receipt.
- Return the pure JSON object with no additional text or explanation.

Important:
Return only the raw JSON object. Do not wrap it in triple backticks (```) or any markdown formatting.
Do not prefix with json or any other label.
Do not include any explanation, comments, or surrounding text — just output the JSON itself so it can be parsed directly.

Inputs:
1. This OCR text: $visionResult
''';

      final responseGeneral =
          await _model.generateContent([Content.text(generalPrompt)]);
      print(responseGeneral.text);
      final jsonGeneralResponse = jsonDecode(responseGeneral.text ?? '{}');

      final expense = Expense.fromJson(jsonGeneralResponse);
      return expense;
    } catch (e) {
      throw Exception('Error generating item content: $e');
    }
  }

  Future<List<ExpenseItem>> generateItemContent(
      String imgPath, Map<String, dynamic> visionResult) async {
    try {
      String itemPrompt = '''
You are a financial assistant AI. I will give you the receipt's OCR result. Your job is to analyze both and return a **pure JSON** response with **no explanation or extra text**.

Use the following JSON schema:

{
  "items": [
    {
      "name": String, // name of the item purchased
      "category": String, // choose from: "Food", "Housing", "Debt Repayment", "Medical", "Transport", "Utilities", "Shopping", "Tax"
      "quantity": String, // quantity of this item
      "price": Double, // price per unit
    }
  ]
}

Instructions:
- Extract each item from the receipt and categorize it intelligently (e.g., "Latte" = Food, "Sofa" = Housing, etc.).
- Provide the quantity and price for each item.
- Ensure that the category is inferred from the item name.
- Return the JSON response with the list of items.

Important:
Return only the raw JSON object. Do not wrap it in triple backticks (```) or any markdown formatting.
Do not prefix with json or any other label.
Do not include any explanation, comments, or surrounding text — just output the JSON itself so it can be parsed directly.

Inputs:
1. This OCR text: $visionResult
''';

      final responseItem =
          await _model.generateContent([Content.text(itemPrompt)]);
      print(responseItem.text);
      final jsonItemResponse = jsonDecode(responseItem.text ?? '{}');

      if (jsonItemResponse['items'] != null) {
        final List<ExpenseItem> expenseItems =
            (jsonItemResponse['items'] as List)
                .map((itemJson) => ExpenseItem.fromJson(itemJson))
                .toList();
        return expenseItems;
      } else {
        throw Exception("No items found in the response");
      }
    } catch (e) {
      throw Exception('Error generating item content: $e');
    }
  }

  Future<Map<String, dynamic>?> classifyImage(String imagePath) async {
    try {
      final bytes = File(imagePath).readAsBytesSync();
      final String base64Image = base64Encode(bytes);
      print("Continue 2");
      final response = await http.post(
        Uri.parse(
            "https://vision.googleapis.com/v1/images:annotate?key=${AppConstants.GOOGLE_VISION_API_KEY}"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'TEXT_DETECTION'},
              ]
            }
          ]
        }),
      );

      print("Continue 3");
      if (response.statusCode == 200) {
        print(response.body);
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }
}
