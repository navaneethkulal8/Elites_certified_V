import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Add this import
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class LoadURL extends StatefulWidget {
  final String pdfUrl;

  LoadURL({required this.pdfUrl});

  @override
  _LoadURLState createState() => _LoadURLState();
}

class _LoadURLState extends State<LoadURL> {
  PDFDocument? doc;

  @override
  void initState() {
    super.initState();
    loadPDFFromURL(widget.pdfUrl);
  }

  // Function to load PDF from a URL
  Future<void> loadPDFFromURL(String url) async {
    try {
      final pdfDocument = await loadPDF(url);

      if (pdfDocument != null) {
        setState(() {
          doc = pdfDocument;
        });
      }
    } catch (e) {
      print("Error loading PDF: $e");
    }
  }

  // Function to download the PDF from the network
  Future<PDFDocument?> loadPDF(String url) async {
    try {
      final bytes = await firebase_storage.FirebaseStorage.instance
          .refFromURL(url)
          .getData();

      if (bytes != null) {
        final tempPath = (await getTemporaryDirectory()).path;
        final pdfPath = '$tempPath/temp.pdf';
        await File(pdfPath).writeAsBytes(bytes);
        return PDFDocument.fromFile(File(pdfPath));
      } else {
        return null;
      }
    } catch (e) {
      print("Error loading PDF: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(46, 49, 146, 38),
        title: Text('Certificate'),
      ),
      body: doc == null
          ? Center(child: CircularProgressIndicator())
          : ViewPDF(document: doc!), // Use the ViewPDF widget here
    );
  }
}

class ViewPDF extends StatefulWidget {
  final PDFDocument document;

  ViewPDF({required this.document});

  @override
  _ViewPDFState createState() => _ViewPDFState();
}

class _ViewPDFState extends State<ViewPDF> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: PDFViewer(document: widget.document),
    );
  }
}
