import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../main.dart';
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
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (pickedImage == null) return;

    final croppedImage = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Picture',
          toolbarColor: AppColors.purple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          hideBottomControls: false,
          showCropGrid: true,
        ),
        IOSUiSettings(
          title: 'Crop Profile Picture',
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
          ],
          rotateButtonsHidden: false,
          resetButtonHidden: false,
        ),
      ],
    );

    if (croppedImage == null) return;

    final bytes = await croppedImage.readAsBytes();

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
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          profilePicture: profilePicture,
          profilePictureName: profilePictureName,
          profilePictureType: profilePictureType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: isKeyboardOpen ? 110 : 190,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Image.asset(
                        Assets.logo,
                        height: isKeyboardOpen ? 72 : 110,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight -
                            (isKeyboardOpen ? 110 : 190),
                      ),
                      padding: const EdgeInsets.fromLTRB(36, 28, 36, 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
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
                          const SizedBox(height: 4),
                          const Text(
                            'Please add your picture and details.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: pickProfilePicture,
                            child: CircleAvatar(
                              radius: isKeyboardOpen ? 34 : 42,
                              backgroundColor: const Color(0xFFF1EEF4),
                              backgroundImage: profilePicture.isNotEmpty
                                  ? MemoryImage(base64Decode(profilePicture))
                                  : null,
                              child: profilePicture.isEmpty
                                  ? Image.asset(
                                      Assets.user,
                                      height: isKeyboardOpen ? 34 : 42,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap to add profile picture',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppInput(
                            hint: 'Full Name',
                            icon: Assets.user,
                            controller: fullNameController,
                            keyboardType: TextInputType.name,
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
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: 'NEXT',
                            onTap: next,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}