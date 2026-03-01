import 'package:everblue/core/services/security/biometric_auth_service.dart';
import 'package:everblue/features/auth/domain/usecases/delete_customer_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/login_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/logout_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/register_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/update_user_usecase.dart';
import 'package:everblue/features/auth/domain/usecases/upload_image_usecase.dart';
import 'package:everblue/features/auth/presentation/pages/signup_screen.dart';
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
        home: SignupScreen(),
      ),
    );
  }

  group('SignupScreen Widget Tests', () {
    testWidgets('renders', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('is SignupScreen widget', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byWidget(find.byType(SignupScreen).evaluate().first.widget as SignupScreen), findsOneWidget);
    });

    testWidgets('has scrollview', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('renders scaffold', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders container', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('test6 renders column', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('test7 renders center', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => true);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => true);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('test8 renders material app', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('test9 renders directionality', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Directionality), findsWidgets);
    });

    testWidgets('test10 renders after pump settle', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(SignupScreen), findsOneWidget);
    });

    testWidgets('test11 renders appbar with biometric', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => true);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => true);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsWidgets);
    });

    testWidgets('test12 multiple pump cycles', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => false);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('test13 biometric enabled scaffold', (WidgetTester tester) async {
      when(() => mockBiometricAuthService.isBiometricEnabled()).thenAnswer((_) async => true);
      when(() => mockBiometricAuthService.canUseBiometrics()).thenAnswer((_) async => true);
      when(() => mockBiometricAuthService.hasSavedCredentials()).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
