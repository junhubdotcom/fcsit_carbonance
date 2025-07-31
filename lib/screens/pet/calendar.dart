import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:steadypunpipi_vhack/models/expense.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';
import 'package:steadypunpipi_vhack/widgets/transaction_widgets/transaction_container.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPet extends StatefulWidget {
  const CalendarPet({super.key});

  @override
  State<CalendarPet> createState() => _CalendarPetState();
}

class _CalendarPetState extends State<CalendarPet> {
  DatabaseService _databaseService = DatabaseService();
  List<Expense> transactionList = [];
  late final ValueNotifier<List<Expense>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    getAllExpenses();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    transactionList = []; 
    kEvents.clear();
    super.dispose();
  }

  List<Expense> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  List<Expense> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    List<Expense> events = [];
    for (final d in days) {
      events.addAll(_getEventsForDay(d));
    }
    return events;
  }

  Future<void> getAllExpenses() async {
    transactionList = await _databaseService.getAllExpenses();
    kEvents.clear(); // Clear any existing data
    if (transactionList.isNotEmpty) {
      for (var transaction in transactionList) {
        Timestamp timestamp = transaction.dateTime;
        DateTime dateTime = timestamp.toDate();
        DateTime dateOnly =
            DateTime(dateTime.year, dateTime.month, dateTime.day);

        if (kEvents.containsKey(dateOnly)) {
          kEvents[dateOnly]!.add(transaction);
        } else {
          kEvents[dateOnly] = [transaction];
        }
      }
    } else {
      print("No expenses found.");
    }
    // Trigger a rebuild to update the calendar
    setState(() {
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
    print("this is selected event: ${_selectedEvents}");
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Expense>(
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: const CalendarStyle(
            // Use `CalendarStyle` to customize the UI
            outsideDaysVisible: false,
          ),
          onDaySelected: _onDaySelected,
          onRangeSelected: _onRangeSelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Expense>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 0),
                    child: TransactionContainer(
                        transactionId: transactionList[index].id ?? "",),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

final kEvents = LinkedHashMap<DateTime, List<Expense>>(
  equals: isSameDay,
  hashCode: getHashCode,
);

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
