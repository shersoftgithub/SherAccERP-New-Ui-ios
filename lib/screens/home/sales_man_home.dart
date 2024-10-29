import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheraccerp/sales_man_settings.dart';
import 'package:sheraccerp/models/company_user.dart';
import 'package:sheraccerp/models/sales_type.dart';
import 'package:sheraccerp/screens/about_shersoft.dart';
import 'package:sheraccerp/screens/inventory/sales/sale.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/service/com_service.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dbhelper.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:intl/intl.dart';

class SalesManHome extends StatefulWidget {
  const SalesManHome({Key? key}) : super(key: key);

  @override
  State<SalesManHome> createState() => _SalesManHomeState();
}

class _SalesManHomeState extends State<SalesManHome> {
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
  bool dialVisible = true, isExpired = false;
  DateTime now = DateTime.now();

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
    setToDay = DateFormat('dd-MM-yyyy').format(now);
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

  sentBachUpData() async {
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
    final dbHelper = DatabaseHelper.instance;
    final allRows = await dbHelper.queryAllRows();
    List<Carts> carts = [];
    for (var row in allRows) {
      carts.add(Carts.fromMap(row));
    }
    if (carts.isNotEmpty) {
      api.addEvent([
        {'data': Carts.encodeCartToJson(carts).toString()}
      ]).then((value) {
        if (value) {
          for (Carts carts in carts) {
            _delete(carts.id, dbHelper);
          }
        }
      });
    }
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

  _handleLogout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              pref.remove('userId');
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', ModalRoute.withName('/login'));
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  bool isPopDone = false, isExpireWarning = false;

  @override
  Widget build(BuildContext context) {
    final CompanyUser args =
        ModalRoute.of(context)!.settings.arguments as CompanyUser;
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
    return WillPopScope(
      onWillPop: showExitPopup,
      child: Scaffold(
        backgroundColor: bagroundColor,
          appBar: AppBar(
            title: const Text("SherAcc"),
            titleTextStyle: const TextStyle(
              fontFamily: 'poppins'
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  _handleLogout();
                },
              ),
              IconButton(
                  onPressed: () {
                    var _pass = '';
                    if (companyUserData!.userType.toUpperCase() == 'ADMIN' ||
                        sherSoftPassword.toString().isEmpty) {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const SalesManSettings()));
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    20.0,
                                  ),
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(
                                top: 10.0,
                              ),
                              title: const Text(
                                "Enter Code",
                                style: TextStyle(fontSize: 24.0),
                              ),
                              content: SizedBox(
                                height: 400,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Enter Your Code",
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'Enter Code here',
                                              labelText: 'Code'),
                                          obscureText: true,
                                          onChanged: (value) => _pass = value,
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 60,
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (_pass == sherSoftPassword) {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          const SalesManSettings()));
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: 'incorrect code');
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            // fixedSize: Size(250, 50),
                                          ),
                                          child: const Text(
                                            "Submit",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    }
                  },
                  icon: const Icon(Icons.settings))
            ],
            elevation: .1,
          ),
          body: isExpired
              ? _expireWidget(args, context)
              : isExpireWarning
                  ? Center(
                      child: _expireWarningWidget(args, context, daysLeft),
                    )
                  : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Row(
                          // crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children:  [
                            const Text('Date',style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                            ),),
                            const SizedBox(
                              width: 4,
                            ),
                            InkWell(
                              onTap: () {
                                _selectDate();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                                  child: Row(
                                    children: [
                                      Text(getToDay,
                                      style: const TextStyle(
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.w500
                                                                  ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      const Icon(Icons.calendar_month,
                                      size: 18,
                                      color: grey,
                                      )
                                    ],
                                  ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // TextButton(
                        //   child: Text('Date : $getToDay',
                        //       style: const TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         fontSize: 20,
                        //       )),
                        //   onPressed: () => _selectDate(),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                var d = userControlData;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2
                                  ),
                                  // decoration: BoxDecoration(
                                  //   border: Border.all(color: grey),
                                  //   borderRadius: BorderRadius.circular(3)
                                  //   ),
                                    child: Text(args.username,
                              style: const TextStyle(
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              ),
                            ),
                          ],
                        ),
                      
                        const SizedBox(
                          height: 50,
                        ),
                        Visibility(
                          visible: ComSettings.userControl('SALE ORDER'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Sales Order',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                bool sType = true;
                                salesTypeData = salesTypeList.firstWhere(
                                    (element) =>
                                        element.name == 'Sales Order Entry');
                                args.active == "false"
                                    ? _commonService.getTrialPeriod(args.atDate)
                                            ? Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) => Sale(
                                                          oldSale: false,
                                                          thisSale: sType,
                                                        )))
                                        : _expire(args, context)
                                        : Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) => Sale(
                                                      oldSale: false,
                                                      thisSale: sType,
                                                    )));
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('SALE'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Sales',
                                   style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                bool sType = isEstimateDataBase;
                                              
                                salesTypeData = ComSettings.appSettings('bool',
                                        'key-switch-sales-form-set', false)
                                    ? salesTypeList.firstWhere((element) =>
                                        element.name ==
                                        ComSettings.salesFormList(
                                                'key-item-sale-form-', false)[0]
                                            .name)
                                    : salesTypeList.firstWhere((element) =>
                                        element.name == 'Sales Estimate Entry');
                                args.active == "false"
                                    ? _commonService.getTrialPeriod(args.atDate)
                                            ? Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) => Sale(
                                                          oldSale: false,
                                                          thisSale: sType,
                                                        )))
                                        : _expire(args, context)
                                        : Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) => Sale(
                                                      oldSale: false,
                                                      thisSale: sType,
                                                    )));
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('RECEIPT'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Receipt',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                args.active == "false"
                                    ? _commonService.getTrialPeriod(args.atDate)
                                        ? Navigator.pushNamed(
                                            context, '/RPVoucher',
                                            arguments: {'voucher': 'Receipt'})
                                        : _expire(args, context)
                                    : Navigator.pushNamed(context, '/RPVoucher',
                                        arguments: {'voucher': 'Receipt'});
                              },
                            ),
                          ),
                        ),
                        Visibility(
                            visible: ComSettings.userControl('RECEIPT ORDER'),
                            child: Container(
                              margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                              child: TextButton(
                                child: const Text('Receipt Order',
                                   style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                                onPressed: () {
                                  args.active == "false"
                                      ? _commonService.getTrialPeriod(args.atDate)
                                          ? Navigator.pushNamed(
                                              context, '/RPVoucher', arguments: {
                                              'voucher': 'Receipt Order'
                                            })
                                          : _expire(args, context)
                                      : Navigator.pushNamed(context, '/RPVoucher',
                                          arguments: {
                                              'voucher': 'Receipt Order'
                                            });
                                },
                              ),
                            ),
                          ),
                        Visibility(
                          visible: ComSettings.userControl('PAYMENT'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Payment',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                args.active == "false"
                                    ? _commonService.getTrialPeriod(args.atDate)
                                        ? Navigator.pushNamed(
                                            context, '/RPVoucher',
                                            arguments: {'voucher': 'Payment'})
                                        : _expire(args, context)
                                    : Navigator.pushNamed(context, '/RPVoucher',
                                        arguments: {'voucher': 'Payment'});
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('PURCHASE'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Purchase',
                                   style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                Navigator.pushNamed(context, '/purchase');
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('ORDER LIST'),
                          child: Container( 
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                            decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Order List',
                                   style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                Navigator.pushNamed(context, '/OrderList');
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('SALE'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Bill List',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                Navigator.pushNamed(context, '/BillList');
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('Order Item List'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Order Item List',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                Navigator.pushNamed(context, '/OrderItemList');
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('SALE RETURN'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Sales Return',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                Navigator.pushNamed(context, '/salesReturn');
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('DAMAGE'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Damage Entry',
                                   style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                Navigator.pushNamed(context, '/damageEntry');
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('LEDGER'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Ledger',
                                   style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                Navigator.pushNamed(context, '/ledger',
                                    arguments: {'parent': ''});
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('JOURNAL'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Journal',
                                   style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                args.active == "false"
                                    ? _commonService.getTrialPeriod(args.atDate)
                                        ? Navigator.pushNamed(
                                            context, '/journal')
                                        : _expire(args, context)
                                    : Navigator.pushNamed(context, '/journal');
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('LEDGER REPORT'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Ledger Report',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                argumentsPass = {'mode': 'ledger'};
                                Navigator.pushNamed(
                                  context,
                                  '/select_ledger',
                                );
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('GROUP LIST'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Group List',
                                   style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                argumentsPass = {'mode': 'GroupList'};
                                Navigator.pushNamed(
                                  context,
                                  '/select_ledger',
                                );
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('SALES REPORT'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Sales List',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/SalesList',
                                );
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('PAYMENT INVOICE'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Payment Invoice',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                Navigator.pushNamed(context, '/InvRPVoucher',
                                    arguments: {'voucher': 'Payment Invoice'});
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: ComSettings.userControl('RECEIPT INVOICE'),
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                            child: TextButton(
                              child: const Text('Receipt Invoice',
                                   style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                              onPressed: () {
                                Navigator.pushNamed(context, '/InvRPVoucher',
                                    arguments: {'voucher': 'Receipt Invoice'});
                              },
                            ),
                          ),
                        ),
                         Visibility(
                            visible: ComSettings.userControl('STOCK REPORT'),
                            child: Container(
                              margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                              child: TextButton(
                                child: const Text('Stock Report',
                                   style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/StockReport');
                                },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: ComSettings.userControl('SALESMAN REPORT'),
                            child: Container(
                              margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                              child: TextButton(
                                child: const Text('SalesMan Report',
                                    style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                                onPressed: () {
                                  argumentsPass = 'SalesMan';
                                  Navigator.pushNamed(
                                    context,
                                    '/salesManReport',
                                  );
                                },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: ComSettings.userControl('RECEIPT REPORT'),
                            child: Container(
                              margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                              child: TextButton(
                                child: const Text('Receipt List',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                                onPressed: () {
                                  argumentsPass = {'mode': 'ReceiptList'};
                                  Navigator.pushNamed(
                                    context,
                                    '/select_ledger',
                                  );
                                },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: ComSettings.userControl('PAYMENT REPORT'),
                            child: Container(
                              margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                              child: TextButton(
                                child: const Text('Payment List',
                                    style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                                onPressed: () {
                                  argumentsPass = {'mode': 'PaymentList'};
                                  Navigator.pushNamed(
                                    context,
                                    '/select_ledger',
                                  );
                                },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: ComSettings.userControl('PRICE LIST'),
                            child: Container(
                              margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                             decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                              child: TextButton(
                                child: const Text('Price List',
                                    style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/priceList');
                                },
                              ),
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.only(
                              bottom: 6
                            ),
                           decoration: BoxDecoration(
                              color: white,
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)
                                  ),
                          child: TextButton(
                            child: const Text('About',
                                style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AboutSherSoft()),
                              );
                            },
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3)
                            )
                          ),
                            onPressed: () async {
                              sentBachUpData();
                            },
                            child: const Text('Share Catch File', style: TextStyle(
                                    color: kPrimaryColor,
                                                                    fontFamily: 'poppins',
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500
                                                                  ),))
                      ],
                    ),
                  )),
    );
  }

  _expire(CompanyUser args, context) {
    setState(() {
      isExpired = true;
    });
  }

  Future _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => setToDay = DateFormat('dd-MM-yyyy').format(picked));
    }
  }

  _expireWidget(CompanyUser args, context) {
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
                      fontWeight: FontWeight.bold, fontSize: 20),
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
