import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../typedef/user_id.dart';

part 'user_info_model.freezed.dart';
part 'user_info_model.g.dart';

@freezed
abstract class UserInfoModel with _$UserInfoModel {
  const factory UserInfoModel({
    required UserId userId,
    required String displayName,
    String? email,
  }) = _UserInfoModel;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);
}
