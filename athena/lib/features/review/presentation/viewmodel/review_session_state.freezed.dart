// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReviewSessionState {

// Session data
 ReviewSessionEntity? get session; List<QuizItemEntity> get items; List<ReviewResponseEntity> get responses;// Current review state
 int get currentItemIndex; QuizItemEntity? get currentItem;// UI state for current item
 bool get isShowingAnswer; DateTime? get responseStartTime;// Session progress
 int get completedItems; int get correctResponses; double get averageDifficulty;// Loading and error states
 bool get isLoadingSession; bool get isSubmittingResponse; String? get error;// Session completion
 bool get isSessionCompleted; bool get isSessionAbandoned;// Multiple choice specific state
 String? get selectedMcqOption; bool get hasMcqAnswered;// Statistics
 int get averageResponseTime;
/// Create a copy of ReviewSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewSessionStateCopyWith<ReviewSessionState> get copyWith => _$ReviewSessionStateCopyWithImpl<ReviewSessionState>(this as ReviewSessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewSessionState&&(identical(other.session, session) || other.session == session)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.responses, responses)&&(identical(other.currentItemIndex, currentItemIndex) || other.currentItemIndex == currentItemIndex)&&(identical(other.currentItem, currentItem) || other.currentItem == currentItem)&&(identical(other.isShowingAnswer, isShowingAnswer) || other.isShowingAnswer == isShowingAnswer)&&(identical(other.responseStartTime, responseStartTime) || other.responseStartTime == responseStartTime)&&(identical(other.completedItems, completedItems) || other.completedItems == completedItems)&&(identical(other.correctResponses, correctResponses) || other.correctResponses == correctResponses)&&(identical(other.averageDifficulty, averageDifficulty) || other.averageDifficulty == averageDifficulty)&&(identical(other.isLoadingSession, isLoadingSession) || other.isLoadingSession == isLoadingSession)&&(identical(other.isSubmittingResponse, isSubmittingResponse) || other.isSubmittingResponse == isSubmittingResponse)&&(identical(other.error, error) || other.error == error)&&(identical(other.isSessionCompleted, isSessionCompleted) || other.isSessionCompleted == isSessionCompleted)&&(identical(other.isSessionAbandoned, isSessionAbandoned) || other.isSessionAbandoned == isSessionAbandoned)&&(identical(other.selectedMcqOption, selectedMcqOption) || other.selectedMcqOption == selectedMcqOption)&&(identical(other.hasMcqAnswered, hasMcqAnswered) || other.hasMcqAnswered == hasMcqAnswered)&&(identical(other.averageResponseTime, averageResponseTime) || other.averageResponseTime == averageResponseTime));
}


@override
int get hashCode => Object.hash(runtimeType,session,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(responses),currentItemIndex,currentItem,isShowingAnswer,responseStartTime,completedItems,correctResponses,averageDifficulty,isLoadingSession,isSubmittingResponse,error,isSessionCompleted,isSessionAbandoned,selectedMcqOption,hasMcqAnswered,averageResponseTime);

@override
String toString() {
  return 'ReviewSessionState(session: $session, items: $items, responses: $responses, currentItemIndex: $currentItemIndex, currentItem: $currentItem, isShowingAnswer: $isShowingAnswer, responseStartTime: $responseStartTime, completedItems: $completedItems, correctResponses: $correctResponses, averageDifficulty: $averageDifficulty, isLoadingSession: $isLoadingSession, isSubmittingResponse: $isSubmittingResponse, error: $error, isSessionCompleted: $isSessionCompleted, isSessionAbandoned: $isSessionAbandoned, selectedMcqOption: $selectedMcqOption, hasMcqAnswered: $hasMcqAnswered, averageResponseTime: $averageResponseTime)';
}


}

