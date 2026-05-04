import 'package:flutter/material.dart';
import '../main.dart'; // For AppColors, DemoData, PageFrame, StatCard, AppCard, InvoiceTable

class HomeScreen extends StatelessWidget {
  final VoidCallback openBudget;
  const HomeScreen({super.key, required this.openBudget});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Monthly Overview',
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: StatCard(label: 'Total Expenses', value: '₱10,000')),
          const SizedBox(width: 16),
          Expanded(child: StatCard(label: 'Total Invoices', value: '55')),
        ]),
        const SizedBox(height: 28),
        const Text('Budget', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Budget Limit', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 6),
          Row(children: [const Text('₱2500/10,000', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const Spacer(), const Text('25%', style: TextStyle(color: AppColors.muted))]),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: .25, minHeight: 11, backgroundColor: const Color(0xFF4A4554), valueColor: const AlwaysStoppedAnimation(AppColors.purple))),
          Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: openBudget, icon: const Icon(Icons.chevron_right, size: 18), label: const Text('Set Budget Here'), style: TextButton.styleFrom(foregroundColor: Colors.white))),
        ])),
        const SizedBox(height: 24),
        const Text('Recent Invoices', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        InvoiceTable(invoices: DemoData.invoices.take(5).toList()),
      ])),
    );
  }
}
