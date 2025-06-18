import 'dart:async';
import 'dart:io';

import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/features/study_materials/data/datasources/study_material_remote_datasource.dart';
import 'package:athena/features/study_materials/data/models/study_material_model.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class StudyMaterialSupabaseDataSourceImpl
    implements StudyMaterialRemoteDataSource {
  final SupabaseClient _supabaseClient;

  StudyMaterialSupabaseDataSourceImpl(this._supabaseClient);
  @override
  Future<List<StudyMaterialModel>> getAllStudyMaterials(String userId) async {
    try {
      final response = await _supabaseClient
          .from('study_materials')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => StudyMaterialModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch study materials: ${e.toString()}');
    }
  }

  @override
  Future<StudyMaterialModel> getStudyMaterialById(
    String studyMaterialId,
  ) async {
    try {
      final response =
          await _supabaseClient
              .from('study_materials')
              .select()
              .eq('id', studyMaterialId)
              .single();

      return StudyMaterialModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to fetch study material: ${e.toString()}');
    }
  }

  @override
  Future<StudyMaterialModel> createStudyMaterial(
    StudyMaterialModel studyMaterial,
  ) async {
    try {
      /// For file-based materials, we need to create the record first to get the ID,
      // then upload the file, then update the record with the storage path
      if (studyMaterial.contentType == ContentType.textFile ||
          studyMaterial.contentType == ContentType.imageFile) {
        if (studyMaterial.fileStoragePath != null &&
            studyMaterial.fileStoragePath!.isNotEmpty) {
          // First, create the study material without the file storage path
          final materialWithoutFile = studyMaterial.copyWith(
            fileStoragePath: null,
          );

          final studyMaterialData = materialWithoutFile.toInsertJson();

          // Insert the study material into the database to get the ID
          final response =
              await _supabaseClient
                  .from('study_materials')
                  .insert(studyMaterialData)
                  .select()
                  .single();

          final createdMaterial = StudyMaterialModel.fromJson(response);

          // Now upload the file using the material ID
          final storagePath = await _uploadFileWithMaterialId(
            studyMaterial.fileStoragePath!,
            studyMaterial.userId,
            createdMaterial.id,
            studyMaterial.contentType,
          );

          // Update the material with the storage path
          final updateResponse =
              await _supabaseClient
                  .from('study_materials')
                  .update({'file_storage_path': storagePath})
                  .eq('id', createdMaterial.id)
                  .select()
                  .single();

          return StudyMaterialModel.fromJson(updateResponse);
        }
      }

      final studyMaterialData = studyMaterial.toInsertJson();

      // Insert the study material into the database
      final response =
          await _supabaseClient
              .from('study_materials')
              .insert(studyMaterialData)
              .select()
              .single();

      return StudyMaterialModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create study material: ${e.toString()}');
    }
  }

  @override
  Future<StudyMaterialModel> updateStudyMaterial(
    StudyMaterialModel studyMaterial,
  ) async {
    try {
      StudyMaterialModel materialToUpdate = studyMaterial;

      // Handle file uploads for textFile and imageFile content types
      if (studyMaterial.contentType == ContentType.textFile ||
          studyMaterial.contentType == ContentType.imageFile) {
        // If there's a new file path (local path, not a storage path), upload the new file
        if (studyMaterial.fileStoragePath != null &&
            studyMaterial.fileStoragePath!.isNotEmpty &&
            !studyMaterial.fileStoragePath!.contains('/')) {
          // Upload new file to Supabase Storage
          final storagePath = await _uploadFileWithMaterialId(
            studyMaterial.fileStoragePath!,
            studyMaterial.userId,
            studyMaterial.id,
            studyMaterial.contentType,
          );

          // Update the material with the new storage path
          materialToUpdate = studyMaterial.copyWith(
            fileStoragePath: storagePath,
          );
        }
      }

      // Prepare data for update (conversion to JSON)
      final studyMaterialData = materialToUpdate.toUpdateJson();

      // Update the study material in the database
      final response =
          await _supabaseClient
              .from('study_materials')
              .update(studyMaterialData)
              .eq('id', studyMaterial.id)
              .select()
              .single();

      return StudyMaterialModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update study material: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteStudyMaterial(String studyMaterialId) async {
    try {
      // First, get the study material to check if it has a file to delete
      final response =
          await _supabaseClient
              .from('study_materials')
              .select('file_storage_path, content_type')
              .eq('id', studyMaterialId)
              .single();

      final fileStoragePath = response['file_storage_path'] as String?;
      final contentType = response['content_type'] as String?;

      // Delete the file from storage if it exists
      if (fileStoragePath != null &&
          fileStoragePath.isNotEmpty &&
          (contentType == 'textFile' || contentType == 'imageFile')) {
        try {
          await _supabaseClient.storage.from('study-materials').remove([
            fileStoragePath,
          ]);
        } catch (e) {
          // Log the error but don't fail the deletion if file removal fails
          print('Warning: Failed to delete file from storage: ${e.toString()}');
        }
      }

      // Delete the study material record from the database
      await _supabaseClient
          .from('study_materials')
          .delete()
          .eq('id', studyMaterialId);
    } catch (e) {
      throw ServerException('Failed to delete study material: ${e.toString()}');
    }
  }

  @override
  Future<String> requestAiSummary(String studyMaterialId) async {
    try {
      // TODO: Implement AI summary generation using Supabase Edge Functions
      // Example implementation:
      // final response = await _supabaseClient.functions.invoke(
      //   'generate-summary',
      //   body: {'material_id': studyMaterialId},
      // );
      // return response.data['summary'] as String;

      throw ServerException('AI summary generation not yet implemented');
    } catch (e) {
      throw ServerException('Failed to generate AI summary: ${e.toString()}');
    }
  }

  @override
  Future<String> requestOcrProcessing(String imagePath) async {
    try {
      // TODO: Implement OCR processing using Supabase Edge Functions
      // Example implementation:
      // final response = await _supabaseClient.functions.invoke(
      //   'process-ocr',
      //   body: {'image_path': imagePath},
      // );
      // return response.data['extracted_text'] as String;

      throw ServerException('OCR processing not yet implemented');
    } catch (e) {
      throw ServerException('Failed to process OCR: ${e.toString()}');
    }
  }

  @override
  Future<String> getSignedDownloadUrl(String fileStoragePath) async {
    try {
      // Generate a public download URL for the file
      final url = _supabaseClient.storage
          .from('study-materials')
          .createSignedUrl(fileStoragePath, 60 * 60);
      return url;
    } catch (e) {
      throw ServerException(
        'Failed to get public download URL: ${e.toString()}',
      );
    }
  }

  /// Uploads a file to Supabase Storage and returns the storage path
  /// Path structure: userId/materialId/filename
  Future<String> _uploadFileWithMaterialId(
    String localFilePath,
    String userId,
    String materialId,
    ContentType contentType,
  ) async {
    try {
      // Read file as bytes
      final file = File(localFilePath);
      final fileBytes = await file.readAsBytes();

      // Generate unique filename to avoid conflicts
      final originalFileName = path.basename(localFilePath);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$originalFileName';

      // Create storage path: userId/materialId/filename
      final storagePath = '$userId/$materialId/$fileName';

      // Upload to Supabase Storage bucket 'study-materials'
      await _supabaseClient.storage
          .from('study-materials')
          .uploadBinary(storagePath, fileBytes);

      return storagePath;
    } catch (e) {
      throw ServerException('Failed to upload file: ${e.toString()}');
    }
  }
}
