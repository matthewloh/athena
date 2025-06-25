// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_quiz_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateQuizState {

// Form fields
 String get title; String get description; Subject? get selectedSubject; String? get selectedStudyMaterialId; CreateQuizMode get mode; QuizType get selectedQuizType;// Quiz items being created
 List<QuizItemData> get quizItems;// Loading states
 bool get isLoading; bool get isCreating; bool get isGeneratingAi; bool get isLoadingStudyMaterials;// UI states
 bool get showValidationErrors; int get currentQuizItemIndex; bool get isExpanded;// Data
 List<StudyMaterialOption> get availableStudyMaterials;// Error handling
 String? get error; String? get fieldError;// Success state
 QuizEntity? get createdQuiz; bool get isSuccess;
/// Create a copy of CreateQuizState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateQuizStateCopyWith<CreateQuizState> get copyWith => _$CreateQuizStateCopyWithImpl<CreateQuizState>(this as CreateQuizState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateQuizState&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.selectedSubject, selectedSubject)&&(identical(other.selectedStudyMaterialId, selectedStudyMaterialId) || other.selectedStudyMaterialId == selectedStudyMaterialId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.selectedQuizType, selectedQuizType) || other.selectedQuizType == selectedQuizType)&&const DeepCollectionEquality().equals(other.quizItems, quizItems)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isCreating, isCreating) || other.isCreating == isCreating)&&(identical(other.isGeneratingAi, isGeneratingAi) || other.isGeneratingAi == isGeneratingAi)&&(identical(other.isLoadingStudyMaterials, isLoadingStudyMaterials) || other.isLoadingStudyMaterials == isLoadingStudyMaterials)&&(identical(other.showValidationErrors, showValidationErrors) || other.showValidationErrors == showValidationErrors)&&(identical(other.currentQuizItemIndex, currentQuizItemIndex) || other.currentQuizItemIndex == currentQuizItemIndex)&&(identical(other.isExpanded, isExpanded) || other.isExpanded == isExpanded)&&const DeepCollectionEquality().equals(other.availableStudyMaterials, availableStudyMaterials)&&(identical(other.error, error) || other.error == error)&&(identical(other.fieldError, fieldError) || other.fieldError == fieldError)&&(identical(other.createdQuiz, createdQuiz) || other.createdQuiz == createdQuiz)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess));
}


@override
int get hashCode => Object.hashAll([runtimeType,title,description,const DeepCollectionEquality().hash(selectedSubject),selectedStudyMaterialId,mode,selectedQuizType,const DeepCollectionEquality().hash(quizItems),isLoading,isCreating,isGeneratingAi,isLoadingStudyMaterials,showValidationErrors,currentQuizItemIndex,isExpanded,const DeepCollectionEquality().hash(availableStudyMaterials),error,fieldError,createdQuiz,isSuccess]);

@override
String toString() {
  return 'CreateQuizState(title: $title, description: $description, selectedSubject: $selectedSubject, selectedStudyMaterialId: $selectedStudyMaterialId, mode: $mode, selectedQuizType: $selectedQuizType, quizItems: $quizItems, isLoading: $isLoading, isCreating: $isCreating, isGeneratingAi: $isGeneratingAi, isLoadingStudyMaterials: $isLoadingStudyMaterials, showValidationErrors: $showValidationErrors, currentQuizItemIndex: $currentQuizItemIndex, isExpanded: $isExpanded, availableStudyMaterials: $availableStudyMaterials, error: $error, fieldError: $fieldError, createdQuiz: $createdQuiz, isSuccess: $isSuccess)';
}


}

