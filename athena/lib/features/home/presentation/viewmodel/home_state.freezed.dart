// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

// User data
 ProfileEntity? get userProfile;// Dashboard data
 DashboardData? get dashboardData;// Individual data components
 int get materialCount; int get quizItemCount; List<UpcomingSession> get upcomingSessions; List<ReviewItem> get reviewItems;// Loading states
 bool get isLoading; bool get isRefreshing; bool get isLoadingProfile; bool get isLoadingDashboard; bool get isLoadingMaterials; bool get isLoadingQuizItems; bool get isLoadingSessions; bool get isLoadingReviewItems;// Error handling
 String? get error; String? get profileError; String? get dashboardError; String? get materialsError; String? get quizItemsError; String? get sessionsError; String? get reviewItemsError;// UI states
 bool get showEmptyState;// Edge function demo state
 String get edgeFunctionName; Map<String, dynamic>? get edgeFunctionResponse; bool get isCallingEdgeFunction; String? get edgeFunctionError;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.userProfile, userProfile) || other.userProfile == userProfile)&&(identical(other.dashboardData, dashboardData) || other.dashboardData == dashboardData)&&(identical(other.materialCount, materialCount) || other.materialCount == materialCount)&&(identical(other.quizItemCount, quizItemCount) || other.quizItemCount == quizItemCount)&&const DeepCollectionEquality().equals(other.upcomingSessions, upcomingSessions)&&const DeepCollectionEquality().equals(other.reviewItems, reviewItems)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isLoadingProfile, isLoadingProfile) || other.isLoadingProfile == isLoadingProfile)&&(identical(other.isLoadingDashboard, isLoadingDashboard) || other.isLoadingDashboard == isLoadingDashboard)&&(identical(other.isLoadingMaterials, isLoadingMaterials) || other.isLoadingMaterials == isLoadingMaterials)&&(identical(other.isLoadingQuizItems, isLoadingQuizItems) || other.isLoadingQuizItems == isLoadingQuizItems)&&(identical(other.isLoadingSessions, isLoadingSessions) || other.isLoadingSessions == isLoadingSessions)&&(identical(other.isLoadingReviewItems, isLoadingReviewItems) || other.isLoadingReviewItems == isLoadingReviewItems)&&(identical(other.error, error) || other.error == error)&&(identical(other.profileError, profileError) || other.profileError == profileError)&&(identical(other.dashboardError, dashboardError) || other.dashboardError == dashboardError)&&(identical(other.materialsError, materialsError) || other.materialsError == materialsError)&&(identical(other.quizItemsError, quizItemsError) || other.quizItemsError == quizItemsError)&&(identical(other.sessionsError, sessionsError) || other.sessionsError == sessionsError)&&(identical(other.reviewItemsError, reviewItemsError) || other.reviewItemsError == reviewItemsError)&&(identical(other.showEmptyState, showEmptyState) || other.showEmptyState == showEmptyState)&&(identical(other.edgeFunctionName, edgeFunctionName) || other.edgeFunctionName == edgeFunctionName)&&const DeepCollectionEquality().equals(other.edgeFunctionResponse, edgeFunctionResponse)&&(identical(other.isCallingEdgeFunction, isCallingEdgeFunction) || other.isCallingEdgeFunction == isCallingEdgeFunction)&&(identical(other.edgeFunctionError, edgeFunctionError) || other.edgeFunctionError == edgeFunctionError));
}


@override
int get hashCode => Object.hashAll([runtimeType,userProfile,dashboardData,materialCount,quizItemCount,const DeepCollectionEquality().hash(upcomingSessions),const DeepCollectionEquality().hash(reviewItems),isLoading,isRefreshing,isLoadingProfile,isLoadingDashboard,isLoadingMaterials,isLoadingQuizItems,isLoadingSessions,isLoadingReviewItems,error,profileError,dashboardError,materialsError,quizItemsError,sessionsError,reviewItemsError,showEmptyState,edgeFunctionName,const DeepCollectionEquality().hash(edgeFunctionResponse),isCallingEdgeFunction,edgeFunctionError]);

