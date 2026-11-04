import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  State<DayView> createState() => DayViewState();
}

class DayViewState extends State<DayView> {
  late DateTime _currentDate;
  late final String uid;
  final bool _loading = false;
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  final List<ActionItem> items = actionItems;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
    );
    DayView.activeDate.value = _currentDate;
    uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _goToPreviousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 1));
      DayView.activeDate.value = _currentDate;
    });
  }

  void _goToNextDay() {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: 1));
      DayView.activeDate.value = _currentDate;
    });
  }

  String _formattedTitle(DateTime date) {
    final now = DateTime.now();
    if (_isSameDate(date, now)) return Strings.today;

    final weekdays = [
      Strings.monday,
      Strings.tuesday,
      Strings.wednesday,
      Strings.thursday,
      Strings.friday,
      Strings.saturday,
      Strings.sunday,
    ];
    final months = [
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
    return DayEntryStorage().dayEntryStream(_currentDate);
  }

  bool get _isToday => _isSameDate(_currentDate, DateTime.now());

  Future<void> toggleVoiceEntry() async {
    if (!_isToday) {
      _currentDate = DateTime.now();
      DayView.activeDate.value = _currentDate;
      if (mounted) setState(() {});
    }
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize(
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(Strings.voicePermissionDenied)),
          );
        }
      },
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _isListening = false);
        }
      },
    );
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Strings.voiceRecognitionUnavailable)),
        );
      }
      return;
    }

    if (mounted) setState(() => _isListening = true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: 'et_EE',
        listenFor: Duration(seconds: 15),
        pauseFor: Duration(seconds: 3),
        partialResults: false,
      ),
      onResult: (result) async {
        if (!result.finalResult || !mounted) return;
        await _saveVoiceMatches(result.recognizedWords);
      },
    );
  }

  Future<void> _saveVoiceMatches(String spokenText) async {
    final text = spokenText.toLowerCase();
    final matches = <String>{};
    if (text.contains(Strings.voiceKeywordHeadache) &&
        text.contains(Strings.voiceKeywordLeft)) {
      matches.add(FirebaseFieldName.peavaluLeft);
    } else if (text.contains(Strings.voiceKeywordHeadache) &&
        text.contains(Strings.voiceKeywordRight)) {
      matches.add(FirebaseFieldName.peavaluRight);
    } else if (text.contains(Strings.voiceKeywordHeadache) &&
        (text.contains(Strings.voiceKeywordWholeHead) ||
            text.contains(Strings.voiceKeywordEntireHead))) {
      matches.add(FirebaseFieldName.peavaluFull);
    } else if (text.contains(Strings.voiceKeywordHeadache)) {
      matches.add(FirebaseFieldName.peavaluFull);
    }
    if (text.contains(Strings.voiceKeywordEyePain)) {
      matches.add(FirebaseFieldName.eyePain);
    }
    if (text.contains(Strings.voiceKeywordVomiting) ||
        text.contains(Strings.voiceKeywordNausea)) {
      matches.add(FirebaseFieldName.vomit);
    }
    if (text.contains(Strings.voiceKeywordPill) ||
        text.contains(Strings.voiceKeywordPillShort)) {
      matches.add(FirebaseFieldName.pill);
    }
    if (matches.isEmpty) {
      if (Platform.isAndroid) {
        await _playRecognitionFailureSound();
      } else {
        await SystemSound.play(SystemSoundType.alert);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Strings.voiceNothingRecognized)),
        );
      }
      return;
    }
    final current = await const DayEntryStorage()
        .dayEntryStream(_currentDate)
        .first;
    for (final key in matches) {
      if (key == FirebaseFieldName.pill) {
        await const DayEntryStorage().changePillCount(_currentDate, 1);
      } else if (current?.icons[key] != true) {
        await const DayEntryStorage().toggleIcon(_currentDate, key);
      }
    }
    await SystemSound.play(SystemSoundType.click);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.voiceSaved)),
      );
    }
  }

  Future<void> _playRecognitionFailureSound() async {
    if (!Platform.isAndroid) return;
    try {
      await const MethodChannel(
        'com.example.headache_diary/speech_feedback',
      ).invokeMethod<void>('playRecognitionFailure');
    } on PlatformException catch (_) {
      await SystemSound.play(SystemSoundType.alert);
    } on MissingPluginException {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
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
                padding: EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_left,
                        color: AppColors.buttonColor,
                      ),
                      iconSize: 44,
                      onPressed: _goToPreviousDay,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _formattedTitle(_currentDate),
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_right,
                        color: AppColors.buttonColor,
                      ),
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
                      final icons = data != null
                          ? data.icons
                          : <String, dynamic>{};
                      final meds = data != null
                          ? data.medication
                          : <String, dynamic>{};
                      final pillVal = meds[FirebaseFieldName.pill] ?? 0;
                      final pillCount = pillVal is int
                          ? pillVal
                          : int.tryParse(pillVal.toString()) ?? 0;
                      final notes = data?.notes ?? '';
                      final preventivePillName =
                          meds[FirebaseFieldName.preventivePillName]
                              ?.toString();
                      final preventivePillGrams =
                          meds[FirebaseFieldName.preventivePillGrams]
                              ?.toString();

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
                                    SvgIcon(
                                      asset: 'assets/icons/tablett.svg',
                                      size: 36,
                                      color: AppColors.buttonColor,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '$pillCount',
                                      style: TextStyle(
                                        color: AppColors.buttonColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2),
                              ],
                            ),
                          ),
                        );
                      }

                      for (final it in items) {
                        if (it.key == 'pill_plus' ||
                            it.key == 'pill_minus' ||
                            it.key == FirebaseFieldName.notes) {
                          continue;
                        }
                        final present =
                            icons.containsKey(it.key) && icons[it.key] == true;
                        if (!present) continue;

                        visible.add(
                          Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform(
                                  alignment: Alignment.center,
                                  transform: it.flip
                                      ? Matrix4.rotationY(3.14159)
                                      : Matrix4.identity(),
                                  child: SvgIcon(
                                    asset: it.asset,
                                    size: 36,
                                    color: AppColors.buttonColor,
                                  ),
                                ),
                                SizedBox(height: 2),
                              ],
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (visible.isNotEmpty)
                              LayoutBuilder(
                                builder: (ctx, constraints) {
                                  final targetCellW = 80.0;
                                  final spacing = 6.0;
                                  final cols = 3;
                                  final maxWidth = constraints.maxWidth;
                                  final totalSpacing = (cols - 1) * spacing;
                                  final availableForCells =
                                      maxWidth - totalSpacing;
                                  final cellW = (availableForCells / cols)
                                      .clamp(48.0, targetCellW);
                                  final cellH = 56.0;
                                  final gridWidth = cellW * cols + totalSpacing;

                                  return Center(
                                    child: SizedBox(
                                      width: gridWidth,
                                      child: GridView.count(
                                        shrinkWrap: true,
                                        physics:
                                            NeverScrollableScrollPhysics(),
                                        crossAxisCount: cols,
                                        mainAxisSpacing: 4,
                                        crossAxisSpacing: 4,
                                        childAspectRatio: cellW / cellH,
                                        children: visible,
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              SizedBox.shrink(),

                            SizedBox(height: 12),

                            if (icons[FirebaseFieldName.preventivePill] ==
                                    true &&
                                preventivePillName != null &&
                                preventivePillGrams != null)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Text(
                                  '$preventivePillName, $preventivePillGrams g',
                                  style: TextStyle(
                                    color: AppColors.textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                            if (notes.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Strings.additionalNotes,
                                      style: TextStyle(
                                        color: AppColors.buttonColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      notes,
                                      style: TextStyle(
                                        color: AppColors.textColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (_loading) LinearProgressIndicator(),
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
