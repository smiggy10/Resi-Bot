import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/export_data_service.dart';
import '../main.dart';
import 'login_screen.dart';
import 'profile_subscription_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notifications = true;
  bool exporting = false;

  Future<void> _exportAllData() async {
    setState(() => exporting = true);

    try {
      await ExportDataService.exportAllUserData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV export completed successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString().replaceFirst('Exception: ', '')}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSession.currentUser;
    final profilePicture = user?.profilePicture ?? '';

    return PageFrame(
      title: 'Profile',
      child: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: Colors.white,
              backgroundImage:
                  profilePicture.isNotEmpty ? NetworkImage(profilePicture) : null,
              child: profilePicture.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 54,
                      color: AppColors.muted,
                    )
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileSubscriptionScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            AppCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications,
                    color: AppColors.purple,
                  ),
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

            const SizedBox(height: 14),

            AppCard(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: exporting ? null : _exportAllData,
                child: Row(
                  children: [
                    const Icon(
                      Icons.file_download_outlined,
                      color: AppColors.purple,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exporting ? 'Exporting data...' : 'Export All Data',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (exporting)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.purple,
                        ),
                      )
                    else
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.purple,
                      ),
                  ],
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
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
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