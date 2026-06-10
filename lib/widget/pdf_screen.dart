import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class PDFScreen extends StatefulWidget {
  final String? pathPDF;
  final String? text;
  final String? subject;
  final List<int>? bytes; // Add this for web support
  
  PDFScreen({
    Key? key, 
    this.pathPDF, 
    this.text, 
    this.subject,
    this.bytes, // Initialize this for web
  }) : super(key: key);

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  late String _pdfUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _loadWebPdf();
    } else {
      _isLoading = false;
    }
  }

  void _loadWebPdf() {
    if (widget.bytes != null) {
      final blob = html.Blob([widget.bytes!], 'application/pdf');
      _pdfUrl = html.Url.createObjectUrlFromBlob(blob);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    if (kIsWeb && _pdfUrl.isNotEmpty) {
      html.Url.revokeObjectUrl(_pdfUrl);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice PDF"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
          ),
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadPdf,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (kIsWeb) {
      return _buildWebPdfViewer();
    } else {
      return _buildMobilePdfViewer();
    }
  }

 Widget _buildWebPdfViewer() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.picture_as_pdf, size: 100, color: Colors.blue),
        const SizedBox(height: 20),
        const Text(
          'PDF is ready to view',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text('Click the button below to open the PDF'),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: _openPdfInNewTab,
          icon: const Icon(Icons.open_in_new),
          label: const Text('Open PDF'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _downloadPdf,
          icon: const Icon(Icons.download),
          label: const Text('Download PDF'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ],
    ),
  );
}

void _openPdfInNewTab() {
  html.window.open(_pdfUrl, '_blank');
}

  Widget _buildMobilePdfViewer() {
    return Center(
      child: Text('Mobile PDF Viewer - Path: ${widget.pathPDF}'),
    );
  }

  void _sharePdf() {
    if (kIsWeb) {
      final anchor = html.AnchorElement(href: _pdfUrl)
        ..download = 'invoice-${DateTime.now().millisecondsSinceEpoch}.pdf'
        ..click();
    } else {
      Share.shareXFiles([XFile(widget.pathPDF!)],
          text: widget.text,
          subject: widget.subject);
    }
  }

  void _downloadPdf() {
    if (kIsWeb) {
      final anchor = html.AnchorElement(href: _pdfUrl)
        ..download = 'invoice-${DateTime.now().millisecondsSinceEpoch}.pdf'
        ..click();
    }
  }
}
// import 'dart:io';

// import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// // import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:sheraccerp/util/res_color.dart';
// // import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// class PDFScreen extends StatelessWidget {
//   final String ?pathPDF;
//   final String? text;
//   final String? subject;
//   PDFScreen({Key? key, this.pathPDF, this.text, this.subject}) : super(key: key);

//   final List<String> paths = [];

//   bool loading= false;

//   @override
//   Widget build(BuildContext context) {
//     File file  = File(pathPDF!);

//     return Scaffold(
//         appBar: AppBar(
//           title: const Text("PDF Document"),
//           titleTextStyle: const TextStyle(
//             fontFamily: 'poppins',
//             color: white,
//           ),
//           actions: [
//             IconButton(
//               icon: Image.asset('assets/icons/ic_share.png',scale: 3.3,),
//               onPressed: () {
//                 paths.add(pathPDF!);
//                 urlFileShare(context, text!, subject!, paths);
//               },
//             ),
//           ],
//         ),
//         body:
//         FutureBuilder(future: PDFDocument.fromFile(file) , builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final data = snapshot.data;
//             return PDFViewer(document:data!);
//           }
//           else{
//           return  Center(child: const CircularProgressIndicator());
//           }
          
//         },)
        
//         // PdfView(path: pathPDF!)
//         // body: SfPdfViewer.file(File(pathPDF)),
//         // body: Container(),
//         );
//   }

//   Future<void> urlFileShare(BuildContext context, String text, String subject,
//       List<String> paths) async {
//     final RenderBox box = context.findRenderObject() as RenderBox;
//     if (paths.isNotEmpty) {
//       List<XFile> files = [];
//       for (String value in paths) {
//         files.add(XFile(value));
//       }
//       await Share.shareXFiles(files,
//           text: text,
//           subject: subject,
//           sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
//     }
//   }
// }

// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:html' as html;

// class PDFScreen extends StatefulWidget {
//   final String? pathPDF;
//   final String? text;
//   final String? subject;
//   final bool isWeb;
  
//   PDFScreen({
//     Key? key, 
//     required this.pathPDF,
//     this.text, 
//     this.subject,
//     this.isWeb = false,
//   }) : super(key: key);

//   @override
//   State<PDFScreen> createState() => _PDFScreenState();
// }

// class _PDFScreenState extends State<PDFScreen> {
//   bool loading = false;
//   PDFDocument? document;
//   String? errorMessage;
//   int retryCount = 0;
//   bool showFallbackOption = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadDocument();
//   }

//   Future<void> _loadDocument() async {
//     if (retryCount >= 3) {
//       setState(() => showFallbackOption = true);
//       return;
//     }

