import 'dart:async';

import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/features/study_materials/data/datasources/study_material_remote_datasource.dart';
import 'package:athena/features/study_materials/data/models/study_material_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      // Prepare data for insertion (conversion to JSON)
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
      // Prepare data for update (conversion to JSON)
      final studyMaterialData = studyMaterial.toUpdateJson();

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
}
