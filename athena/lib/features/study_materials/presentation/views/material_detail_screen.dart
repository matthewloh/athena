import 'package:flutter/material.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:go_router/go_router.dart';

class MaterialDetailScreen extends StatefulWidget {
  final String materialId;

  const MaterialDetailScreen({Key? key, required this.materialId})
    : super(key: key);

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGeneratingSummary = false;

  // Dummy data for UI preview
  final StudyMaterialEntity _dummyMaterial = StudyMaterialEntity(
    id: '123',
    userId: 'user123',
    title: 'Introduction to Machine Learning',
    description: 'Course notes from CS4021',
    subject: Subject.computerScience,
    contentType: ContentType.typedText,
    originalContentText: '''
Machine Learning is a field of study that gives computers the ability to learn without being explicitly programmed.

Key Concepts:
1. Supervised Learning: The algorithm is trained on a labeled dataset, which means we have both input and output parameters.
   - Classification: Predicts discrete values (e.g., spam or not spam)
   - Regression: Predicts continuous values (e.g., house prices)

2. Unsupervised Learning: The algorithm is trained on an unlabeled dataset and must find patterns on its own.
   - Clustering: Grouping similar data points (e.g., customer segmentation)
   - Association: Discovering rules that describe large portions of data (e.g., market basket analysis)

3. Reinforcement Learning: The algorithm learns through trial and error, receiving rewards for correct actions.
   - Used in robotics, gaming, and navigation

Common Algorithms:
- Linear Regression
- Logistic Regression
- Decision Trees
- Random Forest
- Support Vector Machines (SVM)
- K-means Clustering
- Neural Networks

Evaluation Metrics:
- Accuracy, Precision, Recall, F1-Score
- Mean Squared Error (MSE)
- Area Under ROC Curve (AUC)

Challenges:
- Overfitting: Model performs well on training data but poorly on unseen data
- Underfitting: Model is too simple to capture underlying patterns
- Feature Selection: Identifying the most relevant features
    ''',
    summaryText: '''
Machine Learning enables computers to learn without explicit programming. It encompasses:

• Supervised Learning: Uses labeled data for classification (discrete predictions) and regression (continuous predictions)
• Unsupervised Learning: Finds patterns in unlabeled data through clustering and association
• Reinforcement Learning: Learning via trial and error with reward-based feedback

Key algorithms include Linear/Logistic Regression, Decision Trees, Random Forests, SVMs, K-means, and Neural Networks.

Models are evaluated using metrics like Accuracy, Precision, Recall, F1-Score, MSE, and AUC.

Main challenges include overfitting (poor generalization), underfitting (oversimplification), and effective feature selection.
    ''',
    hasAiSummary: true,
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    updatedAt: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleRequestSummary() {
    // In a real app, this would call the RequestSummarizationUseCase
    setState(() {
      _isGeneratingSummary = true;
    });

    // Simulate API delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isGeneratingSummary = false;
      });

      // Navigate to summary tab after generation
      _tabController.animateTo(1);
    });
  }

  void _handleEditMaterial() {
    // Navigate to edit screen with the current material's ID
    context.pushNamed(
      AppRouteNames.addEditMaterial,
      queryParameters: {'materialId': _dummyMaterial.id},
    );
  }

  void _handleDeleteMaterial() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Material'),
            content: const Text(
              'Are you sure you want to delete this study material? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  // In a real app, this would call the DeleteStudyMaterialUseCase
                  context.pop(); // Close the dialog
                  context.pop(); // Return to the materials list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Material deleted successfully'),
                    ),
                  );
                },
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  void _handleAskChatbot() {
    // In a real app, this would navigate to the chatbot with context from this material
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Would open chatbot with this content as context'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: AppColors.athenaPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: _handleAskChatbot,
            tooltip: 'Ask Athena',
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _handleEditMaterial,
            tooltip: 'Edit Material',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _handleDeleteMaterial,
            tooltip: 'Delete Material',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.athenaLightGrey,
          indicatorColor: AppColors.white,
          tabs: const [Tab(text: 'CONTENT'), Tab(text: 'AI SUMMARY')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Original content tab
          _buildOriginalContentTab(),

          // AI Summary tab
          _buildSummaryTab(),
        ],
      ),
    );
  }

  Widget _buildOriginalContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Material title
          Text(
            _dummyMaterial.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Material metadata
          Text(
            _dummyMaterial.subject.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.athenaBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _dummyMaterial.description ?? 'No description available',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.athenaMediumGrey),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 16),

          // Material content
          _dummyMaterial.contentType == 'typedText'
              ? Text(
                _dummyMaterial.originalContentText ?? 'No content available',
                style: Theme.of(context).textTheme.bodyLarge,
              )
              : _dummyMaterial.contentType == 'imageFile'
              ? const Center(
                child: Text('Image note preview would appear here'),
              )
              : const Center(child: Text('File content would appear here')),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    final hasSummary =
        _dummyMaterial.summaryText != null &&
        _dummyMaterial.summaryText!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Material title
          Text(
            _dummyMaterial.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Summary content or loading state
          _isGeneratingSummary
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating summary...'),
                  ],
                ),
              )
              : hasSummary
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI-Generated Summary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dummyMaterial.summaryText!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No summary available yet'),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _handleRequestSummary,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate Summary'),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
