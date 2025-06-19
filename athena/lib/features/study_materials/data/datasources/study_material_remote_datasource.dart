import 'dart:async';
import 'package:athena/features/study_materials/data/models/study_material_model.dart';

abstract class StudyMaterialRemoteDataSource {
  Future<List<StudyMaterialModel>> getAllStudyMaterials(String userId);
  Future<StudyMaterialModel> getStudyMaterialById(String studyMaterialId);
  Future<StudyMaterialModel> createStudyMaterial(StudyMaterialModel studyMaterial);
  Future<StudyMaterialModel> updateStudyMaterial(StudyMaterialModel studyMaterial);
  Future<void> deleteStudyMaterial(String studyMaterialId);
  Future<String> requestAiSummary(String studyMaterialId);
  Future<String> getSignedDownloadUrl(String fileStoragePath);
}