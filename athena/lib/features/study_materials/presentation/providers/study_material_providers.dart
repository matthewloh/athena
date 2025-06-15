import 'package:athena/core/providers/supabase_providers.dart';
import 'package:athena/features/study_materials/data/datasources/study_material_supabase_datasource.dart';
import 'package:athena/features/study_materials/data/repositories/study_material_repository_impl.dart';
import 'package:athena/features/study_materials/domain/repositories/study_material_repository.dart';
import 'package:athena/features/study_materials/domain/usecases/get_all_study_materials_usecase.dart';
import 'package:athena/features/study_materials/domain/usecases/get_study_material_usecase.dart';
import 'package:athena/features/study_materials/domain/usecases/create_study_material_usecase.dart';
import 'package:athena/features/study_materials/domain/usecases/update_study_material_usecase.dart';
import 'package:athena/features/study_materials/domain/usecases/delete_study_material_usecase.dart';
import 'package:athena/features/study_materials/domain/usecases/request_ai_summary_usecase.dart';
import 'package:athena/features/study_materials/domain/usecases/request_ocr_processing_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_material_providers.g.dart';

// DataSources
@riverpod
StudyMaterialSupabaseDataSourceImpl studyMaterialSupabaseDataSource(Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return StudyMaterialSupabaseDataSourceImpl(supabaseClient);
}

// Repositories
@riverpod
StudyMaterialRepository studyMaterialRepository(Ref ref) {
  final dataSource = ref.watch(studyMaterialSupabaseDataSourceProvider);
  return StudyMaterialRepositoryImpl(dataSource);
}

// UseCases
@riverpod
GetAllStudyMaterialsUseCase getAllStudyMaterialsUseCase(Ref ref) {
  final repository = ref.watch(studyMaterialRepositoryProvider);
  return GetAllStudyMaterialsUseCase(repository);
}

@riverpod
GetStudyMaterialUseCase getStudyMaterialUseCase(Ref ref) {
  final repository = ref.watch(studyMaterialRepositoryProvider);
  return GetStudyMaterialUseCase(repository);
}

@riverpod
CreateStudyMaterialUseCase createStudyMaterialUseCase(Ref ref) {
  final repository = ref.watch(studyMaterialRepositoryProvider);
  return CreateStudyMaterialUseCase(repository);
}

@riverpod
UpdateStudyMaterialUseCase updateStudyMaterialUseCase(Ref ref) {
  final repository = ref.watch(studyMaterialRepositoryProvider);
  return UpdateStudyMaterialUseCase(repository);
}

@riverpod
DeleteStudyMaterialUseCase deleteStudyMaterialUseCase(Ref ref) {
  final repository = ref.watch(studyMaterialRepositoryProvider);
  return DeleteStudyMaterialUseCase(repository);
}

@riverpod
RequestAiSummaryUseCase requestAiSummaryUseCase(Ref ref) {
  final repository = ref.watch(studyMaterialRepositoryProvider);
  return RequestAiSummaryUseCase(repository);
}

@riverpod
RequestOcrProcessingUseCase requestOcrProcessingUseCase(Ref ref) {
  final repository = ref.watch(studyMaterialRepositoryProvider);
  return RequestOcrProcessingUseCase(repository);
}
