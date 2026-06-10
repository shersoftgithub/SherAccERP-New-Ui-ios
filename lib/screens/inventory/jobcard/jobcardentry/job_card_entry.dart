import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/cart_item.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/customer_model.dart';
import 'package:sheraccerp/models/ledger_name_model.dart';
import 'package:sheraccerp/models/option_rate_type.dart';
import 'package:sheraccerp/models/order.dart';
import 'package:sheraccerp/models/sales_model.dart';
import 'package:sheraccerp/models/sales_type.dart';
import 'package:sheraccerp/models/stock_item.dart';
import 'package:sheraccerp/models/stock_product.dart';
import 'package:sheraccerp/models/unit_model.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/screens/inventory/sales/previous_bill.dart';
import 'package:sheraccerp/screens/inventory/sales/salesNot.dart';
import 'package:sheraccerp/screens/inventory/sales/sales_return.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/service/com_service.dart';
import 'package:sheraccerp/service/generate_e_invoice.dart';
import 'package:sheraccerp/service/generate_e_way_bill.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/color_palette.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/dbhelper.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/loading.dart';
import 'package:sheraccerp/widget/product_search.dart';
import 'package:sheraccerp/widget/progress_hud.dart';
import 'package:image_picker/image_picker.dart';

class Jobcardentry extends StatefulWidget {
  const Jobcardentry({super.key});

  @override
  State<Jobcardentry> createState() => _JobcardentryState();
}

