
import 'dart:io';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFScreen extends StatelessWidget {
  final String ?pathPDF;
  final String? text;
  final String? subject;
  PDFScreen({Key ?key, this.pathPDF, this.text, this.subject}) : super(key: key);

  final List<String> paths = [];
  bool loading= false;

  @override
  Widget build(BuildContext context) {
    File file  = File(pathPDF!);

    return Scaffold(
        appBar: AppBar(
          title: const Text("PDF Document"),
          titleTextStyle: const TextStyle(
            fontFamily: 'poppins'
          ),
          actions: [
            IconButton(
              icon: Image.asset('assets/icons/ic_share.png',scale: 3.3,),
              onPressed: () {
                paths.add(pathPDF!);
                urlFileShare(context, text!, subject!, paths);
              },
            ),
          ],
        ),
        body:
        FutureBuilder(future: PDFDocument.fromFile(file) , builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;
            return PDFViewer(document:data!);
          }
          else{
          return  Center(child: const CircularProgressIndicator());
          }
          
        },)
        
        // PdfView(path: pathPDF!)
        // body: SfPdfViewer.file(File(pathPDF)),
        // body: Container(),
        );
  }

  Future<void> urlFileShare(BuildContext context, String text, String subject,
      List<String> paths) async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    if (paths.isNotEmpty) {
      List<XFile> files = [];
      for (String value in paths) {
        files.add(XFile(value));
      }
      await Share.shareXFiles(files,
          text: text,
          subject: subject,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }
}
