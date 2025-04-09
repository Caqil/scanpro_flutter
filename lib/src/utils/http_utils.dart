import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart'
    as http_parser; // Added for MediaType
import '../config/scanpro_config.dart';

/// Utility class for HTTP operations
class HttpUtils {
  /// Create a multipart request for file upload
  ///
  /// [url] URL for the request
  /// [method] HTTP method
  /// [headers] HTTP headers
  /// [body] Request body
  /// [files] Files to upload
  static Future<http.Response> uploadFiles({
    required String url,
    String method = 'POST',
    Map<String, String>? headers,
    Map<String, String>? body,
    required Map<String, File> files,
  }) async {
    try {
      // Create multipart request
      final uri = Uri.parse(url);
      final request = http.MultipartRequest(method, uri);

      // Add headers
      if (headers != null) {
        request.headers.addAll(headers);
      }

      // Add fields
      if (body != null) {
        request.fields.addAll(body);
      }

      // Add files
      for (final entry in files.entries) {
        final fieldName = entry.key;
        final file = entry.value;

        final fileName = basename(file.path);
        final mimeType =
            lookupMimeType(file.path) ?? 'application/octet-stream';

        final fileBytes = await file.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            fileBytes,
            filename: fileName,
            contentType: http_parser.MediaType.parse(
              mimeType,
            ), // Use http_parser.MediaType
          ),
        );
      }

      // Send request
      final streamedResponse = await request.send().timeout(
            ScanProConfig.timeout,
          );
      final response = await http.Response.fromStream(streamedResponse);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading files: $e');
      }
      rethrow;
    }
  }

  /// Parse JSON from string
  ///
  /// [jsonString] JSON string
  static dynamic parseJson(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing JSON: $e');
      }
      return null;
    }
  }

  /// Get a URL with query parameters
  ///
  /// [baseUrl] Base URL
  /// [path] Path to append to the base URL
  /// [queryParams] Query parameters
  static String getUrl(
    String baseUrl,
    String path, {
    Map<String, String>? queryParams,
  }) {
    var uri = Uri.parse('$baseUrl$path');

    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    return uri.toString();
  }

  /// Get content type for a file extension
  ///
  /// [extension] File extension
  static String getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'html':
        return 'text/html';
      default:
        return 'application/octet-stream';
    }
  }
}
