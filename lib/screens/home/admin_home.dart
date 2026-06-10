import 'dart:ui';

import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheraccerp/app_settings_page.dart';
import 'package:sheraccerp/models/company_user.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/screens/dash_report/dash_page.dart';
import 'package:sheraccerp/screens/inventory/sales/sale.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/service/com_service.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dbhelper.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/accounts_menu.dart';
import 'package:sheraccerp/widget/accounts_report_menu.dart';
import 'package:sheraccerp/widget/dash_board.dart';
import 'package:sheraccerp/widget/inventory_menu.dart';
import 'package:sheraccerp/widget/inventory_report_menu.dart';
import 'package:sheraccerp/widget/record_list_menu.dart';
import 'package:sheraccerp/widget/report.dart';
import 'package:sheraccerp/screens/settings/more_widget.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> with TickerProviderStateMixin {
  final CommonService _commonService = CommonService();
  Map<dynamic, dynamic>? responseBody;
  String messageTitle = "Empty";
  bool msg = false;
  String notificationAlert = "alert";
  // FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FirebaseInAppMessaging firebaseInAppMessaging =
      FirebaseInAppMessaging.instance;
  DioService api = DioService();
  ScrollController? scrollController;
  bool dialVisible = true;

  @override
  void initState() {
    super.initState();
    ComSettings().fetchOtherData();
    firebaseInAppMessaging.triggerEvent('on_foreground');

    // _firebaseMessaging.configure(
    //   onMessage: (message) async {
    //     setState(() {
    //       messageTitle = message["notification"]["title"];
    //       notificationAlert = "New Notification Alert";
    //       msg = true;
    //     });
    //   },
    //   onResume: (message) async {
    //     setState(() {
    //       messageTitle = message["data"]["title"];
    //       notificationAlert = "Application opened from Notification";
    //     });
    //   },
    // );
    notify();
    load();
  }

  notify() async {
    // var token = await _firebaseMessaging.getToken();
    // print("Instance ID: " + token);
    //             showDialog(
    // context: context, builder: (BuildContext context) => CustomDialog());
    // showFancyCustomDialog(context);
    // if (msg) {
    //   showDialog(
    //       context: context,
    //       builder: (BuildContext context) => CustomAlertDialog(
    //             title: messageTitle,
    //             message: notificationAlert,
    //           ));
    // }

    /***Test Data***/
    // final dbHelper = DatabaseHelper.instance;
    // final allRows = await dbHelper.queryAllRows();
    // List<Carts> carts = [];
    // for (var row in allRows) {
    //   carts.add(Carts.fromMap(row));
    // }
    // if (carts.isNotEmpty) {
    //   api.addEvent([
    //     {'data': Carts.encodeCartToJson(carts).toString()}
    //   ]).then((value) {
    //     if (value) {
    //       for (Carts carts in carts) {
    //         _delete(carts.id, dbHelper);
    //       }
    //     }
    //   });
    // }
  }

  void _delete(id, DatabaseHelper dbHelper) async {
    final rowsDeleted = await dbHelper.delete(id);
  }

  void _update(id, name, status, DatabaseHelper dbHelper) async {
    // row to update
    Carts carts = Carts(id, name, status);
    final rowsAffected = await dbHelper.update(carts);
  }

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  void _handleLogout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  
  return await showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'poppins',
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Text(
                'Are you sure you want to logout from your User?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  fontFamily: 'poppins',
                  height: 1.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(true);
                        await pref.remove('userId');
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            ModalRoute.withName('/login'),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor, //Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      child: const Text('Yes'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}


  String _regId = "", firm = "", firmCode = "", fId = "";
  load() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _regId = (pref.getString('regId') ?? "");
      firm = (pref.getString('CompanyName') ?? "");
      firmCode = (pref.getString('CustomerCode') ?? "");
      fId = (pref.getString('fId') ?? "");
    });
  }

  bool isPopDone = false, isExpireWarning = false;
  @override
  Widget build(BuildContext context) {
    final CompanyUser args =
        ModalRoute.of(context)!.settings.arguments as CompanyUser;
    debugPrint(args.toString());
    int daysLeft = 0;
    if (!isPopDone) {
      if (args.active == 'false') {
        daysLeft = _commonService.getDaysLeft(args.atDate);
        if (daysLeft <= 3 && daysLeft >= 0) {
          setState(() {
            isExpireWarning = true;
          });
          Future.delayed(const Duration(seconds: 5), () {
            setState(() {
              isPopDone = true;
              isExpireWarning = false;
            });
          });
        }
      }
    }
    final List<String> imagetxt = [
      'Today',
      'Dashboard',
      'Inventory',
      'Accounts',
      'Account Report',
      'Inventory Report',
      'Report',
      'Record List',
      'Settings',
      'Tools',
    ];
    
    return WillPopScope(
      onWillPop: showExitPopup,
      child: DefaultTabController(
          length: 10,
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: -19,
              toolbarHeight: 90,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 3, top: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 12.0, 
                        sigmaY: 11.0, 
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12), 
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2), 
                            width: .5,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.logout,
                            size: 24,
                            color: Colors.white, 
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            _handleLogout();
                          },
                        ),
                      ),
                    ),
                  ),
                )
              ],
              // elevation: .1,
              title: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: TabBar(
                  dividerColor: kPrimaryColor,
                  indicator: const BoxDecoration(color: kPrimaryColor),
                  tabs: [
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/icons/today_icon.png'),
                          const Text(
                            'Today',
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/icons/Dashboard_icon.png'),
                          const Text(
                            'DashBoard',
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Tab(icon: Icon(Icons.assessment), text: "Statement"),
                    // Tab(icon: Icon(Icons.assignment), text: "Expense"),
                    // Tab(icon: Icon(Icons.assignment_outlined), text: "Cash & Bank"),
                    // Tab(
                    //     icon: Icon(Icons.assignment_outlined),
                    //     text: "Receivable & Payable"),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/icons/Inventory_icon.png'),
                          const Text(
                            'Inventory',
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/icons/accounts_icon.png'),
                          const Text(
                            'Accounts',
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/icons/accounts_report_icon.png'),
                          const Text(
                            'Account Report',
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/icons/Inventory_report_icon.png'),
                          const Text(
                            'Inventory Report',
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/icons/Report_icon.png'),
                          const Text(
                            'Report',
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/icons/record_icon.png'),
                          const Text(
                            'Record List',
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/icons/Settings_icon.png'),
                          const Text(
                            'Settings',
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/icons/tools_icon.png'),
                          const Text(
                            'Tools',
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                  isScrollable: true,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            body: TabBarView(
              children: [
                (args.active == "false"
                    ? _commonService.getTrialPeriod(args.atDate)
                        ? isExpireWarning
                            ? Center(
                                child:
                                    _expireWarningWidget(args, context, daysLeft),
                              )
                            : const DashPage()
                        : _expire(args, context)
                    : const DashPage()),
                args.active == "false"
                    ? _commonService.getTrialPeriod(args.atDate)
                        ? isExpireWarning
                            ? Center(
                                child:
                                    _expireWarningWidget(args, context, daysLeft),
                              )
                            : const DashList()
                        : _expire(args, context)
                    : const DashList(),
                // args.active == "false"
                //     ? _commonService.getTrialPeriod(args.atDate)
                //         ? const Statement()
                //         : _expire(args, context)
                //     : const Statement(),
                // args.active == "false"
                //     ? _commonService.getTrialPeriod(args.atDate)
                //         ? const Expense()
                //         : _expire(args, context)
                //     : const Expense(),
                // args.active == "false"
                //     ? _commonService.getTrialPeriod(args.atDate)
                //         ? CashAndBank()
                //         : _expire(args, context)
                //     : CashAndBank(),
                // args.active == "false"
                //     ? _commonService.getTrialPeriod(args.atDate)
                //         ? ReceivablesAndPayables()
                //         : _expire(args, context)
                //     : ReceivablesAndPayables(),
                args.active == "false"
                    ? _commonService.getTrialPeriod(args.atDate)
                        ? isExpireWarning
                            ? Center(
                                child:
                                    _expireWarningWidget(args, context, daysLeft),
                              )
                            : const InventoryMenu()
                        : _expire(args, context)
                    : const InventoryMenu(),
                args.active == "false"
                    ? _commonService.getTrialPeriod(args.atDate)
                        ? isExpireWarning
                            ? Center(
                                child:
                                    _expireWarningWidget(args, context, daysLeft),
                              )
                            : const AccountsMenu()
                        : _expire(args, context)
                    : const AccountsMenu(),
                args.active == "false"
                    ? _commonService.getTrialPeriod(args.atDate)
                        ? isExpireWarning
                            ? Center(
                                child:
                                    _expireWarningWidget(args, context, daysLeft),
                              )
                            : const AccountsReportMenu()
                        : _expire(args, context)
                    : const AccountsReportMenu(),
                args.active == "false"
                    ? _commonService.getTrialPeriod(args.atDate)
                        ? isExpireWarning
                            ? Center(
                                child:
                                    _expireWarningWidget(args, context, daysLeft),
                              )
                            : const InventoryReportMenu()
                        : _expire(args, context)
                    : const InventoryReportMenu(),
                args.active == "false"
                    ? _commonService.getTrialPeriod(args.atDate)
                        ? isExpireWarning
                            ? Center(
                                child:
                                    _expireWarningWidget(args, context, daysLeft),
                              )
                            : Report()
                        : _expire(args, context)
                    : Report(),
                args.active == "false"
                    ? _commonService.getTrialPeriod(args.atDate)
                        ? isExpireWarning
                            ? Center(
                                child:
                                    _expireWarningWidget(args, context, daysLeft),
                              )
                            : const RecordListMenu()
                        : _expire(args, context)
                    : const RecordListMenu(),
                const AppSettings(),
                args.userType.toUpperCase() == 'ADMIN'
                    ? const MoreWidget()
                    : const MoreWidget2(),
              ],
            ),
            // floatingActionButton: buildSpeedDial(args),
          )),
    );
  }

  SpeedDial buildSpeedDial(CompanyUser args) {
    return SpeedDial(
      // marginEnd: 18,
      // marginBottom: 20,
      childMargin: const EdgeInsets.only(bottom: 20),
      icon: Icons.add_circle_outline_rounded,
      activeIcon: Icons.highlight_remove_rounded,
      buttonSize: const Size(56.0, 56.0),
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: kPrimaryColor,
      overlayOpacity: 0.5,
      // onOpen: () => print('OPENING DIAL'),
      // onClose: () => print('DIAL CLOSED'),
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: const CircleBorder(),
      gradientBoxShape: BoxShape.circle,
      // gradient: LinearGradient(
      //   begin: Alignment.topCenter,
      //   end: Alignment.bottomCenter,
      //   colors: [kPrimaryColor, Colors.white10],
      // ),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.shopping_bag),
          // backgroundColor: Colors.red[500],
          label: 'Purchase',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            Navigator.pushNamed(context, '/purchase');
          },
          // onLongPress: () => print('SECOND CHILD LONG PRESS'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.storefront_rounded),
          // backgroundColor: kPrimaryColor[500],
          label: 'Sales',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            var settings = ScopedModel.of<MainModel>(context).getSettings();
            bool sType = ComSettings.getValue('TOOLBAR SALES', settings)
                    .toString()
                    .isNotEmpty
                ? ComSettings.selectSalesType(
                    ComSettings.getValue('TOOLBAR SALES', settings))
                : false;
            args.active == "false"
                ? _commonService.getTrialPeriod(args.atDate)
                        ? Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Sale(
                                  oldSale: false,
                                  thisSale: sType,
                                )))
                    : _expire(args, context)
                
                    : Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Sale(
                              oldSale: false,
                              thisSale: sType,
                            )));
          },
          // onLongPress: () => print('FIRST CHILD LONG PRESS'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.payment_rounded),
          // backgroundColor: kPrimaryColor[500],
          label: 'Payment',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            args.active == "false"
                ? _commonService.getTrialPeriod(args.atDate)
                    ? Navigator.pushNamed(context, '/RPVoucher',
                        arguments: {'voucher': 'Payment'})
                    : _expire(args, context)
                : Navigator.pushNamed(context, '/RPVoucher',
                    arguments: {'voucher': 'Payment'});
          },
          // onLongPress: () => print('FIRST CHILD LONG PRESS'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.receipt_rounded),
          // backgroundColor: kPrimaryColor[500],
          label: 'Receipt',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            args.active == "false"
                ? _commonService.getTrialPeriod(args.atDate)
                    ? Navigator.pushNamed(context, '/RPVoucher',
                        arguments: {'voucher': 'Receipt'})
                    : _expire(args, context)
                : Navigator.pushNamed(context, '/RPVoucher',
                    arguments: {'voucher': 'Receipt'});
          },
          // onLongPress: () => print('FIRST CHILD LONG PRESS'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.people_rounded),
          // backgroundColor: kPrimaryColor[500],
          label: 'Ledger Report',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () {
            argumentsPass = {'mode': 'ledger'};
            Navigator.pushNamed(
              context,
              '/select_ledger',
            );
          },
          // onLongPress: () => print('FIRST CHILD LONG PRESS'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.keyboard_voice),
          // backgroundColor: Colors.green,
          label: 'Voice',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () => _showDialog(context),
          // onLongPress: () => print('THIRD CHILD LONG PRESS'),
        ),
      ],
    );
  }
    Future<bool> showExitPopup() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit an App?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 50.0,
                width: 50.0,
              ),
              const Text("SherAcc Alert"),
            ],
          ),
          content: const Text("Not Available. \nwe will update next time"),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _expire(CompanyUser args, context) {
    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(10),
        child: Container(
          padding: const EdgeInsets.all(0.0),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 100,
                width: 90,
              ),
              Text(
                firm.toUpperCase(),
                style:
                    const TextStyle(
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(
                height: 1,
              ),
              Text(
                "CustomerId : $fId / $_regId",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 19, color: blue),
              ),
              const Divider(
                height: 1,
              ),
              Text(
                "UserId : ${args.userId}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 19, color: blue),
              ),
              const Divider(
                height: 1,
              ),
              Text(
                "Dear ${args.username}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 19, color: red),
              ),
              const Text(
                'Your trial period expired',
                style: TextStyle(fontWeight: FontWeight.bold, color: red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _expireWarningWidget(CompanyUser args, context, int daysLeft) {
    return Center(
      child: Card(
        elevation: 10,
        margin: const EdgeInsets.all(10),
        child: Container(
          padding: const EdgeInsets.all(0.0),
          height: 220,
          child: Column(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 100,
                width: 90,
              ),
              Text(
                firm.toUpperCase(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Divider(
                height: 1,
              ),
              Text(
                "CustomerId : $fId / $_regId",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 19, color: blue),
              ),
              const Divider(
                height: 1,
              ),
              Text(
                "UserId : ${args.userId}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 19, color: blue),
              ),
              const Divider(
                height: 1,
              ),
              Text(
                "Dear ${args.username}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 19, color: red),
              ),
              Text(
                'Your trial period $daysLeft days left',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 19, color: red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
