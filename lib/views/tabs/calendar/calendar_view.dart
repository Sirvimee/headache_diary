import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:headache_diary/state/constants/firebase_field_name.dart';
import '../../../state/calendar/models/day_entry_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings.dart';
import '../../main/main_view.dart';
import '../../../widgets/svg_icon.dart';
import '../../../state/calendar/backend/day_entry_storage.dart';

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
  final int _basePage = 1200;
  late final DateTime _baseDate;

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

  Stream<Map<DateTime, DayEntryModel>> monthStream() {
    final start = DateTime(focused.year, focused.month, 1);
    final end = DateTime(focused.year, focused.month + 1, 0);

    return const DayEntryStorage().monthEntries(start, end);
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
    return StreamBuilder<Map<DateTime, DayEntryModel>>(
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

                            // The month grid fills the remaining space
                            Expanded(
                              child: LayoutBuilder(builder: (context, constraints) {
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

                                    final DayEntryModel? data = day != null
                                        ? entries[DateTime(year, month, day)]
                                        : null;

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
                                        margin: const EdgeInsets.all(2.0),
                                        padding: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          color: day != null ? AppColors.accentColor : Colors.transparent,
                                          border: isToday ? Border.all(color: AppColors.buttonColor, width: 3) : null,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            if (day != null)
                                              Align(
                                                alignment: Alignment.topCenter,
                                                child: Text(
                                                  '$day',
                                                  style: const TextStyle(
                                                    color: AppColors.textColor,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),

                                            const SizedBox(height: 8),

                                            // Icons area below the day number
                                            Expanded(
                                              child: Builder(builder: (ctx) {
                                                final iconsMap = data?.icons ?? <String, dynamic>{};
                                                final medsMap = data?.medication ?? <String, dynamic>{};
                                                final pillVal = medsMap[FirebaseFieldName.pill] ?? 0;
                                                final pillCount = pillVal is int ? pillVal : int.tryParse(pillVal.toString()) ?? 0;
                                                final notesStr = data?.notes ?? '';

                                                Widget smallIcon(bool present, String asset, {bool flip = false}) {
                                                  if (!present) return const SizedBox.shrink();
                                                  return Center(
                                                    child: Transform(
                                                      alignment: Alignment.center,
                                                      transform: flip ? Matrix4.rotationY(3.14159) : Matrix4.identity(),
                                                      child: SvgIcon(asset: asset, size: 9.5, color: AppColors.buttonColor),
                                                    ),
                                                  );
                                                }

                                                Widget pillWidget(int count) {
                                                  if (count <= 0) return const SizedBox.shrink();
                                                  return Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: Alignment.center,
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            SvgIcon(asset: 'assets/icons/tablett.svg', size: 9.5, color: AppColors.buttonColor),
                                                            const SizedBox(width: 2),
                                                            Text('$count', style: const TextStyle(color: AppColors.buttonColor, fontSize: 9, fontWeight: FontWeight.w600)),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }

                                                // Build 4x4 layout by collecting present icons per row so there are no gaps
                                                List<Widget> padRow(List<Widget> r) {
                                                  final out = List<Widget>.from(r);
                                                  while (out.length < 4) {
                                                    out.add(const SizedBox.shrink());
                                                  }
                                                  if (out.length > 4) out.removeRange(4, out.length);
                                                  return out;
                                                }

                                                // Row 1: headache icons (left, full, right)
                                                final row1 = <Widget>[];
                                                if (iconsMap[FirebaseFieldName.peavaluLeft] == true) row1.add(smallIcon(true, 'assets/icons/peavalu-pool.svg'));
                                                if (iconsMap[FirebaseFieldName.peavaluFull] == true) row1.add(smallIcon(true, 'assets/icons/peavalu-terve.svg'));
                                                if (iconsMap[FirebaseFieldName.peavaluRight] == true) row1.add(smallIcon(true, 'assets/icons/peavalu-pool.svg', flip: true));

                                                // Row 2: pills (with count) and systal
                                                final row2 = <Widget>[];
                                                if (pillCount > 0) row2.add(pillWidget(pillCount));
                                                if (iconsMap[FirebaseFieldName.systal] == true) row2.add(smallIcon(true, 'assets/icons/systal.svg'));

                                                // Row 3: sex, gym, run, wine
                                                final row3 = <Widget>[];
                                                if (iconsMap[FirebaseFieldName.sex] == true) row3.add(smallIcon(true, 'assets/icons/heart.svg'));
                                                if (iconsMap[FirebaseFieldName.gym] == true) row3.add(smallIcon(true, 'assets/icons/gym.svg'));
                                                if (iconsMap[FirebaseFieldName.run] == true) row3.add(smallIcon(true, 'assets/icons/jooksmine.svg'));
                                                if (iconsMap[FirebaseFieldName.wine] == true) row3.add(smallIcon(true, 'assets/icons/wine.svg'));

                                                // Row 4: blood, notes
                                                final row4 = <Widget>[];
                                                if (iconsMap[FirebaseFieldName.blood] == true) row4.add(smallIcon(true, 'assets/icons/blood.svg'));
                                                if (notesStr.isNotEmpty) row4.add(smallIcon(true, 'assets/icons/notes.svg'));

                                                final gridItems = <Widget>[...padRow(row1), ...padRow(row2), ...padRow(row3), ...padRow(row4)];

                                                return GridView.count(
                                                  crossAxisCount: 4,
                                                  childAspectRatio: 1,
                                                  mainAxisSpacing: 2,
                                                  crossAxisSpacing: 2,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  padding: EdgeInsets.zero,
                                                  children: gridItems,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
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

}
