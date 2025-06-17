// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_material_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StudyMaterialState {

 List<StudyMaterialEntity> get materials; bool get isLoading; bool get isLoadingMaterial; bool get isCreating; bool get isUpdating; bool get isDeleting; bool get isGeneratingSummary; bool get isProcessingOcr; String? get error; String? get selectedMaterialId; StudyMaterialEntity? get selectedMaterial; String get searchQuery; Subject? get selectedSubject; ContentType? get selectedContentType;
/// Create a copy of StudyMaterialState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudyMaterialStateCopyWith<StudyMaterialState> get copyWith => _$StudyMaterialStateCopyWithImpl<StudyMaterialState>(this as StudyMaterialState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudyMaterialState&&const DeepCollectionEquality().equals(other.materials, materials)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMaterial, isLoadingMaterial) || other.isLoadingMaterial == isLoadingMaterial)&&(identical(other.isCreating, isCreating) || other.isCreating == isCreating)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.isDeleting, isDeleting) || other.isDeleting == isDeleting)&&(identical(other.isGeneratingSummary, isGeneratingSummary) || other.isGeneratingSummary == isGeneratingSummary)&&(identical(other.isProcessingOcr, isProcessingOcr) || other.isProcessingOcr == isProcessingOcr)&&(identical(other.error, error) || other.error == error)&&(identical(other.selectedMaterialId, selectedMaterialId) || other.selectedMaterialId == selectedMaterialId)&&(identical(other.selectedMaterial, selectedMaterial) || other.selectedMaterial == selectedMaterial)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.selectedSubject, selectedSubject) || other.selectedSubject == selectedSubject)&&(identical(other.selectedContentType, selectedContentType) || other.selectedContentType == selectedContentType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(materials),isLoading,isLoadingMaterial,isCreating,isUpdating,isDeleting,isGeneratingSummary,isProcessingOcr,error,selectedMaterialId,selectedMaterial,searchQuery,selectedSubject,selectedContentType);

@override
String toString() {
  return 'StudyMaterialState(materials: $materials, isLoading: $isLoading, isLoadingMaterial: $isLoadingMaterial, isCreating: $isCreating, isUpdating: $isUpdating, isDeleting: $isDeleting, isGeneratingSummary: $isGeneratingSummary, isProcessingOcr: $isProcessingOcr, error: $error, selectedMaterialId: $selectedMaterialId, selectedMaterial: $selectedMaterial, searchQuery: $searchQuery, selectedSubject: $selectedSubject, selectedContentType: $selectedContentType)';
}


}

