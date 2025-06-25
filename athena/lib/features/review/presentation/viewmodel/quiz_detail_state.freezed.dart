// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuizDetailState {

// Core data
 QuizEntity? get quiz; List<QuizItemEntity> get quizItems;// Loading states
 bool get isLoading; bool get isLoadingItems; bool get isRefreshing;// Error handling
 String? get error;// Statistics
 int get totalItems; int get dueItems; int get masteredItems; double get accuracy; int get totalReviews; int get streak;// TODO: Review session history (when available)
// @Default([]) List<ReviewSessionEntity> sessionHistory,
// UI states
 int get selectedTabIndex;
/// Create a copy of QuizDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuizDetailStateCopyWith<QuizDetailState> get copyWith => _$QuizDetailStateCopyWithImpl<QuizDetailState>(this as QuizDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuizDetailState&&(identical(other.quiz, quiz) || other.quiz == quiz)&&const DeepCollectionEquality().equals(other.quizItems, quizItems)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingItems, isLoadingItems) || other.isLoadingItems == isLoadingItems)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.error, error) || other.error == error)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.dueItems, dueItems) || other.dueItems == dueItems)&&(identical(other.masteredItems, masteredItems) || other.masteredItems == masteredItems)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.selectedTabIndex, selectedTabIndex) || other.selectedTabIndex == selectedTabIndex));
}


@override
int get hashCode => Object.hash(runtimeType,quiz,const DeepCollectionEquality().hash(quizItems),isLoading,isLoadingItems,isRefreshing,error,totalItems,dueItems,masteredItems,accuracy,totalReviews,streak,selectedTabIndex);

@override
String toString() {
  return 'QuizDetailState(quiz: $quiz, quizItems: $quizItems, isLoading: $isLoading, isLoadingItems: $isLoadingItems, isRefreshing: $isRefreshing, error: $error, totalItems: $totalItems, dueItems: $dueItems, masteredItems: $masteredItems, accuracy: $accuracy, totalReviews: $totalReviews, streak: $streak, selectedTabIndex: $selectedTabIndex)';
}


}

