import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'auth_service.dart';

class BudgetService {
  static Future<Map<String, dynamic>> setMonthlyBudget({
    required double budgetLimit,
  }) async {
    final user = AppSession.currentUser;

    if (user == null || user.userId.isEmpty) {
      throw Exception('No logged-in user found.');
    }

    if (budgetLimit <= 0) {
      throw Exception('Budget limit must be greater than zero.');
    }

    final now = DateTime.now();
    final endDate = _addOneMonth(now);

    final response = await http
        .post(
          Uri.parse(AppConfig.setBudgetUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'userId': user.userId,
            'budgetLimit': budgetLimit,
            'budgetPeriod': 'Monthly',
            'budgetStartDate': _dateOnly(now),
            'budgetEndDate': _dateOnly(endDate),
          }),
        )
        .timeout(const Duration(seconds: 30));

    Map<String, dynamic> data;

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
      throw Exception(data['message'] ?? 'Failed to save budget.');
    }

    return data;
  }

  static DateTime _addOneMonth(DateTime date) {
    final nextMonth = date.month == 12 ? 1 : date.month + 1;
    final nextYear = date.month == 12 ? date.year + 1 : date.year;
    final lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
    final safeDay = min(date.day, lastDayOfNextMonth);

    return DateTime(
      nextYear,
      nextMonth,
      safeDay,
      date.hour,
      date.minute,
      date.second,
    );
  }

  static String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
