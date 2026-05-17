import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/app_refresh_service.dart';

class _CategorySpendRow {
  final String label;
  final double amount;
  final String amountText;

  const _CategorySpendRow({
    required this.label,
    required this.amount,
    required this.amountText,
  });
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  List<String> _monthLabels = const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  List<double> _monthlySpend = const [0, 0, 0, 0, 0, 0];
  List<_CategorySpendRow> _categorySpend = const [];
  List<Invoice> _topVendors = const [];

  late final VoidCallback _refreshListener;

  @override
  void initState() {
    super.initState();

    _refreshListener = () {
      if (mounted) {
        _loadAnalytics();
      }
    };

    AppRefreshService.refreshTick.addListener(_refreshListener);

    _loadAnalytics();
  }

  @override
  void dispose() {
    AppRefreshService.refreshTick.removeListener(_refreshListener);
    super.dispose();
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();

    final cleaned = value
        ?.toString()
        .replaceAll('₱', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(cleaned ?? '') ?? 0;
  }

  String _currency(double amount) => '₱${amount.toStringAsFixed(2)}';

  String _capitalizeFirst(String value) {
    final text = value.trim();

    if (text.isEmpty || text == '-' || text == '—') {
      return '—';
    }

    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _loadAnalytics() async {
    try {
      final user = AppSession.currentUser;

      if (user == null || user.userId.isEmpty) {
        throw Exception('No logged-in user found.');
      }

      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      final response = await http
          .post(
            Uri.parse(AppConfig.analyticsUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': user.userId,
              'year': DateTime.now().year,
            }),
          )
          .timeout(const Duration(seconds: 60));

      Map<String, dynamic> data = {};

      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception(
          'Invalid response from n8n. Status: ${response.statusCode}. Body: ${response.body}',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to load analytics.');
      }

      final analytics = data['analytics'];

      if (analytics is! Map) {
        throw Exception('Analytics data was not found in response.');
      }

      final labels = <String>[];
      final labelRaw = analytics['monthLabels'];

      if (labelRaw is List) {
        labels.addAll(labelRaw.map((e) => e.toString()));
      }

      final monthly = <double>[];
      final monthlyRaw = analytics['monthlySpending'];

      if (monthlyRaw is List) {
        monthly.addAll(monthlyRaw.map(_asDouble));
      }

      final categories = <_CategorySpendRow>[];
      final categoryRaw = analytics['categorySpending'];

      if (categoryRaw is List) {
        for (final item in categoryRaw) {
          if (item is Map) {
            final amount = _asDouble(item['amount']);

            categories.add(
              _CategorySpendRow(
                label: item['category']?.toString() ?? 'Other',
                amount: amount,
                amountText: item['amountText']?.toString() ?? _currency(amount),
              ),
            );
          }
        }
      }

      final vendors = <Invoice>[];
      final vendorRaw = analytics['topVendors'];

      if (vendorRaw is List) {
        for (final item in vendorRaw) {
          if (item is Map) {
            final vendorName = _capitalizeFirst(
              item['vendor']?.toString() ??
                  item['store']?.toString() ??
                  '—',
            );

            vendors.add(
              Invoice(
                vendorName,
                item['category']?.toString() ??
                    '${item['invoiceCount'] ?? 0} invoices',
                item['amountText']?.toString() ?? '₱0.00',
                '—',
                '—',
              ),
            );
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _monthLabels = labels.isEmpty
            ? const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
            : labels;
        _monthlySpend = monthly.isEmpty
            ? const [0, 0, 0, 0, 0, 0]
            : monthly;
        _categorySpend = categories;
        _topVendors = vendors;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _monthLabels = const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
        _monthlySpend = const [0, 0, 0, 0, 0, 0];
        _categorySpend = const [];
        _topVendors = const [];
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  double _safePercent(double numerator, double denominator) {
    if (denominator <= 0) return 0;

    final value = numerator / denominator;

    if (value.isNaN || !value.isFinite) return 0;

    return value.clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotal = _categorySpend.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    return PageFrame(
      title: 'Analytics',
      child: RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(
                    color: AppColors.purple,
                    backgroundColor: Color(0xFF4A4554),
                  ),
                ),

              if (_hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unable to load analytics',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _loadAnalytics,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.lightPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const Text(
                'Spending Over Time (Jan - June)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              AppCard(
                child: SizedBox(
                  height: 190,
                  child: CustomPaint(
                    painter: _AnalyticsLineChartPainter(
                      values: _monthlySpend,
                      labels: _monthLabels,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Spending by Category',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              AppCard(
                child: Column(
                  children: _categorySpend.isEmpty
                      ? [
                          CategoryBar('—', '₱0.00', 0),
                          CategoryBar('—', '₱0.00', 0),
                          CategoryBar('—', '₱0.00', 0),
                          CategoryBar('—', '₱0.00', 0),
                        ]
                      : _categorySpend
                          .map(
                            (row) => CategoryBar(
                              row.label,
                              row.amountText,
                              _safePercent(row.amount, categoryTotal),
                            ),
                          )
                          .toList(),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Top Vendors by Total Spend',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              _topVendors.isEmpty
                  ? AppCard(
                      child: const Text(
                        'No vendor spending data yet.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : InvoiceTable(
                      invoices: _topVendors,
                      compact: true,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsLineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  const _AnalyticsLineChartPainter({
    required this.values,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withOpacity(.10)
      ..strokeWidth = 1;

    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final safeLabels = labels.isEmpty
        ? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
        : labels;

    final clipped = List<double>.filled(safeLabels.length, 0);

    for (var i = 0; i < clipped.length; i++) {
      clipped[i] = i < values.length ? values[i] : 0;
    }

    final maxV = clipped.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );

    final denom = maxV <= 0 ? 1.0 : maxV;
    final chartBottom = size.height * .85;
    final chartTop = size.height * .12;
    final chartSpan = (chartBottom - chartTop).abs();

    final points = <Offset>[];

    for (var i = 0; i < clipped.length; i++) {
      final x = size.width *
          (clipped.length == 1 ? 0 : i / (clipped.length - 1));

      final percent = (clipped[i] / denom).clamp(0.0, 1.0);
      final y = chartBottom - (percent * chartSpan);

      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.purple.withOpacity(.75),
          AppColors.purple.withOpacity(.05),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawPath(fill, fillPaint);

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.purple
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = AppColors.lightPurple);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < safeLabels.length; i++) {
      textPainter.text = TextSpan(
        text: safeLabels[i],
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 10,
        ),
      );

      textPainter.layout();

      final x = safeLabels.length == 1
          ? 0
          : size.width * i / (safeLabels.length - 1);

      textPainter.paint(
        canvas,
        Offset(x - 8, size.height - 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnalyticsLineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
  }
}