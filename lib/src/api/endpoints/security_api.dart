import 'dart:io';
import 'dart:convert';
import '../api_client.dart';
import '../models/api_response.dart';
import '../models/security_models.dart';

/// API endpoints for PDF security
class SecurityApi extends BaseApi {
  /// Constructor
  SecurityApi(super.client);

  /// Protect a PDF with a password
  ///
  /// [file] PDF file to protect
  /// [options] Protection options
  Future<ApiResponse> protectPdf(File file, ProtectPdfOptions options) async {
    return client.uploadFile(
      '/api/pdf/protect',
      'file',
      file,
      fields: options.toParams(),
    );
  }

  /// Unlock a password-protected PDF
  ///
  /// [file] Password-protected PDF file
  /// [password] PDF password
  Future<ApiResponse> unlockPdf(File file, String password) async {
    return client.uploadFile(
      '/api/pdf/unlock',
      'file',
      file,
      fields: {'password': password},
    );
  }

  /// Sign a PDF document
  ///
  /// [file] PDF file to sign
  /// [options] Signing options
  Future<ApiResponse> signPdf(File file, SignPdfOptions options) async {
    return client.uploadFile(
      '/api/pdf/sign',
      'file',
      file,
      fields: {
        'elements': json.encode(
          options.elements.map((e) => e.toJson()).toList(),
        ),
        'pages': json.encode(options.pages.map((p) => p.toJson()).toList()),
        'performOcr': options.performOcr.toString(),
        'ocrLanguage': options.ocrLanguage,
      },
    );
  }
}
