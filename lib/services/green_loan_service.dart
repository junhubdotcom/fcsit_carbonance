import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:steadypunpipi_vhack/models/green_loan.dart';
import 'package:steadypunpipi_vhack/models/green_credit.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';
import 'package:steadypunpipi_vhack/services/green_credit_service.dart';

class GreenLoanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GreenCreditService _greenCreditService = GreenCreditService();

  // Loan eligibility criteria
  static const double _minSustainabilityScore = 50.0;
  static const double _minGreenCreditBalance = 100.0;
  static const double _maxLoanAmount = 50000.0;
  static const double _minLoanAmount = 1000.0;

  // Apply for a green loan
  Future<Map<String, dynamic>> applyForLoan(
    String userId,
    double amount,
    LoanPurpose purpose,
    String description,
    int termMonths,
  ) async {
    try {
      // Get user's green credit profile
      final greenCredit = await _greenCreditService.getUserGreenCredit(userId);

      // Check eligibility
      final eligibilityCheck = _checkEligibility(greenCredit, amount);
      if (!eligibilityCheck['eligible']) {
        return {
          'success': false,
          'message': eligibilityCheck['message'],
          'loan': null,
        };
      }

      // Calculate interest rate based on sustainability score and credit balance
      final interestRate = GreenLoan.calculateInterestRate(
        greenCredit.sustainabilityScore,
        greenCredit.creditBalance,
      );

      // Create loan application
      final loan = GreenLoan(
        userId: userId,
        amount: amount,
        interestRate: interestRate,
        termMonths: termMonths,
        purpose: purpose,
        description: description,
        sustainabilityScore: greenCredit.sustainabilityScore,
        greenCreditBalance: greenCredit.creditBalance,
      );

      // Calculate monthly payment
      loan.calculateMonthlyPayment();

      // Save loan application
      final docRef =
          await _firestore.collection('greenLoans').add(loan.toJson());

      loan.id = docRef.id;

      // Auto-approve if criteria are met
      if (greenCredit.sustainabilityScore >= 80 &&
          greenCredit.creditBalance >= 500) {
        await _approveLoan(loan.id!);
        return {
          'success': true,
          'message': 'Loan approved automatically!',
          'loan': loan,
        };
      }

      return {
        'success': true,
        'message': 'Loan application submitted successfully',
        'loan': loan,
      };
    } catch (e) {
      print('🔥 [GREEN_LOAN] Error applying for loan: $e');
      return {
        'success': false,
        'message': 'Error submitting loan application',
        'loan': null,
      };
    }
  }

  // Check loan eligibility
  Map<String, dynamic> _checkEligibility(
      GreenCredit greenCredit, double amount) {
    if (greenCredit.sustainabilityScore < _minSustainabilityScore) {
      return {
        'eligible': false,
        'message':
            'Minimum sustainability score of $_minSustainabilityScore required',
      };
    }

    if (greenCredit.creditBalance < _minGreenCreditBalance) {
      return {
        'eligible': false,
        'message':
            'Minimum green credit balance of $_minGreenCreditBalance required',
      };
    }

    if (amount < _minLoanAmount) {
      return {
        'eligible': false,
        'message': 'Minimum loan amount is $_minLoanAmount',
      };
    }

    if (amount > _maxLoanAmount) {
      return {
        'eligible': false,
        'message': 'Maximum loan amount is $_maxLoanAmount',
      };
    }

    return {
      'eligible': true,
      'message': 'Eligible for loan',
    };
  }

  // Approve loan
  Future<bool> _approveLoan(String loanId) async {
    try {
      final doc = await _firestore.collection('greenLoans').doc(loanId).get();

      if (!doc.exists) return false;

      final loan = GreenLoan.fromJson(doc.data()!);
      loan.approve();

      await _firestore
          .collection('greenLoans')
          .doc(loanId)
          .update(loan.toJson());

      print('🌱 [GREEN_LOAN] Loan $loanId approved');
      return true;
    } catch (e) {
      print('🔥 [GREEN_LOAN] Error approving loan: $e');
      return false;
    }
  }

  // Get user's loans
  Future<List<GreenLoan>> getUserLoans(String userId) async {
    try {
      final query = await _firestore
          .collection('greenLoans')
          .where('userId', isEqualTo: userId)
          .orderBy('applicationDate', descending: true)
          .get();

      return query.docs.map((doc) {
        final loan = GreenLoan.fromJson(doc.data());
        loan.id = doc.id;
        return loan;
      }).toList();
    } catch (e) {
      print('🔥 [GREEN_LOAN] Error getting user loans: $e');
      return [];
    }
  }

  // Get loan by ID
  Future<GreenLoan?> getLoanById(String loanId) async {
    try {
      final doc = await _firestore.collection('greenLoans').doc(loanId).get();

      if (!doc.exists) return null;

      final loan = GreenLoan.fromJson(doc.data()!);
      loan.id = doc.id;
      return loan;
    } catch (e) {
      print('🔥 [GREEN_LOAN] Error getting loan: $e');
      return null;
    }
  }

  // Make loan payment
  Future<bool> makeLoanPayment(String loanId, double paymentAmount) async {
    try {
      final loan = await getLoanById(loanId);
      if (loan == null || loan.status != LoanStatus.active) return false;

      loan.makePayment(paymentAmount);

      await _firestore
          .collection('greenLoans')
          .doc(loanId)
          .update(loan.toJson());

      print('🌱 [GREEN_LOAN] Payment of $paymentAmount made for loan $loanId');
      return true;
    } catch (e) {
      print('🔥 [GREEN_LOAN] Error making payment: $e');
      return false;
    }
  }

  // Get loan statistics
  Future<Map<String, dynamic>> getLoanStatistics(String userId) async {
    try {
      final loans = await getUserLoans(userId);

      double totalBorrowed = 0.0;
      double totalRepaid = 0.0;
      double activeBalance = 0.0;
      int activeLoans = 0;
      int completedLoans = 0;

      for (GreenLoan loan in loans) {
        totalBorrowed += loan.amount;

        if (loan.status == LoanStatus.active) {
          activeLoans++;
          activeBalance += loan.remainingBalance;
        } else if (loan.status == LoanStatus.completed) {
          completedLoans++;
          totalRepaid += loan.amount;
        }
      }

      return {
        'totalBorrowed': totalBorrowed,
        'totalRepaid': totalRepaid,
        'activeBalance': activeBalance,
        'activeLoans': activeLoans,
        'completedLoans': completedLoans,
        'totalLoans': loans.length,
      };
    } catch (e) {
      print('🔥 [GREEN_LOAN] Error getting loan statistics: $e');
      return {};
    }
  }

  // Get loan recommendations
  Future<List<Map<String, dynamic>>> getLoanRecommendations(
      String userId) async {
    try {
      final greenCredit = await _greenCreditService.getUserGreenCredit(userId);

      List<Map<String, dynamic>> recommendations = [];

      // Solar installation recommendation
      if (greenCredit.sustainabilityScore >= 70) {
        recommendations.add({
          'purpose': LoanPurpose.solarInstallation,
          'title': 'Solar Panel Installation',
          'description': 'Install solar panels to reduce your carbon footprint',
          'recommendedAmount': 15000.0,
          'estimatedSavings': 'RM 200/month on electricity',
          'carbonReduction': '2.5 tons CO2/year',
          'interestRate': GreenLoan.calculateInterestRate(
            greenCredit.sustainabilityScore,
            greenCredit.creditBalance,
          ),
        });
      }

      // Electric vehicle recommendation
      if (greenCredit.sustainabilityScore >= 80 &&
          greenCredit.creditBalance >= 500) {
        recommendations.add({
          'purpose': LoanPurpose.electricVehicle,
          'title': 'Electric Vehicle Purchase',
          'description': 'Switch to an electric vehicle for zero emissions',
          'recommendedAmount': 30000.0,
          'estimatedSavings': 'RM 300/month on fuel',
          'carbonReduction': '3.0 tons CO2/year',
          'interestRate': GreenLoan.calculateInterestRate(
            greenCredit.sustainabilityScore,
            greenCredit.creditBalance,
          ),
        });
      }

      // Home insulation recommendation
      if (greenCredit.sustainabilityScore >= 60) {
        recommendations.add({
          'purpose': LoanPurpose.homeInsulation,
          'title': 'Home Insulation',
          'description':
              'Improve home energy efficiency with better insulation',
          'recommendedAmount': 8000.0,
          'estimatedSavings': 'RM 150/month on energy',
          'carbonReduction': '1.2 tons CO2/year',
          'interestRate': GreenLoan.calculateInterestRate(
            greenCredit.sustainabilityScore,
            greenCredit.creditBalance,
          ),
        });
      }

      return recommendations;
    } catch (e) {
      print('🔥 [GREEN_LOAN] Error getting loan recommendations: $e');
      return [];
    }
  }

  // Calculate loan affordability
  Map<String, dynamic> calculateLoanAffordability(
    double monthlyIncome,
    double monthlyExpenses,
    double loanAmount,
    double interestRate,
    int termMonths,
  ) {
    final monthlyRate = interestRate / 12 / 100;
    final monthlyPayment = loanAmount *
        (monthlyRate * pow(1 + monthlyRate, termMonths)) /
        (pow(1 + monthlyRate, termMonths) - 1);

    final disposableIncome = monthlyIncome - monthlyExpenses;
    final debtToIncomeRatio = monthlyPayment / monthlyIncome;
    final affordabilityRatio = monthlyPayment / disposableIncome;

    return {
      'monthlyPayment': monthlyPayment,
      'debtToIncomeRatio': debtToIncomeRatio,
      'affordabilityRatio': affordabilityRatio,
      'affordable': debtToIncomeRatio <= 0.4 && affordabilityRatio <= 0.7,
      'disposableIncome': disposableIncome,
    };
  }
}