/// @nodoc
abstract mixin class $ReviewSessionStateCopyWith<$Res>  {
  factory $ReviewSessionStateCopyWith(ReviewSessionState value, $Res Function(ReviewSessionState) _then) = _$ReviewSessionStateCopyWithImpl;
@useResult
$Res call({
 ReviewSessionEntity? session, List<QuizItemEntity> items, List<ReviewResponseEntity> responses, int currentItemIndex, QuizItemEntity? currentItem, bool isShowingAnswer, DateTime? responseStartTime, int completedItems, int correctResponses, double averageDifficulty, bool isLoadingSession, bool isSubmittingResponse, String? error, bool isSessionCompleted, bool isSessionAbandoned, String? selectedMcqOption, bool hasMcqAnswered, int averageResponseTime
});




}
/// @nodoc
class _$ReviewSessionStateCopyWithImpl<$Res>
    implements $ReviewSessionStateCopyWith<$Res> {
  _$ReviewSessionStateCopyWithImpl(this._self, this._then);

  final ReviewSessionState _self;
  final $Res Function(ReviewSessionState) _then;

/// Create a copy of ReviewSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? session = freezed,Object? items = null,Object? responses = null,Object? currentItemIndex = null,Object? currentItem = freezed,Object? isShowingAnswer = null,Object? responseStartTime = freezed,Object? completedItems = null,Object? correctResponses = null,Object? averageDifficulty = null,Object? isLoadingSession = null,Object? isSubmittingResponse = null,Object? error = freezed,Object? isSessionCompleted = null,Object? isSessionAbandoned = null,Object? selectedMcqOption = freezed,Object? hasMcqAnswered = null,Object? averageResponseTime = null,}) {
  return _then(_self.copyWith(
session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ReviewSessionEntity?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<QuizItemEntity>,responses: null == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as List<ReviewResponseEntity>,currentItemIndex: null == currentItemIndex ? _self.currentItemIndex : currentItemIndex // ignore: cast_nullable_to_non_nullable
as int,currentItem: freezed == currentItem ? _self.currentItem : currentItem // ignore: cast_nullable_to_non_nullable
as QuizItemEntity?,isShowingAnswer: null == isShowingAnswer ? _self.isShowingAnswer : isShowingAnswer // ignore: cast_nullable_to_non_nullable
as bool,responseStartTime: freezed == responseStartTime ? _self.responseStartTime : responseStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,completedItems: null == completedItems ? _self.completedItems : completedItems // ignore: cast_nullable_to_non_nullable
as int,correctResponses: null == correctResponses ? _self.correctResponses : correctResponses // ignore: cast_nullable_to_non_nullable
as int,averageDifficulty: null == averageDifficulty ? _self.averageDifficulty : averageDifficulty // ignore: cast_nullable_to_non_nullable
as double,isLoadingSession: null == isLoadingSession ? _self.isLoadingSession : isLoadingSession // ignore: cast_nullable_to_non_nullable
as bool,isSubmittingResponse: null == isSubmittingResponse ? _self.isSubmittingResponse : isSubmittingResponse // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,isSessionCompleted: null == isSessionCompleted ? _self.isSessionCompleted : isSessionCompleted // ignore: cast_nullable_to_non_nullable
as bool,isSessionAbandoned: null == isSessionAbandoned ? _self.isSessionAbandoned : isSessionAbandoned // ignore: cast_nullable_to_non_nullable
as bool,selectedMcqOption: freezed == selectedMcqOption ? _self.selectedMcqOption : selectedMcqOption // ignore: cast_nullable_to_non_nullable
as String?,hasMcqAnswered: null == hasMcqAnswered ? _self.hasMcqAnswered : hasMcqAnswered // ignore: cast_nullable_to_non_nullable
as bool,averageResponseTime: null == averageResponseTime ? _self.averageResponseTime : averageResponseTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc


class _ReviewSessionState extends ReviewSessionState {
  const _ReviewSessionState({this.session, final  List<QuizItemEntity> items = const [], final  List<ReviewResponseEntity> responses = const [], this.currentItemIndex = 0, this.currentItem, this.isShowingAnswer = false, this.responseStartTime, this.completedItems = 0, this.correctResponses = 0, this.averageDifficulty = 0.0, this.isLoadingSession = false, this.isSubmittingResponse = false, this.error, this.isSessionCompleted = false, this.isSessionAbandoned = false, this.selectedMcqOption, this.hasMcqAnswered = false, this.averageResponseTime = 0}): _items = items,_responses = responses,super._();
  

// Session data
@override final  ReviewSessionEntity? session;
 final  List<QuizItemEntity> _items;
@override@JsonKey() List<QuizItemEntity> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<ReviewResponseEntity> _responses;
@override@JsonKey() List<ReviewResponseEntity> get responses {
  if (_responses is EqualUnmodifiableListView) return _responses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_responses);
}

// Current review state
@override@JsonKey() final  int currentItemIndex;
@override final  QuizItemEntity? currentItem;
// UI state for current item
@override@JsonKey() final  bool isShowingAnswer;
@override final  DateTime? responseStartTime;
// Session progress
@override@JsonKey() final  int completedItems;
@override@JsonKey() final  int correctResponses;
@override@JsonKey() final  double averageDifficulty;
// Loading and error states
@override@JsonKey() final  bool isLoadingSession;
@override@JsonKey() final  bool isSubmittingResponse;
@override final  String? error;
// Session completion
@override@JsonKey() final  bool isSessionCompleted;
@override@JsonKey() final  bool isSessionAbandoned;
// Multiple choice specific state
@override final  String? selectedMcqOption;
@override@JsonKey() final  bool hasMcqAnswered;
// Statistics
@override@JsonKey() final  int averageResponseTime;

/// Create a copy of ReviewSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewSessionStateCopyWith<_ReviewSessionState> get copyWith => __$ReviewSessionStateCopyWithImpl<_ReviewSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewSessionState&&(identical(other.session, session) || other.session == session)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._responses, _responses)&&(identical(other.currentItemIndex, currentItemIndex) || other.currentItemIndex == currentItemIndex)&&(identical(other.currentItem, currentItem) || other.currentItem == currentItem)&&(identical(other.isShowingAnswer, isShowingAnswer) || other.isShowingAnswer == isShowingAnswer)&&(identical(other.responseStartTime, responseStartTime) || other.responseStartTime == responseStartTime)&&(identical(other.completedItems, completedItems) || other.completedItems == completedItems)&&(identical(other.correctResponses, correctResponses) || other.correctResponses == correctResponses)&&(identical(other.averageDifficulty, averageDifficulty) || other.averageDifficulty == averageDifficulty)&&(identical(other.isLoadingSession, isLoadingSession) || other.isLoadingSession == isLoadingSession)&&(identical(other.isSubmittingResponse, isSubmittingResponse) || other.isSubmittingResponse == isSubmittingResponse)&&(identical(other.error, error) || other.error == error)&&(identical(other.isSessionCompleted, isSessionCompleted) || other.isSessionCompleted == isSessionCompleted)&&(identical(other.isSessionAbandoned, isSessionAbandoned) || other.isSessionAbandoned == isSessionAbandoned)&&(identical(other.selectedMcqOption, selectedMcqOption) || other.selectedMcqOption == selectedMcqOption)&&(identical(other.hasMcqAnswered, hasMcqAnswered) || other.hasMcqAnswered == hasMcqAnswered)&&(identical(other.averageResponseTime, averageResponseTime) || other.averageResponseTime == averageResponseTime));
}


@override
int get hashCode => Object.hash(runtimeType,session,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_responses),currentItemIndex,currentItem,isShowingAnswer,responseStartTime,completedItems,correctResponses,averageDifficulty,isLoadingSession,isSubmittingResponse,error,isSessionCompleted,isSessionAbandoned,selectedMcqOption,hasMcqAnswered,averageResponseTime);

@override
String toString() {
  return 'ReviewSessionState(session: $session, items: $items, responses: $responses, currentItemIndex: $currentItemIndex, currentItem: $currentItem, isShowingAnswer: $isShowingAnswer, responseStartTime: $responseStartTime, completedItems: $completedItems, correctResponses: $correctResponses, averageDifficulty: $averageDifficulty, isLoadingSession: $isLoadingSession, isSubmittingResponse: $isSubmittingResponse, error: $error, isSessionCompleted: $isSessionCompleted, isSessionAbandoned: $isSessionAbandoned, selectedMcqOption: $selectedMcqOption, hasMcqAnswered: $hasMcqAnswered, averageResponseTime: $averageResponseTime)';
}


}

