import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AppUser {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String plan;
  final String profilePicture;
  final String profilePictureName;
  final String profilePictureType;

  AppUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.plan,
    this.profilePicture = '',
    this.profilePictureName = '',
    this.profilePictureType = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      plan: json['plan']?.toString() ?? 'Free',

      // n8n can return either profilePicture or profilePictureUrl.
      // This makes sure Flutter accepts both.
      profilePicture: json['profilePictureUrl']?.toString().isNotEmpty == true
          ? json['profilePictureUrl'].toString()
          : json['profilePicture']?.toString() ?? '',

      profilePictureName: json['profilePictureName']?.toString() ?? '',
      profilePictureType: json['profilePictureType']?.toString() ?? '',
    );
  }
}

class AppSession {
  static AppUser? currentUser;

  static void login(AppUser user) {
    currentUser = user;
  }

  static void logout() {
    currentUser = null;
  }
}

class AuthService {
  static String get registerUrl => AppConfig.registerUrl;
  static String get loginUrl => AppConfig.loginUrl;

  static Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String plan,
    String profilePicture = '',
    String profilePictureName = '',
    String profilePictureType = '',
  }) async {
    final response = await http.post(
      Uri.parse(registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'phone': phone.trim(),
        'plan': plan,
        'profilePicture': profilePicture,
        'profilePictureName': profilePictureName,
        'profilePictureType': profilePictureType,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      final user = AppUser.fromJson(Map<String, dynamic>.from(data['user']));
      AppSession.login(user);
      return user;
    }

    throw Exception(data['message'] ?? 'Registration failed.');
  }

  static Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      final user = AppUser.fromJson(Map<String, dynamic>.from(data['user']));
      AppSession.login(user);
      return user;
    }

    throw Exception(data['message'] ?? 'Login failed.');
  }
}