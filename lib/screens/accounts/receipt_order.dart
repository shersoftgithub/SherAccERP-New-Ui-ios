import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/customer_model.dart';
import 'package:sheraccerp/models/ledger_name_model.dart';
import 'package:sheraccerp/models/rp_model.dart';
import 'package:sheraccerp/models/sms_data_model.dart';
import 'package:sheraccerp/models/voucher_type_model.dart';
import 'package:sheraccerp/scoped-models/main.dart';
import 'package:sheraccerp/screens/html_previews/rpv_preview.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/color_palette.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/container_textfield_widget.dart';
import 'package:sheraccerp/widget/loading.dart';
import 'package:sheraccerp/widget/progress_hud.dart';

class ReceiptOrder extends StatefulWidget {
  const ReceiptOrder({Key? key}) : super(key: key);

  @override
  State<ReceiptOrder> createState() => _ReceiptOrderState();
}

class _ReceiptOrderState extends State<ReceiptOrder> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<LedgerModel> cashBankACList = [];
  List<RpVoucherParticularModel> particularList = [];
  Size? deviceSize;
  List<dynamic> items = [];
  List<dynamic> itemDisplay = [];
  List<String> ledgerListDisplay = [];
  List<LedgerModel> ledgerList = [];
  DioService api = DioService();
  DateTime now = DateTime.now();
  String? formattedDate, narration = '', projectId = '-1';
  double? balance = 0, total = 0, amount = 0, discount = 0,oldBalance = 0;
  var accountId = '', accountName = '';
  LedgerModel? ledData;
  bool _isLoading = false,
      isSelected = false,
      oldVoucher = false,
      valueMore = false,
      widgetID = true,
      lastRecord = false,
      buttonEvent = false,
      isMultiRvPv = false,
      keyLockCashAccount = false,
      isSalesManWiseLedger = false,
      keyEditAndDeleteAdminOnlyDaysBefore = false,
      daysBefore = false;
  int refNo = 0, acId = 0;
  int page = 1, pageTotal = 0, totalRecords = 0, valueDaysBefore = 0;
  int locationId = 1,
      salesManId = 0,
      decimal = 2,
      groupId = 0,
      areaId = 0,
      routeId = 0;
  VoucherType voucherTypeData = VoucherType.emptyData();
  List<CompanySettings>? settings;
  CompanyInformation? companySettings;
  final TextEditingController _controllerAmount = TextEditingController();
  final TextEditingController _controllerDiscount = TextEditingController();
  final TextEditingController _controllerNarration = TextEditingController();

  @override
  void initState() {
    super.initState();
    formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);

    api.getCashBankAc().then((value) {
      setState(() {
        cashBankACList.addAll(value);
      });
    });

      api.getCustomerNameListLike(
                      groupId, areaId, routeId, salesManId, nameLike).then(
                         (value) {
        setState(() {
          ledgerList.addAll(value);
          ledgerListDisplay.addAll(List<String>.from(ledgerList
              .map((item) => (item.name))
              .toList()
              .map((s) => s)
              .toList()));
        });
      },
                      );

    loadSettings();
    loadAsset();
  }
