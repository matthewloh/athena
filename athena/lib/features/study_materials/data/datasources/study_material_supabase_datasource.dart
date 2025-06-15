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
    // TODO: implement getAllStudyMaterials
    throw UnimplementedError();
  }

  @override
  Future<StudyMaterialModel> getStudyMaterialById(
    String studyMaterialId,
  ) async {
    // TODO: implement getStudyMaterialById
    throw UnimplementedError();
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
    // TODO: implement updateStudyMaterial
    throw UnimplementedError();
  }

  @override
  Future<void> deleteStudyMaterial(String studyMaterialId) async {
    // TODO: implement deleteStudyMaterial
    throw UnimplementedError();
  }

  @override
  Future<String> requestAiSummary(String studyMaterialId) async {
    // TODO: implement requestAiSummary
    throw UnimplementedError();
  }

  @override
  Future<String> requestOcrProcessing(String imagePath) async {
    // TODO: implement requestOcrProcessing
    throw UnimplementedError();
  }
}
