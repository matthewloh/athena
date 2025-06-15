import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';

/// Utility class for Subject enum operations
class SubjectUtils {
  /// Convert Subject enum to user-friendly display name
  static String getDisplayName(Subject subject) {
    switch (subject) {
      case Subject.computerScience:
        return 'Computer Science';
      case Subject.dataScience:
        return 'Data Science';
      case Subject.informationTechnology:
        return 'Information Technology';
      case Subject.englishLiterature:
        return 'English Literature';
      case Subject.englishLanguage:
        return 'English Language';
      case Subject.creativeWriting:
        return 'Creative Writing';
      case Subject.politicalScience:
        return 'Political Science';
      case Subject.internationalRelations:
        return 'International Relations';
      case Subject.businessStudies:
        return 'Business Studies';
      case Subject.humanResources:
        return 'Human Resources';
      case Subject.operationsManagement:
        return 'Operations Management';
      case Subject.filmStudies:
        return 'Film Studies';
      case Subject.graphicDesign:
        return 'Graphic Design';
      case Subject.publicHealth:
        return 'Public Health';
      case Subject.physicalEducation:
        return 'Physical Education';
      case Subject.sportsScience:
        return 'Sports Science';
      case Subject.criminalJustice:
        return 'Criminal Justice';
      case Subject.legalStudies:
        return 'Legal Studies';
      case Subject.environmentalScience:
        return 'Environmental Science';
      case Subject.climateScience:
        return 'Climate Science';
      case Subject.marineBiology:
        return 'Marine Biology';
      case Subject.educationalPsychology:
        return 'Educational Psychology';
      default:
        // Capitalize first letter for other subjects
        String name = subject.name;
        return name[0].toUpperCase() + name.substring(1);
    }
  }

  /// Get the category that a subject belongs to
  static String getSubjectCategory(Subject subject) {
    for (final entry in subjectCategories.entries) {
      if (entry.value.contains(subject)) {
        return entry.key;
      }
    }
    return 'Other';
  }

  /// Get all subjects in a specific category
  static List<Subject> getSubjectsByCategory(String category) {
    return subjectCategories[category] ?? [];
  }

  /// Get all available categories
  static List<String> getAllCategories() {
    return subjectCategories.keys.toList();
  }

  /// Search subjects by query string
  static List<Subject> searchSubjects(String query) {
    if (query.isEmpty) return getAllSubjects();
    
    final lowercaseQuery = query.toLowerCase();
    return getAllSubjects()
        .where((subject) => 
            getDisplayName(subject).toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Get all subjects as a flat list
  static List<Subject> getAllSubjects() {
    return subjectCategories.values.expand((subjects) => subjects).toList();
  }

  /// Get a filtered map of categories based on search query
  static Map<String, List<Subject>> getFilteredCategorizedSubjects(String query) {
    if (query.isEmpty) {
      return subjectCategories;
    }

    final lowercaseQuery = query.toLowerCase();
    final Map<String, List<Subject>> filteredCategories = {};

    for (final entry in subjectCategories.entries) {
      final filteredSubjects = entry.value
          .where((subject) => 
              getDisplayName(subject).toLowerCase().contains(lowercaseQuery))
          .toList();
      
      if (filteredSubjects.isNotEmpty) {
        filteredCategories[entry.key] = filteredSubjects;
      }
    }

    return filteredCategories;
  }

  /// Subject categories with their respective subjects
  static const Map<String, List<Subject>> subjectCategories = {
    'STEM & Technology': [
      Subject.mathematics,
      Subject.physics,
      Subject.chemistry,
      Subject.biology,
      Subject.computerScience,
      Subject.engineering,
      Subject.statistics,
      Subject.dataScience,
      Subject.informationTechnology,
      Subject.cybersecurity,
    ],
    'Languages & Literature': [
      Subject.englishLiterature,
      Subject.englishLanguage,
      Subject.spanish,
      Subject.french,
      Subject.german,
      Subject.chinese,
      Subject.japanese,
      Subject.linguistics,
      Subject.creativeWriting,
    ],
    'Social Sciences': [
      Subject.history,
      Subject.geography,
      Subject.psychology,
      Subject.sociology,
      Subject.politicalScience,
      Subject.economics,
      Subject.anthropology,
      Subject.internationalRelations,
      Subject.philosophy,
      Subject.ethics,
    ],
    'Business & Management': [
      Subject.businessStudies,
      Subject.marketing,
      Subject.finance,
      Subject.accounting,
      Subject.management,
      Subject.humanResources,
      Subject.operationsManagement,
      Subject.entrepreneurship,
    ],
    'Arts & Creative': [
      Subject.art,
      Subject.music,
      Subject.drama,
      Subject.filmStudies,
      Subject.photography,
      Subject.graphicDesign,
      Subject.architecture,
    ],
    'Health & Medical': [
      Subject.medicine,
      Subject.nursing,
      Subject.publicHealth,
      Subject.nutrition,
      Subject.physicalEducation,
      Subject.sportsScience,
    ],
    'Law & Legal Studies': [
      Subject.law,
      Subject.criminalJustice,
      Subject.legalStudies,
    ],
    'Environmental & Earth Sciences': [
      Subject.environmentalScience,
      Subject.geology,
      Subject.climateScience,
      Subject.marineBiology,
    ],
    'Education & Teaching': [
      Subject.education,
      Subject.pedagogy,
      Subject.educationalPsychology,
    ],
  };
}
