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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
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
      _profilePhotoUrl = profile?['profile_photo'];
    } catch (_) {
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

      final newPassword = _passwordController.text.trim();
      final uploadedPhotoUrl = await _uploadProfileImage(user.id);

      if (newPassword.isNotEmpty) {
        await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      }

      final result = await _supabase.from('profiles').upsert({
        'id': user.id,
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'profile_photo': uploadedPhotoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id').select();

      debugPrint('CURRENT USER ID: ${user.id}');
      debugPrint('UPSERT RESULT: $result');

      if (!mounted) return;

      setState(() {
        _profilePhotoUrl = uploadedPhotoUrl;
        _selectedImage = null;
        _passwordController.clear();
        _confirmPasswordController.clear();
      });

      _showSnackBar('Profile updated successfully.');
    } catch (_) {
      _showSnackBar('Failed to update profile.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF00112C),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Editar Perfil',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00112C),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 44),
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: const Color(0xFFF1F1F1),
                              backgroundImage: _getProfileImage(),
                              child: _getProfileImage() == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 54,
                                      color: Color(0xFF9CA3AF),
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 2,
                              bottom: 4,
                              child: InkWell(
                                onTap: _pickProfileImage,
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF111827),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 38),
                      _buildProfileField(
                        label: 'Primeiro Nome',
                        controller: _firstNameController,
                        hintText: 'Maria',
                        textInputAction: TextInputAction.next,
                        validatorMessage: 'Introduza o primeiro nome.',
                      ),
                      const SizedBox(height: 22),
                      _buildProfileField(
                        label: 'Apelido',
                        controller: _lastNameController,
                        hintText: 'Silva',
                        textInputAction: TextInputAction.next,
                        validatorMessage: 'Introduza o apelido.',
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00112C),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPasswordField(
                        controller: _passwordController,
                        hintText: 'Digite a nova password',
                        showPassword: _showPassword,
                        onToggle: () {
                          setState(() => _showPassword = !_showPassword);
                        },
                        validator: (value) {
                          final password = value?.trim() ?? '';

                          if (password.isEmpty) return null;

                          if (password.length < 6) {
                            return 'A password deve ter pelo menos 6 caracteres.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirme a nova password',
                        showPassword: _showConfirmPassword,
                        onToggle: () {
                          setState(
                            () => _showConfirmPassword = !_showConfirmPassword,
                          );
                        },
                        validator: (value) {
                          final password = _passwordController.text.trim();
                          final confirmPassword = value?.trim() ?? '';

                          if (password.isEmpty && confirmPassword.isEmpty) {
                            return null;
                          }

                          if (confirmPassword != password) {
                            return 'As passwords não coincidem.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF08A83D),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(
                              0xFF08A83D,
                            ).withValues(alpha: 0.55),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Guardar Alterações',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required TextInputAction textInputAction,
    required String validatorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00112C),
          ),
        ),
        TextFormField(
          controller: controller,
          textInputAction: textInputAction,
          style: const TextStyle(fontSize: 16, color: Color(0xFF334155)),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF08A83D), width: 1.5),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            contentPadding: const EdgeInsets.only(top: 14, bottom: 12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return validatorMessage;
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool showPassword,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      validator: validator,
      style: const TextStyle(fontSize: 16, color: Color(0xFF334155)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            showPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF94A3B8),
          ),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF08A83D), width: 1.5),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.only(top: 14, bottom: 12),
      ),
    );
  }
}
