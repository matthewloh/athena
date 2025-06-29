import 'package:athena/core/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FileUploadWidget extends StatelessWidget {
  final Function(List<PlatformFile>) onFilesSelected;
  final bool isEnabled;

  const FileUploadWidget({
    super.key,
    required this.onFilesSelected,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4, right: 4),
      child: PopupMenuButton<String>(
        enabled: isEnabled,
        icon: Icon(
          Icons.attach_file_rounded,
          color:
              isEnabled
                  ? Colors.black.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.3),
          size: 20,
        ),
        tooltip: 'Attach File',
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        onSelected: (value) => _handleFileSelection(context, value),
        itemBuilder:
            (context) => [
              PopupMenuItem(
                value: 'camera',
                child: Row(
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.athenaBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Take Photo'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'gallery',
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.athenaBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Choose Photo'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'document',
                child: Row(
                  children: [
                    Icon(
                      Icons.description_rounded,
                      color: AppColors.athenaBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Choose Document'),
                  ],
                ),
              ),
            ],
      ),
    );
  }

  Future<void> _handleFileSelection(BuildContext context, String type) async {
    try {
      List<PlatformFile> files = [];

      switch (type) {
        case 'camera':
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 2048,
            maxHeight: 2048,
            imageQuality: 85,
          );

          if (image != null) {
            final bytes = await image.readAsBytes();
            files.add(
              PlatformFile(
                name: image.name,
                size: bytes.length,
                bytes: bytes,
                path: image.path,
              ),
            );
          }
          break;

        case 'gallery':
          final ImagePicker picker = ImagePicker();
          final List<XFile> images = await picker.pickMultiImage(
            maxWidth: 2048,
            maxHeight: 2048,
            imageQuality: 85,
          );

          for (final image in images) {
            final bytes = await image.readAsBytes();
            files.add(
              PlatformFile(
                name: image.name,
                size: bytes.length,
                bytes: bytes,
                path: image.path,
              ),
            );
          }
          break;

        case 'document':
          final result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: [
              'pdf',
              'doc',
              'docx',
              'txt',
              'rtf',
              'xls',
              'xlsx',
              'ppt',
              'pptx',
              'jpg',
              'jpeg',
              'png',
              'gif',
              'webp',
              'mp4',
              'mov',
              'avi',
              'mkv',
              'mp3',
              'wav',
              'aac',
              'm4a',
            ],
            withData: true,
          );

          if (result != null) {
            files.addAll(result.files);
          }
          break;
      }

      if (files.isNotEmpty) {
        onFilesSelected(files);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class FileAttachmentPreview extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onRemove;
  final bool isUploading;
  final double? uploadProgress;

  const FileAttachmentPreview({
    super.key,
    required this.file,
    required this.onRemove,
    this.isUploading = false,
    this.uploadProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.athenaBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.athenaBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFileIcon(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatFileSize(file.size),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                if (isUploading && uploadProgress != null)
                  LinearProgressIndicator(
                    value: uploadProgress,
                    backgroundColor: Colors.black.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.athenaBlue,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isUploading ? null : onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color:
                    isUploading
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon() {
    final extension = file.extension?.toLowerCase() ?? '';

    // Show actual image thumbnail for image files
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension) &&
        file.bytes != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.memory(
            file.bytes!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40,
                height: 40,
                color: Colors.grey.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 20,
                ),
              );
            },
          ),
        ),
      );
    }

    // For non-image files, show appropriate icons
    IconData iconData;
    Color iconColor;

    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      iconData = Icons.image_rounded;
      iconColor = Colors.green;
    } else if (['pdf'].contains(extension)) {
      iconData = Icons.picture_as_pdf_rounded;
      iconColor = Colors.red;
    } else if (['doc', 'docx'].contains(extension)) {
      iconData = Icons.description_rounded;
      iconColor = Colors.blue;
    } else if (['xls', 'xlsx'].contains(extension)) {
      iconData = Icons.table_chart_rounded;
      iconColor = Colors.green;
    } else if (['ppt', 'pptx'].contains(extension)) {
      iconData = Icons.slideshow_rounded;
      iconColor = Colors.orange;
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      iconData = Icons.video_file_rounded;
      iconColor = Colors.purple;
    } else if (['mp3', 'wav', 'aac', 'm4a'].contains(extension)) {
      iconData = Icons.audio_file_rounded;
      iconColor = Colors.pink;
    } else {
      iconData = Icons.attach_file_rounded;
      iconColor = Colors.grey;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
