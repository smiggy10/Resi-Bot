import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/app_refresh_service.dart';
import 'invoice_details_screen.dart';

class _InvoiceItem {
  final String recordId;
  final String vendor;
  final String category;
  final String amountText;
  final String date;
  final String time;
  final String receiptImageUrl;

  const _InvoiceItem({
    required this.recordId,
    required this.vendor,
    required this.category,
    required this.amountText,
    required this.date,
    required this.time,
    required this.receiptImageUrl,
  });

  Invoice get asInvoice => Invoice(vendor, category, amountText, date, time);

  factory _InvoiceItem.fromJson(Map<String, dynamic> json) {
    return _InvoiceItem(
      recordId: json['recordId']?.toString() ?? '',
      vendor: _capitalizeFirst(
        _safeText(json['vendor'] ?? json['store'], fallback: '—'),
      ),
      category: _safeText(json['category'], fallback: '—'),
      amountText: _safeText(
        json['amountText'] ??
            json['totalAmountSpentText'] ??
            json['totalAmountSpent'],
        fallback: '₱0.00',
      ),
      date: _safeText(json['date'] ?? json['rawDate'], fallback: '—'),
      time: _safeText(json['time'], fallback: '—'),
      receiptImageUrl: json['receiptImageUrl']?.toString() ?? '',
    );
  }

  static String _capitalizeFirst(String value) {
    final text = value.trim();

    if (text.isEmpty || text == '-' || text == '—') {
      return '—';
    }

    return text[0].toUpperCase() + text.substring(1);
  }

  static String _safeText(dynamic value, {required String fallback}) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
    return text;
  }
}

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  int _dateFilterIndex = 0;
  DateTimeRange? _customRange;
  List<_InvoiceItem> _invoices = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  late final VoidCallback _refreshListener;

  @override
  void initState() {
    super.initState();

    _refreshListener = () {
      if (mounted) {
        _loadInvoices();
      }
    };

    AppRefreshService.refreshTick.addListener(_refreshListener);

    _loadInvoices();
  }

  @override
  void dispose() {
    AppRefreshService.refreshTick.removeListener(_refreshListener);
    super.dispose();
  }

  String get _filterValue {
    switch (_dateFilterIndex) {
      case 1:
        return 'yesterday';
      case 2:
        return 'last7';
      case 3:
        return 'last15';
      case 4:
        return 'last30';
      default:
        return _customRange == null ? 'all' : 'dateRange';
    }
  }

  String _dateOnly(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _loadInvoices() async {
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

      final body = <String, dynamic>{
        'userId': user.userId,
        'filter': _filterValue,
      };

      if (_filterValue == 'dateRange' && _customRange != null) {
        body['startDate'] = _dateOnly(_customRange!.start);
        body['endDate'] = _dateOnly(_customRange!.end);
      }

      final response = await http
          .post(
            Uri.parse(AppConfig.invoicesUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
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
        throw Exception(data['message'] ?? 'Failed to load invoices.');
      }

      final rawInvoices = data['invoices'];
      final loaded = <_InvoiceItem>[];

      if (rawInvoices is List) {
        for (final item in rawInvoices) {
          if (item is Map) {
            loaded.add(_InvoiceItem.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _invoices = loaded;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _invoices = [];
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _selectFilter(int index) async {
    if (index == 0) {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 3),
        lastDate: DateTime(now.year + 1),
        initialDateRange: _customRange,
      );

      if (picked != null) {
        setState(() {
          _dateFilterIndex = 0;
          _customRange = picked;
        });
        await _loadInvoices();
      } else {
        setState(() {
          _dateFilterIndex = 0;
          _customRange = null;
        });
        await _loadInvoices();
      }
      return;
    }

    setState(() {
      _dateFilterIndex = index;
      _customRange = null;
    });

    await _loadInvoices();
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
              _tappableFilterChip(
                _customRange == null ? 'Date Range' : 'Custom Range',
                0,
              ),
              _tappableFilterChip('Yesterday', 1),
              _tappableFilterChip('Last 7 Days', 2),
              _tappableFilterChip('Last 15 Days', 3),
              _tappableFilterChip('Last 30 Days', 4),
            ],
          ),

          const SizedBox(height: 14),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(
                color: AppColors.purple,
                backgroundColor: Color(0xFF4A4554),
              ),
            ),

          if (_hasError)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unable to load invoices',
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
                      onPressed: _loadInvoices,
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

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadInvoices,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _invoices.isEmpty
                    ? AppCard(
                        child: const Text(
                          'No invoices found for this filter.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      )
                    : _InvoicesTable(invoices: _invoices),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tappableFilterChip(String label, int index) {
    final active = _dateFilterIndex == index;

    return InkWell(
      onTap: () => _selectFilter(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.purple : AppColors.purple.withOpacity(.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.purple.withOpacity(.45)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}

class _InvoicesTable extends StatelessWidget {
  final List<_InvoiceItem> invoices;

  const _InvoicesTable({required this.invoices});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Vendor',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Category',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                'Amount',
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const Divider(color: Color(0xFF3A3846)),

          ...invoices.map(
            (invoice) => InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InvoiceDetailsScreen(
                      invoice: invoice.asInvoice,
                      recordId: invoice.recordId,
                      receiptImageUrl: invoice.receiptImageUrl,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8B190),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        size: 14,
                        color: AppColors.bg,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        invoice.vendor,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Text(
                        invoice.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    Text(
                      invoice.amountText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}