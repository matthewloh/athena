import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/domain/usecases/params/create_study_material_params.dart';
import 'package:athena/features/study_materials/domain/usecases/params/update_study_material_params.dart';
import 'package:athena/features/study_materials/presentation/providers/study_material_providers.dart';
import 'package:athena/features/study_materials/presentation/viewmodel/study_material_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'study_material_viewmodel.g.dart';

@riverpod
class StudyMaterialViewModel extends _$StudyMaterialViewModel {
  // Helper method to get current user ID
  String? _getCurrentUserId() {
    final user = ref.read(appAuthProvider).valueOrNull;
    return user?.id;
  }

  @override
  StudyMaterialState build() {
    // Initialize with empty state - data will be loaded via loadMaterials()
    // Schedule loading materials after initialization
    Future.microtask(() => loadMaterials());

    return const StudyMaterialState();
  }

  // Load all study materials
  Future<void> loadMaterials() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get current user ID
      final userId = _getCurrentUserId();
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated. Please log in again.',
        );
        return;
      }

      final useCase = ref.read(getAllStudyMaterialsUseCaseProvider);
      final result = await useCase.call(userId);

      result.fold(
        (failure) =>
            state = state.copyWith(isLoading: false, error: failure.message),
        (materials) =>
            state = state.copyWith(
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
        (failure) =>
            state = state.copyWith(
              isLoadingMaterial: false,
              error: failure.message,
            ),
        (material) =>
            state = state.copyWith(
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
  Future<void> createMaterial(CreateStudyMaterialParams params) async {
    state = state.copyWith(isCreating: true, error: null);

    try {
      // Get current user ID and inject it into the params
      final userId = _getCurrentUserId();
      if (userId == null) {
        state = state.copyWith(
          isCreating: false,
          error: 'User not authenticated. Please log in again.',
        );
        return;
      }

      // Create params with user ID injected
      final paramsWithUserId = params.copyWithUserId(userId);

      final useCase = ref.read(createStudyMaterialUseCaseProvider);
      final result = await useCase.call(paramsWithUserId);

      result.fold(
        (failure) =>
            state = state.copyWith(isCreating: false, error: failure.message),
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
  Future<void> updateMaterial(UpdateStudyMaterialParams params) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final useCase = ref.read(updateStudyMaterialUseCaseProvider);
      final result = await useCase.call(params);

      result.fold(
        (failure) =>
            state = state.copyWith(isUpdating: false, error: failure.message),
        (updatedMaterial) {
          final updatedMaterials =
              state.materials
                  .map((m) => m.id == updatedMaterial.id ? updatedMaterial : m)
                  .toList();
          state = state.copyWith(
            isUpdating: false,
            materials: updatedMaterials,
            selectedMaterial:
                state.selectedMaterialId == updatedMaterial.id
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
        (failure) =>
            state = state.copyWith(isDeleting: false, error: failure.message),
        (_) {
          final updatedMaterials =
              state.materials.where((material) => material.id != id).toList();
          state = state.copyWith(
            isDeleting: false,
            materials: updatedMaterials,
            selectedMaterial:
                state.selectedMaterialId == id ? null : state.selectedMaterial,
            selectedMaterialId:
                state.selectedMaterialId == id
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
        (failure) =>
            state = state.copyWith(
              isGeneratingSummary: false,
              error: failure.message,
            ),
        (summary) {
          final updatedMaterials =
              state.materials.map((material) {
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
            selectedMaterial:
                state.selectedMaterialId == materialId
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
        (failure) =>
            state = state.copyWith(
              isProcessingOcr: false,
              error: 'Failed to process OCR: ${failure.toString()}',
            ),
        (_) {
          // OCR processing initiated successfully
          // The actual text extraction will be handled by the backend
          // and updated through other means (like real-time updates)
          state = state.copyWith(isProcessingOcr: false, error: null);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isProcessingOcr: false,
        error: 'Failed to process OCR: ${e.toString()}',
      );
    }  }

  // Get signed download URL for a material file or image
  Future<String?> getSignedDownloadUrl(String fileStoragePath) async {
    try {
      final useCase = ref.read(getSignedDownloadUrlUseCaseProvider);
      final result = await useCase.call(fileStoragePath);

      return result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
          return null;
        },
        (url) => url,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to get download URL: ${e.toString()}',
      );
      return null;
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
    state = state.copyWith(selectedMaterialId: null, selectedMaterial: null);
  }
}
