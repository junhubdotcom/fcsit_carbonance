# Open Finance Account Linking Flow

This directory contains the widgets and components for the dynamic Open Finance account linking flow in the Carbonance app.

## Overview

The account linking flow allows users to connect their bank accounts to track transactions and calculate carbon emissions. The flow is designed to be modular, responsive, and easily extensible for future API integration.

## Components

### 1. ConnectedAccountsPage (`../screens/connected_accounts_page.dart`)
- Main page displaying all connected accounts
- Shows account summary with total balance
- Handles adding and removing accounts
- Empty state when no accounts are connected

### 2. ConnectAccountModal (`connect_account_modal.dart`)
- Multi-step modal for connecting new accounts
- Progress indicator showing current step
- Manages the flow between bank selection and consent form

### 3. BankSelector (`bank_selector.dart`)
- Step 1: Bank selection interface
- Search functionality for finding banks
- Popular banks section with grid layout
- All banks section with list layout
- Bank-specific colors and icons

### 4. ConsentForm (`consent_form.dart`)
- Step 2: Account type selection and consent
- Form validation for balance input
- Security and privacy information
- Account type dropdown based on bank support

### 5. AccountTile (`account_tile.dart`)
- Individual account display component
- Shows bank info, account type, balance, and connection date
- Action menu for account management
- Responsive design with bank-specific styling

## Data Models

### BankAccount (`../../models/bank_account.dart`)
```dart
class BankAccount {
  final String id;
  final String bankName;
  final String accountType;
  final String accountNumber;
  final double balance;
  final String currency;
  final bool isConnected;
  final DateTime connectedAt;
}
```

### Bank (`../../models/bank_account.dart`)
```dart
class Bank {
  final String id;
  final String name;
  final String logo;
  final List<String> supportedAccountTypes;
  final bool isPopular;
}
```

## Dummy Data

The flow uses dummy data from `../../common/dummy_data.dart`:
- Sample banks (Maybank, CIMB, HSBC, etc.)
- Pre-connected accounts
- Account types and supported features

## Usage

### Navigation from Profile
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ConnectedAccountsPage(),
  ),
);
```

### Adding New Account
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => ConnectAccountModal(
    onAccountConnected: (account) {
      // Handle new account
    },
  ),
);
```

## Future Enhancements

### API Integration
1. Replace dummy data with real bank APIs
2. Implement OAuth flow for bank authentication
3. Add real-time balance updates
4. Transaction synchronization

### Features
1. Account balance history charts
2. Transaction categorization
3. Carbon footprint calculation per account
4. Account comparison and insights

### Security
1. Biometric authentication
2. Encrypted data storage
3. Secure API communication
4. Privacy controls

## Styling

All components use the app's design system:
- Colors from `AppConstants`
- Google Fonts (Quicksand)
- Consistent spacing and border radius
- Material 3 design principles

## Testing

The components are designed to be easily testable:
- Modular widget structure
- Clear separation of concerns
- Mock data support
- State management with setState (can be upgraded to Provider/Bloc)

## Dependencies

- `flutter/material.dart`
- `google_fonts`
- `steadypunpipi_vhack/common/constants.dart`
- `steadypunpipi_vhack/models/bank_account.dart`
- `steadypunpipi_vhack/common/dummy_data.dart` 