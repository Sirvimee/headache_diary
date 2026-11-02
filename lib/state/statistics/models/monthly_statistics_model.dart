import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_statistics_model.freezed.dart';
part 'monthly_statistics_model.g.dart';

@freezed
abstract class MonthlyStatisticsModel with _$MonthlyStatisticsModel {
  const factory MonthlyStatisticsModel({
    required String title,
    required int year,
    required int month,
    required String headacheDays,
    required String rightSide,
    required String leftSide,
    required String overhead,
    required String pills,
    required String systal,
    required String run,
    required String strength,
    required String sex,
    required String alcohol,
    required String menstruation,
    required String chocolate,
    required String doctor,
    required String eyePain,
    required String vomit,
    required String preventivePill,
  }) = _MonthlyStatisticsModel;

  factory MonthlyStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStatisticsModelFromJson(json);
}
