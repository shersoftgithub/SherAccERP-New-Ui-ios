import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraccerp/util/res_color.dart';

class SalesPredictionReport extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SalesPredictionReport({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Report'),
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
}
