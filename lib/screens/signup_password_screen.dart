import 'package:flutter/material.dart';
import '../main.dart'; // For AppColors, Assets, AppInput, PrimaryButton, AuthShell
import 'subscription_screen.dart';

class SignupPasswordScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String profilePicture;
  final String profilePictureName;
  final String profilePictureType;

  const SignupPasswordScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profilePicture,
    required this.profilePictureName,
    required this.profilePictureType,
  });

  @override
  State<SignupPasswordScreen> createState() => _SignupPasswordScreenState();
}

class _SignupPasswordScreenState extends State<SignupPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void continueToPlan() {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter and confirm your password.')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubscriptionScreen(
          fullName: widget.fullName,
          email: widget.email,
          phone: widget.phone,
          password: passwordController.text,
          profilePicture: widget.profilePicture,
          profilePictureName: widget.profilePictureName,
          profilePictureType: widget.profilePictureType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      compactLogo: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.purple,
            ),
          ),
          const Text(
            'Create a secure password for your account.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 70),
          AppInput(
            hint: 'Password',
            icon: Assets.password,
            obscure: true,
            controller: passwordController,
          ),
          const SizedBox(height: 14),
          AppInput(
            hint: 'Confirm Password',
            icon: Assets.password,
            obscure: true,
            controller: confirmPasswordController,
          ),
          const SizedBox(height: 34),
          PrimaryButton(label: 'SIGN UP', onTap: continueToPlan),
        ],
      ),
    );
  }
}
