import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_material_state.freezed.dart';

@freezed
abstract class StudyMaterialState with _$StudyMaterialState {
  const StudyMaterialState._();
  const factory StudyMaterialState({
    @Default([]) List<StudyMaterialEntity> materials,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMaterial,
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,
    @Default(false) bool isDeleting,
    @Default(false) bool isGeneratingSummary,
    @Default(false) bool isProcessingOcr,
    String? error,
    String? selectedMaterialId,
    StudyMaterialEntity? selectedMaterial,
    @Default('') String searchQuery,
    Subject? selectedSubject,
    ContentType? selectedContentType,
  }) = _StudyMaterialState;

  // Computed properties
  List<StudyMaterialEntity> get filteredMaterials {
    var filtered = materials;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((material) {
            return material.title.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                (material.description?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                (material.originalContentText?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                (material.ocrExtractedText?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ??
                    false);
          }).toList();
    }

    // Apply subject filter
    if (selectedSubject != null) {
      filtered =
          filtered
              .where((material) => material.subject == selectedSubject)
              .toList();
    }

    // Apply content type filter
    if (selectedContentType != null) {
      filtered =
          filtered
              .where((material) => material.contentType == selectedContentType)
              .toList();
    } // Sort by updated date (most recent first) - create a new list to avoid modifying unmodifiable list
    final sortedFiltered = List<StudyMaterialEntity>.from(filtered);
    sortedFiltered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return sortedFiltered;
  }

  bool get hasError => error != null;

  bool get hasAnyLoading =>
      isLoading ||
      isLoadingMaterial ||
      isCreating ||
      isUpdating ||
      isDeleting ||
      isGeneratingSummary ||
      isProcessingOcr;

  bool get hasFilters =>
      searchQuery.isNotEmpty ||
      selectedSubject != null ||
      selectedContentType != null;

  int get materialsCount => materials.length;

  int get filteredMaterialsCount => filteredMaterials.length;
  List<Subject> get availableSubjects {
    final subjects =
        materials
            .map((material) => material.subject)
            .where((subject) => subject != null)
            .cast<Subject>()
            .toSet()
            .toList();
    subjects.sort((a, b) => a.name.compareTo(b.name));
    return subjects;
  }

  List<ContentType> get availableContentTypes {
    final contentTypes =
        materials.map((material) => material.contentType).toSet().toList();
    contentTypes.sort((a, b) => a.name.compareTo(b.name));
    return contentTypes;
  }

  StudyMaterialEntity? getMaterialById(String id) {
    try {
      return materials.firstWhere((material) => material.id == id);
    } catch (e) {
      return null;
    }
  }

  bool hasMaterialWithTitle(String title) {
    return materials.any(
      (material) => material.title.toLowerCase() == title.toLowerCase(),
    );
  }

  List<StudyMaterialEntity> getMaterialsBySubject(Subject subject) {
    return materials.where((material) => material.subject == subject).toList();
  }

  List<StudyMaterialEntity> getMaterialsWithAiSummary() {
    return materials.where((material) => material.hasAiSummary).toList();
  }

  List<StudyMaterialEntity> getMaterialsByContentType(ContentType contentType) {
    return materials
        .where((material) => material.contentType == contentType)
        .toList();
  }
}
