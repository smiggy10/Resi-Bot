import 'package:flutter/material.dart';
import '../main.dart'; // For AppColors, DemoData, PageFrame, AppCard, CategoryBar, InvoiceTable

// -----------------------------------------------------------------------------
// Placeholder / mock controls (UI-only; no API). Real data flow remains intact.
// -----------------------------------------------------------------------------

/// When `true`, Analytics uses local mock data so the UI is testable without any
/// backend integration. When `false`, it uses `DemoData` but still applies safe
/// placeholder fallbacks.
const bool kAnalyticsUseLocalMockDataOnly = true;

// --- Placeholder rules --------------------------------------------------------

bool _isMissingOrPlaceholderString(String value) {
  final t = value.trim();
  if (t.isEmpty) return true;
  if (t == '—' || t == '-' || t == '–') return true;
  if (t.toLowerCase() == 'n/a' || t.toLowerCase() == 'null') return true;
  return false;
}

String _labelOrDash(String value) => _isMissingOrPlaceholderString(value) ? '—' : value.trim();

double _finiteOrZero(num? value) {
  if (value == null) return 0;
  final d = value.toDouble();
  if (d.isNaN || !d.isFinite) return 0;
  return d;
}

String _currencyOrZero(String? value) {
  final t = (value ?? '').trim();
  if (_isMissingOrPlaceholderString(t)) return '₱0.00';
  if (t == '0' || t == '₱0' || t == '₱0.0' || t == '₱0.00') return '₱0.00';
  return t;
}

String _currencyFromAmount(double amount) {
  final safe = _finiteOrZero(amount);
  return '₱${safe.toStringAsFixed(2)}';
}

double _safePercent(double numerator, double denominator) {
  final n = _finiteOrZero(numerator);
  final d = _finiteOrZero(denominator);
  if (d <= 0) return 0;
  final v = n / d;
  if (v.isNaN || !v.isFinite) return 0;
  return v.clamp(0, 1);
}

// --- Mock datasets ------------------------------------------------------------

class _CategorySpendRow {
  final String label;
  final double amount;
  const _CategorySpendRow(this.label, this.amount);
}

const List<String> _monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

final List<double> _mockMonthlySpend = <double>[0, 0, 0, 0, 0, 0];

final List<_CategorySpendRow> _mockCategorySpend = <_CategorySpendRow>[
  const _CategorySpendRow('—', 0),
  const _CategorySpendRow('—', 0),
  const _CategorySpendRow('—', 0),
  const _CategorySpendRow('—', 0),
];

final List<Invoice> _mockTopVendors = <Invoice>[
  Invoice('—', '—', '₱0.00', '—', '—'),
  Invoice('—', '—', '₱0.00', '—', '—'),
  Invoice('—', '—', '₱0.00', '—', '—'),
  Invoice('—', '—', '₱0.00', '—', '—'),
];

Invoice _normalizeInvoiceRow(Invoice invoice) {
  return Invoice(
    _labelOrDash(invoice.vendor),
    _labelOrDash(invoice.category),
    _currencyOrZero(invoice.amount),
    _labelOrDash(invoice.date),
    _labelOrDash(invoice.time),
  );
}

List<Invoice> _normalizeInvoices(Iterable<Invoice> rows) => rows.map(_normalizeInvoiceRow).toList();

List<double> _normalizeMonthlyValues(List<double>? raw) {
  final src = raw ?? const <double>[];
  final out = List<double>.filled(_monthLabels.length, 0);
  for (var i = 0; i < out.length && i < src.length; i++) {
    out[i] = _finiteOrZero(src[i]);
  }
  return out;
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  List<double> get _monthlySpendValues {
    // No backend yet; keep it UI-only.
    if (kAnalyticsUseLocalMockDataOnly) return _normalizeMonthlyValues(_mockMonthlySpend);
    return _normalizeMonthlyValues(const <double>[]); // safe fallback (0s) if backend not wired
  }

  List<_CategorySpendRow> get _categorySpendRows {
    if (kAnalyticsUseLocalMockDataOnly) return _mockCategorySpend;
    return _mockCategorySpend; // safe placeholder until backend wiring
  }

  List<Invoice> get _topVendorInvoices {
    if (kAnalyticsUseLocalMockDataOnly) return _normalizeInvoices(_mockTopVendors);
    final safe = _normalizeInvoices(DemoData.invoices.take(4));
    return safe.isEmpty ? _normalizeInvoices(_mockTopVendors) : safe;
  }

  @override
  Widget build(BuildContext context) {
    final monthly = _monthlySpendValues;
    final categoryRows = _categorySpendRows;
    final categoryTotal = categoryRows.fold<double>(0, (sum, r) => sum + _finiteOrZero(r.amount));

    return PageFrame(
      title: 'Analytics',
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Spending Over Time (Jan - June)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        AppCard(
          child: SizedBox(
            height: 190,
            child: CustomPaint(
              painter: _AnalyticsLineChartPainter(values: monthly, labels: _monthLabels),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Spending by Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            children: categoryRows.isEmpty
                ? [
                    CategoryBar('—', '₱0.00', 0),
                    CategoryBar('—', '₱0.00', 0),
                    CategoryBar('—', '₱0.00', 0),
                    CategoryBar('—', '₱0.00', 0),
                  ]
                : categoryRows
                    .map(
                      (r) => CategoryBar(
                        _labelOrDash(r.label),
                        _currencyFromAmount(r.amount),
                        _safePercent(r.amount, categoryTotal),
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Top Vendors by Total Spend', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        InvoiceTable(invoices: _topVendorInvoices, compact: true),
      ])),
    );
  }
}

class _AnalyticsLineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  const _AnalyticsLineChartPainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withOpacity(.10)
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final safe = values.isEmpty ? List<double>.filled(labels.length, 0) : values;
    final clipped = List<double>.filled(labels.length, 0);
    for (var i = 0; i < clipped.length; i++) {
      final v = i < safe.length ? safe[i] : 0;
      clipped[i] = _finiteOrZero(v);
    }

    final maxV = clipped.fold<double>(0, (m, v) => v > m ? v : m);
    final denom = maxV <= 0 ? 1.0 : maxV;
    final chartBottom = size.height * .85;
    final chartTop = size.height * .12;
    final chartSpan = (chartBottom - chartTop).abs();

    final points = <Offset>[];
    for (var i = 0; i < clipped.length; i++) {
      final x = size.width * (clipped.length == 1 ? 0 : i / (clipped.length - 1));
      final pct = (clipped[i] / denom).clamp(0, 1);
      final y = chartBottom - (pct * chartSpan);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.purple.withOpacity(.75), AppColors.purple.withOpacity(.05)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fill, fillPaint);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.purple
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = AppColors.lightPurple);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(text: labels[i], style: const TextStyle(color: AppColors.muted, fontSize: 10));
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width * i / (labels.length - 1) - 8, size.height - 2));
    }
  }

  @override
  bool shouldRepaint(covariant _AnalyticsLineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
  }
}