//     setState(() {
//       loading = true;
//       errorMessage = null;
//     });

//     try {
//       if (widget.pathPDF == null || widget.pathPDF!.isEmpty) {
//         throw Exception('Invalid PDF path');
//       }

//       if (widget.isWeb) {
//         // Try direct loading first
//         try {
//           document = await PDFDocument.fromURL(widget.pathPDF!)
//               .timeout(const Duration(seconds: 15));
//         } catch (e) {
//           // Fallback to CORS proxy if needed
//           final proxyUrl = 'http://cors-anywhere.herokuapp.com/${widget.pathPDF}';
//           document = await PDFDocument.fromURL(proxyUrl)
//               .timeout(const Duration(seconds: 15));
//         }
//       } else {
//         final file = File(widget.pathPDF!);
//         if (!await file.exists()) {
//           throw Exception('File not found at path: ${widget.pathPDF}');
//         }
//         document = await PDFDocument.fromFile(file);
//       }

//       // Validate PDF
//       if (document == null) {
//         throw Exception('PDF appears to be empty or corrupted');
//       }

//       retryCount = 0; // Reset retry count on success
//     } catch (e) {
//       retryCount++;
//       debugPrint('PDF Error (Attempt $retryCount): $e');
//       setState(() {
//         errorMessage = 'Failed to load PDF: ${e.toString().replaceAll('Exception: ', '')}';
//       });
      
//       // Auto-retry after delay
//       if (retryCount < 3) {
//         await Future.delayed(const Duration(seconds: 2));
//         return _loadDocument();
//       } else {
//         setState(() => showFallbackOption = true);
//       }
//     } finally {
//       if (mounted) {
//         setState(() => loading = false);
//       }
//     }
//   }

//   Future<void> _sharePDF() async {
//     if (document == null) return;
    
//     try {
//       if (widget.isWeb) {
//         if (kIsWeb) {
//           final anchor = html.AnchorElement()
//             ..href = widget.pathPDF!
//             ..style.display = 'none'
//             ..download = '${widget.subject ?? 'document'}.pdf';
//           html.document.body!.children.add(anchor);
//           anchor.click();
//           html.document.body!.children.remove(anchor);
//         }
//       } else {
//         await Share.shareXFiles(
//           [XFile(widget.pathPDF!)],
//           text: widget.text,
//           subject: widget.subject,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to share: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   Future<void> _downloadPDF() async {
//     if (!widget.isWeb || !kIsWeb) {
//       // For mobile, save to downloads folder
//       try {
//         final directory = await getDownloadsDirectory();
//         final path = '${directory?.path}/${widget.subject ?? 'document'}.pdf';
//         await File(widget.pathPDF!).copy(path);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('PDF saved to downloads folder')),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to save: ${e.toString()}')),
//           );
//         }
//       }
//       return;
//     }
//     _sharePDF(); // For web, same as share
//   }

//   Widget _buildBody() {
//     if (loading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading PDF...'),
//           ],
//         ),
//       );
//     }
    
//     if (errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, color: Colors.red, size: 48),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Text(
//                 errorMessage!,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 retryCount = 0;
//                 _loadDocument();
//               },
//               child: const Text('Retry Loading'),
//             ),
//             if (showFallbackOption) ...[
//               const SizedBox(height: 16),
//               Text(
//                 widget.isWeb 
//                     ? 'You can try opening the PDF in a new tab'
//                     : 'You can try opening with another app',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (widget.isWeb && kIsWeb) {
//                     html.window.open(widget.pathPDF!, '_blank');
//                   } else {
//                     await OpenFile.open(widget.pathPDF!);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange,
//                 ),
//                 child: const Text('Open Externally'),
//               ),
//             ],
//           ],
//         ),
//       );
//     }
    
//     if (document == null) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.insert_drive_file, size: 48, color: Colors.grey),
//             SizedBox(height: 16),
//             Text('No document available'),
//           ],
//         ),
//       );
//     }
    
//     return PDFViewer(
//       document: document!,
//       lazyLoad: false,
//       scrollDirection: Axis.vertical,
//       indicatorBackground: Colors.blue,
//       indicatorText: Colors.white,
//       progressIndicator: const CircularProgressIndicator(),
//       // errorWidget: (error) => Center(
//       //   child: Text('Error displaying PDF: $error'),
//       // ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("PDF Document"),
//         actions: [
//           if (document != null) ...[
//             IconButton(
//               icon: const Icon(Icons.share),
//               onPressed: _sharePDF,
//               tooltip: 'Share PDF',
//             ),
//             IconButton(
//               icon: const Icon(Icons.download),
//               onPressed: _downloadPDF,
//               tooltip: widget.isWeb ? 'Download PDF' : 'Save PDF',
//             ),
//           ],
//         ],
//       ),
//       body: _buildBody(),
//       floatingActionButton: loading || document == null
//           ? null
//           : FloatingActionButton(
//               child: const Icon(Icons.refresh),
//               onPressed: () {
//                 retryCount = 0;
//                 _loadDocument();
//               },
//             ),
//     );
//   }
// }