import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart'; // For AppColors, Assets, NavItem
import '../services/budget_service.dart';
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
  int homeRefreshKey = 0;

  Future<void> showBudgetDialog() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(.72),
      builder: (_) => const BudgetDialog(),
    );

    if (saved == true && mounted) {
      setState(() {
        homeRefreshKey++;
        index = 0;
      });
    }
  }

  List<Widget> get pages => [
        HomeScreen(
          key: ValueKey('home-$homeRefreshKey'),
          openBudget: showBudgetDialog,
        ),
        const InvoicesScreen(),
        const AnalyticsScreen(),
        const ProfileScreen(),
      ];

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
          side: BorderSide(color: Colors.white, width: 4),
        ),
        onPressed: () => ReceiptScanFlow.start(context),
        child: const Icon(Icons.add, color: Colors.white, size: 36),
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
  final TextEditingController budgetController = TextEditingController();
  bool isSaving = false;

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  DateTime get startDate => DateTime.now();

  DateTime get endDate => _addOneMonth(startDate);

  DateTime _addOneMonth(DateTime date) {
    final nextMonth = date.month == 12 ? 1 : date.month + 1;
    final nextYear = date.month == 12 ? date.year + 1 : date.year;
    final lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
    final safeDay = min(date.day, lastDayOfNextMonth);

    return DateTime(nextYear, nextMonth, safeDay);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  double _parseBudgetInput() {
    final cleaned = budgetController.text
        .replaceAll('₱', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(cleaned) ?? 0;
  }

  Future<void> _saveBudget() async {
    final budgetLimit = _parseBudgetInput();

    if (budgetLimit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid budget amount.'),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await BudgetService.setMonthlyBudget(budgetLimit: budgetLimit);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget saved successfully.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save budget: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Set Budget Limit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: isSaving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              const Text(
                'Enter your monthly budget limit. The budget period will automatically start today and end one month later.',
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
              TextField(
                controller: budgetController,
                enabled: !isSaving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  prefixText: '₱ ',
                  prefixStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: 'Enter amount',
                  hintStyle: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 18,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.purple),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.lightPurple),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AppCard(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.purple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Budget Period\nMonthly • ${_formatDate(startDate)} to ${_formatDate(endDate)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: const Row(
                  children: [
                    Icon(Icons.refresh, color: AppColors.purple),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your budget will reset automatically one month after the date it was set.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: isSaving ? 'Saving...' : 'Save Budget',
                onTap: isSaving ? () {} : _saveBudget,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
