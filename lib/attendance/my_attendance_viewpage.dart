import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheraccerp/attendance/model/attendance_day_model.dart';
import 'package:sheraccerp/attendance/model/punch_in_model.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/util/res_color.dart';

class MyAttendanceView extends StatefulWidget {
  final dynamic salesmanInfo;
  const MyAttendanceView({
    Key? key,
    required this.salesmanInfo,
  });

  @override
  State<MyAttendanceView> createState() => _MyAttendanceViewState();
}

class _MyAttendanceViewState extends State<MyAttendanceView> {
  String? formattedDate; 
  DateTime currentDate = DateTime.now();
  DioService api = DioService();
  List<AttendanceDay> attendanceDays = [];
  bool isLoading = false;

  String get displayDate {
    return DateFormat('MMMM-yyyy').format(currentDate);
  }

  String get displayMonth {
    return DateFormat('MMMM yyyy').format(currentDate).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('dd-MM-yyyy').format(currentDate);
    _loadAttendanceData();
  }

  void _goToPreviousMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month - 1, 1);
      formattedDate = DateFormat('dd-MM-yyyy').format(currentDate);
    });
    _loadAttendanceData(); // Reload data for new month
  }

  void _goToNextMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
      formattedDate = DateFormat('dd-MM-yyyy').format(currentDate);
    });
    _loadAttendanceData(); 
  }

  Future _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        currentDate = picked;
        formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      });
      _loadAttendanceData(); 
    }
  }

  Future<void> _loadAttendanceData() async {
    setState(() => isLoading = true);
    
    try {
      DateTime date;
      try {
        date = DateFormat('dd-MM-yyyy').parse(formattedDate!);
      } catch (e) {
        debugPrint('Error parsing date: $e');
        return;
      }

      final punchRecords = await api.getAttendanceReportBySalesman(
        widget.salesmanInfo.key, 
        date
      );
      
      if (mounted) {
        setState(() {
          attendanceDays = _processAttendanceData(punchRecords ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error loading attendance data: $e');
      if (mounted) {
        setState(() {
          attendanceDays = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<AttendanceDay> _processAttendanceData(List<PunchInModel> punchRecords) {
    final List<AttendanceDay> attendanceDays = [];
    
    final Map<String, List<PunchInModel>> recordsByDate = {};
    for (final record in punchRecords) {
      try {
        final date = DateFormat('yyyy-MM-dd').format(DateTime.parse(record.pncDate));
        recordsByDate.putIfAbsent(date, () => []).add(record);
      } catch (e) {
        debugPrint('Error parsing date ${record.pncDate}: $e');
        continue;
      }
    }

    for (final entry in recordsByDate.entries) {
      try {
        final date = DateTime.parse(entry.key);
        final dayName = DateFormat('EEE').format(date).toUpperCase();
        final dateDisplay = '${date.day}';
        final dayDisplay = ' $dayName';
        
        entry.value.sort((a, b) => a.punchTime.compareTo(b.punchTime));
        
        final inRecords = entry.value.where((r) => r.punchType == 'IN').toList();
        final outRecords = entry.value.where((r) => r.punchType == 'OUT').toList();
        
        String clockIn = 'N/A';
        String clockOut = 'N/A';
        String workingHours = 'N/A';
        
        if (inRecords.isNotEmpty) {
          final clockInTime = DateTime.parse(inRecords.first.punchTime);
          clockIn = DateFormat('hh:mm a').format(clockInTime);
          
          if (outRecords.isNotEmpty) {
            final clockOutTime = DateTime.parse(outRecords.last.punchTime);
            clockOut = DateFormat('hh:mm a').format(clockOutTime);
            
            final workDue = outRecords.last.workDur;
            // final duration = clockOutTime.difference(clockInTime);
            workingHours =  workDue ?? ''; //'${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';
          }
        }
        
        attendanceDays.add(AttendanceDay(
          date: dateDisplay,
          day: dayDisplay,
          clockIn: clockIn,
          clockOut: clockOut,
          workingHours: workingHours,
        ));
      } catch (e) {
        debugPrint('Error processing attendance record: $e');
        continue;
      }
    }
    
    attendanceDays.sort((a, b) {
      final aDay = int.parse(a.date.split(' ')[0]);
      final bDay = int.parse(b.date.split(' ')[0]);
      return aDay.compareTo(bDay);
    });
    
    return attendanceDays;
  }

  Widget _buildAttendanceTable(List<AttendanceDay> attendanceDays) {
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
                // flex: 2,
                child: Text(
                  // displayMonth, 
                  'Date',
                  style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
              Expanded(child: Text('Clock In', style: TextStyle(fontSize: 13,
                    fontFamily: 'poppins',fontWeight: FontWeight.w500))),
              Expanded(child: Text('Clock Out', style: TextStyle(fontSize: 13,
                    fontFamily: 'poppins',fontWeight: FontWeight.w500))),
              Expanded(child: Text('Working Hr\'s', style: TextStyle(fontSize: 13,
                    fontFamily: 'poppins',fontWeight: FontWeight.w500))),
            ],
          ),
        ),
        ...attendanceDays.map((day) => Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
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
                              Center(child: Text(day.date,
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500
                              ),
                              )),
                              Center(child: Text(day.day,
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
              Expanded(child: Text(day.clockIn,
              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                color: green
                              ),)),
              Expanded(child: Text(day.clockOut,
              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500
                              ),)),
              Expanded(child: Text(day.workingHours,
              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                color: red
                              ),)),
            ],
          ),
        )).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('My Attendance'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'poppins'
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.sizeOf(context).width,
              height: 40,
              decoration: BoxDecoration(
                color: white,
                border: Border.all(
                  width: .5,
                  color: grey
                ),
                borderRadius: BorderRadius.circular(4)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _goToPreviousMonth,
                    icon: const Icon(Icons.arrow_back_ios,
                    size: 20,)
                  ),
                  InkWell(
                    onTap: _selectDate,
                    child: SizedBox(
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 22),
                          Text(
                            displayDate, 
                            style: const TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'poppins',
                              fontSize: 15
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _goToNextMonth,
                    icon: const Icon(Icons.arrow_forward_ios,
                    size: 20,)
                  )
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : attendanceDays.isEmpty
                      ? Center(child: Text('No attendance records found'))
                      : SingleChildScrollView(
                          child: _buildAttendanceTable(attendanceDays),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}