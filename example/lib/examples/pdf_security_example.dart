import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:scanpro_dart/scanpro.dart';
import 'package:scanpro_dart_example/file_utils.dart';
import 'package:share_plus/share_plus.dart';

enum OperationMode { protect, unlock }

class PdfSecurityExample extends StatefulWidget {
  const PdfSecurityExample({super.key});

  @override
  State<PdfSecurityExample> createState() => _PdfSecurityExampleState();
}

class _PdfSecurityExampleState extends State<PdfSecurityExample> {
  File? _selectedFile;
  String _selectedFileName = '';
  bool _isLoading = false;
  String _resultMessage = '';
  String? _outputFilePath;

  // Operation mode

  OperationMode _mode = OperationMode.protect;

  // Password fields
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ownerPasswordController =
      TextEditingController();

  // Protection options
  bool _allowPrinting = false;
  bool _allowCopying = false;
  bool _allowEditing = false;
  String _encryptionLevel = '256';

  @override
  void dispose() {
    _passwordController.dispose();
    _ownerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Security Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operation mode selection
            _buildOperationModeSelection(),
            const SizedBox(height: 16),

            // File selection button
            const Text(
              'Select a PDF file:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFileSelectionButton(),
            const SizedBox(height: 16),

            // Password fields
            _buildPasswordFields(),
            const SizedBox(height: 16),

            // Protection options (only show for protect mode)
            if (_mode == OperationMode.protect) _buildProtectionOptions(),
            const SizedBox(height: 16),

            // Process button
            _buildProcessButton(),

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
                    color: _outputFilePath != null ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Actions for output file
            if (_outputFilePath != null) _buildFileActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationModeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select operation:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<OperationMode>(
                title: const Text('Protect PDF'),
                value: OperationMode.protect,
                groupValue: _mode,
                onChanged: (OperationMode? value) {
                  if (value != null) {
                    setState(() {
                      _mode = value;
                      _resultMessage = '';
                      _outputFilePath = null;
                    });
                  }
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<OperationMode>(
                title: const Text('Unlock PDF'),
                value: OperationMode.unlock,
                groupValue: _mode,
                onChanged: (OperationMode? value) {
                  if (value != null) {
                    setState(() {
                      _mode = value;
                      _resultMessage = '';
                      _outputFilePath = null;
                    });
                  }
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileSelectionButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.file_upload),
          label: const Text('Select PDF file'),
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

  Widget _buildPasswordFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password Information:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText:
                _mode == OperationMode.protect
                    ? 'User Password (required to open the PDF)'
                    : 'PDF Password',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          obscureText: true,
        ),
        if (_mode == OperationMode.protect) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _ownerPasswordController,
            decoration: const InputDecoration(
              labelText: 'Owner Password (optional, for changing permissions)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 4),
          const Text(
            'Leave owner password blank to use the same as user password.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProtectionOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Protection Options:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Allow Printing'),
                value: _allowPrinting,
                onChanged: (bool value) {
                  setState(() {
                    _allowPrinting = value;
                  });
                },
                dense: true,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Allow Copying Content'),
                value: _allowCopying,
                onChanged: (bool value) {
                  setState(() {
                    _allowCopying = value;
                  });
                },
                dense: true,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Allow Editing'),
                value: _allowEditing,
                onChanged: (bool value) {
                  setState(() {
                    _allowEditing = value;
                  });
                },
                dense: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _encryptionLevel,
          decoration: const InputDecoration(
            labelText: 'Encryption Level',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(
              value: '40',
              child: Text('40-bit (Acrobat 3.0 and later)'),
            ),
            DropdownMenuItem(
              value: '128',
              child: Text('128-bit (Acrobat 5.0 and later)'),
            ),
            DropdownMenuItem(
              value: '256',
              child: Text('256-bit AES (Acrobat 9.0 and later)'),
            ),
          ],
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _encryptionLevel = newValue;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildProcessButton() {
    return ElevatedButton.icon(
      onPressed: _canProcess() ? _processFile : null,
      icon: Icon(
        _mode == OperationMode.protect ? Icons.security : Icons.lock_open,
      ),
      label: Text(
        _mode == OperationMode.protect ? 'Protect PDF' : 'Unlock PDF',
      ),
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
        Text(
          _mode == OperationMode.protect ? 'Protected PDF:' : 'Unlocked PDF:',
          style: const TextStyle(fontWeight: FontWeight.bold),
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

  bool _canProcess() {
    if (_selectedFile == null) return false;
    if (_passwordController.text.isEmpty) return false;
    return true;
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
          _resultMessage = '';
          _outputFilePath = null;
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error selecting file: $e';
      });
    }
  }

  Future<void> _processFile() async {
    if (_selectedFile == null || _passwordController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _resultMessage =
          _mode == OperationMode.protect
              ? 'Protecting PDF...'
              : 'Unlocking PDF...';
      _outputFilePath = null;
    });

    try {
      ApiResponse response;

      if (_mode == OperationMode.protect) {
        // Create protect options
        final options = ProtectPdfOptions(
          password: _passwordController.text,
          ownerPassword:
              _ownerPasswordController.text.isNotEmpty
                  ? _ownerPasswordController.text
                  : null,
          encryptionLevel: _encryptionLevel,
          allowPrinting: _allowPrinting,
          allowCopying: _allowCopying,
          allowEditing: _allowEditing,
        );

        // Protect the PDF
        response = await ScanPro.api.security.protectPdf(
          _selectedFile!,
          options,
        );
      } else {
        // Unlock the PDF
        response = await ScanPro.api.security.unlockPdf(
          _selectedFile!,
          _passwordController.text,
        );
      }

      if (response.success) {
        // Download the processed file
        if (response.fileUrl != null) {
          final file = await FileUtils.downloadFile(response.fileUrl!);

          setState(() {
            _outputFilePath = file.path;
            _resultMessage =
                _mode == OperationMode.protect
                    ? 'PDF protected successfully! File saved to: ${file.path}'
                    : 'PDF unlocked successfully! File saved to: ${file.path}';
          });
        } else {
          setState(() {
            _resultMessage =
                'Operation successful, but no file URL was returned.';
          });
        }
      } else {
        setState(() {
          _resultMessage = 'Operation failed: ${response.userFriendlyError}';
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error processing file: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openFile() {
    if (_outputFilePath != null) {
      OpenFile.open(_outputFilePath!);
    }
  }

  void _shareFile() {
    if (_outputFilePath != null) {
      Share.shareXFiles([XFile(_outputFilePath!)]);
    }
  }
}
