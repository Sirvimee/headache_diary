import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'backend/monthly_statistics_storage.dart';
import 'models/monthly_statistics_model.dart';

final monthlyStatisticsProvider =
    FutureProvider.autoDispose<List<MonthlyStatisticsModel>>((ref) async {
      return const MonthlyStatisticsStorage().fetchMonthlyStatistics();
    });
