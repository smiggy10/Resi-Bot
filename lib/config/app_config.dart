class AppConfig {
  // Default n8n instance URL - can be changed at runtime
  static String _n8nBaseUrl = 'https://resibot.app.n8n.cloud';
  
  // Webhook endpoints
  static const String registerWebhook = 'resibot-register';
  static const String loginWebhook = 'resibot-login';
  
  // Getters for webhook URLs
  static String get registerUrl => '$_n8nBaseUrl/webhook/$registerWebhook';
  static String get loginUrl => '$_n8nBaseUrl/webhook/$loginWebhook';
  
  // Getters and setters for base URL
  static String get n8nBaseUrl => _n8nBaseUrl;
  
  static void setN8nBaseUrl(String url) {
    // Ensure URL doesn't end with slash
    _n8nBaseUrl = url.replaceAll(RegExp(r'/+$'), '');
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
  
  // Get all available webhooks (for display purposes)
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
  ];
}
