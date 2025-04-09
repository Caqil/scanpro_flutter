/// API response model
class ApiResponse {
  /// Whether the request was successful
  final bool success;

  /// Response data (if successful)
  final dynamic data;

  /// Error message (if unsuccessful)
  final String? error;

  /// HTTP status code
  final int? statusCode;

  /// Constructor
  ApiResponse({required this.success, this.data, this.error, this.statusCode});

  /// Get a specific field from the data
  T? getField<T>(String fieldName) {
    if (data is Map && data.containsKey(fieldName)) {
      return data[fieldName] as T?;
    }
    return null;
  }

  /// Get the file URL from the response
  String? get fileUrl => getField<String>('fileUrl');

  /// Get the file name from the response
  String? get fileName =>
      getField<String>('fileName') ?? getField<String>('filename');

  /// Get a message from the response
  String? get message => getField<String>('message');

  /// Check if there was a rate limit error
  bool get isRateLimitError => statusCode == 429;

  /// Check if there was an authentication error
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Check if there was a server error
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Get a user-friendly error message
  String get userFriendlyError {
    if (error != null && error!.isNotEmpty) {
      return error!;
    }

    if (isRateLimitError) {
      return 'Rate limit exceeded. Please try again later.';
    } else if (isAuthError) {
      return 'Authentication failed. Please check your API key.';
    } else if (isServerError) {
      return 'Server error. Please try again later.';
    }

    return 'An unknown error occurred.';
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, data: $data, error: $error, statusCode: $statusCode}';
  }
}