/// @nodoc
abstract mixin class $StudyMaterialStateCopyWith<$Res>  {
  factory $StudyMaterialStateCopyWith(StudyMaterialState value, $Res Function(StudyMaterialState) _then) = _$StudyMaterialStateCopyWithImpl;
@useResult
$Res call({
 List<StudyMaterialEntity> materials, bool isLoading, bool isLoadingMaterial, bool isCreating, bool isUpdating, bool isDeleting, bool isGeneratingSummary, bool isProcessingOcr, String? error, String? selectedMaterialId, StudyMaterialEntity? selectedMaterial, String searchQuery, Subject? selectedSubject, ContentType? selectedContentType
});




}
/// @nodoc
class _$StudyMaterialStateCopyWithImpl<$Res>
    implements $StudyMaterialStateCopyWith<$Res> {
  _$StudyMaterialStateCopyWithImpl(this._self, this._then);

  final StudyMaterialState _self;
  final $Res Function(StudyMaterialState) _then;

/// Create a copy of StudyMaterialState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? materials = null,Object? isLoading = null,Object? isLoadingMaterial = null,Object? isCreating = null,Object? isUpdating = null,Object? isDeleting = null,Object? isGeneratingSummary = null,Object? isProcessingOcr = null,Object? error = freezed,Object? selectedMaterialId = freezed,Object? selectedMaterial = freezed,Object? searchQuery = null,Object? selectedSubject = freezed,Object? selectedContentType = freezed,}) {
  return _then(_self.copyWith(
materials: null == materials ? _self.materials : materials // ignore: cast_nullable_to_non_nullable
as List<StudyMaterialEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMaterial: null == isLoadingMaterial ? _self.isLoadingMaterial : isLoadingMaterial // ignore: cast_nullable_to_non_nullable
as bool,isCreating: null == isCreating ? _self.isCreating : isCreating // ignore: cast_nullable_to_non_nullable
as bool,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,isDeleting: null == isDeleting ? _self.isDeleting : isDeleting // ignore: cast_nullable_to_non_nullable
as bool,isGeneratingSummary: null == isGeneratingSummary ? _self.isGeneratingSummary : isGeneratingSummary // ignore: cast_nullable_to_non_nullable
as bool,isProcessingOcr: null == isProcessingOcr ? _self.isProcessingOcr : isProcessingOcr // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,selectedMaterialId: freezed == selectedMaterialId ? _self.selectedMaterialId : selectedMaterialId // ignore: cast_nullable_to_non_nullable
as String?,selectedMaterial: freezed == selectedMaterial ? _self.selectedMaterial : selectedMaterial // ignore: cast_nullable_to_non_nullable
as StudyMaterialEntity?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedSubject: freezed == selectedSubject ? _self.selectedSubject : selectedSubject // ignore: cast_nullable_to_non_nullable
as Subject?,selectedContentType: freezed == selectedContentType ? _self.selectedContentType : selectedContentType // ignore: cast_nullable_to_non_nullable
as ContentType?,
  ));
}

}


/// @nodoc


class _StudyMaterialState extends StudyMaterialState {
  const _StudyMaterialState({final  List<StudyMaterialEntity> materials = const [], this.isLoading = false, this.isLoadingMaterial = false, this.isCreating = false, this.isUpdating = false, this.isDeleting = false, this.isGeneratingSummary = false, this.isProcessingOcr = false, this.error, this.selectedMaterialId, this.selectedMaterial, this.searchQuery = '', this.selectedSubject, this.selectedContentType}): _materials = materials,super._();
  

 final  List<StudyMaterialEntity> _materials;
@override@JsonKey() List<StudyMaterialEntity> get materials {
  if (_materials is EqualUnmodifiableListView) return _materials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_materials);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isLoadingMaterial;
@override@JsonKey() final  bool isCreating;
@override@JsonKey() final  bool isUpdating;
@override@JsonKey() final  bool isDeleting;
@override@JsonKey() final  bool isGeneratingSummary;
@override@JsonKey() final  bool isProcessingOcr;
@override final  String? error;
@override final  String? selectedMaterialId;
@override final  StudyMaterialEntity? selectedMaterial;
@override@JsonKey() final  String searchQuery;
@override final  Subject? selectedSubject;
@override final  ContentType? selectedContentType;

/// Create a copy of StudyMaterialState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudyMaterialStateCopyWith<_StudyMaterialState> get copyWith => __$StudyMaterialStateCopyWithImpl<_StudyMaterialState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudyMaterialState&&const DeepCollectionEquality().equals(other._materials, _materials)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMaterial, isLoadingMaterial) || other.isLoadingMaterial == isLoadingMaterial)&&(identical(other.isCreating, isCreating) || other.isCreating == isCreating)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.isDeleting, isDeleting) || other.isDeleting == isDeleting)&&(identical(other.isGeneratingSummary, isGeneratingSummary) || other.isGeneratingSummary == isGeneratingSummary)&&(identical(other.isProcessingOcr, isProcessingOcr) || other.isProcessingOcr == isProcessingOcr)&&(identical(other.error, error) || other.error == error)&&(identical(other.selectedMaterialId, selectedMaterialId) || other.selectedMaterialId == selectedMaterialId)&&(identical(other.selectedMaterial, selectedMaterial) || other.selectedMaterial == selectedMaterial)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.selectedSubject, selectedSubject) || other.selectedSubject == selectedSubject)&&(identical(other.selectedContentType, selectedContentType) || other.selectedContentType == selectedContentType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_materials),isLoading,isLoadingMaterial,isCreating,isUpdating,isDeleting,isGeneratingSummary,isProcessingOcr,error,selectedMaterialId,selectedMaterial,searchQuery,selectedSubject,selectedContentType);

@override
String toString() {
  return 'StudyMaterialState(materials: $materials, isLoading: $isLoading, isLoadingMaterial: $isLoadingMaterial, isCreating: $isCreating, isUpdating: $isUpdating, isDeleting: $isDeleting, isGeneratingSummary: $isGeneratingSummary, isProcessingOcr: $isProcessingOcr, error: $error, selectedMaterialId: $selectedMaterialId, selectedMaterial: $selectedMaterial, searchQuery: $searchQuery, selectedSubject: $selectedSubject, selectedContentType: $selectedContentType)';
}


}

