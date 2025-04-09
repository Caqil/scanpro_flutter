import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:scanpro_dart/scanpro_dart.dart';
import 'package:scanpro_dart_example/file_utils.dart';
import 'package:share_plus/share_plus.dart';

class ConversionType {
  final String label;
  final ConversionFormat inputFormat;
  final ConversionFormat outputFormat;

  ConversionType(this.label, this.inputFormat, this.outputFormat);
}

class PdfConversionExample extends StatefulWidget {
  const PdfConversionExample({super.key});

  @override
  State<PdfConversionExample> createState() => _PdfConversionExampleState();
}

class _PdfConversionExampleState extends State<PdfConversionExample> {
  File? _selectedFile;
  String _selectedFileName = '';
  bool _isLoading = false;
  String _resultMessage = '';
  String? _convertedFilePath;

  // Select conversion type
  ConversionFormat _inputFormat = ConversionFormat.pdf;
  ConversionFormat _outputFormat = ConversionFormat.docx;

  final List<ConversionType> _conversionTypes = [
    ConversionType('PDF to Word', ConversionFormat.pdf, ConversionFormat.docx),
    ConversionType('PDF to Excel', ConversionFormat.pdf, ConversionFormat.xlsx),
    ConversionType(
      'PDF to PowerPoint',
      ConversionFormat.pdf,
      ConversionFormat.pptx,
    ),
    ConversionType('PDF to JPG', ConversionFormat.pdf, ConversionFormat.jpg),
    ConversionType('PDF to PNG', ConversionFormat.pdf, ConversionFormat.png),
    ConversionType('Word to PDF', ConversionFormat.docx, ConversionFormat.pdf),
    ConversionType('Excel to PDF', ConversionFormat.xlsx, ConversionFormat.pdf),
    ConversionType(
      'PowerPoint to PDF',
      ConversionFormat.pptx,
      ConversionFormat.pdf,
    ),
    ConversionType('JPG to PDF', ConversionFormat.jpg, ConversionFormat.pdf),
    ConversionType('PNG to PDF', ConversionFormat.png, ConversionFormat.pdf),
  ];

  ConversionType _selectedConversionType;

  // OCR options
  bool _enableOcr = false;
  String _ocrLanguage = 'eng';