@override
String toString() {
  return 'HomeState(userProfile: $userProfile, dashboardData: $dashboardData, materialCount: $materialCount, quizItemCount: $quizItemCount, upcomingSessions: $upcomingSessions, reviewItems: $reviewItems, isLoading: $isLoading, isRefreshing: $isRefreshing, isLoadingProfile: $isLoadingProfile, isLoadingDashboard: $isLoadingDashboard, isLoadingMaterials: $isLoadingMaterials, isLoadingQuizItems: $isLoadingQuizItems, isLoadingSessions: $isLoadingSessions, isLoadingReviewItems: $isLoadingReviewItems, error: $error, profileError: $profileError, dashboardError: $dashboardError, materialsError: $materialsError, quizItemsError: $quizItemsError, sessionsError: $sessionsError, reviewItemsError: $reviewItemsError, showEmptyState: $showEmptyState, edgeFunctionName: $edgeFunctionName, edgeFunctionResponse: $edgeFunctionResponse, isCallingEdgeFunction: $isCallingEdgeFunction, edgeFunctionError: $edgeFunctionError)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 ProfileEntity? userProfile, DashboardData? dashboardData, int materialCount, int quizItemCount, List<UpcomingSession> upcomingSessions, List<ReviewItem> reviewItems, bool isLoading, bool isRefreshing, bool isLoadingProfile, bool isLoadingDashboard, bool isLoadingMaterials, bool isLoadingQuizItems, bool isLoadingSessions, bool isLoadingReviewItems, String? error, String? profileError, String? dashboardError, String? materialsError, String? quizItemsError, String? sessionsError, String? reviewItemsError, bool showEmptyState, String edgeFunctionName, Map<String, dynamic>? edgeFunctionResponse, bool isCallingEdgeFunction, String? edgeFunctionError
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userProfile = freezed,Object? dashboardData = freezed,Object? materialCount = null,Object? quizItemCount = null,Object? upcomingSessions = null,Object? reviewItems = null,Object? isLoading = null,Object? isRefreshing = null,Object? isLoadingProfile = null,Object? isLoadingDashboard = null,Object? isLoadingMaterials = null,Object? isLoadingQuizItems = null,Object? isLoadingSessions = null,Object? isLoadingReviewItems = null,Object? error = freezed,Object? profileError = freezed,Object? dashboardError = freezed,Object? materialsError = freezed,Object? quizItemsError = freezed,Object? sessionsError = freezed,Object? reviewItemsError = freezed,Object? showEmptyState = null,Object? edgeFunctionName = null,Object? edgeFunctionResponse = freezed,Object? isCallingEdgeFunction = null,Object? edgeFunctionError = freezed,}) {
  return _then(_self.copyWith(
userProfile: freezed == userProfile ? _self.userProfile : userProfile // ignore: cast_nullable_to_non_nullable
as ProfileEntity?,dashboardData: freezed == dashboardData ? _self.dashboardData : dashboardData // ignore: cast_nullable_to_non_nullable
as DashboardData?,materialCount: null == materialCount ? _self.materialCount : materialCount // ignore: cast_nullable_to_non_nullable
as int,quizItemCount: null == quizItemCount ? _self.quizItemCount : quizItemCount // ignore: cast_nullable_to_non_nullable
as int,upcomingSessions: null == upcomingSessions ? _self.upcomingSessions : upcomingSessions // ignore: cast_nullable_to_non_nullable
as List<UpcomingSession>,reviewItems: null == reviewItems ? _self.reviewItems : reviewItems // ignore: cast_nullable_to_non_nullable
as List<ReviewItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLoadingProfile: null == isLoadingProfile ? _self.isLoadingProfile : isLoadingProfile // ignore: cast_nullable_to_non_nullable
as bool,isLoadingDashboard: null == isLoadingDashboard ? _self.isLoadingDashboard : isLoadingDashboard // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMaterials: null == isLoadingMaterials ? _self.isLoadingMaterials : isLoadingMaterials // ignore: cast_nullable_to_non_nullable
as bool,isLoadingQuizItems: null == isLoadingQuizItems ? _self.isLoadingQuizItems : isLoadingQuizItems // ignore: cast_nullable_to_non_nullable
as bool,isLoadingSessions: null == isLoadingSessions ? _self.isLoadingSessions : isLoadingSessions // ignore: cast_nullable_to_non_nullable
as bool,isLoadingReviewItems: null == isLoadingReviewItems ? _self.isLoadingReviewItems : isLoadingReviewItems // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,profileError: freezed == profileError ? _self.profileError : profileError // ignore: cast_nullable_to_non_nullable
as String?,dashboardError: freezed == dashboardError ? _self.dashboardError : dashboardError // ignore: cast_nullable_to_non_nullable
as String?,materialsError: freezed == materialsError ? _self.materialsError : materialsError // ignore: cast_nullable_to_non_nullable
as String?,quizItemsError: freezed == quizItemsError ? _self.quizItemsError : quizItemsError // ignore: cast_nullable_to_non_nullable
as String?,sessionsError: freezed == sessionsError ? _self.sessionsError : sessionsError // ignore: cast_nullable_to_non_nullable
as String?,reviewItemsError: freezed == reviewItemsError ? _self.reviewItemsError : reviewItemsError // ignore: cast_nullable_to_non_nullable
as String?,showEmptyState: null == showEmptyState ? _self.showEmptyState : showEmptyState // ignore: cast_nullable_to_non_nullable
as bool,edgeFunctionName: null == edgeFunctionName ? _self.edgeFunctionName : edgeFunctionName // ignore: cast_nullable_to_non_nullable
as String,edgeFunctionResponse: freezed == edgeFunctionResponse ? _self.edgeFunctionResponse : edgeFunctionResponse // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isCallingEdgeFunction: null == isCallingEdgeFunction ? _self.isCallingEdgeFunction : isCallingEdgeFunction // ignore: cast_nullable_to_non_nullable
as bool,edgeFunctionError: freezed == edgeFunctionError ? _self.edgeFunctionError : edgeFunctionError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc


class _HomeState extends HomeState {
  const _HomeState({this.userProfile, this.dashboardData, this.materialCount = 0, this.quizItemCount = 0, final  List<UpcomingSession> upcomingSessions = const [], final  List<ReviewItem> reviewItems = const [], this.isLoading = false, this.isRefreshing = false, this.isLoadingProfile = false, this.isLoadingDashboard = false, this.isLoadingMaterials = false, this.isLoadingQuizItems = false, this.isLoadingSessions = false, this.isLoadingReviewItems = false, this.error, this.profileError, this.dashboardError, this.materialsError, this.quizItemsError, this.sessionsError, this.reviewItemsError, this.showEmptyState = false, this.edgeFunctionName = 'Scholar', final  Map<String, dynamic>? edgeFunctionResponse, this.isCallingEdgeFunction = false, this.edgeFunctionError}): _upcomingSessions = upcomingSessions,_reviewItems = reviewItems,_edgeFunctionResponse = edgeFunctionResponse,super._();
  

// User data
@override final  ProfileEntity? userProfile;
// Dashboard data
@override final  DashboardData? dashboardData;
// Individual data components
@override@JsonKey() final  int materialCount;
@override@JsonKey() final  int quizItemCount;
 final  List<UpcomingSession> _upcomingSessions;
@override@JsonKey() List<UpcomingSession> get upcomingSessions {
  if (_upcomingSessions is EqualUnmodifiableListView) return _upcomingSessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upcomingSessions);
}

 final  List<ReviewItem> _reviewItems;
@override@JsonKey() List<ReviewItem> get reviewItems {
  if (_reviewItems is EqualUnmodifiableListView) return _reviewItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviewItems);
}

// Loading states
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isRefreshing;
@override@JsonKey() final  bool isLoadingProfile;
@override@JsonKey() final  bool isLoadingDashboard;
@override@JsonKey() final  bool isLoadingMaterials;
@override@JsonKey() final  bool isLoadingQuizItems;
@override@JsonKey() final  bool isLoadingSessions;
@override@JsonKey() final  bool isLoadingReviewItems;
// Error handling
@override final  String? error;
@override final  String? profileError;
@override final  String? dashboardError;
@override final  String? materialsError;
@override final  String? quizItemsError;
@override final  String? sessionsError;
@override final  String? reviewItemsError;
// UI states
@override@JsonKey() final  bool showEmptyState;
// Edge function demo state
@override@JsonKey() final  String edgeFunctionName;
 final  Map<String, dynamic>? _edgeFunctionResponse;
@override Map<String, dynamic>? get edgeFunctionResponse {
  final value = _edgeFunctionResponse;
  if (value == null) return null;
  if (_edgeFunctionResponse is EqualUnmodifiableMapView) return _edgeFunctionResponse;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  bool isCallingEdgeFunction;
@override final  String? edgeFunctionError;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.userProfile, userProfile) || other.userProfile == userProfile)&&(identical(other.dashboardData, dashboardData) || other.dashboardData == dashboardData)&&(identical(other.materialCount, materialCount) || other.materialCount == materialCount)&&(identical(other.quizItemCount, quizItemCount) || other.quizItemCount == quizItemCount)&&const DeepCollectionEquality().equals(other._upcomingSessions, _upcomingSessions)&&const DeepCollectionEquality().equals(other._reviewItems, _reviewItems)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.isLoadingProfile, isLoadingProfile) || other.isLoadingProfile == isLoadingProfile)&&(identical(other.isLoadingDashboard, isLoadingDashboard) || other.isLoadingDashboard == isLoadingDashboard)&&(identical(other.isLoadingMaterials, isLoadingMaterials) || other.isLoadingMaterials == isLoadingMaterials)&&(identical(other.isLoadingQuizItems, isLoadingQuizItems) || other.isLoadingQuizItems == isLoadingQuizItems)&&(identical(other.isLoadingSessions, isLoadingSessions) || other.isLoadingSessions == isLoadingSessions)&&(identical(other.isLoadingReviewItems, isLoadingReviewItems) || other.isLoadingReviewItems == isLoadingReviewItems)&&(identical(other.error, error) || other.error == error)&&(identical(other.profileError, profileError) || other.profileError == profileError)&&(identical(other.dashboardError, dashboardError) || other.dashboardError == dashboardError)&&(identical(other.materialsError, materialsError) || other.materialsError == materialsError)&&(identical(other.quizItemsError, quizItemsError) || other.quizItemsError == quizItemsError)&&(identical(other.sessionsError, sessionsError) || other.sessionsError == sessionsError)&&(identical(other.reviewItemsError, reviewItemsError) || other.reviewItemsError == reviewItemsError)&&(identical(other.showEmptyState, showEmptyState) || other.showEmptyState == showEmptyState)&&(identical(other.edgeFunctionName, edgeFunctionName) || other.edgeFunctionName == edgeFunctionName)&&const DeepCollectionEquality().equals(other._edgeFunctionResponse, _edgeFunctionResponse)&&(identical(other.isCallingEdgeFunction, isCallingEdgeFunction) || other.isCallingEdgeFunction == isCallingEdgeFunction)&&(identical(other.edgeFunctionError, edgeFunctionError) || other.edgeFunctionError == edgeFunctionError));
}


