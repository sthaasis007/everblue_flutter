import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/security/biometric_auth_service.dart';
import '../../../../core/widgets/mybutton.dart';
import '../../../../core/widgets/mytextfeild.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';
import '../view_model/auth_view_model.dart';
import '../state/auth_state.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController mail = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isBiometricLoginEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final biometricService = ref.read(biometricAuthServiceProvider);

    final isEnabled = await biometricService.isBiometricEnabled();
    final canUseBiometric = await biometricService.canUseBiometrics();
    final hasCredentials = await biometricService.hasSavedCredentials();

    if (!mounted) return;

    final canLoginWithBiometric =
        isEnabled && canUseBiometric && hasCredentials;

    setState(() {
      _isBiometricLoginEnabled = canLoginWithBiometric;
    });
  }

  @override
  void dispose() {
    mail.dispose();
    pass.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(email: mail.text, password: pass.text);

      if (!mounted) return;

      final authState = ref.read(authViewModelProvider);
      if (authState.status == AuthStatus.authenticated) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else if (authState.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.errorMessage ?? 'Login failed')),
        );
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    final biometricService = ref.read(biometricAuthServiceProvider);

    final isAuthenticated = await biometricService.authenticate(
      reason: 'Validate your fingerprint to login',
    );

    if (!isAuthenticated || !mounted) {
      return;
    }

    final credentials = await biometricService.getSavedCredentials();
    if (credentials == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved credentials for fingerprint login.'),
        ),
      );
      return;
    }

    await ref
        .read(authViewModelProvider.notifier)
        .login(email: credentials.email, password: credentials.password);

    if (!mounted) return;

    final authState = ref.read(authViewModelProvider);
    if (authState.status == AuthStatus.authenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else if (authState.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage ?? 'Fingerprint login failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "EverBlue",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: const Center(
                    child: Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 350,
                  child: Image.asset('assets/images/profile.png'),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      MyTextformfield(
                        labelText: "Email",
                        hintText: 'Enter valid Email',
                        controller: mail,
                        errorMessage: 'Enter a valid email',
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 15),
                      MyTextformfield(
                        labelText: "Password",
                        hintText: 'Enter valid password',
                        controller: pass,
                        errorMessage: 'Enter a correct password',
                        validator: validatePassword,
                        obscureText: true,
                      ),
                      const SizedBox(height: 15),
                      if (_isBiometricLoginEnabled) ...[
                        MyButton(
                          onPressed: isLoading ? null : _handleBiometricLogin,
                          text: isLoading
                              ? "Logging in..."
                              : "Login with Fingerprint",
                        ),
                        const SizedBox(height: 15),
                      ],
                      MyButton(
                        onPressed: isLoading ? null : _handleLogin,
                        text: isLoading ? "Logging in..." : "Log In",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Center(
                    child: Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(color: Colors.teal),
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
