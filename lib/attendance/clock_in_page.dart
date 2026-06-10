import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/attendance/attendance_home.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/progress_hud.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shimmer/shimmer.dart';

class ClockInScreen extends StatefulWidget {
  final dynamic salesmanInfo;
  final double comLat;
  final double comLong;
  final bool isPunchIn;

  const ClockInScreen({
    Key? key,
    required this.salesmanInfo,
    required this.comLat,
    required this.comLong, 
    required this.isPunchIn,
  }) : super(key: key);

  @override
  _ClockInScreenState createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  StreamSubscription<ServiceStatus>? _serviceStatusStream;
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<List<ConnectivityResult>>? _connectivityStream;

  CompanyInformation? companySettings;
  DioService api = DioService();
  List<CompanySettings>? settings;
  Position? _currentPosition;
  bool _isLoading = false;
  bool isSaving = false;
  bool _locationServiceEnabled = false;
  bool _hasError = false;
  bool _isWithinRadius = false;
  bool _hasNetwork = true;

  String _statusMessage = 'Tap refresh to check location';
  double _currentDistance = 0.0;
  String comRa = '';
  double companyRadius = 0.0;
  int lId = 0;

  @override
  void initState() {
    super.initState();
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();
    lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    comRa = ComSettings.getValue('COMPANY LOCATION DISTANCE', settings!);
    if (comRa.isNotEmpty) {
      companyRadius = double.tryParse(comRa) ?? 0.0;
    }
    _initNetworkListener();
    _initLocationServiceListener();
    _startListeningPosition();
  }

  void _initNetworkListener() {
    _connectivityStream = Connectivity().onConnectivityChanged.listen((result) {
      final hasInternet = result != ConnectivityResult.none;
      if (hasInternet != _hasNetwork) {
        setState(() {
          _hasNetwork = hasInternet;
        });
        if (hasInternet) {
          _checkLocation();
        }
      }
    });

    // Initial check
    Connectivity().checkConnectivity().then((result) {
      final hasInternet = result != ConnectivityResult.none;
      setState(() {
        _hasNetwork = hasInternet;
      });
    });
  }

  void _initLocationServiceListener() async {
    _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    _serviceStatusStream = Geolocator.getServiceStatusStream().listen((status) async {
      final newStatus = status == ServiceStatus.enabled;
      if (newStatus != _locationServiceEnabled) {
        setState(() {
          _locationServiceEnabled = newStatus;
        });
        if (newStatus) {
          await _checkLocation();
          _startListeningPosition();
        } else {
          _positionStream?.cancel();
        }
      }
    });
  }

