/// Security models for PDF protection and unlocking
class PasswordOptions {
  /// The password for unlocking or protecting the PDF
  final String password;

  /// Constructor
  const PasswordOptions({required this.password});

  /// Convert to API parameters
  Map<String, String> toParams() {
    return {'password': password};
  }
}

/// PDF protection options
class ProtectPdfOptions extends PasswordOptions {
  /// Owner password (for setting permissions)
  final String? ownerPassword;

  /// Permission level (restricted or all)
  final String permission;

  /// Encryption level (40, 128, or 256 bits)
  final String encryptionLevel;

  /// Allow printing
  final bool allowPrinting;

  /// Allow copying content
  final bool allowCopying;

  /// Allow editing
  final bool allowEditing;

  /// Constructor
  const ProtectPdfOptions({
    required super.password,
    this.ownerPassword,
    this.permission = 'restricted',
    this.encryptionLevel = '256',
    this.allowPrinting = false,
    this.allowCopying = false,
    this.allowEditing = false,
  });

  /// Create protection options with all permissions allowed
  factory ProtectPdfOptions.withAllPermissions({
    required String password,
    String? ownerPassword,
    String encryptionLevel = '256',
  }) {
    return ProtectPdfOptions(
      password: password,
      ownerPassword: ownerPassword,
      permission: 'all',
      encryptionLevel: encryptionLevel,
      allowPrinting: true,
      allowCopying: true,
      allowEditing: true,
    );
  }

  @override
  Map<String, String> toParams() {
    final params = <String, String>{
      ...super.toParams(),
      'permission': permission,
      'protectionLevel': encryptionLevel,
      'allowPrinting': allowPrinting.toString(),
      'allowCopying': allowCopying.toString(),
      'allowEditing': allowEditing.toString(),
    };

    if (ownerPassword != null) {
      params['ownerPassword'] = ownerPassword!;
    }

    return params;
  }
}

/// Options for signing a PDF
class SignPdfElement {
  /// Element type
  final String type;

  /// Element data
  final String data;

  /// Position (x, y)
  final Map<String, double> position;

  /// Size (width, height)
  final Map<String, double> size;

  /// Rotation angle
  final double rotation;

  /// Scale factor
  final double scale;

  /// Page number
  final int page;

  /// Text color (for text elements)
  final String? color;

  /// Font size (for text elements)
  final double? fontSize;

  /// Font family (for text elements)
  final String? fontFamily;

  /// Constructor
  SignPdfElement({
    required this.type,
    required this.data,
    required this.position,
    required this.size,
    this.rotation = 0,
    this.scale = 1,
    required this.page,
    this.color,
    this.fontSize,
    this.fontFamily,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'position': position,
      'size': size,
      'rotation': rotation,
      'scale': scale,
      'page': page,
      if (color != null) 'color': color,
      if (fontSize != null) 'fontSize': fontSize,
      if (fontFamily != null) 'fontFamily': fontFamily,
    };
  }

  /// Create a signature element
  factory SignPdfElement.signature({
    required String signatureData,
    required double x,
    required double y,
    required double width,
    required double height,
    double rotation = 0,
    double scale = 1,
    required int page,
  }) {
    return SignPdfElement(
      type: 'signature',
      data: signatureData,
      position: {'x': x, 'y': y},
      size: {'width': width, 'height': height},
      rotation: rotation,
      scale: scale,
      page: page,
    );
  }

  /// Create a text element
  factory SignPdfElement.text({
    required String text,
    required double x,
    required double y,
    required double width,
    required double height,
    double rotation = 0,
    double scale = 1,
    required int page,
    String color = '#000000',
    double fontSize = 12,
    String fontFamily = 'Arial',
  }) {
    return SignPdfElement(
      type: 'text',
      data: text,
      position: {'x': x, 'y': y},
      size: {'width': width, 'height': height},
      rotation: rotation,
      scale: scale,
      page: page,
      color: color,
      fontSize: fontSize,
      fontFamily: fontFamily,
    );
  }

  /// Create a stamp element
  factory SignPdfElement.stamp({
    required String stampData,
    required double x,
    required double y,
    required double width,
    required double height,
    double rotation = 0,
    double scale = 1,
    required int page,
  }) {
    return SignPdfElement(
      type: 'stamp',
      data: stampData,
      position: {'x': x, 'y': y},
      size: {'width': width, 'height': height},
      rotation: rotation,
      scale: scale,
      page: page,
    );
  }

  /// Create a drawing element
  factory SignPdfElement.drawing({
    required String drawingData,
    required double x,
    required double y,
    required double width,
    required double height,
    double rotation = 0,
    double scale = 1,
    required int page,
  }) {
    return SignPdfElement(
      type: 'drawing',
      data: drawingData,
      position: {'x': x, 'y': y},
      size: {'width': width, 'height': height},
      rotation: rotation,
      scale: scale,
      page: page,
    );
  }

  /// Create an image element
  factory SignPdfElement.image({
    required String imageData,
    required double x,
    required double y,
    required double width,
    required double height,
    double rotation = 0,
    double scale = 1,
    required int page,
  }) {
    return SignPdfElement(
      type: 'image',
      data: imageData,
      position: {'x': x, 'y': y},
      size: {'width': width, 'height': height},
      rotation: rotation,
      scale: scale,
      page: page,
    );
  }
}

/// Page data for PDF signing
class SignPageData {
  /// Width of the page
  final double width;

  /// Height of the page
  final double height;

  /// Original width of the page
  final double originalWidth;

  /// Original height of the page
  final double originalHeight;

  /// Constructor
  SignPageData({
    required this.width,
    required this.height,
    required this.originalWidth,
    required this.originalHeight,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'originalWidth': originalWidth,
      'originalHeight': originalHeight,
    };
  }
}

/// Options for signing a PDF
class SignPdfOptions {
  /// Elements to add to the PDF
  final List<SignPdfElement> elements;

  /// Page data for scaling
  final List<SignPageData> pages;

  /// Whether to perform OCR on the signed PDF
  final bool performOcr;

  /// OCR language
  final String ocrLanguage;

  /// Constructor
  SignPdfOptions({
    required this.elements,
    required this.pages,
    this.performOcr = false,
    this.ocrLanguage = 'eng',
  });
}
