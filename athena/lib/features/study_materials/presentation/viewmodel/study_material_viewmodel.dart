import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/domain/usecases/params/create_study_material_params.dart';
import 'package:athena/features/study_materials/presentation/providers/study_material_providers.dart';
import 'package:athena/features/study_materials/presentation/viewmodel/study_material_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'study_material_viewmodel.g.dart';

@riverpod
class StudyMaterialViewModel extends _$StudyMaterialViewModel {
  @override
  StudyMaterialState build() {
    // Initialize with dummy data for development
    final dummyMaterials = [
      StudyMaterialEntity(
        id: '1',
        userId: 'user1',
        title: 'Biology Notes - Chapter 4',
        description: 'Cell structure and function',
        subject: Subject.biology,
        contentType: ContentType.typedText,
        originalContentText: 'Content about cells and their organelles...',
        hasAiSummary: true,
        summaryText: 'Cells are the basic units of life...',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      StudyMaterialEntity(
        id: '2',
        userId: 'user1',
        title: 'Math Formulas',
        description: 'Calculus reference sheet',
        subject: Subject.mathematics,
        contentType: ContentType.typedText,
        originalContentText: 'Derivative formulas, integration techniques...',
        hasAiSummary: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      StudyMaterialEntity(
        id: '3',
        userId: 'user1',
        title: 'History Timeline',
        description: 'Important dates and events',
        subject: Subject.history,
        contentType: ContentType.typedText,
        originalContentText: 'World War I: 1914-1918, World War II: 1939-1945...',
        hasAiSummary: true,
        summaryText: 'Major historical events of the 20th century...',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ];

    return StudyMaterialState(materials: dummyMaterials);
  }
  // Load all study materials
  Future<void> loadMaterials({String userId = 'user1'}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final useCase = ref.read(getAllStudyMaterialsUseCaseProvider);
      final result = await useCase.call(userId);
      
      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: failure.message,
        ),
        (materials) => state = state.copyWith(
          isLoading: false,
          materials: materials,
          error: null,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load materials: ${e.toString()}',
      );
    }
  }

  // Load a specific study material
  Future<void> loadMaterial(String id) async {
    state = state.copyWith(isLoadingMaterial: true, error: null);
    
    try {
      final useCase = ref.read(getStudyMaterialUseCaseProvider);
      final result = await useCase.call(id);
      
      result.fold(
        (failure) => state = state.copyWith(
          isLoadingMaterial: false,
          error: failure.message,
        ),
        (material) => state = state.copyWith(
          isLoadingMaterial: false,
          selectedMaterial: material,
          selectedMaterialId: id,
          error: null,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMaterial: false,
        error: 'Failed to load material: ${e.toString()}',
      );
    }
  }
  // Create a new study material
  Future<void> createMaterial(StudyMaterialEntity material) async {
    state = state.copyWith(isCreating: true, error: null);
    
    try {
      final useCase = ref.read(createStudyMaterialUseCaseProvider);
      final params = CreateStudyMaterialParams(
        userId: material.userId,
        title: material.title,
        description: material.description,
        subject: material.subject,
        contentType: material.contentType,
        originalContentText: material.originalContentText,
        fileStoragePath: material.fileStoragePath,
        ocrExtractedText: material.ocrExtractedText,
        summaryText: material.summaryText,
        hasAiSummary: material.hasAiSummary,
      );
      final result = await useCase.call(params);
      
      result.fold(
        (failure) => state = state.copyWith(
          isCreating: false,
          error: failure.message,
        ),
        (createdMaterial) {
          final updatedMaterials = [...state.materials, createdMaterial];
          state = state.copyWith(
            isCreating: false,
            materials: updatedMaterials,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Failed to create material: ${e.toString()}',
      );
    }
  }

  // Update an existing study material
  Future<void> updateMaterial(StudyMaterialEntity material) async {
    state = state.copyWith(isUpdating: true, error: null);
    
    try {
      final useCase = ref.read(updateStudyMaterialUseCaseProvider);
      final result = await useCase.call(material);
      
      result.fold(
        (failure) => state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        ),
        (updatedMaterial) {
          final updatedMaterials = state.materials
              .map((m) => m.id == updatedMaterial.id ? updatedMaterial : m)
              .toList();
          state = state.copyWith(
            isUpdating: false,
            materials: updatedMaterials,
            selectedMaterial: state.selectedMaterialId == updatedMaterial.id
                ? updatedMaterial
                : state.selectedMaterial,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update material: ${e.toString()}',
      );
    }
  }

  // Delete a study material
  Future<void> deleteMaterial(String id) async {
    state = state.copyWith(isDeleting: true, error: null);
    
    try {
      final useCase = ref.read(deleteStudyMaterialUseCaseProvider);
      final result = await useCase.call(id);
      
      result.fold(
        (failure) => state = state.copyWith(
          isDeleting: false,
          error: failure.message,
        ),
        (_) {
          final updatedMaterials = state.materials
              .where((material) => material.id != id)
              .toList();
          state = state.copyWith(
            isDeleting: false,
            materials: updatedMaterials,
            selectedMaterial: state.selectedMaterialId == id 
                ? null 
                : state.selectedMaterial,
            selectedMaterialId: state.selectedMaterialId == id 
                ? null 
                : state.selectedMaterialId,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Failed to delete material: ${e.toString()}',
      );
    }
  }

  // Request AI summary for a material
  Future<void> generateAiSummary(String materialId) async {
    state = state.copyWith(isGeneratingSummary: true, error: null);
    
    try {
      final useCase = ref.read(requestAiSummaryUseCaseProvider);
      final result = await useCase.call(materialId);
      
      result.fold(
        (failure) => state = state.copyWith(
          isGeneratingSummary: false,
          error: failure.message,
        ),
        (summary) {
          final updatedMaterials = state.materials.map((material) {
            if (material.id == materialId) {
              return material.copyWith(
                summaryText: summary,
                hasAiSummary: true,
                updatedAt: DateTime.now(),
              );
            }
            return material;
          }).toList();
          
          state = state.copyWith(
            isGeneratingSummary: false,
            materials: updatedMaterials,
            selectedMaterial: state.selectedMaterialId == materialId
                ? state.selectedMaterial?.copyWith(
                    summaryText: summary,
                    hasAiSummary: true,
                    updatedAt: DateTime.now(),
                  )
                : state.selectedMaterial,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingSummary: false,
        error: 'Failed to generate AI summary: ${e.toString()}',
      );
    }
  }
  // Process OCR for an image-based material
  Future<void> processOcr(String materialId) async {
    state = state.copyWith(isProcessingOcr: true, error: null);
    
    try {
      final useCase = ref.read(requestOcrProcessingUseCaseProvider);
      final result = await useCase.call(materialId);
      
      result.fold(
        (failure) => state = state.copyWith(
          isProcessingOcr: false,
          error: 'Failed to process OCR: ${failure.toString()}',
        ),
        (_) {
          // OCR processing initiated successfully
          // The actual text extraction will be handled by the backend
          // and updated through other means (like real-time updates)
          state = state.copyWith(
            isProcessingOcr: false,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isProcessingOcr: false,
        error: 'Failed to process OCR: ${e.toString()}',
      );
    }
  }

  // Search and filter methods
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSubjectFilter(Subject? subject) {
    state = state.copyWith(selectedSubject: subject);
  }

  void setContentTypeFilter(ContentType? contentType) {
    state = state.copyWith(selectedContentType: contentType);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedSubject: null,
      selectedContentType: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void selectMaterial(String materialId) {
    final material = state.getMaterialById(materialId);
    state = state.copyWith(
      selectedMaterialId: materialId,
      selectedMaterial: material,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      selectedMaterialId: null,
      selectedMaterial: null,
    );
  }
}