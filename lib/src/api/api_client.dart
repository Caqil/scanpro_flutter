import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:scanpro_dart/scanpro_dart.dart';
/// Main API client for ScanPro
class ApiClient {
  /// HTTP client
  final http.Client _client = http.Client();

  /// Endpoints
  late final ConversionApi conversion = ConversionApi(this);
  late final PdfToolsApi pdfTools = PdfToolsApi(this);
  late final SecurityApi security = SecurityApi(this);
  late final OcrApi ocr = OcrApi(this);

  /// Constructor
  ApiClient() {
    if (ScanProConfig.apiKey.isEmpty) {
      throw Exception(
        'ScanPro API key is not set. Call ScanPro.initialize() first.',
      );
    }
  }

  /// Add authentication headers to requests
  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    return {
      'x-api-key': ScanProConfig.apiKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?additionalHeaders,
    };
  }

  /// Make a GET request
  Future<ApiResponse> get(
    String endpoint, {
    Map<String, String>? params,
  }) async {
    try {
      final uri = Uri.parse(
        '${ScanProConfig.apiUrl}$endpoint',
      ).replace(queryParameters: params);

      final response = await _client
          .get(uri, headers: _getHeaders())
          .timeout(ScanProConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Make a POST request with JSON body
  Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? params,
  }) async {
    try {
      final uri = Uri.parse(
        '${ScanProConfig.apiUrl}$endpoint',
      ).replace(queryParameters: params);

      final response = await _client
          .post(
            uri,
            headers: _getHeaders(),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(ScanProConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Make a POST request with file upload
  Future<ApiResponse> uploadFile(
    String endpoint,
    String fieldName,
    File file, {
    Map<String, String>? fields,
    String? fileNameField,
  }) async {
    try {
      final uri = Uri.parse('${ScanProConfig.apiUrl}$endpoint');

      final request = http.MultipartRequest('POST', uri);

      // Add API key header
      request.headers.addAll({'x-api-key': ScanProConfig.apiKey});

      // Get file details
      final fileName = file.path.split('/').last;
      final fileBytes = await file.readAsBytes();
      final fileSize = fileBytes.length;

      // Check file size
      if (fileSize > ScanProConfig.maxFileSize) {
        return ApiResponse(
          success: false,
          error:
              'File size exceeds maximum allowed size of ${ScanProConfig.maxFileSize ~/ (1024 * 1024)}MB',
        );
      }

      // Determine content type based on file extension
      final fileExtension = fileName.split('.').last.toLowerCase();
      String contentType;

      switch (fileExtension) {
        case 'pdf':
          contentType = 'application/pdf';
          break;
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'docx':
          contentType =
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          break;
        case 'xlsx':
          contentType =
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
          break;
        case 'pptx':
          contentType =
              'application/vnd.openxmlformats-officedocument.presentationml.presentation';
          break;
        default:
          contentType = 'application/octet-stream';
      }

      // Add the file
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      );

      // Add filename field if provided
      if (fileNameField != null) {
        request.fields[fileNameField] = fileName;
      }

      // Add additional fields if provided
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Send the request
      final streamedResponse = await request.send().timeout(
            ScanProConfig.timeout,
          );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Handle API response
  ApiResponse _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          data: data,
          statusCode: response.statusCode,
        );
      } else {
        String errorMessage = 'An error occurred';

        if (data is Map && data.containsKey('error')) {
          errorMessage = data['error'].toString();
        }

        return ApiResponse(
          success: false,
          error: errorMessage,
          statusCode: response.statusCode,
          data: data,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Failed to parse response: ${e.toString()}',
        statusCode: response.statusCode,
        data: response.body,
      );
    }
  }
}

/// Base class for all API endpoints
abstract class BaseApi {
  final ApiClient _client;

  BaseApi(this._client);

  ApiClient get client => _client;
}
