import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

enum LoanStatus { pending, approved, rejected, active, completed, defaulted }

enum LoanPurpose {
  solarInstallation,
  electricVehicle,
  homeInsulation,
  renewableEnergy,
  sustainableBusiness,
  greenHomeImprovement,
  other
}

class GreenLoan {
  String? id;
  String userId;
  double amount;
  double interestRate;
  int termMonths;
  LoanStatus status;
  LoanPurpose purpose;
  String description;
  DateTime applicationDate;
  DateTime? approvalDate;
  DateTime? disbursementDate;
  DateTime? dueDate;
  double monthlyPayment;
  double remainingBalance;
  double sustainabilityScore;
  double greenCreditBalance;
  List<String> documents;
  String? rejectionReason;

  GreenLoan({
    this.id,
    required this.userId,
    required this.amount,
    required this.interestRate,
    required this.termMonths,
    this.status = LoanStatus.pending,
    required this.purpose,
    required this.description,
    DateTime? applicationDate,
    this.approvalDate,
    this.disbursementDate,
    this.dueDate,
    this.monthlyPayment = 0.0,
    this.remainingBalance = 0.0,
    this.sustainabilityScore = 0.0,
    this.greenCreditBalance = 0.0,
    List<String>? documents,
    this.rejectionReason,
  })  : applicationDate = applicationDate ?? DateTime.now(),
        documents = documents ?? [];

  // Calculate monthly payment
  void calculateMonthlyPayment() {
    if (amount > 0 && interestRate > 0 && termMonths > 0) {
      double monthlyRate = interestRate / 12 / 100;
      monthlyPayment = amount *
          (monthlyRate * pow(1 + monthlyRate, termMonths)) /
          (pow(1 + monthlyRate, termMonths) - 1);
      remainingBalance = amount;
    }
  }

  // Calculate interest rate based on sustainability score
  static double calculateInterestRate(
      double sustainabilityScore, double greenCreditBalance) {
    double baseRate = 8.0; // Base interest rate 8%

    // Reduce rate based on sustainability score
    if (sustainabilityScore >= 90)
      baseRate -= 3.0;
    else if (sustainabilityScore >= 80)
      baseRate -= 2.0;
    else if (sustainabilityScore >= 70)
      baseRate -= 1.5;
    else if (sustainabilityScore >= 60) baseRate -= 1.0;

    // Reduce rate based on green credit balance
    if (greenCreditBalance >= 1000)
      baseRate -= 1.0;
    else if (greenCreditBalance >= 500) baseRate -= 0.5;

    return baseRate.clamp(2.0, 15.0); // Min 2%, Max 15%
  }

  // Get loan purpose display name
  String get purposeDisplayName {
    switch (purpose) {
      case LoanPurpose.solarInstallation:
        return 'Solar Panel Installation';
      case LoanPurpose.electricVehicle:
        return 'Electric Vehicle Purchase';
      case LoanPurpose.homeInsulation:
        return 'Home Insulation';
      case LoanPurpose.renewableEnergy:
        return 'Renewable Energy System';
      case LoanPurpose.sustainableBusiness:
        return 'Sustainable Business Investment';
      case LoanPurpose.greenHomeImprovement:
        return 'Green Home Improvement';
      case LoanPurpose.other:
        return 'Other Sustainable Purpose';
    }
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case LoanStatus.pending:
        return 'Pending Review';
      case LoanStatus.approved:
        return 'Approved';
      case LoanStatus.rejected:
        return 'Rejected';
      case LoanStatus.active:
        return 'Active';
      case LoanStatus.completed:
        return 'Completed';
      case LoanStatus.defaulted:
        return 'Defaulted';
    }
  }

  // From JSON
  factory GreenLoan.fromJson(Map<String, dynamic> json) {
    return GreenLoan(
      id: json['id'],
      userId: json['userId'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      interestRate: (json['interestRate'] ?? 0.0).toDouble(),
      termMonths: json['termMonths'] ?? 12,
      status: LoanStatus.values.firstWhere(
        (e) => e.toString() == 'LoanStatus.${json['status']}',
        orElse: () => LoanStatus.pending,
      ),
      purpose: LoanPurpose.values.firstWhere(
        (e) => e.toString() == 'LoanPurpose.${json['purpose']}',
        orElse: () => LoanPurpose.other,
      ),
      description: json['description'] ?? '',
      applicationDate: json['applicationDate'] is Timestamp
          ? (json['applicationDate'] as Timestamp).toDate()
          : DateTime.now(),
      approvalDate: json['approvalDate'] is Timestamp
          ? (json['approvalDate'] as Timestamp).toDate()
          : null,
      disbursementDate: json['disbursementDate'] is Timestamp
          ? (json['disbursementDate'] as Timestamp).toDate()
          : null,
      dueDate: json['dueDate'] is Timestamp
          ? (json['dueDate'] as Timestamp).toDate()
          : null,
      monthlyPayment: (json['monthlyPayment'] ?? 0.0).toDouble(),
      remainingBalance: (json['remainingBalance'] ?? 0.0).toDouble(),
      sustainabilityScore: (json['sustainabilityScore'] ?? 0.0).toDouble(),
      greenCreditBalance: (json['greenCreditBalance'] ?? 0.0).toDouble(),
      documents: List<String>.from(json['documents'] ?? []),
      rejectionReason: json['rejectionReason'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'interestRate': interestRate,
      'termMonths': termMonths,
      'status': status.toString().split('.').last,
      'purpose': purpose.toString().split('.').last,
      'description': description,
      'applicationDate': Timestamp.fromDate(applicationDate),
      'approvalDate':
          approvalDate != null ? Timestamp.fromDate(approvalDate!) : null,
      'disbursementDate': disbursementDate != null
          ? Timestamp.fromDate(disbursementDate!)
          : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'monthlyPayment': monthlyPayment,
      'remainingBalance': remainingBalance,
      'sustainabilityScore': sustainabilityScore,
      'greenCreditBalance': greenCreditBalance,
      'documents': documents,
      'rejectionReason': rejectionReason,
    };
  }

  // Approve loan
  void approve() {
    status = LoanStatus.approved;
    approvalDate = DateTime.now();
    dueDate = DateTime.now().add(Duration(days: termMonths * 30));
    calculateMonthlyPayment();
  }

  // Reject loan
  void reject(String reason) {
    status = LoanStatus.rejected;
    rejectionReason = reason;
  }

  // Disburse loan
  void disburse() {
    status = LoanStatus.active;
    disbursementDate = DateTime.now();
  }

  // Make payment
  void makePayment(double paymentAmount) {
    if (status == LoanStatus.active) {
      remainingBalance -= paymentAmount;
      if (remainingBalance <= 0) {
        status = LoanStatus.completed;
      }
    }
  }
}
