import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../main.dart'; // AppColors, PageFrame, StatCard, AppCard, InvoiceTable, Invoice
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/app_refresh_service.dart';

class HomeDashboardData {
  final String totalExpensesDisplay;
  final String totalInvoicesDisplay;
  final double budgetSpent;
  final double budgetTotal;
  final double overBudgetAmount;
  final bool isOverBudget;
  final List<Invoice> recentInvoices;

  const HomeDashboardData({
    required this.totalExpensesDisplay,
    required this.totalInvoicesDisplay,
    required this.budgetSpent,
    required this.budgetTotal,
    required this.overBudgetAmount,
    required this.isOverBudget,
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
    if (budgetTotal <= 0) return '0%';

    final percent = (budgetSpent / budgetTotal) * 100;

    if (percent.isNaN || !percent.isFinite) return '0%';

    return '${percent.round()}%';
  }

  String get budgetStatusText {
    if (budgetTotal <= 0) {
      return 'No budget limit set yet.';
    }

    if (isOverBudget) {
      return 'Over budget by ₱${_formatIntWithCommas(overBudgetAmount.round())}';
    }

    final remaining = budgetTotal - budgetSpent;
    return 'Remaining budget: ₱${_formatIntWithCommas(remaining.round())}';
  }

  static String _formatIntWithCommas(int n) {
    final s = n.abs().toString();
    final buf = StringBuffer();

    if (n < 0) buf.write('-');

    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buf.write(',');
      }
      buf.write(s[i]);
    }

    return buf.toString();
  }

  factory HomeDashboardData.empty() {
    return const HomeDashboardData(
      totalExpensesDisplay: '₱0',
      totalInvoicesDisplay: '0',
      budgetSpent: 0,
      budgetTotal: 0,
      overBudgetAmount: 0,
      isOverBudget: false,
      recentInvoices: [],
    );
  }

  factory HomeDashboardData.fromJson(Map<String, dynamic> json) {
    final recentRaw = json['recentInvoices'];

    final recentInvoices = <Invoice>[];

    if (recentRaw is List) {
      for (final item in recentRaw) {
        if (item is Map) {
          recentInvoices.add(
            Invoice(
              _capitalizeFirst(
                _stringValue(
                  item['store'] ?? item['vendor'] ?? item['Store'] ?? '—',
                ),
              ),
              _stringValue(
                item['category'] ?? item['Category'] ?? '—',
              ),
              _stringValue(
                item['amountText'] ??
                    item['totalAmountSpentText'] ??
                    item['totalAmountSpent'] ??
                    item['amount'] ??
                    '₱0.00',
              ),
              _stringValue(
                item['date'] ?? item['receiptDate'] ?? item['Receipt Date'] ?? '',
              ),
              _stringValue(
                item['time'] ?? '',
              ),
            ),
          );
        }
      }
    }

    return HomeDashboardData(
      totalExpensesDisplay: _stringValue(
        json['totalSpentText'] ?? json['totalExpensesDisplay'] ?? '₱0',
      ),
      totalInvoicesDisplay: _stringValue(
        json['totalInvoices'] ?? json['totalInvoicesDisplay'] ?? '0',
      ),
      budgetSpent: _doubleValue(
        json['totalSpent'] ?? json['budgetSpent'] ?? 0,
      ),
      budgetTotal: _doubleValue(
        json['budgetLimit'] ?? json['budgetTotal'] ?? 0,
      ),
      overBudgetAmount: _doubleValue(
        json['overBudgetAmount'] ?? 0,
      ),
      isOverBudget: json['isOverBudget'] == true,
      recentInvoices: recentInvoices,
    );
  }

  static String _capitalizeFirst(String value) {
    final text = value.trim();

    if (text.isEmpty || text == '-' || text == '—') {
      return '—';
    }

    return text[0].toUpperCase() + text.substring(1);
  }

  static String _stringValue(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return '';
    }

    return text;
  }

  static double _doubleValue(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    final cleaned = value
        .toString()
        .replaceAll('₱', '')
        .replaceAll(',', '')
        .replaceAll('PHP', '')
        .trim();

    return double.tryParse(cleaned) ?? 0;
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback openBudget;

  const HomeScreen({
    super.key,
    required this.openBudget,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeDashboardData dashboardData = HomeDashboardData.empty();

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  late final VoidCallback _refreshListener;

  @override
  void initState() {
    super.initState();

    _refreshListener = () {
      if (mounted) {
        _loadHomeDashboard();
      }
    };

    AppRefreshService.refreshTick.addListener(_refreshListener);

    _loadHomeDashboard();
  }

  @override
  void dispose() {
    AppRefreshService.refreshTick.removeListener(_refreshListener);
    super.dispose();
  }

  Future<void> _loadHomeDashboard() async {
    try {
      final user = AppSession.currentUser;

      if (user == null || user.userId.isEmpty) {
        throw Exception('No logged-in user found.');
      }

      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = '';
      });

      final now = DateTime.now();

      final response = await http
          .post(
            Uri.parse(AppConfig.homeUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userId': user.userId,
              'month': now.month,
              'year': now.year,
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
        throw Exception(data['message'] ?? 'Failed to load home dashboard.');
      }

      final homeRaw = data['home'];

      if (homeRaw is! Map) {
        throw Exception('Home dashboard data was not found in response.');
      }

      if (!mounted) return;

      setState(() {
        dashboardData = HomeDashboardData.fromJson(
          Map<String, dynamic>.from(homeRaw),
        );
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        dashboardData = HomeDashboardData.empty();
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Monthly Overview',
      child: RefreshIndicator(
        onRefresh: _loadHomeDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(
                    color: AppColors.purple,
                    backgroundColor: Color(0xFF4A4554),
                  ),
                ),

              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unable to load dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          errorMessage,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: _loadHomeDashboard,
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

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Total Expenses',
                      value: dashboardData.totalExpensesDisplay,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      label: 'Total Invoices',
                      value: dashboardData.totalInvoicesDisplay,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'Budget',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget Limit',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dashboardData.budgetSummaryLine,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          dashboardData.budgetPercentLabel,
                          style: TextStyle(
                            color: dashboardData.isOverBudget
                                ? Colors.redAccent
                                : AppColors.muted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: dashboardData.budgetProgress,
                        minHeight: 11,
                        backgroundColor: const Color(0xFF4A4554),
                        valueColor: AlwaysStoppedAnimation(
                          dashboardData.isOverBudget
                              ? Colors.redAccent
                              : AppColors.purple,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      dashboardData.budgetStatusText,
                      style: TextStyle(
                        color: dashboardData.isOverBudget
                            ? Colors.redAccent
                            : AppColors.muted,
                        fontSize: 12,
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: widget.openBudget,
                        icon: const Icon(Icons.chevron_right, size: 18),
                        label: const Text('Set Budget Here'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Invoices',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loadHomeDashboard,
                    icon: const Icon(
                      Icons.refresh,
                      color: AppColors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (dashboardData.recentInvoices.isEmpty)
                AppCard(
                  child: const Text(
                    'No processed receipts yet.',
                    style: TextStyle(
                      color: AppColors.muted,
                    ),
                  ),
                )
              else
                InvoiceTable(
                  invoices: dashboardData.recentInvoices,
                ),
            ],
          ),
        ),
      ),
    );
  }
}