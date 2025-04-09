/// Supported input and output formats for conversion
enum ConversionFormat {
  /// PDF format
  pdf,

  /// Word document format
  docx,

  /// Excel spreadsheet format
  xlsx,

  /// PowerPoint presentation format
  pptx,

  /// JPEG image format
  jpg,

  /// PNG image format
  png,

  /// HTML format
  html,
}

/// Extension to get the file extension for a conversion format
extension ConversionFormatExtension on ConversionFormat {
  /// Get the file extension for this format
  String get extension {
    switch (this) {
      case ConversionFormat.pdf:
        return 'pdf';
      case ConversionFormat.docx:
        return 'docx';
      case ConversionFormat.xlsx:
        return 'xlsx';
      case ConversionFormat.pptx:
        return 'pptx';
      case ConversionFormat.jpg:
        return 'jpg';
      case ConversionFormat.png:
        return 'png';
      case ConversionFormat.html:
        return 'html';
    }
  }

  /// Get the MIME type for this format
  String get mimeType {
    switch (this) {
      case ConversionFormat.pdf:
        return 'application/pdf';
      case ConversionFormat.docx:
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case ConversionFormat.xlsx:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case ConversionFormat.pptx:
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case ConversionFormat.jpg:
        return 'image/jpeg';
      case ConversionFormat.png:
        return 'image/png';
      case ConversionFormat.html:
        return 'text/html';
    }
  }
}

/// Conversion quality
enum ConversionQuality {
  /// Low quality (smaller file size)
  low,

  /// Medium quality (balanced file size and quality)
  medium,

  /// High quality (larger file size)
  high,
}

/// OCR Language
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

/// Options for PDF conversion
class ConversionOptions {
  /// Enable OCR for scanned documents
  final bool enableOcr;

  /// OCR language
  final OcrLanguage? ocrLanguage;

  /// Conversion quality
  final ConversionQuality quality;

  /// Preserve the original layout
  final bool preserveLayout;

  /// Page range (e.g., "1,3,5-10")
  final String? pageRange;

  /// Constructor
  ConversionOptions({
    this.enableOcr = false,
    this.ocrLanguage,
    this.quality = ConversionQuality.high,
    this.preserveLayout = true,
    this.pageRange,
  });

  /// Convert to API parameters
  Map<String, String> toParams() {
    final params = <String, String>{
      'quality': quality.toString().split('.').last,
      'preserveLayout': preserveLayout.toString(),
    };

    if (enableOcr) {
      params['ocr'] = 'true';
      if (ocrLanguage != null) {
        params['ocrLanguage'] = ocrLanguage.toString().split('.').last;
      }
    }

    if (pageRange != null && pageRange!.isNotEmpty) {
      params['pageRange'] = pageRange!;
    }

    return params;
  }
}
