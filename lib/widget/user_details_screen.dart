import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sheraccerp/app_settings_page.dart';
import 'package:sheraccerp/models/company_user.dart';
import 'package:sheraccerp/models/form_model.dart';
import 'package:sheraccerp/models/ledger_name_model.dart';
import 'package:sheraccerp/models/user_settings_model.dart';
import 'package:sheraccerp/service/api.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/loading.dart';

class UserDetailsScreen extends StatefulWidget {
  final CompanyUser user;

  const UserDetailsScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> with TickerProviderStateMixin {
   DioService api = DioService();
  late CompanyUser userData;
  late String role;
  bool changes = false;
  bool defaultChanges = false;
  List<FormModel> form = [];
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isSearching = false;
  String? _selectedCustomer;
  String? _selectedCustomerName;
  bool _showCustomerSearch = false;
  List<Map<String, dynamic>> _customerSearchResults = [];
  TextEditingController _customerSearchController = TextEditingController();

  List<String> roles = [
    'Staff',
    'SalesMan',
    'Delivery',
    'Collection',
    'Admin',
    'Manager',
    'Owner',
    'Pos'
  ];

  String? _selectedSalesman;
  String? _selectedLocation;
  String? _selectedCashAccount;
  String? _selectedArea;
  String? _selectedGroup;
  String? _selectedRoute;
  bool _salesmanSelection = false;
  
  bool newControl = false;
  bool userSettings = false;

 late AnimationController _controller;
 late Animation<double> _fadeAnimation;
 late Animation<Offset> _slideAnimation;

UserSettingsModel? settingsModel;

@override
void initState() {
  super.initState();
  userData = widget.user;
  role = userData.userType;
  getUserSettings(userData.userId).then((value) {
    if(value != null && value.isNotEmpty){
      setState(() {
        _selectedSalesman = value[0].salesmanId != 0 ? value[0].salesmanId.toString() : null;
        _selectedLocation = value[0].branchId != 0 ? value[0].branchId.toString() : null;
        _selectedCashAccount = value[0].cashId != 0 ? value[0].cashId.toString() : null;
        _selectedArea = value[0].areaId != 0 ? value[0].areaId.toString() : null;
        _selectedGroup = value[0].groupId != 0 ? value[0].groupId.toString() : null;
        _selectedRoute = value[0].routeId != 0 ? value[0].routeId.toString() : null;
        _salesmanSelection = value[0].salesmanSelection == 1;
        _selectedCustomer = value[0].employeeId != 0 ? value[0].employeeId.toString() : null;
        userSettings = true;
      });
       if (_selectedCustomer != null) {
        _fetchCustomerName(int.parse(_selectedCustomer!));
      }
    }
  });

  if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
  bool isValue = locationList.any((element) => element.key.toString() == _selectedLocation);
  if (!isValue) {
    _selectedLocation = null;
  }
}

  _nameController.text = userData.username.toString();
  _passwordController.text = userData.password.toString();
  
  _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );
  
  _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeIn),
  );
  
  _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  
  _controller.forward();
}

Future<void> _fetchCustomerName(int customerId) async {
  try {
    List<LedgerModel> results = await api.getLedgerById(customerId);
    
    for (var ledger in results) {
      if (ledger.id == customerId) {
        setState(() {
          _selectedCustomerName = ledger.name;
        });
        break;
      }
    }
  } catch (e) {
    print('Error fetching customer name: $e');
  }
}


