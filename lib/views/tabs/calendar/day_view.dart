import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../state/constants/firebase_field_name.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings.dart';
import '../../../widgets/svg_icon.dart';
import 'day_action_items.dart';
import '../../../state/calendar/backend/day_entry_storage.dart';
import '../../../state/calendar/models/day_entry_model.dart';

class DayView extends StatefulWidget {
  final DateTime date;
  const DayView({super.key, required this.date});

  static final activeDate = ValueNotifier<DateTime>(DateTime.now());

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  late DateTime _currentDate;
  late final String uid;
  final bool _loading = false;

  final List<ActionItem> items = actionItems;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime(widget.date.year, widget.date.month, widget.date.day);
    DayView.activeDate.value = _currentDate;
    uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _goToPreviousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
      DayView.activeDate.value = _currentDate;
    });
  }

  void _goToNextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
      DayView.activeDate.value = _currentDate;
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

  Stream<DayEntryModel?> _dayStream() {
    return const DayEntryStorage().dayEntryStream(_currentDate);
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
              _goToPreviousDay();
            } else if (velocity < 0) {
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

              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  child: StreamBuilder<DayEntryModel?>(
                    stream: _dayStream(),
                    builder: (context, snap) {
                      final data = snap.data;
                      final icons = data != null ? data.icons : <String, dynamic>{};
                      final meds = data != null ? data.medication : <String, dynamic>{};
                      final pillVal = meds[FirebaseFieldName.pill] ?? 0;
                      final pillCount = pillVal is int ? pillVal : int.tryParse(pillVal.toString()) ?? 0;
                      final notes = data?.notes ?? '';

                      final visible = <Widget>[];

                      if (pillCount > 0) {
                        visible.add(
                          Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgIcon(asset: 'assets/icons/tablett.svg', size: 36, color: AppColors.buttonColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$pillCount',
                                      style: const TextStyle(color: AppColors.buttonColor, fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                              ],
                            ),
                          ),
                        );
                      }

                      for (final it in items) {
                        if (it.key == 'pill_plus' || it.key == 'pill_minus' || it.key == FirebaseFieldName.notes) continue;
                        final present = icons.containsKey(it.key) && icons[it.key] == true;
                        if (!present) continue;

                        visible.add(
                          Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform(
                                  alignment: Alignment.center,
                                  transform: it.flip ? Matrix4.rotationY(3.14159) : Matrix4.identity(),
                                  child: SvgIcon(asset: it.asset, size: 36, color: AppColors.buttonColor),
                                ),
                                const SizedBox(height: 2),
                              ],
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (visible.isNotEmpty)
                              LayoutBuilder(builder: (ctx, constraints) {
                                const targetCellW = 80.0;
                                const spacing = 6.0;
                                final cols = 3;
                                final maxWidth = constraints.maxWidth;
                                final totalSpacing = (cols - 1) * spacing;
                                final availableForCells = maxWidth - totalSpacing;
                                final cellW = (availableForCells / cols).clamp(48.0, targetCellW);
                                final cellH = 56.0;
                                final gridWidth = cellW * cols + totalSpacing;

                                return Center(
                                  child: SizedBox(
                                    width: gridWidth,
                                    child: GridView.count(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisCount: cols,
                                      mainAxisSpacing: 4,
                                      crossAxisSpacing: 4,
                                      childAspectRatio: cellW / cellH,
                                      children: visible,
                                    ),
                                  ),
                                );
                              })
                             else
                               const SizedBox.shrink(),

                            const SizedBox(height: 12),

                            if (notes.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(Strings.additionalNotes,
                                        style: TextStyle(
                                          color: AppColors.buttonColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 22,
                                        )
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      notes,
                                      style: const TextStyle(
                                        color: AppColors.textColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (_loading) const LinearProgressIndicator(),
                          ],
                        ),
                      );
                    },
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
