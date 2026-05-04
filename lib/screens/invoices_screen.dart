import 'package:flutter/material.dart';
import '../main.dart'; // AppColors, DemoData, PageFrame, FilterChipLite, InvoiceTable, Invoice

// -----------------------------------------------------------------------------
// Placeholder / mock controls (UI-only; no API). Real data flow uses `DemoData`.
// -----------------------------------------------------------------------------

/// When `true`, the table uses only [_localMockInvoices] so the screen is testable
/// without reading `DemoData`. When `false`, `DemoData.invoices` is the source.
const bool kInvoicesUseLocalMockDataOnly = true;

/// If the date filter yields zero rows, show dash placeholder rows instead of a
/// totally empty table body (stable layout; no crash).
const bool kInvoicesShowDashRowsWhenFilteredEmpty = true;

/// Sample rows for UI tests and for [kInvoicesUseLocalMockDataOnly].
final List<Invoice> _localMockInvoices = <Invoice>[
  Invoice('—', '—', '₱0.00', 'May 05, 2026', '09:15 AM'),
  Invoice('—', '—', '₱0.00', 'May 04, 2026', '06:40 PM'),
  Invoice('—', '—', '₱0.00', 'May 03, 2026', '11:05 AM'),
  Invoice('—', '—', '₱0.00', 'May 02, 2026', '08:22 PM'),
  Invoice('—', '—', '₱0.00', 'May 01, 2026', '03:00 PM'),
  Invoice('—', '—', '₱0.00', 'Apr 30, 2026', '12:00 PM'),
];

// --- Safe display fallbacks (mirror HomeScreen row normalization) -------------

bool _isMissingOrPlaceholderString(String value) {
  final t = value.trim();
  if (t.isEmpty) return true;
  if (t == '—' || t == '-' || t == '–') return true;
  if (t.toLowerCase() == 'n/a' || t.toLowerCase() == 'null') return true;
  return false;
}

String _coerceInvoiceAmountDisplay(String amount) {
  final t = amount.trim();
  if (_isMissingOrPlaceholderString(t)) return '₱0.00';
  if (t == '0' || t == '₱0' || t == '₱0.0' || t == '₱0.00') return '₱0.00';
  return t;
}

String _coerceLabelOrDash(String value) {
  final t = value.trim();
  if (t.isEmpty) return '—';
  if (t.toLowerCase() == 'null') return '—';
  return t;
}

Invoice _normalizeInvoiceRow(Invoice invoice) {
  return Invoice(
    _coerceLabelOrDash(invoice.vendor),
    _coerceLabelOrDash(invoice.category),
    _coerceInvoiceAmountDisplay(invoice.amount),
    invoice.date.trim().isEmpty ? '—' : invoice.date,
    invoice.time.trim().isEmpty ? '—' : invoice.time,
  );
}

List<Invoice> _normalizeInvoices(Iterable<Invoice> rows) => rows.map(_normalizeInvoiceRow).toList();

/// Parses `Apr 21, 2026`-style dates from the table; returns null if unknown (row still shown).
DateTime? _parseListDate(String raw) {
  final t = raw.trim();
  if (t.isEmpty || t == '—') return null;
  const months = <String, int>{
    'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
    'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
  };
  final m = RegExp(r'^([A-Za-z]{3})\s+(\d{1,2}),\s+(\d{4})$').firstMatch(t);
  if (m == null) return null;
  final mo = months[m.group(1)!];
  final day = int.tryParse(m.group(2)!);
  final year = int.tryParse(m.group(3)!);
  if (mo == null || day == null || year == null) return null;
  return DateTime(year, mo, day);
}

/// 0 = Date Range (all), 1 = Yesterday, 2 = Last 7, 3 = Last 15, 4 = Last 30
bool _invoiceMatchesDateFilter(Invoice invoice, int filterIndex) {
  if (filterIndex == 0) return true;
  final dt = _parseListDate(invoice.date);
  if (dt == null) return true;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(dt.year, dt.month, dt.day);

  if (filterIndex == 1) {
    final y = today.subtract(const Duration(days: 1));
    return d == y;
  }
  if (filterIndex == 2) {
    final start = today.subtract(const Duration(days: 7));
    return !d.isBefore(start) && !d.isAfter(today);
  }
  if (filterIndex == 3) {
    final start = today.subtract(const Duration(days: 15));
    return !d.isBefore(start) && !d.isAfter(today);
  }
  if (filterIndex == 4) {
    final start = today.subtract(const Duration(days: 30));
    return !d.isBefore(start) && !d.isAfter(today);
  }
  return true;
}

List<Invoice> _applyDateFilter(List<Invoice> normalized, int filterIndex) {
  return normalized.where((inv) => _invoiceMatchesDateFilter(inv, filterIndex)).toList();
}

List<Invoice> _dashPlaceholderRows(int count) {
  return List<Invoice>.generate(
    count,
    (_) => Invoice('—', '—', '₱0.00', '—', '—'),
  );
}

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  /// 0 Date Range, 1 Yesterday, 2 Last 7 Days, 3 Last 15 Days, 4 Last 30 Days
  int _dateFilterIndex = 0;

  List<Invoice> get _rawSource {
    if (kInvoicesUseLocalMockDataOnly) return List<Invoice>.from(_localMockInvoices);
    return List<Invoice>.from(DemoData.invoices);
  }

  List<Invoice> get _displayInvoices {
    final base = _normalizeInvoices(_rawSource);
    var filtered = _applyDateFilter(base, _dateFilterIndex);
    if (filtered.isEmpty && kInvoicesShowDashRowsWhenFilteredEmpty) {
      filtered = _dashPlaceholderRows(3);
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'All Invoices',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tappableFilterChip('Date Range', 0),
              _tappableFilterChip('Yesterday', 1),
              _tappableFilterChip('Last 7 Days', 2),
              _tappableFilterChip('Last 15 Days', 3),
              _tappableFilterChip('Last 30 Days', 4),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              child: InvoiceTable(invoices: _displayInvoices, clickable: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tappableFilterChip(String label, int index) {
    return InkWell(
      onTap: () => setState(() => _dateFilterIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: FilterChipLite(label),
    );
  }
}
