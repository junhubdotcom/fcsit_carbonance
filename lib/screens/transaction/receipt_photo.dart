import 'dart:io';
import 'package:flutter/material.dart';
import 'package:steadypunpipi_vhack/models/complete_expense.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/screens/transaction/record_transaction.dart';
import 'package:steadypunpipi_vhack/services/api_service.dart';

class ReceiptPhoto extends StatefulWidget {
  String imgPath;

  ReceiptPhoto({required this.imgPath, super.key});

  @override
  State<ReceiptPhoto> createState() => _ReceiptPhotoState();
}

class _ReceiptPhotoState extends State<ReceiptPhoto> {
  final ApiService _apiService = ApiService();
  bool _isProcessing = false; // Add loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 45,
            )),
        backgroundColor: Colors.black,
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Image.file(File(widget.imgPath), fit: BoxFit.cover),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 120,
                color: Colors.black,
                child: Center(
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: FloatingActionButton(
                      child: _isProcessing
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : Icon(
                              Icons.check,
                              size: 35,
                              color: Colors.black,
                            ),
                      backgroundColor: _isProcessing ? Colors.grey : Colors.white,
                      shape: CircleBorder(),
                      onPressed: _isProcessing
                          ? null // Disable button while processing
                          : () async {
                              setState(() {
                                _isProcessing = true; // Start loading
                              });
                              
                              try {
                                print("Generate Content");
                                CompleteExpense completeExpense =
                                    await _apiService.generateContent(widget.imgPath);
                                print("Content Generated");
                                
                                if (mounted) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RecordTransaction(
                                                completeExpense: completeExpense,
                                              )));
                                }
                              } catch (e) {
                                print("Error generating content: $e");
                                if (mounted) {
                                  // Show error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error processing receipt: $e'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  // Reset loading state on error
                                  setState(() {
                                    _isProcessing = false;
                                  });
                                }
                              }
                            },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
