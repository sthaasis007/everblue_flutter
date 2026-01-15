
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/mybutton.dart';
import '../../../../core/widgets/mytextfeild.dart';
import '../view_model/auth_view_model.dart';
import '../state/auth_state.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController number = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    number.dispose();
    password.dispose();
    super.dispose();
  }
 
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
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

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
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

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authViewModelProvider.notifier).register(
        fullName: name.text,
        email: email.text,
        phoneNumber: number.text,
        password: password.text,
      );

      if (!mounted) return;

      final authState = ref.read(authViewModelProvider);
      if (authState.status == AuthStatus.registered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful! Please log in.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (authState.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.errorMessage ?? 'Registration failed')),
        );
      }
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: const Center(
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: Image.asset('assets/images/profile.png'),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      MyTextformfield(
                        labelText: "Name",
                        hintText: 'Enter Full name',
                        controller: name,
                        errorMessage: 'Enter your name',
                        validator: validateName,
                      ),
                      const SizedBox(height: 15),
                      MyTextformfield(
                        labelText: "Email",
                        hintText: 'Enter a valid email',
                        controller: email,
                        errorMessage: 'Enter a valid email',
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 15),
                      MyTextformfield(
                        labelText: "Phone Number",
                        hintText: 'Enter a phone number',
                        controller: number,
                        errorMessage: 'Enter a valid phone number',
                        validator: validatePhone,
                      ),
                      const SizedBox(height: 15),
                      MyTextformfield(
                        labelText: "Password",
                        hintText: '8 character long',
                        controller: password,
                        errorMessage: 'Enter a password',
                        validator: validatePassword,
                        obscureText: true,
                      ),
                      const SizedBox(height: 15),
                      MyButton(
                        onPressed: isLoading ? null : _handleSignup,
                        text: isLoading ? "Creating account..." : "Create account",
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
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Center(
                    child: Text(
                      "Already have account? Login",
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