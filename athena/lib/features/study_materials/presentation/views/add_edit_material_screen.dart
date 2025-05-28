import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/shared/widgets/app_button.dart';
import 'package:athena/features/shared/widgets/app_text_field.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/presentation/providers/study_material_providers.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class AddEditMaterialScreen extends ConsumerStatefulWidget {
  final StudyMaterialEntity? material; // Null when adding new, non-null when editing
  final ContentType? initialContentType; // Optional initial content type for new materials
  final File? capturedImage; // Optional pre-captured image

  const AddEditMaterialScreen({
    Key? key,
    this.material,
    this.initialContentType,
    this.capturedImage,
  }) : super(key: key);

  @override
  ConsumerState<AddEditMaterialScreen> createState() => _AddEditMaterialScreenState();
}

class _AddEditMaterialScreenState extends ConsumerState<AddEditMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  
  // Quill editor controller for rich text
  late QuillController _quillController;
  final _quillFocusNode = FocusNode();
  final ScrollController _quillScrollController = ScrollController();
  
  late ContentType _selectedContentType;
  File? _selectedFile;
  File? _selectedImage;
  bool _isLoading = false;
  String? _fileErrorText;
  @override
  void initState() {
    super.initState();
    // Initialize QuillController with empty document
    _quillController = QuillController.basic();
    
    // Initialize content type
    _selectedContentType = widget.initialContentType ?? ContentType.typedText;
    
    // Set captured image if provided
    if (widget.capturedImage != null) {
      _selectedImage = widget.capturedImage;
      // Process the image with OCR after a short delay to let the UI render
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _selectedImage != null) {
          _processImageWithOCR(_selectedImage!);
        }
      });
    }
    
    // Initialize with existing data if editing
    if (widget.material != null) {
      _titleController.text = widget.material!.title;      // Set the subject if available
      final subject = widget.material!.subject;
      if (subject.isNotEmpty) {
        _subjectController.text = subject;
      }
      _selectedContentType = widget.material!.contentType as ContentType;
      
      // If typed text, populate the content
      if (_selectedContentType == ContentType.typedText && 
          widget.material!.originalContentText != null) {
        // For regular text content
        _contentController.text = widget.material!.originalContentText!;
        
        // For rich text content (if it's stored as JSON)
        try {
          final dynamic jsonData = json.decode(widget.material!.originalContentText!);
          _quillController = QuillController(
            document: Document.fromJson(jsonData),
            selection: const TextSelection.collapsed(offset: 0),
          );
        } catch (e) {
          // If not valid JSON, create a document from plain text
          final document = Document()..insert(0, widget.material!.originalContentText!);
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
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _quillController.dispose();
    _quillFocusNode.dispose();
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
                      Navigator.pop(context);
                      await _getImageFromSource(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(context);
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
    required VoidCallback onTap
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
            child: Icon(
              icon,
              size: 36,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }  Future<void> _getImageFromSource(ImageSource source) async {
    setState(() {
      _selectedImage = null;
      _fileErrorText = null;
    });    try {
      final ImagePicker picker = ImagePicker();
      
      // Use more reasonable image quality/size parameters to prevent large files
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        // Lower quality for better performance and memory usage
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear, // Use rear camera by default for better quality
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
            _fileErrorText = 'Image too large (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB, max 10MB)';
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
  }  Future<CroppedFile?> _cropImage(String sourcePath) async {
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
          IOSUiSettings(
            title: 'Crop Image',
          ),
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
    
    // Check if file exists to avoid crashes
    if (!await imageFile.exists()) {
      print('Image file does not exist for OCR');
      return;
    }
    
    try {
      // Show a loading indicator
      setState(() {
        _isLoading = true;
      });
      
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer();
      String extractedText = '';
      
      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        extractedText = recognizedText.text;
      } catch (e) {
        print('Error recognizing text: $e');
      } finally {
        textRecognizer.close();
        
        // Hide loading indicator regardless of success/failure
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
      
      // If we have text and the widget is still mounted
      if (extractedText.isNotEmpty && mounted) {
        // Show a dialogue asking if they want to use the extracted text
        bool? useExtractedText = await showDialog<bool>(
          context: context,
          barrierDismissible: true, // Allow tapping outside to dismiss
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Text Detected'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('The following text was detected:'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        extractedText.length > 300 
                            ? '${extractedText.substring(0, 300)}...' 
                            : extractedText,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Keep as Image'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Use Extracted Text'),
                ),
              ],
            );
          },
        );
        
        // If user chooses to use the extracted text
        if (useExtractedText == true && mounted) {
          setState(() {
            _selectedContentType = ContentType.typedText;
            _selectedImage = null;
            
            // Convert plain text to Document for QuillController
            final document = Document()..insert(0, extractedText);
            _quillController = QuillController(
              document: document,
              selection: const TextSelection.collapsed(offset: 0),
            );
          });
        }
      }
    } catch (e) {
      print('Error in OCR processing: $e');
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
    });

    try {
      //final viewModel = ref.read(studyMaterialViewModelProvider.notifier);

      if (widget.material == null) {
        // Adding new material
        switch (_selectedContentType) {
          case ContentType.typedText:            // await viewModel.addTypedText(
            //   title: _titleController.text,
            //   subject: _subjectController.text.isEmpty ? null : _subjectController.text,
            //   content: jsonEncode(_quillController.document.toDelta().toJson()),
            // );
            break;
          case ContentType.textFile:
            if (_selectedFile != null) {
              // await viewModel.addTextFile(
              //   title: _titleController.text,
              //   subject: _subjectController.text.isEmpty ? null : _subjectController.text,
              //   file: _selectedFile!,
              // );
            }
            break;
          case ContentType.imageFile:
            if (_selectedImage != null) {
              // await viewModel.addImageNote(
              //   title: _titleController.text,
              //   subject: _subjectController.text.isEmpty ? null : _subjectController.text,
              //   image: _selectedImage!,
              // );
            }
            break;
        }
      } else {
        // Editing existing material
        // For CW2, we'll just update metadata (title and subject)
        // await viewModel.updateStudyMaterial(
        //   id: widget.material!.id,
        //   title: _titleController.text,
        //   subject: _subjectController.text.isEmpty ? null : _subjectController.text,
        // );
      }

      if (mounted) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Study material saved successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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

  bool _isContentRequired() {
    return _selectedContentType == ContentType.typedText && 
           widget.material == null;
  }
  bool _isContentProvided() {
    switch (_selectedContentType) {
      case ContentType.typedText:
        return !_quillController.document.isEmpty();
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
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
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
                  const SizedBox(height: 16),

                  // Subject Field (Optional)
                  AppTextField(
                    controller: _subjectController,
                    labelText: 'Subject (Optional)',
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
                  
                  const SizedBox(height: 32),
                  
                  // Save Button
                  AppButton(
                    label: isEditing ? 'Update' : 'Save',
                    onPressed: _saveStudyMaterial,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.material == null ? 'Add Study Material' : 'Edit Study Material'),
      actions: [
        if (!_isLoading)
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
              Text(
                _fileErrorText!,
                style: const TextStyle(color: Colors.red),
              ),
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
              Text(
                _fileErrorText!,
                style: const TextStyle(color: Colors.red),
              ),
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
              Text(
                _fileErrorText!,
                style: const TextStyle(color: Colors.red),
              ),            ],
          ],
        );
    }
  }  Widget _buildQuillEditor() {
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
                    TargetPlatform.macOS
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to select an image from camera or gallery',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
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
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => setState(() => _selectedImage = null),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
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
        ),        const SizedBox(height: 16),
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
                  minimumSize: const Size(0, 44), // Fixed height for both buttons
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
                  minimumSize: const Size(0, 44), // Fixed height for both buttons
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
