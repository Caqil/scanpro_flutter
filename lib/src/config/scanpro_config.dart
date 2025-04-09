/// Configuration class for ScanPro Flutter plugin
class ScanProConfig {
  /// Base URL for the ScanPro API
  static String baseUrl = 'https://scanpro.cc';

  /// API key for authentication
  static String apiKey = '';

  /// Timeout duration for API requests (in seconds)
  static Duration timeout = const Duration(seconds: 60);

  /// Maximum file size for uploads (in bytes)
  /// Default: 100MB for free tier
  static int maxFileSize = 100 * 1024 * 1024;

  /// Configure the ScanPro plugin
  static void configure({
    String? baseUrl,
    String? apiKey,
    String? apiVersion,
    Duration? timeout,
    int? maxFileSize,
  }) {
    if (baseUrl != null) ScanProConfig.baseUrl = baseUrl;
    if (apiKey != null) ScanProConfig.apiKey = apiKey;
    if (timeout != null) ScanProConfig.timeout = timeout;
    if (maxFileSize != null) ScanProConfig.maxFileSize = maxFileSize;
  }

  /// Get the full API URL including version
  static String get apiUrl => baseUrl;
}