@override
void dispose() {
  _controller.dispose();
  _nameController.dispose();
  _passwordController.dispose();
  _customerSearchController.dispose();
  super.dispose();
}

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: bagroundColor,
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_left, color: kPrimaryColor),
          ),
          onPressed: () {
            Navigator.pop(context, changes ? userData : null);
          },
        ),
        title: const Text(
          'User Details',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _saveUserData,
            ),
          ),
        ],
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          userHeader(),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: userOptions(),
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
              )),
              child: userControlSection(),
            ),
          ),
        ],
      ),
    ),
  );
}

  void _saveUserData() {
    List<FormModel> forms = form.where((element) => element.isChecked == true).toList();
    var part = json.encode(forms);
    var data = {'id': userData.userId, 'data': part};
    
    addUserControl(data).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Saved successfully!' : 'Data Error'),
          backgroundColor: value ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });

    var body = [
      {
        'id': userData.registrationId.toString(),
        'userId': userData.userId.toString(),
        'type': userData.userType,
        'insert': userData.insertData ? 1 : 0,
        'update': userData.updateData ? 1 : 0,
        'delete': userData.deleteData ? 1 : 0
      }
    ];
    
    if (changes) {
      editCompanyUser(body).then((value) {
        if (value) {
         if(!defaultChanges){
          Navigator.pop(context, userData);
         }
        }
      });
    }
     if(defaultChanges){
          settingsModel = UserSettingsModel(
              userId: int.tryParse(userData.userId)! , 
              salesmanId: int.tryParse(_selectedSalesman ?? '0')!, 
              branchId: int.tryParse(_selectedLocation ?? '0')!, 
              cashId: int.tryParse(_selectedCashAccount ?? '0')!, 
              areaId: int.tryParse(_selectedArea ?? '0')!, 
              groupId: int.tryParse(_selectedGroup ?? '0')!, 
              routeId: int.tryParse(_selectedRoute ?? '0')!,
              salesmanSelection: _salesmanSelection ? 1 : 0,
              employeeId: int.tryParse(_selectedCustomer ?? '0'),);
            // var data = [
            //     {
            //       'salesmanId': _selectedSalesman ?? '0',
            //       'branchId': _selectedLocation ?? '0',
            //       'cashId': _selectedCashAccount ?? '0',
            //       'areaId': _selectedArea ?? '0',
            //       'groupId': _selectedGroup ?? '0',
            //       'routeId': _selectedRoute ?? '0',
            //       'userId': userData.userId.toString(),
            //     }
            //   ];
            if(!userSettings){
              addUserSettings(settingsModel!).then((value) {
                 Navigator.pop(context, userData);
              });
            }else{
              editUserSettings(settingsModel!).then((value) {
                 Navigator.pop(context, userData);
              });
            }
          }
  }

  Future<void> deleteSettingsDialog() async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Remove Default Settings',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const Text(
                  'This action will remove the default settings from the user\'s mobile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); 
                        _confirmDeleteSettings(); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Remove',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  void _confirmDeleteSettings() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        );
      },
    );

    deleteDefaultoptions().then((_) {
      Navigator.pop(context); 
      
      setState(() {
        _selectedSalesman = null;
        _selectedLocation = null;
        _selectedCashAccount = null;
        _selectedArea = null;
        _selectedGroup = null;
        _selectedRoute = null;
        userSettings = false;
        defaultChanges = true; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Default settings removed successfully',
            style: TextStyle(fontFamily: 'poppins'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }).catchError((error) {
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error removing settings: $error',
            style: const TextStyle(fontFamily: 'poppins'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  Future<void> deleteDefaultoptions() async {
    try {
      bool result = await deleteUserSettings(userData.userId);
      if (!result) {
        throw Exception('Failed to delete settings');
      }
    } catch (e) {
      throw Exception('Error deleting settings: $e');
    }
  }

  Widget userHeader() {
    return ClipRect(
      child: Hero(
        key:  ValueKey('user_card_${userData.userId}'),
        tag: 'user_${userData.userId}',
        createRectTween: (begin, end) {
          return MaterialRectCenterArcTween(begin: begin, end: end);
        },
        flightShuttleBuilder: (
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Material(
                type: MaterialType.transparency,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        kPrimaryColor,
                        kPrimaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 200),
                        tween: Tween(begin: 0.8, end: 1.0),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 300),
                              tween: Tween(begin: 0.8, end: 1.0),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  alignment: Alignment.centerLeft,
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                userData.username.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 400),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 10 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 4,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.tag,
                                        size: 12,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ID: ${userData.userId}',
                                        style: TextStyle(
                                          fontFamily: 'poppins',
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 12,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateUtil.dateDMY(userData.atDate),
                                        style: TextStyle(
                                          fontFamily: 'poppins',
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData.username.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.tag,
                              size: 12,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ID: ${userData.userId}',
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 12,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateUtil.dateDMY(userData.atDate),
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
    
  Widget userInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Information',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          infoRow(
            icon: Icons.calendar_month_outlined,
            label: 'Date',
            value: DateUtil.dateDMY(userData.atDate),
          ),
          // const Padding(
          //   padding: EdgeInsets.symmetric(vertical: 8),
          //   child: Divider(height: 1),
          // ),
          // infoRow(
          //   icon: Iconsax.clock,
          //   label: 'Last Login',
          //   value: DateUtil.dateTimeDMY(userData.loginDate),
          // ),
        ],
      ),
    );
  }

  Widget infoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kPrimaryColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget userOptions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Role & Permissions',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(kPrimaryColor),
                ),
                onPressed: () => showEditDialog(context, userData),
                icon: const Icon(Icons.key, size: 16, color: white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                items: roles.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(
                      items,
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
                value: role,
                onChanged: (value) {
                  setState(() {
                    role = value!;
                    userData.userType = role;
                    changes = true;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              permissionChip(
                label: 'Save',
                value: userData.insertData,
                onChanged: (value) {
                  setState(() {
                    userData.insertData = value;
                    changes = true;
                  });
                },
              ),
              permissionChip(
                label: 'Edit',
                value: userData.updateData,
                onChanged: (value) {
                  setState(() {
                    userData.updateData = value;
                    changes = true;
                  });
                },
              ),
              permissionChip(
                label: 'Delete',
                value: userData.deleteData,
                onChanged: (value) {
                  setState(() {
                    userData.deleteData = value;
                    changes = true;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          defaultSettings(),
        ],
      ),
    );
  }
  
  Widget defaultSettings() {
  
  int availableCount = 0;
  if (salesmanList.isNotEmpty) availableCount++;
  if (locationList.isNotEmpty) availableCount++;
  if (cashAccount.isNotEmpty) availableCount++;
  if (areaList.isNotEmpty) availableCount++;
  if (groupList.isNotEmpty) availableCount++;
  if (routeList.isNotEmpty) availableCount++;

  availableCount++;

  if (availableCount == 0) {
    return const SizedBox.shrink();
  }
  
  final uniqueLocations = locationList.fold<Map<String, AppSettingsMap>>({}, (map, item) {
    if (item.value?.isNotEmpty == true) {
      map[item.key.toString()] = item;
    }
    return map;
  }).values.toList();
  final emptyLocation = AppSettingsMap(key: 0, value: 'None');
  final locationItems = [emptyLocation, ...uniqueLocations];

  final uniqueCashAccounts = cashAccount.fold<Map<String, AppSettingsMap>>({}, (map, item) {
    if (item.value?.isNotEmpty == true) {
      map[item.key.toString()] = item;
    }
    return map;
  }).values.toList();
  final emptyCashAccount = AppSettingsMap(key: 0, value: 'None');
  final cashAccountItems = [emptyCashAccount, ...uniqueCashAccounts];

  final uniqueAreas = areaList.fold<Map<String, AppSettingsMap>>({}, (map, item) {
    if (item.value?.isNotEmpty == true) {
      map[item.key.toString()] = item;
    }
    return map;
  }).values.toList();
  final emptyArea = AppSettingsMap(key: 0, value: 'None');
  final areaItems = [emptyArea, ...uniqueAreas];

  final uniqueGroups = groupList.fold<Map<String, AppSettingsMap>>({}, (map, item) {
    if (item.value?.isNotEmpty == true) {
      map[item.key.toString()] = item;
    }
    return map;
  }).values.toList();
  final emptyGroup = AppSettingsMap(key: 0, value: 'None');
  final groupItems = [emptyGroup, ...uniqueGroups];

  final uniqueRoutes = routeList.fold<Map<String, AppSettingsMap>>({}, (map, item) {
    if (item.value?.isNotEmpty == true) {
      map[item.key.toString()] = item;
    }
    return map;
  }).values.toList();
  final emptyRoute = AppSettingsMap(key: 0, value: 'None');
  final routeItems = [emptyRoute, ...uniqueRoutes];

  return ExpansionTile(
    title: const Text(
      'Default Settings',
      style: TextStyle(
        fontFamily: 'poppins',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
    subtitle: Text(
      '$availableCount default settings available',
      style: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 11,
        color: Colors.grey,
      ),
    ),
    tilePadding: EdgeInsets.zero,
    childrenPadding: const EdgeInsets.only(top: 12),
    backgroundColor: Colors.transparent,
    collapsedBackgroundColor: Colors.transparent,
    shape: const Border(),
    collapsedShape: const Border(),
    iconColor: kPrimaryColor,
    collapsedIconColor: kPrimaryColor,
    children: [
      if (salesmanList.isNotEmpty)
        dropdownField(
          label: 'Default Salesman',
          icon: Icons.person_2,
          selectedValue: _selectedSalesman,
          items: salesmanList.map((item) {
            return DropdownMenuItem(
              value: item.key.toString(),
              child: Text(
                item.value ?? 'Select Salesman',
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSalesman = value;
              defaultChanges = true;
            });
          },
          isValidValue: _selectedSalesman != null && 
                      salesmanList.any((item) => item.key.toString() == _selectedSalesman),
        ),
      if (locationList.isNotEmpty)
        dropdownField(
          label: 'Default Location',
          icon: Icons.location_city,
          selectedValue: _selectedLocation,
          items: locationItems.map((item) {
            return DropdownMenuItem(
              value: item.key.toString(),
              child: Text(
                item.value ?? 'None',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: item.key == 0 ? Colors.grey : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLocation = value;
              defaultChanges = true;
            });
          },
          isValidValue: _selectedLocation != null && 
                      locationItems.any((item) => item.key.toString() == _selectedLocation),
        ),
      if (cashAccount.isNotEmpty)
        dropdownField(
          label: 'Default Cash Account',
          icon: Icons.money,
          selectedValue: _selectedCashAccount,
          items: cashAccountItems.map((item) {
            return DropdownMenuItem(
              value: item.key.toString(),
              child: Text(
                item.value ?? 'None',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: item.key == 0 ? Colors.grey : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCashAccount = value;
              defaultChanges = true;
            });
          },
          isValidValue: _selectedCashAccount != null && 
                      cashAccountItems.any((item) => item.key.toString() == _selectedCashAccount),
        ),
      if (areaList.isNotEmpty)
        dropdownField(
          label: 'Default Area',
          icon: Icons.map,
          selectedValue: _selectedArea,
          items: areaItems.map((item) {
            return DropdownMenuItem(
              value: item.key.toString(),
              child: Text(
                item.value ?? 'None',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: item.key == 0 ? Colors.grey : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedArea = value;
              defaultChanges = true;
            });
          },
          isValidValue: _selectedArea != null && 
                      areaItems.any((item) => item.key.toString() == _selectedArea),
        ),
      if (groupList.isNotEmpty)
        dropdownField(
          label: 'Default Group',
          icon: Icons.category,
          selectedValue: _selectedGroup,
          items: groupItems.map((item) {
            return DropdownMenuItem(
              value: item.key.toString(),
              child: Text(
                item.value ?? 'None',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: item.key == 0 ? Colors.grey : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGroup = value;
              defaultChanges = true;
            });
          },
          isValidValue: _selectedGroup != null && 
                      groupItems.any((item) => item.key.toString() == _selectedGroup),
        ),
      if (routeList.isNotEmpty)
        dropdownField(
          label: 'Default Route',
          icon: Icons.route,
          selectedValue: _selectedRoute,
          items: routeItems.map((item) {
            return DropdownMenuItem(
              value: item.key.toString(),
              child: Text(
                item.value ?? 'None',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: item.key == 0 ? Colors.grey : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRoute = value;
              defaultChanges = true;
            });
          },
          isValidValue: _selectedRoute != null && 
                      routeItems.any((item) => item.key.toString() == _selectedRoute),
        ),
        if (true) 
  Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person, size: 16, color: kPrimaryColor),
            const SizedBox(width: 8),
            const Text(
              'Default Employee',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => showCustomerSearchDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _selectedCustomerName != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCustomerName!,
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'ID: $_selectedCustomer',
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Select Employee',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                ),
                Icon(
                  Icons.search,
                  color: kPrimaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_selectedCustomer != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCustomer = null;
                      _selectedCustomerName = null;
                      defaultChanges = true;
                    });
                  },
                  icon: const Icon(Icons.close_sharp, size: 14, color: Colors.red),
                  label: const Text(
                    'Clear Selection',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 11,
                      color: Colors.red,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  ),
      salesmanSelectionToggle(), 
      if (userSettings) 
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Center(
            child: TextButton.icon(
              onPressed: () => deleteSettingsDialog(),
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              label: const Text(
                'Remove Default Settings',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
  Widget dropdownField({
    required String label,
    required IconData icon,
    required String? selectedValue,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    bool isValidValue = true, 
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: kPrimaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(
                  'Select $label',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                value: isValidValue ? selectedValue : null,
                items: items,
                onChanged: onChanged,
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: Colors.black87,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (selectedValue != null && !isValidValue)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Text(
                'Previous selection no longer available',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 10,
                  color: Colors.orange[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget salesmanSelectionToggle() {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_2_rounded,
            size: 20,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Salesman Selection',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Allow salesman selection in sales list',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: _salesmanSelection,
          onChanged: (value) {
            setState(() {
              _salesmanSelection = value;
              defaultChanges = true;
            });
          },
          activeColor: kPrimaryColor,
          activeTrackColor: kPrimaryColor.withOpacity(0.3),
          inactiveThumbColor: Colors.grey.shade400,
          inactiveTrackColor: Colors.grey.shade200,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    ),
  );
}

  Widget permissionChip({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: value ? kPrimaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value ? kPrimaryColor : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 11,
            color: value ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget userControlSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Controls',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          form.isEmpty
              ? userControlWidget(userData.userId)
              : controlList(),
        ],
      ),
    );
  }

  Widget controlList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: form.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = form[index];
        return CheckboxListTile(
          title: Text(
            item.title!,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          value: item.isChecked,
          onChanged: (bool? val) {
            setState(() => item.isChecked = val);
          },
          activeColor: kPrimaryColor,
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  showEditDialog(BuildContext context, CompanyUser user) async {
    TextEditingController _textFieldController = TextEditingController();
    TextEditingController _textFieldController1 = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _textFieldController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _textFieldController1,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm password",
                    prefixIcon: const Icon(Icons.lock_clock_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                        style: TextStyle(
                          color: black,
                          fontFamily: 'poppins'
                        )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_textFieldController.text == _textFieldController1.text &&
                              _textFieldController.text.isNotEmpty &&
                              _textFieldController1.text.isNotEmpty) {
                            var body = [
                              {
                                'id': user.registrationId.toString(),
                                'userId': user.userId.toString(),
                                'password': _textFieldController.text,
                              }
                            ];
                            changeCompanyUserPassword(body).then((value) {
                              String msg = "Error password update";
                              if (value) {
                                msg = "Password updated";
                                Navigator.pop(context);
                              }
                              Fluttertoast.showToast(msg: msg);
                            });
                          } else {
                            String msg = "Enter password";
                            if (_textFieldController.text
                                    .compareTo(_textFieldController1.text) !=
                                0) {
                              msg = "Password not match";
                            }
                            Fluttertoast.showToast(msg: msg);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text('Submit',
                        style: TextStyle(
                          color: white,
                          fontFamily: 'poppins'
                        ),),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  userControlWidget(id) {
    return FutureBuilder<List<FormModel>>(
      future: newControl
          ? getCompanyUserControlForms()
          : getCompanyUserControlList(id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            form = snapshot.data!;
            return controlList();
          } else {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    newControl = true;
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Controls'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            );
          }
        } else {
          return const Loading();
        }
      },
    );
  }

 Future<void> showCustomerSearchDialog(BuildContext context) async {
  _customerSearchController.clear();
  _customerSearchResults = [];
  
  final selectedCustomer = await showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.search,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Search Employee',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search Field
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _customerSearchController,
                        decoration: InputDecoration(
                          hintText: 'Type employee name...',
                          hintStyle: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                          suffixIcon: _customerSearchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      _customerSearchController.clear();
                                      _customerSearchResults = [];
                                      _isSearching = false;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey.shade400,
                                    size: 18,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setDialogState(() {});
                          if (value.length >= 2) {
                            _searchCustomersInDialog(value, setDialogState);
                          } else {
                            setDialogState(() {
                              _customerSearchResults = [];
                              _isSearching = false;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  
                  // Results count or loading indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        if (_isSearching)
                          Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Searching...',
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          )
                        else if (_customerSearchResults.isNotEmpty)
                          Text(
                            '${_customerSearchResults.length} results found',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Results List
                  Expanded(
                    child: _customerSearchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _customerSearchController.text.isEmpty
                                      ? 'Start typing to search employees'
                                      : _isSearching 
                                          ? 'Searching...' 
                                          : 'No employees found',
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _customerSearchResults.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final customer = _customerSearchResults[index];
                              return _buildCustomerTileInDialog(
                                customer['Ledcode'].toString(),
                                customer['LedName'].toString(),
                                onSelect: () {
                                  // Return the selected value to parent
                                  Navigator.pop(context, {
                                    'id': customer['Ledcode'].toString(),
                                    'name': customer['LedName'].toString(),
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
  if (selectedCustomer != null) {
    setState(() {
      _selectedCustomer = selectedCustomer['id'];
      _selectedCustomerName = selectedCustomer['name'];
      defaultChanges = true;
    });
    
    print('Selected: $_selectedCustomerName (ID: $_selectedCustomer)');
  }
}

Widget _buildCustomerTileInDialog(String code, String name, {required VoidCallback onSelect}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                color: kPrimaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: $code',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_right,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


Future<void> _searchCustomersInDialog(String query, Function(void Function()) setDialogState) async {
  // if (query.length < 2) {
  //   setDialogState(() {
  //     _customerSearchResults = [];
  //     _isSearching = false;
  //   });
  //   return;
  // }

  setDialogState(() {
    _isSearching = true;
  });

  try {
    String groupId = '0'; //_selectedGroup ?? '0';
    String areaId = '0';//_selectedArea ?? '0';
    String routeId = '0';//_selectedRoute ?? '0';
    String salesmanId ='0'; //_selectedSalesman ?? '0';
    
    List<LedgerModel> results = await api.getCustomerNameListLike(
      int.tryParse(groupId)!, 
      int.tryParse(areaId)!,
      int.tryParse(routeId)!,
      int.tryParse(salesmanId)!,
      query,
    );
    
    List<Map<String, dynamic>> customers = [];
    
    for (var ledger in results) {
      customers.add({
        'Ledcode': ledger.id, 
        'LedName': ledger.name,
      });
    }
    
    setDialogState(() {
      _customerSearchResults = customers;
      _isSearching = false;
    });
    
  } catch (e) {
    print('Error searching: $e');
    setDialogState(() {
      _customerSearchResults = [];
      _isSearching = false;
    });
  }
}

}