class _JobcardentryState extends State<Jobcardentry> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _resetKey = GlobalKey<FormState>();
  bool isVariantSelected = false,
      _isLoading = false,
      buttonEvent = false,
      isSerialNoInStockVariant = false;
  // final bool _autoVariantSelect = true;
  DioService api = DioService();
  Size? deviceSize;
  var ledgerModel;
  String? _selectedStatus;
  StockItem? productModel;
  List<CartJobCartItem> cartItem = [];
  bool valueMore = false,
      lastRecord = false,
      widgetID = true,
      previewData = false,
      oldBill = false,
      itemStockAll = false;

  final List<TextEditingController> _controllers = [];
  DateTime now = DateTime.now();
  String? formattedDate;
  String? _formattedDate;
  String? _formattedDeliveryDate;
  String? _formattedjobcarddate;
  String? formattedDeliveryDatee;
  double _balance = 0, grandTotal = 0;
  final TextEditingController controllerCashReceived = TextEditingController();
  final TextEditingController controllerNarration = TextEditingController();
  final TextEditingController controllerDamageorScratch =
      TextEditingController();
  final TextEditingController controllerEstimate = TextEditingController();
  final FocusNode _focusNodeCashReceived = FocusNode();

  int page = 1, pageTotal = 0, totalRecords = 0;
  int saleAccount = 0, acId = 0, decimal = 2;
  List<dynamic> ledgerDisplay = [];
  List<dynamic> _ledger = [];
  List<dynamic> itemDisplay = [];
  List<dynamic> items = [];
  List<LedgerModel> cashBankACList = [];
  List<SerialNOModel> serialNoData = [];
  int lId = 0, groupId = 0, areaId = 0, routeId = 0;
  var salesManId = 0;
  String labelSerialNo = 'SerialNo';
  String labelSpRate = 'SpRetail';
  bool ledgerScanner = false, productScanner = false, loadScanner = false;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final dbHelper = DatabaseHelper.instance;
  OptionRateType? rateTypeItem;
  List<String> _enteredComplaints = [];
  @override
  void initState() {
    super.initState();
    formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);
    _formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);
    _formattedDeliveryDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);
    _formattedjobcarddate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);

    loadSettings(context);

    salesManId = ComSettings.appSettings(
            'int', 'key-dropdown-default-salesman-view', 1) ??
        0 - 1;
    lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) ??
        0 - 1;

    groupId =
        ComSettings.appSettings('int', 'key-dropdown-default-group-view', 0) ??
            0 - 1;
    areaId =
        ComSettings.appSettings('int', 'key-dropdown-default-area-view', 0) ??
            0 - 1;
    routeId =
        ComSettings.appSettings('int', 'key-dropdown-default-route-view', 0) ??
            0 - 1;

    saleAccount = mainAccount.firstWhere(
        (element) => element['LedName'] == 'GENERAL SALES A/C')['LedCode'];

    ledgerScanner =
        ComSettings.appSettings('bool', 'key-customer-scan', false) ?? false;

    itemStockAll =
        ComSettings.appSettings('bool', 'key-item-stock-all', false) ?? false;

    api.getLedgerListByType('SelectbankOnly').then((value) {
      List<LedgerModel> _dataTemp = [];
      for (var ledger in value) {
        _dataTemp
            .add(LedgerModel(id: ledger['ledcode'], name: ledger['LedName']));
      }
      setState(() {
        cashBankACList.addAll(_dataTemp);
      });
    });
  }

  List otherAmountList = [];
  CompanyInformation? companySettings;
  List<CompanySettings>? settings;
  List rateTypeList = [];
  loadSettings(context) {
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();

    String cashAc =
        ComSettings.getValue('CASH A/C', settings!).toString().trim() ?? 'CASH';
    try {
      acId = mainAccount
          .firstWhere((element) => element['LedName'] == cashAc)['LedCode'];
      acId = ComSettings.appSettings('int', 'key-dropdown-default-cash-ac', 0) -
                  1 >
              acId
          ? ComSettings.appSettings(
                  'int', 'key-dropdown-default-cash-ac', acId) -
              1
          : acId;
    } catch (e) {
      e.toString();
      acId = -1;
    }
    taxMethod = companySettings!.taxCalculation!;
    enableMULTIUNIT = ComSettings.getStatus('ENABLE MULTI-UNIT', settings!);
    pRateBasedProfitInSales =
        ComSettings.getStatus('PRATE BASED PROFIT IN SALES', settings!);
    negativeStock = ComSettings.getStatus('ALLOW NEGETIVE STOCK', settings!);
    companyTaxMode = ComSettings.getValue('PACKAGE', settings!);
    cessOnNetAmount = ComSettings.getStatus('CESS ON NET AMOUNT', settings!);

    enableKeralaFloodCess = false;

    useUniqueCodeAsBarcode =
        ComSettings.getStatus('USE UNIQUECODE AS BARCODE', settings!);
    useOldBarcode = ComSettings.getStatus('USE OLD BARCODE', settings!);
    decimal = (ComSettings.getValue('DECIMAL', settings!).toString().isNotEmpty
        ? int.tryParse(ComSettings.getValue('DECIMAL', settings!).toString())
        : 2)!;

    labelSerialNo =
        ComSettings.getValue('KEY ITEM SERIAL NO', settings!).toString();
    labelSpRate =
        ComSettings.getValue('KEY ITEM SP RATE TITLE', settings!).toString();
    labelSerialNo = labelSerialNo.isEmpty ? 'Remark' : labelSerialNo;
    labelSpRate = labelSpRate.isEmpty ? 'SpRetail' : labelSpRate;
  }

  bool enableMULTIUNIT = false,
      pRateBasedProfitInSales = false,
      negativeStock = false,
      cessOnNetAmount = false,
      negativeStockStatus = false,
      enableKeralaFloodCess = false,
      useUniqueCodeAsBarcode = false,
      useOldBarcode = false,
      isMinimumRatedLock = false;

  final ScrollController _scrollController = ScrollController();
  bool isLoadingData = false;
  List dataDisplay = [];
  @override
  void dispose() {
    _scrollController.dispose();
    _quantityController.dispose();
    if (controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }

  static const platform = MethodChannel('sherAccChannel');
  Future<void> sendSms(number, msg) async {
    debugPrint("SendSMS");
    try {
      final String result = await platform.invokeMethod(
          'sendSMS', <String, dynamic>{"phone": number, "msg": msg});
      debugPrint(result);
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  void _insert(name, status) async {
    /***Test Data***/
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnstatus: status
    };
    Carts car = Carts.fromMap(row);
    final id = await dbHelper.insert(car);
  }

  showMore(context, bool newBill) {
    ConfirmAlertBox(
        buttonColorForNo: Colors.red,
        buttonColorForYes: Colors.green,
        icon: Icons.check,
        onPressedNo: () {
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(
              context,'/sales',
              arguments: {'default': ''});
        },
        onPressedYes: () {
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, '/preview_show',
              arguments: {'title': 'Sale'});
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage:
            'Do you want to Preview\nEntryNo : ${dataDynamic[0]['EntryNo']}',
        title: newBill ? 'SAVED' : 'EDITED',
        context: context);
  }

  showErrorDialog(context, String msg) {
    debugPrint('error save sales :$msg');
    setState(() {
      _isLoading = false;
      buttonEvent = false;
    });
    SimpleAlertBox(
      context: context,
      title: 'Error',
      buttonText: 'Close',
      infoMessage: msg,
    );
  }

  void _getMoreData() async {
    if (!lastRecord) {
      if (dataDisplay.isEmpty ||
          // ignore: curly_braces_in_flow_control_structures
          dataDisplay.length < totalRecords) if (!isLoadingData) {
        setState(() {
          isLoadingData = true;
        });

        List tempList = [];
        var statement = 'JobCardList';
        var locationId =
            lId.toString().trim().isNotEmpty ? lId : salesTypeData!.location;

        api
            .getPaginationList(
                statement,
                page,
                locationId.toString(),
                '0',
                DateUtil.dateYMD(formattedDate),
                salesManId > 0 ? salesManId.toString() : '')
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

          if (mounted) {
            setState(() {
              isLoadingData = false;
              dataDisplay.addAll(tempList);
              lastRecord = tempList.isNotEmpty ? false : true;
            });
          }
        });
      }
    }
  }

  previousBill() {
    _getMoreData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });

    return dataDisplay.isNotEmpty
        ? ListView.builder(
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
                return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    height: 80,
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 5),
                          blurRadius: 6,
                          color: const Color(0xff000000).withOpacity(0.06),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dataDisplay[index]['Name'],
                                  // maxLines: 1,
                                  style: const TextStyle(
                                    // fontFamily: "Nunito",
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
                                        // fontFamily: "Nunito",
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
                                        // fontFamily: "Nunito",
                                        fontSize: 12,
                                        color: ColorPalette.timberGreen
                                            .withOpacity(0.44),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              showEditDialog(context, dataDisplay[index]);
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    // fontFamily: "Nunito",
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
                            onTap: () {},
                          ),
                        ),
                      ],
                    ));
              }
            },
            controller: _scrollController,
          )
        : Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "No items in JobCard",
                style: TextStyle(fontFamily: 'poppins'),
              ),
              TextButton.icon(
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(kPrimaryColor),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () {
                    setState(() {
                      widgetID = false;
                    });
                  },
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Take New JobCard'))
            ],
          ));
  }

  bool _warrantyIssued = false;
  bool _callregister = false;
  bool _sim = false;
  bool _mmc = false;
  bool _charger = false;
  bool _dataCable = false;
  bool _battery = false;
  bool _pouch = false;
  bool _other = false;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _serialNoController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();

  String expDate = '2000-01-01';
  int _dropDownUnit = 0, fUnitId = 0, uniqueCode = 0, barcode = 0;

  List<UnitModel> unitListData = [];
  int get totalItem => cartItem.length;

  expandStyle(int flex, Widget child) => Expanded(flex: flex, child: child);
  @override
  Widget build(BuildContext context) {
    _quantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: _quantityController.text.length));
    deviceSize = MediaQuery.of(context).size;

    return WillPopScope(
        onWillPop: _onWillPop,
        child: widgetID ? widgetPrefix() : widgetSuffix());
  }

  Future<bool> _onWillPop() async {
    if (nextWidget == 3) {
      var result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Back'),
          content: const Text('Select Item Again?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  nextWidget = 2;
                  clearValue();
                });
                Navigator.of(context).pop(false);
              },
              child: const Text('Select'),
            ),
          ],
        ),
      );
      return await result ?? false;
    } else {
      var result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to exit Sale'),
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
      );
      return result ?? false;
    }
  }

  widgetSuffix() {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text(
            "Job Card Entry",
            style: TextStyle(fontSize: 16, fontFamily: 'poppins',
            color: white,
            ),
          ),
          actions: [
            Visibility(
              visible: oldBill,
              child: IconButton(
                  color: red,
                  iconSize: 40,
                  onPressed: () {
                    if (buttonEvent) {
                      return;
                    } else {
                      if (companyUserData!.deleteData) {
                        if (totalItem > 0) {
                          setState(() {
                            _isLoading = true;
                            buttonEvent = true;
                          });
                          _insert(
                              'Delete DateTime:$formattedDate $timeIs location:${lId.toString()} ledger:${ledgerModel.id} ${CartItem.encodeCartToJson(cartItem.cast<CartItem>())}',
                              0);
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Please select atleast one bill');
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
                  icon: const Icon(Icons.delete_forever)),
            ),
            oldBill
                ? IconButton(
                    color: green,
                    iconSize: 40,
                    onPressed: () {
                      if (buttonEvent) {
                        return;
                      } else {
                        if (companyUserData!.updateData) {
                          if (totalItem > 0) {
                            setState(() {
                              _isLoading = true;
                              buttonEvent = true;
                            });
                            _insert(
                                'Edit DateTime:$formattedDate $timeIs location:${lId.toString()} ledger:${ledgerModel.id} ${CartItem.encodeCartToJson(cartItem.cast<CartItem>())}',
                                0);
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please select atleast one bill');
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
                    icon: const Icon(Icons.edit))
                : IconButton(
                    color: white,
                    iconSize: 40,
                    onPressed: () {
                      if (buttonEvent) {
                        return;
                      } else {
                        if (companyUserData!.insertData) {
                          if (totalItem > 0) {
                            setState(() {
                              _isLoading = true;
                              buttonEvent = true;
                            });
                            _insert(
                                'SAVE DateTime:$formattedDate $timeIs location:${lId.toString()} ledger:${ledgerModel.id} ${CartItem.encodeCartToJson(cartItem.cast<CartItem>())}',
                                0);
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please add at least one item');
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
                    icon: const Icon(Icons.save)),
          ],
        ),
        body: ProgressHUD(
            inAsyncCall: _isLoading, opacity: 0.0, child: selectWidget()));
  }

  widgetPrefix() {
    setState(() {
      previewData = true;
    });
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Job Card Entry",
            style: TextStyle(fontSize: 16, fontFamily: 'poppins',
            color: white,
            ),
          ),
          actions: [
            Visibility(
              visible: previewData,
              child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[700],
                  ),
                  onPressed: () async {
                    setState(() {
                      widgetID = false;
                    });
                  },
                  child: Text(
                    previewData ? "New Job Card" : 'Job Card',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
            ),
          ],
        ),
        body: previewData
            ? Container(
                child: previousBill(),
              )
            : selectLedgerWidget());
  }

  var nameLike = "a";
  selectLedgerWidget() {
    previewData = true;
    groupId = 0;
    areaId = 0;
    routeId = 0;

    return FutureBuilder<List<dynamic>>(
      future: api.getCustomerNameListLike(
          groupId, areaId, routeId, salesManId, nameLike),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            return ListView.builder(
              // shrinkWrap: true,
              itemBuilder: (context, index) {
                return index == 0
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Visibility(
                                visible: ledgerScanner,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.qr_code,
                                    color: kPrimaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      loadScanner = true;
                                    });
                                  },
                                )),
                            Flexible(
                              child: TextField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  label: Text('Search...'),
                                ),
                                onChanged: (text) {
                                  text = text.toLowerCase();
                                  setState(() {
                                    // ledgerDisplay = _ledger.where((item) {
                                    //   var itemName = item.name.toLowerCase();
                                    // return itemName.contains(text);
                                    // }).toList();
                                    nameLike = text.isNotEmpty ? text : 'a';
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: kPrimaryColor,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/ledger',
                                    arguments: {'parent': 'CUSTOMERS'});
                              },
                            )
                          ],
                        ),
                      )
                    : InkWell(
                        child: Card(
                          child: ListTile(title: Text(data[index - 1].name)),
                        ),
                        onTap: () {
                          setState(() {
                            ledgerModel = data[index - 1];
                            nextWidget = 1;
                            isData = false;
                          });
                        },
                      );
              },
              itemCount: data!.length + 1,
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text('No Data Found..'),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          nameLike = nameLike.substring(0, nameLike.length - 1);
                          // nextWidget = nextWidget;
                        });
                      },
                      child: const Text('Select Again'))
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          return AlertDialog(
            title: const Text(
              'An Error Occurred!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.redAccent,
              ),
            ),
            content: Text(
              "${snapshot.error}",
              style: const TextStyle(
                color: Colors.blueAccent,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('This may take some time..')
            ],
          ),
        );
      },
    );
  }

  int nextWidget = 0;
  bool isData = false;
  selectWidget() {
    return nextWidget == 0
        ? selectLedgerWidget()
        : nextWidget == 1
            ? selectLedgerDetailWidget()
            : nextWidget == 2
                ? selectProductWidget()
                : nextWidget == 3
                    ? itemDetailWidget(productModel!)
                    : nextWidget == 4
                        ? cartProduct()
                        : nextWidget == 5
                            ? const Text('No Data 5')
                            : nextWidget == 6
                                ? const Text('No Data 6')
                                : const Text('No Widget');
  }

  String customerName = '';
  bool customerReusableProduct =
      ComSettings.appSettings('bool', 'key-customer-reusable-product', false) ??
              false
          ? true
          : false;
  selectLedgerDetailWidget() {
    return FutureBuilder<CustomerModel>(
      future: customerReusableProduct
          ? api.getCustomerDetailStock(ledgerModel.id)
          : api.getCustomerDetail(ledgerModel.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.id != null || snapshot.data!.id! > 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(35, 35, 35, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Name',
                      style:
                          TextStyle(color: blue, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      child:
                          Text(snapshot.data!.name!, style: const TextStyle()),
                      onTap: () {
                        setState(() {
                          nextWidget = 0;
                          nameLike = 'a';
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Address',
                      style:
                          TextStyle(color: blue, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                        "${snapshot.data!.address1!}\n${snapshot.data!.address2!}\n${snapshot.data!.address3!}\n${snapshot.data!.address4!}",
                        style: const TextStyle()),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Phone',
                      style:
                          TextStyle(color: blue, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      child:
                          Text(snapshot.data!.phone!, style: const TextStyle()),
                      onDoubleTap: () => callNumber(snapshot.data!.phone),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              ' Warrenty Issued',
                              style: TextStyle(
                                  color: blue, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 160,
                              child: Card(
                                child: Row(
                                  children: [
                                    Radio(
                                      value: true,
                                      groupValue: _warrantyIssued,
                                      onChanged: (value) {
                                        setState(() {
                                          _warrantyIssued = value!;
                                        });
                                      },
                                    ),
                                    const Text('Yes'),
                                    Radio(
                                      value: false,
                                      groupValue: _warrantyIssued,
                                      onChanged: (value) {
                                        setState(() {
                                          _warrantyIssued = value!;
                                        });
                                      },
                                    ),
                                    const Text('No'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '  Call register',
                              style: TextStyle(
                                  color: blue, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 160,
                              child: Card(
                                child: Row(
                                  children: [
                                    Radio(
                                      value: true,
                                      groupValue: _callregister,
                                      onChanged: (value) {
                                        setState(() {
                                          _callregister = value!;
                                        });
                                      },
                                    ),
                                    const Text('Yes'),
                                    Radio(
                                      value: false,
                                      groupValue: _callregister,
                                      onChanged: (value) {
                                        setState(() {
                                          _callregister = value!;
                                        });
                                      },
                                    ),
                                    const Text('No'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                  color: blue, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              child: Text(
                                _formattedDate!,
                                style: const TextStyle(),
                              ),
                              onTap: () => _selectDatee(),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delivery Date',
                              style: TextStyle(
                                  color: blue, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              child: Text(
                                _formattedDeliveryDate!,
                                style: const TextStyle(),
                              ),
                              onTap: () => _selectDeliveryDate(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Service Engineer',
                      style:
                          TextStyle(color: blue, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Anil',
                      style: TextStyle(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Location',
                      style:
                          TextStyle(color: blue, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'SHOP',
                      style: TextStyle(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Job Taken By',
                      style:
                          TextStyle(color: blue, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Anil',
                      style: TextStyle(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _sim,
                                onChanged: (value) {
                                  setState(() {
                                    _sim = value!;
                                  });
                                },
                              ),
                              const Text('SIM'),
                              const SizedBox(
                                width: 45,
                              ),
                              Checkbox(
                                value: _mmc,
                                onChanged: (value) {
                                  setState(() {
                                    _mmc = value!;
                                  });
                                },
                              ),
                              const Text('MMC'),
                              const SizedBox(
                                width: 12,
                              ),
                              Checkbox(
                                value: _charger,
                                onChanged: (value) {
                                  setState(() {
                                    _charger = value!;
                                  });
                                },
                              ),
                              const Text('Charger'),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _dataCable,
                                onChanged: (value) {
                                  setState(() {
                                    _dataCable = value!;
                                  });
                                },
                              ),
                              const Text('Data Cable'),
                              Checkbox(
                                value: _battery,
                                onChanged: (value) {
                                  setState(() {
                                    _battery = value!;
                                  });
                                },
                              ),
                              const Text('Battery'),
                              Checkbox(
                                value: _pouch,
                                onChanged: (value) {
                                  setState(() {
                                    _pouch = value!;
                                  });
                                },
                              ),
                              const Text('Pouch'),
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _other,
                                onChanged: (value) {
                                  setState(() {
                                    _other = value!;
                                  });
                                },
                              ),
                              const Text('Other'),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Passcode",
                                  style: TextStyle(
                                      color: blue, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 6,
                                                    horizontal: 15),
                                            border: OutlineInputBorder()),
                                      ),
                                    ),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Container(
                                          height: 45,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade300),
                                          child: const Icon(Icons.apps)),
                                    ))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        // showDialog(
                        //   context: context,
                        //   builder: (BuildContext context) {
                        //     return AlertDialog(
                        //       title: const Text(
                        //         "Upload Photos",
                        //         style: TextStyle(fontSize: 15),
                        //       ),
                        //       content:
                        // Container(
                        //         width: MediaQuery.of(context).size.width,
                        //         child: Column(
                        //           mainAxisSize: MainAxisSize.min,
                        //           children: [
                        //             Row(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 InkWell(
                        //                   onTap: () {
                        //                     _pickImage1(ImageSource
                        //                         .gallery); // Change to ImageSource.camera for camera access
                        //                   },
                        //                   child: _imageFile1 != null
                        //                       ? Container(
                        //                           width: 80,
                        //                           child: Image.file(
                        //                             _imageFile1!,
                        //                             fit: BoxFit.cover,

                        //                           ),
                        //                         )
                        //                       : Container(
                        //                           width: 80,
                        //                           decoration: BoxDecoration(
                        //                               border: Border.all()),
                        //                           child: const Column(
                        //                             mainAxisAlignment:
                        //                                 MainAxisAlignment
                        //                                     .center,
                        //                             crossAxisAlignment:
                        //                                 CrossAxisAlignment
                        //                                     .center,
                        //                             children: [
                        //                               Icon(
                        //                                 Icons
                        //                                     .camera_alt_outlined,
                        //                                 size: 50,
                        //                               ),
                        //                               Center(
                        //                                   child: Text(
                        //                                 "NO IMAGE \nAVAILABLE",
                        //                                 style: TextStyle(
                        //                                     fontSize: 8),
                        //                               ))
                        //                             ],
                        //                           ),
                        //                         ),
                        //                 ),
                        //                 InkWell(onTap: () {
                        //                      _pickImage2(ImageSource
                        //                         .gallery); // Change to ImageSource.camera for camera access
                        //                 },
                        //                   child:_imageFile2 != null
                        //                       ? Container(
                        //                           width: 80,
                        //                           child: Image.file(
                        //                             _imageFile2!,
                        //                             fit: BoxFit.cover,

                        //                           ),
                        //                         ):

                        //                    Container(
                        //                     width: 80,
                        //                     decoration: BoxDecoration(
                        //                         border: Border.all()),
                        //                     child: const Column(
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment.center,
                        //                       crossAxisAlignment:
                        //                           CrossAxisAlignment.center,
                        //                       children: [
                        //                         Icon(
                        //                           Icons.camera_alt_outlined,
                        //                           size: 50,
                        //                         ),
                        //                         Center(
                        //                             child: Text(
                        //                           "NO IMAGE \nAVAILABLE",
                        //                           style: TextStyle(fontSize: 8),
                        //                         ))
                        //                       ],
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 InkWell(  onTap: () {
                        //                     _pickImage3(ImageSource
                        //                         .gallery); },// Change to ImageSource.camera for camera access
                        //                   child: _imageFile3 != null
                        //                       ? Container(
                        //                           width: 80,
                        //                           child: Image.file(
                        //                             _imageFile3!,
                        //                             fit: BoxFit.cover,

                        //                           ),
                        //                         ):

                        //                   Container(
                        //                     width: 80,
                        //                     decoration: BoxDecoration(
                        //                         border: Border.all()),
                        //                     child: const Column(
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment.center,
                        //                       crossAxisAlignment:
                        //                           CrossAxisAlignment.center,
                        //                       children: [
                        //                         Icon(
                        //                           Icons.camera_alt_outlined,
                        //                           size: 50,
                        //                         ),
                        //                         Center(
                        //                             child: Text(
                        //                           "NO IMAGE \nAVAILABLE",
                        //                           style: TextStyle(fontSize: 8),
                        //                         ))
                        //                       ],
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //             SizedBox(
                        //               height: 10,
                        //             ),
                        //             Row(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 InkWell( onTap: () {
                        //                     _pickImage4(ImageSource
                        //                         .gallery); },// Change to ImageSource.camera for camera access
                        //                   child: _imageFile4 != null
                        //                       ? Container(
                        //                           width: 80,
                        //                           child: Image.file(
                        //                             _imageFile4!,
                        //                             fit: BoxFit.cover,

                        //                           ),
                        //                         ):
                        //                   Container(
                        //                     width: 80,
                        //                     decoration: BoxDecoration(
                        //                         border: Border.all()),
                        //                     child: const Column(
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment.center,
                        //                       crossAxisAlignment:
                        //                           CrossAxisAlignment.center,
                        //                       children: [
                        //                         Icon(
                        //                           Icons.camera_alt_outlined,
                        //                           size: 50,
                        //                         ),
                        //                         Center(
                        //                             child: Text(
                        //                           "NO IMAGE \nAVAILABLE",
                        //                           style: TextStyle(fontSize: 8),
                        //                         ))
                        //                       ],
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 InkWell( onTap: () {
                        //                     _pickImage5(ImageSource
                        //                         .gallery); },// Change to ImageSource.camera for camera access
                        //                   child: _imageFile5 != null
                        //                       ? Container(
                        //                           width: 80,
                        //                           child: Image.file(
                        //                             _imageFile5!,
                        //                             fit: BoxFit.cover,

                        //                           ),
                        //                         ):
                        //                   Container(
                        //                     width: 80,
                        //                     decoration: BoxDecoration(
                        //                         border: Border.all()),
                        //                     child: const Column(
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment.center,
                        //                       crossAxisAlignment:
                        //                           CrossAxisAlignment.center,
                        //                       children: [
                        //                         Icon(
                        //                           Icons.camera_alt_outlined,
                        //                           size: 50,
                        //                         ),
                        //                         Center(
                        //                             child: Text(
                        //                           "NO IMAGE \nAVAILABLE",
                        //                           style: TextStyle(fontSize: 8),
                        //                         ))
                        //                       ],
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 InkWell( onTap: () {
                        //                     _pickImage6(ImageSource
                        //                         .gallery); },// Change to ImageSource.camera for camera access
                        //                   child:_imageFile6 != null
                        //                       ? Container(
                        //                           width: 80,
                        //                           child: Image.file(
                        //                             _imageFile6!,
                        //                             fit: BoxFit.cover,

                        //                           ),
                        //                         ):
                        //                    Container(
                        //                     width: 80,
                        //                     decoration: BoxDecoration(
                        //                         border: Border.all()),
                        //                     child: const Column(
                        //                       mainAxisAlignment:
                        //                           MainAxisAlignment.center,
                        //                       crossAxisAlignment:
                        //                           CrossAxisAlignment.center,
                        //                       children: [
                        //                         Icon(
                        //                           Icons.camera_alt_outlined,
                        //                           size: 50,
                        //                         ),
                        //                         Center(
                        //                             child: Text(
                        //                           "NO IMAGE \nAVAILABLE",
                        //                           style: TextStyle(fontSize: 8),
                        //                         ))
                        //                       ],
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //       actions: <Widget>[

                        //         TextButton(
                        //           onPressed: () {
                        //             Navigator.of(context).pop();
                        //           },
                        //           child: const Text('Exit'),
                        //         ),    TextButton(
                        //           onPressed: () {
                        //             Navigator.of(context).pop();
                        //           },
                        //           child: const Text('Save'),
                        //         ),
                        //       ],
                        //     );
                        //   },
                        // );

                        Navigator.pushNamed(context, '/uploadphotos');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Upload Photos")
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          ledgerModel = snapshot.data;
                          nextWidget = 2;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: kPrimaryDarkColor,
                          foregroundColor: white,
                          disabledBackgroundColor: grey),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.shopping_bag,
                              color: white,
                            ),
                            SizedBox(
                              width: 4.0,
                            ),
                            Text(
                              "Add Product To Cart",
                              style: TextStyle(color: white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text('No Data Found..')
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          return AlertDialog(
            title: const Text(
              'An Error Occurred!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.redAccent,
              ),
            ),
            content: Text(
              "${snapshot.error}",
              style: const TextStyle(
                color: Colors.blueAccent,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('This may take some time..')
            ],
          ),
        );
      },
    );
  }

  callNumber(number) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(number);
    } catch (_e) {
      debugPrint(_e as String?);
    }
  }

  bool isItemData = false;
  String itemLike = 'a';
  bool isStock = true;
  selectProductWidget() {
    if (!itemStockAll) {
      return FutureBuilder<List<StockItem>>(
        future: isStock
            ? api.fetchStockProductLike(
                DateUtil.dateDMY2YMD(formattedDate), itemLike)
            : api.fetchNoStockProductLike(
                DateUtil.dateDMY2YMD(formattedDate), itemLike),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              var data = snapshot.data;
              // if (!isItemData) {
              itemDisplay = data!;
              items = data;
              // }
              return ListView.builder(
                // shrinkWrap: true,
                itemBuilder: (context, index) {
                  return index == 0
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Search...')),
                            onChanged: (text) {
                              text = text.toLowerCase();
                              setState(() {
                                itemLike = text.toLowerCase();
                              });
                            },
                          ),
                        )
                      : InkWell(
                          child: Card(
                            child: ListTile(
                              title:
                                  Text('Name : ${itemDisplay[index - 1].name}'),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Qty :${itemDisplay[index - 1].quantity}'),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              productModel = itemDisplay[index - 1];
                              nextWidget = 3;
                            });
                          },
                        );
                },
                itemCount: itemDisplay.length + 1,
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text('No Data Found..'),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            itemLike =
                                itemLike.substring(0, itemLike.length - 1);
                            nextWidget = 2;
                          });
                        },
                        child: const Text('Select Again'))
                  ],
                ),
              );
            }
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: const Text(
                'An Error Occurred!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              content: Text(
                "${snapshot.error}",
                style: const TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('This may take some time..')
              ],
            ),
          );
        },
      );
    } else {
      setState(() {
        if (items.isNotEmpty) isItemData = true;
      });

      return FutureBuilder<List<StockItem>>(
        future: (salesTypeData!.type == 'SALES-O' ||
                salesTypeData!.type == 'SALES-Q')
            ? api.fetchNoStockProduct(DateUtil.dateDMY2YMD(formattedDate))
            : api.fetchStockProduct(DateUtil.dateDMY2YMD(formattedDate)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              var data = snapshot.data;
              if (!isItemData) {
                itemDisplay = data!;
                items = data;
              }
              return ListView.builder(
                // shrinkWrap: true,
                itemBuilder: (context, index) {
                  return index == 0
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Search...')),
                            onChanged: (text) {
                              text = text.toLowerCase();
                              setState(() {
                                itemDisplay = items.where((item) {
                                  item.name.toLowerCase();
                                  var itemName = item.name.toLowerCase();
                                  return itemName.contains(text);
                                }).toList();
                              });
                            },
                          ),
                        )
                      : InkWell(
                          child: Card(
                            child: ListTile(
                              title:
                                  Text('Name : ${itemDisplay[index - 1].name}'),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Qty :${itemDisplay[index - 1].quantity}'),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              productModel = itemDisplay[index - 1];
                              nextWidget = 3;
                            });
                          },
                        );
                },
                itemCount: itemDisplay.length + 1,
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text('No Data Found..'),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            itemLike =
                                itemLike.substring(0, itemLike.length - 1);
                            nextWidget = 2;
                          });
                        },
                        child: const Text('Select Again'))
                  ],
                ),
              );
            }
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: const Text(
                'An Error Occurred!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              content: Text(
                "${snapshot.error}",
                style: const TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('This may take some time..')
              ],
            ),
          );
        },
      );
    }
  }

  itemDetailWidget(StockItem product) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Text(product.name!),
          SingleChildScrollView(
            child: Form(
              key: _resetKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            setState(() {
                              nextWidget = 2;
                              isVariantSelected = false;
                              clearValue();
                            });
                          },
                          child: const Text("BACK"),
                          color: blue[400],
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        MaterialButton(
                          onPressed: () {
                            setState(() {
                              isVariantSelected = false;

                              nextWidget = 4;
                              clearValue();
                            });
                          },
                          child: const Text("CANCEL"),
                          color: blue[400],
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        MaterialButton(
                          color: blue,
                          onPressed: () {
                            setState(() {
                              isVariantSelected = false;
                              if (_quantityController.text.isNotEmpty) {
                                // if (totalItem > 0) {
                                //   print("c");
                                //   clearValue();
                                //   nextWidget = 4;
                                // } else {

                                addProduct(
                                    CartJobCartItem(
                                      id: totalItem + 1,
                                      itemid: int.parse(product.code!),
                                      itemName: product.name!,
                                      qty: double.tryParse(
                                          _quantityController.text)!,
                                      uniqueCode: product.id.toString(),
                                      model: _modelController.text,
                                      date: _formattedjobcarddate!,
                                    ),
                                    -1);
                                clearValue();
                                nextWidget = 4;
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No Quantity')),
                                );
                              }
                            }
                                // }
                                );
                          },
                          child: const Text("ADD"),
                        ),
                      ]),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _modelController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                        labelText: 'Model', border: OutlineInputBorder()),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                        labelText: 'SerialNo', border: OutlineInputBorder()),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 70,
                    decoration: BoxDecoration(border: Border.all()),
                    child: InkWell(
                      child: Center(
                        child: Row(
                          children: [
                            Text(
                              '   ${_formattedjobcarddate!}',
                              style: const TextStyle(),
                            ),
                          ],
                        ),
                      ),
                      onTap: () => _selectJobcarddate(context),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                allow: true, replacementString: '.')
                          ],
                          decoration: const InputDecoration(
                              labelText: 'Quantity',
                              hintText: '0.0',
                              border: OutlineInputBorder()),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              bool cartQ = false;
                              setState(() {
                                if (totalItem > 0) {
                                  double cartS = 0, cartQt = 0;
                                  for (var element in cartItem) {
                                    if (element.uniqueCode == product.id) {
                                      cartQt += element.qty;
                                    }
                                  }
                                  if (cartS > 0) {
                                    if (cartS <
                                        cartQt + double.tryParse(value)!) {
                                      cartQ = true;
                                    }
                                  }
                                }
                              });
                            }
                          },
                        ),
                      )),
                      Visibility(
                        visible: enableMULTIUNIT,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: FutureBuilder(
                              future: api.fetchUnitOf(product.id!),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  unitListData.clear();
                                  for (var i = 0;
                                      i < snapshot.data.length;
                                      i++) {
                                    if (defaultUnitID.toString().isNotEmpty) {
                                      if (snapshot.data[i].id ==
                                          defaultUnitID! - 1) {
                                        _dropDownUnit = snapshot.data[i].id;
                                      }
                                    }
                                    unitListData.add(UnitModel(
                                        id: snapshot.data[i].id,
                                        itemId: snapshot.data[i].itemId,
                                        conversion: snapshot.data[i].conversion,
                                        name: snapshot.data[i].name,
                                        pUnit: snapshot.data[i].pUnit,
                                        sUnit: snapshot.data[i].sUnit,
                                        unit: snapshot.data[i].unit,
                                        rate: snapshot.data[i].rate));
                                  }
                                }
                                return snapshot.data != null &&
                                        snapshot.data.length > 0
                                    ? DropdownButton<String>(
                                        hint: Text(_dropDownUnit > 0
                                            ? UnitSettings.getUnitName(
                                                _dropDownUnit)
                                            : 'SKU'),
                                        items: snapshot.data
                                            .map<DropdownMenuItem<String>>(
                                                (item) {
                                          return DropdownMenuItem<String>(
                                            value: item.id.toString(),
                                            child: Text(item.name),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            bool cartQ = false;
                                            _dropDownUnit =
                                                int.tryParse(value!)!;
                                            for (var i = 0;
                                                i < unitListData.length;
                                                i++) {
                                              UnitModel _unit = unitListData[i];
                                            }
                                          });
                                        },
                                      )
                                    : DropdownButton<String>(
                                        hint: Text(_dropDownUnit > 0
                                            ? UnitSettings.getUnitName(
                                                _dropDownUnit)
                                            : 'SKU'),
                                        items: unitListSettings
                                            .map<DropdownMenuItem<String>>(
                                                (item) {
                                          return DropdownMenuItem<String>(
                                            value: item.key.toString(),
                                            child: Text(item.value),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _dropDownUnit =
                                                int.tryParse(value!)!;
                                            // for (var i = 0;
                                            //     i < unitListData.length;
                                            //     i++) {
                                            //   UnitModel _unit = unitListData[i];
                                            //   if (_unit.unit ==
                                            //       int.tryParse(value)) {
                                            //     _conversion = _unit.conversion;
                                            //     break;
                                            //   }
                                            // }
                                            // calculate();
                                          });
                                        },
                                      );
                              },
                            ),
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
    );
  }

  productTrackingList(StockProduct product) {
    var ledId =
        ledgerModel.id.toString().isNotEmpty ? ledgerModel.id.toString() : '0';
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Previous  Sold Price'),
            content: SizedBox(
                width: deviceSize!.width - 10,
                height: deviceSize!.height - 20,
                child: productTrackingListData(ledId, product)),
            actions: [
              InkWell(
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Close",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  productTrackingListData(ledger, StockProduct product) {
    return FutureBuilder(
        future: api.getProductTracking(product.itemId, ledger),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.length > 0) {
              List<dynamic> data = snapshot.data!;
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      child: ListTile(
                        title: Text(data[index]['Supplier'].toString(),
                            style: const TextStyle(fontSize: 12)),
                        trailing: Text(data[index]['Date'].toString()),
                        subtitle: Text(
                            'Qty : ${data[index]['Qty']} Rate : ${data[index]['Rate']}\n Disc : ${data[index]['Disc']}   ${data[index]['DiscPersent']}%'),
                        onLongPress: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  });
            } else {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text('Product not sold'),
                    // TextButton(
                    //     onPressed: () {
                    //       setState(() {
                    //         nextWidget = 2;
                    //       });
                    //     },
                    //     child: const Text('Select Product Again'))
                  ],
                ),
              );
            }
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: const Text(
                'An Error Occurred!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              content: Text(
                "${snapshot.error}",
                style: const TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('This may take some time..')
              ],
            ),
          );
        });

    // return ListView.builder(
    //   itemCount: 150,
    //   itemBuilder: (BuildContext context, int index) {
    //     return ListTile(
    //       title: Text(index.toString()),
    //     );
    //   },
    // );
  }

  Future<List<dynamic>> widgetBankAccount(String filter) async {
    var dd = filter.isEmpty
        ? cashBankACList
        : cashBankACList
            .where((element) => element.name
                .toString()
                .toLowerCase()
                .contains(filter.toLowerCase()))
            .toList();
    List<DataJson> dataResult = [];
    for (var data in dd) {
      dataResult.add(DataJson(id: data.id, name: data.name.trim().toString()));
    }
    return dataResult;
  }

  Future<void> _displayTextInputDialog(
      BuildContext context, String title, String text, int index) async {
    TextEditingController _controller = TextEditingController();
    String? valueText;
    _controller.text = ComSettings.getIfInteger(text);
    return showDialog(
      context: context,
      builder: (context) {
        return (StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _controller,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "value"),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                    allow: true, replacementString: '.')
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                ),
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    valueText = valueText ?? _controller.text;
                    editProduct(title, valueText!, index);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        }));
      },
    );
  }

  cartProduct() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        ListTile(
          title: Text(ledgerModel.name,
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold)),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ledgerModel.address1),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                  child: const SizedBox(
                    height: 26,
                    child: Text(
                      'Add Complaints',
                      style: TextStyle(
                          color: blue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      Navigator.pushNamed(context, '/complaintsjobcard');
                    });
                  }),
              InkWell(
                  child: const SizedBox(
                    height: 26,
                    child: Text(
                      'Add Item',
                      style: TextStyle(
                          color: blue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      nextWidget = 2;
                    });
                  }),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        totalItem > 0
            ? Expanded(
                child: ListView.separated(
                  itemCount: cartItem.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: InkWell(
                        child: Text(cartItem[index].itemName),
                        onDoubleTap: () {
                          setState(() {
                            removeProduct(index);
                          });
                        },
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Qty:'),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Card(
                                    color: Colors.green[200],
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.black,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          updateProduct(cartItem[index],
                                              cartItem[index].qty + 1, index);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    child: Text(
                                        '${cartItem[index].qty}'.toString(),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    onTap: () {
                                      _displayTextInputDialog(
                                          context,
                                          'Edit Quantity',
                                          cartItem[index].qty > 0
                                              ? double.tryParse(cartItem[index]
                                                      .qty
                                                      .toString())
                                                  .toString()
                                              : '',
                                          index);
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Card(
                                    color: Colors.red[200],
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.remove,
                                        color: Colors.black,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          updateProduct(cartItem[index],
                                              cartItem[index].qty - 1, index);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('model: ${cartItem[index].model}'.toString(),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  'Serial No: ${cartItem[index].uniqueCode}'
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              Text('Date: ${cartItem[index].date}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            : const Center(
                child: Text("No items in Cart"),
              ),
        footerWidget()
      ],
    );
  }

  Future _selectDatee() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => _formattedDate = DateFormat('dd-MM-yyyy').format(picked));
    }
  }

  Future _selectDeliveryDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() =>
          _formattedDeliveryDate = DateFormat('dd-MM-yyyy').format(picked));
    }
  }

  Future<void> _selectJobcarddate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now())
      setState(() {
        setState(() =>
            _formattedjobcarddate = DateFormat('dd-MM-yyyy').format(picked));
      });
  }

  void clearValue() {
    _quantityController.clear();
    _serialNoController.clear();
    _modelController.clear();
  }

  void addProduct(product, int index) {
    index = cartItem.indexWhere((i) => i.itemid == product.itemid);

    if (index != -1) {
      updateProduct(product, cartItem[index].qty + product.qty, index);
    } else {
      cartItem.add(product);
    }
  }

  void removeProduct(int index) {
    // int index = cartItem.indexWhere((i) => i.itemId == product.itemId);
    // cartItem[index].quantity = 1;
    cartItem.removeAt(index); //((item) => item.id == product.id);
  }

  void updateProduct(product, qty, int index) {
    // int index = cartItem.indexWhere((i) => i.itemId == product.itemId);
    cartItem[index].qty = qty;

    if (cartItem[index].qty == 0) removeProduct(index);
  }

  void editProduct(String title, String value, int index) {
    // int index = cartItem.indexWhere((i) => i.id == id);

    cartItem[index].qty = double.tryParse(value)!;
  }

  footerWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.blue[50],
        child: Column(
          children: [
            const Divider(
              height: 2,
            ),
            Visibility(
              visible: valueMore,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: deviceSize!.width - 18,
                        height: 35,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.end,
                          controller: controllerEstimate,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            border: OutlineInputBorder(),
                            labelText: 'Estimate',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: SizedBox(
                          // width: deviceSize!.width - 18,
                          height: 35,
                          child: TextField(
                            keyboardType: TextInputType.name,
                            controller: controllerDamageorScratch,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              border: OutlineInputBorder(),
                              labelText: 'Damage/Scratch',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/imagemarker');
                        },
                        child: Container(
                          width: 50,
                          height: 35,
                          decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(6)),
                          child: const Column(
                            children: [
                              SizedBox(
                                height: 9,
                              ),
                              Icon(Icons.more_horiz),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: valueMore,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: deviceSize!.width - 18,
                        height: 35,
                        child: TextField(
                          controller: controllerNarration,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            border: OutlineInputBorder(),
                            labelText: 'Narration',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Visibility(
              visible: valueMore,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButton<String>(
                    underline: const SizedBox(), // Set underline to null here
                    borderRadius: BorderRadius.circular(8),
                    isExpanded: true,
                    hint: const Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text('Service Status'),
                      ],
                    ),

                    value: _selectedStatus,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    },
                    items: <String>[
                      'Spare Waiting',
                      'Working Ok',
                      'Working Progress'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            Visibility(
                visible: valueMore,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/standbyitems');
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6))),
                      child: const Text('StandBy items'),
                    ),
                  ],
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      valueMore = valueMore == true ? false : true;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.blue.shade200),
                  ),
                  child: Icon(valueMore
                      ? Icons.keyboard_double_arrow_down_outlined
                      : Icons.keyboard_double_arrow_up_outlined), //Text('More',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
