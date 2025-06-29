// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_quiz_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditQuizState {

// Core data
 QuizEntity? get originalQuiz; List<QuizItemEntity> get originalQuizItems;// Form fields
 String get title; String get description; Subject? get selectedSubject; String? get selectedStudyMaterialId;// Quiz items being edited
 List<QuizItemData> get quizItems;// Loading states
 bool get isLoading; bool get isLoadingQuizData; bool get isUpdating; bool get isLoadingStudyMaterials;// UI states
 bool get showValidationErrors; bool get hasUnsavedChanges;// Data
 List<StudyMaterialOption> get availableStudyMaterials;// Linked study material metadata (for AI-generated quizzes)
 StudyMaterialEntity? get linkedStudyMaterial; bool get isLoadingLinkedStudyMaterial;// Error handling
 String? get error; String? get fieldError;// Success state
 QuizEntity? get updatedQuiz; bool get isSuccess;
/// Create a copy of EditQuizState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditQuizStateCopyWith<EditQuizState> get copyWith => _$EditQuizStateCopyWithImpl<EditQuizState>(this as EditQuizState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditQuizState&&(identical(other.originalQuiz, originalQuiz) || other.originalQuiz == originalQuiz)&&const DeepCollectionEquality().equals(other.originalQuizItems, originalQuizItems)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.selectedSubject, selectedSubject) || other.selectedSubject == selectedSubject)&&(identical(other.selectedStudyMaterialId, selectedStudyMaterialId) || other.selectedStudyMaterialId == selectedStudyMaterialId)&&const DeepCollectionEquality().equals(other.quizItems, quizItems)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingQuizData, isLoadingQuizData) || other.isLoadingQuizData == isLoadingQuizData)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.isLoadingStudyMaterials, isLoadingStudyMaterials) || other.isLoadingStudyMaterials == isLoadingStudyMaterials)&&(identical(other.showValidationErrors, showValidationErrors) || other.showValidationErrors == showValidationErrors)&&(identical(other.hasUnsavedChanges, hasUnsavedChanges) || other.hasUnsavedChanges == hasUnsavedChanges)&&const DeepCollectionEquality().equals(other.availableStudyMaterials, availableStudyMaterials)&&(identical(other.linkedStudyMaterial, linkedStudyMaterial) || other.linkedStudyMaterial == linkedStudyMaterial)&&(identical(other.isLoadingLinkedStudyMaterial, isLoadingLinkedStudyMaterial) || other.isLoadingLinkedStudyMaterial == isLoadingLinkedStudyMaterial)&&(identical(other.error, error) || other.error == error)&&(identical(other.fieldError, fieldError) || other.fieldError == fieldError)&&(identical(other.updatedQuiz, updatedQuiz) || other.updatedQuiz == updatedQuiz)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess));
}


@override
int get hashCode => Object.hashAll([runtimeType,originalQuiz,const DeepCollectionEquality().hash(originalQuizItems),title,description,selectedSubject,selectedStudyMaterialId,const DeepCollectionEquality().hash(quizItems),isLoading,isLoadingQuizData,isUpdating,isLoadingStudyMaterials,showValidationErrors,hasUnsavedChanges,const DeepCollectionEquality().hash(availableStudyMaterials),linkedStudyMaterial,isLoadingLinkedStudyMaterial,error,fieldError,updatedQuiz,isSuccess]);

@override
String toString() {
  return 'EditQuizState(originalQuiz: $originalQuiz, originalQuizItems: $originalQuizItems, title: $title, description: $description, selectedSubject: $selectedSubject, selectedStudyMaterialId: $selectedStudyMaterialId, quizItems: $quizItems, isLoading: $isLoading, isLoadingQuizData: $isLoadingQuizData, isUpdating: $isUpdating, isLoadingStudyMaterials: $isLoadingStudyMaterials, showValidationErrors: $showValidationErrors, hasUnsavedChanges: $hasUnsavedChanges, availableStudyMaterials: $availableStudyMaterials, linkedStudyMaterial: $linkedStudyMaterial, isLoadingLinkedStudyMaterial: $isLoadingLinkedStudyMaterial, error: $error, fieldError: $fieldError, updatedQuiz: $updatedQuiz, isSuccess: $isSuccess)';
}


}

