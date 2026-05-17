import 'package:flutter/material.dart';
import '../main.dart'; // For AppColors, Assets, NavItem
import 'home_screen.dart';
import 'invoices_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'receipt_scan_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  late final pages = [
    HomeScreen(openBudget: showBudgetDialog),
    const InvoicesScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  void showBudgetDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.72),
      builder: (_) => const BudgetDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: index,
          children: pages,
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: FloatingActionButton.large(
        backgroundColor: AppColors.purple,
        shape: const CircleBorder(
          side: BorderSide(
            color: Colors.white,
            width: 4,
          ),
        ),
        onPressed: () => ReceiptScanFlow.start(context),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 36,
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        height: 76,
        padding: EdgeInsets.zero,
        color: Colors.white,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavItem(
              asset: Assets.home,
              label: 'Home',
              active: index == 0,
              onTap: () => setState(() => index = 0),
            ),
            NavItem(
              asset: Assets.invoices,
              label: 'Invoices',
              active: index == 1,
              onTap: () => setState(() => index = 1),
            ),
            const SizedBox(width: 70),
            NavItem(
              asset: Assets.analytics,
              label: 'Analytics',
              active: index == 2,
              onTap: () => setState(() => index = 2),
            ),
            NavItem(
              asset: Assets.profile,
              label: 'Profile',
              active: index == 3,
              onTap: () => setState(() => index = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetDialog extends StatefulWidget {
  const BudgetDialog({super.key});

  @override
  State<BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  int preset = 1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Set Budget Limit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),

            const Text(
              'Set your monthly budget limit to track and manage your spending.',
              style: TextStyle(color: AppColors.muted),
            ),

            const SizedBox(height: 20),

            const Text(
              'Monthly Budget Limit',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              '₱ 2,500',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(color: AppColors.purple),

            Row(
              children: List.generate(4, (i) {
                final values = [
                  '₱1,000',
                  '₱2,500',
                  '₱5,000',
                  '₱10,000',
                ];

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: Text(
                        values[i],
                        style: const TextStyle(fontSize: 10),
                      ),
                      selected: preset == i,
                      selectedColor: AppColors.purple,
                      onSelected: (_) => setState(() => preset = i),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 18),

            AppCard(
              child: const Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: AppColors.purple,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Budget Period\nMonthly',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            AppCard(
              child: const Row(
                children: [
                  Icon(
                    Icons.refresh,
                    color: AppColors.purple,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your budget will reset automatically every month.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            PrimaryButton(
              label: 'Save Budget',
              onTap: () => Navigator.pop(context),
            ),

            const SizedBox(height: 8),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}