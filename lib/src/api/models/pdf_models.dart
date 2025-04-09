/// Compression quality for PDF
enum CompressionQuality {
  /// Low compression (better quality, larger file size)
  low,

  /// Medium compression (balanced quality and file size)
  medium,

  /// High compression (lower quality, smaller file size)
  high,

  /// Maximum compression (lowest quality, smallest file size)
  maximum,
}

/// Represents a page range for PDF operations
class PageRange {
  /// All pages
  static const String all = 'all';

  /// Even pages only
  static const String even = 'even';

  /// Odd pages only
  static const String odd = 'odd';

  /// Custom page range (e.g., "1,3,5-10")
  final String custom;

  /// Constructor for a custom page range
  const PageRange.custom(this.custom);

  /// Constructor for all pages
  const PageRange.allPages() : custom = all;

  /// Constructor for even pages
  const PageRange.evenPages() : custom = even;

  /// Constructor for odd pages
  const PageRange.oddPages() : custom = odd;

  @override
  String toString() => custom;
}

/// Rotation angle for PDF pages
enum RotationAngle {
  /// 90 degrees clockwise
  clockwise90,

  /// 180 degrees (upside down)
  clockwise180,

  /// 90 degrees counter-clockwise
  counterClockwise90,
}

/// Page rotation information for PDF rotation
class PageRotation {
  /// Page number (1-based)
  final int pageNumber;

  /// Rotation angle
  final RotationAngle angle;

  /// Original angle before rotation
  final int original;

  /// Constructor
  PageRotation({
    required this.pageNumber,
    required this.angle,
    this.original = 0,
  });

  /// Convert to a Map
  Map<String, dynamic> toJson() {
    final angleValue = switch (angle) {
      RotationAngle.clockwise90 => 90,
      RotationAngle.clockwise180 => 180,
      RotationAngle.counterClockwise90 => -90,
    };

    return {
      'pageNumber': pageNumber,
      'angle': angleValue,
      'original': original,
    };
  }
}

/// Watermark position options
enum WatermarkPosition {
  /// Center of the page
  center,

  /// Tiled across the page
  tile,

  /// Custom position
  custom,
}

/// Watermark type (text or image)
enum WatermarkType {
  /// Text watermark
  text,

  /// Image watermark
  image,
}

/// Watermark options
class WatermarkOptions {
  /// Position of the watermark
  final WatermarkPosition position;

  /// Page range to apply the watermark to
  final PageRange pages;

  /// Opacity of the watermark (0-100)
  final int opacity;

  /// Rotation angle for the watermark (0-360)
  final int rotation;

  /// Custom X position (percentage, 0-100, only used when position is custom)
  final int? customX;

  /// Custom Y position (percentage, 0-100, only used when position is custom)
  final int? customY;

  /// Constructor
  WatermarkOptions({
    this.position = WatermarkPosition.center,
    this.pages = const PageRange.allPages(),
    this.opacity = 30,
    this.rotation = 45,
    this.customX,
    this.customY,
  });

  /// Convert to API parameters
  Map<String, String> toParams() {
    final params = <String, String>{
      'position': position.toString().split('.').last,
      'pages': pages.toString(),
      'opacity': opacity.toString(),
      'rotation': rotation.toString(),
    };

    if (position == WatermarkPosition.custom) {
      if (customX != null) params['customX'] = customX.toString();
      if (customY != null) params['customY'] = customY.toString();
    }

    return params;
  }
}

/// Text watermark options
class TextWatermarkOptions extends WatermarkOptions {
  /// Text to use as watermark
  final String text;

  /// Text color (hex format, e.g., "#FF0000")
  final String textColor;

  /// Font size
  final int fontSize;

  /// Font family
  final String fontFamily;

  /// Constructor
  TextWatermarkOptions({
    required this.text,
    this.textColor = '#FF0000',
    this.fontSize = 48,
    this.fontFamily = 'Arial',
    super.position,
    super.pages,
    super.opacity,
    super.rotation,
    super.customX,
    super.customY,
  });

  @override
  Map<String, String> toParams() {
    return {
      ...super.toParams(),
      'watermarkType': 'text',
      'text': text,
      'textColor': textColor,
      'fontSize': fontSize.toString(),
      'fontFamily': fontFamily,
    };
  }
}

/// Image watermark options
class ImageWatermarkOptions extends WatermarkOptions {
  /// Scale of the image (percentage, 0-100)
  final int scale;

  /// Constructor
  ImageWatermarkOptions({
    this.scale = 50,
    super.position,
    super.pages,
    super.opacity,
    super.rotation,
    super.customX,
    super.customY,
  });

