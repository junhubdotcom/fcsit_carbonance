import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steadypunpipi_vhack/common/constants.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

class DateSelector extends StatefulWidget {
  final int selectedIndex;
  final Function(int, DateTime) onSelectionChanged;

  const DateSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelectionChanged,
  });

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late int _selectedIndex;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));

      if (_selectedIndex == 1) {
        // Weekly
        _selectedDate =
            _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      } else if (_selectedIndex == 2) {
        // Monthly
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      }
    });
    widget.onSelectionChanged(_selectedIndex, _selectedDate);
  }

  void _onSegmentChanged(int value) {
    setState(() {
      _selectedIndex = value;
      widget.onSelectionChanged(value, _selectedDate);
      _selectedDate = DateTime.now(); // Reset date when switching
    });

    widget.onSelectionChanged(_selectedIndex, _selectedDate);
  }

  DateTime get startDate {
    switch (_selectedIndex) {
      case 0:
        return _selectedDate;
      case 1:
        return _selectedDate
            .subtract(Duration(days: _selectedDate.weekday - 1));
      case 2:
        return DateTime(_selectedDate.year, _selectedDate.month, 1);
      default:
        return _selectedDate;
    }
  }

  DateTime get endDate {
    switch (_selectedIndex) {
      case 0:
        return _selectedDate.add(Duration(days: 1));
      case 1:
        return startDate.add(Duration(days: 7));
      case 2:
        return DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      default:
        return _selectedDate;
    }
  }

  String _getFormattedDateRange() {
    if (_selectedIndex == 0) {
      return _formatDate(startDate);
    }
    return "${_formatDate(startDate)} - ${_formatDate(endDate)}";
  }

  String _formatDate(DateTime date) {
    return "${_getMonthName(date.month)} ${date.day}";
  }

  String _getMonthName(int month) {
    List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSegmentedControl(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedIndex == 0
                        ? "Today"
                        : _selectedIndex == 1
                            ? "This week"
                            : "This month",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFormattedDateRange(),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildNavButton(
                      Icons.chevron_left,
                      () => _changeDate(-(_selectedIndex == 0
                          ? 1
                          : _selectedIndex == 1
                              ? 7
                              : 30))),
                  const SizedBox(width: 8),
                  _buildNavButton(
                      Icons.chevron_right,
                      () => _changeDate((_selectedIndex == 0
                          ? 1
                          : _selectedIndex == 1
                              ? 7
                              : 30))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Center(
      child: Container(
        width: 350,
        height: 40,
        padding: const EdgeInsets.all(AppConstants.paddingExtraSmall),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
        ),
        child: CustomSlidingSegmentedControl<int>(
          isStretch: true,
          initialValue: _selectedIndex,
          children: {
            0: _buildSegmentText("Daily", 0),
            1: _buildSegmentText("Weekly", 1),
            2: _buildSegmentText("Monthly", 2),
          },
          decoration: const BoxDecoration(color: Colors.transparent),
          thumbDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4.0,
                spreadRadius: 1.0,
                offset: const Offset(0.0, 2.0),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          onValueChanged: _onSegmentChanged,
        ),
      ),
    );
  }

  Widget _buildSegmentText(String text, int index) {
    return Text(
      text,
      style: GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color:
            _selectedIndex == index ? AppConstants.infoColor : Colors.black54,
      ),
    );
  }
}
