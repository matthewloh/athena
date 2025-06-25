// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReviewState {

// Data
 List<QuizEntity> get quizzes; Map<String, List<QuizItemEntity>> get quizItems;// Quiz ID -> List of items
 Map<String, QuizStats> get quizStats;// Quiz ID -> Stats
// Loading states
 bool get isLoading; bool get isRefreshing; bool get isLoadingQuizItems;// Error handling
 String? get error;// Overall stats
 int get totalQuizzes; int get totalItems; int get dueItems; double get overallAccuracy;// UI states
 bool get showEmptyState;// Sorting
 QuizSortCriteria get sortCriteria; bool get sortAscending;
/// Create a copy of ReviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewStateCopyWith<ReviewState> get copyWith => _$ReviewStateCopyWithImpl<ReviewState>(this as ReviewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewState&&const DeepCollectionEquality().equals(other.quizzes, quizzes)&&const DeepCollectionEquality().equals(other.quizItems, quizItems)&&const DeepCollectionEquality().equals(other.quizStats, quizStats)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isLoadingQuizItems, isLoadingQuizItems) || other.isLoadingQuizItems == isLoadingQuizItems)&&(identical(other.error, error) || other.error == error)&&(identical(other.totalQuizzes, totalQuizzes) || other.totalQuizzes == totalQuizzes)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.dueItems, dueItems) || other.dueItems == dueItems)&&(identical(other.overallAccuracy, overallAccuracy) || other.overallAccuracy == overallAccuracy)&&(identical(other.showEmptyState, showEmptyState) || other.showEmptyState == showEmptyState)&&(identical(other.sortCriteria, sortCriteria) || other.sortCriteria == sortCriteria)&&(identical(other.sortAscending, sortAscending) || other.sortAscending == sortAscending));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(quizzes),const DeepCollectionEquality().hash(quizItems),const DeepCollectionEquality().hash(quizStats),isLoading,isRefreshing,isLoadingQuizItems,error,totalQuizzes,totalItems,dueItems,overallAccuracy,showEmptyState,sortCriteria,sortAscending);

@override
String toString() {
  return 'ReviewState(quizzes: $quizzes, quizItems: $quizItems, quizStats: $quizStats, isLoading: $isLoading, isRefreshing: $isRefreshing, isLoadingQuizItems: $isLoadingQuizItems, error: $error, totalQuizzes: $totalQuizzes, totalItems: $totalItems, dueItems: $dueItems, overallAccuracy: $overallAccuracy, showEmptyState: $showEmptyState, sortCriteria: $sortCriteria, sortAscending: $sortAscending)';
}


}

