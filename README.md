# ScanPro Flutter

A powerful Flutter plugin that provides comprehensive PDF and document processing capabilities through the ScanPro API. This plugin enables your Flutter applications to convert, manipulate, secure, and extract text from PDFs and other document formats.

## Features

### PDF Conversion

- **Convert PDF to various formats**: Word (DOCX), Excel (XLSX), PowerPoint (PPTX), Images (JPG, PNG), HTML
- **Convert other formats to PDF**: Word, Excel, PowerPoint, Images, HTML
- **High-quality conversion** with layout preservation options
- **OCR support** for scanned documents

### PDF Tools

- **Merge multiple PDFs** into a single document
- **Split PDFs** by page ranges, extract individual pages, or split by intervals
- **Compress PDFs** with adjustable quality settings to reduce file size
- **Add watermarks** (text or image) with customizable position, opacity, and rotation
- **Rotate pages** with precise control over page selection and rotation angle
- **Repair damaged PDFs** with multiple recovery options

### PDF Security

- **Protect PDFs** with passwords and encryption
- **Set document permissions** (printing, copying, editing)
- **Unlock protected PDFs** with the correct password
- **Add digital signatures** and other elements to PDFs

### OCR (Optical Character Recognition)

- **Extract text** from scanned PDFs and images
- **Create searchable PDFs** that preserve the original appearance
- **Support for multiple languages** including English, French, German, Spanish, Italian, Chinese, Japanese, Korean, and more
- **Enhance scanned documents** for better OCR results
- **Preserve document layout** in extracted text

## Installation

```yaml
dependencies:
  scanpro_dart: ^1.0.0
```

Run `flutter pub get` to install the package.

## Configuration

