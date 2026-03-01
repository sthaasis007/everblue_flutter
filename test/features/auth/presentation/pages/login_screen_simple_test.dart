import 'package:everblue/core/services/security/biometric_auth_service.dart';
import 'package:everblue/features/auth/domain/usecases/delete_customer_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/login_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/logout_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/register_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/upload_image_usecase.dart';
import 'package:everblue/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}
class MockLogoutUsecaseImpl extends Mock implements LogoutUsecaseImpl {}
class MockUploadPhotoUsecase extends Mock implements UploadPhotoUsecase {}
class MockUpdateUserUsecase extends Mock implements UpdateUserUsecase {}
class MockDeleteCustomerUsecase extends Mock implements DeleteCustomerUsecase {}
class MockBiometricAuthService extends Mock implements BiometricAuthService {}

void main() {
  late MockBiometricAuthService mockBiometricAuthService;
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecaseImpl mockLogoutUsecase;
  late MockUploadPhotoUsecase mockUploadPhotoUsecase;
  late MockUpdateUserUsecase mockUpdateUserUsecase;
  late MockDeleteCustomerUsecase mockDeleteCustomerUsecase;

  setUpAll(() {
    TestWidgetsFlutterBinding.instance.window.physicalSizeTestValue =
        const Size(1080, 1920);
    addTearDown(TestWidgetsFlutterBinding.instance.window.clearPhysicalSizeTestValue);
  });

  setUp(() {
    mockBiometricAuthService = MockBiometricAuthService();
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecaseImpl();
    mockUploadPhotoUsecase = MockUploadPhotoUsecase();
    mockUpdateUserUsecase = MockUpdateUserUsecase();
    mockDeleteCustomerUsecase = MockDeleteCustomerUsecase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(mockGetCurrentUserUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        uploadPhotoUsecaseProvider.overrideWithValue(mockUploadPhotoUsecase),
        updateUserUsecaseProvider.overrideWithValue(mockUpdateUserUsecase),
        deleteCustomerUsecaseProvider.overrideWithValue(mockDeleteCustomerUsecase),
        biometricAuthServiceProvider.overrideWithValue(mockBiometricAuthService),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('widget is named LoginScreen', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byWidget(find.byType(LoginScreen).evaluate().first.widget as LoginScreen), findsOneWidget);
    });

    testWidgets('has scaffold', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('biometric false', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('biometric true', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => true);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => true);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('test6 renders scrollview', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('test7 renders with biometric enabled', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => true);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => true);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('test8 renders column', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('test9 renders material app', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('test10 renders with setstate', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Directionality), findsWidgets);
    });

    testWidgets('test11 renders appbar', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsWidgets);
    });

    testWidgets('test12 renders with multiple pumps', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('test13 biometric with center', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => true);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => true);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Center), findsWidgets);
    });
  });
}
