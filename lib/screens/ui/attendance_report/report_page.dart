import 'package:flutter/material.dart';
import 'package:sheraccerp/util/res_color.dart';

class ReportPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  
   ReportPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
        titleTextStyle: const TextStyle(
          color: white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // 
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:MaterialStatePropertyAll(kPrimaryColor),
                        border: TableBorder.all(width: 1.0, color: grey),
                        columnSpacing: 12,
                        headingTextStyle: const TextStyle(
                            fontFamily: 'poppins',
                            color: white,
                            fontWeight: FontWeight.w500),
                        dataRowHeight: 20,
                        headingRowHeight: 30,
              columns: const [
                // DataColumn(label: Text('S.No')),
                // DataColumn(label: Text('Employee Code')),
                DataColumn(label: Text('Name')),
                // DataColumn(label: Text('Shift')),
                DataColumn(label: Text('In Time')),
                DataColumn(label: Text('Out Time')),
                DataColumn(label: Text('Work Duration')),
                DataColumn(label: Text('Over Time')),
                DataColumn(label: Text('Total Duration')),
                DataColumn(label: Text('Status')),
              ],
              rows: data.map((item) {
                return DataRow(
                  cells: [
                    // DataCell(Text(item['Sno'].toString())),
                    // DataCell(Text(item['EmployeeCode'].toString())),
                    DataCell(Text(item['EmployeeName'].toString())),
                    // DataCell(Text(item['ShiftSName'].toString())),
                    DataCell(Text(item['InTime'].toString())),
                    DataCell(Text(item['OutTime'].toString())),
                    DataCell(Text(item['Duration'].toString())),
                    DataCell(Text(item['OverTime'].toString())),
                    DataCell(Text(item['TotalDuration'].toString())),
                    DataCell(Text(item['Status'].toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}