import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/pill_badge.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings.dart';
import '../../main/main_view.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime focused = DateTime.now();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  // Page view setup for vertical month swiping
  late final PageController _pageController;
  final int _basePage = 1200; // large center index
  late final DateTime _baseDate; // the date that corresponds to _basePage

  final List<String> _weekDays = [
    Strings.mo, Strings.tu, Strings.we, Strings.thu,
    Strings.fri, Strings.sat, Strings.sun,
  ];

  final List<String> _monthsEst = [
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

  @override
  void initState() {
    super.initState();
    _baseDate = DateTime(focused.year, focused.month, 1);
    _pageController = PageController(initialPage: _basePage);
  }

  Stream<Map<DateTime, Map<String, dynamic>>> monthStream() {
    final start = DateTime(focused.year, focused.month, 1);
    final end = DateTime(focused.year, focused.month + 1, 0);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('days')
        .where('date', isGreaterThanOrEqualTo: _fmt(start))
        .where('date', isLessThanOrEqualTo: _fmt(end))
        .snapshots()
        .map((snap) {
      final map = <DateTime, Map<String, dynamic>>{};
      for (var d in snap.docs) {
        final data = d.data();
        final dt = DateTime.parse(data['date']);
        map[DateTime(dt.year, dt.month, dt.day)] = data;
      }
      return map;
    });
  }

  List<int?> _generateMonthGrid(int year, int month) {
    // Return a 42-length list (6 weeks x 7 days) with integers for day numbers or null for empty cells.
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // First day of month with Monday as 0
    int firstDay = DateTime(year, month, 1).weekday; // 1 = Mon, 7 = Sun
    // convert so Monday=0..Sunday=6 -> our offset
    final firstDayIndex = (firstDay + 6) % 7; // if weekday=1 -> 0, weekday=7 -> 6

    final List<int?> grid = List.filled(42, null);
    int writeIndex = firstDayIndex;
    for (int d = 1; d <= daysInMonth; d++) {
      if (writeIndex >= 42) break;
      grid[writeIndex] = d;
      writeIndex++;
    }
    return grid;
  }

  bool _isToday(int? day, int year, int month) {
    if (day == null) return false;
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<DateTime, Map<String, dynamic>>>(
      stream: monthStream(),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? {};

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Weekday header (fixed)
                Container(
                  height: 36,
                  color: AppColors.accentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _weekDays
                        .map(
                          (d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: const TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                // PageView with vertical months — expand to fill available space so pages are adjacent
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index) {
                      final offset = index - _basePage;
                      final newFocused = DateTime(_baseDate.year, _baseDate.month + offset, 1);
                      setState(() => focused = newFocused);
                    },
                    itemBuilder: (context, index) {
                      final offset = index - _basePage;
                      final monthDate = DateTime(_baseDate.year, _baseDate.month + offset, 1);
                      final year = monthDate.year;
                      final month = monthDate.month;
                      final grid = _generateMonthGrid(year, month);

                      // Build the page so the grid fills the available space.
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Column(
                          children: [
                            Text(
                              '${_monthsEst[month - 1]} $year',
                              style: const TextStyle(
                                color: AppColors.textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),

                            // Let the grid take remaining vertical space so it never overflows the page.
                            Expanded(
                              child: LayoutBuilder(builder: (context, constraints) {
                                // Calculate cell aspect ratio based on available width/height so grid fills the area.
                                final availW = constraints.maxWidth;
                                final availH = constraints.maxHeight;
                                final cellW = availW / 7.0;
                                final cellH = availH / 5.0;
                                final aspect = cellW / cellH;

                                return GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    mainAxisSpacing: 0,
                                    crossAxisSpacing: 0,
                                    childAspectRatio: aspect,
                                  ),
                                  itemCount: 42,
                                  itemBuilder: (ctx, i) {
                                    final day = grid[i];

                                    // Look up entry for this day
                                    Map<String, dynamic>? data;
                                    if (day != null) {
                                      final key = DateTime(year, month, day);
                                      data = entries[key];
                                    }

                                    final meds = data != null
                                        ? Map<String, dynamic>.from(data['medication'] ?? {})
                                        : <String, dynamic>{};
                                    final pillCount = meds.values.fold<int>(0, (s, v) => s + (v as int));

                                    final hasInjection = data != null && data['preventiveInjection'] == true;
                                    final hasReminder = data != null && data['reminder']?['enabled'] == true;

                                    final isToday = _isToday(day, year, month);

                                    return GestureDetector(
                                      onTap: day == null
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => MainView(initialIndex: 1, initialDate: DateTime(year, month, day)),
                                                ),
                                              );
                                            },
                                      child: Container(
                                        margin: EdgeInsets.all(2.0),
                                        decoration: BoxDecoration(
                                          color: day != null ? AppColors.accentColor : Colors.transparent,
                                          border: isToday
                                              ? Border.all(color: AppColors.buttonColor, width: 3)
                                              : null,
                                        ),
                                        child: Stack(
                                          children: [
                                            if (day != null)
                                              Center(
                                                child: Text(
                                                  '$day',
                                                  style: const TextStyle(
                                                    color: AppColors.textColor,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            // Markers
                                            if ((pillCount > 0) || hasInjection)
                                              Positioned(
                                                top: 6,
                                                right: 6,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (pillCount > 0) PillWithCount(count: pillCount),
                                                    if (hasInjection) InjectionWithClock(hasReminder: hasReminder),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),

                            const SizedBox(height: 5),

                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmt(DateTime d) => d.toIso8601String().substring(0, 10);
}
