import 'package:everblue/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  @override
  Widget build(BuildContext context) {
    final userSessionService = ref.watch(userSessionServiceProvider);

    final userName =
        userSessionService.getCurrentUserFullName() ?? 'User';
    final userEmail =
        userSessionService.getCurrentUserEmail() ?? '';
    final phoneNumber =
        userSessionService.getCurrentUserPhoneNumber() ?? '';
    // final profileImageUrl =
    //     userSessionService.getCurrentUserProfileImage();

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
                    child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      
                      // radius: 60,
                      // backgroundColor: Colors.grey.shade200,
                      // backgroundImage:
                      //     profileImageUrl != null &&
                      //             profileImageUrl.isNotEmpty
                      //         ? NetworkImage(profileImageUrl)
                      //         : null,
                      // child: profileImageUrl == null ||
                      //         profileImageUrl.isEmpty
                      //     ? Text(
                      //         userName.isNotEmpty
                      //             ? userName[0].toUpperCase()
                      //             : 'U',
                      //         style: const TextStyle(
                      //           fontSize: 48,
                      //           fontWeight: FontWeight.bold,
                      //           color: Colors.teal,
                      //         ),
                      //       )
                      //     : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: InkWell(
                      onTap: _uploadProfileImage,
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
                    _profileField(
                      icon: Icons.person,
                      label: 'Full Name',
                      value: userName,
                      onEdit: () {
                        // TODO: edit name
                      },
                    ),
                    _profileField(
                      icon: Icons.email,
                      label: 'Email',
                      value: userEmail,
                      onEdit: () {
                        // usually email not editable
                      },
                    ),
                    _profileField(
                      icon: Icons.phone,
                      label: 'Phone Number',
                      value: phoneNumber,
                      onEdit: () {
                        // TODO: edit phone
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Upload image handler (camera + button use same logic)
  Future<void> _uploadProfileImage() async {
    // TODO:
    // 1. Pick image (ImagePicker)
    // 2. Upload via multipart
    // 3. Update user session
    // 4. ref.invalidate(userSessionServiceProvider)
  }

  Widget _profileField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.teal),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