/// @nodoc
abstract mixin class $EditQuizStateCopyWith<$Res>  {
  factory $EditQuizStateCopyWith(EditQuizState value, $Res Function(EditQuizState) _then) = _$EditQuizStateCopyWithImpl;
@useResult
$Res call({
 QuizEntity? originalQuiz, List<QuizItemEntity> originalQuizItems, String title, String description, Subject? selectedSubject, String? selectedStudyMaterialId, List<QuizItemData> quizItems, bool isLoading, bool isLoadingQuizData, bool isUpdating, bool isLoadingStudyMaterials, bool showValidationErrors, bool hasUnsavedChanges, List<StudyMaterialOption> availableStudyMaterials, StudyMaterialEntity? linkedStudyMaterial, bool isLoadingLinkedStudyMaterial, String? error, String? fieldError, QuizEntity? updatedQuiz, bool isSuccess
});




}
/// @nodoc
class _$EditQuizStateCopyWithImpl<$Res>
    implements $EditQuizStateCopyWith<$Res> {
  _$EditQuizStateCopyWithImpl(this._self, this._then);

  final EditQuizState _self;
  final $Res Function(EditQuizState) _then;

/// Create a copy of EditQuizState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? originalQuiz = freezed,Object? originalQuizItems = null,Object? title = null,Object? description = null,Object? selectedSubject = freezed,Object? selectedStudyMaterialId = freezed,Object? quizItems = null,Object? isLoading = null,Object? isLoadingQuizData = null,Object? isUpdating = null,Object? isLoadingStudyMaterials = null,Object? showValidationErrors = null,Object? hasUnsavedChanges = null,Object? availableStudyMaterials = null,Object? linkedStudyMaterial = freezed,Object? isLoadingLinkedStudyMaterial = null,Object? error = freezed,Object? fieldError = freezed,Object? updatedQuiz = freezed,Object? isSuccess = null,}) {
  return _then(_self.copyWith(
originalQuiz: freezed == originalQuiz ? _self.originalQuiz : originalQuiz // ignore: cast_nullable_to_non_nullable
as QuizEntity?,originalQuizItems: null == originalQuizItems ? _self.originalQuizItems : originalQuizItems // ignore: cast_nullable_to_non_nullable
as List<QuizItemEntity>,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,selectedSubject: freezed == selectedSubject ? _self.selectedSubject : selectedSubject // ignore: cast_nullable_to_non_nullable
as Subject?,selectedStudyMaterialId: freezed == selectedStudyMaterialId ? _self.selectedStudyMaterialId : selectedStudyMaterialId // ignore: cast_nullable_to_non_nullable
as String?,quizItems: null == quizItems ? _self.quizItems : quizItems // ignore: cast_nullable_to_non_nullable
as List<QuizItemData>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingQuizData: null == isLoadingQuizData ? _self.isLoadingQuizData : isLoadingQuizData // ignore: cast_nullable_to_non_nullable
as bool,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,isLoadingStudyMaterials: null == isLoadingStudyMaterials ? _self.isLoadingStudyMaterials : isLoadingStudyMaterials // ignore: cast_nullable_to_non_nullable
as bool,showValidationErrors: null == showValidationErrors ? _self.showValidationErrors : showValidationErrors // ignore: cast_nullable_to_non_nullable
as bool,hasUnsavedChanges: null == hasUnsavedChanges ? _self.hasUnsavedChanges : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
as bool,availableStudyMaterials: null == availableStudyMaterials ? _self.availableStudyMaterials : availableStudyMaterials // ignore: cast_nullable_to_non_nullable
as List<StudyMaterialOption>,linkedStudyMaterial: freezed == linkedStudyMaterial ? _self.linkedStudyMaterial : linkedStudyMaterial // ignore: cast_nullable_to_non_nullable
as StudyMaterialEntity?,isLoadingLinkedStudyMaterial: null == isLoadingLinkedStudyMaterial ? _self.isLoadingLinkedStudyMaterial : isLoadingLinkedStudyMaterial // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,fieldError: freezed == fieldError ? _self.fieldError : fieldError // ignore: cast_nullable_to_non_nullable
as String?,updatedQuiz: freezed == updatedQuiz ? _self.updatedQuiz : updatedQuiz // ignore: cast_nullable_to_non_nullable
as QuizEntity?,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc


class _EditQuizState extends EditQuizState {
  const _EditQuizState({this.originalQuiz, final  List<QuizItemEntity> originalQuizItems = const [], this.title = '', this.description = '', this.selectedSubject, this.selectedStudyMaterialId, final  List<QuizItemData> quizItems = const [], this.isLoading = false, this.isLoadingQuizData = false, this.isUpdating = false, this.isLoadingStudyMaterials = false, this.showValidationErrors = false, this.hasUnsavedChanges = false, final  List<StudyMaterialOption> availableStudyMaterials = const [], this.linkedStudyMaterial, this.isLoadingLinkedStudyMaterial = false, this.error, this.fieldError, this.updatedQuiz, this.isSuccess = false}): _originalQuizItems = originalQuizItems,_quizItems = quizItems,_availableStudyMaterials = availableStudyMaterials,super._();
  

// Core data
@override final  QuizEntity? originalQuiz;
 final  List<QuizItemEntity> _originalQuizItems;
@override@JsonKey() List<QuizItemEntity> get originalQuizItems {
  if (_originalQuizItems is EqualUnmodifiableListView) return _originalQuizItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_originalQuizItems);
}

// Form fields
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override final  Subject? selectedSubject;
@override final  String? selectedStudyMaterialId;
// Quiz items being edited
 final  List<QuizItemData> _quizItems;
// Quiz items being edited
@override@JsonKey() List<QuizItemData> get quizItems {
  if (_quizItems is EqualUnmodifiableListView) return _quizItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quizItems);
}

// Loading states
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isLoadingQuizData;
@override@JsonKey() final  bool isUpdating;
@override@JsonKey() final  bool isLoadingStudyMaterials;
// UI states
@override@JsonKey() final  bool showValidationErrors;
@override@JsonKey() final  bool hasUnsavedChanges;
// Data
 final  List<StudyMaterialOption> _availableStudyMaterials;
// Data
@override@JsonKey() List<StudyMaterialOption> get availableStudyMaterials {
  if (_availableStudyMaterials is EqualUnmodifiableListView) return _availableStudyMaterials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableStudyMaterials);
}

// Linked study material metadata (for AI-generated quizzes)
@override final  StudyMaterialEntity? linkedStudyMaterial;
@override@JsonKey() final  bool isLoadingLinkedStudyMaterial;
// Error handling
@override final  String? error;
@override final  String? fieldError;
// Success state
@override final  QuizEntity? updatedQuiz;
@override@JsonKey() final  bool isSuccess;

/// Create a copy of EditQuizState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditQuizStateCopyWith<_EditQuizState> get copyWith => __$EditQuizStateCopyWithImpl<_EditQuizState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditQuizState&&(identical(other.originalQuiz, originalQuiz) || other.originalQuiz == originalQuiz)&&const DeepCollectionEquality().equals(other._originalQuizItems, _originalQuizItems)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.selectedSubject, selectedSubject) || other.selectedSubject == selectedSubject)&&(identical(other.selectedStudyMaterialId, selectedStudyMaterialId) || other.selectedStudyMaterialId == selectedStudyMaterialId)&&const DeepCollectionEquality().equals(other._quizItems, _quizItems)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingQuizData, isLoadingQuizData) || other.isLoadingQuizData == isLoadingQuizData)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.isLoadingStudyMaterials, isLoadingStudyMaterials) || other.isLoadingStudyMaterials == isLoadingStudyMaterials)&&(identical(other.showValidationErrors, showValidationErrors) || other.showValidationErrors == showValidationErrors)&&(identical(other.hasUnsavedChanges, hasUnsavedChanges) || other.hasUnsavedChanges == hasUnsavedChanges)&&const DeepCollectionEquality().equals(other._availableStudyMaterials, _availableStudyMaterials)&&(identical(other.linkedStudyMaterial, linkedStudyMaterial) || other.linkedStudyMaterial == linkedStudyMaterial)&&(identical(other.isLoadingLinkedStudyMaterial, isLoadingLinkedStudyMaterial) || other.isLoadingLinkedStudyMaterial == isLoadingLinkedStudyMaterial)&&(identical(other.error, error) || other.error == error)&&(identical(other.fieldError, fieldError) || other.fieldError == fieldError)&&(identical(other.updatedQuiz, updatedQuiz) || other.updatedQuiz == updatedQuiz)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess));
}


