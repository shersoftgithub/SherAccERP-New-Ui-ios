import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/attendance/clock_in_page.dart';
import 'package:sheraccerp/attendance/model/first_in_model.dart';
import 'package:sheraccerp/attendance/model/punchtype_model.dart';
import 'package:sheraccerp/attendance/my_attendance_viewpage.dart';
import 'package:sheraccerp/attendance/my_leaves_viewpage.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide Position;

class AttendanceHome extends StatefulWidget {
  const AttendanceHome({super.key});

  @override
  _AttendanceHomeState createState() => _AttendanceHomeState();
}

class _AttendanceHomeState extends State<AttendanceHome> {
  CompanyInformation? companySettings;
  List<CompanySettings>? settings;
  DioService api = DioService();
  int _selectedIndex = 0;
  int salesMan = 0;
  dynamic salesManInfo;
  double? comLat;
  double? comLong;
  bool isPunchIn = false;
  String lastPunchType = '';
  dynamic lastPunchData;
  String? punchingTime;
  String? punchOutTime;
  String firstPunchInTime = '';
  Future<List<PunchTypeModel>>? lastPunchFuture;
  Future<List<FirstInModel>>? getFirstPunchInTime;
  bool _isLoading = false;
  
  // Duration tracking variables
  Duration _totalWorkDuration = Duration.zero;
  Duration _currentSessionDuration = Duration.zero;
  DateTime? _currentPunchInTime;
  Timer? _workingDurationTimer;

  @override
  void initState() {
    super.initState();
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();
    comapnyLatAndLong =
        ComSettings.getValue('COMPANY LATITUDE AND LONGITUDE', settings!);

    salesMan = ComSettings.appSettings(
            'int', 'key-dropdown-default-salesman-view', 1) -
        1;
    
    if (salesMan > 0) {
      for (var i = 0; i < salesmanList.length; i++) {
        if (salesmanList[i].key == salesMan) {
          salesManInfo = salesmanList[i];
          break;
        }
      }
    }

    if (comapnyLatAndLong.isNotEmpty) {
      var latLong = comapnyLatAndLong.split(',');
      if (latLong.length == 2) {
        comLat = double.tryParse(latLong[0]);
        comLong = double.tryParse(latLong[1]);
      }
    }

    lastPunchFuture = _fetchLastPunchData();
    getFirstPunchInTime = _fetchFirstPunchInTime();
  }

 Future<List<PunchTypeModel>> _fetchLastPunchData() async {
  final value = await api.getLastPuchType(salesMan, DateTime.now());
  if (value != null && value.isNotEmpty) {
    if (mounted) {
      setState(() {
        lastPunchType = value[0].punchType!;
        isPunchIn = lastPunchType == 'IN';
        
        // Reset durations
        _totalWorkDuration = Duration.zero;
        _currentSessionDuration = Duration.zero;
        
        for(var data in value) {
          if(data.punchType == 'IN') {
            punchingTime = data.punchTime;
            _currentPunchInTime = DateTime.parse(data.punchTime);
          } else {
            punchOutTime = data.punchTime;
            if (data.workDuration != null && data.workDuration!.isNotEmpty) {
              final parts = data.workDuration!.split(':');
              if (parts.length == 2) {
                _totalWorkDuration = Duration(
                  hours: int.parse(parts[0]),
                  minutes: int.parse(parts[1]),
                );
              }
            }
          }
        }

        if (isPunchIn) {
          _startWorkingDurationTimer();
        }
      });
    }
  }
  return value;    
}

  Future<List<FirstInModel>> _fetchFirstPunchInTime() async {
    final value = await api.getFirstPuchIn(salesMan, DateTime.now());
    
    if (value != null && value.isNotEmpty && value[0].punchTime.isNotEmpty) {
      if (mounted) {
        setState(() {
          firstPunchInTime = value[0].punchTime!;
          if (isPunchIn) {
            final punchInTimeUtc = DateTime.parse(firstPunchInTime);
            final currentTimeUtc = DateTime.now().toUtc();
            _currentSessionDuration = currentTimeUtc.add(const Duration(hours: 5, minutes: 30))
                              .difference(punchInTimeUtc);
          }
        });
      }
    }
    return value ?? [];
  }