/// @nodoc
abstract mixin class $ReviewStateCopyWith<$Res>  {
  factory $ReviewStateCopyWith(ReviewState value, $Res Function(ReviewState) _then) = _$ReviewStateCopyWithImpl;
@useResult
$Res call({
 List<QuizEntity> quizzes, Map<String, List<QuizItemEntity>> quizItems, Map<String, QuizStats> quizStats, bool isLoading, bool isRefreshing, bool isLoadingQuizItems, String? error, int totalQuizzes, int totalItems, int dueItems, double overallAccuracy, bool showEmptyState, QuizSortCriteria sortCriteria, bool sortAscending
});




}
/// @nodoc
class _$ReviewStateCopyWithImpl<$Res>
    implements $ReviewStateCopyWith<$Res> {
  _$ReviewStateCopyWithImpl(this._self, this._then);

  final ReviewState _self;
  final $Res Function(ReviewState) _then;

/// Create a copy of ReviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quizzes = null,Object? quizItems = null,Object? quizStats = null,Object? isLoading = null,Object? isRefreshing = null,Object? isLoadingQuizItems = null,Object? error = freezed,Object? totalQuizzes = null,Object? totalItems = null,Object? dueItems = null,Object? overallAccuracy = null,Object? showEmptyState = null,Object? sortCriteria = null,Object? sortAscending = null,}) {
  return _then(_self.copyWith(
quizzes: null == quizzes ? _self.quizzes : quizzes // ignore: cast_nullable_to_non_nullable
as List<QuizEntity>,quizItems: null == quizItems ? _self.quizItems : quizItems // ignore: cast_nullable_to_non_nullable
as Map<String, List<QuizItemEntity>>,quizStats: null == quizStats ? _self.quizStats : quizStats // ignore: cast_nullable_to_non_nullable
as Map<String, QuizStats>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLoadingQuizItems: null == isLoadingQuizItems ? _self.isLoadingQuizItems : isLoadingQuizItems // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,totalQuizzes: null == totalQuizzes ? _self.totalQuizzes : totalQuizzes // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,dueItems: null == dueItems ? _self.dueItems : dueItems // ignore: cast_nullable_to_non_nullable
as int,overallAccuracy: null == overallAccuracy ? _self.overallAccuracy : overallAccuracy // ignore: cast_nullable_to_non_nullable
as double,showEmptyState: null == showEmptyState ? _self.showEmptyState : showEmptyState // ignore: cast_nullable_to_non_nullable
as bool,sortCriteria: null == sortCriteria ? _self.sortCriteria : sortCriteria // ignore: cast_nullable_to_non_nullable
as QuizSortCriteria,sortAscending: null == sortAscending ? _self.sortAscending : sortAscending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc


class _ReviewState extends ReviewState {
  const _ReviewState({final  List<QuizEntity> quizzes = const [], final  Map<String, List<QuizItemEntity>> quizItems = const {}, final  Map<String, QuizStats> quizStats = const {}, this.isLoading = false, this.isRefreshing = false, this.isLoadingQuizItems = false, this.error, this.totalQuizzes = 0, this.totalItems = 0, this.dueItems = 0, this.overallAccuracy = 0.0, this.showEmptyState = false, this.sortCriteria = QuizSortCriteria.lastUpdated, this.sortAscending = false}): _quizzes = quizzes,_quizItems = quizItems,_quizStats = quizStats,super._();
  

// Data
 final  List<QuizEntity> _quizzes;
// Data
@override@JsonKey() List<QuizEntity> get quizzes {
  if (_quizzes is EqualUnmodifiableListView) return _quizzes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quizzes);
}

 final  Map<String, List<QuizItemEntity>> _quizItems;
@override@JsonKey() Map<String, List<QuizItemEntity>> get quizItems {
  if (_quizItems is EqualUnmodifiableMapView) return _quizItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_quizItems);
}

// Quiz ID -> List of items
 final  Map<String, QuizStats> _quizStats;
// Quiz ID -> List of items
@override@JsonKey() Map<String, QuizStats> get quizStats {
  if (_quizStats is EqualUnmodifiableMapView) return _quizStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_quizStats);
}

// Quiz ID -> Stats
// Loading states
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isRefreshing;
@override@JsonKey() final  bool isLoadingQuizItems;
// Error handling
@override final  String? error;
// Overall stats
@override@JsonKey() final  int totalQuizzes;
@override@JsonKey() final  int totalItems;
@override@JsonKey() final  int dueItems;
@override@JsonKey() final  double overallAccuracy;
// UI states
@override@JsonKey() final  bool showEmptyState;
// Sorting
@override@JsonKey() final  QuizSortCriteria sortCriteria;
@override@JsonKey() final  bool sortAscending;

/// Create a copy of ReviewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewStateCopyWith<_ReviewState> get copyWith => __$ReviewStateCopyWithImpl<_ReviewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewState&&const DeepCollectionEquality().equals(other._quizzes, _quizzes)&&const DeepCollectionEquality().equals(other._quizItems, _quizItems)&&const DeepCollectionEquality().equals(other._quizStats, _quizStats)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isLoadingQuizItems, isLoadingQuizItems) || other.isLoadingQuizItems == isLoadingQuizItems)&&(identical(other.error, error) || other.error == error)&&(identical(other.totalQuizzes, totalQuizzes) || other.totalQuizzes == totalQuizzes)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.dueItems, dueItems) || other.dueItems == dueItems)&&(identical(other.overallAccuracy, overallAccuracy) || other.overallAccuracy == overallAccuracy)&&(identical(other.showEmptyState, showEmptyState) || other.showEmptyState == showEmptyState)&&(identical(other.sortCriteria, sortCriteria) || other.sortCriteria == sortCriteria)&&(identical(other.sortAscending, sortAscending) || other.sortAscending == sortAscending));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_quizzes),const DeepCollectionEquality().hash(_quizItems),const DeepCollectionEquality().hash(_quizStats),isLoading,isRefreshing,isLoadingQuizItems,error,totalQuizzes,totalItems,dueItems,overallAccuracy,showEmptyState,sortCriteria,sortAscending);

@override
String toString() {
  return 'ReviewState(quizzes: $quizzes, quizItems: $quizItems, quizStats: $quizStats, isLoading: $isLoading, isRefreshing: $isRefreshing, isLoadingQuizItems: $isLoadingQuizItems, error: $error, totalQuizzes: $totalQuizzes, totalItems: $totalItems, dueItems: $dueItems, overallAccuracy: $overallAccuracy, showEmptyState: $showEmptyState, sortCriteria: $sortCriteria, sortAscending: $sortAscending)';
}


}

