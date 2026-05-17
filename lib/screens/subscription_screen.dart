import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../main.dart';
import 'login_screen.dart';

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
  int selected = 1;
  bool loading = false;
  String loadingLabel = '';

  Future<void> registerWithPlan(String plan) async {
    setState(() {
      loading = true;

      if (plan == 'Premium') {
        loadingLabel = 'ACTIVATING PROMO...';
      } else if (plan == 'Premium') {
        loadingLabel = 'STARTING FREE TRIAL...';
      } else {
        loadingLabel = 'CREATING FREE ACCOUNT...';
      }
    });

    try {
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
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
          loadingLabel = '';
        });
      }
    }
  }

  String get selectedPlan {
    if (selected == 1) return 'Premium';
    return 'Free';
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      compactLogo: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to Resi-Bot',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Special launch offer for new users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: pillDecoration(),
              child: const Column(
                children: [
                  Text(
                    'Get Premium for 50% off',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Only ₱248/month instead of ₱499/month',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SubscriptionPlanCard(
                    title: 'Free',
                    subtitle: 'For getting started',
                    price: '₱0',
                    oldPrice: '',
                    suffix: '/ month',
                    selected: selected == 0,
                    onTap: loading ? null : () => setState(() => selected = 0),
                    features: const [
                      '10 receipt scans / month',
                      'Basic data extraction',
                      'Basic expense history',
                      'Simple budget tracking',
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SubscriptionPlanCard(
                    title: 'Premium',
                    subtitle: 'For smart tracking',
                    price: '₱248',
                    oldPrice: '₱499',
                    suffix: '/ month',
                    selected: selected == 1,
                    highlightBadge: '50% OFF',
                    onTap: loading ? null : () => setState(() => selected = 1),
                    features: const [
                      'Unlimited receipt scans',
                      'AI-powered extraction',
                      'Budget alerts',
                      'Spending reports',
                      'Export as PDF/CSV',
                      'Priority support',
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.purple.withOpacity(.25),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.card_giftcard,
                    color: AppColors.purple,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Not ready to subscribe? Start a 7-day Premium free trial and decide later.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: loading
                  ? loadingLabel
                  : selectedPlan == 'Premium'
                      ? 'CLAIM 50% OFF'
                      : 'CONTINUE WITH FREE',
              onTap: loading ? () {} : () => registerWithPlan(selectedPlan),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: loading ? null : () => registerWithPlan('Free Trial'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.purple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Start 7-Day Free Trial',
                style: TextStyle(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: loading ? null : () => registerWithPlan('Free'),
              child: const Text(
                'Continue with Free',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionPlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String oldPrice;
  final String suffix;
  final bool selected;
  final String? highlightBadge;
  final VoidCallback? onTap;
  final List<String> features;

  const _SubscriptionPlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.oldPrice,
    required this.suffix,
    required this.selected,
    required this.onTap,
    required this.features,
    this.highlightBadge,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.purple : const Color(0xFF8E729E);
    final backgroundColor =
        selected ? AppColors.purple.withOpacity(.07) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(
          minHeight: 300,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: selected ? 2 : 1.3,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.purple.withOpacity(.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (highlightBadge != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    highlightBadge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFA6A0AD),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            if (oldPrice.isNotEmpty)
              Text(
                oldPrice,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    price,
                    style: const TextStyle(
                      color: Color(0xFF8B6C9D),
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    suffix,
                    style: const TextStyle(
                      color: Color(0xFFA6A0AD),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              color: Color(0xFFE0D8E5),
              height: 18,
            ),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color:
                          selected ? AppColors.purple : const Color(0xFFA6A0AD),
                      size: 14,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: Color(0xFF9A94A4),
                          fontSize: 10.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
