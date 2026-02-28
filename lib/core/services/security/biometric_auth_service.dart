import 'package:everblue/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localAuthenticationProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService(
    localAuthentication: ref.read(localAuthenticationProvider),
    secureStorage: ref.read(flutterSecureStorageProvider),
    prefs: ref.read(sharedPreferencesProvider),
  );
});

class BiometricCredentials {
  final String email;
  final String password;

  const BiometricCredentials({required this.email, required this.password});
}

class BiometricAuthService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricEmailKey = 'biometric_login_email';
  static const String _biometricPasswordKey = 'biometric_login_password';

  final LocalAuthentication _localAuthentication;
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  BiometricAuthService({
    required LocalAuthentication localAuthentication,
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  }) : _localAuthentication = localAuthentication,
       _secureStorage = secureStorage,
       _prefs = prefs;

  Future<bool> isBiometricEnabled() async {
    return _prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> canUseBiometrics() async {
    try {
      final isSupported = await _localAuthentication.isDeviceSupported();
      final canCheck = await _localAuthentication.canCheckBiometrics;
      final availableBiometrics = await _localAuthentication
          .getAvailableBiometrics();
      return isSupported && canCheck && availableBiometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<String> getBiometricUnavailableReason() async {
    try {
      final isSupported = await _localAuthentication.isDeviceSupported();
      if (!isSupported) {
        return 'This device does not support biometric authentication.';
      }

      final canCheck = await _localAuthentication.canCheckBiometrics;
      if (!canCheck) {
        return 'No fingerprint is enrolled. Please add a fingerprint and screen lock in phone settings.';
      }

      final availableBiometrics = await _localAuthentication
          .getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return 'Fingerprint is not set up on this device. Please enroll a fingerprint in settings.';
      }

      return 'Biometric authentication is currently unavailable.';
    } catch (_) {
      return 'Biometric authentication is unavailable. Please check your device security settings.';
    }
  }

  Future<bool> authenticate({
    String reason = 'Please verify your fingerprint to continue',
  }) async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> saveLoginCredentials({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: _biometricEmailKey, value: email);
    await _secureStorage.write(key: _biometricPasswordKey, value: password);
  }

  Future<BiometricCredentials?> getSavedCredentials() async {
    final email = await _secureStorage.read(key: _biometricEmailKey);
    final password = await _secureStorage.read(key: _biometricPasswordKey);

    if (email == null || password == null) {
      return null;
    }

    return BiometricCredentials(email: email, password: password);
  }

  Future<bool> hasSavedCredentials() async {
    final credentials = await getSavedCredentials();
    return credentials != null;
  }

  Future<void> clearSavedCredentials() async {
    await _secureStorage.delete(key: _biometricEmailKey);
    await _secureStorage.delete(key: _biometricPasswordKey);
  }
}