You need a [ScanPro API](https://scanpro.cc/en/login) key to use this plugin. Initialize the plugin in your app before using any of its features:

```dart
import 'package:scanpro_flutter/scanpro_flutter.dart';

void main() {
  // Initialize ScanPro with your API key
  ScanPro.initialize(apiKey: 'YOUR_API_KEY');

  runApp(MyApp());
}
```

You can also configure additional settings:

```dart
ScanProConfig.configure(
  baseUrl: 'https://api.scanpro.cc', // Custom API URL if needed
  timeout: const Duration(seconds: 120), // Custom timeout
  maxFileSize: 200 * 1024 * 1024, // Custom max file size (200MB)
);
```

## Usage Examples

### PDF Conversion

```dart
import 'dart:io';
import 'package:scanpro_flutter/scanpro_flutter.dart';

// Convert PDF to Word
Future<void> convertPdfToWord(File pdfFile) async {
  final response = await ScanPro.api.conversion.pdfToWord(pdfFile);

  if (response.success) {
    final docxUrl = response.fileUrl;
    // Download or process the converted file
    print('Converted file URL: $docxUrl');
  } else {
    print('Conversion failed: ${response.userFriendlyError}');
  }
}

// Convert Word to PDF
Future<void> convertWordToPdf(File wordFile) async {
  final response = await ScanPro.api.conversion.wordToPdf(wordFile);

  if (response.success) {
    final pdfUrl = response.fileUrl;
    // Download or process the converted file
    print('Converted file URL: $pdfUrl');
  } else {
    print('Conversion failed: ${response.userFriendlyError}');
  }
}
```

### Merge PDFs

```dart
import 'dart:io';
import 'package:scanpro_flutter/scanpro_flutter.dart';

Future<void> mergePdfFiles(List<File> pdfFiles) async {
  final response = await ScanPro.api.pdfTools.mergePdfs(pdfFiles);

  if (response.success) {
    final mergedPdfUrl = response.fileUrl;
    // Download or process the merged file
    print('Merged PDF URL: $mergedPdfUrl');
  } else {
    print('Merge failed: ${response.userFriendlyError}');
  }
}
```

### Protect PDF

```dart
import 'dart:io';
import 'package:scanpro_flutter/scanpro_flutter.dart';

Future<void> protectPdf(File pdfFile, String password) async {
  final options = ProtectPdfOptions(
    password: password,
    encryptionLevel: '256',
    allowPrinting: true,
    allowCopying: false,
    allowEditing: false,
  );

  final response = await ScanPro.api.security.protectPdf(pdfFile, options);

  if (response.success) {
    final protectedPdfUrl = response.fileUrl;
    // Download or process the protected file
    print('Protected PDF URL: $protectedPdfUrl');
  } else {
    print('Protection failed: ${response.userFriendlyError}');
  }
}
```

### OCR - Extract Text from PDF

```dart
import 'dart:io';
import 'package:scanpro_flutter/scanpro_flutter.dart';

Future<void> extractTextFromPdf(File pdfFile) async {
  final options = OcrOptions(
    language: 'eng',
    enhanceScanned: true,
    preserveLayout: true,
  );

  final response = await ScanPro.api.ocr.performOcr(pdfFile, options: options);

  if (response.success) {
    final ocrResult = ScanPro.api.ocr.parseOcrResult(response);

    if (ocrResult.text != null) {
      print('Extracted Text: ${ocrResult.text}');
    }

    if (ocrResult.searchablePdfUrl != null) {
      print('Searchable PDF URL: ${ocrResult.searchablePdfUrl}');
    }
  } else {
    print('OCR failed: ${response.userFriendlyError}');
  }
}
```

### Create Searchable PDF

```dart
import 'dart:io';
import 'package:scanpro_flutter/scanpro_flutter.dart';

Future<void> createSearchablePdf(File pdfFile) async {
  final options = OcrOptions(
    language: 'eng',
    enhanceScanned: true,
  );

  final response = await ScanPro.api.ocr.makeSearchablePdf(pdfFile, options: options);

  if (response.success) {
    final ocrResult = ScanPro.api.ocr.parseOcrResult(response);

    if (ocrResult.searchablePdfUrl != null) {
      print('Searchable PDF URL: ${ocrResult.searchablePdfUrl}');
    }
  } else {
    print('OCR failed: ${response.userFriendlyError}');
  }
}
```

## Complete Example Application

The package includes a complete example application demonstrating all major features:

1. **PDF Conversion**: Convert between PDF and other formats
2. **Merge PDFs**: Combine multiple PDF files
3. **PDF Security**: Protect and unlock PDFs
4. **OCR**: Extract text and create searchable PDFs

To run the example:

1. Clone the repository
2. Enter your API key in `example/lib/main.dart`
3. Run `flutter pub get`
4. Run `flutter run`

## API Documentation

For detailed API documentation, see the [API Reference](https://docs.scanpro.cc/en/developer-api).

## Error Handling

The plugin provides detailed error messages through the `ApiResponse` class:

```dart
try {
  final response = await ScanPro.api.conversion.pdfToWord(file);

  if (response.success) {
    // Process successful response
  } else {
    // Handle error
    if (response.isRateLimitError) {
      // Handle rate limiting
    } else if (response.isAuthError) {
      // Handle authentication errors
    } else if (response.isServerError) {
      // Handle server errors
    } else {
      // Handle other errors
      print(response.userFriendlyError);
    }
  }
} catch (e) {
  // Handle exceptions
  print('Exception: $e');
}
```

## File Handling Utilities

The plugin includes utility classes for working with files:

```dart
import 'package:scanpro_flutter/scanpro_flutter.dart';

// Download a file from URL
final file = await FileUtils.downloadFile(url);

// Get file format
final format = FileUtils.getFileFormat('pdf'); // Returns "PDF Document"

// Get file size
final size = await FileUtils.getFileSize(filePath);
```

## Platform Support

- Android
- iOS
- Web
- macOS
- Windows
- Linux

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@scanpro.cc or visit [scanpro.cc/support](https://scanpro.cc/support).
