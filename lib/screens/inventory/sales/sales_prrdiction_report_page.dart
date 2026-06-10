import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:sheraccerp/util/res_color.dart';

class SalesPredictionReport extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SalesPredictionReport({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Report'),
        titleTextStyle: const TextStyle(
          color: white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              await shareReportAsPdf();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(kPrimaryColor),
              border: TableBorder.all(width: 1.0, color: grey),
              columnSpacing: 12,
              headingTextStyle: const TextStyle(
                fontFamily: 'poppins',
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              dataRowHeight: 20,
              headingRowHeight: 30,
              columns: const [
                DataColumn(label: Text('Item Name')),
                DataColumn(label: Text('Last Sold Date')),
                DataColumn(label: Text('Last Sold Qty')),
                DataColumn(label: Text('Predicted Next Sale Date')),
                DataColumn(label: Text('Predicted Next Qty')),
              ],
              rows: data.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item['ItemName'].toString())),
                    DataCell(Text(formatYMD(item['LastSoldDate'].toString()))),
                    DataCell(Text(item['LastSoldQty'].toString())),
                    DataCell(Text(formatYMD(item['PredictedNextSaleDate'].toString()))),
                    DataCell(Text(item['PredictedNextQty'].toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String formatYMD(value) {
    var dateTime = DateFormat("yyyy-MM-dd").parse(value.toString());
    return DateFormat("dd-MM-yyyy").format(dateTime);
  }

  Future<void> shareReportAsPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: [
              'Item Name',
              'Last Sold Date',
              'Last Sold Qty',
              'Predicted Next Sale Date',
              'Predicted Next Qty',
            ],
            data: data.map((item) {
              return [
                item['ItemName'].toString(),
                formatYMD(item['LastSoldDate'].toString()),
                item['LastSoldQty'].toString(),
                formatYMD(item['PredictedNextSaleDate'].toString()),
                item['PredictedNextQty'].toString(),
              ];
            }).toList(),
          );
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();

    final directory = await Directory.systemTemp.createTemp();
    final pdfFile = File('${directory.path}/sales_prediction_report.pdf');
    await pdfFile.writeAsBytes(pdfBytes);

    // Share the PDF file using share_plus
    final XFile xFile = XFile(pdfFile.path);
    await Share.shareXFiles([xFile], text: 'Sales Prediction Report');
  }
}
