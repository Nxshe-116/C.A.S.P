// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:html' as html;

class PdfViewerPage extends StatefulWidget {
  final String fileName;

  const PdfViewerPage({super.key, required this.fileName});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  Uint8List? pdfData;
  String? errorMessage;
  bool isLoading = true;
  late PdfViewerController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    loadPdf();
  }

  Future<void> loadPdf() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (kIsWeb) {
        // For web deployment
        final path = 'assets/documents/${widget.fileName}';
        print('Loading PDF from: $path');

        // Try direct HTTP request first
        try {
          final response = await html.HttpRequest.request(
            path,
            responseType: 'arraybuffer',
          );

          if (response.status == 200) {
            final bytes = (response.response as ByteBuffer).asUint8List();
            if (bytes.isEmpty) throw Exception('PDF file is empty');
            
            setState(() {
              pdfData = bytes;
              isLoading = false;
            });
            return;
          }
        } catch (e) {
          print('HTTP request failed: $e');
          // Fall through to rootBundle approach
        }

        // Fallback to rootBundle
        try {
          final bytes = await rootBundle.load(path);
          setState(() {
            pdfData = bytes.buffer.asUint8List();
            isLoading = false;
          });
          return;
        } catch (e) {
          print('rootBundle load failed: $e');
        }

        throw Exception('All loading methods failed');
      } else {
        // Mobile/Desktop implementation
        final path = 'assets/documents/${widget.fileName}';
        final bytes = await rootBundle.load(path);
        setState(() {
          pdfData = bytes.buffer.asUint8List();
          isLoading = false;
        });
      }
    } catch (e) {
      print('PDF loading error: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = 'Failed to load PDF. Please ensure the file exists at: assets/documents/${widget.fileName}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadPdf,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SfPdfViewer.memory(
      pdfData!,
      controller: _pdfController,
      canShowPaginationDialog: true,
      onDocumentLoaded: (details) {
        print('PDF loaded successfully - ${details.document.pages.count} pages');
      },
      onDocumentLoadFailed: (details) {
        print('PDF load failed: ${details.error}');
        if (!mounted) return;
        setState(() {
          errorMessage = 'Failed to display PDF content. The file might be corrupted.';
          pdfData = null;
        });
      },
    );
  }
}