import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../config/scanpro_config.dart';

/// Utility class for file operations
class FileUtils {
  /// Download a file from URL and save it to a temporary file
  ///
  /// [url] URL of the file to download
  /// [filename] Name of the file
  static Future<File> downloadFile(String url, {String? filename}) async {
    try {
      // Modify the URL to use the ScanPro API if it's a relative URL
      if (url.startsWith('/')) {
        url = '${ScanProConfig.baseUrl}$url';
      }

      // Get the HTTP response
      final response = await http.get(Uri.parse(url), headers: {
        'x-api-key': ScanProConfig.apiKey
      }).timeout(ScanProConfig.timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }

      // Get the filename
      String downloadFilename;

      if (filename != null) {
        downloadFilename = filename;
      } else {
        // Try to get filename from Content-Disposition header
        final contentDisposition = response.headers['content-disposition'];
        if (contentDisposition != null &&
            contentDisposition.contains('filename=')) {
          downloadFilename =
              contentDisposition.split('filename=')[1].replaceAll('"', '');
        } else {
          // Use the URL path as a fallback
          downloadFilename = url.split('/').last.split('?').first;
        }
      }

      // Save the file
      final file = await _saveBytesToFile(response.bodyBytes, downloadFilename);
      return file;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
      rethrow;
    }
  }

  /// Download multiple files and save them to temporary files
  ///
  /// [urls] List of URLs to download
  static Future<List<File>> downloadFiles(List<String> urls) async {
    final files = <File>[];
    for (final url in urls) {
      files.add(await downloadFile(url));
    }
    return files;
  }

  /// Save bytes to a temporary file
  ///
  /// [bytes] Bytes to save
  /// [filename] Name of the file
  static Future<File> _saveBytesToFile(Uint8List bytes, String filename) async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');

      // Write the file
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving file: $e');
      }
      rethrow;
    }
  }

  /// Get file extension from file path
  ///
  /// [filePath] File path
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Check if a file exists
  ///
  /// [filePath] File path
  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return file.exists();
  }

  /// Get file size
  ///
  /// [filePath] File path
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return file.length();
  }

  /// Get file format from extension
  ///
  /// [extension] File extension
  static String getFileFormat(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'PDF Document';
      case 'docx':
        return 'Word Document';
      case 'xlsx':
        return 'Excel Spreadsheet';
      case 'pptx':
        return 'PowerPoint Presentation';
      case 'jpg':
      case 'jpeg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      case 'html':
        return 'HTML Document';
      default:
        return 'Document';
    }
  }
}
