import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:scanpro_dart/scanpro.dart';
import 'package:scanpro_dart_example/file_utils.dart';
import 'package:share_plus/share_plus.dart';

class MergePdfExample extends StatefulWidget {
  const MergePdfExample({super.key});

  @override
  State<MergePdfExample> createState() => _MergePdfExampleState();
}

class _MergePdfExampleState extends State<MergePdfExample> {
  final List<File> _selectedFiles = [];
  bool _isLoading = false;
  String _resultMessage = '';
  String? _mergedFilePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge PDFs Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select PDF files to merge:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFileSelectionButton(),
            const SizedBox(height: 16),

            // Selected files list
            if (_selectedFiles.isNotEmpty) _buildSelectedFilesList(),
            const SizedBox(height: 16),

            // Merge button
            _buildMergeButton(),

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
                    color: _mergedFilePath != null ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Actions for merged file
            if (_mergedFilePath != null) _buildFileActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectionButton() {
    return ElevatedButton.icon(
      onPressed: _pickFiles,
      icon: const Icon(Icons.file_upload),
      label: const Text('Select PDF files'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected files:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedFiles.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final file = _selectedFiles[index];
              final fileName = file.path.split('/').last;

              return ListTile(
                dense: true,
                title: Text(fileName),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _selectedFiles.removeAt(index);
                      _resultMessage = '';
                      _mergedFilePath = null;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.add),
              label: const Text('Add more files'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFiles.clear();
                  _resultMessage = '';
                  _mergedFilePath = null;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear all'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMergeButton() {
    return ElevatedButton.icon(
      onPressed: _selectedFiles.length >= 2 ? _mergeFiles : null,
      icon: const Icon(Icons.merge_type),
      label: const Text('Merge PDFs'),
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
          'Merged PDF:',
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

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final newFiles =
            result.files
                .where((file) => file.path != null)
                .map((file) => File(file.path!))
                .toList();

        setState(() {
          _selectedFiles.addAll(newFiles);
          _resultMessage = '';
          _mergedFilePath = null;
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error selecting files: $e';
      });
    }
  }

  Future<void> _mergeFiles() async {
    if (_selectedFiles.length < 2) {
      setState(() {
        _resultMessage = 'Please select at least 2 PDF files to merge.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _resultMessage = 'Merging PDF files...';
      _mergedFilePath = null;
    });

    try {
      // Create merge options
      final options = const MergeOptions();

      // Perform the merge
      final response = await ScanPro.api.pdfTools.mergePdfs(
        _selectedFiles,
        options: options,
      );

      if (response.success) {
        // Download the merged file
        if (response.fileUrl != null) {
          final file = await FileUtils.downloadFile(response.fileUrl!);

          setState(() {
            _mergedFilePath = file.path;
            _resultMessage = 'Merge successful! File saved to: ${file.path}';
          });
        } else {
          setState(() {
            _resultMessage = 'Merge successful, but no file URL was returned.';
          });
        }
      } else {
        setState(() {
          _resultMessage = 'Merge failed: ${response.userFriendlyError}';
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error merging files: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openFile() {
    if (_mergedFilePath != null) {
      OpenFile.open(_mergedFilePath!);
    }
  }

  void _shareFile() {
    if (_mergedFilePath != null) {
      Share.shareXFiles([XFile(_mergedFilePath!)]);
    }
  }
}
