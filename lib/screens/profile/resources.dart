// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'dart:html' as html;

import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ResourcesScreen extends StatefulWidget {
  final String name;
  final String lastName;
  final String uid;

  const ResourcesScreen({
    Key? key,
    required this.name,
    required this.lastName,
    required this.uid,
  }) : super(key: key);

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class FrameworkDocument {
  final String title;
  final String type;
  final String url;

  FrameworkDocument({
    required this.title,
    required this.type,
    required this.url,
  });
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final List<FrameworkDocument> documents = [
    FrameworkDocument(
      title: "World Bank Risk Country Profile(Zimbabwe)",
      type: "PDF",
      url: "file1.pdf",
    ),
    FrameworkDocument(
      title: "National Climate Change Response Strategy",
      type: "PDF",
      url: "file2.pdf",
    ),
    FrameworkDocument(
      title: "Zimbabwe Climate Policy(2016)",
      type: "PDF",
      url: "file3.pdf",
    ),
  ];

  bool isPdfDialogOpen = false;
  String? currentPdfUrl;
  bool isPdfLoading = true;
  String? currentPdfTitle;
  late PdfViewerController pdfViewerController;

  @override
  void initState() {
    super.initState();
    pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> openPdfPopup(String pdfUrl, String title) async {
    try {
      if (!mounted) return;

      setState(() {
        currentPdfUrl = pdfUrl;
        currentPdfTitle = title;
        isPdfDialogOpen = true;
        isPdfLoading = true;
      });

      // // Verify the file exists
      // final manifestContent = await rootBundle.loadString('AssetManifest.json');
      // final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      try {
        await rootBundle.load(pdfUrl); // Try loading directly
      } catch (e) {
        print('PDF file not found: $pdfUrl');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF file not found')),
        );
        closePdfPopup();
        return;
      }

      // For web, preload the PDF to verify it can be loaded
      if (kIsWeb) {
        try {
          final filename = pdfUrl.replaceFirst('assets/documents/', '');
          await rootBundle.load('assets/documents/$filename');
        } catch (e) {
          print('Error loading PDF: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading PDF: ${e.toString()}')),
          );
          closePdfPopup();
        }
      }
    } catch (e) {
      print('Error opening PDF: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      closePdfPopup();
    }
  }

  void closePdfPopup() {
    if (!mounted) return;
    setState(() {
      isPdfDialogOpen = false;
      currentPdfUrl = null;
      currentPdfTitle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                Header(
                  text: "Regulatory Framework",
                  name: widget.name,
                  lastName: widget.lastName,
                ),
                const SizedBox(height: defaultPadding),
                buildDocumentList(),
              ],
            ),
          ),
          if (isPdfDialogOpen) buildPdfDialog(),
        ],
      ),
    );
  }

  Widget buildDocumentList() {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Available Documents",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...documents.map((doc) => buildDocumentCard(doc)).toList(),
          ],
        ),
      ),
    );
  }

  Widget buildDocumentCard(FrameworkDocument doc) {
    return Card(
      color: const Color(0xFFF4FAFF),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          doc.type == "PDF" ? Icons.picture_as_pdf : Icons.link,
          color: primaryColor,
        ),
        title: Text(doc.title),
        subtitle: Text(doc.type),
        onTap: () {
          final pdfPath = 'assets/documents/${doc.url}';
          print('Opening PDF: $pdfPath');
          openPdfPopup(pdfPath, doc.title);
        },
      ),
    );
  }

  Widget buildPdfDialog() {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        color: const Color(0xFFF4FAFF),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentPdfTitle ?? 'Document',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding * 1.5,
                          vertical: defaultPadding /
                              (Responsive.isMobile(context) ? 2 : 1),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      onPressed: () {
                        openPdfInNewTab(currentPdfUrl!);
                      },
                      icon: Icon(Icons.download, color: Colors.white),
                      label: Text("Download",
                          style: TextStyle(color: Colors.white)),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.redAccent,
                      ),
                      onPressed: closePdfPopup,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: kIsWeb ? buildWebPdfViewer() : buildMobilePdfViewer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWebPdfViewer() {
    if (currentPdfUrl == null)
      return const Center(child: Text('No PDF selected'));

    return FutureBuilder<Uint8List>(
      future: rootBundle
          .load(currentPdfUrl!)
          .then((data) => data.buffer.asUint8List()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading PDF: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return SfPdfViewer.memory(
          snapshot.data!,
          controller: pdfViewerController,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF failed to load: ${details.error}')),
            );
          },
        );
      },
    );
  }

  Future<Uint8List> loadPdfBytes(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      return byteData.buffer.asUint8List();
    } catch (e) {
      throw Exception('Failed to load PDF bytes: $e');
    }
  }

  Widget buildMobilePdfViewer() {
    if (currentPdfUrl == null) {
      return const Center(child: Text('No PDF selected'));
    }

    return FutureBuilder<String>(
      future: getPdfPath(currentPdfUrl!.replaceFirst('assets/documents/', '')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final file = File(snapshot.data!);
          if (!file.existsSync()) {
            return const Center(child: Text('PDF file not found'));
          }

          return SfPdfViewer.file(
            file,
            controller: pdfViewerController,
            onDocumentLoaded: (details) {
              if (mounted) {
                setState(() => isPdfLoading = false);
              }
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<String> getPdfPath(String filename) async {
    try {
      final ByteData data = await rootBundle.load('assets/documents/$filename');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      return file.path;
    } catch (e) {
      throw Exception('Failed to load PDF: $e');
    }
  }

  Future<void> openPdfInNewTab(String pdfUrl) async {
    try {
      final fullPath = '$pdfUrl';
      final bytes = await rootBundle.load(fullPath);
      final blob = html.Blob([bytes.buffer.asUint8List()], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
    } catch (e) {
      print('Error opening PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: ${e.toString()}')),
      );
    }
  }
}
