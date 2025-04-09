import 'dart:io';
import '../api_client.dart';
import '../models/api_response.dart';
import '../models/conversion_models.dart';

/// API endpoints for PDF conversion
class ConversionApi extends BaseApi {
  /// Constructor
  ConversionApi(super.client);

  /// Convert PDF to another format
  ///
  /// [file] PDF file to convert
  /// [outputFormat] Format to convert to
  /// [options] Conversion options
  Future<ApiResponse> convertPdfTo(
    File file,
    ConversionFormat outputFormat, {
    ConversionOptions? options,
  }) async {
    options ??= ConversionOptions();

    final fields = {
      'outputFormat': outputFormat.extension,
      ...options.toParams(),
    };

    return client.uploadFile('/api/convert', 'file', file, fields: fields);
  }

  /// Convert various formats to PDF
  ///
  /// [file] File to convert
  /// [inputFormat] Format of the input file
  /// [options] Conversion options
  Future<ApiResponse> convertToPdf(
    File file,
    ConversionFormat inputFormat, {
    ConversionOptions? options,
  }) async {
    options ??= ConversionOptions();

    final fields = {
      'inputFormat': inputFormat.extension,
      ...options.toParams(),
    };

    return client.uploadFile('/api/convert', 'file', file, fields: fields);
  }

  /// Convert PDF to Word document
  ///
  /// [file] PDF file to convert
  /// [options] Conversion options
  Future<ApiResponse> pdfToWord(File file, {ConversionOptions? options}) {
    return convertPdfTo(file, ConversionFormat.docx, options: options);
  }

  /// Convert PDF to Excel spreadsheet
  ///
  /// [file] PDF file to convert
  /// [options] Conversion options
  Future<ApiResponse> pdfToExcel(File file, {ConversionOptions? options}) {
    return convertPdfTo(file, ConversionFormat.xlsx, options: options);
  }

  /// Convert PDF to PowerPoint presentation
  ///
  /// [file] PDF file to convert
  /// [options] Conversion options
  Future<ApiResponse> pdfToPowerPoint(File file, {ConversionOptions? options}) {
    return convertPdfTo(file, ConversionFormat.pptx, options: options);
  }

  /// Convert PDF to images (JPG)
  ///
  /// [file] PDF file to convert
  /// [options] Conversion options
  Future<ApiResponse> pdfToJpg(File file, {ConversionOptions? options}) {
    return convertPdfTo(file, ConversionFormat.jpg, options: options);
  }

  /// Convert PDF to images (PNG)
  ///
  /// [file] PDF file to convert
  /// [options] Conversion options
  Future<ApiResponse> pdfToPng(File file, {ConversionOptions? options}) {
    return convertPdfTo(file, ConversionFormat.png, options: options);
  }

  /// Convert PDF to HTML
  ///
  /// [file] PDF file to convert
  /// [options] Conversion options
  Future<ApiResponse> pdfToHtml(File file, {ConversionOptions? options}) {
    return convertPdfTo(file, ConversionFormat.html, options: options);
  }

  /// Convert Word document to PDF
  ///
  /// [file] Word document to convert
  /// [options] Conversion options
  Future<ApiResponse> wordToPdf(File file, {ConversionOptions? options}) {
    return convertToPdf(file, ConversionFormat.docx, options: options);
  }

  /// Convert Excel spreadsheet to PDF
  ///
  /// [file] Excel spreadsheet to convert
  /// [options] Conversion options
  Future<ApiResponse> excelToPdf(File file, {ConversionOptions? options}) {
    return convertToPdf(file, ConversionFormat.xlsx, options: options);
  }

  /// Convert PowerPoint presentation to PDF
  ///
  /// [file] PowerPoint presentation to convert
  /// [options] Conversion options
  Future<ApiResponse> powerPointToPdf(File file, {ConversionOptions? options}) {
    return convertToPdf(file, ConversionFormat.pptx, options: options);
  }

  /// Convert JPG image to PDF
  ///
  /// [file] JPG image to convert
  /// [options] Conversion options
  Future<ApiResponse> jpgToPdf(File file, {ConversionOptions? options}) {
    return convertToPdf(file, ConversionFormat.jpg, options: options);
  }

  /// Convert PNG image to PDF
  ///
  /// [file] PNG image to convert
  /// [options] Conversion options
  Future<ApiResponse> pngToPdf(File file, {ConversionOptions? options}) {
    return convertToPdf(file, ConversionFormat.png, options: options);
  }

  /// Convert HTML to PDF
  ///
  /// [file] HTML file to convert
  /// [options] Conversion options
  Future<ApiResponse> htmlToPdf(File file, {ConversionOptions? options}) {
    return convertToPdf(file, ConversionFormat.html, options: options);
  }
}
