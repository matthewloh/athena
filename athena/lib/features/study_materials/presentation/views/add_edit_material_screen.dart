import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:athena/domain/enums/subject.dart';
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
import 'package:athena/features/shared/widgets/subject_searchable_dropdown.dart';
import 'package:athena/features/study_materials/presentation/utils/ocr_utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:go_router/go_router.dart';

class AddEditMaterialScreen extends ConsumerStatefulWidget {
  final String? materialId; // Null when adding new, non-null when editing
  final ContentType?
  initialContentType; // Optional initial content type for new materials

  const AddEditMaterialScreen({
    super.key,
    this.materialId,
    this.initialContentType,
  });

  @override
  ConsumerState<AddEditMaterialScreen> createState() =>
      _AddEditMaterialScreenState();
}

class _AddEditMaterialScreenState extends ConsumerState<AddEditMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  // Material loading state
  bool _isLoadingMaterial = false;
  StudyMaterialEntity? _loadedMaterial;

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

  // Track if user has selected new files in edit mode
  bool _hasSelectedNewFile = false;
  bool _hasSelectedNewImage = false;

  @override
  void initState() {
    super.initState();
    // Initialize QuillController with empty document
    _quillController = QuillController.basic();

    // Initialize content type - will be updated if we're editing
    _selectedContentType = widget.initialContentType ?? ContentType.typedText;

    // If we have materialId, it means we're in edit mode - load material
    if (widget.materialId != null) {
      // Use a post-frame callback to ensure the widget tree is built first
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadMaterialData(widget.materialId!);
        }
      });
    }
  }

  // Load material data by ID from the viewmodel
  Future<void> _loadMaterialData(String materialId) async {
    if (!mounted) return;

    setState(() {
      _isLoadingMaterial = true;
    });

    try {
      // Get the viewmodel and load the material
      final viewModel = ref.read(studyMaterialViewModelProvider.notifier);

      // Load material using the viewmodel - this operation modifies the provider state
      await viewModel.loadMaterial(materialId);

      if (!mounted) return;

      // Now it's safe to read the updated state
      final state = ref.read(studyMaterialViewModelProvider);
      final material = state.selectedMaterial;

      if (material != null && mounted) {
        // Update UI in a setState call to ensure proper rebuilding
        setState(() {
          // Store loaded material
          _loadedMaterial = material;

          // Reset selection flags when loading existing material
          _hasSelectedNewFile = false;
          _hasSelectedNewImage = false;

          // Populate form fields
          _titleController.text = material.title;
          _selectedSubject = material.subject;
          _descriptionController.text =
              material.description ?? ''; // Handle null description
          _selectedContentType =
              material.contentType; // Handle different content types
          if (_selectedContentType == ContentType.typedText &&
              material.originalContentText != null) {
            // For regular text content
            _contentController.text = material.originalContentText!;

            // Try to parse as rich text JSON
            try {
              final dynamic jsonData = json.decode(
                material.originalContentText!,
              );
              _quillController = QuillController(
                document: Document.fromJson(jsonData),
                selection: const TextSelection.collapsed(offset: 0),
              );
            } catch (e) {
              // If not valid JSON, create a document from plain text
              final document =
                  Document()..insert(0, material.originalContentText!);
              _quillController = QuillController(
                document: document,
                selection: const TextSelection.collapsed(offset: 0),
              );
            }
          } // Handle image file content type
          else if (_selectedContentType == ContentType.imageFile) {
            // If we have a stored file path, store it for later use
            if (material.fileStoragePath != null &&
                material.fileStoragePath!.isNotEmpty) {
              final bool isSupabaseImage = material.fileStoragePath!.contains(
                'supabase.co',
              );

              debugPrint(
                'Image path stored: ${material.fileStoragePath}, isSupabaseImage: $isSupabaseImage',
              );

              // Only create a File reference if it's a local file that exists
              if (!isSupabaseImage) {
                try {
                  final file = File(material.fileStoragePath!);
                  if (file.existsSync()) {
                    _selectedImage = file;
                    debugPrint('Local image file loaded successfully');
                  }
                } catch (e) {
                  debugPrint('Error loading local image file: $e');
                }
              }
            }

            // If there's extracted OCR text, populate it
            if (material.ocrExtractedText != null &&
                material.ocrExtractedText!.isNotEmpty) {
              _extractedImageText = material.ocrExtractedText;
              _imageTextController = TextEditingController(
                text: _extractedImageText,
              );
              debugPrint(
                'OCR text loaded: ${_extractedImageText!.substring(0, min(50, _extractedImageText!.length))}...',
              );
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading material: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMaterial = false;
        });
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
        _hasSelectedNewFile = true; // Mark that user selected a new file
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
              color: AppColors.secondary.withValues(alpha: 0.1),
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
        } // Set the image immediately to avoid blank screen if cropping fails
        setState(() {
          _selectedImage = imageFile;
          _hasSelectedNewImage = true; // Mark that user selected a new image
          // Clear any previous error
          _fileErrorText = null;
        });

        // Now try to crop the image if possible, but don't block the UI
        try {
          // Attempt to crop but don't wait for it in the main flow
          final croppedFile = await _cropImage(image.path);

          // If cropping was successful, update the image
          if (croppedFile != null) {
            final File croppedImageFile = File(
              croppedFile.path,
            ); // Update the image if we're still in image mode
            if (mounted && _selectedContentType == ContentType.imageFile) {
              setState(() {
                _selectedImage = croppedImageFile;
                // Keep the flag as true since this is still a new image
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
          extractedText,
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
            _imageTextController = TextEditingController(
              text: extractedText ?? '',
            );
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

      if (widget.materialId == null) {
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
              widget.materialId == null
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
            content: Text('Error: ${_fileErrorText ?? 'Unknown error'}'),
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
    if (widget.materialId == null || _loadedMaterial == null) return;

    // For editing, we'll update metadata and content based on content type
    String? updatedContent;
    String? newFilePath;

    switch (_selectedContentType) {
      case ContentType.typedText:
        // Convert Quill document to JSON string for storage
        final documentJson = _quillController.document.toDelta().toJson();
        updatedContent = json.encode(documentJson);
        break;
      case ContentType.textFile:
        // Only include the file path if user has selected a new file
        if (_selectedFile != null && _hasSelectedNewFile) {
          debugPrint('Using new text file: ${_selectedFile!.path}');
          newFilePath = _selectedFile!.path;

          // For text files, try to read the content if possible
          try {
            final extension = newFilePath.split('.').last.toLowerCase();
            if (extension == 'txt' || extension == 'md') {
              updatedContent = await _selectedFile!.readAsString();
            } else {
              // For other files (PDF, DOCX), store filename info
              updatedContent =
                  'File uploaded: ${_selectedFile!.path.split(Platform.isWindows ? '\\' : '/').last}';
            }
          } catch (e) {
            debugPrint('Could not read file content: $e');
            // If reading fails, at least store file information
            updatedContent =
                'File uploaded: ${_selectedFile!.path.split(Platform.isWindows ? '\\' : '/').last}';
          }
        } else {
          debugPrint('No new text file selected, keeping original');
        }
        break;
      case ContentType.imageFile:
        // Only include the image path if user has selected a new image
        if (_selectedImage != null && _hasSelectedNewImage) {
          debugPrint('Using new image: ${_selectedImage!.path}');
          newFilePath = _selectedImage!.path;
        } else {
          debugPrint('No new image selected, keeping original');
        }
        break;
    }
    final params = UpdateStudyMaterialParams(
      id: _loadedMaterial!.id,
      title: _titleController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      subject: _selectedSubject,
      originalContentText: updatedContent,
      // Only include file path if a new file was actually selected
      fileStoragePath: newFilePath, // This will be null if no new file
      // Preserve the OCR text if it was modified
      ocrExtractedText: _extractedImageText,
    );

    debugPrint('Updating material with newFilePath: $newFilePath');
    await viewModel.updateMaterial(params);
  }

  bool _isContentRequired() {
    // Content is always required, even in edit mode
    // The difference is in edit mode we might already have content
    return true;
  }

  bool _isContentProvided() {
    final bool isEditing = widget.materialId != null;

    switch (_selectedContentType) {
      case ContentType.typedText:
        // Check if Quill document has actual content
        final text = _quillController.document.toPlainText().trim();
        return text.isNotEmpty;

      case ContentType.textFile:
        // In edit mode, we either need the original file or a new selection
        if (isEditing) {
          return _selectedFile != null ||
              (_loadedMaterial?.fileStoragePath != null &&
                  _loadedMaterial!.fileStoragePath!.isNotEmpty);
        }
        // In create mode, we need a new file selection
        return _selectedFile != null;

      case ContentType.imageFile:
        // In edit mode, we either need the original image or a new selection
        if (isEditing) {
          return _selectedImage != null ||
              (_loadedMaterial?.fileStoragePath != null &&
                  _loadedMaterial!.fileStoragePath!.isNotEmpty);
        }
        // In create mode, we need a new image selection
        return _selectedImage != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add debug print to check _loadedMaterial
    if (widget.materialId != null &&
        _loadedMaterial != null &&
        _selectedContentType == ContentType.imageFile) {
      debugPrint(
        'Build with image material: ${_loadedMaterial?.fileStoragePath}',
      );
      debugPrint(
        '_selectedImage is ${_selectedImage != null ? 'not null' : 'null'}',
      );
      debugPrint(
        'Is Supabase image: ${_loadedMaterial?.fileStoragePath?.contains('supabase.co')}',
      );
    }

    final isEditing = widget.materialId != null;
    final appTheme = Theme.of(
      context,
    ); // Watch for errors and material updates from the viewmodel
    ref.listen<StudyMaterialState>(studyMaterialViewModelProvider, (
      previous,
      current,
    ) {
      // Handle error messages
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

      // Check for material updates when in edit mode and not already loading
      if (widget.materialId != null &&
          !_isLoadingMaterial &&
          current.selectedMaterial != null &&
          current.selectedMaterialId == widget.materialId &&
          _loadedMaterial?.id != current.selectedMaterial?.id) {
        // Update the loaded material with the freshly loaded one
        final material = current.selectedMaterial!;
        setState(() {
          _loadedMaterial = material;
          _isLoadingMaterial = false;

          // Populate form fields again with the latest data
          _titleController.text = material.title;
          _selectedSubject = material.subject;
          _selectedContentType = material.contentType;

          // Handle different content types
          if (_selectedContentType == ContentType.typedText &&
              material.originalContentText != null) {
            // Update content controllers
            _contentController.text = material.originalContentText!;

            // Update Quill editor
            try {
              final dynamic jsonData = json.decode(
                material.originalContentText!,
              );
              _quillController = QuillController(
                document: Document.fromJson(jsonData),
                selection: const TextSelection.collapsed(offset: 0),
              );
            } catch (e) {
              final document =
                  Document()..insert(0, material.originalContentText!);
              _quillController = QuillController(
                document: document,
                selection: const TextSelection.collapsed(offset: 0),
              );
            }
          }
        });
      }
    });
    final state = ref.watch(studyMaterialViewModelProvider);
    final isCreatingMaterial = state.isCreating;
    return Scaffold(
      appBar: _buildAppBar(),
      body:
          (_isLoading ||
                  isCreatingMaterial ||
                  _isLoadingMaterial ||
                  state.isLoadingMaterial)
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
                    const SizedBox(
                      height: 24,
                    ), // Content Type Selection - Only shown in create mode
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
                    ], // Content type indicator for edit mode
                    if (isEditing) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            _selectedContentType == ContentType.typedText
                                ? Icons.edit_note
                                : _selectedContentType == ContentType.textFile
                                ? Icons.description
                                : Icons.image,
                            size: 20,
                            color: AppColors.athenaPurple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Content Type: ${_selectedContentType == ContentType.typedText
                                ? 'Rich Text'
                                : _selectedContentType == ContentType.textFile
                                ? 'Text File'
                                : 'Image'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.athenaDarkGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Content Input is ALWAYS shown, for both create and edit modes
                    _buildContentInput(),

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
        widget.materialId == null
            ? 'Add Study Material'
            : 'Edit Study Material',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Study Notes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.athenaDarkGrey,
                  ),
                ),
                // Add a hint text that this is editable
                if (widget.materialId != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit content',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
              ],
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
        final bool isEditing = widget.materialId != null;

        // Extract original filename more reliably with cross-platform path handling
        String? originalFileName;
        if (isEditing && _loadedMaterial?.fileStoragePath != null) {
          final String path = _loadedMaterial!.fileStoragePath!;

          if (path.contains('supabase.co')) {
            // If it's a URL, extract the filename from the last part
            final segments = path.split('/');
            final fullName = segments.last;

            // Extract meaningful name by removing UUID prefixes if present (typical pattern)
            final parts = fullName.split('_');
            originalFileName =
                parts.length > 1 ? parts.sublist(1).join('_') : fullName;
          } else {
            // For local file paths, handle both Windows and UNIX paths
            final segments = path.split(Platform.isWindows ? '\\' : '/');
            originalFileName = segments.last;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show original file name if in edit mode
            if (isEditing && originalFileName != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.athenaPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.file_present_rounded,
                          color: AppColors.athenaPurple,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Current File',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.athenaDarkGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.description, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              originalFileName
                                  .split('/')
                                  .last
                                  .split('_')
                                  .sublist(1)
                                  .join('_'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            AppButton(
              label:
                  isEditing
                      ? 'Change File'
                      : 'Select Text File (.pdf, .docx, etc.)',
              onPressed: _pickTextFile,
              icon: Icon(
                isEditing ? Icons.change_circle_outlined : Icons.upload_file,
              ),
              backgroundColor: isEditing ? Colors.white : AppColors.secondary,
              textColor: isEditing ? AppColors.secondary : Colors.white,
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
                        _selectedFile!.path
                            .split(Platform.isWindows ? '\\' : '/')
                            .last,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                          _hasSelectedNewFile =
                              false; // Reset flag when removing file
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
        final bool isEditing = widget.materialId != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isEditing)
              // Header for Image content section
              Container(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      size: 20,
                      color: AppColors.athenaDarkGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Image Content',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.athenaDarkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            // In edit mode OR if we have a local image, use appropriate display
            _selectedImage != null
                ? _buildSelectedImagePreview()
                : _buildImagePickerArea(), // OCR text section in edit mode when we have an image but no extracted text
            if (isEditing &&
                _extractedImageText == null &&
                _selectedImage != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.text_fields, color: AppColors.athenaPurple),
                        SizedBox(width: 8),
                        Text(
                          'No OCR Text Available',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_selectedImage != null) {
                          _processImageWithOCR(_selectedImage!);
                        }
                      },
                      icon: const Icon(Icons.text_fields, size: 18),
                      label: const Text('Extract Text from Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.athenaPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Always show OCR text in edit mode if it exists, regardless of image availability
            if (isEditing && _extractedImageText != null) ...[
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced header for OCR text section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.athenaPurple.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      border: Border.all(
                        color: AppColors.athenaPurple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.text_fields,
                          size: 20,
                          color: AppColors.athenaPurple,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'OCR Extracted Text',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.athenaPurple,
                          ),
                        ),
                        const Spacer(),
                        // Help icon with tooltip
                        Tooltip(
                          message:
                              'Text automatically extracted from image. You can edit it for better accuracy.',
                          child: const Icon(
                            Icons.help_outline,
                            size: 16,
                            color: AppColors.athenaDarkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons with more prominence
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border(
                        left: BorderSide(
                          color: AppColors.athenaPurple.withValues(alpha: 0.3),
                        ),
                        right: BorderSide(
                          color: AppColors.athenaPurple.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Edit button - more compact and subtle
                        TextButton.icon(
                          onPressed: _editExtractedText,
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text(
                            'Edit',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: const Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Remove button - more compact and subtle
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _extractedImageText = null;
                              _imageTextController?.dispose();
                              _imageTextController = null;
                            });
                          },
                          icon: const Icon(Icons.delete_outline, size: 14),
                          label: const Text(
                            'Remove',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: const Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text display with animation and better interaction cues
                  GestureDetector(
                    onTap: _editExtractedText,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        minHeight: 100,
                        maxHeight: 300,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                        border: Border.all(
                          color: AppColors.athenaPurple.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Scrollable text content
                          SingleChildScrollView(
                            child: Text(
                              _extractedImageText!,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),

                          // Edit indicator overlay
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tap to Edit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Help text to guide users
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'OCR text might not be 100% accurate. Tap on the text to make corrections.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            if (_fileErrorText != null) ...[
              const SizedBox(height: 8),
              Text(_fileErrorText!, style: const TextStyle(color: Colors.red)),
            ],

            // In edit mode, if there's no OCR text but we're in image mode, add an option to extract new text
            if (isEditing &&
                _extractedImageText == null &&
                _selectedImage == null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add a new image to extract text'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                ),
              ),
            ],
          ],
        );
    }
  }

  Widget _buildQuillEditor() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Editor header with edit indicator
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.athenaPurple.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.edit_note,
                color: AppColors.athenaPurple,
                size: 20,
              ),
              const SizedBox(width: 6),
              const Text(
                'Rich Text Editor',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.athenaPurple,
                ),
              ),
              const Spacer(),
              // Help text for new users
              Text(
                'Format your notes here',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),

        // Toolbar with improved visibility
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.symmetric(
              horizontal: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: QuillSimpleToolbar(
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
        ),

        // Editor with animation and highlights to make it more interactive
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 300, // Increased height for better editing experience
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  _quillFocusNode.hasFocus
                      ? AppColors.secondary
                      : Colors.grey.shade300,
              width: _quillFocusNode.hasFocus ? 2.0 : 1.0,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
            color: Colors.white,
            boxShadow:
                _quillFocusNode.hasFocus
                    ? [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                    : [],
          ),
          child: Stack(
            children: [
              // Editor
              QuillEditor(
                focusNode: _quillFocusNode,
                scrollController: _quillScrollController,
                controller: _quillController,
                config: QuillEditorConfig(
                  placeholder: 'Tap here to edit your study notes...',
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),

        // Helper text to guide users
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text(
            'Use the formatting tools above to customize your notes',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerArea() {
    final bool isEditing = widget.materialId != null;
    final bool hasOriginalImage =
        isEditing &&
        _loadedMaterial?.fileStoragePath != null &&
        _loadedMaterial!.fileStoragePath!.isNotEmpty;

    // For Supabase stored images, the fileStoragePath is just the path within the bucket
    // not a full URL, so we need a different check
    final bool isSupabaseImage =
        hasOriginalImage &&
        !_loadedMaterial!.fileStoragePath!.startsWith('/') &&
        !File(_loadedMaterial!.fileStoragePath!).existsSync();

    // Debug prints to help diagnose issues
    if (isEditing) {
      debugPrint(
        '_buildImagePickerArea - hasOriginalImage: $hasOriginalImage, isSupabaseImage: $isSupabaseImage',
      );
      debugPrint(
        '_buildImagePickerArea - filePath: ${_loadedMaterial?.fileStoragePath}',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display original image if in edit mode and available from Supabase
        if (hasOriginalImage && isSupabaseImage) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.athenaPurple.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.image_rounded,
                      color: AppColors.athenaPurple,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Current Image',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.athenaDarkGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Image container with border and shadow
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    // Use a FutureBuilder to load the Supabase image
                    child: FutureBuilder<String>(
                      // Get a temporary signed URL for the image from Supabase
                      future: _getSupabaseImageUrl(
                        _loadedMaterial!.fileStoragePath!,
                      ),
                      builder: (context, snapshot) {
                        debugPrint(
                          'FutureBuilder state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, error: ${snapshot.error}',
                        );

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppColors.athenaPurple,
                                ),
                                const SizedBox(height: 16),
                                const Text('Loading image...'),
                              ],
                            ),
                          );
                        }

                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Could not load image',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                if (snapshot.hasError) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '${snapshot.error}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          );
                        }

                        debugPrint('Image URL: ${snapshot.data!}');
                        return Image.network(
                          snapshot.data!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    strokeWidth: 3,
                                    color: AppColors.athenaPurple,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    loadingProgress.expectedTotalBytes != null
                                        ? '${((loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100).toStringAsFixed(0)}%'
                                        : 'Loading...',
                                  ),
                                ],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('Image error: $error');
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Error loading image',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // The image picker area
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 160, // Reduced height when showing with original image
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isEditing
                        ? AppColors.secondary.withValues(alpha: 0.5)
                        : Colors.grey.shade300,
                width: isEditing ? 2 : 1.5,
              ),
              boxShadow:
                  isEditing
                      ? [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isEditing
                            ? AppColors.secondary.withValues(alpha: 0.2)
                            : AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEditing
                        ? Icons.change_circle_outlined
                        : Icons.add_photo_alternate_rounded,
                    size: 36,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isEditing ? 'Change Image' : 'Add Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isEditing ? AppColors.secondary : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select from camera or gallery',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to get a temporary public URL for an image from Supabase
  Future<String> _getSupabaseImageUrl(String storagePath) async {
    debugPrint('Getting Supabase URL for: $storagePath');

    if (storagePath.isEmpty) {
      debugPrint('Empty storage path');
      return '';
    }

    try {
      final viewModel = ref.read(studyMaterialViewModelProvider.notifier);
      final url = await viewModel.getSignedDownloadUrl(storagePath);

      if (url == null || url.isEmpty) {
        debugPrint('Received empty URL from getSignedDownloadUrl');
        return '';
      }

      debugPrint('Successfully got Supabase URL: $url');
      return url;
    } catch (e) {
      debugPrint('Error getting Supabase image URL: $e');
      if (e is Error) {
        debugPrint('Stack trace: ${e.stackTrace}');
      }
      return '';
    }
  }

  Widget _buildSelectedImagePreview() {
    final bool isEditing = widget.materialId != null;
    final bool isNewImage =
        isEditing &&
        _loadedMaterial?.fileStoragePath != null &&
        !_selectedImage!.path.contains('supabase.co') &&
        _loadedMaterial?.fileStoragePath != _selectedImage?.path;

    return Column(
      children: [
        // Image change indicator - improved visibility
        if (isEditing) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color:
                  isNewImage
                      ? AppColors.secondary.withValues(alpha: 0.1)
                      : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: Border.all(
                color:
                    isNewImage
                        ? AppColors.secondary.withValues(alpha: 0.5)
                        : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isNewImage
                      ? Icons.change_circle_outlined
                      : Icons.check_circle_outline,
                  size: 18,
                  color: isNewImage ? AppColors.secondary : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isNewImage
                        ? 'New image selected - will replace original'
                        : 'Current image from study material',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isNewImage ? FontWeight.w500 : FontWeight.normal,
                      color:
                          isNewImage
                              ? AppColors.secondary
                              : Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Image preview with improved styling
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                isEditing
                    ? const BorderRadius.vertical(bottom: Radius.circular(12))
                    : BorderRadius.circular(12),
            border: Border.all(
              color:
                  isEditing && isNewImage
                      ? AppColors.secondary.withValues(alpha: 0.5)
                      : Colors.grey.shade300,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Image container
              ClipRRect(
                borderRadius:
                    isEditing
                        ? const BorderRadius.vertical(
                          bottom: Radius.circular(0),
                        )
                        : BorderRadius.circular(12),
                child: SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image with error handling
                      Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Unable to load image',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Remove button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap:
                              () => setState(() {
                                _selectedImage = null;
                                _hasSelectedNewImage =
                                    false; // Reset flag when removing image
                                // Only clear extracted text if we're in create mode
                                // In edit mode, keep existing OCR text unless explicitly removed
                                if (!isEditing) {
                                  _extractedImageText = null;
                                  _imageTextController?.dispose();
                                  _imageTextController = null;
                                }
                              }),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons directly under the image
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Change Image'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.secondary),
                          foregroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
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
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ), // Display extracted text section if available and NOT in edit mode
        // (since we're already handling it in the main build method for edit mode)
        if (_extractedImageText != null && widget.materialId == null) ...[
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced header for OCR text section
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.athenaPurple.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  border: Border.all(
                    color: AppColors.athenaPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.text_fields,
                      size: 20,
                      color: AppColors.athenaPurple,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'OCR Extracted Text',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.athenaPurple,
                      ),
                    ),
                    const Spacer(),
                    // Help icon with tooltip
                    Tooltip(
                      message:
                          'Text automatically extracted from image. You can edit it for better accuracy.',
                      child: const Icon(
                        Icons.help_outline,
                        size: 16,
                        color: AppColors.athenaDarkGrey,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons with more prominence
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(
                    left: BorderSide(
                      color: AppColors.athenaPurple.withValues(alpha: 0.3),
                    ),
                    right: BorderSide(
                      color: AppColors.athenaPurple.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Edit button - more compact and subtle
                    TextButton.icon(
                      onPressed: _editExtractedText,
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text('Edit', style: TextStyle(fontSize: 13)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Remove button - more compact and subtle
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _extractedImageText = null;
                          _imageTextController?.dispose();
                          _imageTextController = null;
                        });
                      },
                      icon: const Icon(Icons.delete_outline, size: 14),
                      label: const Text(
                        'Remove',
                        style: TextStyle(fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              // Text display with animation and better interaction cues
              GestureDetector(
                onTap: _editExtractedText,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    minHeight: 100,
                    maxHeight: 300,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    border: Border.all(
                      color: AppColors.athenaPurple.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Scrollable text content
                      SingleChildScrollView(
                        child: Text(
                          _extractedImageText!,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),

                      // Edit indicator overlay
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Tap to Edit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Help text to guide users
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'OCR text might not be 100% accurate. Tap on the text to make corrections.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
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

    // Show a brief toast to indicate editing mode
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit the OCR text for better accuracy'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Use the OCR utility to display the edit dialog
    final editedText = await OcrUtils.showEditTextDialog(
      context,
      _extractedImageText!,
    );

    // Update the state if user made changes
    if (editedText != null && mounted) {
      setState(() {
        _extractedImageText = editedText;

        // Dispose of old controller to prevent memory leaks
        if (_imageTextController != null) {
          _imageTextController!.dispose();
        }

        // Create new controller with updated text
        _imageTextController = TextEditingController(text: editedText);
      });

      // Confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text updated successfully'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
