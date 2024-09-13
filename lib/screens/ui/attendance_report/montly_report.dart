
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraccerp/util/res_color.dart';

class MonthlyReportPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  
   MonthlyReportPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    debugPrint(dateDMY('2024-08-15"'));
    List tableColumns = data[0].keys.toList();
    // tableColumns.removeAt(0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
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
              columns: 
              
               [
                for(var item in tableColumns)

                (DataColumn(label: Text( ( item == 'EmployeeCode' || item== 'EmployeeName' || item== 'P' || item== 'A' || item== 'L'|| item== 'H' || item== 'HP' ||item== 'WO' || item== 'WOP')? item
                 : (item== 'EmpCode'||item== 'S0') ? ' ': dateDMY(item)
                  ))),
              ],
              rows:
               data.map((item) {    
                return DataRow(
                  cells: [
                    for(int index = 0 ; index < item.length ; index ++)
                    DataCell(Text(
                      tableColumns[index] == 'EmpCode' ? ' '
                     : item[tableColumns[index]].toString())),
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
  String dateDMY(value) {
    var dateTime = DateFormat("yyyy-MM-dd").parse(value.toString());

    return dateTime.day.toString() + ' ' + weekDayName[dateTime.weekday]!;
    // DateFormat("dd-MM-yyyy").format(dateTime);
  }
   
  Map<int , String> weekDayName = { 1: 'Mo',2:'Tu',3:'We' ,4:'Th',5:'Fr',6:'Sa',7:'Su'} ;