import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_entry_model.freezed.dart';
part 'day_entry_model.g.dart';

@freezed
abstract class DayEntryModel with _$DayEntryModel {
  const factory DayEntryModel({
    required String date,
    @Default(<String, dynamic>{}) Map<String, dynamic> icons,
    @Default(<String, dynamic>{}) Map<String, dynamic> medication,
    @Default('') String notes,
    Map<String, dynamic>? reminder,
  }) = _DayEntryModel;

  factory DayEntryModel.fromJson(Map<String, dynamic> json) => _$DayEntryModelFromJson(json);
}
