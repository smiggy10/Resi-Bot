class AppConfig {
  // Default n8n instance URL - can be changed at runtime
  static String _n8nBaseUrl = 'https://resibot.app.n8n.cloud';

  // Use true while testing with "Listen for test event" in n8n.
  // Use false once your workflow is active/live.
  static bool useTestWebhook = false;

  // Webhook endpoints
  static const String registerWebhook = 'resibot-register';
  static const String loginWebhook = 'resibot-login';
  static const String receiptWebhook = 'resibot-receipt';
  static const String homeWebhook = 'resibot-home';

  // Helper for webhook path
  static String get _webhookPath => useTestWebhook ? 'webhook-test' : 'webhook';

  // Getters for webhook URLs
  static String get registerUrl => '$_n8nBaseUrl/webhook/$registerWebhook';
  static String get loginUrl => '$_n8nBaseUrl/webhook/$loginWebhook';

  // Receipt processing URL
  static String get receiptUrl => '$_n8nBaseUrl/$_webhookPath/$receiptWebhook';

  // Home dashboard data URL
  static String get homeUrl => '$_n8nBaseUrl/$_webhookPath/$homeWebhook';

  // Getters and setters for base URL
  static String get n8nBaseUrl => _n8nBaseUrl;

  static void setN8nBaseUrl(String url) {
    // Ensure URL doesn't end with slash
    _n8nBaseUrl = url.replaceAll(RegExp(r'/+$'), '');
  }

  static void setUseTestWebhook(bool value) {
    useTestWebhook = value;
  }

  // Validate URL format
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Get all available webhooks for display purposes
  static List<Map<String, String>> get availableWebhooks => [
        {
          'name': 'Register',
          'endpoint': registerWebhook,
          'url': registerUrl,
        },
        {
          'name': 'Login',
          'endpoint': loginWebhook,
          'url': loginUrl,
        },
        {
          'name': 'Receipt Processing',
          'endpoint': receiptWebhook,
          'url': receiptUrl,
        },
        {
          'name': 'Home Dashboard',
          'endpoint': homeWebhook,
          'url': homeUrl,
        },
      ];
}