@override
int get hashCode => Object.hashAll([runtimeType,userProfile,dashboardData,materialCount,quizItemCount,const DeepCollectionEquality().hash(_upcomingSessions),const DeepCollectionEquality().hash(_reviewItems),isLoading,isRefreshing,isLoadingProfile,isLoadingDashboard,isLoadingMaterials,isLoadingQuizItems,isLoadingSessions,isLoadingReviewItems,error,profileError,dashboardError,materialsError,quizItemsError,sessionsError,reviewItemsError,showEmptyState,edgeFunctionName,const DeepCollectionEquality().hash(_edgeFunctionResponse),isCallingEdgeFunction,edgeFunctionError]);

@override
String toString() {
  return 'HomeState(userProfile: $userProfile, dashboardData: $dashboardData, materialCount: $materialCount, quizItemCount: $quizItemCount, upcomingSessions: $upcomingSessions, reviewItems: $reviewItems, isLoading: $isLoading, isRefreshing: $isRefreshing, isLoadingProfile: $isLoadingProfile, isLoadingDashboard: $isLoadingDashboard, isLoadingMaterials: $isLoadingMaterials, isLoadingQuizItems: $isLoadingQuizItems, isLoadingSessions: $isLoadingSessions, isLoadingReviewItems: $isLoadingReviewItems, error: $error, profileError: $profileError, dashboardError: $dashboardError, materialsError: $materialsError, quizItemsError: $quizItemsError, sessionsError: $sessionsError, reviewItemsError: $reviewItemsError, showEmptyState: $showEmptyState, edgeFunctionName: $edgeFunctionName, edgeFunctionResponse: $edgeFunctionResponse, isCallingEdgeFunction: $isCallingEdgeFunction, edgeFunctionError: $edgeFunctionError)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 ProfileEntity? userProfile, DashboardData? dashboardData, int materialCount, int quizItemCount, List<UpcomingSession> upcomingSessions, List<ReviewItem> reviewItems, bool isLoading, bool isRefreshing, bool isLoadingProfile, bool isLoadingDashboard, bool isLoadingMaterials, bool isLoadingQuizItems, bool isLoadingSessions, bool isLoadingReviewItems, String? error, String? profileError, String? dashboardError, String? materialsError, String? quizItemsError, String? sessionsError, String? reviewItemsError, bool showEmptyState, String edgeFunctionName, Map<String, dynamic>? edgeFunctionResponse, bool isCallingEdgeFunction, String? edgeFunctionError
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userProfile = freezed,Object? dashboardData = freezed,Object? materialCount = null,Object? quizItemCount = null,Object? upcomingSessions = null,Object? reviewItems = null,Object? isLoading = null,Object? isRefreshing = null,Object? isLoadingProfile = null,Object? isLoadingDashboard = null,Object? isLoadingMaterials = null,Object? isLoadingQuizItems = null,Object? isLoadingSessions = null,Object? isLoadingReviewItems = null,Object? error = freezed,Object? profileError = freezed,Object? dashboardError = freezed,Object? materialsError = freezed,Object? quizItemsError = freezed,Object? sessionsError = freezed,Object? reviewItemsError = freezed,Object? showEmptyState = null,Object? edgeFunctionName = null,Object? edgeFunctionResponse = freezed,Object? isCallingEdgeFunction = null,Object? edgeFunctionError = freezed,}) {
  return _then(_HomeState(
userProfile: freezed == userProfile ? _self.userProfile : userProfile // ignore: cast_nullable_to_non_nullable
as ProfileEntity?,dashboardData: freezed == dashboardData ? _self.dashboardData : dashboardData // ignore: cast_nullable_to_non_nullable
as DashboardData?,materialCount: null == materialCount ? _self.materialCount : materialCount // ignore: cast_nullable_to_non_nullable
as int,quizItemCount: null == quizItemCount ? _self.quizItemCount : quizItemCount // ignore: cast_nullable_to_non_nullable
as int,upcomingSessions: null == upcomingSessions ? _self._upcomingSessions : upcomingSessions // ignore: cast_nullable_to_non_nullable
as List<UpcomingSession>,reviewItems: null == reviewItems ? _self._reviewItems : reviewItems // ignore: cast_nullable_to_non_nullable
as List<ReviewItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,isLoadingProfile: null == isLoadingProfile ? _self.isLoadingProfile : isLoadingProfile // ignore: cast_nullable_to_non_nullable
as bool,isLoadingDashboard: null == isLoadingDashboard ? _self.isLoadingDashboard : isLoadingDashboard // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMaterials: null == isLoadingMaterials ? _self.isLoadingMaterials : isLoadingMaterials // ignore: cast_nullable_to_non_nullable
as bool,isLoadingQuizItems: null == isLoadingQuizItems ? _self.isLoadingQuizItems : isLoadingQuizItems // ignore: cast_nullable_to_non_nullable
as bool,isLoadingSessions: null == isLoadingSessions ? _self.isLoadingSessions : isLoadingSessions // ignore: cast_nullable_to_non_nullable
as bool,isLoadingReviewItems: null == isLoadingReviewItems ? _self.isLoadingReviewItems : isLoadingReviewItems // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,profileError: freezed == profileError ? _self.profileError : profileError // ignore: cast_nullable_to_non_nullable
as String?,dashboardError: freezed == dashboardError ? _self.dashboardError : dashboardError // ignore: cast_nullable_to_non_nullable
as String?,materialsError: freezed == materialsError ? _self.materialsError : materialsError // ignore: cast_nullable_to_non_nullable
as String?,quizItemsError: freezed == quizItemsError ? _self.quizItemsError : quizItemsError // ignore: cast_nullable_to_non_nullable
as String?,sessionsError: freezed == sessionsError ? _self.sessionsError : sessionsError // ignore: cast_nullable_to_non_nullable
as String?,reviewItemsError: freezed == reviewItemsError ? _self.reviewItemsError : reviewItemsError // ignore: cast_nullable_to_non_nullable
as String?,showEmptyState: null == showEmptyState ? _self.showEmptyState : showEmptyState // ignore: cast_nullable_to_non_nullable
as bool,edgeFunctionName: null == edgeFunctionName ? _self.edgeFunctionName : edgeFunctionName // ignore: cast_nullable_to_non_nullable
as String,edgeFunctionResponse: freezed == edgeFunctionResponse ? _self._edgeFunctionResponse : edgeFunctionResponse // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isCallingEdgeFunction: null == isCallingEdgeFunction ? _self.isCallingEdgeFunction : isCallingEdgeFunction // ignore: cast_nullable_to_non_nullable
as bool,edgeFunctionError: freezed == edgeFunctionError ? _self.edgeFunctionError : edgeFunctionError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