/// @nodoc
abstract mixin class $CreateQuizStateCopyWith<$Res>  {
  factory $CreateQuizStateCopyWith(CreateQuizState value, $Res Function(CreateQuizState) _then) = _$CreateQuizStateCopyWithImpl;
@useResult
$Res call({
 String title, String description, Subject? selectedSubject, String? selectedStudyMaterialId, CreateQuizMode mode, QuizType selectedQuizType, List<QuizItemData> quizItems, bool isLoading, bool isCreating, bool isGeneratingAi, bool isLoadingStudyMaterials, bool showValidationErrors, int currentQuizItemIndex, bool isExpanded, List<StudyMaterialOption> availableStudyMaterials, String? error, String? fieldError, QuizEntity? createdQuiz, bool isSuccess
});




}
/// @nodoc
class _$CreateQuizStateCopyWithImpl<$Res>
    implements $CreateQuizStateCopyWith<$Res> {
  _$CreateQuizStateCopyWithImpl(this._self, this._then);

  final CreateQuizState _self;
  final $Res Function(CreateQuizState) _then;

/// Create a copy of CreateQuizState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? selectedSubject = freezed,Object? selectedStudyMaterialId = freezed,Object? mode = null,Object? selectedQuizType = null,Object? quizItems = null,Object? isLoading = null,Object? isCreating = null,Object? isGeneratingAi = null,Object? isLoadingStudyMaterials = null,Object? showValidationErrors = null,Object? currentQuizItemIndex = null,Object? isExpanded = null,Object? availableStudyMaterials = null,Object? error = freezed,Object? fieldError = freezed,Object? createdQuiz = freezed,Object? isSuccess = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,selectedSubject: freezed == selectedSubject ? _self.selectedSubject : selectedSubject // ignore: cast_nullable_to_non_nullable
as Subject?,selectedStudyMaterialId: freezed == selectedStudyMaterialId ? _self.selectedStudyMaterialId : selectedStudyMaterialId // ignore: cast_nullable_to_non_nullable
as String?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CreateQuizMode,selectedQuizType: null == selectedQuizType ? _self.selectedQuizType : selectedQuizType // ignore: cast_nullable_to_non_nullable
as QuizType,quizItems: null == quizItems ? _self.quizItems : quizItems // ignore: cast_nullable_to_non_nullable
as List<QuizItemData>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isCreating: null == isCreating ? _self.isCreating : isCreating // ignore: cast_nullable_to_non_nullable
as bool,isGeneratingAi: null == isGeneratingAi ? _self.isGeneratingAi : isGeneratingAi // ignore: cast_nullable_to_non_nullable
as bool,isLoadingStudyMaterials: null == isLoadingStudyMaterials ? _self.isLoadingStudyMaterials : isLoadingStudyMaterials // ignore: cast_nullable_to_non_nullable
as bool,showValidationErrors: null == showValidationErrors ? _self.showValidationErrors : showValidationErrors // ignore: cast_nullable_to_non_nullable
as bool,currentQuizItemIndex: null == currentQuizItemIndex ? _self.currentQuizItemIndex : currentQuizItemIndex // ignore: cast_nullable_to_non_nullable
as int,isExpanded: null == isExpanded ? _self.isExpanded : isExpanded // ignore: cast_nullable_to_non_nullable
as bool,availableStudyMaterials: null == availableStudyMaterials ? _self.availableStudyMaterials : availableStudyMaterials // ignore: cast_nullable_to_non_nullable
as List<StudyMaterialOption>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,fieldError: freezed == fieldError ? _self.fieldError : fieldError // ignore: cast_nullable_to_non_nullable
as String?,createdQuiz: freezed == createdQuiz ? _self.createdQuiz : createdQuiz // ignore: cast_nullable_to_non_nullable
as QuizEntity?,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc


class _CreateQuizState extends CreateQuizState {
  const _CreateQuizState({this.title = '', this.description = '', this.selectedSubject, this.selectedStudyMaterialId, this.mode = CreateQuizMode.manual, this.selectedQuizType = QuizType.flashcard, final  List<QuizItemData> quizItems = const [], this.isLoading = false, this.isCreating = false, this.isGeneratingAi = false, this.isLoadingStudyMaterials = false, this.showValidationErrors = false, this.currentQuizItemIndex = 0, this.isExpanded = false, final  List<StudyMaterialOption> availableStudyMaterials = const [], this.error, this.fieldError, this.createdQuiz, this.isSuccess = false}): _quizItems = quizItems,_availableStudyMaterials = availableStudyMaterials,super._();
  

// Form fields
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override final  Subject? selectedSubject;
@override final  String? selectedStudyMaterialId;
@override@JsonKey() final  CreateQuizMode mode;
@override@JsonKey() final  QuizType selectedQuizType;
// Quiz items being created
 final  List<QuizItemData> _quizItems;
// Quiz items being created
@override@JsonKey() List<QuizItemData> get quizItems {
  if (_quizItems is EqualUnmodifiableListView) return _quizItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quizItems);
}

// Loading states
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isCreating;
@override@JsonKey() final  bool isGeneratingAi;
@override@JsonKey() final  bool isLoadingStudyMaterials;
// UI states
@override@JsonKey() final  bool showValidationErrors;
@override@JsonKey() final  int currentQuizItemIndex;
@override@JsonKey() final  bool isExpanded;
// Data
 final  List<StudyMaterialOption> _availableStudyMaterials;
// Data
@override@JsonKey() List<StudyMaterialOption> get availableStudyMaterials {
  if (_availableStudyMaterials is EqualUnmodifiableListView) return _availableStudyMaterials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableStudyMaterials);
}

