import 'dart:io';
import '../api_client.dart';
import '../models/api_response.dart';
import '../models/ocr_models.dart';

/// API endpoints for OCR
class OcrApi extends BaseApi {
  /// Constructor
  OcrApi(super.client);

  /// Perform OCR on a PDF file
  ///
  /// [file] PDF file to process
  /// [options] OCR options
  Future<ApiResponse> performOcr(File file, {OcrOptions? options}) async {
    options ??= OcrOptions();

    return client.uploadFile(
      '/api/ocr',
      'file',
      file,
      fields: options.toParams(),
    );
  }

  /// Extract text from an image using OCR
  ///
  /// [file] Image file to process
  /// [language] OCR language
  Future<ApiResponse> extractTextFromImage(
    File file, {
    String language = 'eng',
  }) async {
    return client.uploadFile(
      '/api/ocr',
      'file',
      file,
      fields: {'language': language},
    );
  }

  /// Make a PDF searchable using OCR
  ///
  /// [file] PDF file to make searchable
  /// [options] OCR options
  Future<ApiResponse> makeSearchablePdf(
    File file, {
    OcrOptions? options,
  }) async {
    options ??= OcrOptions();

    return client.uploadFile(
      '/api/ocr-pdf',
      'file',
      file,
      fields: {...options.toParams(), 'createSearchablePdf': 'true'},
    );
  }

  /// Parse OCR result from API response
  ///
  /// [response] API response
  OcrResult parseOcrResult(ApiResponse response) {
    return OcrResult.fromResponse(response);
  }
}
