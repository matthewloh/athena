import 'package:athena/domain/enums/subject.dart';
import 'package:flutter/material.dart';

/// Utility class for Subject enum operations
class SubjectUtils {
  /// Get subject color and icon for consistent UI representation
  static (Color, IconData) getSubjectAttributes(Subject? subject) {
    if (subject == null) {
      return (Colors.grey, Icons.subject);
    }

    switch (subject) {
      // STEM & Technology
      case Subject.mathematics:
        return (Colors.blue, Icons.calculate_rounded);
      case Subject.physics:
        return (Colors.indigo, Icons.science_rounded);
      case Subject.chemistry:
        return (Colors.green, Icons.science_rounded);
      case Subject.biology:
        return (Colors.teal, Icons.biotech_rounded);
      case Subject.computerScience:
        return (Colors.deepPurple, Icons.computer_rounded);
      case Subject.engineering:
        return (Colors.orange, Icons.engineering_rounded);
      case Subject.statistics:
        return (Colors.blueGrey, Icons.bar_chart_rounded);
      case Subject.dataScience:
        return (Colors.cyan, Icons.analytics_rounded);
      case Subject.informationTechnology:
        return (Colors.purple, Icons.devices_rounded);
      case Subject.cybersecurity:
        return (Colors.red, Icons.security_rounded);

      // Languages & Literature
      case Subject.englishLiterature:
      case Subject.englishLanguage:
        return (Colors.purple, Icons.menu_book_rounded);
      case Subject.spanish:
      case Subject.french:
      case Subject.german:
      case Subject.chinese:
      case Subject.japanese:
        return (Colors.deepOrange, Icons.language_rounded);
      case Subject.linguistics:
        return (Colors.pink, Icons.translate_rounded);
      case Subject.creativeWriting:
        return (Colors.indigo, Icons.edit_rounded);

      // Social Sciences
      case Subject.history:
        return (Colors.amber.shade700, Icons.history_edu_rounded);
      case Subject.geography:
        return (Colors.green, Icons.map_rounded);
      case Subject.psychology:
        return (Colors.purple, Icons.psychology_rounded);
      case Subject.sociology:
        return (Colors.blue, Icons.groups_rounded);
      case Subject.politicalScience:
        return (Colors.red, Icons.account_balance_rounded);
      case Subject.economics:
        return (Colors.green, Icons.trending_up_rounded);
      case Subject.anthropology:
        return (Colors.brown, Icons.diversity_3_rounded);
      case Subject.internationalRelations:
        return (Colors.blue, Icons.public_rounded);
      case Subject.philosophy:
        return (Colors.grey, Icons.psychology_alt_rounded);
      case Subject.ethics:
        return (Colors.teal, Icons.gavel_rounded);

      // Business & Management
      case Subject.businessStudies:
        return (Colors.blue, Icons.business_rounded);
      case Subject.marketing:
        return (Colors.orange, Icons.campaign_rounded);
      case Subject.finance:
        return (Colors.green, Icons.attach_money_rounded);
      case Subject.accounting:
        return (Colors.teal, Icons.receipt_long_rounded);
      case Subject.management:
        return (Colors.purple, Icons.manage_accounts_rounded);
      case Subject.humanResources:
        return (Colors.pink, Icons.people_rounded);
      case Subject.operationsManagement:
        return (Colors.indigo, Icons.settings_rounded);
      case Subject.entrepreneurship:
        return (Colors.orange, Icons.lightbulb_rounded);

      // Arts & Creative
      case Subject.art:
        return (Colors.pink, Icons.palette_rounded);
      case Subject.music:
        return (Colors.purple, Icons.music_note_rounded);
      case Subject.drama:
        return (Colors.red, Icons.theater_comedy_rounded);
      case Subject.filmStudies:
        return (Colors.indigo, Icons.movie_rounded);
      case Subject.photography:
        return (Colors.grey, Icons.camera_alt_rounded);
      case Subject.graphicDesign:
        return (Colors.cyan, Icons.design_services_rounded);
      case Subject.architecture:
        return (Colors.brown, Icons.architecture_rounded);

      // Health & Medical
      case Subject.medicine:
        return (Colors.red, Icons.local_hospital_rounded);
      case Subject.nursing:
        return (Colors.pink, Icons.medical_services_rounded);
      case Subject.publicHealth:
        return (Colors.green, Icons.health_and_safety_rounded);
      case Subject.nutrition:
        return (Colors.orange, Icons.restaurant_rounded);
      case Subject.physicalEducation:
        return (Colors.blue, Icons.fitness_center_rounded);
      case Subject.sportsScience:
        return (Colors.indigo, Icons.sports_soccer_rounded);

      // Law & Legal Studies
      case Subject.law:
        return (Colors.brown, Icons.gavel_rounded);
      case Subject.criminalJustice:
        return (Colors.red, Icons.security_rounded);
      case Subject.legalStudies:
        return (Colors.grey, Icons.balance_rounded);

      // Environmental & Earth Sciences
      case Subject.environmentalScience:
        return (Colors.green, Icons.eco_rounded);
      case Subject.geology:
        return (Colors.brown, Icons.terrain_rounded);
      case Subject.climateScience:
        return (Colors.blue, Icons.cloud_rounded);
      case Subject.marineBiology:
        return (Colors.cyan, Icons.waves_rounded);

      // Education & Teaching
      case Subject.education:
        return (Colors.amber, Icons.school_rounded);
      case Subject.pedagogy:
        return (Colors.orange, Icons.school_rounded);
      case Subject.educationalPsychology:
        return (Colors.purple, Icons.psychology_rounded);

      // Default case
      case Subject.none:
        return (Colors.grey, Icons.subject);
    }
  }

  /// Convert Subject enum to user-friendly display name
  static String getDisplayName(Subject? subject) {
    if (subject == null) return 'None';

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
