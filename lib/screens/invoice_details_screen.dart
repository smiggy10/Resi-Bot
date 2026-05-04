import 'package:flutter/material.dart';
import '../main.dart'; // For AppColors, Invoice, AppCard, DetailLine, PrimaryButton

class InvoiceDetailsScreen extends StatelessWidget {
  final Invoice invoice;
  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: Colors.white)), const Expanded(child: Text('Invoice Details', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), const Icon(Icons.delete_outline, color: AppColors.purple)]),
            const SizedBox(height: 10),
            Row(children: [CircleAvatar(backgroundColor: AppColors.purple, child: Text(invoice.vendor[0], style: const TextStyle(color: Colors.white))), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(invoice.vendor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(invoice.category, style: const TextStyle(color: AppColors.muted))]), const Spacer(), Chip(label: Text(invoice.category, style: const TextStyle(color: Colors.white, fontSize: 11)), backgroundColor: AppColors.purple.withOpacity(.35))]),
            const SizedBox(height: 14),
            Text(invoice.amount, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            Text('${invoice.date}  •  ${invoice.time}', style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 18),
            Expanded(
              child: AppCard(
                child: Center(
                  child: Container(
                    width: 230,
                    padding: const EdgeInsets.all(18),
                    color: Colors.white,
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.black, fontSize: 11),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('7 ELEVEN PHILIPPINES', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text('Sample Scanned Receipt'),
                          const Divider(color: Colors.black),
                          receiptLine('Hotdog Sandwich', '₱85.00'),
                          receiptLine('Bottled Water', '₱35.00'),
                          receiptLine('Coffee', '₱65.00'),
                          receiptLine('Convenience Fee', '₱65.67'),
                          const Divider(color: Colors.black),
                          receiptLine('TOTAL', invoice.amount, bold: true),
                          const SizedBox(height: 16),
                          const Text('THANK YOU!'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Extracted Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AppCard(child: Column(children: [DetailLine('Vendor', invoice.vendor), DetailLine('Category', invoice.category), DetailLine('Amount', invoice.amount), DetailLine('Date', invoice.date), DetailLine('Time', invoice.time)])),
            const SizedBox(height: 14),
            PrimaryButton(label: 'Edit Details', onTap: () {}),
          ]),
        ),
      ),
    );
  }

  Widget receiptLine(String left, String right, {bool bold = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(left, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)), Text(right, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal))]);
}