@override
int get hashCode => Object.hashAll([runtimeType,originalQuiz,const DeepCollectionEquality().hash(_originalQuizItems),title,description,selectedSubject,selectedStudyMaterialId,const DeepCollectionEquality().hash(_quizItems),isLoading,isLoadingQuizData,isUpdating,isLoadingStudyMaterials,showValidationErrors,hasUnsavedChanges,const DeepCollectionEquality().hash(_availableStudyMaterials),linkedStudyMaterial,isLoadingLinkedStudyMaterial,error,fieldError,updatedQuiz,isSuccess]);

@override
String toString() {
  return 'EditQuizState(originalQuiz: $originalQuiz, originalQuizItems: $originalQuizItems, title: $title, description: $description, selectedSubject: $selectedSubject, selectedStudyMaterialId: $selectedStudyMaterialId, quizItems: $quizItems, isLoading: $isLoading, isLoadingQuizData: $isLoadingQuizData, isUpdating: $isUpdating, isLoadingStudyMaterials: $isLoadingStudyMaterials, showValidationErrors: $showValidationErrors, hasUnsavedChanges: $hasUnsavedChanges, availableStudyMaterials: $availableStudyMaterials, linkedStudyMaterial: $linkedStudyMaterial, isLoadingLinkedStudyMaterial: $isLoadingLinkedStudyMaterial, error: $error, fieldError: $fieldError, updatedQuiz: $updatedQuiz, isSuccess: $isSuccess)';
}


}

