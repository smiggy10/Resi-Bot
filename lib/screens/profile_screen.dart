import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../main.dart'; // For AppColors, Assets, PageFrame, AppCard, ProfileRow, PrimaryButton
import 'settings_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notifications = true;

  ImageProvider? getProfileImage() {
    final imageBase64 = AppSession.currentUser?.profilePicture ?? '';

    if (imageBase64.isEmpty) return null;

    try {
      return MemoryImage(base64Decode(imageBase64));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSession.currentUser;

    return PageFrame(
      title: 'Profile',
      child: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: Colors.white,
              backgroundImage: getProfileImage(),
              child: getProfileImage() == null
                  ? Image.asset(Assets.user, height: 54)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              user?.fullName ?? 'Guest User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('Edit ✎', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'User Information',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ProfileRow(
              icon: Icons.badge,
              label: 'User ID',
              value: user?.userId ?? '-',
            ),
            ProfileRow(
              icon: Icons.alternate_email,
              label: 'Email',
              value: user?.email ?? '-',
            ),
            ProfileRow(
              icon: Icons.phone,
              label: 'Phone Number',
              value: user?.phone ?? '-',
            ),
            ProfileRow(
              icon: Icons.workspace_premium,
              label: 'Subscription',
              value: user?.plan ?? 'Free',
              trailing: Icons.chevron_right,
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.notifications, color: AppColors.purple),
                  const SizedBox(width: 12),
                  const Text(
                    'Notification',
                    style: TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  Switch(
                    value: notifications,
                    activeColor: AppColors.purple,
                    onChanged: (v) => setState(() => notifications = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: ProfileRow(
                icon: Icons.settings,
                label: 'API Configuration',
                value: 'n8n Settings',
                trailing: Icons.chevron_right,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'LOGOUT',
              onTap: () {
                AppSession.logout();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