/// @nodoc
abstract mixin class _$ReviewSessionStateCopyWith<$Res> implements $ReviewSessionStateCopyWith<$Res> {
  factory _$ReviewSessionStateCopyWith(_ReviewSessionState value, $Res Function(_ReviewSessionState) _then) = __$ReviewSessionStateCopyWithImpl;
@override @useResult
$Res call({
 ReviewSessionEntity? session, List<QuizItemEntity> items, List<ReviewResponseEntity> responses, int currentItemIndex, QuizItemEntity? currentItem, bool isShowingAnswer, DateTime? responseStartTime, int completedItems, int correctResponses, double averageDifficulty, bool isLoadingSession, bool isSubmittingResponse, String? error, bool isSessionCompleted, bool isSessionAbandoned, String? selectedMcqOption, bool hasMcqAnswered, int averageResponseTime
});




}
/// @nodoc
class __$ReviewSessionStateCopyWithImpl<$Res>
    implements _$ReviewSessionStateCopyWith<$Res> {
  __$ReviewSessionStateCopyWithImpl(this._self, this._then);

  final _ReviewSessionState _self;
  final $Res Function(_ReviewSessionState) _then;

/// Create a copy of ReviewSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? session = freezed,Object? items = null,Object? responses = null,Object? currentItemIndex = null,Object? currentItem = freezed,Object? isShowingAnswer = null,Object? responseStartTime = freezed,Object? completedItems = null,Object? correctResponses = null,Object? averageDifficulty = null,Object? isLoadingSession = null,Object? isSubmittingResponse = null,Object? error = freezed,Object? isSessionCompleted = null,Object? isSessionAbandoned = null,Object? selectedMcqOption = freezed,Object? hasMcqAnswered = null,Object? averageResponseTime = null,}) {
  return _then(_ReviewSessionState(
session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ReviewSessionEntity?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<QuizItemEntity>,responses: null == responses ? _self._responses : responses // ignore: cast_nullable_to_non_nullable
as List<ReviewResponseEntity>,currentItemIndex: null == currentItemIndex ? _self.currentItemIndex : currentItemIndex // ignore: cast_nullable_to_non_nullable
as int,currentItem: freezed == currentItem ? _self.currentItem : currentItem // ignore: cast_nullable_to_non_nullable
as QuizItemEntity?,isShowingAnswer: null == isShowingAnswer ? _self.isShowingAnswer : isShowingAnswer // ignore: cast_nullable_to_non_nullable
as bool,responseStartTime: freezed == responseStartTime ? _self.responseStartTime : responseStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,completedItems: null == completedItems ? _self.completedItems : completedItems // ignore: cast_nullable_to_non_nullable
as int,correctResponses: null == correctResponses ? _self.correctResponses : correctResponses // ignore: cast_nullable_to_non_nullable
as int,averageDifficulty: null == averageDifficulty ? _self.averageDifficulty : averageDifficulty // ignore: cast_nullable_to_non_nullable
as double,isLoadingSession: null == isLoadingSession ? _self.isLoadingSession : isLoadingSession // ignore: cast_nullable_to_non_nullable
as bool,isSubmittingResponse: null == isSubmittingResponse ? _self.isSubmittingResponse : isSubmittingResponse // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,isSessionCompleted: null == isSessionCompleted ? _self.isSessionCompleted : isSessionCompleted // ignore: cast_nullable_to_non_nullable
as bool,isSessionAbandoned: null == isSessionAbandoned ? _self.isSessionAbandoned : isSessionAbandoned // ignore: cast_nullable_to_non_nullable
as bool,selectedMcqOption: freezed == selectedMcqOption ? _self.selectedMcqOption : selectedMcqOption // ignore: cast_nullable_to_non_nullable
as String?,hasMcqAnswered: null == hasMcqAnswered ? _self.hasMcqAnswered : hasMcqAnswered // ignore: cast_nullable_to_non_nullable
as bool,averageResponseTime: null == averageResponseTime ? _self.averageResponseTime : averageResponseTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
