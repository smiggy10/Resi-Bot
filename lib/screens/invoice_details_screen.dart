import 'package:flutter/material.dart';
import '../main.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final dynamic invoice;

  final String? recordId;
  final String? store;
  final String? category;
  final String? amount;
  final String? date;
  final String? time;
  final String? receiptImageUrl;

  const InvoiceDetailsScreen({
    super.key,
    this.invoice,
    this.recordId,
    this.store,
    this.category,
    this.amount,
    this.date,
    this.time,
    this.receiptImageUrl,
  });

  String _capitalizeFirst(String value) {
    final text = value.trim();

    if (text.isEmpty || text == '-' || text == '—') {
      return '—';
    }

    return text[0].toUpperCase() + text.substring(1);
  }

  String _safeValue(dynamic value, {String fallback = '—'}) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  dynamic _readField(String fieldName) {
    if (invoice == null) return null;

    try {
      switch (fieldName) {
        case 'recordId':
          return invoice.recordId;
        case 'store':
          return invoice.store;
        case 'vendor':
          return invoice.vendor;
        case 'category':
          return invoice.category;
        case 'amount':
          return invoice.amount;
        case 'totalAmountSpent':
          return invoice.totalAmountSpent;
        case 'date':
          return invoice.date;
        case 'time':
          return invoice.time;
        case 'receiptImageUrl':
          return invoice.receiptImageUrl;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  String _getStore() {
    final value = store ??
        _readField('store') ??
        _readField('vendor') ??
        '';

    return _capitalizeFirst(_safeValue(value));
  }

  String _getCategory() {
    final value = category ?? _readField('category') ?? '';
    return _safeValue(value);
  }

  String _getAmount() {
    final value = amount ??
        _readField('amount') ??
        _readField('totalAmountSpent') ??
        '';

    final text = _safeValue(value, fallback: '₱0.00');

    if (text.startsWith('₱')) {
      return text;
    }

    return '₱$text';
  }

  String _getDate() {
    final value = date ?? _readField('date') ?? '';
    return _safeValue(value);
  }

  String _getTime() {
    final value = time ?? _readField('time') ?? '';
    return _safeValue(value, fallback: '');
  }

  String _getRecordId() {
    final value = recordId ?? _readField('recordId') ?? '';
    return _safeValue(value);
  }

  String _getImageUrl() {
    final value = receiptImageUrl ?? _readField('receiptImageUrl') ?? '';
    return _safeValue(value, fallback: '');
  }

  @override
  Widget build(BuildContext context) {
    final displayStore = _getStore();
    final displayCategory = _getCategory();
    final displayAmount = _getAmount();
    final displayDate = _getDate();
    final displayTime = _getTime();
    final displayRecordId = _getRecordId();
    final displayImageUrl = _getImageUrl();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Invoice Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.receipt_long,
                    color: AppColors.purple,
                  ),
                  const SizedBox(width: 12),
                ],
              ),

              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.purple,
                            child: Text(
                              displayStore.isNotEmpty && displayStore != '—'
                                  ? displayStore[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayStore,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  displayCategory,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withOpacity(.35),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.purple,
                              ),
                            ),
                            child: Text(
                              displayCategory,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Text(
                        displayAmount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        displayTime.isNotEmpty
                            ? '$displayDate • $displayTime'
                            : displayDate,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 20),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          height: 300,
                          color: AppColors.card,
                          child: displayImageUrl.isNotEmpty
                              ? Image.network(
                                  displayImageUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }

                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.purple,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(
                                          'Receipt image could not be loaded.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'No receipt image available.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Extracted Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      AppCard(
                        child: Column(
                          children: [
                            _DetailRow(
                              label: 'Vendor',
                              value: displayStore,
                            ),
                            _DetailRow(
                              label: 'Category',
                              value: displayCategory,
                            ),
                            _DetailRow(
                              label: 'Amount',
                              value: displayAmount,
                            ),
                            _DetailRow(
                              label: 'Date',
                              value: displayDate,
                            ),
                            _DetailRow(
                              label: 'Time',
                              value: displayTime.isNotEmpty
                                  ? displayTime
                                  : '—',
                            ),
                            _DetailRow(
                              label: 'Record ID',
                              value: displayRecordId,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}