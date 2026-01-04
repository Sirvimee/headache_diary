// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserInfoModel _$UserInfoModelFromJson(Map<String, dynamic> json) =>
    _UserInfoModel(
      userId: json['uid'] as String,
      displayName: json['display_name'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$UserInfoModelToJson(_UserInfoModel instance) =>
    <String, dynamic>{
      'uid': instance.userId,
      'display_name': instance.displayName,
      'email': instance.email,
    };