  @override
  Map<String, String> toParams() {
    return {
      ...super.toParams(),
      'watermarkType': 'image',
      'scale': scale.toString(),
    };
  }
}

/// Password protection options for PDF
class ProtectionOptions {
  /// User password (required to open the document)
  final String password;

  /// Owner password (required to change permissions)
  final String? ownerPassword;

  /// Encryption level (40, 128, or 256)
  final String encryptionLevel;

  /// Permission settings
  final PermissionOptions permissions;

  /// Constructor
  ProtectionOptions({
    required this.password,
    this.ownerPassword,
    this.encryptionLevel = '256',
    this.permissions = const PermissionOptions(),
  });

  /// Convert to API parameters
  Map<String, String> toParams() {
    final params = <String, String>{
      'password': password,
      'protectionLevel': encryptionLevel,
    };

    if (ownerPassword != null) {
      params['ownerPassword'] = ownerPassword!;
    }

    // Add permission options
    params.addAll(permissions.toParams());

    return params;
  }
}

/// Permission options for PDF protection
class PermissionOptions {
  /// Permission mode
  final String permission;

  /// Allow printing
  final bool allowPrinting;

  /// Allow copying text and images
  final bool allowCopying;

  /// Allow editing and annotations
  final bool allowEditing;

  /// Constructor
  const PermissionOptions({
    this.permission = 'restricted',
    this.allowPrinting = false,
    this.allowCopying = false,
    this.allowEditing = false,
  });

  /// Allow all permissions
  const PermissionOptions.allowAll()
    : permission = 'all',
      allowPrinting = true,
      allowCopying = true,
      allowEditing = true;

  /// Convert to API parameters
  Map<String, String> toParams() {
    return {
      'permission': permission,
      'allowPrinting': allowPrinting.toString(),
      'allowCopying': allowCopying.toString(),
      'allowEditing': allowEditing.toString(),
    };
  }
}

/// PDF merge options
class MergeOptions {
  /// Constructor
  const MergeOptions();

  /// Convert to API parameters
  Map<String, String> toParams() {
    return {};
  }
}

/// PDF split options
enum SplitMethod {
  /// Split by page ranges
  byRange,

  /// Extract all pages as separate PDFs
  extractAll,

  /// Split every N pages
  everyNPages,
}

/// PDF split options
class SplitOptions {
  /// Split method
  final SplitMethod method;

  /// Page ranges (only used when method is byRange)
  final String? pageRanges;

  /// Number of pages per file (only used when method is everyNPages)
  final int? pagesPerFile;

  /// Constructor
  SplitOptions({
    this.method = SplitMethod.byRange,
    this.pageRanges,
    this.pagesPerFile,
  });

  /// Convert to API parameters
  Map<String, String> toParams() {
    final params = <String, String>{
      'splitMethod': method.toString().split('.').last,
    };

    if (method == SplitMethod.byRange && pageRanges != null) {
      params['pageRanges'] = pageRanges!;
    }

    if (method == SplitMethod.everyNPages && pagesPerFile != null) {
      params['everyNPagesNumber'] = pagesPerFile.toString();
    }

    return params;
  }
}

/// Repair mode for PDF repair
enum RepairMode {
  /// Standard repair for common issues
  standard,

  /// Advanced recovery for severely damaged PDFs
  advanced,

  /// Optimization to clean up and optimize PDF structure
  optimization,
}

/// PDF repair options
class RepairOptions {
  /// Repair mode
  final RepairMode mode;

  /// Preserve form fields
  final bool preserveFormFields;

  /// Preserve annotations
  final bool preserveAnnotations;

  /// Preserve bookmarks
  final bool preserveBookmarks;

  /// Optimize images
  final bool optimizeImages;

  /// PDF password (if the PDF is password-protected)
  final String? password;

  /// Constructor
  RepairOptions({
    this.mode = RepairMode.standard,
    this.preserveFormFields = true,
    this.preserveAnnotations = true,
    this.preserveBookmarks = true,
    this.optimizeImages = false,
    this.password,
  });

  /// Convert to API parameters
  Map<String, String> toParams() {
    final params = <String, String>{
      'repairMode': mode.toString().split('.').last,
      'preserveFormFields': preserveFormFields.toString(),
      'preserveAnnotations': preserveAnnotations.toString(),
      'preserveBookmarks': preserveBookmarks.toString(),
      'optimizeImages': optimizeImages.toString(),
    };

    if (password != null) {
      params['password'] = password!;
    }

    return params;
  }
}
