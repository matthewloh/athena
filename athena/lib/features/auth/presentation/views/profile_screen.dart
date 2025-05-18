import 'package:athena/features/auth/domain/entities/user_entity.dart';
import 'package:athena/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import AuthViewModel or a new ProfileViewModel
// TODO: Import UserEntity

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _subjectsController;
  UserEntity? _initialUserEntity;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _subjectsController = TextEditingController();

    // Initialize controllers once the first frame is built and we have context to read provider.
    // Or better, listen to the provider and update controllers when user data changes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authViewModelProvider);
      if (authState.currentUser != null) {
        _initialUserEntity = authState.currentUser;
        _nameController.text = authState.currentUser!.fullName ?? '';
        _subjectsController.text = (authState.currentUser!.preferredSubjects ?? []).join(', ');
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectsController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      final currentAuthState = ref.read(authViewModelProvider);
      if (currentAuthState.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No user logged in to update.')),
        );
        return;
      }

      final name = _nameController.text;
      final subjects = _subjectsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final updatedUser = currentAuthState.currentUser!.copyWith(
        fullName: name,
        preferredSubjects: subjects,
      );

      ref.read(authViewModelProvider.notifier).updateUserProfile(updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.currentUser;

    // If user data changes in the provider, update text controllers
    // This handles cases where data is fetched after initState or updated elsewhere
    if (user != null && user != _initialUserEntity) {
      _initialUserEntity = user; // Update our baseline for comparison
      _nameController.text = user.fullName ?? '';
      _subjectsController.text = (user.preferredSubjects ?? []).join(', ');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              if (authState.isProfileLoading) const LinearProgressIndicator(),
              if (authState.profileError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Error: ${authState.profileError}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _subjectsController,
                decoration: const InputDecoration(
                  labelText: 'Preferred Subjects (comma-separated)',
                  hintText: 'e.g. Math, Physics, History',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: authState.isProfileLoading ? null : _updateProfile,
                child: authState.isProfileLoading
                    ? const SizedBox(
                        height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 