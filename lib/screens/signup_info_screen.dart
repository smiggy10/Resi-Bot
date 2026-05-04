import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart'; // For AppColors, Assets, AppInput, PrimaryButton, AuthShell
import 'signup_password_screen.dart';

class SignupInfoScreen extends StatefulWidget {
  const SignupInfoScreen({super.key});

  @override
  State<SignupInfoScreen> createState() => _SignupInfoScreenState();
}

class _SignupInfoScreenState extends State<SignupInfoScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String profilePicture = '';
  String profilePictureName = '';
  String profilePictureType = '';

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> pickProfilePicture() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 800,
    );

    if (pickedImage == null) return;

    final bytes = await pickedImage.readAsBytes();

    setState(() {
      profilePicture = base64Encode(bytes);
      profilePictureName = pickedImage.name;
      profilePictureType = pickedImage.mimeType ?? 'image/jpeg';
    });
  }

  void next() {
    if (fullNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupPasswordScreen(
          fullName: fullNameController.text,
          email: emailController.text,
          phone: phoneController.text,
          profilePicture: profilePicture,
          profilePictureName: profilePictureName,
          profilePictureType: profilePictureType,
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
            'Sign Up',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.purple,
            ),
          ),
          const Text(
            'Please add your picture and details.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: pickProfilePicture,
            child: CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFFF1EEF4),
              backgroundImage: profilePicture.isNotEmpty
                  ? MemoryImage(base64Decode(profilePicture))
                  : null,
              child: profilePicture.isEmpty
                  ? Image.asset(Assets.user, height: 42)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap to add profile picture',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 20),
          AppInput(
            hint: 'Full Name',
            icon: Assets.user,
            controller: fullNameController,
          ),
          const SizedBox(height: 14),
          AppInput(
            hint: 'Email',
            icon: Assets.gmail,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          AppInput(
            hint: 'Phone Number',
            icon: Assets.phone,
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 30),
          PrimaryButton(label: 'NEXT', onTap: next),
        ],
      ),
    );
  }
}
