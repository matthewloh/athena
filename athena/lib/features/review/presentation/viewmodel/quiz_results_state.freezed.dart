// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_results_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuizResultsState {

// Session data
 ReviewSessionEntity? get session;// Loading state
 bool get isLoading;// Error state
 String? get error;
/// Create a copy of QuizResultsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuizResultsStateCopyWith<QuizResultsState> get copyWith => _$QuizResultsStateCopyWithImpl<QuizResultsState>(this as QuizResultsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuizResultsState&&(identical(other.session, session) || other.session == session)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,session,isLoading,error);

@override
String toString() {
  return 'QuizResultsState(session: $session, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $QuizResultsStateCopyWith<$Res>  {
  factory $QuizResultsStateCopyWith(QuizResultsState value, $Res Function(QuizResultsState) _then) = _$QuizResultsStateCopyWithImpl;
@useResult
$Res call({
 ReviewSessionEntity? session, bool isLoading, String? error
});




}
/// @nodoc
class _$QuizResultsStateCopyWithImpl<$Res>
    implements $QuizResultsStateCopyWith<$Res> {
  _$QuizResultsStateCopyWithImpl(this._self, this._then);

  final QuizResultsState _self;
  final $Res Function(QuizResultsState) _then;

/// Create a copy of QuizResultsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? session = freezed,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ReviewSessionEntity?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc


class _QuizResultsState extends QuizResultsState {
  const _QuizResultsState({this.session, this.isLoading = false, this.error}): super._();
  

// Session data
@override final  ReviewSessionEntity? session;
// Loading state
@override@JsonKey() final  bool isLoading;
// Error state
@override final  String? error;

/// Create a copy of QuizResultsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuizResultsStateCopyWith<_QuizResultsState> get copyWith => __$QuizResultsStateCopyWithImpl<_QuizResultsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuizResultsState&&(identical(other.session, session) || other.session == session)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,session,isLoading,error);

@override
String toString() {
  return 'QuizResultsState(session: $session, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$QuizResultsStateCopyWith<$Res> implements $QuizResultsStateCopyWith<$Res> {
  factory _$QuizResultsStateCopyWith(_QuizResultsState value, $Res Function(_QuizResultsState) _then) = __$QuizResultsStateCopyWithImpl;
@override @useResult
$Res call({
 ReviewSessionEntity? session, bool isLoading, String? error
});




}
/// @nodoc
class __$QuizResultsStateCopyWithImpl<$Res>
    implements _$QuizResultsStateCopyWith<$Res> {
  __$QuizResultsStateCopyWithImpl(this._self, this._then);

  final _QuizResultsState _self;
  final $Res Function(_QuizResultsState) _then;

/// Create a copy of QuizResultsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? session = freezed,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_QuizResultsState(
session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ReviewSessionEntity?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
