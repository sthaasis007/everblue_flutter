import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everblue/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:everblue/features/bottom_screen/presentation/pages/home_screen.dart';
import 'package:everblue/features/bottom_screen/presentation/pages/cart_screen.dart';
import 'package:everblue/features/bottom_screen/presentation/pages/checkout_screen.dart';
import 'package:everblue/features/bottom_screen/presentation/pages/profile_screen.dart';

import 'package:everblue/core/services/storage/user_session_service.dart';

/// ✅ Fake user session service for tests
class FakeUserSessionService implements UserSessionService {
  @override
  String? getCurrentUserFullName() => 'Test User';

  @override
  String? getCurrentUserEmail() => 'test@gmail.com';

  @override
  String? getCurrentUserProfilePicture() => '';
  
  @override
  Future<void> clearSession() {
    // TODO: implement clearSession
    throw UnimplementedError();
  }
  
  @override
  String? getCurrentUserId() {
    // TODO: implement getCurrentUserId
    throw UnimplementedError();
  }
  
  @override
  String? getCurrentUserPhoneNumber() {
    // TODO: implement getCurrentUserPhoneNumber
    throw UnimplementedError();
  }
  
  @override
  bool isLoggedIn() {
    // TODO: implement isLoggedIn
    throw UnimplementedError();
  }
  
  @override
  Future<void> saveUserSession({required String userId, required String email, required String fullName, String? phoneNumber, String? profilePicture}) {
    // TODO: implement saveUserSession
    throw UnimplementedError();
  }
  
  @override
  Future<void> updateUserProfilePicture(String pictureFileName) {
    // TODO: implement updateUserProfilePicture
    throw UnimplementedError();
  } // keep empty to avoid NetworkImage
}

void main() {
  testWidgets('DashboardScreen switches bottom navigation screens',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // ✅ Override the provider used by ProfileScreen
          userSessionServiceProvider.overrideWithValue(FakeUserSessionService()),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Default screen should be Home
    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap Cart
    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.byType(CartScreen), findsOneWidget);

    // Tap Check Out
    await tester.tap(find.text('Check Out'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutScreen), findsOneWidget);

    // Tap Profile (this should no longer crash)
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    // Confirm Profile UI shows the fake name/email
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@gmail.com'), findsOneWidget);
  });
}
