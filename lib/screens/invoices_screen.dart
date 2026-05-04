import 'package:flutter/material.dart';
import '../main.dart'; // For AppColors, DemoData, PageFrame, FilterChipLite, InvoiceTable

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'All Invoices',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 8, children: const [FilterChipLite('Date Range'), FilterChipLite('Yesterday'), FilterChipLite('Last 7 Days'), FilterChipLite('Last 15 Days'), FilterChipLite('Last 30 Days')]),
        const SizedBox(height: 14),
        Expanded(child: SingleChildScrollView(child: InvoiceTable(invoices: DemoData.invoices, clickable: true))),
      ]),
    );
  }
}
