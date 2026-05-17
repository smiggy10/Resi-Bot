import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'auth_service.dart';

class ExportDataService {
  static Future<void> exportAllUserData() async {
    final user = AppSession.currentUser;

    if (user == null || user.userId.isEmpty) {
      throw Exception('No logged-in user found.');
    }

    final now = DateTime.now();

    final homeResponse = await http
        .post(
          Uri.parse(AppConfig.homeUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': user.userId,
            'month': now.month,
            'year': now.year,
          }),
        )
        .timeout(const Duration(seconds: 60));

    final invoicesResponse = await http
        .post(
          Uri.parse(AppConfig.invoicesUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': user.userId,
            'filter': 'all',
          }),
        )
        .timeout(const Duration(seconds: 60));

    final homeData = _decodeResponse(homeResponse);
    final invoicesData = _decodeResponse(invoicesResponse);

    final home = homeData['home'] is Map
        ? Map<String, dynamic>.from(homeData['home'])
        : <String, dynamic>{};

    final invoicesRaw = invoicesData['invoices'];
    final invoices = invoicesRaw is List ? invoicesRaw : [];

    final csv = _buildCsv(
      userId: user.userId,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      plan: user.plan,
      home: home,
      invoices: invoices,
    );

    final fileName =
        'resibot_export_${user.userId}_${_dateOnly(DateTime.now())}';

    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(utf8.encode(csv)),
      ext: 'csv',
      mimeType: MimeType.csv,
    );
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
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
      throw Exception(data['message'] ?? 'Failed to export data.');
    }

    return data;
  }

  static String _buildCsv({
    required String userId,
    required String fullName,
    required String email,
    required String phone,
    required String plan,
    required Map<String, dynamic> home,
    required List invoices,
  }) {
    final rows = <List<dynamic>>[];

    rows.add([
      'Data Type',
      'User ID',
      'Full Name',
      'Email',
      'Phone',
      'Plan',
      'Month',
      'Year',
      'Total Spent',
      'Total Invoices',
      'Budget Limit',
      'Budget Remaining',
      'Over Budget',
      'Invoice Record ID',
      'Store/Vendor',
      'Category',
      'Amount',
      'Date',
      'Time',
      'Processing Status',
      'Receipt Image URL',
    ]);

    rows.add([
      'User Profile',
      userId,
      fullName,
      email,
      phone,
      plan,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);

    rows.add([
      'Budget Summary',
      userId,
      fullName,
      email,
      phone,
      plan,
      home['month'] ?? '',
      home['year'] ?? '',
      home['totalSpentText'] ?? home['totalSpent'] ?? '',
      home['totalInvoices'] ?? '',
      home['budgetLimitText'] ?? home['budgetLimit'] ?? '',
      home['budgetRemainingText'] ?? home['budgetRemaining'] ?? '',
      home['overBudgetText'] ?? home['overBudgetAmount'] ?? '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ]);

    for (final item in invoices) {
      if (item is! Map) continue;

      rows.add([
        'Invoice',
        item['userId'] ?? userId,
        fullName,
        email,
        phone,
        plan,
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        item['recordId'] ?? '',
        item['vendor'] ?? item['store'] ?? '',
        item['category'] ?? '',
        item['amountText'] ?? item['totalAmountSpentText'] ?? item['amount'] ?? '',
        item['date'] ?? item['rawDate'] ?? '',
        item['time'] ?? '',
        item['processingStatus'] ?? '',
        item['receiptImageUrl'] ?? '',
      ]);
    }

    return rows.map(_csvRow).join('\n');
  }

  static String _csvRow(List<dynamic> values) {
    return values.map(_csvEscape).join(',');
  }

  static String _csvEscape(dynamic value) {
    final text = value?.toString() ?? '';
    final escaped = text.replaceAll('"', '""');

    if (escaped.contains(',') ||
        escaped.contains('"') ||
        escaped.contains('\n') ||
        escaped.contains('\r')) {
      return '"$escaped"';
    }

    return escaped;
  }

  static String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}