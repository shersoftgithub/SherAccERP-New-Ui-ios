import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraccerp/attendance/model/leave_salesman_model.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/util/res_color.dart';

class MyLeavesView extends StatefulWidget {
  final dynamic salesmanInfo;

  const MyLeavesView({
    Key? key,
    required this.salesmanInfo,
  }) : super(key: key);

  @override
  State<MyLeavesView> createState() => _MyLeavesViewState();
}

class _MyLeavesViewState extends State<MyLeavesView> {
  DateTime currentDate = DateTime.now();
  DioService api = DioService();
  List<AbsentDay> absentDays = [];
  bool isLoading = false;

  String get displayDate {
    return DateFormat('MMMM yyyy').format(currentDate);
  }

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  void _goToPreviousMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month - 1, 1);
    });
    _loadAttendanceData();
  }

  void _goToNextMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    });
    _loadAttendanceData();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        currentDate = picked;
      });
      _loadAttendanceData();
    }
  }

  Future<void> _loadAttendanceData() async {
    setState(() => isLoading = true);

    try {
      final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
      final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);

      final presentDays = await api.getLeaveReportBySalesman(
        widget.salesmanInfo.key,
        firstDayOfMonth,
      );

      if (mounted) {
        setState(() {
          absentDays = _calculateAbsentDays(firstDayOfMonth, lastDayOfMonth, presentDays ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error loading attendance data: $e');
      if (mounted) {
        setState(() {
          absentDays = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<AbsentDay> _calculateAbsentDays(
    DateTime firstDayOfMonth,
    DateTime lastDayOfMonth,
    List<LeavesModel> presentDays,
  ) {
    final List<AbsentDay> absentDays = [];

    final presentDates = presentDays.map((day) {
      try {
        return DateFormat('yyyy-MM-dd').format(day.ddate);
      } catch (e) {
        return '';
      }
    }).where((date) => date.isNotEmpty).toSet();

    for (var date = firstDayOfMonth;
        date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final isSunday = date.weekday == DateTime.sunday;

      if (!presentDates.contains(dateStr) && !isSunday) {
        absentDays.add(AbsentDay(date: date, isWeekend: false));
      } else if (isSunday) {
        absentDays.add(AbsentDay(date: date, isWeekend: true));
      }
    }

    return absentDays;
  }

 Widget _buildAbsentDaysTable(List<AbsentDay> absentDays) {
final filteredDays = absentDays.where((day) => day.date.isBefore(DateTime.now())).toList();

  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: const Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Date',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Expanded(
            //   flex: 3,
            //   child: Text(
            //     'Status',
            //     style: TextStyle(
            //       fontSize: 13,
            //       fontFamily: 'poppins',
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      ...filteredDays.map((day) {
        final dayStyle = TextStyle(
          fontFamily: 'poppins',
          fontWeight: FontWeight.w500,
          color: day.isWeekend ? Colors.blue : red,
        );

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Expanded(
                // flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width / 9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            width: .1,
                            color: Colors.grey.withOpacity(0.9)
                          ),
                          color:bagroundColor,
                          boxShadow: [
                            BoxShadow(
                          offset: const Offset(0, 5),
                          blurRadius: 6,
                          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.06),
                        ),
                          ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2.0,
                            vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(child: Text(DateFormat('dd').format(day.date),
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500
                              ),
                              )),
                              Center(child: Text(DateFormat('EEE').format(day.date).toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500
                              ),))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Expanded(
              //   // flex: 2,
              //   child: Padding(
              //     padding: const EdgeInsets.all(0.0),
              //     child: Container(
              //       width: MediaQuery.sizeOf(context).width / 3,
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(3),
              //         border: Border.all(
              //           width: .1,
              //           color: Colors.grey.withOpacity(0.9),
              //         ),
              //         color:  bagroundColor,
              //         boxShadow: [
              //           BoxShadow(
              //             offset: const Offset(0, 5),
              //             blurRadius: 6,
              //             color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.06),
              //           ),
              //         ],
              //       ),
              //       child: Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4),
              //         child: Column(
              //           children: [
              //             Center(
              //               child: Text(
              //                 DateFormat('dd').format(day.date),
              //                 style: const TextStyle(
              //                   fontFamily: 'poppins',
              //                   fontWeight: FontWeight.w500,
              //                 ),
              //               ),
              //             ),
              //             Center(
              //               child: Text(
              //                 DateFormat('EEE').format(day.date).toUpperCase(),
              //                 style: const TextStyle(
              //                   fontFamily: 'poppins',
              //                   fontWeight: FontWeight.w500,
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              Expanded(
                flex: 3,
                child:
                day.isWeekend ?
                 Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Color(0xffFCFBF1)
                  ),
                   child: Center(
                     child: Text(
                        'Sunday',
                      style: dayStyle,
                                     ),
                   ),
                 )
                : Center(
                  child: Text(
                      'Absent',
                    style: dayStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ],
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('My Leaves'),
        centerTitle: true,
        titleTextStyle: const TextStyle(fontFamily: 'poppins'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.sizeOf(context).width,
              height: 40,
              decoration: BoxDecoration(
                color: white,
                border: Border.all(width: .5, color: grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _goToPreviousMonth,
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  InkWell(
                    onTap: _selectDate,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 22),
                        Text(
                          displayDate,
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'poppins',
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _goToNextMonth,
                    icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : absentDays.isEmpty
                      ? const Center(child: Text('No absent days found'))
                      : SingleChildScrollView(
                          child: _buildAbsentDaysTable(absentDays),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class AbsentDay {
  final DateTime date;
  final bool isWeekend;

  AbsentDay({
    required this.date,
    required this.isWeekend,
  });
}
