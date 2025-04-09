library scanpro_flutter;

import 'package:flutter/foundation.dart';
import 'package:scanpro_dart/scanpro_flutter.dart';

// Export all APIs
export 'src/api/api_client.dart';
export 'src/api/endpoints/conversion_api.dart';
export 'src/api/endpoints/pdf_tools_api.dart';
export 'src/api/endpoints/security_api.dart';
export 'src/api/endpoints/ocr_api.dart';

// Export models
export 'src/api/models/api_response.dart';
export 'src/api/models/conversion_models.dart';
export 'src/api/models/pdf_models.dart';
export 'src/api/models/security_models.dart';

// Export config
export 'src/config/scanpro_config.dart';

/// Main ScanPro API client class that provides access to all ScanPro services
class ScanPro {
  /// Initialize ScanPro with your API key
  static void initialize({required String apiKey}) {
    ScanProConfig.apiKey = apiKey;
    if (kDebugMode) {
      print('ScanPro initialized with API key');
    }
  }

  /// Get the API client
  static ApiClient get api => ApiClient();

  /// Check if the ScanPro plugin has been initialized with an API key
  static bool get isInitialized => ScanProConfig.apiKey.isNotEmpty;
}
