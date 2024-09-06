
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sheraccerp/screens/ui/attendance_report/montly_report.dart';
import 'package:sheraccerp/screens/ui/attendance_report/report_page.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'dart:convert';

import 'package:sheraccerp/util/res_color.dart';

class AttendanceHomePage extends StatefulWidget {
  const AttendanceHomePage({super.key});

  @override
  State<AttendanceHomePage> createState() => _AttendanceHomePageState();
}

class _AttendanceHomePageState extends State<AttendanceHomePage> {
  DioService api = DioService();
  String? fromDate, toDate;
  DateTime now = DateTime.now();
  bool isLoading = false; 
  String? errorMessage; 
  List<String> dropdownType = ['Basic Report', 'Monthly wise',];
  String? selectedType ;

  @override
  void initState() {
    super.initState();
    fromDate = datePickerDMY(now);
    toDate = datePickerDMY(now);
    selectedType = dropdownType.first;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        title: const Text('Attendance Report'),
        titleTextStyle: const TextStyle(
          color: white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  const Text(
                    'From ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      fontFamily: 'poppins',
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _selectDate('f');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: grey),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          Text(
                            fromDate!,
                            style: const TextStyle(fontFamily: 'poppins'),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'To ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      fontFamily: 'poppins',
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _selectDate('t');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: grey),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          Text(
                            toDate!,
                            style: const TextStyle(fontFamily: 'poppins'),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text('Report Type',
             style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      fontFamily: 'poppins',
                    ),
            ),
            const SizedBox(height: 4),
           Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 5,),
              decoration: BoxDecoration(
                border: Border.all(color: grey),
                borderRadius: BorderRadius.circular(3),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedType,
                  items: dropdownType.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                    debugPrint(selectedType);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (isLoading) 
              const Center(child: CircularProgressIndicator())
            else 
              Column(
                children: [
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                        )
                      ),
                      onPressed:
                      selectedType == 'Basic Report'? () async {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });

                        try {
                          var data = await api.getAttendanceReport(formatYMD(fromDate), formatYMD(toDate));
                          List<Map<String, dynamic>> displayData=[];
                          for(var item in data){
                            if (isDateMatch(item["AttendanceDate"])) {
                              displayData.add(item);
                          } else{
                            Map<String,dynamic> map={};
                            map.addAll({"AttendanceDate":item["AttendanceDate"],"Sno":"----------","EmployeeCode":"----------","EmployeeName":item["AttendanceDate"],"ShiftSName":"----------","InTime":"----------","OutTime":"----------","Duration":"----------","OverTime":"----------","TotalDuration":"----------","Status":"----------"}); 
                            displayData.add(map);
                            displayData.add(item);
                          }
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportPage(data: displayData),
                            ),
                          );
                        } catch (e) {
                          setState(() {
                            errorMessage = "Error: $e";
                          });
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                      :
                      () async{
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });

                        try {
                          var data = await api.getAttendanceReportMonthly(formatYMD(fromDate), formatYMD(toDate));
                          List<Map<String, dynamic>> displayData=[];
                          debugPrint(data.toString());
                          for(var item in data){
                            // if (isDateMatch(item["AttendanceDate"])) {
                              displayData.add(item);
                          //     debugPrint(displayData.toString());
                          // } 
                          // else{
                          //   Map<String,dynamic> map={};
                          //   map.addAll({"AttendanceDate":item["AttendanceDate"],"Sno":"----------","EmployeeCode":"----------","EmployeeName":item["AttendanceDate"],"ShiftSName":"----------","InTime":"----------","OutTime":"----------","Duration":"----------","OverTime":"----------","TotalDuration":"----------","Status":"----------"}); 
                          //   displayData.add(map);
                          //   displayData.add(item);
                          // }
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MonthlyReportPage(data: displayData),
                            ),
                          );
                        } catch (e) {
                          setState(() {
                            errorMessage = "Error: $e";
                            
                          });
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      // }
                        // fetchMonthly();
                        // Fluttertoast.showToast(
                        //   msg: 'Under maintenance');
                      },
                      child: const Text('Show Report',
                      style: TextStyle(
                        color: white
                      ),
                      ),
                    ),
                  ),
                  if (errorMessage != null) 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String formatYMD(value) {
    var dateTime = DateFormat("dd-MM-yyyy").parse(value.toString());
    return DateFormat("yyyy-MM-dd").format(dateTime);
  }

  Future<void> _selectDate(String type) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (type == 'f') {
          fromDate = datePickerDMY(picked);
        } else {
          toDate = datePickerDMY(picked);
        }
      });
    }
  }

  static String datePickerDMY(DateTime picker) {
    return DateFormat('dd-MM-yyyy').format(picker);
  }
  
String currentDate = '';
 bool isDateMatch(String date){
  bool ret =false;
  ret = currentDate.isEmpty? false : currentDate == date ? true :false;
  currentDate = date;
     return ret;
  }
}
