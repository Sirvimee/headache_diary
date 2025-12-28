import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../constants/app_colors.dart';
import '../../constants/strings.dart';

class DayView extends StatefulWidget {
  final DateTime date;
  const DayView({super.key, required this.date});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  late DateTime _currentDate;
  late final String uid;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime(widget.date.year, widget.date.month, widget.date.day);
    uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _goToPreviousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
    });
  }

  String _formattedTitle(DateTime date) {
    final now = DateTime.now();
    if (_isSameDate(date, now)) return Strings.today;

    const weekdays = [
      Strings.monday, Strings.tuesday,
      Strings.wednesday, Strings.thursday,
      Strings.friday, Strings.saturday, Strings.sunday,
    ];
    const months = [
      Strings.january,
      Strings.february,
      Strings.march,
      Strings.april,
      Strings.may,
      Strings.june,
      Strings.july,
      Strings.august,
      Strings.september,
      Strings.october,
      Strings.november,
      Strings.december,
    ];

    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];

    return '$weekday, $day. $month';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0.0;
            if (velocity > 0) {
              // swiped right -> previous day
              _goToPreviousDay();
            } else if (velocity < 0) {
              // swiped left -> next day
              _goToNextDay();
            }
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left, color: AppColors.buttonColor),
                      iconSize: 44,
                      onPressed: _goToPreviousDay,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _formattedTitle(_currentDate),
                          style: const TextStyle(
                            color: AppColors.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right, color: AppColors.buttonColor),
                      iconSize: 44,
                      onPressed: _goToNextDay,
                    ),
                  ],
                ),
              ),

              // Empty content area for future icons and notes from the database
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  child: const Center(
                    child: SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