  _PdfConversionExampleState()
    : _selectedConversionType = ConversionType(
        'PDF to Word',
        ConversionFormat.pdf,
        ConversionFormat.docx,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Conversion Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a conversion type:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildConversionTypeDropdown(),
            const SizedBox(height: 16),

            // File selection button
            const Text(
              'Select a file to convert:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFileSelectionButton(),
            const SizedBox(height: 16),

            // OCR options (only show for PDF input)
            if (_inputFormat == ConversionFormat.pdf) _buildOcrOptions(),

            const SizedBox(height: 16),

            // Convert button
            _buildConvertButton(),

            // Status and result
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Result message
            if (_resultMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _resultMessage,
                  style: TextStyle(
                    color:
                        _convertedFilePath != null ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Actions for converted file
            if (_convertedFilePath != null) _buildFileActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionTypeDropdown() {
    return DropdownButtonFormField<ConversionType>(
      value: _selectedConversionType,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      isExpanded: true,
      items:
          _conversionTypes.map((ConversionType type) {
            return DropdownMenuItem<ConversionType>(
              value: type,
              child: Text(type.label),
            );
          }).toList(),
      onChanged: (ConversionType? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedConversionType = newValue;
            _inputFormat = newValue.inputFormat;
            _outputFormat = newValue.outputFormat;
            _selectedFile = null;
            _selectedFileName = '';
            _resultMessage = '';
            _convertedFilePath = null;
          });
        }
      },
    );
  }

  Widget _buildFileSelectionButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.file_upload),
          label: const Text('Select file'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        if (_selectedFileName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Selected file: $_selectedFileName',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  Widget _buildOcrOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OCR Options:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Enable OCR'),
          subtitle: const Text('Extract text from scanned documents'),
          value: _enableOcr,
          onChanged: (bool value) {
            setState(() {
              _enableOcr = value;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        if (_enableOcr)
          DropdownButtonFormField<String>(
            value: _ocrLanguage,
            decoration: const InputDecoration(
              labelText: 'OCR Language',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'eng', child: Text('English')),
              DropdownMenuItem(value: 'fra', child: Text('French')),
              DropdownMenuItem(value: 'deu', child: Text('German')),
              DropdownMenuItem(value: 'spa', child: Text('Spanish')),
              DropdownMenuItem(value: 'ita', child: Text('Italian')),
              DropdownMenuItem(value: 'rus', child: Text('Russian')),
              DropdownMenuItem(
                value: 'chi_sim',
                child: Text('Chinese (Simplified)'),
              ),
              DropdownMenuItem(value: 'jpn', child: Text('Japanese')),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _ocrLanguage = newValue;
                });
              }
            },
          ),
      ],
    );
  }

  Widget _buildConvertButton() {
    return ElevatedButton.icon(
      onPressed: _selectedFile != null ? _convertFile : null,
      icon: const Icon(Icons.swap_horiz),
      label: const Text('Convert'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildFileActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'Converted File:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _openFile,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open'),
            ),
            ElevatedButton.icon(
              onPressed: _shareFile,
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    try {
      // Determine the file extensions to filter by based on the selected input format
      List<String> allowedExtensions;
      switch (_inputFormat) {
        case ConversionFormat.pdf:
          allowedExtensions = ['pdf'];
          break;
        case ConversionFormat.docx:
          allowedExtensions = ['docx', 'doc'];
          break;
        case ConversionFormat.xlsx:
          allowedExtensions = ['xlsx', 'xls'];
          break;
        case ConversionFormat.pptx:
          allowedExtensions = ['pptx', 'ppt'];
          break;
        case ConversionFormat.jpg:
          allowedExtensions = ['jpg', 'jpeg'];
          break;
        case ConversionFormat.png:
          allowedExtensions = ['png'];
          break;
        case ConversionFormat.html:
          allowedExtensions = ['html', 'htm'];
          break;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
          _resultMessage = '';
          _convertedFilePath = null;
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error selecting file: $e';
      });
    }
  }

  Future<void> _convertFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isLoading = true;
      _resultMessage = 'Converting file...';
      _convertedFilePath = null;
    });

    try {
      // Create conversion options
      final options = ConversionOptions(
        enableOcr: _enableOcr,
        ocrLanguage:
            _ocrLanguage == 'eng'
                ? OcrLanguage.eng
                : _ocrLanguage == 'fra'
                ? OcrLanguage.fra
                : _ocrLanguage == 'deu'
                ? OcrLanguage.deu
                : _ocrLanguage == 'spa'
                ? OcrLanguage.spa
                : _ocrLanguage == 'ita'
                ? OcrLanguage.ita
                : _ocrLanguage == 'rus'
                ? OcrLanguage.rus
                : _ocrLanguage == 'chi_sim'
                ? OcrLanguage.chi_sim
                : OcrLanguage.jpn,
        quality: ConversionQuality.high,
        preserveLayout: true,
      );

      // Perform the conversion
      late ApiResponse response;

      if (_inputFormat == ConversionFormat.pdf) {
        // Convert from PDF to another format
        response = await ScanPro.api.conversion.convertPdfTo(
          _selectedFile!,
          _outputFormat,
          options: options,
        );
      } else {
        // Convert to PDF
        response = await ScanPro.api.conversion.convertToPdf(
          _selectedFile!,
          _inputFormat,
          options: options,
        );
      }

      if (response.success) {
        // Download the converted file
        if (response.fileUrl != null) {
          final file = await FileUtils.downloadFile(response.fileUrl!);

          setState(() {
            _convertedFilePath = file.path;
            _resultMessage =
                'Conversion successful! File saved to: ${file.path}';
          });
        } else {
          setState(() {
            _resultMessage =
                'Conversion successful, but no file URL was returned.';
          });
        }
      } else {
        setState(() {
          _resultMessage = 'Conversion failed: ${response.userFriendlyError}';
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error converting file: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openFile() {
    if (_convertedFilePath != null) {
      OpenFile.open(_convertedFilePath!);
    }
  }

  void _shareFile() {
    if (_convertedFilePath != null) {
      Share.shareXFiles([XFile(_convertedFilePath!)]);
    }
  }
}
