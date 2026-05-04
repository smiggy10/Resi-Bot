import 'package:flutter/material.dart';
import '../main.dart'; // AppColors, PageFrame, StatCard, AppCard, InvoiceTable, Invoice, DemoData

// Home dashboard data flow:
// - [kUseHomeDashboardMockData] == false (default) → ₱0, 0, ₱0/0, 0%, empty recent list until [dashboardData] is set.
// - [kUseHomeDashboardMockData] == true → optional sample rows/numbers for UI preview only (no backend).
// Real data: pass [HomeScreen.dashboardData]; [HomeDashboardData.normalizedFrom] still coerces missing fields to zeros/—/₱0.00.

/// Default `false`: all placeholders show zero until you pass [dashboardData] or turn on mock for previews.
const bool kUseHomeDashboardMockData = false;

/// UI-only snapshot for the home dashboard. Keeps API/backend types out of this file.
class HomeDashboardData {
  final String totalExpensesDisplay;
  final String totalInvoicesDisplay;
  final double budgetSpent;
  final double budgetTotal;
  final List<Invoice> recentInvoices;

  const HomeDashboardData({
    required this.totalExpensesDisplay,
    required this.totalInvoicesDisplay,
    required this.budgetSpent,
    required this.budgetTotal,
    required this.recentInvoices,
  });

  double get budgetProgress {
    if (budgetSpent.isNaN ||
        budgetTotal.isNaN ||
        !budgetSpent.isFinite ||
        !budgetTotal.isFinite) {
      return 0;
    }
    if (budgetTotal <= 0) return 0;
    return (budgetSpent / budgetTotal).clamp(0.0, 1.0);
  }

  String get budgetSummaryLine {
    final spent = _formatIntWithCommas(budgetSpent.round());
    final total = _formatIntWithCommas(budgetTotal.round());
    return '₱$spent/$total';
  }

  String get budgetPercentLabel {
    final p = budgetProgress;
    if (p.isNaN || !p.isFinite) return '0%';
    return '${(p * 100).round()}%';
  }

  static String _formatIntWithCommas(int n) {
    final s = n.abs().toString();
    final buf = StringBuffer();
    if (n < 0) buf.write('-');
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  /// Placeholder values for UI preview; no network or services.
  factory HomeDashboardData.mock() {
    return HomeDashboardData(
      totalExpensesDisplay: '₱10,000',
      totalInvoicesDisplay: '55',
      budgetSpent: 2500,
      budgetTotal: 10000,
      recentInvoices: List<Invoice>.from(DemoData.invoices.take(8)),
    );
  }

  /// Use when `kUseHomeDashboardMockData` is false and data is not ready yet.
  factory HomeDashboardData.empty() {
    return const HomeDashboardData(
      totalExpensesDisplay: '₱0',
      totalInvoicesDisplay: '0',
      budgetSpent: 0,
      budgetTotal: 0,
      recentInvoices: [],
    );
  }

  /// Applies UI-safe defaults so missing, null-like, or placeholder strings do not break layout.
  /// Call with real [dashboardData] when [kUseHomeDashboardMockData] is false.
  factory HomeDashboardData.normalizedFrom(HomeDashboardData? raw) {
    if (raw == null) return HomeDashboardData.empty();
    return HomeDashboardData(
      totalExpensesDisplay: _coerceExpenseTotalDisplay(raw.totalExpensesDisplay),
      totalInvoicesDisplay: _coerceInvoiceCountDisplay(raw.totalInvoicesDisplay),
      budgetSpent: _coerceFiniteAmount(raw.budgetSpent),
      budgetTotal: _coerceFiniteAmount(raw.budgetTotal),
      recentInvoices: raw.recentInvoices.map(_normalizeInvoiceRow).toList(),
    );
  }

  static bool _isMissingOrPlaceholderString(String value) {
    final t = value.trim();
    if (t.isEmpty) return true;
    if (t == '—' || t == '-' || t == '–') return true;
    if (t.toLowerCase() == 'n/a' || t.toLowerCase() == 'null') return true;
    return false;
  }

  static String _coerceExpenseTotalDisplay(String value) {
    if (_isMissingOrPlaceholderString(value)) return '₱0';
    return value.trim();
  }

  static String _coerceInvoiceCountDisplay(String value) {
    if (_isMissingOrPlaceholderString(value)) return '0';
    return value.trim();
  }

  static double _coerceFiniteAmount(double value) {
    if (value.isNaN || !value.isFinite) return 0;
    return value;
  }

  static String _coerceInvoiceAmountDisplay(String amount) {
    final t = amount.trim();
    if (_isMissingOrPlaceholderString(t)) return '₱0.00';
    return t;
  }

  static String _coerceLabelOrDash(String value) {
    final t = value.trim();
    if (t.isEmpty) return '—';
    if (t.toLowerCase() == 'null') return '—';
    return t;
  }

  static Invoice _normalizeInvoiceRow(Invoice invoice) {
    return Invoice(
      _coerceLabelOrDash(invoice.vendor),
      _coerceLabelOrDash(invoice.category),
      _coerceInvoiceAmountDisplay(invoice.amount),
      invoice.date,
      invoice.time,
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback openBudget;
  final HomeDashboardData? dashboardData;

  const HomeScreen({super.key, required this.openBudget, this.dashboardData});

  HomeDashboardData get _data {
    if (kUseHomeDashboardMockData) return HomeDashboardData.mock();
    return HomeDashboardData.normalizedFrom(dashboardData);
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return PageFrame(
      title: 'Monthly Overview',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: StatCard(label: 'Total Expenses', value: data.totalExpensesDisplay)),
              const SizedBox(width: 16),
              Expanded(child: StatCard(label: 'Total Invoices', value: data.totalInvoicesDisplay)),
            ]),
            const SizedBox(height: 28),
            const Text('Budget', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Budget Limit', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text(data.budgetSummaryLine, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(data.budgetPercentLabel, style: const TextStyle(color: AppColors.muted)),
                  ]),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: data.budgetProgress,
                      minHeight: 11,
                      backgroundColor: const Color(0xFF4A4554),
                      valueColor: const AlwaysStoppedAnimation(AppColors.purple),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: openBudget,
                      icon: const Icon(Icons.chevron_right, size: 18),
                      label: const Text('Set Budget Here'),
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Invoices', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            InvoiceTable(invoices: data.recentInvoices),
          ],
        ),
      ),
    );
  }
}
