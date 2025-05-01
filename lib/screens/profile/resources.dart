// ignore_for_file: deprecated_member_use, unused_local_variable

import 'dart:html' as html;
import 'dart:io';
import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:admin/screens/profile/pdfviewer.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
  String? currentPdfTitle;

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
          final pdfPath = doc.url; // Just use the filename
          print('Opening PDF: $pdfPath');
          openPdfPopup(pdfPath, doc.title);
        },
      ),
    );
  }

  Future<void> openPdfPopup(String pdfUrl, String title) async {
    try {
      setState(() {
        currentPdfUrl = pdfUrl;
        currentPdfTitle = title;
        isPdfDialogOpen = true;
      });
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
            // In your buildPdfDialog method:
            Expanded(
              child: currentPdfUrl != null
                  ? PdfViewerPage(fileName: currentPdfUrl!)
                  : const Center(child: Text('No PDF selected')),
            )
          ],
        ),
      ),
    );
  }

  Future<void> openPdfInNewTab(String pdfUrl) async {
    try {
      if (kIsWeb) {
        // Web download implementation
        final anchor = html.AnchorElement()
          ..href = 'assets/documents/$pdfUrl'
          ..target = '_blank'
          ..download = pdfUrl
          ..click();
      } else {
        // Mobile download implementation
        final bytes = await rootBundle.load('assets/documents/$pdfUrl');
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$pdfUrl');
        await file.writeAsBytes(bytes.buffer.asUint8List());
        // Open the file - requires open_file package
        // await OpenFile.open(file.path);
      }
    } catch (e) {
      print('Download error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: ${e.toString()}')),
      );
    }
  }
}
