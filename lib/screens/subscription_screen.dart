import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../main.dart'; // For AppColors, Assets, PrimaryButton, AuthShell, PlanCard, pillDecoration
import 'main_shell.dart';

class SubscriptionScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String profilePicture;
  final String profilePictureName;
  final String profilePictureType;

  const SubscriptionScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.profilePicture,
    required this.profilePictureName,
    required this.profilePictureType,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int selected = 0;
  bool loading = false;

  Future<void> register() async {
    setState(() => loading = true);

    try {
      final plan = selected == 0 ? 'Free' : 'Premium';

      await AuthService.register(
        fullName: widget.fullName,
        email: widget.email,
        phone: widget.phone,
        password: widget.password,
        plan: plan,
        profilePicture: widget.profilePicture,
        profilePictureName: widget.profilePictureName,
        profilePictureType: widget.profilePictureType,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      compactLogo: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome to Resi-Bot',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Don\'t miss out on our offer!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: pillDecoration(),
            child: const Text(
              'Start your journey with Resi-Bot Premium!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: PlanCard(
                  title: 'Free',
                  price: '₱0',
                  selected: selected == 0,
                  onTap: () => setState(() => selected = 0),
                  features: const [
                    'Manual invoice input',
                    'Basic tracking',
                    'Limited analytics',
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PlanCard(
                  title: 'Premium',
                  price: '₱499',
                  selected: selected == 1,
                  onTap: () => setState(() => selected = 1),
                  features: const [
                    'AI receipt scanner',
                    'Budget warnings',
                    'Premium analytics',
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          PrimaryButton(
            label: loading ? 'CREATING ACCOUNT...' : 'DONE',
            onTap: loading ? () {} : register,
          ),
          TextButton(
            onPressed: loading ? null : register,
            child: const Text(
              'Skip for now',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
