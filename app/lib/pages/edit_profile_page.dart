import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  File? _selectedImage;
  String? _profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated.');
      }

      final profile = await _supabase
          .from('profiles')
          .select('first_name, last_name, profile_photo')
          .eq('id', user.id)
          .maybeSingle();

      _firstNameController.text = profile?['first_name'] ?? '';
      _lastNameController.text = profile?['last_name'] ?? '';
      _emailController.text = user.email ?? '';
      _profilePhotoUrl = profile?['profile_photo'];
    } catch (error) {
      _showSnackBar('Failed to load profile.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future<String?> _uploadProfileImage(String userId) async {
    if (_selectedImage == null) return _profilePhotoUrl;

    final fileExtension = _selectedImage!.path.split('.').last;
    final filePath = '$userId/profile_photo.$fileExtension';

    await _supabase.storage
        .from('profile-photos')
        .upload(
          filePath,
          _selectedImage!,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from('profile-photos').getPublicUrl(filePath);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated.');
      }

      final newEmail = _emailController.text.trim();
      final newPassword = _passwordController.text.trim();
      final uploadedPhotoUrl = await _uploadProfileImage(user.id);

      if (newEmail != user.email || newPassword.isNotEmpty) {
        await _supabase.auth.updateUser(
          UserAttributes(
            email: newEmail != user.email ? newEmail : null,
            password: newPassword.isNotEmpty ? newPassword : null,
          ),
        );
      }

      await _supabase.from('profiles').upsert({
        'id': user.id,
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'profile_photo': uploadedPhotoUrl,
      });

      if (!mounted) return;

      setState(() {
        _profilePhotoUrl = uploadedPhotoUrl;
        _selectedImage = null;
        _passwordController.clear();
        _confirmPasswordController.clear();
      });

      _showSnackBar('Profile updated successfully.');
    } catch (error) {
      _showSnackBar('Failed to update profile.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete account?'),
          content: const Text(
            'This action is permanent. Your account and related data will be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);

    try {
      // This Edge Function must delete the authenticated user with the Supabase Admin API.
      // Do not delete auth users directly from the app with the service role key.
      await _supabase.functions.invoke('delete-user');

      await _supabase.auth.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (error) {
      _showSnackBar('Failed to delete account.');
      _showSnackBar('Failed to delete account: $error');
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }

    if (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty) {
      return NetworkImage(_profilePhotoUrl!);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 58,
                              backgroundColor: Colors.white,
                              backgroundImage: _getProfileImage(),
                              child: _getProfileImage() == null
                                  ? const Icon(Icons.person, size: 56)
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: InkWell(
                                onTap: _pickProfileImage,
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _firstNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'First name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your first name.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your last name.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email.';
                          }

                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Please enter a valid email.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Change password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'New password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => _showPassword = !_showPassword);
                            },
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final password = value?.trim() ?? '';

                          if (password.isEmpty) return null;

                          if (password.length < 6) {
                            return 'Password must have at least 6 characters.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_showConfirmPassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Confirm new password',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => _showConfirmPassword =
                                    !_showConfirmPassword,
                              );
                            },
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final password = _passwordController.text.trim();
                          final confirmPassword = value?.trim() ?? '';

                          if (password.isEmpty && confirmPassword.isEmpty) {
                            return null;
                          }

                          if (confirmPassword != password) {
                            return 'Passwords do not match.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving || _isDeleting
                              ? null
                              : _saveProfile,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save changes'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _isSaving || _isDeleting
                              ? null
                              : _confirmDeleteAccount,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete_outline),
                          label: Text(
                            _isDeleting
                                ? 'Deleting account...'
                                : 'Delete account',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
