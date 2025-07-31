import 'package:flutter/material.dart';

class AppConstants {
  // 🌟 App-wide values
  static const String appName = "Expense Tracker";
  static const String currency = "MYR";

  // 🌐 API Endpoints
  static const String baseUrl = "https://api.yourserver.com";
  static const String transactionsEndpoint = "$baseUrl/transactions";
  static const String carbonEndpoint = "$baseUrl/carbon";
  static const String GEMINI_API_KEY =
      "AIzaSyDvgydDIgm2BnHGmzghqGIQSgzvRitkDkA";
  static const String GOOGLE_VISION_API_KEY =
      "AIzaSyAOKtlOJCS_N38VLCnBZ5LY08BHy2Bc3XA";
  static const String TRANSACTION_GEMINI_API_KEY =
      "AIzaSyByfHg3R3hd4XrxmOoMNaMaKsW0GjuscIc";
  static const String CARBON_API_KEY =
      "87a834b021e3a52ef7a31d63824f2cc7250b53c8ad608500c985d710e116290bb2f615a0f0316b5a76a1786e786735e31890c22dc569dff8efdc39ff873c615f";

  // 🎨 Color Palette (Light Theme)
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF03A9F4);

  // 🌙 Dark Theme Colors (For Future Use)
  static const Color darkPrimary = Color(0xFF1B5E20);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0BEC5);

  // 📝 Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeExtraLarge = 24.0;
  static const double fontSizeTitle = 32.0;

  // 📏 Spacing & Padding
  static const double paddingExtraSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // 🏷 Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;

  // 🎭 Shadows
  static final BoxShadow boxShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 10.0,
    spreadRadius: 2.0,
    offset: Offset(2, 4),
  );
}
