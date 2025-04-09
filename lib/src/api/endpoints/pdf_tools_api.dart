import 'dart:io';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:scanpro_dart/scanpro.dart';
import 'package:http/http.dart' as http;

/// API endpoints for PDF tools
class PdfToolsApi extends BaseApi {
  /// Constructor
  PdfToolsApi(super.client);

  /// Compress a PDF file
  ///
  /// [file] PDF file to compress
  /// [quality] Compression quality
  Future<ApiResponse> compressPdf(
    File file, {
    CompressionQuality quality = CompressionQuality.medium,
  }) async {
    return client.uploadFile(
      '/api/compress',
      'file',
      file,
      fields: {'quality': quality.toString().split('.').last},
    );
  }

  /// Merge multiple PDF files
  ///
  /// [files] List of PDF files to merge
  /// [options] Merge options
  Future<ApiResponse> mergePdfs(
    List<File> files, {
    MergeOptions? options,
  }) async {
    options ??= const MergeOptions();

    // Create a multipart request manually
    final uri = Uri.parse('${ScanProConfig.apiUrl}/api/merge');
    final request = http.MultipartRequest('POST', uri);

    // Add API key header
    request.headers.addAll({'x-api-key': ScanProConfig.apiKey});

    // Add each file to the request
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = file.path.split('/').last;
      final fileBytes = await file.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse('application/pdf'),
        ),
      );
    }

    // Add merge options
    request.fields.addAll(options.toParams());

    // Send the request
    final streamedResponse = await request.send().timeout(
      ScanProConfig.timeout,
    );
    final response = await http.Response.fromStream(streamedResponse);

    // Parse the response
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

  /// Split a PDF file
  ///
  /// [file] PDF file to split
  /// [options] Split options
  Future<ApiResponse> splitPdf(
    File file, {
    required SplitOptions options,
  }) async {
    return client.uploadFile(
      '/api/split',
      'file',
      file,
      fields: options.toParams(),
    );
  }

  /// Rotate PDF pages
  ///
  /// [file] PDF file to rotate
  /// [rotations] List of page rotations
  Future<ApiResponse> rotatePdf(File file, List<PageRotation> rotations) async {
    return client.uploadFile(
      '/api/pdf/rotate',
      'file',
      file,
      fields: {
        'rotations': json.encode(rotations.map((r) => r.toJson()).toList()),
      },
    );
  }

  /// Add a text watermark to a PDF
  ///
  /// [file] PDF file to watermark
  /// [options] Text watermark options
  Future<ApiResponse> addTextWatermark(
    File file,
    TextWatermarkOptions options,
  ) async {
    return client.uploadFile(
      '/api/pdf/watermark',
      'file',
      file,
      fields: options.toParams(),
    );
  }

  /// Add an image watermark to a PDF
  ///
  /// [file] PDF file to watermark
  /// [watermarkImage] Image file to use as watermark
  /// [options] Image watermark options
  Future<ApiResponse> addImageWatermark(
    File file,
    File watermarkImage,
    ImageWatermarkOptions options,
  ) async {
    // Create a multipart request manually
    final uri = Uri.parse('${ScanProConfig.apiUrl}/api/pdf/watermark');
    final request = http.MultipartRequest('POST', uri);

    // Add API key header
    request.headers.addAll({'x-api-key': ScanProConfig.apiKey});

    // Add PDF file
    final pdfFileName = file.path.split('/').last;
    final pdfBytes = await file.readAsBytes();

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        pdfBytes,
        filename: pdfFileName,
        contentType: MediaType.parse('application/pdf'),
      ),
    );

    // Add watermark image file
    final imageFileName = watermarkImage.path.split('/').last;
    final imageBytes = await watermarkImage.readAsBytes();

    // Determine image content type
    String imageContentType = 'image/jpeg';
    if (imageFileName.toLowerCase().endsWith('.png')) {
      imageContentType = 'image/png';
    } else if (imageFileName.toLowerCase().endsWith('.svg')) {
      imageContentType = 'image/svg+xml';
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'watermarkImage',
        imageBytes,
        filename: imageFileName,
        contentType: MediaType.parse(imageContentType),
      ),
    );

    // Add watermark options
    request.fields.addAll(options.toParams());

    // Send the request
    final streamedResponse = await request.send().timeout(
      ScanProConfig.timeout,
    );
    final response = await http.Response.fromStream(streamedResponse);

    // Parse the response
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

  /// Repair a PDF file
  ///
  /// [file] PDF file to repair
  /// [options] Repair options
  Future<ApiResponse> repairPdf(File file, {RepairOptions? options}) async {
    options ??= RepairOptions();

    return client.uploadFile(
      '/api/pdf/repair',
      'file',
      file,
      fields: options.toParams(),
    );
  }

  /// Get PDF information
  ///
  /// [file] PDF file to get information for
  Future<ApiResponse> getPdfInfo(File file) async {
    return client.uploadFile('/api/pdf/info', 'file', file);
  }
}
