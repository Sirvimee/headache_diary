import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../constants/app_colors.dart';
import '../../constants/strings.dart';
import '../../../state/statistics/monthly_statistics_provider.dart';
import '../../../state/statistics/statistics_shared.dart';
import 'statistics_block.dart';

enum StatisticsMode { monthly, period }

class StatisticsView extends ConsumerStatefulWidget {
  final StatisticsMode mode;
  final DateTime? start;
  final DateTime? end;

  const StatisticsView({Key? key}) : this._(key: key, mode: StatisticsMode.monthly);
  const StatisticsView._({super.key, required this.mode, this.start, this.end});
  const StatisticsView.monthly({Key? key}) : this._(key: key, mode: StatisticsMode.monthly);
  const StatisticsView.period({Key? key, required DateTime start, required DateTime end}) : this._(key: key, mode: StatisticsMode.period, start: start, end: end);

  @override
  ConsumerState<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends ConsumerState<StatisticsView> {
  final ItemScrollController _itemScrollController = ItemScrollController();

  Future<Map<String, String>> _aggregateForPeriod(DateTime start, DateTime end) async {
    final block = await aggregateForPeriod(start, end);
    block['title'] = estMonth(start);
    return block;
  }

  void _scrollToIndexIfNeeded(int index, int itemCount) {
    if (index >= 0 && index < itemCount && _itemScrollController.isAttached) {
      _itemScrollController.scrollTo(index: index, duration: const Duration(milliseconds: 300), alignment: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == StatisticsMode.period && widget.start != null && widget.end != null) {
      return Container(
        color: AppColors.accentColor,
        child: FutureBuilder<Map<String, String>>(
          future: _aggregateForPeriod(widget.start!, widget.end!),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('${Strings.error}: ${snap.error}'));
            }
            final block = snap.data ?? {};
            return ListView(
              padding: const EdgeInsets.only(bottom: 24, top: 12),
              children: [
                StatisticsBlock(block: block),
              ],
            );
          },
        ),
      );
    }

    final asyncMonths = ref.watch(monthlyStatisticsProvider);

    return Container(
      color: AppColors.accentColor,
      child: asyncMonths.when(
        data: (monthsList) {
          if (monthsList.isEmpty) return const Center(child: Text(Strings.dataNotFound));

          final now = DateTime.now();
          final curIndex = monthsList.indexWhere((m) => m['year'] == now.year.toString() && m['month'] == now.month.toString());

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToIndexIfNeeded(curIndex, monthsList.length);
          });

          return ScrollablePositionedList.separated(
            padding: const EdgeInsets.only(bottom: 24, top: 12),
            itemCount: monthsList.length,
            itemScrollController: _itemScrollController,
            separatorBuilder: (ctx, idx) => const Divider(color: AppColors.textColor, height: 1, indent: 20, endIndent: 20),
            itemBuilder: (ctx, idx) {
              final b = Map<String, String>.from(monthsList[idx]);
              final isFocused = idx == curIndex;
              return StatisticsBlock(block: b, focused: isFocused);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${Strings.error}: $e')),
      ),
    );
  }
}
