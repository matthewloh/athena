import 'package:athena/core/constants/app_route_names.dart';

/// Navigation action that can be embedded in chatbot responses
class ChatNavigationAction {
  final String id;
  final String label;
  final String? description;
  final String routeName;
  final Map<String, dynamic>? pathParameters;
  final Map<String, dynamic>? queryParameters;
  final String? icon;
  final ChatNavigationActionType type;

  const ChatNavigationAction({
    required this.id,
    required this.label,
    this.description,
    required this.routeName,
    this.pathParameters,
    this.queryParameters,
    this.icon,
    this.type = ChatNavigationActionType.primary,
  });

  factory ChatNavigationAction.fromJson(Map<String, dynamic> json) {
    return ChatNavigationAction(
      id: json['id'] as String,
      label: json['label'] as String,
      description: json['description'] as String?,
      routeName: json['routeName'] as String,
      pathParameters: json['pathParameters'] as Map<String, dynamic>?,
      queryParameters: json['queryParameters'] as Map<String, dynamic>?,
      icon: json['icon'] as String?,
      type: ChatNavigationActionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChatNavigationActionType.primary,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'description': description,
      'routeName': routeName,
      'pathParameters': pathParameters,
      'queryParameters': queryParameters,
      'icon': icon,
      'type': type.name,
    };
  }

  // Factory constructors for common navigation actions
  static ChatNavigationAction viewMaterial({
    required String materialId,
    required String materialTitle,
    bool showSummary = false,
  }) {
    return ChatNavigationAction(
      id: 'view_material_$materialId',
      label: materialTitle,
      description: 'View material details',
      routeName: AppRouteNames.materialDetail,
      pathParameters: {'materialId': materialId},
      queryParameters: showSummary ? {'tab': 'summary'} : null,
      icon: '📄',
      type: ChatNavigationActionType.material,
    );
  }

  static ChatNavigationAction viewAllMaterials({String? subject}) {
    return ChatNavigationAction(
      id: 'view_all_materials',
      label: 'View All Materials',
      description: subject != null ? 'View $subject materials' : 'Browse your study materials',
      routeName: AppRouteNames.materials,
      queryParameters: subject != null ? {'subject': subject} : null,
      icon: '📚',
      type: ChatNavigationActionType.primary,
    );
  }

  static ChatNavigationAction createQuiz({String? studyMaterialId, String? materialTitle}) {
    return ChatNavigationAction(
      id: 'create_quiz_${studyMaterialId ?? 'new'}',
      label: materialTitle != null ? 'Create Quiz: $materialTitle' : 'Create Quiz',
      description: 'Generate quiz questions from this material',
      routeName: AppRouteNames.createQuiz,
      queryParameters: studyMaterialId != null ? {'studyMaterialId': studyMaterialId} : null,
      icon: '❓',
      type: ChatNavigationActionType.quiz,
    );
  }

  static ChatNavigationAction viewQuiz({
    required String quizId,
    required String quizTitle,
  }) {
    return ChatNavigationAction(
      id: 'view_quiz_$quizId',
      label: quizTitle,
      description: 'View quiz details and performance',
      routeName: AppRouteNames.quizDetail,
      pathParameters: {'quizId': quizId},
      icon: '📝',
      type: ChatNavigationActionType.quiz,
    );
  }

  static ChatNavigationAction startReviewSession({
    required String quizId,
    required String quizTitle,
    String? sessionType,
  }) {
    return ChatNavigationAction(
      id: 'review_$quizId',
      label: 'Review: $quizTitle',
      description: 'Start a review session',
      routeName: AppRouteNames.reviewSession,
      pathParameters: {'quizId': quizId},
      queryParameters: sessionType != null ? {'sessionType': sessionType} : null,
      icon: '🎯',
      type: ChatNavigationActionType.review,
    );
  }

  static ChatNavigationAction viewAllQuizzes() {
    return ChatNavigationAction(
      id: 'view_all_quizzes',
      label: 'View All Quizzes',
      description: 'Browse your quiz collection',
      routeName: AppRouteNames.review,
      icon: '📋',
      type: ChatNavigationActionType.primary,
    );
  }

  static ChatNavigationAction viewPlanner() {
    return ChatNavigationAction(
      id: 'view_planner',
      label: 'Study Planner',
      description: 'Plan your study sessions',
      routeName: AppRouteNames.planner,
      icon: '📅',
      type: ChatNavigationActionType.planner,
    );
  }

  static ChatNavigationAction viewProgressInsights() {
    return ChatNavigationAction(
      id: 'view_progress',
      label: 'Progress Insights',
      description: 'View your study analytics',
      routeName: AppRouteNames.progressInsights,
      icon: '📊',
      type: ChatNavigationActionType.insights,
    );
  }

  static ChatNavigationAction addMaterial({String? contentType}) {
    return ChatNavigationAction(
      id: 'add_material_${contentType ?? 'new'}',
      label: 'Add Study Material',
      description: 'Upload or create new study material',
      routeName: AppRouteNames.addEditMaterial,
      queryParameters: contentType != null ? {'contentType': contentType} : null,
      icon: '➕',
      type: ChatNavigationActionType.action,
    );
  }
}

enum ChatNavigationActionType {
  primary,    // Main actions (blue)
  material,   // Material-related (green)
  quiz,       // Quiz-related (orange)
  review,     // Review sessions (purple)
  planner,    // Planning (teal)
  insights,   // Analytics (indigo)
  action,     // Create/Add actions (red)
} 