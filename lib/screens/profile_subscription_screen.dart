import 'package:flutter/material.dart';

import '../main.dart';

class ProfileSubscriptionScreen extends StatefulWidget {
  const ProfileSubscriptionScreen({super.key});

  @override
  State<ProfileSubscriptionScreen> createState() =>
      _ProfileSubscriptionScreenState();
}

class _ProfileSubscriptionScreenState extends State<ProfileSubscriptionScreen> {
  int selected = 0;
  bool loading = false;

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
              'Manage Subscription',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose how you want to continue using Resi-Bot',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 22),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ProfilePlanCard(
                    title: 'Stay Free',
                    subtitle: 'Keep basic tracking',
                    price: '₱0',
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
                  child: _ProfilePlanCard(
                    title: 'Subscribe',
                    subtitle: 'Unlock full features',
                    price: '₱499',
                    suffix: '/ month',
                    selected: selected == 1,
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

            const SizedBox(height: 18),

            const SizedBox(height: 24),

            PrimaryButton(
              label: selected == 1 ? 'SUBSCRIBE NOW' : 'STAY FREE',
              onTap: loading
                  ? () {}
                  : () {
                      Navigator.pop(context);
                    },
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: loading ? null : () => Navigator.pop(context),
              child: const Text(
                'Cancel',
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

class _ProfilePlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String suffix;
  final bool selected;
  final VoidCallback? onTap;
  final List<String> features;

  const _ProfilePlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.suffix,
    required this.selected,
    required this.onTap,
    required this.features,
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
          minHeight: 285,
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
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    price,
                    style: const TextStyle(
                      color: Color(0xFF8B6C9D),
                      fontSize: 30,
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
              height: 20,
            ),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: selected
                          ? AppColors.purple
                          : const Color(0xFFA6A0AD),
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