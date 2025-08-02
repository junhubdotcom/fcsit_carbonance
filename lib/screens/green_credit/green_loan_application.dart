import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class GreenLoanApplication extends StatefulWidget {
  @override
  _GreenLoanApplicationState createState() => _GreenLoanApplicationState();
}

class _GreenLoanApplicationState extends State<GreenLoanApplication> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '15000');
  final _descriptionController =
      TextEditingController(text: 'Solar panel installation for my home');

  String _selectedPurpose = 'Solar Installation';
  int _selectedTerm = 36;
  bool _isLoading = false;
  bool _isDemoMode = true;

  // Mock data for demo
  final Map<String, dynamic> _mockEligibility = {
    'sustainabilityScore': 85.0,
    'creditBalance': 750.0,
    'eligible': true,
  };

  final List<String> _loanPurposes = [
    'Solar Installation',
    'Electric Vehicle',
    'Home Insulation',
    'Renewable Energy',
    'Green Home Improvement',
  ];

  final List<int> _loanTerms = [12, 24, 36, 48, 60];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Apply for Green Loan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF27AE60),
        elevation: 0,
        actions: [
          // Demo mode toggle
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Switch(
              value: _isDemoMode,
              onChanged: (value) {
                setState(() {
                  _isDemoMode = value;
                });
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDemoModeBanner(),
            SizedBox(height: 16),
            _buildEligibilityCard(),
            SizedBox(height: 24),
            _buildApplicationForm(),
            SizedBox(height: 24),
            _buildLoanCalculator(),
            SizedBox(height: 24),
            _buildLoanRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoModeBanner() {
    if (!_isDemoMode) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFFFEAA7)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF856404), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo Mode: All data is simulated for display purposes',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Color(0xFF856404),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityCard() {
    final score = _mockEligibility['sustainabilityScore'];
    final creditBalance = _mockEligibility['creditBalance'];
    final eligible = _mockEligibility['eligible'];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: eligible
              ? [Color(0xFFE8F5E8), Color(0xFFD4EDDA)]
              : [Color(0xFFFFF3CD), Color(0xFFFFEAA7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: eligible ? Color(0xFF27AE60) : Color(0xFFFFC107),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: eligible ? Color(0xFF27AE60) : Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  eligible ? Icons.check_circle : Icons.warning,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eligible
                          ? 'Eligible for Green Loans'
                          : 'Not Yet Eligible',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: eligible ? Color(0xFF27AE60) : Color(0xFF856404),
                      ),
                    ),
                    Text(
                      eligible
                          ? 'You can apply for sustainable financing'
                          : 'Improve your sustainability score',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: eligible ? Color(0xFF27AE60) : Color(0xFF856404),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildEligibilityMetric(
                  'Sustainability Score',
                  '${score.toStringAsFixed(0)}',
                  score >= 50 ? Color(0xFF27AE60) : Color(0xFFE74C3C),
                  Icons.eco,
                ),
              ),
              Expanded(
                child: _buildEligibilityMetric(
                  'Green Credits',
                  '${creditBalance.toStringAsFixed(0)}',
                  creditBalance >= 100 ? Color(0xFF27AE60) : Color(0xFFE74C3C),
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityMetric(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationForm() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: Color(0xFF27AE60), size: 24),
                SizedBox(width: 8),
                Text(
                  'Loan Application',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Loan Purpose
            _buildFormField(
              'Loan Purpose',
              DropdownButtonFormField<String>(
                value: _selectedPurpose,
                decoration: _buildInputDecoration('Select loan purpose'),
                items: _loanPurposes.map((purpose) {
                  return DropdownMenuItem(
                    value: purpose,
                    child: Text(purpose),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPurpose = value!;
                  });
                },
              ),
            ),

            // Loan Amount
            _buildFormField(
              'Loan Amount (RM)',
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('Enter loan amount')
                    .copyWith(prefixText: 'RM '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter loan amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 1000) {
                    return 'Minimum loan amount is RM 1,000';
                  }
                  if (amount > 50000) {
                    return 'Maximum loan amount is RM 50,000';
                  }
                  return null;
                },
              ),
            ),

            // Loan Term
            _buildFormField(
              'Loan Term (Months)',
              DropdownButtonFormField<int>(
                value: _selectedTerm,
                decoration: _buildInputDecoration('Select loan term'),
                items: _loanTerms.map((term) {
                  return DropdownMenuItem(
                    value: term,
                    child: Text('$term months'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTerm = value!;
                  });
                },
              ),
            ),

            // Description
            _buildFormField(
              'Description',
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration:
                    _buildInputDecoration('Describe your sustainable project'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a description';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF27AE60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Submit Application',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: 8),
        child,
        SizedBox(height: 16),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF27AE60), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
    );
  }

  Widget _buildLoanCalculator() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount == 0) return SizedBox.shrink();

    final interestRate = 4.5; // Mock interest rate
    final monthlyRate = interestRate / 12 / 100;
    final monthlyPayment = amount *
        (monthlyRate * pow(1 + monthlyRate, _selectedTerm)) /
        (pow(1 + monthlyRate, _selectedTerm) - 1);
    final totalPayment = monthlyPayment * _selectedTerm;
    final totalInterest = totalPayment - amount;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF2196F3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: Color(0xFF1976D2), size: 24),
              SizedBox(width: 8),
              Text(
                'Loan Calculator',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _buildCalculatorItem(
                      'Interest Rate',
                      '${interestRate.toStringAsFixed(1)}%',
                      Icons.percent,
                      Color(0xFF1976D2))),
              Expanded(
                  child: _buildCalculatorItem(
                      'Monthly Payment',
                      'RM ${monthlyPayment.toStringAsFixed(0)}',
                      Icons.payment,
                      Color(0xFF1976D2))),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildCalculatorItem(
                      'Total Interest',
                      'RM ${totalInterest.toStringAsFixed(0)}',
                      Icons.trending_up,
                      Color(0xFF1976D2))),
              Expanded(
                  child: _buildCalculatorItem(
                      'Total Payment',
                      'RM ${totalPayment.toStringAsFixed(0)}',
                      Icons.account_balance_wallet,
                      Color(0xFF1976D2))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanRecommendations() {
    final recommendations = [
      {
        'title': 'Solar Panel Installation',
        'description': 'Install solar panels to reduce your carbon footprint',
        'amount': 'RM 15,000',
        'savings': 'RM 200/month',
        'icon': '☀️',
        'color': Color(0xFFFF9800),
      },
      {
        'title': 'Electric Vehicle',
        'description': 'Switch to an electric vehicle for zero emissions',
        'amount': 'RM 30,000',
        'savings': 'RM 300/month',
        'icon': '🚗',
        'color': Color(0xFF4CAF50),
      },
      {
        'title': 'Home Insulation',
        'description': 'Improve home energy efficiency with better insulation',
        'amount': 'RM 8,000',
        'savings': 'RM 150/month',
        'icon': '🏠',
        'color': Color(0xFF2196F3),
      },
    ];

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFFFFC107), size: 24),
              SizedBox(width: 8),
              Text(
                'Recommended Loans',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...recommendations
              .map((rec) => _buildRecommendationCard(rec))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rec['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rec['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rec['color'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rec['icon'],
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  rec['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      rec['amount'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: rec['color'],
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Save ${rec['savings']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: rec['color'], size: 16),
        ],
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 24),
            SizedBox(width: 8),
            Text(
              'Application Submitted',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Your green loan application has been submitted successfully! We will review your application and get back to you within 2-3 business days.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: Color(0xFF27AE60),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