  void _startListeningPosition() {
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      _processPosition(position);
    });
  }

  void _processPosition(Position position) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      widget.comLat,
      widget.comLong,
    );
    final isCurrentlyWithinRadius = distance <= companyRadius;
    setState(() {
      _currentPosition = position;
      _currentDistance = distance;
      _isWithinRadius = isCurrentlyWithinRadius;
      _statusMessage = isCurrentlyWithinRadius
          ? 'Location Verified'
          : 'Outside company radius (${distance.toStringAsFixed(1)}m)';
      _isLoading = false;
    });
    if (isCurrentlyWithinRadius) {
      _showSuccessToast();
    } else {
      _showWarningToast();
    }
  }

  Future<void> _checkLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _statusMessage = 'Getting current location...';
      });

      _locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_locationServiceEnabled) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Location services disabled';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          setState(() {
            _isLoading = false;
            _statusMessage = 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Location permission permanently denied';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      await Future.delayed(const Duration(seconds: 1));
      _processPosition(position);

    } catch (e) {
      debugPrint("Location error: $e");
      setState(() {
        _hasError = true;
        _isLoading = false;
        _statusMessage = 'Failed to get location: ${e.toString()}';
      });
    }
  }

  void _showSuccessToast() {
    MotionToast.success(
      title: const Text("Location Verified"),
      description: Text("You're within the company radius (${_currentDistance.toStringAsFixed(1)}m)"),
      animationType: AnimationType.slideInFromTop,
      position: MotionToastPosition.top,
      width: 300,
    ).show(context);
  }

  void _showWarningToast() {
    MotionToast.warning(
      title: const Text("Out of Range"),
      description: Text("You're outside the company radius (${_currentDistance.toStringAsFixed(1)}m)"),
      animationType: AnimationType.slideInFromTop,
      position: MotionToastPosition.top,
      width: 300,
    ).show(context);
  }

  Widget _buildMap() {
    try {
      MapLatLng initialFocus = _currentPosition != null
          ? MapLatLng(_currentPosition!.latitude, _currentPosition!.longitude)
          : MapLatLng(widget.comLat, widget.comLong);

      return SfMaps(
        layers: [
          MapTileLayer(
            key: ValueKey(_currentPosition?.toString() ?? 'none'),
            initialFocalLatLng: initialFocus,
            initialZoomLevel: 17,
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            initialMarkersCount: _currentPosition != null ? 2 : 1,
            markerBuilder: (BuildContext context, int index) {
              if (index == 0 && _currentPosition != null) {
                return MapMarker(
                  latitude: 
                  _currentPosition!.latitude,
                  longitude: _currentPosition!.longitude,
                  child: Icon(
                    Icons.person_pin_circle,
                    color: _isWithinRadius ? Colors.green : Colors.red,
                    size: 32,
                  ),
                );
              } else {
                return MapMarker(
                  latitude: widget.comLat,
                  longitude: widget.comLong,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 28,
                  ),
                );
              }
            },
            sublayers: [
              MapCircleLayer(
                circles: {
                  MapCircle(
                    center: MapLatLng(widget.comLat, widget.comLong),
                    radius: companyRadius,
                    color: Colors.blue.withOpacity(0.2),
                    strokeColor: Colors.blue,
                    strokeWidth: 2,
                  ),
                },
              ),
            ],
          ),
        ],
      );
    } catch (e) {
      debugPrint("Map rendering error: $e");
      return _buildMapErrorWidget();
    }
  }

  Widget _buildMapErrorWidget() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text("Map loading failed"),
        ],
      ),
    );
  }

  Widget _buildLocationStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _isWithinRadius ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isWithinRadius ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isWithinRadius ? Icons.check_circle : Icons.warning,
            color: _isWithinRadius ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _isWithinRadius ? Colors.green.shade700 : Colors.orange.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'poppins',
              ),
            ),
          ),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 20),
            color: Colors.blue,
            onPressed: _isLoading ? null : _checkLocation,
            tooltip: 'Check location',
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const Icon(
                  Icons.cloud_off,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const Text(
                  'Waiting for network connection...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black26,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const Icon(
                  Icons.location_searching,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const Text(
                  'Fetching your location...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serviceStatusStream?.cancel();
    _positionStream?.cancel();
    _connectivityStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('EEE, dd MMM yyyy').format(DateTime.now());
    final currentTime = DateFormat('hh:mm a').format(DateTime.now());

    return  SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.only(top: 20, right: 16),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.salesmanInfo.value ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'poppins',
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentDate,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: black,
                    ),
                  ),
                ],
              ),
              iconTheme: IconThemeData(color: black),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: black),
                  onPressed: _hasNetwork ? _checkLocation : null,
                  tooltip: 'Check location',
                ),
                const Icon(
                  Icons.notifications_none,
                  size: 28,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
        body: ProgressHUD(
          inAsyncCall: isSaving || !_hasNetwork, opacity: 0.0,
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(child: _buildMap()),
                  const SizedBox(height: 16),
                  _buildLocationStatus(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 140,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isWithinRadius ? kPrimaryColor : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isWithinRadius && _hasNetwork && !isSaving
              ? () async {
                 if(!widget.isPunchIn){
           setState(() {
            isSaving = true;
          });
          
          try {
            final dataMap = {
              'employee': widget.salesmanInfo.key,
              'date': DateTime.now(),
              'Time': DateTime.now(),
              'ptype': "IN",
              'narration': '',
              'otamount': 0.0,
              'Allowances': 0.0,
              'EmpSection': '',
              'location': lId,
              'type': 'P',
              'Attendance': 1,
              'Wage': 0,
              'oth': 0,
              'fyId': currentFinancialYear!.id,
            };
          
            // Make the API callcall
            final success = await api.savePunchingEntry(dataMap);
          
            // Handle the response
            if (success) {
              // Show success message
              MotionToast.success(
                title: const Text("Success"),
                description: const Text("Clock-in recorded successfully"),
                animationType: AnimationType.slideInFromTop,
                position: MotionToastPosition.top,
                width: 300,
              ).show(context);
          
              // Navigate after a short delay to let user see the success message
              await Future.delayed(const Duration(seconds: 1));
              
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AttendanceHome()),
                  (route) => false,
                );
              }
            } else {
              // Show error message if API call failed
              MotionToast.error(
                title: const Text("Error"),
                description: const Text("Failed to record clock-in"),
                animationType: AnimationType.slideInFromTop,
                position: MotionToastPosition.top,
                width: 300,
              ).show(context);
            }
          } catch (e) {
            // Show error message for exceptions
            MotionToast.error(
              title: const Text("Error"),
              description: Text("An error occurred: ${e.toString()}"),
              animationType: AnimationType.slideInFromTop,
              position: MotionToastPosition.top,
              width: 300,
            ).show(context);
            
            // Log the error for debugging
            debugPrint("Clock-in error: $e");
          } finally {
            // Always reset the loading state
            if (mounted) {
              setState(() {
                isSaving = false;
              });
            }
          }
                 }else{
            setState(() {
            isSaving = true;
          });
           var dataMap = {
                          'employee': widget.salesmanInfo.key,
                          'date': DateTime.now(),
                          'Time': DateTime.now(),
                          'ptype': "OUT",
                        };
                         try {
                  bool success = await api.punchOutEntry(dataMap);
                  
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      isSaving = false;
                      // isSaving = false;
                    });
                    
                    if (success) {
                      MotionToast.success(
                        title: const Text("Clock Out Successful"),
                        description: const Text("You have successfully clocked Out."),
                        animationType: AnimationType.slideInFromTop,
                        position: MotionToastPosition.top,
                        width: 300,
                      ).show(context);
                      // await Future.delayed(const Duration(seconds: 1));
              
              if (mounted) {
                // Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AttendanceHome()),
                  (route) => false,
                );
              }
                      // Future.delayed(const Duration(seconds: 1), () {
                        // if (mounted) {
                        //   Navigator.popUntil(context, ModalRoute.withName('/AttendanceRegister'));
                          // Navigator.pushNamedAndRemoveUntil(
                          //     context,
                          //     '/AttendanceRegister',
                          //     (Route<dynamic> route) => false,
                          //   );
                          // Navigator.pushReplacementNamed(context, '/AttendanceRegister');
                        // }
                      // });
                    } else {
                      MotionToast.error(
                        title: const Text("Clock Out Failed"),
                        description: const Text("Please try again later."),
                        animationType: AnimationType.slideInFromTop,
                        position: MotionToastPosition.top,
                        width: 300,
                      ).show(context);
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      isSaving = false;
                      //  isSaving = false;
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
              : null,
              //           onPressed: _isWithinRadius  && _hasNetwork
              //               ? () async{
              //                  setState(() {
              //         isSaving = true;
              //       });
              //                  var dataMap = {
              //             'employee': widget.salesmanInfo.key,
              //             'date': DateTime.now(),
              //             'Time': DateTime.now(),
              //             'ptype': "IN",
              //             'narration': '',
              //             'otamount': 0.0,
              //             'Allowances': 0.0,
              //             'EmpSection' : '',
              //             'location': lId,
              //             'type' : 'P',
              //             'Attendance' : 1,
              //             'Wage' : 0,
              //             'oth': 0,
              //             'fyId' : currentFinancialYear!.id
              //           };
              //                try {
              //     bool success = await api.savePunchingEntry(dataMap);
                  
              //     // if (mounted) {
              //       setState(() {
              //         _isLoading = false;
              //         isSaving = false;
              //       });
                    
              //       if (success) {
              //         MotionToast.success(
              //           title: const Text("Clock In Successful"),
              //           description: const Text("You have successfully clocked in."),
              //           animationType: AnimationType.fromTop,
              //           position: MotionToastPosition.top,
              //           width: 300,
              //         ).show(context);
                      
              //         // Navigate to AttendanceHome after a short delay
              //         // Future.delayed(const Duration(seconds: 1), () {
              //           if (mounted) {
              //             Navigator.pushReplacement(
              //               context,
              //               MaterialPageRoute(builder: (context) => AttendanceHome()),
              //             );
              //             // Navigator.popUntil(context, ModalRoute.withName('/AttendanceRegister'));
              //             // Navigator.pushNamedAndRemoveUntil(
              //             //     context,
              //             //     '/AttendanceRegister',
              //             //     (Route<dynamic> route) => false,
              //             //   );
              //             // Navigator.pushReplacementNamed(context, '/AttendanceRegister');
              //           }
              //         // });
              //       } else {
              //         MotionToast.error(
              //           title: const Text("Clock In Failed"),
              //           description: const Text("Please try again later."),
              //           animationType: AnimationType.fromTop,
              //           position: MotionToastPosition.top,
              //           width: 300,
              //         ).show(context);
              //       }
              //     // }
              //   } catch (e) {
              //     // if (mounted) {
              //       setState(() {
              //         _isLoading = false;
              //          isSaving = false;
              //       });
              //       MotionToast.error(
              //         title: const Text("Error"),
              //         description: Text("An error occurred: ${e.toString()}"),
              //         animationType: AnimationType.fromTop,
              //         position: MotionToastPosition.top,
              //         width: 300,
              //       ).show(context);
              //     // }
              //   }
              // }
              //               : null,
                        child: isSaving 
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                               !widget.isPunchIn ? 'Clock In' : 'Clock Out',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'poppins',
                                  color: white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
          
              // if (!_hasNetwork) _buildOfflineOverlay(),
          
              // if (_isLoading && _hasNetwork) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}