  void _startWorkingDurationTimer() {
    _workingDurationTimer?.cancel();
    
    if (isPunchIn && _currentPunchInTime != null) {
      final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
      _currentSessionDuration = now.difference(_currentPunchInTime!);
      
      _workingDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && isPunchIn) {
          setState(() {
            final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
            _currentSessionDuration = now.difference(_currentPunchInTime!);
          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _workingDurationTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AttendanceHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    lastPunchFuture = _fetchLastPunchData();
    getFirstPunchInTime = _fetchFirstPunchInTime();
  }

  Future<bool> _checkLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Location Services Disabled"),
          content: const Text("Please enable location services to use this feature"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings();
                Navigator.pop(context);
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are required")),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Location Permissions Required"),
          content: const Text(
            "Location permissions are permanently denied. Please enable them in app settings",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openAppSettings();
                Navigator.pop(context);
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bagroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 190,
                decoration: const BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  salesManInfo != null
                                      ? salesManInfo.value
                                      : '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: IconButton(
                            icon: Icon(Icons.notifications_none, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.1,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => MyAttendanceView(
                                    salesmanInfo: salesManInfo,
                                  ),
                                  )
                                );
                              },
                              child: _buildMenuCard(
                                'My Attendance',
                                Icons.calendar_today_outlined,
                                const Color(0xFF00C968),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => MyLeavesView(
                                    salesmanInfo: salesManInfo,
                                  ),
                                  )
                                );
                              },
                              child: _buildMenuCard(
                                'My Leaves',
                                Icons.beach_access_outlined,
                                const Color(0xFFFFA940),
                              ),
                            ),
                            _buildMenuCard(
                              'Dashboard',
                              Icons.bar_chart_outlined,
                              const Color(0xFF8C54FF),
                            ),
                            _buildMenuCard(
                              'Movements',
                              Icons.directions_walk_outlined,
                              const Color(0xFF2E5BFF),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          Positioned(
            top: 100, 
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getToDay,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Punch In',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder<List<PunchTypeModel>>(
                                      future: lastPunchFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading...');
                                        }
                                        
                                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                          return const Text('--/--');
                                        }
                                        
                                        String? punchInTime;
                                        String? punchOutTime;
                                        for(var data in snapshot.data!) {
                                          if(data.punchType == 'IN') {
                                            punchInTime = data.punchTime;
                                          } else {
                                            punchOutTime = data.punchTime;
                                          }
                                        }
                                        
                                        return Text(
                                          punchInTime != null && punchInTime.isNotEmpty
                                              ? DateFormat('h:mm a').format(DateTime.parse(punchInTime)) 
                                              : '--/--',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                ),
                                const SizedBox(width: 40),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Punch Out',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder<List<PunchTypeModel>>(
                                      future: lastPunchFuture, 
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading...');
                                        }
                                        
                                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                          return const Text('--/--');
                                        }
                                        
                                        String? punchInTime;
                                        String? punchOutTime;
                                        for(var data in snapshot.data!) {
                                          if(data.punchType == 'IN') {
                                            punchInTime = data.punchTime;
                                          } else {
                                            punchOutTime = data.punchTime;
                                          }
                                        }
                                        
                                        return Text(
                                          punchOutTime != null && punchOutTime.isNotEmpty
                                                ? DateFormat('h:mm a').format(DateTime.parse(punchOutTime)) 
                                                : '--/--',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () async {
                                if (!isPunchIn) {
                                  if (comLat == null || comLong == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Company location not configured")),
                                    );
                                    return;
                                  }

                                  bool hasPermission = await _checkLocationPermissions();
                                  if (hasPermission) {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClockInScreen(
                                          salesmanInfo: salesManInfo,
                                          comLat: comLat!,
                                          comLong: comLong!,
                                          isPunchIn: isPunchIn,
                                        ),
                                      ),
                                    );
                                    
                                    if (result == true) {
                                      setState(() {
                                        lastPunchFuture = _fetchLastPunchData();
                                      });
                                    }
                                  }
                                } else {
                                  bool hasPermission = await _checkLocationPermissions();
                                  if (hasPermission) {
                                    setState(() {
                                      _isLoading = true;
                                      _workingDurationTimer?.cancel();
                                    });
                                    
                                    try {
                                      Position currentPosition = await Geolocator.getCurrentPosition(
                                        desiredAccuracy: LocationAccuracy.best,
                                      );
                                      
                                      // Calculate total duration before API call
                                      final totalDuration = _totalWorkDuration + _currentSessionDuration;
                                      
                                      var dataMap = {
                                        'employee': salesManInfo.key,
                                        'date': DateTime.now(),
                                        'Time': DateTime.now(),
                                        'ptype': "OUT",
                                        'latitude': currentPosition.latitude.toString(),
                                        'longitude': currentPosition.longitude.toString(),
                                        'workDur': '${totalDuration.inHours}:${(totalDuration.inMinutes % 60).toString().padLeft(2, '0')}',
                                      };
                                      
                                      bool success = await api.punchOutEntry(dataMap);
                                      
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                          if (success) {
                                            // Update both durations immediately
                                            _totalWorkDuration = totalDuration;
                                            _currentSessionDuration = Duration.zero;
                                            isPunchIn = false;
                                          }
                                        });
                                        
                                        if (success) {
                                          MotionToast.success(
                                            title: const Text("Clock Out Successful"),
                                            description: const Text("You have successfully clocked Out."),
                                            animationType: AnimationType.slideInFromTop,
                                            position: MotionToastPosition.top,
                                            width: 300,
                                          ).show(context);
                                          
                                          // Refresh data
                                          setState(() {
                                            lastPunchFuture = _fetchLastPunchData().then((value) {
                                              // Ensure UI updates with latest data
                                              if (mounted) setState(() {});
                                              return value;
                                            });
                                          });
                                        }
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        MotionToast.error(
                                          title: const Text("Error"),
                                          description: Text("An error occurred: ${e.toString()}"),
                                          animationType: AnimationType.slideInFromTop,
                                          position: MotionToastPosition.top,
                                          width: 300,
                                        ).show(context);
                                      }
                                    }
                                  }
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: kPrimaryColor, 
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                width: MediaQuery.of(context).size.width - 200,
                                height: 34,
                                child: Center(
                                  child: FutureBuilder<List<PunchTypeModel>>(
                                    future: lastPunchFuture,
                                    builder: (context, snapshot) {
                                      bool showPunchOut = false;
                                      
                                      if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                                        final punchTypeData = snapshot.data![0].punchType ?? '';
                                        showPunchOut = punchTypeData == 'IN';
                                      }
                                      
                                      return _isLoading 
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          showPunchOut ? 'Punch Out' : 'Punch In',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'poppins',
                                            fontWeight: FontWeight.w400,
                                            color: showPunchOut ? Colors.white : Colors.white,
                                          ),
                                        );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: 120,
                          height: 110,
                          child: ValueListenableBuilder<Duration>(
                            valueListenable: ValueNotifier(_currentSessionDuration),
                            builder: (context, sessionDuration, _) {
                              final displayDuration = isPunchIn 
                                                      ? _totalWorkDuration + sessionDuration
                                                      : _totalWorkDuration;
                              
                              return SfCircularChart(
                                margin: EdgeInsets.zero,
                                series: <CircularSeries>[
                                  RadialBarSeries<ChartData, String>(
                                    maximumValue: 8,
                                    radius: '95%',
                                    gap: '30%',
                                    innerRadius: '75%',
                                    dataSource: [
                                      ChartData(
                                        'Hours',
                                        isPunchIn 
                                           ? (_totalWorkDuration.inHours + _currentSessionDuration.inHours + 
               (_totalWorkDuration.inMinutes % 60 + _currentSessionDuration.inMinutes % 60) / 60).clamp(0, 8)
            : (_totalWorkDuration.inHours + (_totalWorkDuration.inMinutes % 60) / 60).clamp(0, 8),
                                        kPrimaryColor,
                                      ),
                                    ],
                                    cornerStyle: CornerStyle.bothCurve,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                    pointColorMapper: (ChartData data, _) => data.color,
                                    trackOpacity: 0.2,
                                    trackColor: const Color.fromARGB(255, 198, 198, 198),
                                    trackBorderWidth: 0,
                                  )
                                ],
                                annotations: <CircularChartAnnotation>[
                                  CircularChartAnnotation(
                                    widget: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                           Text(
                                             firstPunchInTime.isNotEmpty
                                                ? "${DateFormat('h:mm a').format(DateTime.parse(firstPunchInTime))}"
                                                : '',
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        Text(
                                          '${displayDuration.inHours}h ${displayDuration.inMinutes.remainder(60)}m',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor,
                                          ),
                                        ),
                                        Text(
                                          isPunchIn ? 'Working' : 'Worked Today',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            activeIcon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined, size: 24),
            activeIcon: Icon(Icons.calendar_today, size: 24),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined, size: 24),
            activeIcon: Icon(Icons.access_time, size: 24),
            label: 'Leave',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            activeIcon: Icon(Icons.person, size: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  fontFamily: 'poppins'
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}