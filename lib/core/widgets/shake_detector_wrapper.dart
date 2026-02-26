import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shake/shake.dart';
import 'package:everblue/core/services/storage/user_session_service.dart';
import 'package:everblue/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:everblue/features/auth/presentation/pages/login_screen.dart';

/// A wrapper widget that detects shake gestures and shows logout confirmation dialog
class ShakeDetectorWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const ShakeDetectorWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ShakeDetectorWrapper> createState() => _ShakeDetectorWrapperState();
}

class _ShakeDetectorWrapperState extends ConsumerState<ShakeDetectorWrapper> {
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();
    _initializeShakeDetector();
  }

  void _initializeShakeDetector() {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        // Check if user is logged in before showing logout dialog
        final userSessionService = ref.read(userSessionServiceProvider);
        if (userSessionService.isLoggedIn()) {
          _showLogoutConfirmationDialog();
        }
      },
      minimumShakeCount: 2,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );
  }

  void _showLogoutConfirmationDialog() {
    // Get the context from the overlay
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Icon(
          Icons.logout_rounded,
          color: Colors.red,
          size: 48,
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to logout?'),
            SizedBox(height: 8),
            Text(
              'Shake detected!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Perform logout
              await ref.read(authViewModelProvider.notifier).logout();
              
              // Navigate to login screen
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Global navigator key to access context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
