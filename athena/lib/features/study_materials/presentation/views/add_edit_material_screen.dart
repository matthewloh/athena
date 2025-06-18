import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/features/shared/widgets/app_button.dart';
import 'package:athena/features/shared/widgets/app_text_field.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/domain/usecases/params/create_study_material_params.dart';
import 'package:athena/features/study_materials/domain/usecases/params/update_study_material_params.dart';
import 'package:athena/features/study_materials/presentation/viewmodel/study_material_viewmodel.dart';
import 'package:athena/features/study_materials/presentation/viewmodel/study_material_state.dart';
import 'package:athena/features/study_materials/presentation/widgets/subject_searchable_dropdown.dart';
import 'package:athena/features/study_materials/presentation/utils/ocr_utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:go_router/go_router.dart';

class AddEditMaterialScreen extends ConsumerStatefulWidget {
  final StudyMaterialEntity?
  material; // Null when adding new, non-null when editing
  final ContentType?
  initialContentType; // Optional initial content type for new materials

  const AddEditMaterialScreen({
    Key? key,
    this.material,
    this.initialContentType,
  }) : super(key: key);

  @override
  ConsumerState<AddEditMaterialScreen> createState() =>
      _AddEditMaterialScreenState();
}

class _AddEditMaterialScreenState extends ConsumerState<AddEditMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  // Subject selection (replacing TextEditingController)
  Subject? _selectedSubject;

  // Quill editor controller for rich text
  late QuillController _quillController;
  final _quillFocusNode = FocusNode();
  final ScrollController _quillScrollController = ScrollController();
  late ContentType _selectedContentType;
  File? _selectedFile;
  File? _selectedImage;
  String? _extractedImageText; // Store OCR extracted text for image notes
  TextEditingController?
  _imageTextController; // Controller for editing extracted text
  bool _isLoading = false;
  String? _fileErrorText;

  @override
  void initState() {
    super.initState();
    // Initialize QuillController with empty document
    _quillController = QuillController.basic();

    // Initialize content type
    _selectedContentType =
        widget.initialContentType ??
        ContentType.typedText; // Initialize with existing data if editing
    if (widget.material != null) {
      _titleController.text = widget.material!.title;

      // Set the subject if available
      _selectedSubject = widget.material!.subject;

      _selectedContentType = widget.material!.contentType;

      // If typed text, populate the content
      if (_selectedContentType == ContentType.typedText &&
          widget.material!.originalContentText != null) {
        // For regular text content
        _contentController.text = widget.material!.originalContentText!;

        // For rich text content (if it's stored as JSON)
        try {
          final dynamic jsonData = json.decode(
            widget.material!.originalContentText!,
          );
          _quillController = QuillController(
            document: Document.fromJson(jsonData),
            selection: const TextSelection.collapsed(offset: 0),
          );
        } catch (e) {
          // If not valid JSON, create a document from plain text
          final document =
              Document()..insert(0, widget.material!.originalContentText!);
          _quillController = QuillController(
            document: document,
            selection: const TextSelection.collapsed(offset: 0),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    // Dispose all the controllers to prevent memory leaks
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _quillController.dispose();
    _quillFocusNode.dispose();
    _quillScrollController.dispose();

    // Safely dispose the image text controller if it exists
    if (_imageTextController != null) {
      _imageTextController!.dispose();
      _imageTextController = null;
    }

    super.dispose();
  }

  Future<void> _pickTextFile() async {
    setState(() {
      _fileErrorText = null;
      _selectedFile = null;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt', 'md'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      // Check if the file size is acceptable (e.g., less than 5MB)
      if (await file.length() > 5 * 1024 * 1024) {
        setState(() {
          _fileErrorText = 'File too large (max 5MB)';
        });
        return;
      }

      setState(() {
        _selectedFile = file;
      });
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _fileErrorText = null;
    });

    // Show a modal bottom sheet to choose between camera and gallery
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Image',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () async {
                      context.pop();
                      await _getImageFromSource(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () async {
                      context.pop();
                      await _getImageFromSource(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 36, color: AppColors.secondary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _getImageFromSource(ImageSource source) async {
    setState(() {
      _selectedImage = null;
      _fileErrorText = null;
    });
    try {
      final ImagePicker picker = ImagePicker();

      // Use more reasonable image quality/size parameters to prevent large files
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        // Lower quality for better performance and memory usage
        imageQuality: 80,
        preferredCameraDevice:
            CameraDevice.rear, // Use rear camera by default for better quality
      );

      if (image != null) {
        File imageFile = File(image.path);

        // Verify file exists before proceeding
        if (!await imageFile.exists()) {
          setState(() {
            _fileErrorText = 'Image file not found. Please try again.';
          });
          return;
        }

        // First check if the original image size is acceptable
        final fileSize = await imageFile.length();
        if (fileSize > 10 * 1024 * 1024) {
          setState(() {
            _fileErrorText =
                'Image too large (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB, max 10MB)';
          });
          return;
        }

        // Set the image immediately to avoid blank screen if cropping fails
        setState(() {
          _selectedImage = imageFile;
          // Clear any previous error
          _fileErrorText = null;
        });

        // Now try to crop the image if possible, but don't block the UI
        try {
          // Attempt to crop but don't wait for it in the main flow
          final croppedFile = await _cropImage(image.path);

          // If cropping was successful, update the image
          if (croppedFile != null) {
            final File croppedImageFile = File(croppedFile.path);

            // Update the image if we're still in image mode
            if (mounted && _selectedContentType == ContentType.imageFile) {
              setState(() {
                _selectedImage = croppedImageFile;
              });

              // Try OCR on the cropped image
              await _processImageWithOCR(croppedImageFile);
            }
          } else {
            // If cropping returned null but we still have the original image
            if (mounted && _selectedContentType == ContentType.imageFile) {
              // Try OCR on the original image
              await _processImageWithOCR(imageFile);
            }
          }
        } catch (e) {
          print('Error during image processing: $e');
          // We already set _selectedImage to the original file above,
          // so no need to do anything here

          // Still try OCR on the original image
          if (mounted && _selectedContentType == ContentType.imageFile) {
            try {
              await _processImageWithOCR(imageFile);
            } catch (ocrError) {
              print('Error during OCR processing: $ocrError');
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        _fileErrorText = 'Error capturing image: ${e.toString()}';
      });
      print('Error picking image: $e');
    }
  }

  Future<CroppedFile?> _cropImage(String sourcePath) async {
    try {
      // Use bare minimum configuration to avoid crashes
      return await ImageCropper().cropImage(
        sourcePath: sourcePath,
        // Avoid using aspectRatioPresets parameter
        // Avoid using compressQuality parameter
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );
    } catch (e) {
      print('Error during image cropping: $e');

      // Create a more detailed log for debugging
      if (e is Exception) {
        print('Exception type: ${e.runtimeType}');
        print('Exception details: $e');
      }

      // Return null to indicate cropping failed, so original image will be used
      return null;
    }
  }
  Future<void> _processImageWithOCR(File imageFile) async {
    if (!mounted) return;

    try {
      // Show a loading indicator
      setState(() {
        _isLoading = true;
      });

      // Use the OCR utility to process the image
      final extractedText = await OcrUtils.processImageWithOCR(imageFile);

      // Hide loading indicator regardless of success/failure
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // If the widget is still mounted, show results whether text was extracted or not
      if (mounted) {
        // Show a dialog with the extracted text and options
        bool? addTextToImage = await OcrUtils.showOcrResultDialog(
          context, 
          extractedText
        );

        // If user chooses to add the text to the image
        if (addTextToImage == true && mounted) {
          setState(() {
            // Store the extracted text
            _extractedImageText = extractedText;

            // Dispose of any existing controller first to prevent memory leaks
            if (_imageTextController != null) {
              _imageTextController!.dispose();
              _imageTextController = null;
            }

            // Initialize the text controller with the extracted text
            _imageTextController = TextEditingController(text: extractedText ?? '');
          });
        }
      }
    } catch (e) {
      debugPrint('Error in OCR processing: $e');
      // Ensure loading indicator is hidden
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveStudyMaterial() async {
    if (!_formKey.currentState!.validate() ||
        (_isContentRequired() && !_isContentProvided())) {
      // Show content error if applicable
      if (_isContentRequired() && !_isContentProvided()) {
        setState(() {
          _fileErrorText = 'Please provide the required content';
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _fileErrorText = null; // Clear any previous errors
    });

    try {
      final viewModel = ref.read(studyMaterialViewModelProvider.notifier);

      if (widget.material == null) {
        // Adding new material
        await _createNewMaterial(viewModel);
      } else {
        // Editing existing material
        await _updateExistingMaterial(viewModel);
      }

      if (mounted) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.material == null
                  ? 'Study material created successfully!'
                  : 'Study material updated successfully!',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        // Safe navigation back
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(AppRouteNames.materials);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fileErrorText =
              e.toString().contains('Exception: ')
                  ? e.toString().replaceFirst('Exception: ', '')
                  : e.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${_fileErrorText}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createNewMaterial(StudyMaterialViewModel viewModel) async {
    CreateStudyMaterialParams params;

    switch (_selectedContentType) {
      case ContentType.typedText:
        // Convert Quill document to JSON string for storage
        final documentJson = _quillController.document.toDelta().toJson();
        final contentText = json.encode(documentJson);

        params = CreateStudyMaterialParams.fromUserInput(
          title: _titleController.text.trim(),
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          subject: _selectedSubject,
          contentType: ContentType.typedText,
          originalContentText: contentText,
        );
        break;
      case ContentType.textFile:
        if (_selectedFile == null) {
          throw Exception('No file selected');
        }

        // Read file content based on file type
        String? fileContent;
        String? filePath = _selectedFile!.path;

        try {
          final extension = filePath.split('.').last.toLowerCase();

          if (extension == 'txt' || extension == 'md') {
            // For text files, read the content directly
            fileContent = await _selectedFile!.readAsString();
          } else {
            // For other files (PDF, DOCX), store the path for backend processing
            // The backend will handle file parsing and text extraction
            fileContent =
                'File uploaded: ${_selectedFile!.path.split('/').last}';
          }
        } catch (e) {
          // If reading fails, just store file information
          fileContent = 'File uploaded: ${_selectedFile!.path.split('/').last}';
        }

        params = CreateStudyMaterialParams.fromUserInput(
          title: _titleController.text.trim(),
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          subject: _selectedSubject,
          contentType: ContentType.textFile,
          originalContentText: fileContent,
          fileStoragePath: filePath, // Store the local path for upload
        );
        break;

      case ContentType.imageFile:
        if (_selectedImage == null) {
          throw Exception('No image selected');
        }

        params = CreateStudyMaterialParams.fromUserInput(
          title: _titleController.text.trim(),
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          subject: _selectedSubject,
          contentType: ContentType.imageFile,
          fileStoragePath:
              _selectedImage!.path, // This will be processed by the backend
          ocrExtractedText: _extractedImageText, // Include any extracted text
        );
        break;
    }

    await viewModel.createMaterial(params);
  }

  Future<void> _updateExistingMaterial(StudyMaterialViewModel viewModel) async {
    if (widget.material == null) return;

    // For editing, we'll update metadata and content if it's typed text
    String? updatedContent;

    if (_selectedContentType == ContentType.typedText) {
      // Convert Quill document to JSON string for storage
      final documentJson = _quillController.document.toDelta().toJson();
      updatedContent = json.encode(documentJson);
    }

    final params = UpdateStudyMaterialParams(
      id: widget.material!.id,
      title: _titleController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      subject: _selectedSubject,
      originalContentText: updatedContent,
    );

    await viewModel.updateMaterial(params);
  }

  bool _isContentRequired() {
    // Content is required when creating new materials (not when editing)
    return widget.material == null;
  }

  bool _isContentProvided() {
    switch (_selectedContentType) {
      case ContentType.typedText:
        // Check if Quill document has actual content
        final text = _quillController.document.toPlainText().trim();
        return text.isNotEmpty;
      case ContentType.textFile:
        return _selectedFile != null;
      case ContentType.imageFile:
        return _selectedImage != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.material != null;
    final appTheme = Theme.of(context);

    // Watch for errors from the viewmodel
    ref.listen<StudyMaterialState>(studyMaterialViewModelProvider, (
      previous,
      current,
    ) {
      if (current.error != null && current.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.error!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
        // Clear the error after showing it
        ref.read(studyMaterialViewModelProvider.notifier).clearError();
      }
    });

    final state = ref.watch(studyMaterialViewModelProvider);
    final isCreatingMaterial = state.isCreating;

    return Scaffold(
      appBar: _buildAppBar(),
      body:
          (_isLoading || isCreatingMaterial)
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Title Field
                    AppTextField(
                      controller: _titleController,
                      labelText: 'Title',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16), // Subject Field (Optional)
                    SubjectSearchableDropdown(
                      selectedSubject: _selectedSubject,
                      onChanged: (Subject? subject) {
                        setState(() {
                          _selectedSubject = subject;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: _descriptionController,
                      labelText: 'Description (Optional)',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Content Type Selection
                    if (!isEditing) ...[
                      Text(
                        'Content Type',
                        style: appTheme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<ContentType>(
                        segments: const [
                          ButtonSegment<ContentType>(
                            value: ContentType.typedText,
                            label: Text('Type Text'),
                            icon: Icon(Icons.edit),
                          ),
                          ButtonSegment<ContentType>(
                            value: ContentType.textFile,
                            label: Text('Upload File'),
                            icon: Icon(Icons.upload_file),
                          ),
                          ButtonSegment<ContentType>(
                            value: ContentType.imageFile,
                            label: Text('Upload Image'),
                            icon: Icon(Icons.image),
                          ),
                        ],
                        selected: {_selectedContentType},
                        onSelectionChanged: (Set<ContentType> selected) {
                          setState(() {
                            _selectedContentType = selected.first;
                            _fileErrorText = null;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Content Input based on selected type
                      _buildContentInput(),
                    ],

                    const SizedBox(height: 32), // Save Button
                    AppButton(
                      label: isEditing ? 'Update' : 'Save',
                      onPressed: _saveStudyMaterial,
                      isLoading: _isLoading || isCreatingMaterial,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
    );
  }

  AppBar _buildAppBar() {
    final state = ref.watch(studyMaterialViewModelProvider);
    final isCreatingMaterial = state.isCreating;

    return AppBar(
      title: Text(
        widget.material == null ? 'Add Study Material' : 'Edit Study Material',
      ),
      backgroundColor: AppColors.athenaPurple,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // Safe navigation back - check if we can pop, otherwise go to materials
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(AppRouteNames.materials);
          }
        },
      ),
      actions: [
        if (!_isLoading && !isCreatingMaterial)
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveStudyMaterial,
            tooltip: 'Save',
          ),
      ],
    );
  }

  Widget _buildContentInput() {
    switch (_selectedContentType) {
      case ContentType.typedText:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Notes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.athenaDarkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _buildQuillEditor(),
            ),
            if (_fileErrorText != null) ...[
              const SizedBox(height: 8),
              Text(_fileErrorText!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        );

      case ContentType.textFile:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppButton(
              label: 'Select Text File (.pdf, .docx, etc.)',
              onPressed: _pickTextFile,
              icon: const Icon(Icons.upload_file),
              backgroundColor: AppColors.secondary,
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFile!.path.split('/').last,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
            if (_fileErrorText != null) ...[
              const SizedBox(height: 8),
              Text(_fileErrorText!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        );
      case ContentType.imageFile:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _selectedImage == null
                ? _buildImagePickerArea()
                : _buildSelectedImagePreview(),
            if (_fileErrorText != null) ...[
              const SizedBox(height: 8),
              Text(_fileErrorText!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        );
    }
  }

  Widget _buildQuillEditor() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QuillSimpleToolbar(
          controller: _quillController,
          config: QuillSimpleToolbarConfig(
            // Only show essential buttons for mobile
            multiRowsDisplay: false,
            showFontFamily: false,
            showFontSize: false,
            showBoldButton: true,
            showItalicButton: true,
            showUnderLineButton: true,
            showStrikeThrough: false,
            showInlineCode: true,
            showColorButton: true,
            showBackgroundColorButton: false,
            showClearFormat: true,
            showAlignmentButtons: false,
            showLeftAlignment: false,
            showCenterAlignment: false,
            showRightAlignment: false,
            showJustifyAlignment: false,
            showHeaderStyle: true,
            showListNumbers: true,
            showListBullets: true,
            showListCheck: false,
            showCodeBlock: false,
            showQuote: true,
            showIndent: false,
            showLink: true,
            showUndo: true,
            showRedo: true,
            showClipboardPaste: true,
            showDividers: true,
            buttonOptions: QuillSimpleToolbarButtonOptions(
              base: QuillToolbarBaseButtonOptions(
                afterButtonPressed: () {
                  final isDesktop = {
                    TargetPlatform.linux,
                    TargetPlatform.windows,
                    TargetPlatform.macOS,
                  }.contains(defaultTargetPlatform);
                  if (isDesktop) {
                    _quillFocusNode.requestFocus();
                  }
                },
              ),
              linkStyle: QuillToolbarLinkStyleButtonOptions(
                validateLink: (link) {
                  return true;
                },
              ),
            ),
          ),
        ),
        // Use a SizedBox with fixed height instead of Expanded
        SizedBox(
          height: 250, // Specify a fixed height for the editor
          child: QuillEditor(
            focusNode: _quillFocusNode,
            scrollController: _quillScrollController,
            controller: _quillController,
            config: QuillEditorConfig(
              placeholder: 'Enter your study notes here...',
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerArea() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                size: 40,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to select an image from camera or gallery',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImagePreview() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap:
                    () => setState(() {
                      _selectedImage = null;
                      _extractedImageText = null;
                      _imageTextController?.dispose();
                      _imageTextController = null;
                    }),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Change'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.secondary),
                  foregroundColor: AppColors.secondary,
                  minimumSize: const Size(
                    0,
                    44,
                  ), // Fixed height for both buttons
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_selectedImage != null) {
                    _processImageWithOCR(_selectedImage!);
                  }
                },
                icon: const Icon(Icons.text_fields, size: 18),
                label: const Text('Extract Text'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.athenaPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(
                    0,
                    44,
                  ), // Fixed height for both buttons
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ),

        // Display extracted text section if available
        if (_extractedImageText != null) ...[
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.text_fields,
                    size: 16,
                    color: AppColors.athenaPurple,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Extracted Text',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.athenaDarkGrey,
                    ),
                  ),
                  const Spacer(),
                  // Remove button
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _extractedImageText = null;
                        _imageTextController?.dispose();
                        _imageTextController = null;
                      });
                    },
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Remove'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: const Size(0, 32),
                    ),
                  ), // Edit button for text
                  TextButton.icon(
                    onPressed:
                        _extractedImageText != null ? _editExtractedText : null,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _extractedImageText!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
  Future<void> _editExtractedText() async {
    if (_extractedImageText == null) return;

    // Use the OCR utility to show the edit dialog
    final editedText = await OcrUtils.showEditTextDialog(
      context, 
      _extractedImageText!
    );

    // Update main state if user saved changes
    // We need to make sure we're still mounted before updating the state
    if (editedText != null && mounted) {
      setState(() {
        _extractedImageText = editedText;

        // Always dispose the old controller first to prevent memory leaks
        if (_imageTextController != null) {
          _imageTextController!.dispose();
          _imageTextController = null; // Set to null after disposing
        }

        // Only then create a new controller with the edited text
        if (mounted) {
          _imageTextController = TextEditingController(text: editedText);
        }
      });
    }
  }
}
