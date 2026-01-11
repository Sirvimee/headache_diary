// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DayEntryModel {

 String get date; Map<String, dynamic> get icons; Map<String, dynamic> get medication; String get notes; Map<String, dynamic>? get reminder;
/// Create a copy of DayEntryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayEntryModelCopyWith<DayEntryModel> get copyWith => _$DayEntryModelCopyWithImpl<DayEntryModel>(this as DayEntryModel, _$identity);

  /// Serializes this DayEntryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayEntryModel&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.icons, icons)&&const DeepCollectionEquality().equals(other.medication, medication)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.reminder, reminder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(icons),const DeepCollectionEquality().hash(medication),notes,const DeepCollectionEquality().hash(reminder));

@override
String toString() {
  return 'DayEntryModel(date: $date, icons: $icons, medication: $medication, notes: $notes, reminder: $reminder)';
}


}

/// @nodoc
abstract mixin class $DayEntryModelCopyWith<$Res>  {
  factory $DayEntryModelCopyWith(DayEntryModel value, $Res Function(DayEntryModel) _then) = _$DayEntryModelCopyWithImpl;
@useResult
$Res call({
 String date, Map<String, dynamic> icons, Map<String, dynamic> medication, String notes, Map<String, dynamic>? reminder
});




}
/// @nodoc
class _$DayEntryModelCopyWithImpl<$Res>
    implements $DayEntryModelCopyWith<$Res> {
  _$DayEntryModelCopyWithImpl(this._self, this._then);

  final DayEntryModel _self;
  final $Res Function(DayEntryModel) _then;

/// Create a copy of DayEntryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? icons = null,Object? medication = null,Object? notes = null,Object? reminder = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,icons: null == icons ? _self.icons : icons // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,medication: null == medication ? _self.medication : medication // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,reminder: freezed == reminder ? _self.reminder : reminder // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [DayEntryModel].
extension DayEntryModelPatterns on DayEntryModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayEntryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayEntryModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayEntryModel value)  $default,){
final _that = this;
switch (_that) {
case _DayEntryModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayEntryModel value)?  $default,){
final _that = this;
switch (_that) {
case _DayEntryModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  Map<String, dynamic> icons,  Map<String, dynamic> medication,  String notes,  Map<String, dynamic>? reminder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayEntryModel() when $default != null:
return $default(_that.date,_that.icons,_that.medication,_that.notes,_that.reminder);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  Map<String, dynamic> icons,  Map<String, dynamic> medication,  String notes,  Map<String, dynamic>? reminder)  $default,) {final _that = this;
switch (_that) {
case _DayEntryModel():
return $default(_that.date,_that.icons,_that.medication,_that.notes,_that.reminder);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  Map<String, dynamic> icons,  Map<String, dynamic> medication,  String notes,  Map<String, dynamic>? reminder)?  $default,) {final _that = this;
switch (_that) {
case _DayEntryModel() when $default != null:
return $default(_that.date,_that.icons,_that.medication,_that.notes,_that.reminder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DayEntryModel implements DayEntryModel {
  const _DayEntryModel({required this.date, final  Map<String, dynamic> icons = const <String, dynamic>{}, final  Map<String, dynamic> medication = const <String, dynamic>{}, this.notes = '', final  Map<String, dynamic>? reminder}): _icons = icons,_medication = medication,_reminder = reminder;
  factory _DayEntryModel.fromJson(Map<String, dynamic> json) => _$DayEntryModelFromJson(json);

@override final  String date;
 final  Map<String, dynamic> _icons;
@override@JsonKey() Map<String, dynamic> get icons {
  if (_icons is EqualUnmodifiableMapView) return _icons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_icons);
}

 final  Map<String, dynamic> _medication;
@override@JsonKey() Map<String, dynamic> get medication {
  if (_medication is EqualUnmodifiableMapView) return _medication;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_medication);
}

@override@JsonKey() final  String notes;
 final  Map<String, dynamic>? _reminder;
@override Map<String, dynamic>? get reminder {
  final value = _reminder;
  if (value == null) return null;
  if (_reminder is EqualUnmodifiableMapView) return _reminder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of DayEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayEntryModelCopyWith<_DayEntryModel> get copyWith => __$DayEntryModelCopyWithImpl<_DayEntryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DayEntryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayEntryModel&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other._icons, _icons)&&const DeepCollectionEquality().equals(other._medication, _medication)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._reminder, _reminder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(_icons),const DeepCollectionEquality().hash(_medication),notes,const DeepCollectionEquality().hash(_reminder));

@override
String toString() {
  return 'DayEntryModel(date: $date, icons: $icons, medication: $medication, notes: $notes, reminder: $reminder)';
}


}

/// @nodoc
abstract mixin class _$DayEntryModelCopyWith<$Res> implements $DayEntryModelCopyWith<$Res> {
  factory _$DayEntryModelCopyWith(_DayEntryModel value, $Res Function(_DayEntryModel) _then) = __$DayEntryModelCopyWithImpl;
@override @useResult
$Res call({
 String date, Map<String, dynamic> icons, Map<String, dynamic> medication, String notes, Map<String, dynamic>? reminder
});




}
/// @nodoc
class __$DayEntryModelCopyWithImpl<$Res>
    implements _$DayEntryModelCopyWith<$Res> {
  __$DayEntryModelCopyWithImpl(this._self, this._then);

  final _DayEntryModel _self;
  final $Res Function(_DayEntryModel) _then;

/// Create a copy of DayEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? icons = null,Object? medication = null,Object? notes = null,Object? reminder = freezed,}) {
  return _then(_DayEntryModel(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,icons: null == icons ? _self._icons : icons // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,medication: null == medication ? _self._medication : medication // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,reminder: freezed == reminder ? _self._reminder : reminder // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