/// @nodoc
abstract mixin class _$EditQuizStateCopyWith<$Res> implements $EditQuizStateCopyWith<$Res> {
  factory _$EditQuizStateCopyWith(_EditQuizState value, $Res Function(_EditQuizState) _then) = __$EditQuizStateCopyWithImpl;
@override @useResult
$Res call({
 QuizEntity? originalQuiz, List<QuizItemEntity> originalQuizItems, String title, String description, Subject? selectedSubject, String? selectedStudyMaterialId, List<QuizItemData> quizItems, bool isLoading, bool isLoadingQuizData, bool isUpdating, bool isLoadingStudyMaterials, bool showValidationErrors, bool hasUnsavedChanges, List<StudyMaterialOption> availableStudyMaterials, StudyMaterialEntity? linkedStudyMaterial, bool isLoadingLinkedStudyMaterial, String? error, String? fieldError, QuizEntity? updatedQuiz, bool isSuccess
});




}
/// @nodoc
class __$EditQuizStateCopyWithImpl<$Res>
    implements _$EditQuizStateCopyWith<$Res> {
  __$EditQuizStateCopyWithImpl(this._self, this._then);

  final _EditQuizState _self;
  final $Res Function(_EditQuizState) _then;

/// Create a copy of EditQuizState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? originalQuiz = freezed,Object? originalQuizItems = null,Object? title = null,Object? description = null,Object? selectedSubject = freezed,Object? selectedStudyMaterialId = freezed,Object? quizItems = null,Object? isLoading = null,Object? isLoadingQuizData = null,Object? isUpdating = null,Object? isLoadingStudyMaterials = null,Object? showValidationErrors = null,Object? hasUnsavedChanges = null,Object? availableStudyMaterials = null,Object? linkedStudyMaterial = freezed,Object? isLoadingLinkedStudyMaterial = null,Object? error = freezed,Object? fieldError = freezed,Object? updatedQuiz = freezed,Object? isSuccess = null,}) {
  return _then(_EditQuizState(
originalQuiz: freezed == originalQuiz ? _self.originalQuiz : originalQuiz // ignore: cast_nullable_to_non_nullable
as QuizEntity?,originalQuizItems: null == originalQuizItems ? _self._originalQuizItems : originalQuizItems // ignore: cast_nullable_to_non_nullable
as List<QuizItemEntity>,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,selectedSubject: freezed == selectedSubject ? _self.selectedSubject : selectedSubject // ignore: cast_nullable_to_non_nullable
as Subject?,selectedStudyMaterialId: freezed == selectedStudyMaterialId ? _self.selectedStudyMaterialId : selectedStudyMaterialId // ignore: cast_nullable_to_non_nullable
as String?,quizItems: null == quizItems ? _self._quizItems : quizItems // ignore: cast_nullable_to_non_nullable
as List<QuizItemData>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingQuizData: null == isLoadingQuizData ? _self.isLoadingQuizData : isLoadingQuizData // ignore: cast_nullable_to_non_nullable
as bool,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,isLoadingStudyMaterials: null == isLoadingStudyMaterials ? _self.isLoadingStudyMaterials : isLoadingStudyMaterials // ignore: cast_nullable_to_non_nullable
as bool,showValidationErrors: null == showValidationErrors ? _self.showValidationErrors : showValidationErrors // ignore: cast_nullable_to_non_nullable
as bool,hasUnsavedChanges: null == hasUnsavedChanges ? _self.hasUnsavedChanges : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
as bool,availableStudyMaterials: null == availableStudyMaterials ? _self._availableStudyMaterials : availableStudyMaterials // ignore: cast_nullable_to_non_nullable
as List<StudyMaterialOption>,linkedStudyMaterial: freezed == linkedStudyMaterial ? _self.linkedStudyMaterial : linkedStudyMaterial // ignore: cast_nullable_to_non_nullable
as StudyMaterialEntity?,isLoadingLinkedStudyMaterial: null == isLoadingLinkedStudyMaterial ? _self.isLoadingLinkedStudyMaterial : isLoadingLinkedStudyMaterial // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,fieldError: freezed == fieldError ? _self.fieldError : fieldError // ignore: cast_nullable_to_non_nullable
as String?,updatedQuiz: freezed == updatedQuiz ? _self.updatedQuiz : updatedQuiz // ignore: cast_nullable_to_non_nullable
as QuizEntity?,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
