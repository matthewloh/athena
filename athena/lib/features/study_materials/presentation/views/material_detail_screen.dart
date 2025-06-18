import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/presentation/viewmodel/study_material_viewmodel.dart';
import 'package:athena/features/study_materials/presentation/utils/subject_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialDetailScreen extends ConsumerStatefulWidget {
  final String materialId;

  const MaterialDetailScreen({Key? key, required this.materialId})
    : super(key: key);

  @override
  ConsumerState<MaterialDetailScreen> createState() =>
      _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends ConsumerState<MaterialDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyMaterialViewModelProvider);
    final viewModel = ref.read(studyMaterialViewModelProvider.notifier);

    // Load material if not already loaded
    final material = state.getMaterialById(widget.materialId);

    if (material == null) {
      // Try to load the material
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.loadMaterial(widget.materialId);
      });

      return Scaffold(
        backgroundColor: AppColors.athenaOffWhite,
        appBar: AppBar(
          backgroundColor: AppColors.athenaPurple,
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error if any
    if (state.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () => viewModel.clearError(),
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      appBar: _buildAppBar(context, material, viewModel),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOriginalContentTab(material),
                _buildSummaryTab(material, state, viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleEditMaterial(StudyMaterialEntity material) {
    // Navigate to edit screen with the current material's ID
    context.pushNamed(
      AppRouteNames.addEditMaterial,
      queryParameters: {'materialId': material.id},
    );
  }

  void _handleDeleteMaterial(StudyMaterialEntity material, dynamic viewModel) {
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
                  viewModel.deleteMaterial(material.id);
                  context.pop(); // Close the dialog
                  context.pop(); // Return to the materials list
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

  AppBar _buildAppBar(
    BuildContext context,
    StudyMaterialEntity material,
    dynamic viewModel,
  ) {
    return AppBar(
      backgroundColor: AppColors.athenaPurple,
      title: Text(
        material.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _handleEditMaterial(material),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _handleDeleteMaterial(material, viewModel),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabs: const [Tab(text: 'Original Content'), Tab(text: 'AI Summary')],
      ),
    );
  }

  Widget _buildOriginalContentTab(StudyMaterialEntity material) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Material title
          Text(
            material.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Combined metadata row
          _buildMetadataRow(material),
          const SizedBox(height: 8),

          // Description if available
          if (material.description != null &&
              material.description!.isNotEmpty) ...[
            Text(
              material.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
          ],

          const Divider(),
          const SizedBox(height: 16),
          
          // Material content based on type
          if (material.contentType == ContentType.typedText)
            _buildTypedTextContent(material)
          else if (material.contentType == ContentType.imageFile)
            _buildImageContent(
              material,
              ref.read(studyMaterialViewModelProvider.notifier),
            )
          else
            _buildFileContent(
              material,
              ref.read(studyMaterialViewModelProvider.notifier),
            ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getContentTypeLabel(ContentType type) {
    switch (type) {
      case ContentType.typedText:
        return 'Rich Text';
      case ContentType.imageFile:
        return 'Image Note';
      case ContentType.textFile:
        return 'File Note';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return 'Just now';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  Widget _buildTypedTextContent(StudyMaterialEntity material) {
    if (material.originalContentText == null ||
        material.originalContentText!.isEmpty) {
      return const Text('No content available');
    }

    try {
      // Try to parse the content as Quill Delta JSON
      final json = jsonDecode(material.originalContentText!);
      final quillController = QuillController(
        document: Document.fromJson(json),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            child: QuillEditor(
              controller: quillController,
              scrollController: ScrollController(),
              focusNode: FocusNode(),
              config: QuillEditorConfig(
                padding: EdgeInsets.zero,
                placeholder: '',
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      // Fallback to plain text if parsing fails
      return Text(
        material.originalContentText!,
        style: Theme.of(context).textTheme.bodyLarge,
      );
    }
  }

  Widget _buildMetadataRow(StudyMaterialEntity material) {
    final (subjectColor, subjectIcon) = SubjectUtils.getSubjectAttributes(
      material.subject,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags row with proper overflow handling
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Type tag with icon
            _buildTag(
              icon: _getContentTypeIcon(material.contentType),
              label: _getContentTypeLabel(material.contentType),
              color: AppColors.athenaPurple,
            ),

            // Subject tag with icon if available
            if (material.subject != null)
              _buildTag(
                icon: subjectIcon,
                label: SubjectUtils.getDisplayName(material.subject),
                color: subjectColor,
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Date info
        Text(
          material.updatedAt != material.createdAt
              ? 'Updated ${_formatDate(material.updatedAt)}'
              : 'Created ${_formatDate(material.createdAt)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.athenaMediumGrey),
        ),
      ],
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.typedText:
        return Icons.text_fields_rounded;
      case ContentType.imageFile:
        return Icons.image_rounded;
      case ContentType.textFile:
        return Icons.description_rounded;
    }
  }

  Widget _buildSummaryTab(
    StudyMaterialEntity material,
    dynamic state,
    dynamic viewModel,
  ) {
    final hasSummary =
        material.summaryText != null && material.summaryText!.isNotEmpty;
    final isGeneratingSummary = state.isGeneratingSummary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Material title
          Text(
            material.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Metadata row - reuse the same one from original tab
          _buildMetadataRow(material),
          const SizedBox(height: 16),

          // Summary content or loading state
          if (isGeneratingSummary)
            _buildGeneratingSummaryUI()
          else if (hasSummary)
            _buildExistingSummaryUI(material, viewModel)
          else
            _buildNoSummaryUI(material, viewModel),
        ],
      ),
    );
  }

  Widget _buildGeneratingSummaryUI() {
    return Card(
      elevation: 0,
      color: Colors.blue.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Generating AI Summary...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This may take a moment as our AI analyzes your content.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue.shade600.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingSummaryUI(
    StudyMaterialEntity material,
    dynamic viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and action buttons
        Row(
          children: [
            const Text(
              'AI-Generated Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Spacer(),
            // Copy button
            IconButton(
              tooltip: 'Copy summary to clipboard',
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () {
                // Copy to clipboard functionality
                final summaryText = material.summaryText ?? '';
                if (summaryText.isNotEmpty) {
                  _copyToClipboard(summaryText);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Summary copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Summary content
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            material.summaryText!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),

        const SizedBox(height: 24),

        // Regenerate button
        Center(
          child: OutlinedButton.icon(
            onPressed: () {
              viewModel.generateAiSummary(material.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Regenerating summary...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Regenerate Summary'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoSummaryUI(StudyMaterialEntity material, dynamic viewModel) {
    return Card(
      elevation: 0,
      color: Colors.grey.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 48,
              color: AppColors.athenaPurple,
            ),
            const SizedBox(height: 16),
            const Text(
              'No AI Summary Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Generate an AI summary to quickly grasp the key points of this material.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                viewModel.generateAiSummary(material.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Generating summary...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Summary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.athenaPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  // Image content display with download URL from Supabase
  Widget _buildImageContent(StudyMaterialEntity material, dynamic viewModel) {
    if (material.fileStoragePath == null || material.fileStoragePath!.isEmpty) {
      return const Center(
        child: Text(
          'Image not available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return FutureBuilder<String?>(
      future: viewModel.getSignedDownloadUrl(material.fileStoragePath!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Failed to load image: ${snapshot.error ?? "Unknown error"}',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Image loaded successfully
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  snapshot.data!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Actions row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download Image'),
                  onPressed: () {
                    if (snapshot.data != null) {
                      final Uri url = Uri.parse(snapshot.data!);
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                // Show OCR button if there's no OCR text yet and we're not already processing
                if ((material.ocrExtractedText == null ||
                        material.ocrExtractedText!.isEmpty) &&
                    !ref.watch(studyMaterialViewModelProvider).isProcessingOcr)
                  TextButton.icon(
                    icon: const Icon(Icons.document_scanner),
                    label: const Text('Extract Text (OCR)'),
                    onPressed: () => viewModel.processOcr(material.id),
                  ),
              ],
            ),

            // OCR Text Section
            if (material.ocrExtractedText != null &&
                material.ocrExtractedText!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Extracted Text from Image:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.ocrExtractedText!,
                      style: const TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy Text'),
                        onPressed:
                            () => _copyToClipboard(material.ocrExtractedText!),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (ref
                .watch(studyMaterialViewModelProvider)
                .isProcessingOcr) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Processing OCR to extract text from this image...',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Text(
                  'No text could be extracted from this image.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // File content display with download link and preview
  Widget _buildFileContent(StudyMaterialEntity material, dynamic viewModel) {
    if (material.fileStoragePath == null || material.fileStoragePath!.isEmpty) {
      return const Center(
        child: Text('File not available', style: TextStyle(color: Colors.grey)),
      );
    }

    return FutureBuilder<String?>(
      future: viewModel.getSignedDownloadUrl(material.fileStoragePath!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to access file: ${snapshot.error ?? "Unknown error"}',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // File URL retrieved successfully
        final fileName = material.fileStoragePath!.split('/').last;
        final fileExtension = fileName.split('.').last.toLowerCase();
        final isPreviewableText = [
          'txt',
          'md',
          'json',
          'csv',
          'xml',
          'html',
          'css',
          'js',
          'dart',
        ].contains(fileExtension);
        final hasSavedContent =
            material.originalContentText != null &&
            material.originalContentText!.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File header with icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(fileExtension),
                    size: 48,
                    color: AppColors.athenaPurple,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Type: ${fileExtension.toUpperCase()} file',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Action buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download File'),
                  onPressed: () {
                    final Uri url = Uri.parse(snapshot.data!);
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                ),

                // Preview button if it's a web-viewable file
                if (!isPreviewableText)
                  TextButton.icon(
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Open in Browser'),
                    onPressed: () {
                      final Uri url = Uri.parse(snapshot.data!);
                      launchUrl(url, mode: LaunchMode.platformDefault);
                    },
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // File content preview section
            if (isPreviewableText && hasSavedContent) ...[
              const Text(
                'File Preview:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 400),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    material.originalContentText!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy Text'),
                  onPressed:
                      () => _copyToClipboard(material.originalContentText!),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ] else if (!isPreviewableText &&
                hasSavedContent &&
                fileExtension == 'pdf') ...[
              // For PDFs, we might have extracted content
              const Text(
                'File Content:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.originalContentText!,
                      style: const TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy Text'),
                        onPressed:
                            () =>
                                _copyToClipboard(material.originalContentText!),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isPreviewableText) ...[
              // Text file that we don't have content for yet
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Text(
                  'Preview not available. Download the file to view its contents.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // Helper to get appropriate icon based on file extension
  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
      case 'md':
        return Icons.article;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp3':
      case 'wav':
      case 'ogg':
        return Icons.audio_file;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }
}