// Error handling
@override final  String? error;
@override final  String? fieldError;
// Success state
@override final  QuizEntity? createdQuiz;
@override@JsonKey() final  bool isSuccess;

/// Create a copy of CreateQuizState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateQuizStateCopyWith<_CreateQuizState> get copyWith => __$CreateQuizStateCopyWithImpl<_CreateQuizState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateQuizState&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.selectedSubject, selectedSubject)&&(identical(other.selectedStudyMaterialId, selectedStudyMaterialId) || other.selectedStudyMaterialId == selectedStudyMaterialId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.selectedQuizType, selectedQuizType) || other.selectedQuizType == selectedQuizType)&&const DeepCollectionEquality().equals(other._quizItems, _quizItems)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isCreating, isCreating) || other.isCreating == isCreating)&&(identical(other.isGeneratingAi, isGeneratingAi) || other.isGeneratingAi == isGeneratingAi)&&(identical(other.isLoadingStudyMaterials, isLoadingStudyMaterials) || other.isLoadingStudyMaterials == isLoadingStudyMaterials)&&(identical(other.showValidationErrors, showValidationErrors) || other.showValidationErrors == showValidationErrors)&&(identical(other.currentQuizItemIndex, currentQuizItemIndex) || other.currentQuizItemIndex == currentQuizItemIndex)&&(identical(other.isExpanded, isExpanded) || other.isExpanded == isExpanded)&&const DeepCollectionEquality().equals(other._availableStudyMaterials, _availableStudyMaterials)&&(identical(other.error, error) || other.error == error)&&(identical(other.fieldError, fieldError) || other.fieldError == fieldError)&&(identical(other.createdQuiz, createdQuiz) || other.createdQuiz == createdQuiz)&&(identical(other.isSuccess, isSuccess) || other.isSuccess == isSuccess));
}


@override
int get hashCode => Object.hashAll([runtimeType,title,description,const DeepCollectionEquality().hash(selectedSubject),selectedStudyMaterialId,mode,selectedQuizType,const DeepCollectionEquality().hash(_quizItems),isLoading,isCreating,isGeneratingAi,isLoadingStudyMaterials,showValidationErrors,currentQuizItemIndex,isExpanded,const DeepCollectionEquality().hash(_availableStudyMaterials),error,fieldError,createdQuiz,isSuccess]);

@override
String toString() {
  return 'CreateQuizState(title: $title, description: $description, selectedSubject: $selectedSubject, selectedStudyMaterialId: $selectedStudyMaterialId, mode: $mode, selectedQuizType: $selectedQuizType, quizItems: $quizItems, isLoading: $isLoading, isCreating: $isCreating, isGeneratingAi: $isGeneratingAi, isLoadingStudyMaterials: $isLoadingStudyMaterials, showValidationErrors: $showValidationErrors, currentQuizItemIndex: $currentQuizItemIndex, isExpanded: $isExpanded, availableStudyMaterials: $availableStudyMaterials, error: $error, fieldError: $fieldError, createdQuiz: $createdQuiz, isSuccess: $isSuccess)';
}


}

