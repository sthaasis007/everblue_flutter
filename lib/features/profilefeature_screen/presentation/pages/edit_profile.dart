import 'dart:io';
import 'package:everblue/app/routes/app_routes.dart';
import 'package:everblue/core/api/api_endpoint.dart';
import 'package:everblue/core/services/storage/user_session_service.dart';
import 'package:everblue/features/auth/presentation/pages/login_screen.dart';
import 'package:everblue/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:everblue/features/profilefeature_screen/presentation/widgets/media_picker_buttom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  final List<File> _selectedMedia = [];
  final ImagePicker _imagePicker = ImagePicker();
  String? _publishedProfileImageUrl;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _initialName = '';
  String _initialEmail = '';
  String _initialPhone = '';
  bool _hasPendingChanges = false;

  @override
  void initState() {
    super.initState();
    // Refresh session data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(userSessionServiceProvider);
    });

    final userSessionService = ref.read(userSessionServiceProvider);
    _syncControllersFromSession(userSessionService);

    _nameController.addListener(_updateDirtyFlag);
    _emailController.addListener(_updateDirtyFlag);
    _phoneController.addListener(_updateDirtyFlag);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _syncControllersFromSession(UserSessionService userSessionService) {
    _initialName = userSessionService.getCurrentUserFullName() ?? '';
    _initialEmail = userSessionService.getCurrentUserEmail() ?? '';
    _initialPhone = userSessionService.getCurrentUserPhoneNumber() ?? '';

    _nameController.text = _initialName;
    _emailController.text = _initialEmail;
    _phoneController.text = _initialPhone;

    _hasPendingChanges = false;
  }

  void _updateDirtyFlag() {
    final nameChanged = _nameController.text.trim() != _initialName.trim();
    final emailChanged = _emailController.text.trim() != _initialEmail.trim();
    final phoneChanged = _phoneController.text.trim() != _initialPhone.trim();
    final hasChanges = nameChanged || emailChanged || phoneChanged;
    if (hasChanges != _hasPendingChanges && mounted) {
      setState(() {
        _hasPendingChanges = hasChanges;
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "This feature requires permission to access your camera or gallery. Please enable it in your device settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }

    return false;
  }

  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(File(photo.path));
      });
      final result = await ref
          .read(authViewModelProvider.notifier)
          .uploadPhoto(File(photo.path));
      
      // If upload successful, update UI immediately
      if (result != null && mounted) {
        setState(() {
          _selectedMedia.clear();
          _publishedProfileImageUrl = result;
        });
        // Also save to session for persistence
        await Future.delayed(const Duration(milliseconds: 300));
        ref.invalidate(userSessionServiceProvider);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedMedia.clear();
          _selectedMedia.add(File(image.path));
        });
        final result = await ref
            .read(authViewModelProvider.notifier)
            .uploadPhoto(File(image.path));
        
        // If upload successful, update UI immediately
        if (result != null && mounted) {
          setState(() {
            _selectedMedia.clear();
            _publishedProfileImageUrl = result;
          });
          // Also save to session for persistence
          await Future.delayed(const Duration(milliseconds: 300));
          ref.invalidate(userSessionServiceProvider);
        }
      }
    } catch (e) {
      debugPrint('Gallery Error $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to access gallery. Please try using the camera instead.')),
        );
      }
    }
  }

  void _showMediaPicker() {
    MediaPickerBottomSheet.show(
      context,
      onCameraTap: _pickFromCamera,
      onGalleryTap: _pickFromGallery,
    );
  }

  void _showPasswordDialog() {
    _passwordController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Password'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter your password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _saveProfileUpdates();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    _passwordController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text('Enter your password to confirm:'),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your password')),
        );
      }
      return;
    }

    final userSessionService = ref.read(userSessionServiceProvider);
    final userId = userSessionService.getCurrentUserId() ?? '';
    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete account right now')),
        );
      }
      return;
    }

    final success = await ref.read(authViewModelProvider.notifier).deleteCustomer(userId, password);

    if (success && mounted) {
      await userSessionService.clearSession();
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );
      // Navigate to login screen after deletion
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          AppRoutes.pushAndRemoveUntil(context, const LoginScreen());
        }
      });
    } else if (mounted) {
      final errorMessage = ref.read(authViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Failed to delete account'),
        ),
      );
    }
  }

  Future<void> _saveProfileUpdates() async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final userId = userSessionService.getCurrentUserId() ?? '';
    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update profile right now')),
        );
      }
      return;
    }

    final updatedName = _nameController.text.trim();
    final updatedEmail = _emailController.text.trim();
    final updatedPhone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your password')),
        );
      }
      return;
    }

    final nameChanged = updatedName != _initialName.trim();
    final emailChanged = updatedEmail != _initialEmail.trim();
    final phoneChanged = updatedPhone != _initialPhone.trim();

    if (updatedName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name')),
        );
      }
      return;
    }

    if (updatedEmail.isEmpty || !updatedEmail.contains('@')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email')),
        );
      }
      return;
    }

    if (phoneChanged) {
      final phoneRegex = RegExp(r'^\d{10}$');
      if (updatedPhone.isEmpty || !phoneRegex.hasMatch(updatedPhone)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number must be exactly 10 digits'),
            ),
          );
        }
        return;
      }
    }

    final success = await ref.read(authViewModelProvider.notifier).updateUser(
          userId: userId,
          fullName: nameChanged ? updatedName : null,
          email: emailChanged ? updatedEmail : null,
          phoneNumber: phoneChanged ? updatedPhone : null,
          password: password,
        );

    if (success && mounted) {
      ref.invalidate(userSessionServiceProvider);
      setState(() {
        _initialName = updatedName;
        _initialEmail = updatedEmail;
        _initialPhone = updatedPhone;
        _hasPendingChanges = false;
        _passwordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } else if (mounted) {
      final errorMessage = ref.read(authViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Failed to update profile'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSessionService = ref.watch(userSessionServiceProvider);

    final userName = _nameController.text.isNotEmpty
      ? _nameController.text
      : (userSessionService.getCurrentUserFullName() ?? 'User');
    final sessionProfileImageUrl =
        userSessionService.getCurrentUserProfilePicture() ?? '';
    
    // Use published URL (with timestamp) if available, otherwise use session URL
    final profileImageUrl = _publishedProfileImageUrl ?? sessionProfileImageUrl;
    
    String? _buildProfileImageUrl(String path) {
      if (path.isEmpty || path == 'default.png') return null;
      if (path.startsWith('http')) return path;
      if (path.startsWith('/public')) {
        return '${ApiEndpoints.serverUrl}${path.replaceFirst('/public', '')}';
      }
      if (path.startsWith('/profile_picture')) return '${ApiEndpoints.serverUrl}$path';
      return '${ApiEndpoints.serverUrl}/profile_picture/$path';
    }

    final profileImageFullUrl = _buildProfileImageUrl(profileImageUrl);
    
    // print(' EditProfile build - Photo URL: $profileImageUrl');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ever Blue'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),

              const Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // Avatar + camera icon
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _selectedMedia.isNotEmpty
                        ? CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: FileImage(_selectedMedia.first),
                          )
                        : (profileImageFullUrl != null)
                            ? CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                  profileImageFullUrl,
                                ),
                                child: Container(),
                              )
                            : CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue,
                                ),)
                              ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: InkWell(
                      onTap: _showMediaPicker,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Profile fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _editableProfileField(
                      icon: Icons.person,
                      label: 'Full Name',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                    ),
                    _editableProfileField(
                      icon: Icons.email,
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _editableProfileField(
                      icon: Icons.phone,
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_hasPendingChanges)
                ElevatedButton(
                  onPressed: _showPasswordDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Update Profile',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _showDeleteConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                child: const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editableProfileField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
