import 'package:flutter/material.dart';
import '../main.dart'; // For AppColors, DemoData, PageFrame, AppCard, CategoryBar, InvoiceTable

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Analytics',
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Spending Over Time (Jan - June)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        AppCard(child: SizedBox(height: 190, child: CustomPaint(painter: LineChartPainter()))),
        const SizedBox(height: 18),
        const Text('Spending by Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        AppCard(child: Column(children: [
          CategoryBar('Convenience', '₱50,000', .88),
          CategoryBar('Groceries', '₱40,322', .70),
          CategoryBar('Travel', '₱25,200', .42),
          CategoryBar('Utilities', '₱5,242', .20),
        ])),
        const SizedBox(height: 18),
        const Text('Top Vendors by Total Spend', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        InvoiceTable(invoices: DemoData.invoices.take(4).toList(), compact: true),
      ])),
    );
  }
}