/// @nodoc
abstract mixin class _$CreateQuizStateCopyWith<$Res> implements $CreateQuizStateCopyWith<$Res> {
  factory _$CreateQuizStateCopyWith(_CreateQuizState value, $Res Function(_CreateQuizState) _then) = __$CreateQuizStateCopyWithImpl;
@override @useResult
$Res call({
 String title, String description, Subject? selectedSubject, String? selectedStudyMaterialId, CreateQuizMode mode, QuizType selectedQuizType, List<QuizItemData> quizItems, bool isLoading, bool isCreating, bool isGeneratingAi, bool isLoadingStudyMaterials, bool showValidationErrors, int currentQuizItemIndex, bool isExpanded, List<StudyMaterialOption> availableStudyMaterials, String? error, String? fieldError, QuizEntity? createdQuiz, bool isSuccess
});




}
/// @nodoc
class __$CreateQuizStateCopyWithImpl<$Res>
    implements _$CreateQuizStateCopyWith<$Res> {
  __$CreateQuizStateCopyWithImpl(this._self, this._then);

  final _CreateQuizState _self;
  final $Res Function(_CreateQuizState) _then;

/// Create a copy of CreateQuizState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? selectedSubject = freezed,Object? selectedStudyMaterialId = freezed,Object? mode = null,Object? selectedQuizType = null,Object? quizItems = null,Object? isLoading = null,Object? isCreating = null,Object? isGeneratingAi = null,Object? isLoadingStudyMaterials = null,Object? showValidationErrors = null,Object? currentQuizItemIndex = null,Object? isExpanded = null,Object? availableStudyMaterials = null,Object? error = freezed,Object? fieldError = freezed,Object? createdQuiz = freezed,Object? isSuccess = null,}) {
  return _then(_CreateQuizState(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,selectedSubject: freezed == selectedSubject ? _self.selectedSubject : selectedSubject // ignore: cast_nullable_to_non_nullable
as Subject?,selectedStudyMaterialId: freezed == selectedStudyMaterialId ? _self.selectedStudyMaterialId : selectedStudyMaterialId // ignore: cast_nullable_to_non_nullable
as String?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as CreateQuizMode,selectedQuizType: null == selectedQuizType ? _self.selectedQuizType : selectedQuizType // ignore: cast_nullable_to_non_nullable
as QuizType,quizItems: null == quizItems ? _self._quizItems : quizItems // ignore: cast_nullable_to_non_nullable
as List<QuizItemData>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isCreating: null == isCreating ? _self.isCreating : isCreating // ignore: cast_nullable_to_non_nullable
as bool,isGeneratingAi: null == isGeneratingAi ? _self.isGeneratingAi : isGeneratingAi // ignore: cast_nullable_to_non_nullable
as bool,isLoadingStudyMaterials: null == isLoadingStudyMaterials ? _self.isLoadingStudyMaterials : isLoadingStudyMaterials // ignore: cast_nullable_to_non_nullable
as bool,showValidationErrors: null == showValidationErrors ? _self.showValidationErrors : showValidationErrors // ignore: cast_nullable_to_non_nullable
as bool,currentQuizItemIndex: null == currentQuizItemIndex ? _self.currentQuizItemIndex : currentQuizItemIndex // ignore: cast_nullable_to_non_nullable
as int,isExpanded: null == isExpanded ? _self.isExpanded : isExpanded // ignore: cast_nullable_to_non_nullable
as bool,availableStudyMaterials: null == availableStudyMaterials ? _self._availableStudyMaterials : availableStudyMaterials // ignore: cast_nullable_to_non_nullable
as List<StudyMaterialOption>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,fieldError: freezed == fieldError ? _self.fieldError : fieldError // ignore: cast_nullable_to_non_nullable
as String?,createdQuiz: freezed == createdQuiz ? _self.createdQuiz : createdQuiz // ignore: cast_nullable_to_non_nullable
as QuizEntity?,isSuccess: null == isSuccess ? _self.isSuccess : isSuccess // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$QuizItemData {

 String get id; QuizItemType get type; String get question; String get answer; List<String> get mcqOptions; int get correctOptionIndex; bool get isExpanded;
/// Create a copy of QuizItemData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuizItemDataCopyWith<QuizItemData> get copyWith => _$QuizItemDataCopyWithImpl<QuizItemData>(this as QuizItemData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuizItemData&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&const DeepCollectionEquality().equals(other.mcqOptions, mcqOptions)&&(identical(other.correctOptionIndex, correctOptionIndex) || other.correctOptionIndex == correctOptionIndex)&&(identical(other.isExpanded, isExpanded) || other.isExpanded == isExpanded));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,question,answer,const DeepCollectionEquality().hash(mcqOptions),correctOptionIndex,isExpanded);

@override
String toString() {
  return 'QuizItemData(id: $id, type: $type, question: $question, answer: $answer, mcqOptions: $mcqOptions, correctOptionIndex: $correctOptionIndex, isExpanded: $isExpanded)';
}


}

/// @nodoc
abstract mixin class $QuizItemDataCopyWith<$Res>  {
  factory $QuizItemDataCopyWith(QuizItemData value, $Res Function(QuizItemData) _then) = _$QuizItemDataCopyWithImpl;
@useResult
$Res call({
 String id, QuizItemType type, String question, String answer, List<String> mcqOptions, int correctOptionIndex, bool isExpanded
});




}
/// @nodoc
class _$QuizItemDataCopyWithImpl<$Res>
    implements $QuizItemDataCopyWith<$Res> {
  _$QuizItemDataCopyWithImpl(this._self, this._then);

  final QuizItemData _self;
  final $Res Function(QuizItemData) _then;

/// Create a copy of QuizItemData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? question = null,Object? answer = null,Object? mcqOptions = null,Object? correctOptionIndex = null,Object? isExpanded = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as QuizItemType,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,mcqOptions: null == mcqOptions ? _self.mcqOptions : mcqOptions // ignore: cast_nullable_to_non_nullable
as List<String>,correctOptionIndex: null == correctOptionIndex ? _self.correctOptionIndex : correctOptionIndex // ignore: cast_nullable_to_non_nullable
as int,isExpanded: null == isExpanded ? _self.isExpanded : isExpanded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc


class _QuizItemData extends QuizItemData {
  const _QuizItemData({required this.id, this.type = QuizItemType.flashcard, this.question = '', this.answer = '', final  List<String> mcqOptions = const [], this.correctOptionIndex = 0, this.isExpanded = false}): _mcqOptions = mcqOptions,super._();
  

@override final  String id;
@override@JsonKey() final  QuizItemType type;
@override@JsonKey() final  String question;
@override@JsonKey() final  String answer;
 final  List<String> _mcqOptions;
@override@JsonKey() List<String> get mcqOptions {
  if (_mcqOptions is EqualUnmodifiableListView) return _mcqOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mcqOptions);
}

@override@JsonKey() final  int correctOptionIndex;
@override@JsonKey() final  bool isExpanded;

/// Create a copy of QuizItemData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuizItemDataCopyWith<_QuizItemData> get copyWith => __$QuizItemDataCopyWithImpl<_QuizItemData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuizItemData&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&const DeepCollectionEquality().equals(other._mcqOptions, _mcqOptions)&&(identical(other.correctOptionIndex, correctOptionIndex) || other.correctOptionIndex == correctOptionIndex)&&(identical(other.isExpanded, isExpanded) || other.isExpanded == isExpanded));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,question,answer,const DeepCollectionEquality().hash(_mcqOptions),correctOptionIndex,isExpanded);

@override
String toString() {
  return 'QuizItemData(id: $id, type: $type, question: $question, answer: $answer, mcqOptions: $mcqOptions, correctOptionIndex: $correctOptionIndex, isExpanded: $isExpanded)';
}


}

/// @nodoc
abstract mixin class _$QuizItemDataCopyWith<$Res> implements $QuizItemDataCopyWith<$Res> {
  factory _$QuizItemDataCopyWith(_QuizItemData value, $Res Function(_QuizItemData) _then) = __$QuizItemDataCopyWithImpl;
@override @useResult
$Res call({
 String id, QuizItemType type, String question, String answer, List<String> mcqOptions, int correctOptionIndex, bool isExpanded
});




}
/// @nodoc
class __$QuizItemDataCopyWithImpl<$Res>
    implements _$QuizItemDataCopyWith<$Res> {
  __$QuizItemDataCopyWithImpl(this._self, this._then);

  final _QuizItemData _self;
  final $Res Function(_QuizItemData) _then;

/// Create a copy of QuizItemData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? question = null,Object? answer = null,Object? mcqOptions = null,Object? correctOptionIndex = null,Object? isExpanded = null,}) {
  return _then(_QuizItemData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as QuizItemType,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,mcqOptions: null == mcqOptions ? _self._mcqOptions : mcqOptions // ignore: cast_nullable_to_non_nullable
as List<String>,correctOptionIndex: null == correctOptionIndex ? _self.correctOptionIndex : correctOptionIndex // ignore: cast_nullable_to_non_nullable
as int,isExpanded: null == isExpanded ? _self.isExpanded : isExpanded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$StudyMaterialOption {

 String get id; String get title; Subject? get subject; String get contentType;
/// Create a copy of StudyMaterialOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudyMaterialOptionCopyWith<StudyMaterialOption> get copyWith => _$StudyMaterialOptionCopyWithImpl<StudyMaterialOption>(this as StudyMaterialOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudyMaterialOption&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.subject, subject)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(subject),contentType);

@override
String toString() {
  return 'StudyMaterialOption(id: $id, title: $title, subject: $subject, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $StudyMaterialOptionCopyWith<$Res>  {
  factory $StudyMaterialOptionCopyWith(StudyMaterialOption value, $Res Function(StudyMaterialOption) _then) = _$StudyMaterialOptionCopyWithImpl;
@useResult
$Res call({
 String id, String title, Subject? subject, String contentType
});




}
/// @nodoc
class _$StudyMaterialOptionCopyWithImpl<$Res>
    implements $StudyMaterialOptionCopyWith<$Res> {
  _$StudyMaterialOptionCopyWithImpl(this._self, this._then);

  final StudyMaterialOption _self;
  final $Res Function(StudyMaterialOption) _then;

/// Create a copy of StudyMaterialOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? subject = freezed,Object? contentType = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as Subject?,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc


class _StudyMaterialOption implements StudyMaterialOption {
  const _StudyMaterialOption({required this.id, required this.title, this.subject, required this.contentType});
  

@override final  String id;
@override final  String title;
@override final  Subject? subject;
@override final  String contentType;

/// Create a copy of StudyMaterialOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudyMaterialOptionCopyWith<_StudyMaterialOption> get copyWith => __$StudyMaterialOptionCopyWithImpl<_StudyMaterialOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudyMaterialOption&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.subject, subject)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(subject),contentType);

@override
String toString() {
  return 'StudyMaterialOption(id: $id, title: $title, subject: $subject, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class _$StudyMaterialOptionCopyWith<$Res> implements $StudyMaterialOptionCopyWith<$Res> {
  factory _$StudyMaterialOptionCopyWith(_StudyMaterialOption value, $Res Function(_StudyMaterialOption) _then) = __$StudyMaterialOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, Subject? subject, String contentType
});




}
/// @nodoc
class __$StudyMaterialOptionCopyWithImpl<$Res>
    implements _$StudyMaterialOptionCopyWith<$Res> {
  __$StudyMaterialOptionCopyWithImpl(this._self, this._then);

  final _StudyMaterialOption _self;
  final $Res Function(_StudyMaterialOption) _then;

/// Create a copy of StudyMaterialOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? subject = freezed,Object? contentType = null,}) {
  return _then(_StudyMaterialOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as Subject?,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
