import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:headache_diary/views/tabs/calendar/calendar_view.dart';
import 'package:headache_diary/views/tabs/calendar/day_view.dart';
import '../shared/main_layout.dart';
import '../tabs/statistics/statistics_monthly_view.dart';
import '../tabs/statistics/statistics_period_view.dart';
import '../tabs/profile/profile_view.dart';

class MainView extends ConsumerStatefulWidget {
  final int? initialIndex;
  final DateTime? initialDate;

  const MainView({super.key, this.initialIndex, this.initialDate});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView>
    with WidgetsBindingObserver {
  late int _currentIndex;
  Map<String, dynamic>? _pendingStatsParams;
  final _dayViewKey = GlobalKey<DayViewState>();

  static DateTime get date => DateTime.now();

  List<Widget> get screens => [
        const CalendarView(),
        DayView(
          key: _dayViewKey,
          date: widget.initialDate ?? date,
        ),
        // Build StatisticsView with any pending params
        if (_pendingStatsParams != null && _pendingStatsParams!['mode'] == 'period' && _pendingStatsParams!['start'] != null && _pendingStatsParams!['end'] != null)
          StatisticsPeriodView(start: _pendingStatsParams!['start'], end: _pendingStatsParams!['end'])
        else
          const StatisticsView.monthly(),
        const ProfileContent(),
      ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex ?? 0;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consumeAddSymptomShortcut();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _consumeAddSymptomShortcut();
    }
  }

  Future<void> _consumeAddSymptomShortcut() async {
    try {
      final requested = await const MethodChannel(
        'com.example.headache_diary/speech_feedback',
      ).invokeMethod<bool>('consumeAddSymptomShortcut');
      if (requested != true || !mounted) return;
      _startVoiceEntry();
    } on PlatformException {
      // The shortcut channel is unavailable on this platform.
    } on MissingPluginException {
      // The shortcut channel is unavailable on this platform.
    }
  }

  void _startVoiceEntry() {
    if (_currentIndex != 1) {
      setState(() => _currentIndex = 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dayViewKey.currentState?.toggleVoiceEntry();
      });
      return;
    }

    _dayViewKey.currentState?.toggleVoiceEntry();
  }

  @override
  Widget build(BuildContext context) {
    final navIndex = (_currentIndex >= 0 && _currentIndex <= 2) ? _currentIndex : 0;

    return Scaffold(
      appBar: buildMainAppBar(
        context,
        ref,
        onVoiceEntry: _startVoiceEntry,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: buildMainBottomNavigationBar(context, navIndex, (index, [params]) {
        // If called with params from statistics picker, store them then navigate
        if (index == 2 && params is Map<String, dynamic>) {
          _pendingStatsParams = params;
        } else {
          _pendingStatsParams = null;
        }
        setState(() => _currentIndex = index);
      }),
    );
  }
}
