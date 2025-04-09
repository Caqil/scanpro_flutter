import 'package:flutter/material.dart';
import 'package:scanpro_dart/scanpro_flutter.dart';
import 'package:scanpro_dart_example/examples/merge_pdf_example.dart';

import 'examples/ocr_example.dart';
import 'examples/pdf_conversion_example.dart';
import 'examples/pdf_security_example.dart';

void main() {
  // Initialize ScanPro with your API key
  ScanPro.initialize(apiKey: 'YOUR_API_KEY_HERE');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanPro Flutter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScanPro Flutter Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'ScanPro Flutter Plugin Examples',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildExampleButton(
                context,
                'PDF Conversion',
                'Convert PDFs to and from various formats',
                Icons.file_copy,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PdfConversionExample(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildExampleButton(
                context,
                'Merge PDFs',
                'Combine multiple PDF files into one',
                Icons.merge_type,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MergePdfExample(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildExampleButton(
                context,
                'PDF Security',
                'Protect and unlock PDF documents',
                Icons.security,
                Colors.red,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PdfSecurityExample(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildExampleButton(
                context,
                'OCR',
                'Extract text from images and PDFs',
                Icons.document_scanner,
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OcrExample()),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Note: Make sure to set your API key in main.dart before running the examples.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleButton(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
