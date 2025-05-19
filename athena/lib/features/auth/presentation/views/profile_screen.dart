import 'dart:typed_data';

import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _avatarUrl;
  final TextEditingController _fullNameController = TextEditingController();

  Future<void> _uploadAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );

    if (image == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Generate filename
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Read file as bytes (works on both web and mobile)
      final Uint8List bytes = await image.readAsBytes();

      // Upload bytes using uploadBinary (compatible with web)
      await supabase.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Get signed URL with long expiration instead of public URL
      final imageUrl = await supabase.storage
          .from('avatars')
          .createSignedUrl(fileName, 60 * 60 * 24 * 365); // 1 year expiration

      debugPrint('Image uploaded, URL: $imageUrl');

      // Update user profile with just the filename, not the full URL
      await supabase
          .from('profiles')
          .update({'avatar_url': fileName})
          .eq('id', user.id);

      setState(() {
        _avatarUrl = imageUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile photo updated!'),
            backgroundColor: AppColors.athenaSupportiveGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update profile photo. Please try again.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_errorMessage'),
            backgroundColor: AppColors.error,
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

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response =
          await supabase
              .from('profiles')
              .select('avatar_url, full_name')
              .eq('id', user.id)
              .single();

      final avatarUrl = response['avatar_url'] as String?;

      // If avatar URL exists, convert it to a signed URL
      String? signedAvatarUrl;
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        // Extract filename from the URL - assuming avatar_url stores the filename or full path
        final filePathComponents = avatarUrl.split('/');
        final fileName = filePathComponents.last;

        // Create a signed URL for the avatar
        try {
          signedAvatarUrl = await supabase.storage
              .from('avatars')
              .createSignedUrl(fileName, 60 * 60 * 24); // 1 day expiration
          debugPrint('Created signed URL: $signedAvatarUrl');
        } catch (e) {
          debugPrint('Error creating signed URL: $e');
        }
      }

      debugPrint(
        'Loaded profile with avatar URL: ${signedAvatarUrl ?? avatarUrl}',
      );

      setState(() {
        _avatarUrl = signedAvatarUrl ?? avatarUrl;
        _fullNameController.text = response['full_name'] as String? ?? '';
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await supabase
          .from('profiles')
          .update({'full_name': _fullNameController.text.trim()})
          .eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: AppColors.athenaSupportiveGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update profile. Please try again.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_errorMessage'),
            backgroundColor: AppColors.error,
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

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(appAuthProvider.notifier).signOut();
      if (mounted) {
        context.go('/landing');
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sign out. Please try again.'),
            backgroundColor: AppColors.error,
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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Widget _buildAvatarImage() {
    if (_avatarUrl == null || _avatarUrl!.isEmpty) {
      return Icon(
        Icons.person,
        size: 60,
        color: AppColors.athenaBlue.withValues(alpha: 0.7),
      );
    }

    debugPrint('Using avatar URL for image: $_avatarUrl');

    return Image.network(
      _avatarUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value:
                loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
            color: AppColors.athenaPurple,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image: $error');
        return Icon(
          Icons.broken_image_rounded,
          size: 60,
          color: AppColors.error,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(appAuthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        backgroundColor: AppColors.athenaBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section with Profile Photo
                Container(
                  color: AppColors.athenaBlue.withValues(alpha: 0.05),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.athenaBlue.withValues(
                                  alpha: 0.5,
                                ),
                                width: 4,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.athenaOffWhite,
                              child: ClipOval(
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: _buildAvatarImage(),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _isLoading ? null : _uploadAvatar,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.athenaPurple,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.email ?? 'No email available',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.athenaDarkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),

                // Personal Information Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.athenaDarkGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Full Name Field
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: AppColors.athenaPurple,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.athenaBlue.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.athenaPurple,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Save Button
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _updateProfile,
                        icon:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.save),
                        label: const Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.athenaSupportiveGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Account Details Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Details',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: AppColors.athenaDarkGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 32),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.athenaBlue.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.email_outlined,
                                color: AppColors.athenaBlue,
                              ),
                            ),
                            title: const Text('Email'),
                            subtitle: Text(
                              user.email ?? 'No email available',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.athenaPurple.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.fingerprint,
                                color: AppColors.athenaPurple,
                              ),
                            ),
                            title: const Text('User ID'),
                            subtitle: Text(
                              user.id,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sign Out Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.athenaPurple),
            ),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $error',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: _loadProfile,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