/// @nodoc
abstract mixin class $QuizDetailStateCopyWith<$Res>  {
  factory $QuizDetailStateCopyWith(QuizDetailState value, $Res Function(QuizDetailState) _then) = _$QuizDetailStateCopyWithImpl;
@useResult
$Res call({
 QuizEntity? quiz, List<QuizItemEntity> quizItems, bool isLoading, bool isLoadingItems, bool isRefreshing, String? error, int totalItems, int dueItems, int masteredItems, double accuracy, int totalReviews, int streak, int selectedTabIndex
});




}
/// @nodoc
class _$QuizDetailStateCopyWithImpl<$Res>
    implements $QuizDetailStateCopyWith<$Res> {
  _$QuizDetailStateCopyWithImpl(this._self, this._then);

  final QuizDetailState _self;
  final $Res Function(QuizDetailState) _then;

/// Create a copy of QuizDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quiz = freezed,Object? quizItems = null,Object? isLoading = null,Object? isLoadingItems = null,Object? isRefreshing = null,Object? error = freezed,Object? totalItems = null,Object? dueItems = null,Object? masteredItems = null,Object? accuracy = null,Object? totalReviews = null,Object? streak = null,Object? selectedTabIndex = null,}) {
  return _then(_self.copyWith(
quiz: freezed == quiz ? _self.quiz : quiz // ignore: cast_nullable_to_non_nullable
as QuizEntity?,quizItems: null == quizItems ? _self.quizItems : quizItems // ignore: cast_nullable_to_non_nullable
as List<QuizItemEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingItems: null == isLoadingItems ? _self.isLoadingItems : isLoadingItems // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,dueItems: null == dueItems ? _self.dueItems : dueItems // ignore: cast_nullable_to_non_nullable
as int,masteredItems: null == masteredItems ? _self.masteredItems : masteredItems // ignore: cast_nullable_to_non_nullable
as int,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,selectedTabIndex: null == selectedTabIndex ? _self.selectedTabIndex : selectedTabIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc


class _QuizDetailState extends QuizDetailState {
  const _QuizDetailState({this.quiz, final  List<QuizItemEntity> quizItems = const [], this.isLoading = false, this.isLoadingItems = false, this.isRefreshing = false, this.error, this.totalItems = 0, this.dueItems = 0, this.masteredItems = 0, this.accuracy = 0.0, this.totalReviews = 0, this.streak = 0, this.selectedTabIndex = 0}): _quizItems = quizItems,super._();
  

// Core data
@override final  QuizEntity? quiz;
 final  List<QuizItemEntity> _quizItems;
@override@JsonKey() List<QuizItemEntity> get quizItems {
  if (_quizItems is EqualUnmodifiableListView) return _quizItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quizItems);
}

// Loading states
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isLoadingItems;
@override@JsonKey() final  bool isRefreshing;
// Error handling
@override final  String? error;
// Statistics
@override@JsonKey() final  int totalItems;
@override@JsonKey() final  int dueItems;
@override@JsonKey() final  int masteredItems;
@override@JsonKey() final  double accuracy;
@override@JsonKey() final  int totalReviews;
@override@JsonKey() final  int streak;
// TODO: Review session history (when available)
// @Default([]) List<ReviewSessionEntity> sessionHistory,
// UI states
@override@JsonKey() final  int selectedTabIndex;

/// Create a copy of QuizDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuizDetailStateCopyWith<_QuizDetailState> get copyWith => __$QuizDetailStateCopyWithImpl<_QuizDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuizDetailState&&(identical(other.quiz, quiz) || other.quiz == quiz)&&const DeepCollectionEquality().equals(other._quizItems, _quizItems)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingItems, isLoadingItems) || other.isLoadingItems == isLoadingItems)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.error, error) || other.error == error)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.dueItems, dueItems) || other.dueItems == dueItems)&&(identical(other.masteredItems, masteredItems) || other.masteredItems == masteredItems)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.selectedTabIndex, selectedTabIndex) || other.selectedTabIndex == selectedTabIndex));
}


@override
int get hashCode => Object.hash(runtimeType,quiz,const DeepCollectionEquality().hash(_quizItems),isLoading,isLoadingItems,isRefreshing,error,totalItems,dueItems,masteredItems,accuracy,totalReviews,streak,selectedTabIndex);

@override
String toString() {
  return 'QuizDetailState(quiz: $quiz, quizItems: $quizItems, isLoading: $isLoading, isLoadingItems: $isLoadingItems, isRefreshing: $isRefreshing, error: $error, totalItems: $totalItems, dueItems: $dueItems, masteredItems: $masteredItems, accuracy: $accuracy, totalReviews: $totalReviews, streak: $streak, selectedTabIndex: $selectedTabIndex)';
}


}

/// @nodoc
abstract mixin class _$QuizDetailStateCopyWith<$Res> implements $QuizDetailStateCopyWith<$Res> {
  factory _$QuizDetailStateCopyWith(_QuizDetailState value, $Res Function(_QuizDetailState) _then) = __$QuizDetailStateCopyWithImpl;
@override @useResult
$Res call({
 QuizEntity? quiz, List<QuizItemEntity> quizItems, bool isLoading, bool isLoadingItems, bool isRefreshing, String? error, int totalItems, int dueItems, int masteredItems, double accuracy, int totalReviews, int streak, int selectedTabIndex
});




}
/// @nodoc
class __$QuizDetailStateCopyWithImpl<$Res>
    implements _$QuizDetailStateCopyWith<$Res> {
  __$QuizDetailStateCopyWithImpl(this._self, this._then);

  final _QuizDetailState _self;
  final $Res Function(_QuizDetailState) _then;

/// Create a copy of QuizDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quiz = freezed,Object? quizItems = null,Object? isLoading = null,Object? isLoadingItems = null,Object? isRefreshing = null,Object? error = freezed,Object? totalItems = null,Object? dueItems = null,Object? masteredItems = null,Object? accuracy = null,Object? totalReviews = null,Object? streak = null,Object? selectedTabIndex = null,}) {
  return _then(_QuizDetailState(
quiz: freezed == quiz ? _self.quiz : quiz // ignore: cast_nullable_to_non_nullable
as QuizEntity?,quizItems: null == quizItems ? _self._quizItems : quizItems // ignore: cast_nullable_to_non_nullable
as List<QuizItemEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingItems: null == isLoadingItems ? _self.isLoadingItems : isLoadingItems // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,dueItems: null == dueItems ? _self.dueItems : dueItems // ignore: cast_nullable_to_non_nullable
as int,masteredItems: null == masteredItems ? _self.masteredItems : masteredItems // ignore: cast_nullable_to_non_nullable
as int,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,selectedTabIndex: null == selectedTabIndex ? _self.selectedTabIndex : selectedTabIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
