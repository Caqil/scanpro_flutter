import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:scanpro_dart/scanpro_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:scanpro_dart_example/file_utils.dart';
import 'package:share_plus/share_plus.dart';

class OcrExample extends StatefulWidget {
  const OcrExample({super.key});

  @override
  State<OcrExample> createState() => _OcrExampleState();
}

class _OcrExampleState extends State<OcrExample> {
  File? _selectedFile;
  String _selectedFileName = '';
  String _selectedFileType = '';
  bool _isLoading = false;
  String _resultMessage = '';
  String? _extractedText;
  String? _searchablePdfPath;
  String? _textFilePath;

  // OCR options
  String _ocrLanguage = 'eng';
  String _pageScope = 'all';
  String _pageRange = '';
  bool _enhanceScanned = true;
  bool _preserveLayout = true;
  bool _createSearchablePdf = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File selection button
            const Text(
              'Select a file for OCR:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'You can select a PDF or an image (JPG, PNG)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _buildFileSelectionButton(),
            const SizedBox(height: 16),

            // OCR options
            if (_selectedFile != null) _buildOcrOptions(),
            const SizedBox(height: 16),

            // OCR button
            _buildOcrButton(),

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
                        _extractedText != null ||
                                _searchablePdfPath != null ||
                                _textFilePath != null
                            ? Colors.green
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Extracted text
            if (_extractedText != null && _extractedText!.isNotEmpty)
              _buildExtractedTextSection(),

            // Actions for searchable PDF
            if (_searchablePdfPath != null) _buildSearchablePdfActions(),

            // Actions for text file
            if (_textFilePath != null) _buildTextFileActions(),
          ],
        ),
      ),
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
              'Selected file: $_selectedFileName ($_selectedFileType)',
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
        // Language selection
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
            DropdownMenuItem(value: 'kor', child: Text('Korean')),
            DropdownMenuItem(value: 'ara', child: Text('Arabic')),
            DropdownMenuItem(value: 'hin', child: Text('Hindi')),
            DropdownMenuItem(value: 'por', child: Text('Portuguese')),
          ],
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _ocrLanguage = newValue;
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // Only show these options for PDF files
        if (_selectedFileType.toLowerCase() == 'pdf') ...[
          // Page scope selection
          DropdownButtonFormField<String>(
            value: _pageScope,
            decoration: const InputDecoration(
              labelText: 'Page Scope',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Pages')),
              DropdownMenuItem(value: 'even', child: Text('Even Pages Only')),
              DropdownMenuItem(value: 'odd', child: Text('Odd Pages Only')),
              DropdownMenuItem(value: 'custom', child: Text('Custom Range')),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _pageScope = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Page range (only shown when custom is selected)
          if (_pageScope == 'custom')
            TextField(
              decoration: const InputDecoration(
                labelText: 'Page Range (e.g., "1,3,5-10")',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _pageRange = value;
                });
              },
            ),
          if (_pageScope == 'custom') const SizedBox(height: 16),

          // Create searchable PDF option
          SwitchListTile(
            title: const Text('Create Searchable PDF'),
            subtitle: const Text(
              'Makes the PDF searchable while preserving the original look',
            ),
            value: _createSearchablePdf,
            onChanged: (bool value) {
              setState(() {
                _createSearchablePdf = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],

        // Options for both PDF and images
        SwitchListTile(
          title: const Text('Enhance Scanned Image'),
          subtitle: const Text(
            'Improve quality of scanned documents for better OCR results',
          ),
          value: _enhanceScanned,
          onChanged: (bool value) {
            setState(() {
              _enhanceScanned = value;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),

        SwitchListTile(
          title: const Text('Preserve Layout'),
          subtitle: const Text(
            'Maintain original document layout in extracted text',
          ),
          value: _preserveLayout,
          onChanged: (bool value) {
            setState(() {
              _preserveLayout = value;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildOcrButton() {
    return ElevatedButton.icon(
      onPressed: _selectedFile != null ? _performOcr : null,
      icon: const Icon(Icons.document_scanner),
      label: const Text('Perform OCR'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildExtractedTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'Extracted Text:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(_extractedText!),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            Share.share(_extractedText!);
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copy Text'),
        ),
      ],
    );
  }

  Widget _buildSearchablePdfActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'Searchable PDF:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                if (_searchablePdfPath != null) {
                  OpenFile.open(_searchablePdfPath!);
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (_searchablePdfPath != null) {
                  Share.shareXFiles([XFile(_searchablePdfPath!)]);
                }
              },
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFileActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Text File:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                if (_textFilePath != null) {
                  OpenFile.open(_textFilePath!);
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (_textFilePath != null) {
                  Share.shareXFiles([XFile(_textFilePath!)]);
                }
              },
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
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Determine file type based on extension
        final fileExtension = fileName.split('.').last.toLowerCase();
        String fileType;

        switch (fileExtension) {
          case 'pdf':
            fileType = 'PDF';
            break;
          case 'jpg':
          case 'jpeg':
            fileType = 'JPEG Image';
            break;
          case 'png':
            fileType = 'PNG Image';
            break;
          default:
            fileType = 'Unknown';
        }

        setState(() {
          _selectedFile = file;
          _selectedFileName = fileName;
          _selectedFileType = fileType;
          _resultMessage = '';
          _extractedText = null;
          _searchablePdfPath = null;
          _textFilePath = null;
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error selecting file: $e';
      });
    }
  }

  Future<void> _performOcr() async {
    if (_selectedFile == null) return;

    setState(() {
      _isLoading = true;
      _resultMessage = 'Performing OCR...';
      _extractedText = null;
      _searchablePdfPath = null;
      _textFilePath = null;
    });

    try {
      // Create API parameters for OCR
      final Map<String, String> params = {
        'language': _ocrLanguage,
        'scope': _pageScope,
        'enhanceScanned': _enhanceScanned.toString(),
        'preserveLayout': _preserveLayout.toString(),
      };

      // Add page range for custom page scope
      if (_pageScope == 'custom' && _pageRange.isNotEmpty) {
        params['pages'] = _pageRange;
      }

      ApiResponse response;

      if (_selectedFileType.toLowerCase() == 'pdf') {
        if (_createSearchablePdf) {
          // Make searchable PDF
          params['createSearchablePdf'] = 'true';
          response = await ScanPro.api.ocr.makeSearchablePdf(
            _selectedFile!,
            options:
                null, // Use params directly in makeSearchablePdf when implemented
          );
        } else {
          // Regular OCR on PDF
          response = await ScanPro.api.ocr.performOcr(
            _selectedFile!,
            options: null, // Use params directly in performOcr when implemented
          );
        }
      } else {
        // Image OCR
        response = await ScanPro.api.ocr.extractTextFromImage(
          _selectedFile!,
          language: _ocrLanguage,
        );
      }

      if (response.success) {
        // Parse the OCR result
        final ocrResult = ScanPro.api.ocr.parseOcrResult(response);

        setState(() {
          _extractedText = ocrResult.text;

          if (ocrResult.searchablePdfUrl != null) {
            _downloadSearchablePdf(ocrResult.searchablePdfUrl!);
          }

          if (ocrResult.textUrl != null) {
            _downloadTextFile(ocrResult.textUrl!);
          }

          _resultMessage = 'OCR completed successfully!';
        });
      } else {
        setState(() {
          _resultMessage = 'OCR failed: ${response.userFriendlyError}';
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error performing OCR: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadSearchablePdf(String url) async {
    try {
      final file = await FileUtils.downloadFile(url);
      setState(() {
        _searchablePdfPath = file.path;
      });
    } catch (e) {
      setState(() {
        _resultMessage =
            'OCR completed, but error downloading searchable PDF: $e';
      });
    }
  }

  Future<void> _downloadTextFile(String url) async {
    try {
      final file = await FileUtils.downloadFile(url);
      setState(() {
        _textFilePath = file.path;
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'OCR completed, but error downloading text file: $e';
      });
    }
  }
}