String cashAc = '';
  int cashId = 0;
  loadSettings() {
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();

     cashAc =
        ComSettings.getValue('CASH A/C', settings!).toString().trim() ?? 'CASH';
      acId = mainAccount
        .firstWhere((element) => element['LedName'] == cashAc)['LedCode'];
    cashId =
        ComSettings.appSettings('int', 'key-dropdown-default-cash-ac', 0) - 1;
    var acModel = cashId > 0
        ? mainAccount.firstWhere((element) => element['LedCode'] == cashId,
            orElse: () => {'LedName': cashAc, 'LedCode': acId})
        : {'LedName': cashAc, 'LedCode': acId};
    acId = cashId > 0 ? acModel['LedCode'] : acId;
    cashAc = cashId > 0 ? acModel['LedName'] : cashAc;
    if (acId > 0) {
      _dropDownValue = '$acId-$cashAc';
      accountId = acId.toString();
      accountName = cashAc;
    }
    salesManId = ComSettings.appSettings(
            'int', 'key-dropdown-default-salesman-view', 1) -
        1;
    locationId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    decimal = ComSettings.getValue('DECIMAL', settings!).toString().isNotEmpty
        ? int.tryParse(ComSettings.getValue('DECIMAL', settings!).toString())!
        : 2;
    isMultiRvPv = ComSettings.getStatus('KEY MULTI RV-PV', settings!);
    groupId =
        ComSettings.appSettings('int', 'key-dropdown-default-group-view', 0) -
            1;
    areaId =
        ComSettings.appSettings('int', 'key-dropdown-default-area-view', 0) - 1;
    routeId =
        ComSettings.appSettings('int', 'key-dropdown-default-route-view', 0) -
            1;
    keyEditAndDeleteAdminOnlyDaysBefore = ComSettings.getStatus(
        'KEY EDIT AND DELETE ADMIN ONLY DAYS BEFORE', settings!);
    valueDaysBefore = int.tryParse(ComSettings.getValue(
            'KEY EDIT AND DELETE ADMIN ONLY DAYS BEFORE', settings!)
        .toString())!;
    isSalesManWiseLedger =
        ComSettings.getStatus('KEY SALESMAN WISE LEDGER', settings!);
    userDateCheck(DateUtil.dateYMD(formattedDate));
  }

  userDateCheck(String date) {
    if (keyEditAndDeleteAdminOnlyDaysBefore) {
      DateTime date1 =
          DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(date)));
      DateTime date2 = DateTime.parse(DateFormat('yyyy-MM-dd').format(now));

      if (DateUtil.compareDate(
          date1: date1, date2: date2, days: valueDaysBefore)) {
        if (companyUserData!.userType.toUpperCase() != 'ADMIN') {
          daysBefore = true;
        }else {
          daysBefore = false;
        }
      }else {
        daysBefore = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    final routes = (ModalRoute.of(context)!.settings.arguments) != null
        ? (ModalRoute.of(context)!.settings.arguments) as Map<String, String>
        : {'voucher': ''};
    var title = routes.isNotEmpty ? routes['voucher'].toString() : 'Voucher';
    if (voucherTypeList.isNotEmpty) {
      voucherTypeData = voucherTypeList.firstWhere((element) =>
                      element.voucher.toLowerCase() == 'receipt order');
      // = title == 'Payment'
      //     ? voucherTypeList.firstWhere(
      //         (element) => element.voucher.toLowerCase() == 'payment')
      //     : title == 'Receipt'
      //         ? voucherTypeList.firstWhere(
      //             (element) => element.voucher.toLowerCase() == 'receipt')
      //             : title == 'Receipt Order'
      //             ? voucherTypeList.firstWhere((element) =>
      //                 element.voucher.toLowerCase() == 'receipt order')
      //                 : title == 'Payment Order'
      //                  ? voucherTypeList.firstWhere((element) =>
      //                     element.voucher.toLowerCase() == 'Payment order')
      //                       : VoucherType.emptyData();
    }
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
          final NavigatorState navigator = Navigator.of(context);
          final bool? shouldPop = await _onWillPop();
          if (shouldPop ?? false) {
            navigator.pop();
          }
        },
        child: widgetID ? widgetPrefix(title) : widgetSuffix(title));
  }

  _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  widgetSuffix(title) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: [
            Visibility(
              visible: oldVoucher,
              child: IconButton(
                  color: red,
                  iconSize: 40,
                  onPressed: () {
                    //delete
                    if (buttonEvent) {
                      return;
                    } else {
                      if (accountId.trim().isEmpty &&
                          accountName.trim().isEmpty) {
                        // accountId = acId > 0 ? acId.toString() : '0';
                        Fluttertoast.showToast(msg: 'Select Cash Account');
                        return;
                      }
                      if (companyUserData!.deleteData) {
                        if (!daysBefore) {
                          title == 'Payment'
                              ? deleteVoucher('Payment', 'DELETE')
                              : deleteVoucher('Receipt', 'DELETE');
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Voucher Date not equal\ncan`t delete');
                          setState(() {
                            buttonEvent = false;
                          });
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Permission denied\ncan`t delete');
                        setState(() {
                          buttonEvent = false;
                        });
                      }
                    }
                  },
                  icon: Image.asset('assets/icons/ic_delete.png',scale: 3.3,)),
            ),
            oldVoucher
                ? IconButton(
                    color: white,
                    iconSize: 40,
                    onPressed: () {
                      //edit
                      if (accountId.trim().isEmpty &&
                          accountName.trim().isEmpty) {
                        // accountId = acId > 0 ? acId.toString() : '0';
                        Fluttertoast.showToast(msg: 'Select Cash Account');
                        return;
                      }
                       if (buttonEvent) {
                      return;
                    } else {
                      if (companyUserData!.updateData) {
                        if (!daysBefore) {
                          title == 'Payment'
                              ? submitData('Payment', 'UPDATE')
                              : submitData('Receipt', 'UPDATE');
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Voucher Date not equal\ncan`t edit');
                          setState(() {
                            buttonEvent = false;
                          });
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Permission denied\ncan`t edit');
                        setState(() {
                          buttonEvent = false;
                        });
                      }
                    }
                    },
                    icon: Image.asset('assets/icons/ic_edit.png',scale: 3.3,))
                : IconButton(
                    color: white,
                    iconSize: 40,
                    onPressed: () {
                      //save
                      if (accountId.trim().isEmpty &&
                          accountName.trim().isEmpty) {
                        //   accountId = acId > 0 ? acId.toString() : '0';
                        Fluttertoast.showToast(msg: 'Select Cash Account');
                        return;
                      }
                       if (buttonEvent) {
                      return;
                    } else {
                      if (companyUserData!.insertData) {
                        if (!daysBefore) {
                          title == 'Payment'
                              ? submitData('Payment', 'INSERT')
                              : submitData('Receipt', 'INSERT');
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Voucher Date not equal\ncan`t save');
                          setState(() {
                            buttonEvent = false;
                          });
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Permission denied\ncan`t save');
                        setState(() {
                          buttonEvent = false;
                        });
                      }
                    }
                    },
                    icon: Image.asset('assets/icons/Save instagram@2x.png',scale: 1.6,)),
          ],
          title: Text(title),
          titleTextStyle: const TextStyle(fontFamily: 'poppins'),
        ),
        body: ProgressHUD(
          inAsyncCall: _isLoading,
          opacity: 0.0,
          child: cashBankACList.isNotEmpty ? _body(title) : const Loading(),
        ));
  }

  var nameLike = 'a';
  _body(mode) {
    return Container(
      padding: const EdgeInsets.all(6.0),
      child: SingleChildScrollView(
        child:
            isMultiRvPv ? voucherParticularWidget(mode) : voucherWidget(mode),
        // mode == 'Payment' ? paymentVoucher() : receiptVoucher(),
      ),
    );
  }

  widgetPrefix(mode) {
    return Scaffold(
      backgroundColor: bagroundColor,
        key: _scaffoldKey,
        appBar: AppBar(
          actions: [
            TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue[700],
                ),
                onPressed: () async {
                  setState(() {
                    widgetID = false;
                  });
                },
                child: const Text(
                  " New ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
          ],
          title: Text(mode),
        ),
        body: Container(
          child: previousBill(mode),
        ));
  }

  final ScrollController _scrollController = ScrollController();
  bool isLoadingData = false;
  List dataDisplay = [];

  void _getMoreData(mode) async {
    if (!lastRecord) {
      if (dataDisplay.isEmpty ||
          // ignore: curly_braces_in_flow_control_structures
          dataDisplay.length < totalRecords) if (!isLoadingData) {
        setState(() {
          isLoadingData = true;
        });

        List tempList = [];
        var statement = mode == 'Payment' ? 'PVList' : 'RVList';
        salesManId = salesManId > 0 ? salesManId : -1;
        locationId = locationId > 0 ? locationId : -1;
        String salesMan = salesManId > 0 ? salesManId.toString() : '';
        api
            .getPaginationList(
                statement,
                page,
                locationId.toString(),
                voucherTypeData.id.toString(),
                DateUtil.dateYMD(formattedDate),
                salesMan)
            .then((value) {
          if (value.isEmpty) {
            return;
          }
          final response = value;
          pageTotal = response[1][0]['Filtered'];
          totalRecords = response[1][0]['Total'];
          page++;
          for (int i = 0; i < response[0].length; i++) {
            tempList.add(response[0][i]);
          }

          setState(() {
            isLoadingData = false;
            dataDisplay.addAll(tempList);
            lastRecord = tempList.isNotEmpty ? false : true;
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  CustomerModel? ledgerData;
  ledgerDetailWidget(int id) {
    return FutureBuilder<CustomerModel>(
      future: api.getCustomerDetail(id),
      builder: (context, snapshot) {
        ledgerData = snapshot.data;
          if (snapshot.hasData) {
          oldBalance = oldVoucher
              ? oldBalance
              : double.parse(snapshot.data!.balance.toString().split(' ')[0]);
        }
        return snapshot.hasData
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    'Balance : ${snapshot.data!.balance}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                    Expanded(
                      child: Text(
                    oldVoucher ? 'OB : $oldBalance' : '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    'Balance : 0',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
              );
      },
    );
  }
   getOldBalance(int Id, String statement, String type, String date, entryno) {
    api.getBalance(Id, statement, type, date, entryno).then((value) {
      oldBalance = double.parse(value['oldBalance'].toString());
    });
  }
  // paymentVoucher() {
  //   //Payment
  //   return Column(
  //     children: [
  //       TextButton(
  //           onPressed: () async {
  //             submitData('Payment');//submitData('Receipt');
  //           },
  //           style: TextButton.styleFrom(
  //               primary: white,
  //               backgroundColor: blue,
  //               side: const BorderSide(color: kPrimaryDarkColor, width: 1)),
  //           child: const Text('Save'))
  //     ],
  //   );
  // }

  // receiptVoucher() {
  //   //Receipt
  //   return Column(
  //     children: [
  //       TextButton(
  //           onPressed: () async {
  //             submitData('Receipt');
  //           },
  //           style: TextButton.styleFrom(
  //               primary: white,
  //               backgroundColor: blue,
  //               side: const BorderSide(color: kPrimaryDarkColor, width: 1)),
  //           child: const Text('Save'))
  //     ],
  //   );
  // }

  void submitData(mode, operation) async {
    if (accountId.isEmpty) {
      Fluttertoast.showToast(msg: 'Select Cash Account');
    } else {
      if (isMultiRvPv) {
        setState(() {
          _isLoading = true;
          buttonEvent = true;
        });
        var particular =
            RpVoucherParticularModel.toMapData(particularList).toString();
        double totalAmount = 0, totalDiscount = 0, totalTotal = 0;
        totalAmount = particularList.fold(
            0, (previousValue, element) => previousValue + element.amount);
        totalDiscount = particularList.fold(
            0, (previousValue, element) => previousValue + element.discount);
        totalTotal = particularList.fold(
            0, (previousValue, element) => previousValue + element.total);
        var data = [
          {
            'entryno': oldVoucher ? dataDynamic[0]['EntryNo'].toString() : '0',
            'date': formatDMY(formattedDate),
            'debitAccount': accountId,
            'amount': totalAmount,
            'discount': totalDiscount,
            'total': totalTotal,
            'location': locationId,
            'user': 1,
            'project': projectId,
            'salesman': salesManId,
            'month': '',
            'particular': particular,
            'fyId': currentFinancialYear!.id,
            'frmId': voucherTypeData.id,
            'statementType': operation == 'UPDATE'
                ? mode == 'Payment'
                    ? 'Update_Pv'
                    : 'Update_Rv'
                : mode == 'Payment'
                    ? 'InsertPv'
                    : 'Insert_Rv'
            // 'Update_Rv'  Update_Pv Delete_Pv Delete_Rv  FindPv FindRv
          }
        ];
        refNo = await api.addVoucher(data);
        if (refNo > 0) {
          setState(() {
            _isLoading = false;
            buttonEvent = false;
            // showInSnackBar(operation == 'DELETE'
            //     ? 'Deleted : ' + mode + ' voucher.'
            //     : operation == 'UPDATE'
            //         ? 'Update : ' + mode + ' voucher.'
            //         : 'Saved : ' + mode + ' voucher.');
            if (operation == 'DELETE') {
              showInSnackBar('Deleted');
            } else {
               for (var ledData in particularList) {
                var dataAll = [
                  {
                    'entryNo': oldVoucher
                        ? dataDynamic[0]['EntryNo'].toString()
                        : refNo,
                    'date': formatDMY(formattedDate),
                    'debitAccount': accountId,
                    'amount': amount,
                    'discount': discount,
                    'total': total,
                    'particular': particular,
                    'account': accountName,
                    'name': ledData.name,
                    'balance': ledData.balance,
                    'oldBalance': oldBalance,
                    'message': footerMessage
                  }
                ];

                if (ComSettings.appSettings(
                    'bool', 'key-sms-customer', false)) {
                  var bal = ledData.balance.toString().split(' ');
                  if (bal[1] == 'Dr') {
                    // var oldBalance = double.tryParse(bal[0].toString()) ?? 0;
                    if (mode == 'Payment') {
                      balance = oldBalance! - (data[0]['total'] as double?)!;
                    } else {
                      balance = operation == 'UPDATE'
                          ? oldBalance
                          : oldBalance! - (data[0]['total'] as double?)!;
                    }
                  } else {
                    // var oldBalance =
                    //     (double.tryParse(bal[0].toString()) * (-1));
                    balance = oldBalance! - (data[0]['total'] as double?)!;
                  }
                  var amt = balance!.toStringAsFixed(2);
                  var form = mode == 'Payment' ? 'PAYMENT' : 'RECEIPT';
                  String smsBody =
                      "Dear ${ledData.name.toString()},\nYour $form ${data[0]['entryno'].toString()}, Dated : $formattedDate for the Amount of ${data[0]['total'].toString()}/- \nBalance:$amt /- has been confirmed  \n${companySettings!.name}";
                  if (ledData.phone.toString().isNotEmpty) {
                    sendSms(ledData.phone, smsBody);
                  }
                }

                if (ComSettings.getStatus('ENABLE SMS OPTION', settings!)) {
                  String form = mode == 'Payment' ? 'PAYMENT' : 'RECEIPT';
                  SmsDataModel smsData = smsSettingsList.firstWhere(
                      (element) => element.voucher == form,
                      orElse: () => SmsDataModel.emptyData());
                  if (smsData != null && smsData.apiLink.isNotEmpty) {
                    String smsBody = smsData.messageBody;
                    String urlData = smsData.apiLink;
                    var bal = ledData.balance.toString().split(' ');
                    // double oldBalance = 0;
                    if (bal[1] == 'Dr') {
                      // oldBalance = double.tryParse(bal[0].toString()) ?? 0;
                      if (mode == 'Payment') {
                        balance = oldBalance! - (data[0]['total'] as double?)!;
                      } else {
                        balance = operation == 'UPDATE'
                            ? oldBalance
                            : oldBalance! - (data[0]['total'] as double?)!;
                      }
                    } else {
                      // oldBalance = (double.tryParse(bal[0].toString()) * (-1));
                      balance = oldBalance! - (data[0]['total'] as double?)!;
                    }
                    double cashReceived = 0, billAmount = 0;
                    billAmount = (data[0]['total'] as double?)!;
                    smsBody = smsBody
                        .replaceFirst("#Customer#", ledData.name.toString())
                        .replaceFirst("#OB#", oldBalance!.toStringAsFixed(2))
                        .replaceFirst(
                            "#EntryNo#", data[0]['entryno'].toString())
                        .replaceFirst(
                            "#ThisBill#", billAmount.toStringAsFixed(2))
                        .replaceFirst(
                            "#CashReceived#", cashReceived.toStringAsFixed(2));
                    double totalBalance =
                        ((billAmount + cashReceived)).roundToDouble();
                    smsBody = smsBody
                        .replaceFirst(
                            "#TotalBalance#", totalBalance.toStringAsFixed(2))
                        .replaceFirst("#NetBalance#", balance.toString())
                        .replaceFirst(
                            "#GrandTotal#", billAmount.toStringAsFixed(2))
                        .replaceFirst("#Narration#", ledData.narration);

                    if (ledData.phone.toString().trim().isNotEmpty) {
                      if (ledData.phone.toString().trim().length == 10) {
                        urlData = urlData
                            .replaceFirst(
                                "#MobileNo#", ledData.phone.toString().trim())
                            .replaceFirst("#SMS#", smsBody);
                        api.sentSmsOverApi(urlData);
                      }
                    }
                  } else {
                    debugPrint('sms data is empty');
                  }
                }
              }
              actionShow(mode, context, [
                {
                  'entryNo':
                      oldVoucher ? dataDynamic[0]['EntryNo'].toString() : refNo,
                  'date': formatDMY(formattedDate),
                  'debitAccount': accountId,
                  'amount': amount,
                  'discount': discount,
                  'total': total,
                  'particular': particular,
                  'account': accountName,
                  'name': ledgerData!.name,
                  'oldBalance': ledgerData!.balance,
                  'message': footerMessage
                }
              ]);
            }
          });
        } else {
          var opr = operation == 'DELETE'
              ? 'error : Cannot delete this ' + mode
              : operation == 'UPDATE'
                  ? 'error : Cannot update this ' + mode
                  : 'error : Cannot save this ' + mode;
          showInSnackBar(opr);
        }
      } else {
        if (total! <= 0 || ledData!.id <= 0) {
          Fluttertoast.showToast(msg: 'Select Account and amount');
          setState(() {
            buttonEvent = false;
          });
        } else {
          setState(() {
            _isLoading = true;
            buttonEvent = true;
          });
          var particular = '[${json.encode({
                'amount': amount,
                'discount': discount,
                'total': total,
                'narration': narration,
                'Ledid': ledData!.id
              })}]';
          var data = [
            {
              'entryno':
                  oldVoucher ? dataDynamic[0]['EntryNo'].toString() : '0',
              'date': formatDMY(formattedDate),
              'debitAccount': accountId,
              'amount': amount,
              'discount': discount,
              'total': total,
              'location': locationId,
              'user': 1,
              'project': projectId,
              'salesman': salesManId,
              'month': '',
              'particular': particular,
              'fyId': currentFinancialYear!.id,
              'frmId': voucherTypeData.id,
              'statementType': operation == 'UPDATE'
                  ? mode == 'Payment'
                      ? 'Update_Pv'
                      : 'Update_Rv'
                  : mode == 'Payment'
                      ? 'InsertPv'
                      : 'Insert_Rv'
              // 'Update_Rv'  Update_Pv Delete_Pv Delete_Rv  FindPv FindRv
            }
          ];
          refNo = await api.addVoucher(data);
          if (refNo > 0) {
            setState(() {
              _isLoading = false;
              buttonEvent = false;
              // showInSnackBar(operation == 'DELETE'
              //     ? 'Deleted : ' + mode + ' voucher.'
              //     : operation == 'UPDATE'
              //         ? 'Update : ' + mode + ' voucher.'
              //         : 'Saved : ' + mode + ' voucher.');
              if (operation == 'DELETE') {
                showInSnackBar('Deleted');
              } else {
                var dataAll = [
                  {
                    'entryNo': oldVoucher
                        ? dataDynamic[0]['EntryNo'].toString()
                        : refNo,
                    'date': formatDMY(formattedDate),
                    'debitAccount': accountId,
                    'amount': amount,
                    'discount': discount,
                    'total': total,
                    'particular': particular,
                    'account': accountName,
                    'name': ledgerData!.name,
                    'oldBalance': ledgerData!.balance,
                    'message': footerMessage
                  }
                ];
                actionShow(mode, context, dataAll);
                if (ComSettings.appSettings(
                    'bool', 'key-sms-customer', false)) {
                  var bal = ledgerData!.balance.toString().split(' ');
                  if (bal[1] == 'Dr') {
                     var oldBalance = double.tryParse(bal[0].toString()) ?? 0;
                    if (mode == 'Payment') {
                       balance = oldBalance - (data[0]['total'] as double?)!;
                    } else {
                      balance = operation == 'UPDATE'
                          ? oldBalance
                          : oldBalance - (data[0]['total'] as double?)!;
                    }
                  } else {
                     var oldBalance =
                        (double.tryParse(bal[0].toString())! * (-1));
                    balance = oldBalance - (data[0]['total'] as double?)!;
                  }
                  var amt = balance!.toStringAsFixed(2);
                  var form = mode == 'Payment' ? 'PAYMENT' : 'RECEIPT';
                  String smsBody =
                      "Dear ${ledgerData!.name.toString()},\nYour $form ${data[0]['entryno'].toString()}, Dated : $formattedDate for the Amount of ${data[0]['total'].toString()}/- \nBalance:$amt /- has been confirmed  \n${companySettings!.name}";
                  if (ledgerData!.phone.toString().isNotEmpty) {
                    sendSms(ledgerData!.phone, smsBody);
                  }
               }
                     if (ComSettings.getStatus('ENABLE SMS OPTION', settings!)) {
                  String form = mode == 'Payment' ? 'PAYMENT' : 'RECEIPT';
                  SmsDataModel smsData = smsSettingsList.firstWhere(
                      (element) => element.voucher == form,
                      orElse: () => SmsDataModel.emptyData());
                  if (smsData != null && smsData.apiLink.isNotEmpty) {
                    String smsBody = smsData.messageBody;
                    String urlData = smsData.apiLink;
                    var bal = ledgerData!.balance.toString().split(' ');
                    double oldBalance = 0;
                    if (bal[1] == 'Dr') {
                      oldBalance = double.tryParse(bal[0].toString()) ?? 0;
                      if (mode == 'Payment') {
                        balance = oldBalance - (data[0]['total'] as double?)!;
                      } else {
                        balance = operation == 'UPDATE'
                            ? oldBalance
                            : oldBalance - (data[0]['total'] as double?)!;
                      }
                    } else {
                      oldBalance = (double.tryParse(bal[0].toString())! * (-1));
                      balance = oldBalance - (data[0]['total'] as double?)!;
                    }
                    double cashReceived = 0, billAmount = 0;
                    billAmount = (data[0]['total'] as double?)!;
                    smsBody = smsBody
                        .replaceFirst("#Customer#", ledgerData!.name.toString())
                        .replaceFirst("#OB#", oldBalance.toStringAsFixed(2))
                        .replaceFirst(
                            "#EntryNo#", data[0]['entryno'].toString())
                        .replaceFirst(
                            "#ThisBill#", billAmount.toStringAsFixed(2))
                        .replaceFirst(
                            "#CashReceived#", cashReceived.toStringAsFixed(2));
                    double totalBalance =
                        ((billAmount + cashReceived)).roundToDouble();
                    smsBody = smsBody
                        .replaceFirst(
                            "#TotalBalance#", totalBalance.toStringAsFixed(2))
                        .replaceFirst("#NetBalance#", balance.toString())
                        .replaceFirst(
                            "#GrandTotal#", billAmount.toStringAsFixed(2))
                        .replaceFirst("#Narration#", narration!);

                   if (ledgerData!.phone.toString().trim().isNotEmpty) {
                      if (ledgerData!.phone.toString().trim().length == 10) {
                        urlData = urlData
                            .replaceFirst("#MobileNo#",
                                ledgerData!.phone.toString().trim())
                            .replaceFirst("#SMS#", smsBody);
                        api.sentSmsOverApi(urlData);
                      }
                    }
                    } else {
                    debugPrint('sms data is empty');
                  }
               
                }
              }
              clearData();
            });
          } else {
            var opr = operation == 'DELETE'
                ? 'error : Cannot delete this ' + mode
                : operation == 'UPDATE'
                    ? 'error : Cannot update this ' + mode
                    : 'error : Cannot save this ' + mode;
            showInSnackBar(opr);
          }
        }
      }
    }
  }

  void deleteVoucher(mode, operation) async {
    if (accountId.isEmpty) {
      Fluttertoast.showToast(msg: 'Select Cash Account');
    } else {
      bool state = false;
      if (isMultiRvPv) {
        if (particularList.isEmpty) {
          state = true;
        }
      } else {
        if (amount! <= 0 || ledData!.id <= 0) {
          state = true;
        }
      }
      if (state) {
        // if (amount! <= 0 || ledData!.id <= 0) {
        Fluttertoast.showToast(msg: 'Select Account and amount');
        setState(() {
          buttonEvent = false;
        });
      } else {
        setState(() {
          _isLoading = true;
          buttonEvent = true;
        });
        var entryNo = oldVoucher ? dataDynamic[0]['EntryNo'].toString() : '0';
        var fyId = currentFinancialYear!.id;
        var statementType = mode == 'Payment' ? 'Delete_Pv' : 'Delete_Rv';
        refNo = await api.deleteVoucher(
          entryNo,
          fyId,
          statementType,
          voucherTypeData.id,
        );
        if (refNo > 0) {
          setState(() {
            _isLoading = false;
            buttonEvent = false;
            showInSnackBar('Deleted');
            particularList = [];
            clearData();
          });
        } else {
          var opr = 'error : Cannot delete this ' + mode;
          showInSnackBar(opr);
        }
      }
    }
  }

  Uint8List? byteImage;
  loadAsset() async {
    // Test image
    ByteData bytes = await rootBundle.load('assets/logo.png');
    final buffer = bytes.buffer;
    byteImage = Uint8List.view(buffer);
  }
  
  Future<String?> selectPositionDialog(BuildContext context, int length) async {
    return await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select SlNo'),
            children: List.generate(
              length,
              (index) => SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, index.toString());
                },
                child: Text('${index + 1}'),
              ),
            ),
          );
        });
  }

  actionShow(mode, context, data) async {
    var form = mode == 'Payment' ? 'PAYMENT' : 'RECEIPT';
    var title = mode == 'Payment' ? 'Payment Voucher' : 'Receipt Voucher';

    ConfirmAlertBox(
        buttonColorForNo: Colors.red,
        buttonColorForYes: Colors.green,
        icon: Icons.check,
        onPressedNo: () {
          clearData();
          particularList = [];
          Navigator.of(context).pop();
        },
        onPressedYes: () {
          Navigator.of(context).pop();
          // _showPrinterSize(context).then((value) => printBluetooth(context,
          //     title, companySettings, settings, data, byteImage, value, form));
          if (isMultiRvPv) {
            selectPositionDialog(context, particularList.length).then((value) {
              int index = int.parse(value!);
              RpVoucherParticularModel partData = particularList[index];
              ledData = LedgerModel(id: partData.id, name: partData.name);
              var particular = '[${json.encode({
                    'amount': partData.amount,
                    'discount': partData.discount,
                    'total': partData.total,
                    'narration': partData.narration,
                    'Ledid': ledData!.id
                  })}]';
              data = [
                {
                  'entryNo': dataDynamic[0]['EntryNo'].toString(),
                  'entryNo': oldVoucher
                      ? dataDynamic[0]['EntryNo'].toString()
                      : refNo.toString(),
                  'date': formatDMY(formattedDate),
                  'debitAccount': accountId,
                  'amount': partData.amount,
                  'discount': partData.discount,
                  'total': partData.total,
                  'particular': particular,
                  'account': accountName,
                  'name': ledData!.name,
                  'balance': partData.balance.toString() == "0"
                      ? '0 Dr'
                      : partData.balance,
                  'oldBalance': oldBalance,
                  'message': footerMessage
                }
              ];

              particularList = [];
              clearData();
              return sentToPreview(title, form, data);
            });
          } else {
            clearData();
            return sentToPreview(title, form, data);
          }
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage: 'Do you want to preview \nRefNo:${data[0]['entryNo']}',
        title: 'Print Voucher',
        context: context);
  }

  // List<String> newDataList = ["2", "3", "4"];

  // Future<String> _showPrinterSize(BuildContext context) async {
  //   return await showDialog<String>(
  //       context: context,
  //       barrierDismissible: true,
  //       builder: (BuildContext context) {
  //         return SimpleDialog(
  //           title: const Text('Printer Size'),
  //           children: <Widget>[
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 Navigator.pop(context, newDataList[0]);
  //               },
  //               child: const Text('2'),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 Navigator.pop(context, newDataList[1]);
  //               },
  //               child: const Text('3'),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 Navigator.pop(context, newDataList[2]);
  //               },
  //               child: const Text('4'),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 Navigator.pop(context, newDataList[3]);
  //               },
  //               child: const Text('5'),
  //             ),
  //           ],
  //         );
  //       });
  // }

  sentToPreview(String title, String form, var data) {
    // Future<dynamic> printBluetooth(
    //     BuildContext context,
    //     String title,
    //     CompanyInformation companySettings,
    //     List<CompanySettings> settings,
    //     data,
    //     byteImage,
    //     size,
    //     form) async {
    var dataAll = [data, form];
    // Navigator.push(context,
    //     MaterialPageRoute(builder: (_) => BtPrint(dataAll, byteImage)));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => RVPreviewShow(title: title, dataAll: dataAll)));
  }

  clearData() {
    _controllerAmount.text = '';
    _controllerDiscount.text = '';
    _controllerNarration.text = '';
    acId = 0;
    // accountId = '';
    // accountName = '';
    ledgerData = null;
    // _dropDownValue = '';
    balance = 0;
    amount = 0;
    discount = 0;
    narration = '';
    ledData!.id = 0;
    ledData!.name = '';
    total = 0;
    setState(() {
      isSelected = false;
      widgetID = true;
      oldVoucher = false;
      isLoadingData = false;
      dataDisplay = [];
      lastRecord = false;
      page = 1;
    });
  }

  void showInSnackBar(String value) {
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  calculate(mode) {
    setState(() {
      total = amount! + discount!;
    });
  }

  var _dropDownValue = '';
  widgetAccount() {
    return Container(
      height: 35,
      padding: const EdgeInsets.only(left: 3),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
          border: Border.all(color: grey),
          borderRadius: BorderRadius.circular(3)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Center(
            child: Text(
              _dropDownValue.isNotEmpty
                  ? _dropDownValue.split('-')[1]
                  : 'Select cash account',
              style: const TextStyle(
              fontFamily: 'poppins', 
              color: black,
              fontSize: 13,
              fontWeight: FontWeight.w500
              ),
            ),
          ),
          items: cashBankACList.map<DropdownMenuItem<String>>((item) {
            return DropdownMenuItem<String>(
              value: "${item.id}-${item.name}",
              child: Text(item.name,
               style: const TextStyle(
              fontFamily: 'poppins', 
              color: black,
              fontSize: 13,
              fontWeight: FontWeight.w500
              ),
              ),
            );
          }).toList(),
          onChanged: (value) {
             if (!keyLockCashAccount) {
          // if (cashId <= 0) {
          setState(() {
            _dropDownValue = value!;
            accountId = value.split('-')[0];
            accountName = value.split('-')[1];
          });
        }
          },
        ),
      ),
    );
  }

  Future _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => formattedDate = DateFormat('dd-MM-yyyy').format(picked));
      userDateCheck(DateUtil.dateYMD(formattedDate));
    }
  }

  String formatDMY(value) {
    var dateTime = DateFormat("dd-mm-yyyy").parse(value.toString());
    return DateFormat("yyyy-mm-dd").format(dateTime);
  }

  previousBill(mode) {
    _getMoreData(mode);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData(mode);
      }
    });

    return dataDisplay.isNotEmpty
        ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(
              height: 5,
            ),
              itemCount: dataDisplay.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == dataDisplay.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Opacity(
                        opacity: isLoadingData ? 1.0 : 00,
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  );
                } else {
                  return 
                  InkWell(
                    onTap: () {
                      showEditDialog(context, dataDisplay[index], mode);
                    },
                    child:
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        // height: 80,
                         constraints: BoxConstraints(
                          maxHeight: 110,
                          minHeight: 80
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 5),
                              blurRadius: 6,
                              color: const Color(0xff000000).withOpacity(0.06),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dataDisplay[index]['Name'],
                                      // maxLines: 1,
                                      style: const TextStyle(
                                        // fontSize: 16,
                                        color: ColorPalette.timberGreen,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Date :${dataDisplay[index]['Date']}',
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: ColorPalette.timberGreen
                                                .withOpacity(0.44),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 5,
                                            top: 2,
                                            right: 5,
                                          ),
                                          child: Icon(
                                            Icons.circle,
                                            size: 5,
                                            color: ColorPalette.timberGreen
                                                .withOpacity(0.44),
                                          ),
                                        ),
                                        Text(
                                          'EntryNo :${dataDisplay[index]['Id'].toString()}',
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: ColorPalette.timberGreen
                                                .withOpacity(0.44),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ColorPalette.nileBlue,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            '${dataDisplay[index]['Total'].toStringAsFixed(decimal)}'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        // ListTile(
                        //   title: Text(dataDisplay[index]['Name']),
                        //   subtitle: Text('Date: ' +
                        //       dataDisplay[index]['Date'] +
                        //       ' / EntryNo : ' +
                        //       dataDisplay[index]['Id'].toString()),
                        //   trailing: Text(
                        //       'Total : ' + dataDisplay[index]['Total'].toString()),
                        //   onTap: () {
                        //     showEditDialog(context, dataDisplay[index]);
                        //   },
                        // ),
                        ),
                  );
                }
              },
              controller: _scrollController,
            ),
        )
        : Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("No data in" + mode,
              style: const TextStyle(fontFamily: 'poppins'),),
              TextButton.icon(
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5))
                    )),
                      backgroundColor: MaterialStatePropertyAll(kPrimaryColor)),
                  onPressed: () {
                    setState(() {
                      widgetID = false;
                    });
                  },
                  icon: const Icon(
                    Icons.shopping_bag,
                    color: white,
                  ),
                  label: Text(
                    'Take New ' + mode,
                    style: const TextStyle(color: white, fontFamily: 'poppins'),
                  ))
            ],
          ));
  }

  showEditDialog(context, dataDynamic, mode) {
    ConfirmAlertBox(
        buttonColorForNo: Colors.red,
        buttonColorForYes: Colors.green,
        icon: Icons.check,
        onPressedNo: () {
          Navigator.of(context).pop();
          // clearData();
        },
        onPressedYes: () {
          Navigator.of(context).pop();
          fetchVoucher(context, dataDynamic, mode);
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage:
            'Do you want to edit or delete\nRefNo:${dataDynamic['Id']}',
        title: 'Update',
        context: context);
  }

  var footerMessage = '';
  fetchVoucher(context, data, mode) {
    double voucherTotal = 0;
    int row = 0;
    api
        .fetchVoucher(data['Id'], mode == 'Payment' ? 'FindPv' : 'FindRv',
            voucherTypeData.id)
        .then((value) {
      if (value != null) {
        var information = value[0][0];
        var particulars = value[1];
        footerMessage = value[2][0]['s_Value'];
        List c = value[1].toList();
        row = c.length;
        formattedDate = DateUtil.dateDMY(information['DDate']);

        dataDynamic = [
          {
            'RealEntryNo': information['EntryNo'],
            'EntryNo': information['EntryNo'],
            'InvoiceNo': information['EntryNo'],
            'Type': '0'
          }
        ];

        voucherTotal = double.tryParse(information['Total'].toString())!;
         _dropDownValue = '${information['LedCode']}-${information['LedName']}';
        accountName = information['LedName'].toString();
        accountId = information['LedCode'].toString();
        acId = information['LedCode'];
        var part1 = particulars[0];
        ledData = LedgerModel(id: part1['LedCode'], name: part1['LedName']);
        amount = double.tryParse(part1['Amount'].toString())!;
        discount = double.tryParse(part1['Discount'].toString())!;
        total = double.tryParse(part1['Total'].toString())!;
        narration = part1['Narration'].toString();
         if (isMultiRvPv) {
          for (var part in particulars) {
            particularList.add(RpVoucherParticularModel(
                id: part['LedCode'],
                name: part['LedName'],
                amount: double.tryParse(part['Amount'].toString())!,
                discount: double.tryParse(part['Discount'].toString())!,
                total: double.tryParse(part['Total'].toString())!,
                narration: part['Narration'].toString(),
                balance: '0',
                phone: ''));
            ledData = LedgerModel(id: 0, name: '');
            isSelected = false;
            //   amount = double.tryParse(part['Amount'].toString());
            //   discount = double.tryParse(part['Discount'].toString());
            //   total = double.tryParse(part['Total'].toString());
            //   narration = part['Narration'].toString();
          }
        } else {
          var part1 = particulars[0];
          ledData = LedgerModel(id: part1['LedCode'], name: part1['LedName']);
          amount = double.tryParse(part1['Amount'].toString());
          discount = double.tryParse(part1['Discount'].toString());
          total = double.tryParse(part1['Total'].toString());
          narration = part1['Narration'].toString();
        }
        if (isMultiRvPv) {
          // particularList
        } else {
          getOldBalance(
              ledData!.id,
              (mode == 'Payment' ? 'SupplierOB' : 'CustomerOB'),
              mode,
              DateUtil.dateYMD(formattedDate),
              information['EntryNo']);
        }

        userDateCheck(information['DDate']);
        setState(() {
          if (row > 0) {
            widgetID = false;
            oldVoucher = true;
            isSelected = true;
            _controllerAmount.text = amount.toString();
            _controllerDiscount.text = discount! > 0 ? discount.toString() : '';
            _controllerNarration.text = narration.toString();
          }else {
            ledData = LedgerModel(id: 0, name: '');
            widgetID = false;
            oldVoucher = true;
            isSelected = true;
            _controllerAmount.text = '';
            _controllerDiscount.text = '';
            _controllerNarration.text = '';
          }
        });
      }
    });
  }

  static const platform = MethodChannel('sherAccChannel');

  Future<void> sendSms(number, msg) async {
    debugPrint("SendSMS");
    try {
      final String result = await platform.invokeMethod(
          'sendSMS', <String, dynamic>{"phone": number, "msg": msg});
      debugPrint(result);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    } on PlatformException catch (e, s) {
      debugPrint(e.toString());
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: 'sent SMS:' + number.toString());
    }
  }

  voucherWidget(var mode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // const Text(
              //   'Date : ',
              //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              // ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(' Date',
                     style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      fontFamily: 'poppins'),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    InkWell(
                          child: Container(
                            // margin: EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            // width: 140,
                            height: 35,
                            decoration: BoxDecoration(
                                border: Border.all(color: grey),
                                borderRadius: BorderRadius.circular(3)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedDate!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      fontFamily: 'poppins'),
                                ),
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 20,
                                  color: grey,
                                )
                              ],
                            ),
                          ),
                          onTap: () => _selectDate(),
                        ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 2,
                // width: 200,
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(' Cash Account',
                      style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      fontFamily: 'poppins'),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    widgetAccount(),
                  ],
                )
              )
            ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     const Text('Cash Account',
          //         style: TextStyle(fontWeight: FontWeight.bold)),
          //     widgetAccount(),
          //   ],
          // ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 3,
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              onPressed: () {
                var under = mode == 'Payment' ? 'SUPPLIERS' : 'CUSTOMERS';
                Navigator.pushNamed(context, '/ledger',
                    arguments: {'parent': under});
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: white,
                  ),
                  Text(
                    'Add New Ledger',
                    style: TextStyle(
                        fontFamily: 'poppins', color: white, fontSize: 16),
                  )
                ],
              )),
          // Card(
          //   elevation: 5,
          //   color: kPrimaryColor,

          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       TextButton(
          //         onPressed: () {
          //           var under = mode == 'Payment' ? 'SUPPLIERS' : 'CUSTOMERS';
          //           Navigator.pushNamed(context, '/ledger',
          //               arguments: {'parent': under});
          //         },
          //         child: const Text('Add new ledger'),
          //       ),
          //       IconButton(
          //         icon: const Icon(
          //           Icons.add_circle,
          //           color: kPrimaryColor,
          //         ),
          //         onPressed: () {
          //           var under = mode == 'Payment' ? 'SUPPLIERS' : 'CUSTOMERS';
          //           Navigator.pushNamed(context, '/ledger',
          //               arguments: {'parent': under});
          //         },
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(
            height: 10,
          ),
          
          ContainerFieldWidget(
              widget: DropdownSearch<LedgerModel>(
                popupProps: const PopupPropsMultiSelection.dialog(
                    showSearchBox: true,
                    isFilterOnline: true,
                    
                    // constraints: BoxConstraints(
                    //   maxHeight: 300,
                    // )
                    ),
                asyncItems: (String filter) async {
                  nameLike = filter.isNotEmpty ? filter : 'a';
                  var models = isSalesManWiseLedger
                ? api.getLedgerBySalesManLike(salesManId, nameLike)
                : api.getCustomerNameListLike(
                    groupId, areaId, routeId, salesManId, nameLike);
                  return models;
                },
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 5
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                onChanged: (LedgerModel? data) {
                  // print(data);
                  ledData = data;
                  setState(() {
                    isSelected = true;
                  });
                },
                selectedItem: ledData,
              ),
              headTxt: 'Select Ledger Name'),
          const SizedBox(
            height: 8,
          ),
          isSelected && ledData!.id > 0
              ? ledgerDetailWidget(ledData!.id)
              : const Text(
                  'Balance : 0',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      fontFamily: 'poppins',
                      color: kPrimaryColor),
                ),
          const SizedBox(
            height: 8,
          ),
          ContainerFieldWidget(
              widget: TextField(
                controller: _controllerAmount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp(r'[0-9]'),
                      allow: true, replacementString: '.')
                ],
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    amount = (value != null
                        ? value.trim().isNotEmpty
                            ? double.tryParse(value)
                            : 0
                        : 0)!;
                    calculate(mode);
                  });
                },
              ),
              headTxt: 'Ammount'),
          const SizedBox(
            height: 4,
          ),
          ContainerFieldWidget(
              widget: TextField(
                controller: _controllerDiscount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp(r'[0-9]'),
                      allow: true, replacementString: '.')
                ],
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    discount = (value != null
                        ? value.trim().isNotEmpty
                            ? double.tryParse(value)
                            : 0
                        : 0)!;
                    calculate(mode);
                  });
                },
              ),
              headTxt: 'Discount'),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Total : ${total!.toStringAsFixed(0)}',
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                fontFamily: 'poppins',
                color: kPrimaryColor),
          ),
          const SizedBox(
            height: 8,
          ),
          ContainerFieldWidget(
              widget: TextField(
                controller: _controllerNarration,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    narration = value;
                  });
                },
              ),
              headTxt: 'Narration')
          // const Divider(),
        ],
      ),
    );
  }

  // voucherParticularWidget(mode) {
  //   return const Center(
  //     child: Text('Coming soon'),
  //   );
  // }
   voucherParticularWidget(mode) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              'Date : ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            InkWell(
              child: Text(
                formattedDate!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              onTap: () => _selectDate(),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Cash Account',
                style: TextStyle(fontWeight: FontWeight.bold)),
            widgetAccount(),
          ],
        ),
        Card(
          elevation: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  var under = mode == 'Payment' ? 'SUPPLIERS' : 'CUSTOMERS';
                  Navigator.pushNamed(context, '/ledger',
                      arguments: {'parent': under});
                },
                child: const Text('Add new ledger'),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: kPrimaryColor,
                ),
                onPressed: () {
                  var under = mode == 'Payment' ? 'SUPPLIERS' : 'CUSTOMERS';
                  Navigator.pushNamed(context, '/ledger',
                      arguments: {'parent': under});
                },
              ),
            ],
          ),
        ),
        const Divider(),
        DropdownSearch<LedgerModel>(
          // onFind: (String filter) async {
          //   nameLike = filter.isNotEmpty ? filter : 'a';
          //   var models = isSalesManWiseLedger
          //       ? api.getLedgerBySalesManLike(salesManId, nameLike)
          //       : api.getCustomerNameListLike(
          //           groupId, areaId, routeId, salesManId, nameLike);
          //   return models;
          // },
          onChanged: (LedgerModel? data) {
            // print(data);
            ledData = data;
            setState(() {
              isSelected = true;
            });
          },
          selectedItem: ledData,
          popupProps: const PopupPropsMultiSelection.modalBottomSheet(
              showSearchBox: true,
              isFilterOnline: true,
              constraints: BoxConstraints(
                maxHeight: 300,
              )),
          asyncItems: (String filter) async {
            nameLike = filter.isNotEmpty ? filter : 'a';
            var models = isSalesManWiseLedger
                ? api.getLedgerBySalesManLike(salesManId, nameLike)
                : api.getCustomerNameListLike(
                    groupId, areaId, routeId, salesManId, nameLike);
            return models;
          },
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
                border: OutlineInputBorder(), labelText: "Select Ledger Name"),
          ),
        ),
        const Divider(),
        isSelected && ledData!.id > 0
            ? ledgerDetailWidget(ledData!.id)
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                      child: Text(
                    'Balance : 0',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
              ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                controller: _controllerAmount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp(r'[0-9]'),
                      allow: true, replacementString: '.')
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Amount'),
                ),
                onChanged: (value) {
                  setState(() {
                    amount = value != null
                        ? value.trim().isNotEmpty
                            ? double.tryParse(value)
                            : 0
                        : 0;
                    calculate(mode);
                  });
                },
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextField(
                controller: _controllerDiscount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp(r'[0-9]'),
                      allow: true, replacementString: '.')
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Discount'),
                ),
                onChanged: (value) {
                  setState(() {
                    discount = value != null
                        ? value.trim().isNotEmpty
                            ? double.tryParse(value)
                            : 0
                        : 0;
                    calculate(mode);
                  });
                },
              ),
            ),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                controller: _controllerNarration,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Narration'),
                ),
                onChanged: (value) {
                  setState(() {
                    narration = value;
                  });
                },
              ),
            ),
          ],
        ),
        ElevatedButton(
            onPressed: () {
              if (ledData!.id.toString().trim().isNotEmpty &&
                  ledData!.name.trim().isNotEmpty) {
                setState(() {
                  particularList.add(RpVoucherParticularModel(
                      id: ledData!.id,
                      name: ledData!.name,
                      amount: amount!,
                      discount: discount!,
                      total: amount! + discount!,
                      narration: narration!,
                      balance:
                          isSelected ? ledgerData!.balance.toString() : '0',
                      phone: isSelected ? ledgerData!.phone.toString() : ''));

                  _controllerAmount.text = '';
                  _controllerDiscount.text = '';
                  _controllerNarration.text = '';
                  ledgerData = null;
                  balance = 0;
                  amount = 0;
                  discount = 0;
                  narration = '';
                  ledData!.id = 0;
                  ledData!.name = '';
                  total = 0;
                });
              }
            },
            child: const Text('Add')),
        const Divider(),
        ListView.builder(
          itemCount: particularList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            RpVoucherParticularModel data = particularList[index];
            return Card(
              elevation: 10,
              child: ListTile(
                title: Text(data.name),
                subtitle: Text(
                    'Amount: ${data.amount} Disc: ${data.discount} Total :${data.total}'),
                trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        if (companyUserData!.deleteData) {
                          particularList.removeAt(index);
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: red,
                    )),
              ),
            );
          },
        ),
      ],
    );
  }
}
