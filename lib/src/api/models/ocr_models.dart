

import 'package:scanpro_dart/scanpro.dart';

/// OCR options for PDF processing
class OcrOptions {
  /// OCR language
  final String language;

  /// Pages to process
  final String pageScope;

  /// Page range (e.g., "1,3,5-10")
  final String? pageRange;

  /// Whether to enhance scanned images for better OCR
  final bool enhanceScanned;

  /// Whether to preserve layout when extracting text
  final bool preserveLayout;

  /// Constructor
  OcrOptions({
    this.language = 'eng',
    this.pageScope = 'all',
    this.pageRange,
    this.enhanceScanned = true,
    this.preserveLayout = true,
  });

  /// Convert to API parameters
  Map<String, String> toParams() {
    final params = <String, String>{
      'language': language,
      'scope': pageScope,
      'enhanceScanned': enhanceScanned.toString(),
      'preserveLayout': preserveLayout.toString(),
    };

    if (pageScope == 'custom' && pageRange != null) {
      params['pages'] = pageRange!;
    }

    return params;
  }
}

/// OCR result containing extracted text
class OcrResult {
  /// Whether OCR was successful
  final bool success;

  /// Extracted text
  final String? text;

  /// Error message
  final String? error;

  /// URL to the searchable PDF (if applicable)
  final String? searchablePdfUrl;

  /// URL to the text file (if applicable)
  final String? textUrl;

  /// Constructor
  OcrResult({
    required this.success,
    this.text,
    this.error,
    this.searchablePdfUrl,
    this.textUrl,
  });

  /// Create from API response
  factory OcrResult.fromResponse(ApiResponse response) {
    final success = response.success;

    if (!success) {
      return OcrResult(success: false, error: response.error);
    }

    return OcrResult(
      success: true,
      text: response.getField<String>('ocrText'),
      searchablePdfUrl: response.getField<String>('searchablePdfUrl'),
      textUrl: response.getField<String>('ocrTextUrl'),
    );
  }
}

/// Document language for OCR
enum OcrLanguage {
  /// English
  eng,

  /// French
  fra,

  /// German
  deu,

  /// Spanish
  spa,

  /// Italian
  ita,

  /// Portuguese
  por,

  /// Chinese (Simplified)
  chi_sim,

  /// Chinese (Traditional)
  chi_tra,

  /// Japanese
  jpn,

  /// Korean
  kor,

  /// Russian
  rus,

  /// Arabic
  ara,

  /// Hindi
  hin,
}

/// Extension to get the language code for an OCR language
extension OcrLanguageExtension on OcrLanguage {
  /// Get the language code for this OCR language
  String get code {
    return toString().split('.').last;
  }
}