/// @nodoc
abstract mixin class _$StudyMaterialStateCopyWith<$Res> implements $StudyMaterialStateCopyWith<$Res> {
  factory _$StudyMaterialStateCopyWith(_StudyMaterialState value, $Res Function(_StudyMaterialState) _then) = __$StudyMaterialStateCopyWithImpl;
@override @useResult
$Res call({
 List<StudyMaterialEntity> materials, bool isLoading, bool isLoadingMaterial, bool isCreating, bool isUpdating, bool isDeleting, bool isGeneratingSummary, bool isProcessingOcr, String? error, String? selectedMaterialId, StudyMaterialEntity? selectedMaterial, String searchQuery, Subject? selectedSubject, ContentType? selectedContentType
});




}
/// @nodoc
class __$StudyMaterialStateCopyWithImpl<$Res>
    implements _$StudyMaterialStateCopyWith<$Res> {
  __$StudyMaterialStateCopyWithImpl(this._self, this._then);

  final _StudyMaterialState _self;
  final $Res Function(_StudyMaterialState) _then;

/// Create a copy of StudyMaterialState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? materials = null,Object? isLoading = null,Object? isLoadingMaterial = null,Object? isCreating = null,Object? isUpdating = null,Object? isDeleting = null,Object? isGeneratingSummary = null,Object? isProcessingOcr = null,Object? error = freezed,Object? selectedMaterialId = freezed,Object? selectedMaterial = freezed,Object? searchQuery = null,Object? selectedSubject = freezed,Object? selectedContentType = freezed,}) {
  return _then(_StudyMaterialState(
materials: null == materials ? _self._materials : materials // ignore: cast_nullable_to_non_nullable
as List<StudyMaterialEntity>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMaterial: null == isLoadingMaterial ? _self.isLoadingMaterial : isLoadingMaterial // ignore: cast_nullable_to_non_nullable
as bool,isCreating: null == isCreating ? _self.isCreating : isCreating // ignore: cast_nullable_to_non_nullable
as bool,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,isDeleting: null == isDeleting ? _self.isDeleting : isDeleting // ignore: cast_nullable_to_non_nullable
as bool,isGeneratingSummary: null == isGeneratingSummary ? _self.isGeneratingSummary : isGeneratingSummary // ignore: cast_nullable_to_non_nullable
as bool,isProcessingOcr: null == isProcessingOcr ? _self.isProcessingOcr : isProcessingOcr // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,selectedMaterialId: freezed == selectedMaterialId ? _self.selectedMaterialId : selectedMaterialId // ignore: cast_nullable_to_non_nullable
as String?,selectedMaterial: freezed == selectedMaterial ? _self.selectedMaterial : selectedMaterial // ignore: cast_nullable_to_non_nullable
as StudyMaterialEntity?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedSubject: freezed == selectedSubject ? _self.selectedSubject : selectedSubject // ignore: cast_nullable_to_non_nullable
as Subject?,selectedContentType: freezed == selectedContentType ? _self.selectedContentType : selectedContentType // ignore: cast_nullable_to_non_nullable
as ContentType?,
  ));
}


}

// dart format on