/// @nodoc
abstract mixin class _$ReviewStateCopyWith<$Res> implements $ReviewStateCopyWith<$Res> {
  factory _$ReviewStateCopyWith(_ReviewState value, $Res Function(_ReviewState) _then) = __$ReviewStateCopyWithImpl;
@override @useResult
$Res call({
 List<QuizEntity> quizzes, Map<String, List<QuizItemEntity>> quizItems, Map<String, QuizStats> quizStats, bool isLoading, bool isRefreshing, bool isLoadingQuizItems, String? error, int totalQuizzes, int totalItems, int dueItems, double overallAccuracy, bool showEmptyState, QuizSortCriteria sortCriteria, bool sortAscending
});




}
/// @nodoc
class __$ReviewStateCopyWithImpl<$Res>
    implements _$ReviewStateCopyWith<$Res> {
  __$ReviewStateCopyWithImpl(this._self, this._then);

  final _ReviewState _self;
  final $Res Function(_ReviewState) _then;

/// Create a copy of ReviewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quizzes = null,Object? quizItems = null,Object? quizStats = null,Object? isLoading = null,Object? isRefreshing = null,Object? isLoadingQuizItems = null,Object? error = freezed,Object? totalQuizzes = null,Object? totalItems = null,Object? dueItems = null,Object? overallAccuracy = null,Object? showEmptyState = null,Object? sortCriteria = null,Object? sortAscending = null,}) {
  return _then(_ReviewState(
quizzes: null == quizzes ? _self._quizzes : quizzes // ignore: cast_nullable_to_non_nullable
as List<QuizEntity>,quizItems: null == quizItems ? _self._quizItems : quizItems // ignore: cast_nullable_to_non_nullable
as Map<String, List<QuizItemEntity>>,quizStats: null == quizStats ? _self._quizStats : quizStats // ignore: cast_nullable_to_non_nullable
as Map<String, QuizStats>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLoadingQuizItems: null == isLoadingQuizItems ? _self.isLoadingQuizItems : isLoadingQuizItems // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,totalQuizzes: null == totalQuizzes ? _self.totalQuizzes : totalQuizzes // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,dueItems: null == dueItems ? _self.dueItems : dueItems // ignore: cast_nullable_to_non_nullable
as int,overallAccuracy: null == overallAccuracy ? _self.overallAccuracy : overallAccuracy // ignore: cast_nullable_to_non_nullable
as double,showEmptyState: null == showEmptyState ? _self.showEmptyState : showEmptyState // ignore: cast_nullable_to_non_nullable
as bool,sortCriteria: null == sortCriteria ? _self.sortCriteria : sortCriteria // ignore: cast_nullable_to_non_nullable
as QuizSortCriteria,sortAscending: null == sortAscending ? _self.sortAscending : sortAscending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$QuizStats {

 int get totalItems; int get dueItems; double get accuracy; DateTime? get lastReviewed;
/// Create a copy of QuizStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuizStatsCopyWith<QuizStats> get copyWith => _$QuizStatsCopyWithImpl<QuizStats>(this as QuizStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuizStats&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.dueItems, dueItems) || other.dueItems == dueItems)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.lastReviewed, lastReviewed) || other.lastReviewed == lastReviewed));
}


@override
int get hashCode => Object.hash(runtimeType,totalItems,dueItems,accuracy,lastReviewed);

@override
String toString() {
  return 'QuizStats(totalItems: $totalItems, dueItems: $dueItems, accuracy: $accuracy, lastReviewed: $lastReviewed)';
}


}

/// @nodoc
abstract mixin class $QuizStatsCopyWith<$Res>  {
  factory $QuizStatsCopyWith(QuizStats value, $Res Function(QuizStats) _then) = _$QuizStatsCopyWithImpl;
@useResult
$Res call({
 int totalItems, int dueItems, double accuracy, DateTime? lastReviewed
});




}
/// @nodoc
class _$QuizStatsCopyWithImpl<$Res>
    implements $QuizStatsCopyWith<$Res> {
  _$QuizStatsCopyWithImpl(this._self, this._then);

  final QuizStats _self;
  final $Res Function(QuizStats) _then;

/// Create a copy of QuizStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalItems = null,Object? dueItems = null,Object? accuracy = null,Object? lastReviewed = freezed,}) {
  return _then(_self.copyWith(
totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,dueItems: null == dueItems ? _self.dueItems : dueItems // ignore: cast_nullable_to_non_nullable
as int,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,lastReviewed: freezed == lastReviewed ? _self.lastReviewed : lastReviewed // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc


class _QuizStats implements QuizStats {
  const _QuizStats({this.totalItems = 0, this.dueItems = 0, this.accuracy = 0.0, this.lastReviewed});
  

@override@JsonKey() final  int totalItems;
@override@JsonKey() final  int dueItems;
@override@JsonKey() final  double accuracy;
@override final  DateTime? lastReviewed;

/// Create a copy of QuizStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuizStatsCopyWith<_QuizStats> get copyWith => __$QuizStatsCopyWithImpl<_QuizStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuizStats&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.dueItems, dueItems) || other.dueItems == dueItems)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.lastReviewed, lastReviewed) || other.lastReviewed == lastReviewed));
}


@override
int get hashCode => Object.hash(runtimeType,totalItems,dueItems,accuracy,lastReviewed);

@override
String toString() {
  return 'QuizStats(totalItems: $totalItems, dueItems: $dueItems, accuracy: $accuracy, lastReviewed: $lastReviewed)';
}


}

/// @nodoc
abstract mixin class _$QuizStatsCopyWith<$Res> implements $QuizStatsCopyWith<$Res> {
  factory _$QuizStatsCopyWith(_QuizStats value, $Res Function(_QuizStats) _then) = __$QuizStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalItems, int dueItems, double accuracy, DateTime? lastReviewed
});




}
/// @nodoc
class __$QuizStatsCopyWithImpl<$Res>
    implements _$QuizStatsCopyWith<$Res> {
  __$QuizStatsCopyWithImpl(this._self, this._then);

  final _QuizStats _self;
  final $Res Function(_QuizStats) _then;

/// Create a copy of QuizStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalItems = null,Object? dueItems = null,Object? accuracy = null,Object? lastReviewed = freezed,}) {
  return _then(_QuizStats(
totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,dueItems: null == dueItems ? _self.dueItems : dueItems // ignore: cast_nullable_to_non_nullable
as int,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,lastReviewed: freezed == lastReviewed ? _self.lastReviewed : lastReviewed // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
