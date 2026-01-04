import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headache_diary/views/tabs/calendar/calendar_view.dart';
import 'package:headache_diary/views/tabs/calendar/day_view.dart';
import '../shared/main_layout.dart';
import '../tabs/statistics/statistics_view.dart';
import '../tabs/profile/profile_view.dart';

class MainView extends ConsumerStatefulWidget {
  final int? initialIndex;
  final DateTime? initialDate;

  const MainView({super.key, this.initialIndex, this.initialDate});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  late int _currentIndex;

  static DateTime get date => DateTime.now();

  List<Widget> get screens => [
        const CalendarView(),
        DayView(date: widget.initialDate ?? date),
        const StatisticsView(),
        const ProfileContent(),
      ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final navIndex = (_currentIndex >= 0 && _currentIndex <= 2) ? _currentIndex : 0;

    return Scaffold(
      appBar: buildMainAppBar(context, ref),
      body: screens[_currentIndex],
      bottomNavigationBar: buildMainBottomNavigationBar(navIndex, (index) {
        setState(() => _currentIndex = index);
      }),
    );
  }
}
