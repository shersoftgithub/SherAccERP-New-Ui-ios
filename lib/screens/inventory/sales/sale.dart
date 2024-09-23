import 'dart:convert';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:sheraccerp/provider/customer_provider.dart';
import 'package:sheraccerp/provider/product_provider.dart';
import 'package:sheraccerp/scoped-models/main.dart';
import 'package:sheraccerp/screens/inventory/sales/previous_bill.dart';
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
import 'package:sheraccerp/widget/components.dart';
import 'package:sheraccerp/widget/container_textfield_widget.dart';
import 'package:sheraccerp/widget/loading.dart';
import 'package:sheraccerp/widget/popup_menu_action.dart';
import 'package:sheraccerp/widget/progress_hud.dart';

class Sale extends ConsumerStatefulWidget {
  final bool thisSale;
  final bool oldSale;
  const Sale({
    Key? key,
    required this.thisSale,
    required this.oldSale,
  }) : super(key: key);
  @override
  ConsumerState<Sale> createState() => _SaleState();
}

class _SaleState extends ConsumerState<Sale> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<SalesType> salesTypeDisplay = [];
  dynamic salesData;
  bool _defaultSale = false,
      thisSale = false,
      _isLoading = false,
      isCustomForm = false,
      buttonEvent = false,
      isSerialNoInStockVariant = false;
  bool _autoVariantSelect = false;
  DioService api = DioService();
  Size? deviceSize;
  var vehicleData;
  CustomerModel? ledgerModel;
  LedgerModel? ledgerDataModel;
  CartItem? cartModel;
  String vehicleName = '', invoiceNo = '';
  
  StockItem? productModel;
  List<CartItem> cartItem = [];
  List<String> unregisteredNameList = [];
  List<dynamic> otherAmountList = [];
  bool isTax = true,
      isTaxTypeLocked = false,
      blockTaxLedgerOnB2CorBOS = false,
      otherAmountLoaded = false,
      salesmanAsVehicle = false,
      valueMore = false,
      lastRecord = false,
      widgetID = true,
      previewData = false,
      oldBill = false,
      itemCodeVise = false,
      itemCodeViseChek = false,
      itemStockAll = false,
      isItemRateEditLocked = false,
      isMinimumRate = false,
      isItemDiscountEditLocked = false,
      isItemSerialNo = false,
      keyItemsVariantStock = false,
      enableBarcode = false,
      _isReturnInSales = false,
      productTracking = false,
      isFreeItem = false,
      isStockProductOnlyInSalesQO = false,
      isLockQtyOnlyInSales = false,
      isSalesManWiseLedger = false,
      isEnableProfitlessSalesWarning = false,
      salesEntryCustomerOnly = false,
      isFreeQty = false,
      gstVerified = false,
      gstValidation = false,
      isLedgerWiseLastSRate = false,
      isQuantityBasedSerialNo = false,
      keySwitchSalesRateTypeSet = false,
      keyEditAndDeleteAdminOnlyDaysBefore = false,
      daysBefore = false,
      isAdminUser = false,
      newSale = false,
      manualInvoiceNumberInSales = false;
  final List<TextEditingController> _controllers = [];
  DateTime now = DateTime.now();
  String? formattedDate;
  double _balance = 0, grandTotal = 0;
  final invoiceNoController = TextEditingController();
  final controllerCashReceived = TextEditingController();
  final controllerNarration = TextEditingController();
  final vehicleNameControl = TextEditingController();
  final customerNameControl = TextEditingController();
  final addressControl = TextEditingController();
  final siteNameControl = TextEditingController();
  final taxNoControl = TextEditingController();
  final mobileNoControl = TextEditingController();
  final nameControl = TextEditingController();
  final billingNameController = TextEditingController();
  final itemNameControl = TextEditingController();
  final FocusNode _focusNodeCashReceived = FocusNode();
  String oldBalance = '0';

  GlobalKey<AutoCompleteTextFieldState<String>> keyName = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> keySection = GlobalKey();

  int page = 1, pageTotal = 0, totalRecords = 0, valueDaysBefore = 0;
  int saleAccount = 0, acId = 0, decimal = 2;
  String cashAc = '';
  int cashId = 0;
  List<LedgerModel> ledgerDisplay = [];
  List<LedgerModel> _ledger = [];
  List<dynamic> itemDisplay = [];
  List<dynamic> items = [];
  List<LedgerModel> cashBankACList = [];
  List<SerialNOModel> serialNoData = [];
  List<String> vehicleNameListDisplay = [];
  late List<LedgerModel> customerList = [];
  List<String> nameListDisplay = [];
  late List<StockItem> productList = [];
  List<String> itemNameListDisplay = [];
  int lId = 0, groupId = 0, areaId = 0, routeId = 0;
  String date = '', like = '';
  var salesManId = 0;
  String labelSerialNo = 'SerialNo';
  String labelSpRate = 'SpRetail';
  bool ledgerScanner = false, productScanner = false, loadScanner = false;
  List<String> suggestions = [];
  Map<String, String> nameToIdMap = {};
  bool isLoading = false;

  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final dbHelper = DatabaseHelper.instance;
  GlobalKey<AutoCompleteTextFieldState<String>> keyVehicleName = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> keyCustomerName = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);

    isCustomForm =
        ComSettings.appSettings('bool', 'key-switch-sales-form-set', false)
            ? true
            : false;
    if (isCustomForm) {
      salesTypeDisplay =
          ComSettings.salesFormList('key-item-sale-form-', false);
    }
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //  if (salesTypeData != null) {
    //     salesTypeData!.type == 'SALE-O' || salesTypeData!.type == 'SALE-Q'
    //   ? ref.read(productsProvider.notifier).fetchNoStockProducts("", date)
    //  : ref.read(productsProvider.notifier).fetchStockProducts("", date);
    //  }
    // });
    // fetchCustomerNames();
    // fetchStockProducts();
    // api
    //     .getCustomerNameListByParent(
    //   groupId,
    //   areaId,
    //   routeId,
    //   salesManId,
    // )
    //     .then((value) {
    //   print('API Call Successful: $value');
    //   setState(() {
    //     customerList = value;
    //     nameListDisplay = customerList.map((item) => item.name).toList();
    //   });
    // }).catchError((error) {
    //   print('API Call Failed: $error');
    // });

    // api
    //     .fetchStockProductLike(DateUtil.dateDMY2YMD(formattedDate), itemLike)
    //     .then((value) {
    //   print('API Call Successful: $value');
    //   setState(() {
    //     productList = value;
    //     itemNameListDisplay = productList
    //         .map((item) => item.name)
    //         .where((name) => name != null)
    //         .cast<String>()
    //         .toList();
    //   });
    // }).catchError((error) {
    //   print('API Call Failed: $error');
    // });

    loadSettings();
 
    api.getUnregisteredNameList().then((value) => unregisteredNameList = value);
    salesManId = ComSettings.appSettings(
            'int', 'key-dropdown-default-salesman-view', 1) -
        1;
    lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;

    groupId =
        ComSettings.appSettings('int', 'key-dropdown-default-group-view', 0) -
            1;
    areaId =
        ComSettings.appSettings('int', 'key-dropdown-default-area-view', 0) - 1;
    routeId =
        ComSettings.appSettings('int', 'key-dropdown-default-route-view', 0) -
            1;

    saleAccount = mainAccount.firstWhere(
        (element) => element['LedName'] == 'GENERAL SALES A/C')['LedCode'];

    ledgerScanner = ComSettings.appSettings('bool', 'key-customer-scan', false);
    itemCodeVise = ComSettings.appSettings('bool', 'key-item-by-code', false);
    itemCodeViseChek = itemCodeVise;
    itemStockAll = ComSettings.appSettings('bool', 'key-item-stock-all', false);
   isAdminUser =
        companyUserData!.userType.toUpperCase() == 'ADMIN' ? true : false;
    keyItemsVariantStock =
        ComSettings.appSettings('bool', 'key-items-variant-stock', false);

    if (optionRateTypeList.isEmpty) {
      api.getRateTypeList().then((value) {
        setState(() {
          rateTypeList = value;

          String rateTypeS = salesTypeData != null
              ? salesTypeData!.rateType.isNotEmpty
                  ? salesTypeData!.rateType
                  : 'MRP'
              : 'MRP';

          rateTypeItem =
              rateTypeList.firstWhere((element) => element.name == rateTypeS);
        });
      });
    } else {
      rateTypeList = optionRateTypeList;

      String rateTypeS = salesTypeData != null
          ? salesTypeData!.rateType.isNotEmpty  
              ? salesTypeData!.rateType
              : 'MRP'
          : 'MRP';

      rateTypeItem = rateTypeList.firstWhere((element) =>
          element.name.toString().toUpperCase() == rateTypeS.toUpperCase());
    }

    api.getLedgerListByType('SelectbankOnly').then((value) {
      List<LedgerModel> _dataTemp = [];
      for (var ledger in value) {
        _dataTemp
            .add(LedgerModel(id: ledger['ledcode'], name: ledger['LedName']));
      }
      setState(() {
        cashBankACList.addAll(_dataTemp);
          if (bankLedgerData != null) {
          bankLedgerData = cashBankACList.firstWhere(
            (element) =>
                element.name.toLowerCase() == bankLedgerName!.toLowerCase(),
            orElse: () => LedgerModel(id: 0, name: bankLedgerName!),
          );
          bankLedgerName = bankLedgerData.name;
        }
      });
    });
  }

  CompanyInformation? companySettings;
  List<CompanySettings>? settings;
  List<OptionRateType> rateTypeList = [];

  loadSettings() {
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();

     cashAc =
        ComSettings.getValue('CASH A/C', settings!).toString().trim() ?? 'CASH';
     cashId =
        ComSettings.appSettings('int', 'key-dropdown-default-cash-ac', 0) - 1;
    acId = 
         mainAccount.firstWhere((element) => element['LedName'] == cashAc,
            orElse: () => {'LedName': cashAc, 'LedCode': acId})['LedCode']
        ;
    taxMethod = companySettings!.taxCalculation!;
    enableMULTIUNIT = ComSettings.getStatus('ENABLE MULTI-UNIT', settings!);
    if (!enableMULTIUNIT) {
      _dropDownUnit = otherRegUnitList.isNotEmpty ? otherRegUnitList[0].id : 0;
    }
    pRateBasedProfitInSales =
        ComSettings.getStatus('PRATE BASED PROFIT IN SALES', settings!);
    negativeStock = ComSettings.getStatus('ALLOW NEGETIVE STOCK', settings!);
    companyTaxMode = ComSettings.getValue('PACKAGE', settings!);
    cessOnNetAmount = ComSettings.getStatus('CESS ON NET AMOUNT', settings!);
    salesEntryCustomerOnly =
        ComSettings.getStatus('SALES ENTRY CUSTOMER ONLY', settings!);
    blockTaxLedgerOnB2CorBOS = ComSettings.getStatus(
        'BLOCK B2C BOS SALES TO GST CUSTOMERS', settings!);
    enableKeralaFloodCess = false;
    enableBarcode = ComSettings.getStatus('ENABLE BARCODE OPTION', settings!);
    isEnableProfitlessSalesWarning =
        ComSettings.getStatus('ENABLE PROFITLESS SALES WARNING', settings!);
    useUniqueCodeAsBarcode =
        ComSettings.getStatus('USE UNIQUECODE AS BARCODE', settings!);
    useOldBarcode = ComSettings.getStatus('USE OLD BARCODE', settings!);
    decimal = (ComSettings.getValue('DECIMAL', settings!).toString().isNotEmpty
        ? int.tryParse(ComSettings.getValue('DECIMAL', settings!).toString())
        : 2)!;
    isItemSerialNo = ComSettings.getStatus('KEY ITEM SERIAL NO', settings!);
    labelSerialNo =
        ComSettings.getValue('KEY ITEM SERIAL NO', settings!).toString();
    labelSpRate =
        ComSettings.getValue('KEY ITEM SP RATE TITLE', settings!).toString();
    labelSerialNo = labelSerialNo.isEmpty ? 'Remark' : labelSerialNo;
    labelSpRate = labelSpRate.isEmpty ? 'SpRetail' : labelSpRate;
    isItemDiscountEditLocked =
        ComSettings.getStatus('KEY LOCK SALES DISCOUNT', settings!);
    isItemRateEditLocked =
        ComSettings.getStatus('KEY LOCK SALES RATE', settings!);
    isMinimumRate =
        ComSettings.getStatus('KEY LOCK MINIMUM SALES RATE', settings!);
    _isReturnInSales =
        ComSettings.getStatus('SALES-RETURN IN SALES', settings!);
    productTracking =
        ComSettings.getStatus('ENABLE PRODUCT TRACKING IN SALES', settings!);
    isFreeItem = ComSettings.getStatus('KEY FREE ITEM', settings!);
    isFreeQty = ComSettings.getStatus('KEY FREE QTY IN SALE', settings!);
    isStockProductOnlyInSalesQO =
        ComSettings.getStatus('KEY STOCK PRODUCT ONLY IN SALES QO', settings!);
    isLockQtyOnlyInSales =
        ComSettings.getStatus('KEY LOCK QTY ONLY IN SALES', settings!);
    isSalesManWiseLedger =
        ComSettings.getStatus('KEY SALESMAN WISE LEDGER', settings!);
    isSerialNoInStockVariant =
        ComSettings.getStatus('SHOW SERIALNO IN STOCK WINDOW', settings!);
    salesmanAsVehicle =
        ComSettings.getStatus('USE SALESMAN AS VEHICLE', settings!);
    isLedgerWiseLastSRate =
        ComSettings.getStatus('ENABLE CUSTOMER WISE LAST S.RATE', settings!);
    isQuantityBasedSerialNo =
        ComSettings.getStatus('ENABLE QUANTITY BASED SERIAL NO', settings!);
    keyEditAndDeleteAdminOnlyDaysBefore = ComSettings.getStatus(
        'KEY EDIT AND DELETE ADMIN ONLY DAYS BEFORE', settings!);
    var valX = ComSettings.getValue(
        'KEY EDIT AND DELETE ADMIN ONLY DAYS BEFORE', settings!);
    valueDaysBefore =
        int.tryParse(valX.toString().isNotEmpty ? valX.toString() : '0')!;
    manualInvoiceNumberInSales =
        ComSettings.getStatus('MANNUAL INVOICE NUMBER IN SALES', settings!);

    if (widget.oldSale != null && widget.oldSale) {
      _isLoading = true;
      fetchSale(context, dataDynamic[0]);
      _isLoading = false;
    }
    else{
      api.fetchDetailAmount().then((value) {
      otherAmountList = value;
      setState(() {
        otherAmountLoaded = true;
      });
      });
    }
    
      WidgetsBinding.instance.addPostFrameCallback((_) {
     if (salesTypeData != null) {
     var productspro= 
        salesTypeData!.type == 'SALE-O' || salesTypeData!.type == 'SALE-Q'
        ? isStockProductOnlyInSalesQO
                ? ref.read(productsProvider.notifier).fetchStockProducts(itemLike, DateUtil.dateDMY2YMD(formattedDate))
                : ref.read(productsProvider.notifier).fetchNoStockProducts(
                    DateUtil.dateDMY2YMD(formattedDate), itemLike)
            : ref.read(productsProvider.notifier).fetchStockProducts(
                DateUtil.dateDMY2YMD(formattedDate), itemLike);
    //   ? ref.read(productsProvider.notifier).fetchNoStockProducts("", date)
    //  : ref.read(productsProvider.notifier).fetchStockProducts("", date);
     }
    });

    api.getVehicleNameList().then((value) {
      vehicleNameListDisplay.addAll(value);
    });
  }
  
    getOldBalance(int id, String type, String entryNo) {
    api
        .getBalance(
            id, 'CustomerOB', type, DateUtil.dateYMD(formattedDate), entryNo)
        .then((obValue) {
      setState(() {
        oldBalance = obValue['oldBalance'].toString();
        // balance = double.parse(obValue['balance'].toString());
      });
    });
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
        }
      }
    }
  }

  Future<List<LedgerModel>> fetchCustomerNames(String query) async {
    try {
      var value = await api.getCustomerNameListByParent(
        groupId,
        areaId,
        routeId,
        salesManId,
      );
      print('API Call Successful: $value');
      return value;
    } catch (error) {
      print('API Call Failed: $error');
      return [];
    }
  }

  Future<void> fetchSuggestions(String query) async {
    setState(() {
      isLoading = true;
    });
    try {
      var value = await api.getCustomerNameListByParent(
        groupId,
        areaId,
        routeId,
        salesManId,
      );
      print('API Call Successful: $value');
      setState(() {
        suggestions = value.map((item) => item.name).toList();
        nameToIdMap = {for (var item in value) item.name: item.id.toString()};
        isLoading = false;
      });
    } catch (error) {
      print('API Call Failed: $error');
      setState(() {
        suggestions = [];
        nameToIdMap = {};
        isLoading = false;
      });
    }
  }

  int? selectedCustomerId;
  void fetchCustomerDetails(String selectedCustomer) {
    setState(() {
      selectedCustomerId = (nameToIdMap[selectedCustomer] ?? '') as int?;
    });
  }

  Future<List<StockItem>> fetchStockProducts(String itemLike) async {
    try {
      var value = await api.fetchStockProductLike(
          DateUtil.dateDMY2YMD(formattedDate), itemLike);
      print('API Call Successful: $value');
      return value;
    } catch (error) {
      print('API Call Failed: $error');
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    _discountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _discountController.text.length));
    _discountPercentController.selection = TextSelection.fromPosition(
        TextPosition(offset: _discountPercentController.text.length));
    _quantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: _quantityController.text.length));
    _rateController.selection = TextSelection.fromPosition(
        TextPosition(offset: _rateController.text.length));
    controllerCashReceived.selection = TextSelection.fromPosition(
        TextPosition(offset: controllerCashReceived.text.length));
    _freeQuantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: _freeQuantityController.text.length));

    deviceSize = MediaQuery.of(context).size;
    thisSale = widget.thisSale;
    taxable = isTaxTypeLocked
        ? isTaxTypeLocked
        : (salesTypeData != null ? salesTypeData!.tax : taxable);

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
        child: widgetID ? widgetPrefix(thisSale) : widgetSuffix(thisSale));
  }

  _onWillPop() async {
    if (nextWidget == 2) {
      return setState(() {
        nextWidget = 0;
      },);
      // (await showDialog(
      //       context: context,
      //       builder: (context) => AlertDialog(
      //         title: const Text('Back'),
      //         content: const Text('Select Item Again?'),
      //         actions: [
      //           TextButton(
      //             onPressed: () {
      //               setState(() {
      //                 nextWidget = 2;
      //                 clearValue();
      //               });
      //               Navigator.of(context).pop(false);
      //             },
      //             child: const Text('Select'),
      //           ),
      //         ],
      //       ),
      //     )) ??
      //     false;
    } else if (loadReturnForm) {
      setState(() {
        loadReturnForm = false;
        returnBillId = getReturnBillNo != null
            ? getReturnBillNo > 0
                ? getReturnBillNo
                : 0
            : 0;
        returnEntryNoController.text = getReturnBillNo != null
            ? getReturnBillNo > 0
                ? getReturnBillNo.toString()
                : ''
            : '';
        returnAmount = getReturnBillAmount != null
            ? getReturnBillAmount > 0
                ? getReturnBillAmount
                : 0
            : 0;
        returnAmountController.text = getReturnBillAmount != null
            ? getReturnBillAmount > 0
                ? getReturnBillAmount.toString()
                : ''
            : '';
        if (returnAmount > 0) {
          grandTotal = grandTotal - returnAmount;
        }
      });
    } else {
      return (await showDialog(
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
          )) ??
          false;
    }
  }

  widgetSuffix(thisSale) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: newSale
            ? AppBar(
                title: const Text(
                  "Sales",
                  style: TextStyle(fontFamily: 'poppins'),
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
                              if (!daysBefore) {
                                if (totalItem > 0) {
                                  setState(() {
                                    _isLoading = true;
                                    buttonEvent = true;
                                  });
                                  _insert(
                                      'Delete DateTime:$formattedDate $timeIs location:${lId.toString()} ledger:${ledgerModel!.id} ${CartItem.encodeCartToJson(cartItem)}',
                                      0);
                                  deleteSale(context);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Please select at least one bill');
                                  setState(() {
                                    buttonEvent = false;
                                  });
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        'Invoice Date not equal\ncan`t delete');
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
                                if (!daysBefore) {
                                  if (totalItem > 0) {
                                    setState(() {
                                      _isLoading = true;
                                      buttonEvent = true;
                                    });
                                    _insert(
                                        'Edit DateTime:$formattedDate $timeIs location:${lId.toString()} ledger:${ledgerModel!.id} ${CartItem.encodeCartToJson(cartItem)}',
                                        0);
                                    updateSale();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'Please select at least one bill');
                                    setState(() {
                                      buttonEvent = false;
                                    });
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg:
                                          'Invoice Date not equal\ncan`t edit');
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
                                if (!daysBefore) {
                                  if (totalItem > 0) {
                                    setState(() {
                                      _isLoading = true;
                                      buttonEvent = true;
                                    });
                                    _insert(
                                        'SAVE DateTime:$formattedDate $timeIs location:${lId.toString()} ledger:${ledgerModel!.id} ${CartItem.encodeCartToJson(cartItem)}',
                                        0);
                                    saveSale();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'Please add at least one item');
                                    setState(() {
                                      buttonEvent = false;
                                    });
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg:
                                          'Invoice Date not equal\ncan`t save');
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
              )
            : null,
        body: ProgressHUD(
            inAsyncCall: _isLoading, opacity: 0.0, child: selectWidget()));
  }

  widgetPrefix(thisSale) {
    setState(() {
      if (thisSale) {
        previewData = true;
      }
    });
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: bagroundColor,
        appBar: AppBar(
          title: const Text(
            "Sales",
            style: TextStyle(fontFamily: 'poppins'),
          ),
          actions: [
            Visibility(
              visible: previewData,
              child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[700],
                  ),
                  onPressed: () async {
                    setState(() {
                      widgetID = false;
                    });
                  },
                  child: Text(
                    previewData ? "New ${salesTypeData!.name}" : 'Sales',
                    style: const TextStyle(
                        color: Colors.white, fontFamily: 'poppins'),
                  )),
            ),
          ],
        ),
        body: thisSale
            ? Padding(
             padding: const EdgeInsets.symmetric(
                horizontal: 16,vertical: 8
              ),
              child: Container(
                  child: previousBill(),
                ),
            )
            : _defaultSale
                ? Padding(
                   padding: const EdgeInsets.symmetric(
                horizontal: 16,vertical: 8
              ),
                  child: Container(
                      child: previousBill(),
                    ),
                )
                : previewData
                    ? Padding(
                       padding: const EdgeInsets.symmetric(
                horizontal: 16,vertical: 8
              ),
                      child: Container(
                          child: previousBill(),
                        ),
                    )
                    : Container(
                      padding: const EdgeInsets.symmetric(
                horizontal: 16,vertical: 8
              ),
                        child: Container(
                            color: white,
                            padding: const EdgeInsets.all(8),
                            child: selectSalesType()),
                      )
                      );
  }

  final ScrollController _scrollController = ScrollController();
  bool isLoadingData = false;
  List dataDisplay = [];

  void _getMoreData() async {
    if (!lastRecord) {
      if (dataDisplay.isEmpty ||
          // ignore: curly_braces_in_flow_control_structures
          dataDisplay.length < totalRecords) if (!isLoadingData) {
        setState(() {
          isLoadingData = true;
        });

        List tempList = [];
        var statement = 'SalesList';
        var locationId =
            lId.toString().trim().isNotEmpty ? lId : salesTypeData!.location;

        api
            .getPaginationList(
                statement,
                page,
                locationId.toString(),
                salesTypeData!.id.toString(),
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

  @override
  void dispose() {
    _scrollController.dispose();
    if (controller != null) {
      controller!.dispose();
    }

    invoiceNoController.dispose();
    controllerCashReceived.dispose();
    controllerNarration.dispose();
    _rateController.dispose();
    _discountController.dispose();
    _quantityController.dispose();
    _freeQuantityController.dispose();
    _discountPercentController.dispose();
    _serialNoController.dispose();
    returnAmountController.dispose();
    returnEntryNoController.dispose();
    bankAmountController.dispose();
    commissionAmountController.dispose();
    addressControl.dispose();
    siteNameControl.dispose();
    taxNoControl.dispose();
    mobileNoControl.dispose();
    itemNameControl.dispose();
    customerNameControl.dispose();

    super.dispose();
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
                    // height: 80,
                    constraints: const BoxConstraints(
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
                            child: InkWell(
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
                              onTap: () {
                                showDetails(context, dataDisplay[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ));
                // return Card(
                //   elevation: 3,
                //   clipBehavior: Clip.hardEdge,
                //   margin: EdgeInsets.all(2),
                //   child: ListTile(
                //     title: Text(dataDisplay[index]['Name']),
                //     subtitle: Text('Date: ' +
                //         dataDisplay[index]['Date'] +
                //         ' / EntryNo : ' +
                //         dataDisplay[index]['Id'].toString()),
                //     trailing: Text(
                //         'Total : ' + dataDisplay[index]['Total'].toString()),
                //     onTap: () {
                //       if (userRole == 'SALESMAN') {
                //         showEditDialog(context, dataDisplay[index]);
                //       } else {
                //         showEditDialog(context, dataDisplay[index]);
                //       }
                //     },
                //   ),
                // );
              }
            },
            controller: _scrollController,
          )
        : Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No items in ${salesTypeData!.name}",
                style: const TextStyle(fontFamily: 'poppins'),
              ),
              TextButton.icon(
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                    backgroundColor:const MaterialStatePropertyAll(kPrimaryColor),
                    foregroundColor:
                        const MaterialStatePropertyAll(Colors.white),
                  ),
                  onPressed: () {
                    setState(() {
                      widgetID = false;
                    });
                  },
                  icon: const Icon(Icons.shopping_bag),
                  label: Text(
                    'Take New ${salesTypeData!.name}',
                    style: const TextStyle(fontFamily: 'poppins',
                    color: white
                    ),
                  ))
            ],
          ));
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

  saveSale() async {
    
    List<CustomerModel> ledger = [];
    ledger.add(CustomerModel(
        address1: addressControl.text,
        address2: siteNameControl.text,
        address3: '',
        address4: ledgerModel!.address4 ?? '',
        balance: ledgerModel!.balance,
        city: ledgerModel!.city,
        email: ledgerModel!.email,
        id: ledgerModel!.id,
        name: ledgerModel!.name,
        phone: ledgerModel!.phone,
        remarks: ledgerModel!.remarks,
        route: ledgerModel!.route,
        state: ledgerModel!.state,
        stateCode: ledgerModel!.stateCode,
        taxNumber: ledgerModel!.taxNumber));

    var locationId =
        lId.toString().trim().isNotEmpty ? lId : salesTypeData!.location;
    invoiceNo =
        invoiceNoController.text.isNotEmpty ? invoiceNoController.text : '0';

    Order order = Order(
        customerModel: ledger,
        lineItems: cartItem,
        grossValue: totalGrossValue.toString(),
        discount: totalDiscount.toString(),
        rDiscount: totalRDiscount.toString(),
        net: totalNet.toString(),
        cGST: totalCgST.toString(),
        sGST: totalSgST.toString(),
        iGST: totalIgST.toString(),
        cess: totalCess.toString(),
        adCess: totalAdCess.toString(),
        fCess: totalFCess.toString(),
        total: totalCartValue.toString(),
        grandTotal:
            grandTotal > 0 ? grandTotal.toString() : totalCartValue.toString(),
        profit: totalProfit.toString(),
        cashReceived: controllerCashReceived.text.isNotEmpty
            ? controllerCashReceived.text
            : '0',
        otherDiscount: '0',
        loadingCharge: '0',
        otherCharges: '0',
        labourCharge: '0',
        discountPer: '0',
        balanceAmount: _balance > 0
            ? _balance.toStringAsFixed(decimal)
            : controllerCashReceived.text.isNotEmpty
                ? grandTotal > 0
                    ? ComSettings.appSettings(
                            'bool', 'key-round-off-amount', false)
                        ? (grandTotal -
                                double.tryParse(controllerCashReceived.text)!)
                            .toStringAsFixed(decimal)
                        : (grandTotal -
                                double.tryParse(controllerCashReceived.text)!)
                            .roundToDouble()
                            .toString()
                    : ComSettings.appSettings(
                            'bool', 'key-round-off-amount', false)
                        ? ((totalCartValue) -
                                double.tryParse(controllerCashReceived.text)!)
                            .toStringAsFixed(decimal)
                        : ((totalCartValue) -
                                double.tryParse(controllerCashReceived.text)!)
                            .roundToDouble()
                            .toString()
                : grandTotal > 0
                    ? ComSettings.appSettings(
                            'bool', 'key-round-off-amount', false)
                        ? grandTotal.toStringAsFixed(decimal)
                        : grandTotal.roundToDouble().toString()
                    : ComSettings.appSettings(
                            'bool', 'key-round-off-amount', false)
                        ? totalCartValue.toStringAsFixed(decimal)
                        : totalCartValue.roundToDouble().toString(),
        creditPeriod: '0',
        narration:
            controllerNarration.text.isNotEmpty ? controllerNarration.text : '',
        takeUser: userIdC.toString(),
        location: locationId.toString(),
        billType: companyTaxMode == 'GULF' ? '2' : '0',
        roundOff: '0',
        salesMan: salesManId.toString(),
        sType: salesTypeData!.rateType,
        dated: DateUtil.dateYMD(formattedDate),
        cashAC: acId.toString(),
        otherAmountData: otherAmountList);
    if (order.lineItems.isNotEmpty) {
      var jsonLedger = CustomerModel.encodeCustomerToJson(order.customerModel);
      var jsonItem = CartItem.encodeCartToJson(order.lineItems);
      var items = json.encode(jsonItem);
      var ledger = json.encode(jsonLedger);
      var otherAmount = json.encode(order.otherAmountData);
      var saleFormId = salesTypeData!.id;
      var saleFormType = salesTypeData!.type;
      var taxType = salesTypeData!.tax ? 'T' : 'NT';
      var salesRateTypeId =
          rateTypeItem != null ? rateTypeItem!.id.toString() : '1';
      var saleAccountId = saleAccount > 0 ? saleAccount.toString() : '0';
      var checkKFC = isKFC ? '1' : '0';
      double grandTotal = double.tryParse(order.grandTotal)! > 0
          ? (CommonService.getRound(
                  decimal, double.tryParse(order.grandTotal)!) +
              CommonService.getRound(
                  decimal, double.tryParse(order.loadingCharge)!) +
              CommonService.getRound(
                  decimal, double.tryParse(order.otherCharges)!) +
              CommonService.getRound(decimal, double.tryParse(order.adCess)!) +
              CommonService.getRound(
                  decimal, double.tryParse(order.labourCharge)!) -
              CommonService.getRound(
                  decimal, double.tryParse(order.otherDiscount)!))
          : 0;
      double roundOff = 0, different = 0;
      if (!ComSettings.appSettings('bool', 'key-round-off-amount', false)) {
        different = grandTotal - grandTotal.round();
        if (different < 0.5) {
          roundOff = CommonService.getRound(decimal, (different * -1));
        } else {
          roundOff = CommonService.getRound(1, (1 - different));
        }
      }
      var data = '[${json.encode({
            'statement': 'SalesInsert',
            'entryNo': 0,
            'invoiceNo': manualInvoiceNumberInSales ? invoiceNo : '0',
            'saleFormId': saleFormId,
            'saleFormType': saleFormType,
            'taxType': taxType,
            'date': order.dated,
            'time':
                '1900-01-01 ${DateFormat("H:m:s:S").format(DateTime.now())}', //1900-01-01 19:27:23.930
            'sType': salesRateTypeId,
            'saleAccountId': saleAccountId,
            'grossValue': order.grossValue,
            'discPercent': order.discountPer,
            'discount': order.discount,
            'rDiscount': order.rDiscount,
            'net': order.net,
            'cess': order.cess,
            'total': order.total,
            'profit': order.profit,
            'cGST': order.cGST,
            'sGST': order.sGST,
            'iGST': order.iGST,
            'addCess': order.adCess,
            'fCess': order.fCess,
            'otherDiscount': order.otherDiscount,
            'otherCharges': order.otherCharges,
            'loadingCharge': order.loadingCharge,
            'balanceAmount': ComSettings.appSettings(
                    'bool', 'key-round-off-amount', false)
                ? double.parse(order.balanceAmount).toStringAsFixed(decimal)
                : double.parse(order.balanceAmount).roundToDouble().toString(),
            'labourCharge': order.labourCharge,
            'grandTotal':
                ComSettings.appSettings('bool', 'key-round-off-amount', false)
                    ? grandTotal.toStringAsFixed(decimal)
                    : grandTotal.roundToDouble().toString(),
            'creditPeriod': order.creditPeriod,
            'takeUser': order.takeUser,
            'narration': order.narration,
            'cashReceived': order.cashReceived,
            'cashAC': order.cashAC,
            'check_kFC': checkKFC,
            'salesMan': order.salesMan,
            'location': order.location,
            'roundOff': roundOff,
            'billType': order.billType,
            'returnNo': returnBillId,
            'returnAmount': returnAmount,
            'otherAmount': _otherAmountTotal(order.otherAmountData),
            'fyId': currentFinancialYear!.id,
            'commissionAccount': commissionAccount ?? 0,
            'commissionAmount': commissionAmountController.text.isEmpty
                ? 0
                : commissionAmountController.text,
            'bankName': bankLedgerName ?? '',
            'bankAmount': bankAmountController.text.isEmpty
                ? 0
                : bankAmountController.text,
            'eVehicleNo': vehicleNameControl.text
          })}]';

      final body = {
        'information': ledger,
        'data': data,
        'particular': items,
        'serialNoData': json.encode(SerialNOModel.encodedToJson(serialNoData)),
      };
      debugPrint('body====${body.toString()}');
      if (saleAccountId != '0') {
        if (checkFinancialYear(DateUtil.dateYMD(formattedDate))) {
          if (manualInvoiceNumberInSales) {
            api.checkManualInvoiceNoStatus(invoiceNo).then((value) {
              if (!value) {
                postSale(body, otherAmount, order, saleFormType, saleFormId);
              } else {
                showErrorDialog(context, 'Duplicate Invoice No');
                setState(() {
                  _isLoading = false;
                  buttonEvent = false;
                });
              }
            });
          } else {
            postSale(body, otherAmount, order, saleFormType, saleFormId);
          }
        } else {
          showErrorDialog(
              context, "Date Is Incompatible With This Financial Year");

          setState(() {
            _isLoading = false;
            buttonEvent = false;
          });
        }
      } else {
        Fluttertoast.showToast(msg: "select SalesAccount");

        setState(() {
          _isLoading = false;
          buttonEvent = false;
        });
      }
    } else {
      Fluttertoast.showToast(msg: "Add item");

      setState(() {
        _isLoading = false;
        buttonEvent = false;
      });
    }
  }

  postSale(body, otherAmount, Order order, saleFormType, saleFormId) {
    api.addSale(body).then((result) {
      debugPrint('body====${result.toString()}');
      if (CommonService().isNumeric(result) && int.tryParse(result)! > 0) {
        final bodyJsonAmount = {
          'statement': 'SalesInsert',
          'entryNo': int.tryParse(result.toString()),
          'data': otherAmount,
          'date': order.dated.toString(),
          'saleFormType': saleFormType,
          'narration': order.narration,
          'location': order.location.toString(),
          'id': order.customerModel[0].id.toString(),
          'fyId': currentFinancialYear!.id
        };
        debugPrint(bodyJsonAmount.toString());
        if (salesTypeData!.accounts) {
          api.addOtherAmount(bodyJsonAmount).then((ret) {
            if (ret) {
              final bodyJson = {
                'statement': 'CheckPrint',
                'entryNo': int.tryParse(result.toString()),
                'sType': saleFormId.toString(),
                'grandTotal': ComSettings.appSettings(
                        'bool', 'key-round-off-amount', false)
                    ? grandTotal.toStringAsFixed(decimal)
                    : grandTotal.roundToDouble().toString()
              };
              api.checkBill(bodyJson).then((data) {
                if (data) {
                  dataDynamic = [
                    {
                      'RealEntryNo': int.tryParse(result.toString()),
                      'EntryNo': int.tryParse(result.toString()),
                      'InvoiceNo': int.tryParse(result.toString()),
                      'Type': saleFormId
                    }
                  ];
                  if (ComSettings.appSettings(
                      'bool', 'key-sms-customer', false)) {
                    var billName = salesTypeData!.name == "Sales Order Entry"
                        ? "Order"
                        : "Bill";
                    var ob = ledgerModel!.balance.toString().split(' ');
                    var ob1 = ob[0];
                    var ob2 = ob[1];
                    var amt = salesTypeData!.name == "Sales Order Entry"
                        ? ledgerModel!.balance
                        : ob2 == 'Dr'
                            ? double.tryParse(ob1)! +
                                double.tryParse(order.balanceAmount)!
                            : double.tryParse(order.balanceAmount)! -
                                double.tryParse(ob1)!;
                    String smsBody =
                        "Dear ${ledgerModel!.name},\nYour Sales $billName ${result.toString()}, Dated : $formattedDate for the Amount of ${order.grandTotal}/- \nBalance:$amt /- has been confirmed  \n${companySettings!.name}";
                    if (ledgerModel!.phone.toString().isNotEmpty) {
                      sendSms(ledgerModel!.phone, smsBody);
                    }
                  }
                  if (ComSettings.getStatus('ENABLE SMS OPTION', settings!)) {
                    //
                  }
                  clearCart();
                  showMore(context, true);
                }
              });
            }
          });
        } else {
          final bodyJson = {
            'statement': 'CheckPrint',
            'entryNo': int.tryParse(result.toString()),
            'sType': saleFormId.toString(),
            'grandTotal':
                ComSettings.appSettings('bool', 'key-round-off-amount', false)
                    ? grandTotal.toStringAsFixed(decimal)
                    : grandTotal.roundToDouble().toString()
          };
          api.checkBill(bodyJson).then((data) {
            if (data) {
              dataDynamic = [
                {
                  'RealEntryNo': int.tryParse(result.toString()),
                  'EntryNo': int.tryParse(result.toString()),
                  'InvoiceNo': int.tryParse(result.toString()),
                  'Type': saleFormId
                }
              ];
              if (ComSettings.appSettings('bool', 'key-sms-customer', false)) {
                var billName = salesTypeData!.name == "Sales Order Entry"
                    ? "Order"
                    : "Bill";
                var ob = ledgerModel!.balance.toString().split(' ');
                var ob1 = ob[0];
                var ob2 = ob[1];
                var amt = salesTypeData!.name == "Sales Order Entry"
                    ? ledgerModel!.balance
                    : ob2 == 'Dr'
                        ? double.tryParse(ob1)! +
                            double.tryParse(order.balanceAmount)!
                        : double.tryParse(order.balanceAmount)! -
                            double.tryParse(ob1)!;
                String smsBody =
                    "Dear ${ledgerModel!.name},\nYour Sales $billName ${result.toString()}, Dated : $formattedDate for the Amount of ${order.grandTotal}/- \nBalance:$amt /- has been confirmed  \n${companySettings!.name}";
                if (ledgerModel!.phone.toString().isNotEmpty) {
                  sendSms(ledgerModel!.phone, smsBody);
                }
              }
              if (ComSettings.getStatus('ENABLE SMS OPTION', settings!)) {
                //
              }
              clearCart();
              showMore(context, true);
            }
          });
        }
        setState(() {
          _isLoading = false;
        });
      } else {
        showErrorDialog(context, result.toString());
      }
    }).catchError((e) {
      showErrorDialog(context, e.toString());
    });
  }

  updateSale() {
    List<CustomerModel> ledger = [];
    ledger.add(CustomerModel(
        address1: addressControl.text,
        address2: siteNameControl.text,
        address3: ledgerModel!.address3,
        address4: ledgerModel!.address4,
        balance: ledgerModel!.balance,
        city: ledgerModel!.city,
        email: ledgerModel!.email,
        id: ledgerModel!.id,
        name: ledgerModel!.name,
        phone: ledgerModel!.phone,
        remarks: ledgerModel!.remarks,
        route: ledgerModel!.route,
        state: ledgerModel!.state,
        stateCode: ledgerModel!.stateCode,
        taxNumber: ledgerModel!.taxNumber));
    var locationId =
        lId.toString().trim().isNotEmpty ? lId : salesTypeData!.location;
    invoiceNo =
        invoiceNoController.text.isNotEmpty ? invoiceNoController.text : '0';

    Order order = Order(
        customerModel: ledger,
        lineItems: cartItem,
        grossValue: totalGrossValue.toString(),
        discount: totalDiscount.toString(),
        rDiscount: totalRDiscount.toString(),
        net: totalNet.toString(),
        cGST: totalCgST.toString(),
        sGST: totalSgST.toString(),
        iGST: totalIgST.toString(),
        cess: totalCess.toString(),
        adCess: totalAdCess.toString(),
        fCess: totalFCess.toString(),
        total: totalCartValue.toString(),
        grandTotal:
            grandTotal > 0 ? grandTotal.toString() : totalCartValue.toString(),
        profit: totalProfit.toString(),
        cashReceived: controllerCashReceived.text.isNotEmpty
            ? controllerCashReceived.text
            : '0',
        otherDiscount: '0',
        loadingCharge: '0',
        otherCharges: '0',
        labourCharge: '0',
        discountPer: '0',
        balanceAmount: _balance > 0
            ? _balance.toStringAsFixed(decimal)
            : controllerCashReceived.text.isNotEmpty
                ? grandTotal > 0
                    ? ComSettings.appSettings(
                            'bool', 'key-round-off-amount', false)
                        ? (grandTotal -
                                double.tryParse(controllerCashReceived.text)!)
                            .toStringAsFixed(decimal)
                        : (grandTotal -
                                double.tryParse(controllerCashReceived.text)!)
                            .roundToDouble()
                            .toString()
                    : ComSettings.appSettings(
                            'bool', 'key-round-off-amount', false)
                        ? ((totalCartValue) -
                                double.tryParse(controllerCashReceived.text)!)
                            .toStringAsFixed(decimal)
                        : ((totalCartValue) -
                                double.tryParse(controllerCashReceived.text)!)
                            .roundToDouble()
                            .toString()
                : grandTotal > 0
                    ? ComSettings.appSettings(
                            'bool', 'key-round-off-amount', false)
                        ? grandTotal.toStringAsFixed(decimal)
                        : grandTotal.roundToDouble().toString()
                    : ComSettings.appSettings(
                            'bool', 'key-round-off-amount', false)
                        ? totalCartValue.toStringAsFixed(decimal)
                        : totalCartValue.roundToDouble().toString(),
        creditPeriod: '0',
        narration:
            controllerNarration.text.isNotEmpty ? controllerNarration.text : '',
        takeUser: userIdC.toString(),
        location: locationId.toString(),
        billType: companyTaxMode == 'GULF' ? '2' : '0',
        roundOff: '0',
        salesMan: salesManId.toString(),
        sType: salesTypeData!.rateType,
        dated: DateUtil.dateYMD(formattedDate),
        cashAC: acId.toString(),
        otherAmountData: otherAmountList);
    if (order.lineItems.isNotEmpty) {
      var jsonLedger = CustomerModel.encodeCustomerToJson(order.customerModel);
      var jsonItem = CartItem.encodeCartToJson(order.lineItems);
      var items = json.encode(jsonItem);
      var ledger = json.encode(jsonLedger);
      var  otherAmount = json.encode(order.otherAmountData);
      var saleFormId = salesTypeData!.id;
      var saleFormType = salesTypeData!.type;
      var taxType = salesTypeData!.tax ? 'T' : 'NT';
      var salesRateTypeId =
          rateTypeItem != null ? rateTypeItem!.id.toString() : '1';
      var saleAccountId = saleAccount > 0 ? saleAccount.toString() : '0';
      var checkKFC = isKFC ? '1' : '0';
      double grandTotal = double.tryParse(order.grandTotal)! > 0
          ? (CommonService.getRound(
                  decimal, double.tryParse(order.grandTotal)!) +
              CommonService.getRound(
                  decimal, double.tryParse(order.loadingCharge)!) +
              CommonService.getRound(
                  decimal, double.tryParse(order.otherCharges)!) +
              CommonService.getRound(decimal, double.tryParse(order.adCess)!) +
              CommonService.getRound(
                  decimal, double.tryParse(order.labourCharge)!) -
              CommonService.getRound(
                  decimal, double.tryParse(order.otherDiscount)!))
          : 0;
      double roundOff = 0, different = 0;
      if (!ComSettings.appSettings('bool', 'key-round-off-amount', false)) {
        different = grandTotal - grandTotal.round();
        if (different < 0.5) {
          roundOff = CommonService.getRound(decimal, (different * -1));
        } else {
          roundOff = CommonService.getRound(1, (1 - different));
        }
      }
      var data = "[${json.encode({
            'statement': 'SalesUpdate',
            'entryNo': dataDynamic[0]['EntryNo'],
            'EditEntryNo': dataDynamic[0]['EntryNo'],
            'invoiceNo': manualInvoiceNumberInSales
                ? invoiceNo
                : dataDynamic[0]['InvoiceNo'].toString(),
            'saleFormId': saleFormId,
            'saleFormType': saleFormType,
            'taxType': taxType,
            'date': order.dated,
            'time':
                '1900-01-01 ${DateFormat("H:m:s:S").format(DateTime.now())}', //1900-01-01 19:27:23.930
            'sType': salesRateTypeId,
            'saleAccountId': saleAccountId,
            'grossValue': order.grossValue,
            'discPercent': order.discountPer,
            'discount': order.discount,
            'rDiscount': order.rDiscount,
            'net': order.net,
            'cess': order.cess,
            'total': order.total,
            'profit': order.profit,
            'cGST': order.cGST,
            'sGST': order.sGST,
            'iGST': order.iGST,
            'addCess': order.adCess,
            'fCess': order.fCess,
            'otherDiscount': order.otherDiscount,
            'otherCharges': order.otherCharges,
            'loadingCharge': order.loadingCharge,
            'balanceAmount': ComSettings.appSettings(
                    'bool', 'key-round-off-amount', false)
                ? double.parse(order.balanceAmount).toStringAsFixed(decimal)
                : double.parse(order.balanceAmount).roundToDouble().toString(),
            'labourCharge': order.labourCharge,
            'grandTotal':
                ComSettings.appSettings('bool', 'key-round-off-amount', false)
                    ? grandTotal.toStringAsFixed(decimal)
                    : grandTotal.roundToDouble().toString(),
            'creditPeriod': order.creditPeriod,
            'takeUser': order.takeUser,
            'narration': order.narration,
            'cashReceived': order.cashReceived,
            'cashAC': order.cashAC,
            'check_kFC': checkKFC,
            'salesMan': order.salesMan,
            'location': order.location,
            'roundOff': roundOff,
            'billType': order.billType,
            'returnNo': returnBillId,
            'returnAmount': returnAmount,
            'otherAmount': _otherAmountTotal(order.otherAmountData),
            'fyId': currentFinancialYear!.id,
            'commissionAccount': commissionAccount ?? 0,
            'commissionAmount': commissionAmountController.text.isEmpty
                ? 0
                : commissionAmountController.text,
            'bankName': bankLedgerName ?? 0,
            'bankAmount': bankAmountController.text.isEmpty
                ? 0
                : bankAmountController.text,
            'eVehicleNo': vehicleNameControl.text
          })}]";

      final body = {
        'information': ledger,
        'data': data,
        'particular': items,
        'serialNoData': json.encode(SerialNOModel.encodedToJson(serialNoData)),
      };
      if (saleAccountId != '0' && order.cashAC != '0') {
        api.editSale(body).then((result) {
          if (CommonService().isNumeric(result) && int.tryParse(result)! > 0) {
            final bodyJsonAmount = {
              'statement': 'SalesUpdate',
              'entryNo': dataDynamic[0]['EntryNo'].toString(),
              'data': otherAmount,
              'date': order.dated.toString(),
              'saleFormType': saleFormType,
              'narration': order.narration,
              'location': order.location.toString(),
              'id': order.customerModel[0].id.toString(),
              'fyId': currentFinancialYear!.id.toString()
            };
            if (salesTypeData!.accounts) {
              api.addOtherAmount(bodyJsonAmount).then((retNotUsed) {
                final bodyJson = {
                  'statement': 'CheckPrint',
                  'entryNo': dataDynamic[0]['EntryNo'].toString(),
                  'sType': dataDynamic[0]['Type'].toString(),
                  'grandTotal': ComSettings.appSettings(
                          'bool', 'key-round-off-amount', false)
                      ? grandTotal.toStringAsFixed(decimal)
                      : grandTotal.roundToDouble().toString()
                };
                api.checkBill(bodyJson).then((data) {
                  if (data) {
                    clearCart();
                    showMore(context, false);
                  }
                });
              });
            } else {
              final bodyJson = {
                'statement': 'CheckPrint',
                'entryNo': dataDynamic[0]['EntryNo'].toString(),
                'sType': dataDynamic[0]['Type'].toString(),
                'grandTotal': ComSettings.appSettings(
                        'bool', 'key-round-off-amount', false)
                    ? grandTotal.toStringAsFixed(decimal)
                    : grandTotal.roundToDouble().toString()
              };
              api.checkBill(bodyJson).then((data) {
                if (data) {
                  clearCart();
                  showMore(context, false);
                }
              });
               }
            setState(() {
              _isLoading = false;
            });
          } else {
            showErrorDialog(context, result.toString());
          }
           }).catchError((e) {
          showErrorDialog(context, e.toString());
        });
      } else {
        Fluttertoast.showToast(msg: "select SalesAccount or CashAccount");
      }
    }
  }

  deleteSale(context) {
    ConfirmAlertBox(
        buttonColorForNo: Colors.red,
        buttonColorForYes: Colors.green,
        icon: Icons.check,
        onPressedNo: () {
          Navigator.of(context).pop();
          setState(() {
            _isLoading = false;
          });
        },
        onPressedYes: () {
          Navigator.of(context).pop();
          deleteSaleData();
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage: 'Do you want to Delete',
        title: 'Delete Bill',
        context: context);
  }

  deleteSaleData() {
    api
        .deleteSale(
            dataDynamic[0]['EntryNo'], salesTypeData!.id, salesTypeData!.type)
        .then((value) {
      setState(() {
        _isLoading = false;
      });
      if (value) {
        setState(() {
          buttonEvent = false;
        });
        clearCart();
        cartItem.clear();
         Navigator.pushReplacementNamed(
                          context, '/sales',
                          arguments: Sale(thisSale: thisSale, oldSale: true));
        Fluttertoast.showToast(
          backgroundColor: green,
          msg: 'Sale Bill Deleted');                  
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return Expanded(
        //       child: AlertDialog(
        //         title: const Text('Sale Deleted'),
        //         actions: [
        //           TextButton(
        //             onPressed: () {
        //               Navigator.of(context).pop();
        //               Navigator.pushReplacementNamed(
        //                   context, '/sales',
        //                   arguments: Sale(thisSale: thisSale, oldSale: true));
        //             },
        //             child: const Text('CANCEL'),
        //           )
        //         ],
        //       ),
        //     );
        //   },
        // );
      }
    });
  }

  int nextWidget = 0;
  selectWidget() {
    return nextWidget == 0
        ? loadScanner
            ? scannerWidget()
            : newSaleWidget(newSale)
        // selectLedgerWidget()
        : nextWidget == 1
            ? selectLedgerWidget()
            //  selectLedgerDetailWidget()
            : nextWidget == 2
                ? addItemWidget()
                // selectProductWidget()
                : nextWidget == 3
                    ? SizedBox()
                    : nextWidget == 4
                        ? cartProduct()
                        : nextWidget == 5
                            ? const Text('No Data 5')
                            : nextWidget == 6
                                ? const Text('No Data 6')
                                : const Text('No Widget');
  }

  getEntryNo(saleFormId) {
    api.getSalesInvoiceNo(saleFormId,'SEntryNo').then((value) {
      setState(() {
        invoiceNo = (int.parse(value.toString()) + 1).toString();
        invoiceNoController.text = invoiceNo;
      });
    });
  }

  selectSalesType() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: isCustomForm ? salesTypeDisplay.length : salesTypeList.length,
      itemBuilder: (context, index) {
        return _listSalesTypItem(index);
      },
    );
  }

  _listSalesTypItem(index) {
    return Column(
      children: [
        InkWell(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: grey)),
            child: ListTile(
                title: Text(
              isCustomForm
                  ? salesTypeDisplay[index].name
                  : salesTypeList[index].name,
              style: const TextStyle(fontFamily: 'poppins'),
            )),
          ),
          onTap: () {
            setState(() {
              salesTypeData =
                  isCustomForm ? salesTypeDisplay[index] : salesTypeList[index];
              previewData = true;
              taxable = isTaxTypeLocked
                  ? isTaxTypeLocked
                  : (salesTypeData != null ? salesTypeData!.tax : taxable);
              rateTypeItem = rateTypeList.isEmpty
                  ? null
                  : rateTypeList.firstWhere((element) =>
                      element.name == salesTypeData!.rateType.toUpperCase());
              getEntryNo(salesTypeData!.id);
            });
          },
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }

  var nameLike = "a";
  selectLedgerWidget() {
    return FutureBuilder<List<LedgerModel>>(
      future: isSalesManWiseLedger
          ? api.getLedgerBySalesManLike(salesManId, nameLike)
          : api.getCustomerNameListLike(
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
                                autofocus: true,
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
                            ledgerDataModel = data[index - 1];
                            nextWidget = 0;
                            isData = false;
                          });
                        },
                      );
              },
              itemCount: data!.length + 1,
            );
          } else {
            return ListView(children: [
              Padding(
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
                        autofocus: true,
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
              ),
              Card(
                color: grey.shade300,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text('No Ledger Found'),
                      ],
                    ),
                  ),
                ),
              )
            ]);
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

  // Future _selectDate(String type) async {
  //   DateTime? picked = await showDatePicker(
  //       context: context,
  //       initialDate: DateTime.now(),
  //       firstDate: DateTime(2000),
  //       lastDate: DateTime(2100));
  //   if (picked != null) {
  //     setState(() => {
  //           if (type == 'f')
  //             {formattedDate = DateFormat('dd-MM-yyyy').format(picked)}
  //           // else
  //           //   {toDate = DateFormat('dd-MM-yyyy').format(picked)}
  //         });
  //   }
  // }

  final expandedHeight = 472.0;
  final collapsedHeight =   230.0;
  final collaps = 300.0;
  final animationDuration = const Duration(milliseconds: 400);
  bool isExpanded = false;
  final namesLike = 'a';
  var selectedCustomer;
  int selectedTabIndex = 0;
  var filterCashAccount;
  var filteredName;
  
void _onTabTapped(int index) {
  setState(() {
    selectedTabIndex = index;
  });

  if (index == 1) {
    setState(() {
      selectedCustomerId = acId;
      
      final csDetails = api.getCustomerDetail(acId);
      
      csDetails.then((value) { 
        setState(() {
          ledgerModel = value;

          filterCashAccount = cashAccount.where((element) {
            return element.key == selectedCustomerId;
          }).toList();

          filteredName = filterCashAccount.map((element) {
            return element.value; 
          }).join(', ');

          ledgerModel!.name = filteredName.toString(); 

          // print(filteredName);
        });
      });
    });
  }
  else{
    setState(() {
      selectedCustomerId != acId;
    });
  }
}


  // void _onTabTapped(int index) {
  // setState(() {
  //   selectedTabIndex = index;
  // });
  // if (index == 1) {

  //   setState(() {
  //    selectedCustomerId =  acId;
  //     final csDetails = api.getCustomerDetail(acId);
      
  //     csDetails.then((value)  { 
  //       ledgerModel = value;
  //       ledgerModel!.name = filteredName.toString(); 
  //     });
  //     filterCashAccount = cashAccount.firstWhere((element) {
  //           return element.key == selectedCustomerId;
  //         }).toList();
  //         print(filterCashAccount);
          
  //          filteredName = filterCashAccount.map((element) {
  //       return element.key.toString(); 
        
  //     });
  //     print(filteredName);

  //   });
    
       
  //   // ref.watch(customersProvider).whenData((data) {
  //   //   LedgerModel? cashCustomer;
  //   //   try {

  //   //     cashCustomer = data.firstWhere((customer) => customer.name == 'CASH');
  //   //   } catch (e) {
  //   //     cashCustomer = null;
  //   //   }

  //   //   setState(() {
  //   //     if (cashCustomer != null) {
  //   //       selectedCustomerId = cashCustomer.id;
  //   //       final csDetails = api.getCustomerDetail(cashCustomer.id);
  //   //       csDetails.then((value) => ledgerModel = value,);

  //   //       print(acId);
  //   //       print("Selected Customer ID: $selectedCustomerId, Name: ${cashCustomer.name}");
  //   //     } else {
  //   //       selectedCustomerId = null;
  //   //     }
  //   //   });
  //   //  });
  //   }
  // }
  TabController? tabController;
  newSaleWidget(newSale) {
    if (newSale) {
      setState(() {
        newSale = true;
      });
    }
    return DefaultTabController(
      initialIndex: selectedTabIndex,
      animationDuration: const Duration(milliseconds: 1),
      length: 2,
      child: Scaffold(
        backgroundColor: bagroundColor,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 60,
          title:  Text(
            salesTypeData!.type,
            style: const TextStyle(fontFamily: 'poppins'),
          ),
          actions: [
           !oldBill? Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: white,
              ),
              width: 130,
              child: TabBar(
                onTap: _onTabTapped,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: green,
                  unselectedLabelColor: black,
                  dividerHeight: 0,
                  labelStyle: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 10,
                  ),
                  padding: const EdgeInsets.all(1),
                  indicator: BoxDecoration(
                      color: green, borderRadius: BorderRadius.circular(30)),
                  tabs: const [
                    Tab(
                      text: 'Credit',
                      // child: SizedBox(
                      //   // width: 65,
                      //   child: Text('Credit'),
                      // ),
                    ),
                    Tab(
                      text: 'Cash',
                    )
                  ]),
            ):const SizedBox(),
            const SizedBox(
              width: 10,
            ),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.settings,
                  color: white,
                )),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: TabBarView(
           physics: const NeverScrollableScrollPhysics(),
          children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: bagroundColor,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      color: white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: ContainerFieldWidget(
                                  widget: 
                                  // InkWell(
                                  //   onTap: () {
                                  //     // showModalBottomSheet(
                                  //     //   context: context,
                                  //     //   builder: (BuildContext context) =>
                                  //     //       Padding(
                                  //     //     padding: EdgeInsets.only(
                                  //     //         bottom: MediaQuery.of(context).viewInsets.bottom),
                                  //     //     child: Padding(
                                  //     //       padding: const EdgeInsets.all(8.0),
                                  //     //       child: Column(
                                  //     //         children: [
                                  //     //           const SizedBox(height: 16),
                                  //     //           TextField(
                                  //     //             decoration: const  InputDecoration(
                                  //     //                     border: OutlineInputBorder(),
                                  //     //                     // hintText:
                                  //     //                     //     'Invoice No',
                                  //     //                     labelText:'Enter invoice no'),
                                  //     //             controller: invoiceNoController,
                                  //     //             autofocus: true,
                                  //     //           ),
                                  //     //           const SizedBox(height: 10),
                                  //     //           ElevatedButton(
                                  //     //             style: ElevatedButton.styleFrom(
                                  //     //                 backgroundColor: kPrimaryColor,
                                  //     //                 shape: RoundedRectangleBorder(
                                  //     //                 borderRadius:BorderRadius.circular(3))),
                                  //     //             onPressed: () {
                                  //     //               Navigator.of(context).pop();
                                  //     //               setState(() {});
                                  //     //             },
                                  //     //             child: const Text("Done",
                                  //     //                 style: TextStyle(
                                  //     //                     fontFamily: 'poppins',
                                  //     //                     color: white)),
                                  //     //           ),
                                  //     //         ],
                                  //     //       ),
                                  //     //     ),
                                  //     //   ),
                                  //     // );
                                  //   },
                                  //   child: Container(
                                  //     margin: const EdgeInsets.only(
                                  //       bottom: 15,
                                  //     ),
                                  //     width: MediaQuery.of(context).size.width,
                                  //     padding: const EdgeInsets.symmetric(horizontal: 5),
                                  //     height: 20,
                                  //     decoration: BoxDecoration(
                                  //         border: Border.all(color: grey),
                                  //         borderRadius: BorderRadius.circular(3)),
                                  //     child: Row(
                                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //       children: [
                                  //         Text(invoiceNoController.text,
                                  //             style: const TextStyle(
                                  //                 fontWeight: FontWeight.w500,
                                  //                 fontSize: 16,
                                  //                 fontFamily: 'poppins')),
                                  //         // const Icon(
                                  //         //     Icons.arrow_drop_down_sharp,
                                  //         //     color: black)
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 15,
                                    ),
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14
                                      ),
                                      controller: invoiceNoController,
                                      decoration:  InputDecoration(
                                      
                                         prefixIcon: Visibility(
                                          visible: isAdminUser,
                                           child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Icon(Icons.keyboard_double_arrow_left_rounded),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                             InkWell(
                                                  onTap: () {
                                                   var invoiceNum = invoiceNo;
                                           
                                                  setState(() {
                                                   int invoiceNumber = int.parse(invoiceNum); 
                                                   invoiceNumber--; 
                                                   invoiceNum = invoiceNumber.toString(); 
                                                 });
                                           
                                                debugPrint(invoiceNum.toString());
                                           
                                            dataDynamic = [
                                             {
                                             'Type': salesTypeData!.type,
                                             'InvoiceNo': invoiceNum,
                                             'EntryNo': int.parse(invoiceNum) ?? 0,
                                             'Id': int.parse(invoiceNum) ?? 0
                                             }
                                                                                   ];
                                                                                   cartItem.clear();
                                                                                  fetchSale(context, dataDynamic[0]);
                                                                                 },
                                                                                  child: const Icon(
                                           Icons.arrow_back_ios_rounded,
                                           // size: 16, 
                                                                                ),
                                                                             ),
                                           
                                            ],
                                                                                   ),
                                         ),
                                        suffixIcon: Visibility(
                                          visible: isAdminUser,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                     var invoiceNum = invoiceNo;
                                          
                                                  setState(() {
                                                   int invoiceNumber = int.parse(invoiceNum); 
                                                   invoiceNumber++; 
                                                   invoiceNum = invoiceNumber.toString(); 
                                                 });
                                          
                                                debugPrint(invoiceNum.toString());
                                          
                                            dataDynamic = [
                                             {
                                             'Type': salesTypeData!.type,
                                             'InvoiceNo': invoiceNum,
                                             'EntryNo': int.parse(invoiceNum) ?? 0,
                                             'Id': int.parse(invoiceNum) ?? 0
                                             }
                                          ];
                                                                                 cartItem.clear();
                                                                                 try {
                                           fetchSale(context, dataDynamic[0]);
                                                                                 } catch (e) {
                                           if (e is RangeError) {
                                              showDialog(
                                                   context: context,
                                                   builder: (BuildContext context) {
                                                    return AlertDialog(
                                                           title: const Text("Error"),
                                                           content: const Text("An error occurred while fetching the Sale Bill Invalid value."),
                                                           actions: [
                                                            TextButton(
                                                             child: const Text("OK"),
                                                             onPressed: () {
                                                             Navigator.of(context).pop(); 
                                                          },
                                                        ),
                                                      ],
                                                   );
                                                 },
                                              );
                                           }else {
                                              debugPrint("An unexpected error occurred: $e");
                                           }
                                                                                 }
                                                },
                                                child: const Icon(Icons.arrow_forward_ios_rounded)),
                                                const SizedBox(
                                                  width: 4,
                                                )
                                              //  Icon(Icons.keyboard_double_arrow_right_rounded),
                                            ],
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          maxHeight: 40
                                        ),
                                          contentPadding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 8),
                                          border: const OutlineInputBorder()),
                                    ),
                                  ),
                                  headTxt: 'Entry No')),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                              child: ContainerFieldWidget(
                                  widget: InkWell(
                                    onTap: () {
                                      _selectDate();
                                    },
                                    child: Container(
                                      height: 40,
                                      margin: const EdgeInsets.only(
                                        bottom: 15,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          border: Border.all(color: grey)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            formattedDate!,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                fontFamily: 'poppins'),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          const Icon(
                                            Icons.calendar_month_outlined,
                                            color: grey,
                                            size: 25,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  headTxt: 'Date')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      color: white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: ContainerFieldWidget(
                          widget: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                border: Border.all(color: grey),
                                borderRadius: BorderRadius.circular(3)),
                            child: widgetRateType(),
                          ),
                          headTxt: 'Sales Rate'),
                    ),
                    const SizedBox(height: 15),
                    AnimatedContainer(
                      duration: animationDuration,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      height: isExpanded 
                      ? expandedHeight
                      : oldBill 
                      ? selectedCustomerId == acId 
                      ? collaps 
                      :collapsedHeight 
                      : collapsedHeight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            ' Customer',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // SizedBox(
                          //   width: MediaQuery.of(context).size.width,
                          //   height: 55,
                          //   child: InkWell(
                          //     onTap: () {
                          //       setState(() {
                          //         nextWidget = 1;
                          //       });
                          //     },
                          // )),
                          ref.watch(customersProvider).when(
                                data: (data) {
                                  // ledgerModel = data;
                                  List<String> names =
                                      data.map((e) => e.name).toList();
                                  return EasyAutocomplete(
                                    autofocus: false,
                                    progressIndicatorBuilder: isLoading
                                        ? const CircularProgressIndicator()
                                        : null,
                                    controller: nameControl,
                                    
                                    inputTextStyle: const TextStyle(
                                        fontFamily: 'poppins', fontSize: 14),
                                    suggestionTextStyle:
                                        const TextStyle(fontFamily: 'poppins'),
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 5),
                                        border: OutlineInputBorder()),
                                    suggestions:  names,
                                    onChanged: (value) {
                                      // fetchSuggestions(value);
                                    },
                                    onSubmitted: (value) {
                                      setState(() {
                                         selectedCustomer = data.firstWhere(
                                          (element) => element.name == value,
                                        );
                                        selectedCustomerId = selectedCustomer.id;
                                        final details = api.getCustomerDetail(selectedCustomerId!); 
                                        details.then((value) => ledgerModel = value);
                                        print('Customer id : $selectedCustomerId');
                                      });
                                      ledgerDataModel= selectedCustomer;
                                 
                                      // final selectedCustomerId =
                                      //     nameToIdMap[value];

                                      // if (selectedCustomerId != null) {
                                      //   print(
                                      //       'Selected customer ID: $selectedCustomerId');
                                      // } else {
                                      //   print(
                                      //       'No matching customer found for the selected value.');
                                      // }
                                    },
                                  );
                                },
                                error: (error, stackTrace) {
                                  return Text(error.toString());
                                },
                                loading: () =>
                                    const Center(child: CircularProgressIndicator()),
                              ),
                          const SizedBox(
                            height: 6,
                          ),
                     oldBill ? selectedCustomerId == acId?  Column(
                      children: [
                        ContainerFieldWidget(widget: TextField(
                      controller: TextEditingController(text: ledgerModel!.name),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 5),
                        border: OutlineInputBorder()
                      ),
                     ), headTxt: 'Billing Name'),
                     const SizedBox(
                      height: 4,
                     )
                      ],
                     ): const SizedBox() : const SizedBox(),
                    //  const SizedBox(
                    //   height: 4,
                    //  ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Theme(
                                    data: ThemeData(
                                        dividerColor: Colors.transparent),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: grey),
                                          borderRadius:
                                              BorderRadius.circular(3)),
                                      child: ExpansionTile(
                                        // enableFeedback: false,
                                        controlAffinity:
                                            ListTileControlAffinity.platform,
                                        title: const Text(
                                          'Other',
                                          style: TextStyle(
                                            fontFamily: 'poppins',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 8),
                                            child:
                                             selectedCustomerId != null
                                                ? 
                                                 FutureBuilder(
                                                    future: selectedCustomerId !=
                                                            null
                                                        ? api.getCustomerDetail(
                                                            selectedCustomerId!)
                                                        : api.getCustomerDetail(
                                                            0),
                                                    builder:
                                                        (context, snapshot) {
                                                      // if (snapshot.data ==
                                                      //     null) {
                                                      //   return const SizedBox();
                                                      // }
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const CircularProgressIndicator();
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                            'Error: ${snapshot.error}');
                                                      } else if (!snapshot
                                                          .hasData) {
                                                        return const Text(
                                                            'No data found');
                                                      }
                                                      ledgerModel = snapshot.data!;
                                  ledgerModel!.name = ledgerModel!.name;
                                  ledgerModel!.address1 = ledgerModel!.address1;
                                  ledgerModel!.address2 = ledgerModel!.address2;
                                  ledgerModel!.address3 = ledgerModel!.address3;
                                  ledgerModel!.address4 = ledgerModel!.taxNumber ;
                                                      final data =
                                                          snapshot.data;
                                                      addressControl.text =
                                                          "${ledgerModel!.address1} ${data!.address2} ${data.address3}";
                                                      return Column(
                                                        children: [
                                                          ContainerFieldWidget(
                                                              widget: TextField(
                                                                maxLines: null,
                                                                controller:
                                                                    addressControl,
                                                                readOnly: true,
                                                                decoration: const InputDecoration(
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            5),
                                                                    border:
                                                                        OutlineInputBorder()),
                                                              ),
                                                              headTxt:
                                                                  'Address'),
                                                          const SizedBox(
                                                              height: 6),
                                                          ContainerFieldWidget(
                                                              widget: TextField(
                                                                controller: TextEditingController(
                                                                    text: snapshot
                                                                        .data!
                                                                        .phone),
                                                                decoration: const InputDecoration(
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            5),
                                                                    border:
                                                                        OutlineInputBorder()),
                                                              ),
                                                              headTxt: 'Phone'),
                                                          const SizedBox(
                                                              height: 6),
                                                           ContainerFieldWidget(
                                                              widget: Container(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                alignment: Alignment.centerLeft,
                                                                width: MediaQuery.of(context).size.width,
                                                                height: 30,
                                                                decoration: BoxDecoration(border: Border.all(color: grey),borderRadius: BorderRadius.circular(3)),
                                                                child: Text(ledgerModel!.taxNumber!),
                                                              ),
                                                              headTxt: 'Tax Number'),
                                                        ],
                                                      );
                                                    }):Column(
                                                        children: [
                                                          ContainerFieldWidget(
                                                              widget: TextField(
                                                                maxLines: null,
                                                                controller:
                                                                    addressControl,
                                                                readOnly: true,
                                                                decoration: const InputDecoration(
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            5),
                                                                    border:
                                                                        OutlineInputBorder()),
                                                              ),
                                                              headTxt:
                                                                  'Address'),
                                                          const SizedBox(
                                                              height: 6),
                                                          ContainerFieldWidget(
                                                              widget: TextField(
                                                                controller: TextEditingController(
                                                                    text: ''),
                                                                decoration: const InputDecoration(
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            5),
                                                                    border:
                                                                        OutlineInputBorder()),
                                                              ),
                                                              headTxt: 'Phone'),
                                                          const SizedBox(
                                                              height: 6),
                                                           ContainerFieldWidget(
                                                              widget:  TextField(
                                                                controller: TextEditingController(
                                                                    text: ''),
                                                                decoration: const InputDecoration(
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            5),
                                                                    border:
                                                                        OutlineInputBorder()),
                                                              ),
                                                              headTxt: 'Tax Number'),
                                                        ],
                                                      ),
                                          )
                                        ],
                                        onExpansionChanged: (newIsExpanded) {
                                          setState(() {

                                            isExpanded = newIsExpanded;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (selectedCustomerId == null) {
              Fluttertoast.showToast(
                msg: 'Select Customer',
                backgroundColor: Colors.red,
              );
            } else {
              setState(() {
                if (ledgerModel!.name!.toUpperCase() == 'CASH') {
                  // if (salesTypeData!.rateType.isNotEmpty) {
                  //   rateType = salesTypeData!.id.toString();
                  // }
                  nextWidget = 2;
                } else {
                  if (salesTypeData!.type == 'SALES-BB') {
                    if (ledgerModel!.taxNumber!.isNotEmpty) {
                      // if (salesTypeData!.rateType.isNotEmpty) {
                      //   rateType = salesTypeData!.id.toString();
                      // }
                      nextWidget = 2;
                    } else if (!blockTaxLedgerOnB2CorBOS) {
                      // if (salesTypeData!.rateType.isNotEmpty) {
                      //   rateType = salesTypeData!.id.toString();
                      // }
                      nextWidget = 2;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('B2B Invoice not allowed without a TAX number'),
                      ));
                    }
                  } else {
                    if (blockTaxLedgerOnB2CorBOS) {
                      if ((salesTypeData!.type == 'SALES-BC' || salesTypeData!.type == 'SALES-BOS') &&
                          ledgerModel!.taxNumber!.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tax Registered Ledger')),
                        );
                        return;
                      }
                    }
                    // if (salesTypeData!.rateType.isNotEmpty) {
                    //   rateType = salesTypeData!.id.toString();
                    // }
                    editItem = false;
                    nextWidget = 2;
                  }
                }
              });
            }
                              
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => addItemWidget(),
                              //     ));
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              backgroundColor: const Color(0xff0008B3),
                            ),
                            // onPressed: () => context.push(AddItemToSalePage.routePath),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Image(
                                //     image: AssetImage(
                                //         'assets/icons/add_item_icon.png')),
                                SizedBox(width: 10),
                                Text(
                                  'Add Item',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'poppins',
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    cartItem.isNotEmpty
                        ? Container(
                             constraints: const BoxConstraints(maxHeight: 300),
                          // height: 250,
                            width: MediaQuery.sizeOf(context).width,
                            color: white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 4),
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics() ,
                                itemCount: cartItem.length ,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        editItem = true;
                                        clearValue();
                                        position = index;
                                        cartModel =
                                            cartItem.elementAt(position!);
                                            debugPrint(cartModel!.unitValue.toString());
                                            selectedItemId = cartModel!.itemId;
                                            uniqueCode = cartModel!.uniqueCode!;
                                        itemNameControl.text =
                                            cartModel!.itemName.toString();
                                        _rateController.text =
                                            cartModel!.rate!.toStringAsFixed(decimal);
                                            rate = cartModel!.rate!;
                                        _quantityController.text =
                                            cartModel!.quantity!.toString();
                                        _freeQuantityController.text =
                                            cartModel!.free.toString();
                                        _discountController.text =
                                            cartModel!.discount.toString();
                                        _discountPercentController.text =
                                            cartModel!.discountPercent
                                                .toString();
                                        _serialNoController.text =
                                            cartModel!.serialNo!;
                                        _dropDownUnit = cartModel!.unitId!;
                                        // unitValue = _conversion;
                                        // taxP = cartModel!.taxP!;
                                        // tax = cartModel!.tax!;
                                        // taxP = (salesTypeData!.type == 'SALES-ES'
                                        // ? cartModel!.taxP 
                                        // :0)!;
                                        // tax = (salesTypeData!.type == 'SALES-ES'
                                        // ? cartModel!.tax 
                                        // :0)!;
                                        salesTypeData!.type != 'SALES-EC'
                                        ? taxP = cartModel!.taxP!
                                        : taxP = 0;
                                        salesTypeData!.type != 'SALES-EC'
                                        ? tax = cartModel!.tax!
                                        : tax = 0;
                                        gross = 
                                         cartModel!.gross!;
                                        total = cartModel!.total!;
                                        cartModel!.uniqueCode = uniqueCode;
                                        unitValue = cartModel!.unitValue!;
                                         unit = DataJson(
                                              id: cartModel!.unitId,
                                              name: cartModel!.itemName!,
                                            );
                                        nextWidget = 2;
                                      });
                                      
                                    },
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          // boxShadow: [
                                          //   BoxShadow(
                                          //     color: Colors.grey.shade400,
                                          //     blurRadius: 5,
                                          //     spreadRadius: .8,
                                          //   )
                                          // ],
                                          border: Border.all(
                                              color: grey, width: .5),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          color:
                                              Colors.grey.withOpacity(.1)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width,
                                              child: Row(children: [
                                                Container(
                                                    padding:const EdgeInsets.symmetric(horizontal: 5),
                                                    decoration:BoxDecoration(
                                                            color: white,
                                                            borderRadius:BorderRadius.circular(3),
                                                            border: Border.all(
                                                              width: .3,
                                                              color: grey,
                                                            )),
                                                    child: Text('# ${index + 1}',
                                                      style: const TextStyle( fontSize: 12),
                                                    )),
                                                Text(' ${cartItem[index].itemName}',
                                                    style: const TextStyle(
                                                        color: black,
                                                        fontWeight:FontWeight.w500,
                                                        fontFamily:'poppins')),
                                                const Spacer(),
                                                // PopUpMenuAction(
                                                //   onDelete: () {
                                                //     setState(() {
                                                //       removeProduct(index);
                                                //     });
                                                //   },
                                                //   onEdit: () {
                                                //     setState(() {
                                                //       editItem = true;
                                                //       position = index;
                                                //       cartModel = cartItem
                                                //           .elementAt(position!);
                                                //       _rateController.text =
                                                //           cartModel!.rate!
                                                //               .toString();
                                                //       _quantityController.text =
                                                //           cartModel!.quantity!
                                                //               .toString();
                                                //       _freeQuantityController
                                                //               .text =
                                                //           cartModel!.free
                                                //               .toString();
                                                //       _discountController.text =
                                                //           cartModel!.discount
                                                //               .toString();
                                                //       _discountPercentController
                                                //               .text =
                                                //           cartModel!
                                                //               .discountPercent
                                                //               .toString();
                                                //       _serialNoController.text =
                                                //           cartModel!.serialNo!;
                                                //       _dropDownUnit =
                                                //           cartModel!.unitId!;
                                                //       nextWidget = 3;
                                                //     });
                                                //   },
                                                // ),
                                                // RichText(
                                                //   overflow: TextOverflow.ellipsis,
                                                //   maxLines: 1,
                                                //   text: TextSpan(
                                                //       text:
                                                //           ' ${cartItem[index].itemName}\n',
                                                //       style: const TextStyle(
                                                //           color: black,
                                                //           fontWeight:
                                                //               FontWeight.w500,
                                                //           fontFamily: 'poppins')),
                                                // ),
                                              ]),
                                            ),
                                            SizedBox(width: MediaQuery.of(context).size.width,
                                              child: Row(
                                                children: [
                                                  const Text('Item Subtotal',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:'poppins'),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    "${cartItem[index].quantity!.toStringAsFixed(0)} ${UnitSettings.getUnitName(cartItem[index].unitId??0)} x ${(selectedTaxOption == 'With Tax' ? cartItem[index].rRate!.toStringAsFixed(2) : cartItem[index].rate!.toStringAsFixed(2))} = ₹ ${cartItem[index].gross}",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                                width:
                                                    MediaQuery.of(context).size.width,
                                                child: Row(
                                                  children: [
                                                    Text('Discount (%): ',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.orange[700],
                                                          fontFamily:'poppins'),
                                                    ),
                                                    Text(
                                                      cartItem[index].discountPercent!.toStringAsFixed(2),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.orange[700],
                                                          fontFamily:'poppins'),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      '₹ ${cartItem[index].discount!.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.orange[700],
                                                      ),
                                                    )
                                                  ],
                                                )),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width,
                                              child: Row(children: [
                                                Text('Tax (%): ${cartItem[index].taxP}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '₹ ${cartItem[index].tax!.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ]),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width,
                                              child: Row(children: [
                                                const Text(
                                                  'Total',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:FontWeight.w500),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '₹ ${cartItem[index].total!.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:FontWeight.w500),
                                                ),
                                              ]),
                                            ),
                                            // Row(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment.spaceEvenly,
                                            //   mainAxisSize: MainAxisSize.max,
                                            //   children: [
                                            //     SizedBox(
                                            //       width: 100,
                                            //       child: Column(
                                            //         crossAxisAlignment:
                                            //             CrossAxisAlignment.start,
                                            //         children: [
                                            //           // const SizedBox(
                                            //           //   height: 1.0,
                                            //           // ),
                                            //           RichText(
                                            //             maxLines: 1,
                                            //             text: TextSpan(
                                            //                 text:
                                            //                     '${cartItem[index].id}/',
                                            //                 style: TextStyle(
                                            //                     color: Colors
                                            //                         .blueGrey
                                            //                         .shade800,
                                            //                     fontSize: 10.0),
                                            //                 children: [
                                            //                   TextSpan(
                                            //                       text:
                                            //                           '${cartItem[index].uniqueCode}/${cartItem[index].itemId}',
                                            //                       style: const TextStyle(
                                            //                           fontSize:
                                            //                               10.0,
                                            //                           fontWeight:
                                            //                               FontWeight
                                            //                                   .bold)),
                                            //                 ]),
                                            //           ),
                                            //           RichText(
                                            //             maxLines: 1,
                                            //             text: TextSpan(
                                            //                 text: 'Unit: ',
                                            //                 style: TextStyle(
                                            //                     color: Colors
                                            //                         .blueGrey
                                            //                         .shade800,
                                            //                     fontSize: 12.0),
                                            //                 children: [
                                            //                   TextSpan(
                                            //                       text:
                                            //                           '${UnitSettings.getUnitName(cartItem[index].unitId!)}\n',
                                            //                       style: const TextStyle(
                                            //                           fontSize:
                                            //                               12.0,
                                            //                           fontWeight:
                                            //                               FontWeight
                                            //                                   .bold)),
                                            //                 ]),
                                            //           ),
                                            //         ],
                                            //       ),
                                            //     ),
                                            //     // PlusMinusButtons(
                                            //     //   addQuantity: () {
                                            //     //     if (oldBill) {
                                            //     //       api
                                            //     //           .getStockOf(
                                            //     //               cartItem[index]
                                            //     //                   .itemId!)
                                            //     //           .then((value) {
                                            //     //         cartItem[index].stock =
                                            //     //             value;
                                            //     //         setState(() {
                                            //     //           bool cartQ = false;
                                            //     //           if (totalItem > 0) {
                                            //     //             double cartS = 0,
                                            //     //                 cartQt = 0;
                                            //     //             for (var element
                                            //     //                 in cartItem) {
                                            //     //               if (element
                                            //     //                       .itemId ==
                                            //     //                   cartItem[index]
                                            //     //                       .itemId) {
                                            //     //                 cartQt += element
                                            //     //                     .quantity!;
                                            //     //                 cartS = element
                                            //     //                     .stock!;
                                            //     //               }
                                            //     //             }
                                            //     //             cartS = oldBill
                                            //     //                 ? value
                                            //     //                 : cartS;
                                            //     //             if (cartS > 0) {
                                            //     //               if (cartS <
                                            //     //                   cartQt + 1) {
                                            //     //                 cartQ = true;
                                            //     //               }
                                            //     //             }
                                            //     //           }
                                            //     //           outOfStock = isLockQtyOnlyInSales
                                            //     //               ? cartItem[index].quantity! + 1 > cartItem[index].stock!
                                            //     //                   ? true
                                            //     //                   : cartQ
                                            //     //                       ? true
                                            //     //                       : false
                                            //     //               : negativeStock
                                            //     //                   ? false
                                            //     //                   : salesTypeData!.type == 'SALES-O' || salesTypeData!.type == 'SALES-Q'
                                            //     //                       ? isStockProductOnlyInSalesQO
                                            //     //                           ? cartItem[index].quantity! + 1 > cartItem[index].stock!
                                            //     //                               ? true
                                            //     //                               : cartQ
                                            //     //                                   ? true
                                            //     //                                   : false
                                            //     //                           : false
                                            //     //                       : cartItem[index].quantity! + 1 > cartItem[index].stock!
                                            //     //                           ? true
                                            //     //                           : cartQ
                                            //     //                               ? true
                                            //     //                               : false;
                                            //     //           if (outOfStock) {
                                            //     //             ScaffoldMessenger.of(
                                            //     //                     context)
                                            //     //                 .showSnackBar(
                                            //     //                     SnackBar(
                                            //     //               content: const Text(
                                            //     //                   'Sorry stock not available.'),
                                            //     //               duration:
                                            //     //                   const Duration(
                                            //     //                       seconds:
                                            //     //                           10),
                                            //     //               action:
                                            //     //                   SnackBarAction(
                                            //     //                 label: 'Click',
                                            //     //                 onPressed: () {
                                            //     //                   // print('Action is clicked');
                                            //     //                 },
                                            //     //                 textColor:
                                            //     //                     Colors.white,
                                            //     //                 disabledTextColor:
                                            //     //                     Colors.grey,
                                            //     //               ),
                                            //     //               backgroundColor:
                                            //     //                   Colors.red,
                                            //     //             ));
                                            //     //           } else {
                                            //     //             updateProduct(
                                            //     //                 cartItem[index],
                                            //     //                 cartItem[index]
                                            //     //                         .quantity! +
                                            //     //                     1,
                                            //     //                 index);
                                            //     //           }
                                            //     //         });
                                            //     //       });
                                            //     //     } else {
                                            //     //       setState(() {
                                            //     //         bool cartQ = false;
                                            //     //         if (totalItem > 0) {
                                            //     //           double cartS = 0,
                                            //     //               cartQt = 0;
                                            //     //           for (var element
                                            //     //               in cartItem) {
                                            //     //             if (element.itemId ==
                                            //     //                 cartItem[index]
                                            //     //                     .itemId) {
                                            //     //               cartQt += element
                                            //     //                   .quantity!;
                                            //     //               cartS =
                                            //     //                   element.stock!;
                                            //     //             }
                                            //     //           }
                                            //     //           // cartS = oldBill?:cartS;
                                            //     //           if (cartS > 0) {
                                            //     //             if (cartS <
                                            //     //                 cartQt + 1) {
                                            //     //               cartQ = true;
                                            //     //             }
                                            //     //           }
                                            //     //         }
                                            //     //         outOfStock = isLockQtyOnlyInSales
                                            //     //             ? ((cartItem[index].quantity! * cartItem[index].unitValue!) + cartItem[index].free!) + 1 > cartItem[index].stock!
                                            //     //                 ? true
                                            //     //                 : cartQ
                                            //     //                     ? true
                                            //     //                     : false
                                            //     //             : negativeStock
                                            //     //                 ? false
                                            //     //                 : salesTypeData!.type == 'SALES-O' || salesTypeData!.type == 'SALES-Q'
                                            //     //                     ? isStockProductOnlyInSalesQO
                                            //     //                         ? ((cartItem[index].quantity! * cartItem[index].unitValue!) + cartItem[index].free!) + 1 > cartItem[index].stock!
                                            //     //                             ? true
                                            //     //                             : cartQ
                                            //     //                                 ? true
                                            //     //                                 : false
                                            //     //                         : false
                                            //     //                     : cartItem[index].quantity! + 1 > cartItem[index].stock!
                                            //     //                         ? true
                                            //     //                         : cartQ
                                            //     //                             ? true
                                            //     //                             : false;
                                            //     //         if (outOfStock) {
                                            //     //           ScaffoldMessenger.of(
                                            //     //                   context)
                                            //     //               .showSnackBar(
                                            //     //                   SnackBar(
                                            //     //             content: const Text(
                                            //     //                 'Sorry stock not available.'),
                                            //     //             duration:
                                            //     //                 const Duration(
                                            //     //                     seconds: 10),
                                            //     //             action:
                                            //     //                 SnackBarAction(
                                            //     //               label: 'Click',
                                            //     //               onPressed: () {
                                            //     //                 // print('Action is clicked');
                                            //     //               },
                                            //     //               textColor:
                                            //     //                   Colors.white,
                                            //     //               disabledTextColor:
                                            //     //                   Colors.grey,
                                            //     //             ),
                                            //     //             backgroundColor:
                                            //     //                 Colors.red,
                                            //     //           ));
                                            //     //         } else {
                                            //     //           updateProduct(
                                            //     //               cartItem[index],
                                            //     //               cartItem[index]
                                            //     //                       .quantity! +
                                            //     //                   1,
                                            //     //               index);
                                            //     //         }
                                            //     //       });
                                            //     //     }
                              
                                            //     //     //  cart.addQuantity(
                                            //     //     //      cartItem[index].id!);
                                            //     //     //  dbHelper!
                                            //     //     //      .updateQuantity(Cart(
                                            //     //     //          id: index,
                                            //     //     //          productId: index.toString(),
                                            //     //     //          productName: provider
                                            //     //     //              .cart[index].productName,
                                            //     //     //          initialPrice: provider
                                            //     //     //              .cart[index].initialPrice,
                                            //     //     //          productPrice: provider
                                            //     //     //              .cart[index].productPrice,
                                            //     //     //          quantity: ValueNotifier(
                                            //     //     //              cartItem[index]
                                            //     //     //                  .quantity!.value),
                                            //     //     //          unitTag: provider
                                            //     //     //              .cart[index].unitTag,
                                            //     //     //          image: provider
                                            //     //     //              .cart[index].image))
                                            //     //     //      .then((value) {
                                            //     //     //    setState(() {
                                            //     //     //      cart.addTotalPrice(double.parse(
                                            //     //     //          provider
                                            //     //     //              .cart[index].productPrice
                                            //     //     //              .toString()));
                                            //     //     //    });
                                            //     //     //  });
                                            //     //   },
                                            //     //   deleteQuantity: () {
                                            //     //     setState(() {
                                            //     //       updateProduct(
                                            //     //           cartItem[index],
                                            //     //           cartItem[index]
                                            //     //                   .quantity! -
                                            //     //               1,
                                            //     //           index);
                                            //     //     });
                              
                                            //     //     //  cart.deleteQuantity(
                                            //     //     //      cartItem[index].id!);
                                            //     //     //  cart.removeTotalPrice(double.parse(
                                            //     //     //      cartItem[index].productPrice
                                            //     //     //          .toString()));
                                            //     //   },
                                            //     //   text: cartItem[index]
                                            //     //       .quantity
                                            //     //       .toString(),
                                            //     // ),
                                            //     RichText(  
                                            //       maxLines: 1,
                                            //       text: TextSpan(
                                            //           text: 'Rate: ',
                                            //           style: TextStyle(
                                            //               color: Colors
                                            //                   .blueGrey.shade800,
                                            //               fontSize: 13.0),
                                            //           children: [
                                            //             TextSpan(
                                            //                 text:
                                            //                     '${cartItem[index].rate}\n',
                                            //                 style:
                                            //                     const TextStyle(
                                            //                         fontWeight:
                                            //                             FontWeight
                                            //                                 .bold,
                                            //                         fontSize:
                                            //                             12.0)),
                                            //           ]),
                                            //     ),
                                            //     // IconButton(
                                            //     // onPressed: () {
                                            //     //  dbHelper!.deleteCartItem(
                                            //     //      cartItem[index].id!);
                                            //     //  provider
                                            //     //      .removeItem(cartItem[index].id!);
                                            //     //  provider.removeCounter();
                                            //     // },
                                            //     // icon: Icon(
                                            //     // Icons.edit,
                                            //     // color: Colors.blue.shade800,
                                            //     // )),
                                            //     PopUpMenuAction(
                                            //       onDelete: () {
                                            //         setState(() {
                                            //           removeProduct(index);
                                            //         });
                                            //       },
                                            //       onEdit: () {
                                            //         setState(() {
                                            //           editItem = true;
                                            //           position = index;
                                            //           cartModel = cartItem
                                            //               .elementAt(position!);
                                            //           _rateController.text =
                                            //               cartModel!.rate!
                                            //                   .toString();
                                            //           _quantityController.text =
                                            //               cartModel!.quantity!
                                            //                   .toString();
                                            //           _freeQuantityController
                                            //                   .text =
                                            //               cartModel!.free
                                            //                   .toString();
                                            //           _discountController.text =
                                            //               cartModel!.discount
                                            //                   .toString();
                                            //           _discountPercentController
                                            //                   .text =
                                            //               cartModel!
                                            //                   .discountPercent
                                            //                   .toString();
                                            //           _serialNoController.text =
                                            //               cartModel!.serialNo!;
                                            //           _dropDownUnit =
                                            //               cartModel!.unitId!;
                                            //           nextWidget = 3;
                                            //         });
                                            //       },
                                            //     ),
                                            //   ],
                                            // ),
                                            // RichText(
                                            //   text: TextSpan(
                                            //       text: 'Gross:',
                                            //       style: TextStyle(
                                            //           color: Colors
                                            //               .blueGrey.shade800,
                                            //           fontSize: 12.0),
                                            //       children: [
                                            //         TextSpan(
                                            //             text:
                                            //                 '${cartItem[index].gross}    ',
                                            //             style: const TextStyle(
                                            //                 fontWeight:
                                            //                     FontWeight.bold,
                                            //                 fontSize: 12.0)),
                                            //         TextSpan(
                                            //             text: 'Disc:',
                                            //             style: const TextStyle(
                                            //                 fontSize: 12.0),
                                            //             children: [
                                            //               TextSpan(
                                            //                   text:
                                            //                       '${cartItem[index].discountPercent}% ${cartItem[index].discount}    ',
                                            //                   style: const TextStyle(
                                            //                       fontWeight:
                                            //                           FontWeight
                                            //                               .bold,
                                            //                       fontSize:
                                            //                           12.0)),
                                            //             ]),
                                            //         TextSpan(
                                            //             text: 'Net:',
                                            //             style: const TextStyle(
                                            //                 fontSize: 12.0),
                                            //             children: [
                                            //               TextSpan(
                                            //                   text:
                                            //                       '${cartItem[index].net}    ',
                                            //                   style: const TextStyle(
                                            //                       fontWeight:
                                            //                           FontWeight
                                            //                               .bold,
                                            //                       fontSize:
                                            //                           12.0)),
                                            //             ]),
                                            //         isTax
                                            //             ? TextSpan(
                                            //                 text:
                                            //                     'Tax:${cartItem[index].taxP}% ',
                                            //                 style:
                                            //                     const TextStyle(
                                            //                         fontSize:
                                            //                             12.0),
                                            //                 children: [
                                            //                     TextSpan(
                                            //                         text:
                                            //                             '${cartItem[index].tax}    ',
                                            //                         style: const TextStyle(
                                            //                             fontWeight:
                                            //                                 FontWeight
                                            //                                     .bold,
                                            //                             fontSize:
                                            //                                 12.0)),
                                            //                   ])
                                            //             : const TextSpan(
                                            //                 text: ''),
                                            //         TextSpan(
                                            //             text: 'Total:',
                                            //             style: const TextStyle(
                                            //                 fontSize: 12.0),
                                            //             children: [
                                            //               TextSpan(
                                            //                   text:
                                            //                       '${cartItem[index].total}',
                                            //                   style: const TextStyle(
                                            //                       fontWeight:
                                            //                           FontWeight
                                            //                               .bold,
                                            //                       fontSize:
                                            //                           12.0)),
                                            //             ]),
                                            //       ]),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : const Center(
                            child: Text("No items in Cart"),
                          ),
                          totalItem > 0 ?
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            width: MediaQuery.of(context).size.width,color: white,child: Column(children: [
                               const SizedBox(
                                    height: 5,
                                  ),
                             Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Disc : ${CommonService.getRound(decimal, totalDiscount).toStringAsFixed(decimal)}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'poppins'),
                                      ),
                                      Text('Total Tax Amt : ${CommonService.getRound(decimal, taxTotalCartValue).toStringAsFixed(decimal)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'poppins')),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total Item : ${CommonService.getRound(decimal, double.parse(totalItem.toString())).toStringAsFixed(decimal)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'poppins')),
                                      Text('Subtotal: ${CommonService.getRound(decimal, totalGrossValue).toStringAsFixed(decimal)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'poppins')),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  )
                          ],),
                          )
                          : const SizedBox(),
                          const SizedBox(
                            height: 10,
                          ),
                           Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 20),
                         child: Column(
                           children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: grey
                                ),
                                borderRadius: BorderRadius.circular(3)
                              ),
                              child: ExpansionTile(
                                initiallyExpanded: valueMore,
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    valueMore = expanded;
                                  });
                                },
                                title: const Text('Other Amounts',
                                style: TextStyle(fontFamily: 'poppins'),),
                                trailing: Icon(
                                  valueMore
                                      ? Icons.keyboard_double_arrow_down_outlined
                                      : Icons.keyboard_double_arrow_up_outlined,
                                ),
                                children: [
                                  Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: controllerNarration,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 8
                                          ),
                                          border: OutlineInputBorder(),
                                          labelText: 'Narration',
                                        ),
                                      ),
                                      Visibility(
                                        visible: _isReturnInSales,
                                        child: const SizedBox(
                                        height: 6,
                                      )),
                                      Visibility(
                                        visible: _isReturnInSales,
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              // const SizedBox(height: 3),
                                              Expanded(
                                                child: TextField(
                                                  controller: returnEntryNoController,
                                                  decoration: const InputDecoration(
                                                     contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                          ),
                                                    border: OutlineInputBorder(),
                                                    labelText: 'Bill No :',
                                                  ),
                                                  keyboardType: const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true),
                                                  ],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      returnBillId = int.tryParse(value)!;
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      loadReturnForm = true;
                                                    });
                                                  },
                                                  style: ButtonStyle(
                                                    shape: MaterialStatePropertyAll(
                                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))
                                                    ),
                                                    foregroundColor: const MaterialStatePropertyAll(white),
                                                    backgroundColor: MaterialStateProperty.all(kPrimaryColor),
                                                  ),
                                                  child: const Text('Return Bill'),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: TextField(
                                                  controller: returnAmountController,
                                                  decoration: const InputDecoration(
                                                     contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                          ),
                                                    border: OutlineInputBorder(),
                                                    labelText: 'Amount',
                                                  ),
                                                  keyboardType: const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true),
                                                  ],
                                                  onChanged: (value) {
                                                    if (value.isNotEmpty) {
                                                      setState(() {
                                                        returnAmount = double.tryParse(value)!;
                                                        grandTotal = grandTotal - returnAmount;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: SizedBox(
                                                height: 45,
                                                child: DropdownSearch<dynamic>(
                                                  popupProps: const PopupPropsMultiSelection.dialog(
                                                    showSearchBox: true,
                                                  ),
                                                  asyncItems: (String filter) =>
                                                      api.getLedgerDataByParent(filter, 0, 0, 0, 0),
                                                  dropdownDecoratorProps: const DropDownDecoratorProps(
                                                    dropdownSearchDecoration: InputDecoration(
                                                        contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                          ),
                                                      // labelStyle: TextStyle(
                                                      //   color: black
                                                      // ),
                                                      border: OutlineInputBorder(),
                                                      labelText: 'Select Unit',
                                                    ),
                                                  ),
                                                  onChanged: (dynamic data) {
                                                    setState(() {
                                                      commissionLedgerData = data;
                                                    commissionAccount = data.id;
                                                    });
                                                    debugPrint(data.toString());
                                                  },
                                                  selectedItem: commissionLedgerData,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: commissionAmountController,
                                                decoration: const InputDecoration(
                                                   contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                          ),
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Amount',
                                                ),
                                                keyboardType: const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: SizedBox(
                                                height: 45,
                                                child: DropdownSearch<dynamic>(
                                                  popupProps: PopupPropsMultiSelection.dialog(
                                                    showSearchBox: true,
                                                  ),
                                                  asyncItems: (String filter) => widgetBankAccount(filter),
                                                  dropdownDecoratorProps: const DropDownDecoratorProps(
                                                    dropdownSearchDecoration: InputDecoration(
                                                        contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                          ),
                                                      border: OutlineInputBorder(),
                                                      labelText: 'Card A/C',
                                                    ),
                                                  ),
                                                  onChanged: (dynamic data) {
                                                    bankLedgerData = data;
                                                    bankLedgerName = data.name;
                                                    bankAccount = data.id;
                                                  },
                                                  selectedItem: bankLedgerData,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: bankAmountController,
                                                decoration: const InputDecoration(
                                                   contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                          ),
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Amount',
                                                ),
                                                keyboardType: const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true),
                                                ],
                                                onChanged: (value) {
                                                  setState(() {
                                                    balanceCalculate();
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      SizedBox(
                                        // height: deviceSize!.height / 5,
                                        child: Container(
                                          child: ListView.separated(
                                            separatorBuilder: (context, index) {
                                              return SizedBox(
                                                height: 6,
                                              );
                                            },
                                            physics: const BouncingScrollPhysics(),
                                            itemCount: otherAmountList.length,
                                            shrinkWrap: true,
                                            itemBuilder: (BuildContext context, int index) {
                                              _controllers.add(TextEditingController());
                                              _controllers[index].text =
                                                  otherAmountList[index]['Amount'].toString();
                              
                                              return SizedBox(
                                                width: MediaQuery.of(context).size.width,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        margin: const EdgeInsets.only(left: 2),
                                                        child: Text(
                                                                                '${otherAmountList[index]['LedName']} : ',
                                                                                style: TextStyle(
                                                                                  fontFamily: 'poppins'
                                                                                ),
                                                                                ),
                                                      ),
                                                    ),
                                                  Expanded(
                                                    child: TextField(
                                                      decoration: const InputDecoration(
                                                         contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                          ),
                                                        border: OutlineInputBorder(),
                                                      ),
                                                      controller: TextEditingController.fromValue(
                                                        TextEditingValue(
                                                                              text: otherAmountList[index]['Amount'].toString(),
                                                                              selection: TextSelection(
                                                                                baseOffset: 0,
                                                                                extentOffset: otherAmountList[index]['Amount']
                                                                                    .toString()
                                                                                    .length,
                                                                              ),
                                                        ),
                                                      ),
                                                      keyboardType: const TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter(
                                                                              RegExp(r'[0-9]'),
                                                                              allow: true,
                                                                              replacementString: '.',
                                                        ),
                                                      ],
                                                      onSubmitted: (String str) {
                                                        var cartTotal = totalCartValue;
                                                        if (str.isNotEmpty) {
                                                                              try {
                                                                                otherAmountList[index]['Amount'] =
                                                                                    double.tryParse(str);
                                                                                otherAmountList[index]['Percentage'] =
                                                                                    CommonService.getRound(
                                                                                        decimal,
                                                                                        ((double.tryParse(str)! * 100) /
                                                                                            cartTotal));
                                                                                var netTotal = (cartTotal - returnAmount) +
                                                                                    otherAmountList.fold(
                                                                                        0.0,
                                                                                        (t, e) => t +
                                                                                            double.parse(e['Symbol'] == '-'
                                                                                                  ? (e['Amount'] * -1).toString()
                                                                                                  : e['Amount'].toString()));
                                                                                setState(() {
                                                                                  grandTotal = netTotal;
                                                                                });
                                                                              } on FormatException {
                                                                                debugPrint('ex');
                                                                              }
                                                        }
                                                      },
                                                    ),
                                                  )
                                                ]),
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
                            const SizedBox(
                              height: 15,
                            ),

                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                const Text('Total Amount ',style:TextStyle(fontSize: 16,fontWeight: FontWeight.w500,fontFamily: 'poppins')),
                                Text('₹   ${CommonService.getRound(decimal, grandTotal).toStringAsFixed(decimal)}',style:const 
                                TextStyle(fontSize: 16,fontWeight: FontWeight.w500,),),
                              ]
                             ),
                                const SizedBox(
                                        height: 8,
                                  ),
                             Row(
                              children:[
                                const Expanded(child: Text('Cash Received',style:TextStyle(fontSize: 16,fontWeight: FontWeight.w500,fontFamily: 'poppins'),),),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 30,
                                        child: Container(
                                            decoration: DottedDecoration(
                                                              color: black,
                                                              strokeWidth: 1,
                                                              linePosition: LinePosition.bottom,
                                                            ),
                                          child: TextField(
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'poppins'),
                                                                controller: controllerCashReceived,
                                                                focusNode: _focusNodeCashReceived,
                                                                keyboardType:
                                                                    const TextInputType.numberWithOptions(decimal: true),
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                                                      allow: true, replacementString: '.')
                                                                ],
                                                                decoration:  const InputDecoration(
                                                                  prefixIcon: Text('₹ ',
                                                                  style: TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w500,
                                                                    ),),
                                                                  prefixIconConstraints: BoxConstraints(
                                                                    maxWidth: 15
                                                                  ),
                                                                  contentPadding: EdgeInsets.symmetric(vertical: 3,horizontal: 5),
                                                                  border: OutlineInputBorder(
                                                                    borderSide: BorderSide.none
                                                                  )
                                                                ),
                                                                onChanged: (value) {
                                                                  setState(() {
                                                                    balanceCalculate();
                                                                  });
                                                                },
                                                              ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                             ),
                             const SizedBox(
                              height: 8,
                             ),
                               Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                const Text('Balance Due ',style:TextStyle(color: green,fontSize: 16,fontWeight: FontWeight.w500,fontFamily: 'poppins')),
                                Text('₹   ${ComSettings.appSettings('bool', 'key-round-off-amount', false) ? _balance.toStringAsFixed(2) : _balance.toStringAsFixed(2)}',style:const 
                                TextStyle(color: green,fontSize: 16,fontWeight: FontWeight.w500,),),
                              ]
                             ),
                           ],
                         ),
                       ),
                       const SizedBox(
                        height: 20,
                       ),
                  ],
                ),
              ),
              bottomNavigationBar: 
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                // child: 
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(8),
                //   child:
                   Container(
                    width: MediaQuery.of(context).size.width,
                    // decoration: const BoxDecoration(
                    //   boxShadow: [
                    //     BoxShadow(
                    //         color: grey, blurRadius: .8, spreadRadius: 100),
                    //   ],
                    // ),
                    height: 60,
                    child: Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.grey,
                              onTap: () {
                               oldBill ? setState(() {
                                   if (buttonEvent) {
                            return;
                          } else {
                            if (companyUserData!.deleteData) {
                              if (!daysBefore) {
                                if (totalItem > 0) {
                                  setState(() {
                                    _isLoading = true;
                                    buttonEvent = true;
                                  });
                                  
                                  _insert(
                                      'Delete DateTime:$formattedDate $timeIs location:${lId.toString()} ledger:${ledgerModel!.id} ${CartItem.encodeCartToJson(cartItem)}',
                                      0);
                                      // deleteSaleData();
                                  // deleteSale(context);
                                    if (currentFinancialYear != null) {
                              deleteSale(context);
                            }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Please select at least one bill');
                                  setState(() {
                                    buttonEvent = false;
                                  });
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        'Invoice Date not equal\ncan`t delete');
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
                                }) : null;
                              },
                              child: Container(
                                height: 60,
                                color: Colors.white,
                                child:  Center(
                                  child: 
                                   Text(
                                    oldBill? 'Delete': 'Save & New',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.white,
                              onTap: () {
                               oldBill ? setState(() {
                                selectedCustomerId = ledgerModel!.id;
                                  if (buttonEvent) {
                                  return;
                                } else {
                                  if (companyUserData!.insertData) {
                                    if (!daysBefore) {
                                      if (totalItem > 0 && selectedCustomerId != null ) {
                                        setState(() {
                                          _isLoading = true;
                                          buttonEvent = true;
                                        }); 
                                        _insert(
                                            'SAVE DateTime:$formattedDate $timeIs location:${lId.toString()} ledger:${selectedCustomerId!} ${CartItem.encodeCartToJson(cartItem)}',
                                            0);
                                        // updateSale();
                                        if (currentFinancialYear != null) {
                                               updateSale();
                                           }
                                      } else {
                                        Fluttertoast.showToast(
                                          backgroundColor: red,
                                            msg: selectedCustomerId == null ? 'Select Customer':
                                                'Please add at least one item');
                                        setState(() {
                                          buttonEvent = false;
                                        });
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              'Invoice Date not equal\ncan`t save');
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
                               },) : setState(() {
                                  if (buttonEvent) {
                                  return;
                                } else {
                                  if (companyUserData!.insertData) {
                                    if (!daysBefore) {
                                      if (totalItem > 0 && selectedCustomerId != null ) {
                                        setState(() {
                                          _isLoading = true;
                                          buttonEvent = true;
                                        }); 
                                        _insert(
                                            'SAVE DateTime:$formattedDate $timeIs location:${lId.toString()} ledger:${selectedCustomerId!} ${CartItem.encodeCartToJson(cartItem)}',
                                            0);
                                        // saveSale();
                                        if (currentFinancialYear != null) {
                                             saveSale();
                                          }

                                      } else {
                                        Fluttertoast.showToast(
                                          backgroundColor: red,
                                            msg: selectedCustomerId == null ? 'Select Customer':
                                                'Please add at least one item');
                                        setState(() {
                                          buttonEvent = false;
                                        });
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              'Invoice Date not equal\ncan`t save');
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
                               },);
                              },
                              child: Container(
                                height: 60,
                                color: kPrimaryColor,
                                child:  const Center(
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  // ),
                // ),
              ),
              // extendBody: true,
            ),
          ),

          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: bagroundColor,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 4,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      color: white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20,),
                      child: Row(
                        children: [
                          Expanded(
                              child: 
                              // ContainerFieldWidget(
                              //       widget: InkWell(
                              //         onTap: () {
                              //           showModalBottomSheet(
                              //             context: context,
                              //             builder: (BuildContext context) =>
                              //                 Padding(
                              //               padding: EdgeInsets.only(
                              //                   bottom: MediaQuery.of(context)
                              //                       .viewInsets
                              //                       .bottom),
                              //               child: Padding(
                              //                 padding: const EdgeInsets.all(8.0),
                              //                 child: Column(
                              //                   children: [
                              //                     const SizedBox(height: 10),
                              //                     TextField(
                              //                       decoration:
                              //                           const InputDecoration(
                              //                               border:
                              //                                   OutlineInputBorder(),
                              //                               // hintText:
                              //                               //     'Invoice No',
                              //                               labelText:
                              //                                   'Enter invoice no'),
                              //                       controller:
                              //                           invoiceNoController,
                              //                       autofocus: true,
                              //                     ),
                              //                     const SizedBox(height: 16),
                              //                     ElevatedButton(
                              //                       style: ElevatedButton.styleFrom(
                              //                           backgroundColor:
                              //                               kPrimaryColor,
                              //                           shape:
                              //                               RoundedRectangleBorder(
                              //                                   borderRadius:
                              //                                       BorderRadius
                              //                                           .circular(
                              //                                               3))),
                              //                       onPressed: () {
                              //                         Navigator.of(context).pop();
                              //                         setState(() {});
                              //                       },
                              //                       child: const Text("Done",
                              //                           style: TextStyle(
                              //                               fontFamily: 'poppins',
                              //                               color: white)),
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ),
                              //             ),
                              //           );
                              //         },
                              //         child: Container(
                              //           margin: const EdgeInsets.only(
                              //             bottom: 15,
                              //           ),
                              //           width: MediaQuery.of(context).size.width,
                              //           padding: const EdgeInsets.symmetric(
                              //               horizontal: 5),
                              //           height: 40,
                              //           decoration: BoxDecoration(
                              //               border: Border.all(color: grey),
                              //               borderRadius:
                              //                   BorderRadius.circular(3)),
                              //           child: Row(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.spaceBetween,
                              //             children: [
                              //               Text(invoiceNoController.text,
                              //                   style: const TextStyle(
                              //                       fontWeight: FontWeight.w500,
                              //                       fontSize: 16,
                              //                       fontFamily: 'poppins')),
                              //               const Icon(
                              //                   Icons.arrow_drop_down_sharp,
                              //                   color: black)
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //       // TextField(
                              //       //   controller: invoiceNoController,
                              //       //   decoration: const InputDecoration(
                              //       //       contentPadding: EdgeInsets.symmetric(
                              //       //           vertical: 5, horizontal: 5),
                              //       //       border: OutlineInputBorder()),
                              //       // ),
                              //       headTxt: 'Invoice No')),
                               ContainerFieldWidget(
                                  widget: 
                                  // InkWell(
                                  //   onTap: () {
                                  //     // showModalBottomSheet(
                                  //     //   context: context,
                                  //     //   builder: (BuildContext context) =>
                                  //     //       Padding(
                                  //     //     padding: EdgeInsets.only(
                                  //     //         bottom: MediaQuery.of(context).viewInsets.bottom),
                                  //     //     child: Padding(
                                  //     //       padding: const EdgeInsets.all(8.0),
                                  //     //       child: Column(
                                  //     //         children: [
                                  //     //           const SizedBox(height: 16),
                                  //     //           TextField(
                                  //     //             decoration: const  InputDecoration(
                                  //     //                     border: OutlineInputBorder(),
                                  //     //                     // hintText:
                                  //     //                     //     'Invoice No',
                                  //     //                     labelText:'Enter invoice no'),
                                  //     //             controller: invoiceNoController,
                                  //     //             autofocus: true,
                                  //     //           ),
                                  //     //           const SizedBox(height: 10),
                                  //     //           ElevatedButton(
                                  //     //             style: ElevatedButton.styleFrom(
                                  //     //                 backgroundColor: kPrimaryColor,
                                  //     //                 shape: RoundedRectangleBorder(
                                  //     //                 borderRadius:BorderRadius.circular(3))),
                                  //     //             onPressed: () {
                                  //     //               Navigator.of(context).pop();
                                  //     //               setState(() {});
                                  //     //             },
                                  //     //             child: const Text("Done",
                                  //     //                 style: TextStyle(
                                  //     //                     fontFamily: 'poppins',
                                  //     //                     color: white)),
                                  //     //           ),
                                  //     //         ],
                                  //     //       ),
                                  //     //     ),
                                  //     //   ),
                                  //     // );
                                  //   },
                                  //   child: Container(
                                  //     margin: const EdgeInsets.only(
                                  //       bottom: 15,
                                  //     ),
                                  //     width: MediaQuery.of(context).size.width,
                                  //     padding: const EdgeInsets.symmetric(horizontal: 5),
                                  //     height: 20,
                                  //     decoration: BoxDecoration(
                                  //         border: Border.all(color: grey),
                                  //         borderRadius: BorderRadius.circular(3)),
                                  //     child: Row(
                                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //       children: [
                                  //         Text(invoiceNoController.text,
                                  //             style: const TextStyle(
                                  //                 fontWeight: FontWeight.w500,
                                  //                 fontSize: 16,
                                  //                 fontFamily: 'poppins')),
                                  //         // const Icon(
                                  //         //     Icons.arrow_drop_down_sharp,
                                  //         //     color: black)
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 15,
                                    ),
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14
                                      ),
                                      controller: invoiceNoController,
                                      decoration:  InputDecoration(
                                      
                                  //        prefixIcon: Row(
                                  //         mainAxisSize: MainAxisSize.min,
                                  //         children: [
                                  //           // Icon(Icons.keyboard_double_arrow_left_rounded),
                                  //           const SizedBox(
                                  //             width: 4,
                                  //           ),
                                  //          InkWell(
                                  //               onTap: () {
                                  //                var invoiceNum = invoiceNo;

                                  //               setState(() {
                                  //                int invoiceNumber = int.parse(invoiceNum); 
                                  //                invoiceNumber--; 
                                  //                invoiceNum = invoiceNumber.toString(); 
                                  //              });

                                  //             debugPrint(invoiceNum.toString());

                                  //         dataDynamic = [
                                  //          {
                                  //          'Type': salesTypeData!.type,
                                  //          'InvoiceNo': invoiceNum,
                                  //          'EntryNo': int.parse(invoiceNum) ?? 0,
                                  //          'Id': int.parse(invoiceNum) ?? 0
                                  //          }
                                  //       ];
                                  //       cartItem.clear();
                                  //      fetchSale(context, dataDynamic[0]);
                                  //     },
                                  //      child: const Icon(
                                  //        Icons.arrow_back_ios_rounded,
                                  //        // size: 16, 
                                  //    ),
                                  // ),

                                  //         ],
                                  //       ),
                                      //   suffixIcon: Row(
                                      //     mainAxisSize: MainAxisSize.min,
                                      //     children: [
                                      //       InkWell(
                                      //         onTap: () {
                                      //              var invoiceNum = invoiceNo;

                                      //           setState(() {
                                      //            int invoiceNumber = int.parse(invoiceNum); 
                                      //            invoiceNumber++; 
                                      //            invoiceNum = invoiceNumber.toString(); 
                                      //          });

                                      //         debugPrint(invoiceNum.toString());

                                      //     dataDynamic = [
                                      //      {
                                      //      'Type': salesTypeData!.type,
                                      //      'InvoiceNo': invoiceNum,
                                      //      'EntryNo': int.parse(invoiceNum) ?? 0,
                                      //      'Id': int.parse(invoiceNum) ?? 0
                                      //      }
                                      //   ];
                                      //  cartItem.clear();
                                      //  try {
                                      //    fetchSale(context, dataDynamic[0]);
                                      //  } catch (e) {
                                      //    if (e is RangeError) {
                                      //       showDialog(
                                      //            context: context,
                                      //            builder: (BuildContext context) {
                                      //             return AlertDialog(
                                      //                    title: const Text("Error"),
                                      //                    content: const Text("An error occurred while fetching the Sale Bill Invalid value."),
                                      //                    actions: [
                                      //                     TextButton(
                                      //                      child: const Text("OK"),
                                      //                      onPressed: () {
                                      //                      Navigator.of(context).pop(); 
                                      //                   },
                                      //                 ),
                                      //               ],
                                      //            );
                                      //          },
                                      //       );
                                      //    }else {
                                      //       debugPrint("An unexpected error occurred: $e");
                                      //    }
                                      //  }
                                      //         },
                                      //         child: const Icon(Icons.arrow_forward_ios_rounded)),
                                      //       //  Icon(Icons.keyboard_double_arrow_right_rounded),
                                      //     ],
                                      //   ),
                                        constraints: BoxConstraints(
                                          maxHeight: 40
                                        ),
                                          contentPadding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 8),
                                          border: const OutlineInputBorder()),
                                    ),
                                  ),
                                  headTxt: 'Entry No')),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                              child: ContainerFieldWidget(
                                  widget: InkWell(
                                    onTap: () {
                                      _selectDate();
                                    },
                                    child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 15,
                                        ),
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3),
                                          border: Border.all(color: grey)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            formattedDate!,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                fontFamily: 'poppins'),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          const Icon(
                                            Icons.calendar_month_outlined,
                                            color: grey,
                                            size: 25,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  headTxt: 'Date')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      color: white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: ContainerFieldWidget(
                          widget: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                border: Border.all(color: grey),
                                borderRadius: BorderRadius.circular(3)),
                            child: widgetRateType(),
                          ),
                          headTxt: 'Sales Rate'),
                    ),
                    const SizedBox(height: 15),
                    AnimatedContainer(
                      duration: animationDuration,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      height: isExpanded ? expandedHeight : collapsedHeight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            ' Biiling Name',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                           TextField(
                            controller: billingNameController,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 5),
                                border: OutlineInputBorder()),
                          ),
                          // EasyAutocomplete(
                          //     autofocus: false,
                          //     progressIndicatorBuilder:
                          //         const CircularProgressIndicator(),
                          //     controller: nameControl,
                          //     inputTextStyle:
                          //         const TextStyle(fontFamily: 'poppins'),
                          //     suggestionTextStyle:
                          //         const TextStyle(fontFamily: 'poppins'),
                          //     decoration: const InputDecoration(
                          //         border: OutlineInputBorder()),
                          //     suggestions: nameListDisplay,
                          //     onChanged: (value) =>
                          //         print('onChanged value: $value'),
                          //     onSubmitted: (value) =>
                          //         print('onSubmitted value: $value')),
                          const SizedBox(
                            height: 6,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Theme(
                                    data: ThemeData(
                                        dividerColor: Colors.transparent),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: grey),
                                          borderRadius: BorderRadius.circular(3)),
                                      child: ExpansionTile(
                                        // enableFeedback: false,
                                        controlAffinity:
                                            ListTileControlAffinity.platform,
                                        title: const Text(
                                          'Other',
                                          style: TextStyle(
                                            fontFamily: 'poppins',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 8),
                                            child: Column(
                                              children: [
                                                const ContainerFieldWidget(widget: TextField(
                                                  // controller: addressControl,
                                                  decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder()),
                                                ), headTxt: 'Phone Number'),
                                                const SizedBox(height: 8),
                                                ContainerFieldWidget(widget: TextField(
                                                  controller: addressControl,
                                                  decoration: const InputDecoration(
                                                      border:
                                                          OutlineInputBorder()),
                                                ), headTxt: 'Address'),
                                                const SizedBox(height: 8),
                                               const ContainerFieldWidget(widget:  TextField(
                                                  decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder()),
                                                ), headTxt: 'Email')
                                              ],
                                            ),
                                          )
                                        ],
                                        onExpansionChanged: (newIsExpanded) {
                                          setState(() {
                                            isExpanded = newIsExpanded;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                nextWidget = 2;
                                editItem = false;
                              });
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => addItemWidget(),
                              //     ));
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              backgroundColor: const Color(0xff0008B3),
                            ),
                            // onPressed: () => context.push(AddItemToSalePage.routePath),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Image(
                                //     image: AssetImage(
                                //         'assets/icons/add_item_icon.png')),
                                SizedBox(width: 10),
                                Text(
                                  'Add Item',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'poppins',
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    cartItem.isNotEmpty
                        ? Container(
                             constraints: const BoxConstraints(maxHeight: 300),
                          // height: 250,
                            width: MediaQuery.sizeOf(context).width,
                            color: white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 4),
                                shrinkWrap: true,
                                // physics: ClampingScrollPhysics() ,
                                itemCount: cartItem.length ,
                                // scrollDirection: Axis.vertical,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        editItem = true;
                                        position = index;
                                        cartModel =
                                            cartItem.elementAt(position!);
                                        itemNameControl.text =
                                            cartModel!.itemName.toString();
                                        _rateController.text =
                                            cartModel!.rate!.toString();
                                        _quantityController.text =
                                            cartModel!.quantity!.toString();
                                        _freeQuantityController.text =
                                            cartModel!.free.toString();
                                        _discountController.text =
                                            cartModel!.discount.toString();
                                        _discountPercentController.text =
                                            cartModel!.discountPercent
                                                .toString();
                                        _serialNoController.text =
                                            cartModel!.serialNo!;
                                        _dropDownUnit = cartModel!.unitId!;
                                        taxP = cartModel!.taxP!;
                                        tax = cartModel!.tax!;
                                        gross = cartModel!.gross!;
                                        total = cartModel!.total!;
                                        nextWidget = 2;
                                      });
                                    },
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          // boxShadow: [
                                          //   BoxShadow(
                                          //     color: Colors.grey.shade400,
                                          //     blurRadius: 5,
                                          //     spreadRadius: .8,
                                          //   )
                                          // ],
                                          border: Border.all(
                                              color: grey, width: .5),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          color:
                                              Colors.grey.withOpacity(.1)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(children: [
                                                Container(
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 5),
                                                    decoration:
                                                        BoxDecoration(
                                                            color: white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3),
                                                            border:
                                                                Border.all(
                                                              width: .3,
                                                              color: grey,
                                                            )),
                                                    child: Text(
                                                      '# ${cartItem[index].id}',
                                                      style:
                                                          const TextStyle(
                                                              fontSize: 12),
                                                    )),
                                                Text(
                                                    ' ${cartItem[index].itemName}',
                                                    style: const TextStyle(
                                                        color: black,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily:
                                                            'poppins')),
                                                const Spacer(),
                                                
                                              ]),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    'Item Subtotal',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'poppins'),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    "${cartItem[index].quantity!.toStringAsFixed(0)} ${UnitSettings.getUnitName(cartItem[index].unitId!)} x ${(selectedTaxOption == 'With Tax' ? cartItem[index].rRate!.toStringAsFixed(2) : cartItem[index].rate!.toStringAsFixed(2))} = ₹ ${cartItem[index].gross}",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                                width:
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Discount (%): ',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .orange[700],
                                                          fontFamily:
                                                              'poppins'),
                                                    ),
                                                    Text(
                                                      cartItem[index]
                                                          .discountPercent!
                                                          .toStringAsFixed(
                                                              2),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .orange[700],
                                                          fontFamily:
                                                              'poppins'),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      '₹ ${cartItem[index].discount!.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .orange[700],
                                                      ),
                                                    )
                                                  ],
                                                )),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(children: [
                                                Text(
                                                  'Tax (%): ${cartItem[index].taxP}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '₹ ${cartItem[index].tax!.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ]),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(children: [
                                                const Text(
                                                  'Total',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '₹ ${cartItem[index].total!.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ]),
                                            ),
                                           
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : const Center(
                            child: Text("No items in Cart"),
                          ),
                          
                          cartItem.isNotEmpty ?
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            width: MediaQuery.of(context).size.width,color: white,child: Column(children: [
                               const SizedBox(
                                    height: 5,
                                  ),
                             Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Disc : ${CommonService.getRound(decimal, totalDiscount).toStringAsFixed(decimal)}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'poppins'),
                                      ),
                                      Text('Total Tax Amt : ${CommonService.getRound(decimal, taxTotalCartValue).toStringAsFixed(decimal)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'poppins')),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total Item : ${CommonService.getRound(decimal, double.parse(totalItem.toString())).toStringAsFixed(decimal)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'poppins')),
                                      Text('Subtotal: ${CommonService.getRound(decimal, totalGrossValue).toStringAsFixed(decimal)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'poppins')),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  )
                          ],),
                          ): const SizedBox(),
                          const SizedBox(
                            height: 10,
                          ),
                           Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 20),
                         child: Column(
                           children: [
                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                const Text('Total Amount ',style:TextStyle(fontSize: 16,fontWeight: FontWeight.w500,fontFamily: 'poppins')),
                                Text('₹   ${CommonService.getRound(decimal, grandTotal).toStringAsFixed(decimal)}',style:const 
                                TextStyle(fontSize: 16,fontWeight: FontWeight.w500,),),
                              ]
                             ),
                           
                           ],
                         ),
                       ),
                       const SizedBox(
                        height: 20,
                       ),
                  ],
                ),
              ),
               bottomNavigationBar:
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      color: white,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      // decoration: const BoxDecoration(
                      //   boxShadow: [
                      //     BoxShadow(
                      //         color: grey, blurRadius: .8, spreadRadius: 100),
                      //   ],
                      // ),
                      height: 60,
                      child: Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.grey,
                                onTap: () {
                      //                              setState(() {
                      //                               // selectedCustomerId = acId;
                      //                             if (buttonEvent) {
                      //                               return;
                      //                             } else {
                      //                               if (companyUserData!.insertData) {
                      //                                 if (!daysBefore) {
                      //                                   if (totalItem > 0) {
                      //                                     setState(() {
                      //                                       _isLoading = true;
                      //                                       buttonEvent = true;
                      //                                       billingNameController.text.isNotEmpty ? 
                      //                                       ledgerModel!.name = billingNameController.text
                      //                                       :
                      //                                       ledgerModel!.name; 
                                            
                      //                                     });
                      //                                     _insert(
                      //                                         'SAVE DateTime:$formattedDate $timeIs location:${lId.toString()} ledger:${selectedCustomerId!} ${CartItem.encodeCartToJson(cartItem)}',
                      //                                         0);
                      //                                     // saveSale();
                      //                                      List<CustomerModel> ledger = [];
                      //   ledger.add(CustomerModel(
                      //       address1: addressControl.text,
                      //       address2: siteNameControl.text,
                      //       address3: '',
                      //       address4: ledgerModel!.address4 ?? '',
                      //       balance: ledgerModel!.balance,
                      //       city: ledgerModel!.city,
                      //       email: ledgerModel!.email,
                      //       id: ledgerModel!.id,
                      //       name: ledgerModel!.name,
                      //       phone: ledgerModel!.phone,
                      //       remarks: ledgerModel!.remarks,
                      //       route: ledgerModel!.route,
                      //       state: ledgerModel!.state,
                      //       stateCode: ledgerModel!.stateCode,
                      //       taxNumber: ledgerModel!.taxNumber));
                    
                      //   var locationId =
                      //       lId.toString().trim().isNotEmpty ? lId : salesTypeData!.location;
                      //   invoiceNo =
                      //       invoiceNoController.text.isNotEmpty ? invoiceNoController.text : '0';
                    
                      //   Order order = Order(
                      //       customerModel: ledger,
                      //       lineItems: cartItem,
                      //       grossValue: totalGrossValue.toString(),
                      //       discount: totalDiscount.toString(),
                      //       rDiscount: totalRDiscount.toString(),
                      //       net: totalNet.toString(),
                      //       cGST: totalCgST.toString(),
                      //       sGST: totalSgST.toString(),
                      //       iGST: totalIgST.toString(),
                      //       cess: totalCess.toString(),
                      //       adCess: totalAdCess.toString(),
                      //       fCess: totalFCess.toString(),
                      //       total: totalCartValue.toString(),
                      //       grandTotal:
                      //           grandTotal > 0 ? grandTotal.toString() : totalCartValue.toString(),
                      //       profit: totalProfit.toString(),
                      //       cashReceived: controllerCashReceived.text.isNotEmpty
                      //           ? controllerCashReceived.text
                      //           : '0',
                      //       otherDiscount: '0',
                      //       loadingCharge: '0',
                      //       otherCharges: '0',
                      //       labourCharge: '0',
                      //       discountPer: '0',
                      //       balanceAmount: _balance > 0
                      //           ? _balance.toStringAsFixed(decimal)
                      //           : controllerCashReceived.text.isNotEmpty
                      //               ? grandTotal > 0
                      //                   ? ComSettings.appSettings(
                      //                           'bool', 'key-round-off-amount', false)
                      //                       ? (grandTotal -
                      //                               double.tryParse(controllerCashReceived.text)!)
                      //                           .toStringAsFixed(decimal)
                      //                       : (grandTotal -
                      //                               double.tryParse(controllerCashReceived.text)!)
                      //                           .roundToDouble()
                      //                           .toString()
                      //                   : ComSettings.appSettings(
                      //                           'bool', 'key-round-off-amount', false)
                      //                       ? ((totalCartValue) -
                      //                               double.tryParse(controllerCashReceived.text)!)
                      //                           .toStringAsFixed(decimal)
                      //                       : ((totalCartValue) -
                      //                               double.tryParse(controllerCashReceived.text)!)
                      //                           .roundToDouble()
                      //                           .toString()
                      //               : grandTotal > 0
                      //                   ? ComSettings.appSettings(
                      //                           'bool', 'key-round-off-amount', false)
                      //                       ? grandTotal.toStringAsFixed(decimal)
                      //                       : grandTotal.roundToDouble().toString()
                      //                   : ComSettings.appSettings(
                      //                           'bool', 'key-round-off-amount', false)
                      //                       ? totalCartValue.toStringAsFixed(decimal)
                      //                       : totalCartValue.roundToDouble().toString(),
                      //       creditPeriod: '0',
                      //       narration:
                      //           controllerNarration.text.isNotEmpty ? controllerNarration.text : '',
                      //       takeUser: userIdC.toString(),
                      //       location: locationId.toString(),
                      //       billType: companyTaxMode == 'GULF' ? '2' : '0',
                      //       roundOff: '0',
                      //       salesMan: salesManId.toString(),
                      //       sType: salesTypeData!.rateType,
                      //       dated: DateUtil.dateYMD(formattedDate),
                      //       cashAC: acId.toString(),
                      //       otherAmountData: otherAmountList);
                      //   if (order.lineItems.isNotEmpty) {
                      //     var jsonLedger = CustomerModel.encodeCustomerToJson(order.customerModel);
                      //     var jsonItem = CartItem.encodeCartToJson(order.lineItems);
                      //     var items = json.encode(jsonItem);
                      //     var ledger = json.encode(jsonLedger);
                      //     var otherAmount = json.encode(order.otherAmountData);
                      //     var saleFormId = salesTypeData!.id;
                      //     var saleFormType = salesTypeData!.type;
                      //     var taxType = salesTypeData!.tax ? 'T' : 'NT';
                      //     var salesRateTypeId =
                      //         rateTypeItem != null ? rateTypeItem!.id.toString() : '1';
                      //     var saleAccountId = saleAccount > 0 ? saleAccount.toString() : '0';
                      //     var checkKFC = isKFC ? '1' : '0';
                      //     double grandTotal = double.tryParse(order.grandTotal)! > 0
                      //         ? (CommonService.getRound(
                      //                 decimal, double.tryParse(order.grandTotal)!) +
                      //             CommonService.getRound(
                      //                 decimal, double.tryParse(order.loadingCharge)!) +
                      //             CommonService.getRound(
                      //                 decimal, double.tryParse(order.otherCharges)!) +
                      //             CommonService.getRound(decimal, double.tryParse(order.adCess)!) +
                      //             CommonService.getRound(
                      //                 decimal, double.tryParse(order.labourCharge)!) -
                      //             CommonService.getRound(
                      //                 decimal, double.tryParse(order.otherDiscount)!))
                      //         : 0;
                      //     double roundOff = 0, different = 0;
                      //     if (!ComSettings.appSettings('bool', 'key-round-off-amount', false)) {
                      //       different = grandTotal - grandTotal.round();
                      //       if (different < 0.5) {
                      //         roundOff = CommonService.getRound(decimal, (different * -1));
                      //       } else {
                      //         roundOff = CommonService.getRound(1, (1 - different));
                      //       }
                      //     }
                      //     var data = '[${json.encode({
                      //           'statement': 'SalesInsert',
                      //           'entryNo': 0,
                      //           'invoiceNo': manualInvoiceNumberInSales ? invoiceNo : '0',
                      //           'saleFormId': saleFormId,
                      //           'saleFormType': saleFormType,
                      //           'taxType': taxType,
                      //           'date': order.dated,
                      //           'time':
                      //               '1900-01-01 ${DateFormat("H:m:s:S").format(DateTime.now())}', //1900-01-01 19:27:23.930
                      //           'sType': salesRateTypeId,
                      //           'saleAccountId': saleAccountId,
                      //           'grossValue': order.grossValue,
                      //           'discPercent': order.discountPer,
                      //           'discount': order.discount,
                      //           'rDiscount': order.rDiscount,
                      //           'net': order.net,
                      //           'cess': order.cess,
                      //           'total': order.total,
                      //           'profit': order.profit,
                      //           'cGST': order.cGST,
                      //           'sGST': order.sGST,
                      //           'iGST': order.iGST,
                      //           'addCess': order.adCess,
                      //           'fCess': order.fCess,
                      //           'otherDiscount': order.otherDiscount,
                      //           'otherCharges': order.otherCharges,
                      //           'loadingCharge': order.loadingCharge,
                      //           'balanceAmount': ComSettings.appSettings(
                      //                   'bool', 'key-round-off-amount', false)
                      //               ? double.parse(order.balanceAmount).toStringAsFixed(decimal)
                      //               : double.parse(order.balanceAmount).roundToDouble().toString(),
                      //           'labourCharge': order.labourCharge,
                      //           'grandTotal':
                      //               ComSettings.appSettings('bool', 'key-round-off-amount', false)
                      //                   ? grandTotal.toStringAsFixed(decimal)
                      //                   : grandTotal.roundToDouble().toString(),
                      //           'creditPeriod': order.creditPeriod,
                      //           'takeUser': order.takeUser,
                      //           'narration': order.narration,
                      //           'cashReceived': order.cashReceived,
                      //           'cashAC': order.cashAC,
                      //           'check_kFC': checkKFC,
                      //           'salesMan': order.salesMan,
                      //           'location': order.location,
                      //           'roundOff': roundOff,
                      //           'billType': order.billType,
                      //           'returnNo': returnBillId,
                      //           'returnAmount': returnAmount,
                      //           'otherAmount': _otherAmountTotal(order.otherAmountData),
                      //           'fyId': currentFinancialYear!.id,
                      //           'commissionAccount': commissionAccount ?? 0,
                      //           'commissionAmount': commissionAmountController.text.isEmpty
                      //               ? 0
                      //               : commissionAmountController.text,
                      //           'bankName': bankLedgerName ?? '',
                      //           'bankAmount': bankAmountController.text.isEmpty
                      //               ? 0
                      //               : bankAmountController.text,
                      //           'eVehicleNo': vehicleNameControl.text
                      //         })}]';
                    
                      //     final body = {
                      //       'information': ledger,
                      //       'data': data,
                      //       'particular': items,
                      //       'serialNoData': json.encode(SerialNOModel.encodedToJson(serialNoData)),
                      //     };
                      //     if (saleAccountId != '0') {
                      //       if (checkFinancialYear(DateUtil.dateYMD(formattedDate))) {
                      //         if (manualInvoiceNumberInSales) {
                      //           api.checkManualInvoiceNoStatus(invoiceNo).then((value) {
                      //             if (!value) {
                      //               postSale(body, otherAmount, order, saleFormType, saleFormId);
                      //             } else {
                      //               showErrorDialog(context, 'Duplicate Invoice No');
                      //               setState(() {
                      //                 _isLoading = false;
                      //                 buttonEvent = false;
                      //               });
                      //             }
                      //           });
                      //         } else {
                      //            postSale(body, otherAmount, Order order, saleFormType, saleFormId) {
                      //   api.addSale(body).then((result) {
                      //     if (CommonService().isNumeric(result) && int.tryParse(result)! > 0) {
                      //       final bodyJsonAmount = {
                      //         'statement': 'SalesInsert',
                      //         'entryNo': int.tryParse(result.toString()),
                      //         'data': otherAmount,
                      //         'date': order.dated.toString(),
                      //         'saleFormType': saleFormType,
                      //         'narration': order.narration,
                      //         'location': order.location.toString(),
                      //         'id': order.customerModel[0].id.toString(),
                      //         'fyId': currentFinancialYear!.id
                      //       };
                      //       if (salesTypeData!.accounts) {
                      //         api.addOtherAmount(bodyJsonAmount).then((ret) {
                      //           if (ret) {
                      //             final bodyJson = {
                      //               'statement': 'CheckPrint',
                      //               'entryNo': int.tryParse(result.toString()),
                      //               'sType': saleFormId.toString(),
                      //               'grandTotal': ComSettings.appSettings(
                      //                       'bool', 'key-round-off-amount', false)
                      //                   ? grandTotal.toStringAsFixed(decimal)
                      //                   : grandTotal.roundToDouble().toString()
                      //             };
                      //             api.checkBill(bodyJson).then((data) {
                      //               if (data) {
                      //                 dataDynamic = [
                      //                   {
                      //                     'RealEntryNo': int.tryParse(result.toString()),
                      //                     'EntryNo': int.tryParse(result.toString()),
                      //                     'InvoiceNo': int.tryParse(result.toString()),
                      //                     'Type': saleFormId
                      //                   }
                      //                 ];
                      //                 if (ComSettings.appSettings(
                      //                     'bool', 'key-sms-customer', false)) {
                      //                   var billName = salesTypeData!.name == "Sales Order Entry"
                      //                       ? "Order"
                      //                       : "Bill";
                      //                   var ob = ledgerModel!.balance.toString().split(' ');
                      //                   var ob1 = ob[0];
                      //                   var ob2 = ob[1];
                      //                   var amt = salesTypeData!.name == "Sales Order Entry"
                      //                       ? ledgerModel!.balance
                      //                       : ob2 == 'Dr'
                      //                           ? double.tryParse(ob1)! +
                      //                               double.tryParse(order.balanceAmount)!
                      //                           : double.tryParse(order.balanceAmount)! -
                      //                               double.tryParse(ob1)!;
                      //                   String smsBody =
                      //                       "Dear ${ledgerModel!.name},\nYour Sales $billName ${result.toString()}, Dated : $formattedDate for the Amount of ${order.grandTotal}/- \nBalance:$amt /- has been confirmed  \n${companySettings!.name}";
                      //                   if (ledgerModel!.phone.toString().isNotEmpty) {
                      //                     sendSms(ledgerModel!.phone, smsBody);
                      //                   }
                      //                 }
                      //                 if (ComSettings.getStatus('ENABLE SMS OPTION', settings!)) {
                      //                   //
                      //                 }
                      //                 clearCart();
                      //                 Fluttertoast.showToast(
                      //                   backgroundColor: green,
                      //                   msg: 'Bill Saved');
                      //                 // showMore(context, true);
                      //               }
                      //             });
                      //           }
                      //         });
                      //       } else {
                      //         final bodyJson = {
                      //           'statement': 'CheckPrint',
                      //           'entryNo': int.tryParse(result.toString()),
                      //           'sType': saleFormId.toString(),
                      //           'grandTotal':
                      //               ComSettings.appSettings('bool', 'key-round-off-amount', false)
                      //                   ? grandTotal.toStringAsFixed(decimal)
                      //                   : grandTotal.roundToDouble().toString()
                      //         };
                      //         api.checkBill(bodyJson).then((data) {
                      //           if (data) {
                      //             dataDynamic = [
                      //               {
                      //                 'RealEntryNo': int.tryParse(result.toString()),
                      //                 'EntryNo': int.tryParse(result.toString()),
                      //                 'InvoiceNo': int.tryParse(result.toString()),
                      //                 'Type': saleFormId
                      //               }
                      //             ];
                      //             if (ComSettings.appSettings('bool', 'key-sms-customer', false)) {
                      //               var billName = salesTypeData!.name == "Sales Order Entry"
                      //                   ? "Order"
                      //                   : "Bill";
                      //               var ob = ledgerModel!.balance.toString().split(' ');
                      //               var ob1 = ob[0];
                      //               var ob2 = ob[1];
                      //               var amt = salesTypeData!.name == "Sales Order Entry"
                      //                   ? ledgerModel!.balance
                      //                   : ob2 == 'Dr'
                      //                       ? double.tryParse(ob1)! +
                      //                           double.tryParse(order.balanceAmount)!
                      //                       : double.tryParse(order.balanceAmount)! -
                      //                           double.tryParse(ob1)!;
                      //               String smsBody =
                      //                   "Dear ${ledgerModel!.name},\nYour Sales $billName ${result.toString()}, Dated : $formattedDate for the Amount of ${order.grandTotal}/- \nBalance:$amt /- has been confirmed  \n${companySettings!.name}";
                      //               if (ledgerModel!.phone.toString().isNotEmpty) {
                      //                 sendSms(ledgerModel!.phone, smsBody);
                      //               }
                      //             }
                      //             if (ComSettings.getStatus('ENABLE SMS OPTION', settings!)) {
                      //               //
                      //             }
                      //             clearCart();
                      //             Fluttertoast.showToast(
                      //                   backgroundColor: green,
                      //                   msg: 'Bill Saved');
                      //             // showMore(context, true);
                      //           }
                      //         });
                      //       }
                      //       setState(() {
                      //         _isLoading = false;
                      //       });
                      //     } else {
                      //       showErrorDialog(context, result.toString());
                      //     }
                      //   }).catchError((e) {
                      //     showErrorDialog(context, e.toString());
                      //   });
                      // }
                      //         }
                      //       } else {
                      //         showErrorDialog(
                      //             context, "Date Is Incompatible With This Financial Year");
                    
                      //         setState(() {
                      //           _isLoading = false;
                      //           buttonEvent = false;
                      //         });
                      //       }
                      //     } else {
                      //       Fluttertoast.showToast(msg: "select SalesAccount");
                    
                      //       setState(() {
                      //         _isLoading = false;
                      //         buttonEvent = false;
                      //       });
                      //     }
                      //   } else {
                      //     Fluttertoast.showToast(msg: "Add item");
                    
                      //     setState(() {
                      //       _isLoading = false;
                      //       buttonEvent = false;
                      //     });
                      //   }
                      //                                     print('id ===== $selectedCustomerId');
                      //                                   } else {
                      //                                     Fluttertoast.showToast(
                      //                                         msg:
                      //                                             'Please add at least one item');
                      //                                     setState(() {
                      //                                       buttonEvent = false;
                      //                                     });
                      //                                   }
                      //                                 } else {
                      //                                   Fluttertoast.showToast(
                      //                                       msg:
                      //                                           'Invoice Date not equal\ncan`t save');
                      //                                   setState(() {
                      //                                     buttonEvent = false;
                      //                                   });
                      //                                 }
                      //                               } else {
                      //                                 Fluttertoast.showToast(
                      //                                     msg: 'Permission denied\ncan`t save');
                      //                                 setState(() {
                      //                                   buttonEvent = false;
                      //                                 });
                      //                               }
                      //                             }
                      //                            });
                                },
                                child: Container(
                                  height: 60,
                                  color: Colors.white,
                                  child: const Center(
                                    child: Text(
                                      'Save & New',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.white,
                                onTap: () {
                                 setState(() {
                                    // selectedCustomerId = acId;
                                  if (buttonEvent) {
                                    return;
                                  } else {
                                    if (companyUserData!.insertData) {
                                      if (!daysBefore) {
                                        if (totalItem > 0) {
                                          setState(() {
                                            _isLoading = true;
                                            buttonEvent = true;
                                            billingNameController.text.isNotEmpty ? 
                                            ledgerModel!.name = billingNameController.text
                                            :
                                            ledgerModel!.name; 
                                            
                                          });
                                          _insert(
                                              'SAVE DateTime:$formattedDate $timeIs location:${lId.toString()} ledger:${selectedCustomerId!} ${CartItem.encodeCartToJson(cartItem)}',
                                              0);
                                          saveSale();
                                          
                                          print('id ===== $selectedCustomerId');
                                        } else {
                                          Fluttertoast.showToast(
                                              msg:
                                                  'Please add at least one item');
                                          setState(() {
                                            buttonEvent = false;
                                          });
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                'Invoice Date not equal\ncan`t save');
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
                                 });
                                },
                                child: Container(
                                  height: 60,
                                  color: kPrimaryColor,
                                  child:  Center(
                                    child: !buttonEvent? const Text(
                                      'Save',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ):const FittedBox(child: CircularProgressIndicator()),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              // extendBody: true,
            ),
          ),
        ]),
      ),
    );
  }

  String selectedQuantity = '';
  List<String> selectedUnits = [];
  int? selectedItemId;
  bool isPrateEdited = false;
  String? selectedTaxOption = 'With Tax';
  late StockProduct selectedVariant;
  bool isVariantSelected = false;
  List<StockProduct> stockVariantProductList =[];
  var selectedItem;
  var fetchedData;
  addItemWidget() {
    
     List<UnitModel> unitListData = [];
    if (editItem) {
      editItem = true;
      cartModel = cartItem.elementAt(position!);
      // uniqueCode = selectedVariant.productId!;

      unitValue = cartModel!.unitValue!;
      debugPrint("unitvalue =${unitValue.toString()}");
      _dropDownUnit = cartModel!.unitId!;
      // rate = cartModel!.rate!;
      // _rateController.text = cartModel!.rate!.toStringAsFixed(decimal);
      _conversion = cartModel!.unitValue!;
      unit = DataJson(
                                              id: cartModel!.unitId,
                                              name: cartModel!.itemName!,
                                            );
      calculateTotal();
    }
    calculateTextBatch(StockProduct product, double qty) {
      double sRate = _rateController.text.isNotEmpty
        ? double.tryParse(_rateController.text)!
        : 0;

    double discP =  _discountPercentController.text.isNotEmpty
    ? double.tryParse(_discountPercentController.text)!
    : 0;
    
  double disc = double.parse((((qty * sRate)* discP)/100).toStringAsFixed(2));

    if (enableMULTIUNIT && rate > 0 && _conversion > 0) {
      rate = rate; // * _conversion;
      pRate = product.buyingPrice! * _conversion;
      rPRate = product.buyingPriceReal! * _conversion;
    } else {
      pRate = product.buyingPrice!;
      rPRate = product.buyingPriceReal!;
    }
    freeQty = _freeQuantityController.text.isNotEmpty
        ? double.tryParse(_freeQuantityController.text)!
        : 0;
    rRate = taxMethod == 'MINUS'
        ? cessOnNetAmount
            ? CommonService.getRound(
                4, (100 * rate) / (100 + taxP + kfcP + cessPer))
            : CommonService.getRound(4, (100 * rate) / (100 + taxP + kfcP))
        : rate;
    discount = disc;
    discountPercent = discP;
    // if (discP > 0) {
    //   discount =
    //       double.parse((((qt * sRate) * discP) / 100).toStringAsFixed(2));
    //   _discountController.text = discount.toStringAsFixed(2);
    //   discountPercent = discP;
    // } else if (disc > 0) {
    //   discountPercent =
    //       double.parse(((disc * 100) / (qt * sRate)).toStringAsFixed(2));
    //   _discountPercentController.text = discountPercent.toStringAsFixed(2);
    //   discount = disc;
    // }

    rDisc = taxMethod == 'MINUS'
        ? CommonService.getRound(
            4,
            ((discount * 100) /
                (cessOnNetAmount
                    ? (taxP + 100 + cessPer + kfcP)
                    : (taxP + 100 + kfcP))))
        : discount;
    gross = CommonService.getRound(decimal, ((rRate * qty)));
    subTotal = CommonService.getRound(decimal, (gross - rDisc));
    if (taxP > 0) {
      tax = CommonService.getRound(4, ((subTotal * taxP) / 100));
    }
    if (companyTaxMode == 'INDIA') {
      kfc = isKFC ? CommonService.getRound(4, ((subTotal * kfcP) / 100)) : 0;
      double csPer = taxP / 2;
      iGST = 0;
      csGST = CommonService.getRound(4, ((subTotal * csPer) / 100));
    } else if (companyTaxMode == 'GULF') {
      iGST = CommonService.getRound(4, ((subTotal * taxP) / 100));
      csGST = 0;
      kfc = 0;
    } else {
      iGST = 0;
      csGST = 0;
      kfc = 0;
      tax = 0;
    }
    if (cessOnNetAmount) {
      if (cessPer > 0) {
        cess = CommonService.getRound(4, ((subTotal * cessPer) / 100));
        adCess = CommonService.getRound(4, (qty * adCessPer));
      } else {
        cess = 0;
        adCess = 0;
      }
    } else {
      cess = 0;
      adCess = 0;
    }
    total = CommonService.getRound(
        2, (subTotal + csGST + csGST + iGST + cess + kfc + adCess));
    if (enableMULTIUNIT && _conversion > 0) {
      profitPer = pRateBasedProfitInSales
          ? CommonService.getRound(
              2, (total - (product.buyingPrice! * _conversion * qty)))
          : CommonService.getRound(
              decimal, (total - (product.buyingPriceReal! * _conversion * qty)));
    } else {
      profitPer = pRateBasedProfitInSales
          ? CommonService.getRound(2, (total - (product.buyingPrice! * qty)))
          : CommonService.getRound(
              2, (total - (product.buyingPriceReal! * qty)));
    }
    unitValue = _conversion > 0 ? _conversion : 1;
  }
    calculate() {
      uniqueCode = selectedVariant.productId!;
    if (enableMULTIUNIT) {
      if (saleRate > 0) {
        if (_conversion > 0) {
          //var r = 0.0;
          if (_focusNodeRate.hasFocus) {
            rate = double.tryParse(_rateController.text) ?? 0;
            // rate = double.tryParse(_rateController.text) * _conversion;
            lastRateStatus = false;
          } else {
            rate =  (saleRate * _conversion);
            // rate = saleRate; // * _conversion;
            _rateController.text = rate.toStringAsFixed(decimal);
          }
          //rate = r;
          // _rateController.text = r.toStringAsFixed(decimal);
          pRate = selectedVariant.buyingPrice! * _conversion;
          rPRate = selectedVariant.buyingPriceReal! * _conversion;
        } else {
          rate = (_rateController.text.isNotEmpty
              ? (double.tryParse(_rateController.text))
              : 0) ?? 0;
        }
      } else {
        rate = (_rateController.text.isNotEmpty
            ? (double.tryParse(_rateController.text))
            : 0)?? 0;
      }
    } else {
      if (_focusNodeRate.hasFocus) {
        rate = double.tryParse(_rateController.text)!;
        lastRateStatus = false;
      } else if (saleRate > 0) {
        _rateController.text = saleRate.toStringAsFixed(decimal);
        rate = saleRate;
      } else {
        rate = (_rateController.text.isNotEmpty
            ? double.tryParse(_rateController.text)
            : 0)!;
      }
    }
    if (_focusNodeQuantity.hasFocus) {
      quantity = (_quantityController.text.isNotEmpty
          ? double.tryParse(_quantityController.text)
          : 0)!;
    } else {
      quantity = (_quantityController.text.isNotEmpty
          ? double.tryParse(_quantityController.text)
          : 0)!;
    }
    freeQty = (_freeQuantityController.text.isNotEmpty
        ? double.tryParse(_freeQuantityController.text)
        : 0)!;
    rRate = taxMethod == 'MINUS'
        ? cessOnNetAmount
            ? CommonService.getRound(
                4, (100 * rate) / (100 + taxP + kfcP + cessPer))
            : CommonService.getRound(4, (100 * rate) / (100 + taxP + kfcP))
        : rate;
    discount = (_discountController.text.isNotEmpty
        ? double.tryParse(_discountController.text)
        : 0)!;
    double? discP = _discountPercentController.text.isNotEmpty
        ? double.tryParse(_discountPercentController.text)?? 0 
        : 0;
    double? disc = _discountController.text.isNotEmpty
        ? double.tryParse(_discountController.text)??0 
        : 0;
    double? qt = _quantityController.text.isNotEmpty
        ? double.tryParse(_quantityController.text)
        : 0;
    double? sRate = _rateController.text.isNotEmpty
        ? double.tryParse(_rateController.text)
        : 0;
    if (_focusNodeDiscountPer.hasFocus) {
      _discountController.text = _discountPercentController.text.isNotEmpty &&
              selectedTaxOption == 'With Tax'
          ? (((qt! * rRate!) * discP) / 100).toStringAsFixed(2) 
          : (((qt! * rate!) * discP) / 100).toStringAsFixed(2);
      discount = (_discountController.text.isNotEmpty
          ? double.tryParse(_discountController.text)
          : 0)!;
      discountPercent = double.tryParse(_discountPercentController.text) ?? 0;
    }

    if (_focusNodeDiscount.hasFocus) {
      _discountPercentController.text =
          _discountController.text.isNotEmpty && selectedTaxOption == 'With Tax'
              ? ((disc * 100) / (qt! * rRate!)).toStringAsFixed(2)
              : ((disc * 100) / (qt! * rate!)).toStringAsFixed(2);
      discountPercent = (_discountController.text.isNotEmpty
          ? double.tryParse(_discountPercentController.text)
          : 0)!;
      // discount = discountPercent > 0
      // ?
      double.tryParse(_discountController.text);
      // : discount;
    }
    rDisc = taxMethod == 'MINUS'
        ? CommonService.getRound(
            4,
            ((discount * 100) /
                (cessOnNetAmount
                    ? (taxP + 100 + cessPer + kfcP)
                    : (taxP + 100 + kfcP))))
        : discount;
    gross = selectedTaxOption == 'With Tax'
        ? CommonService.getRound(decimal, ((rRate * quantity)))
        : CommonService.getRound(decimal, ((rate * quantity)));
    subTotal = CommonService.getRound(decimal, (gross - rDisc));
    if (taxP > 0) {
      tax = CommonService.getRound(4, ((subTotal * taxP) / 100));
    }
    if (companyTaxMode == 'INDIA') {
      kfc = isKFC ? CommonService.getRound(4, ((subTotal * kfcP) / 100)) : 0;
      double csPer = taxP / 2;
      iGST = 0;
      csGST = CommonService.getRound(4, ((subTotal * csPer) / 100));
    } else if (companyTaxMode == 'GULF') {
      iGST = CommonService.getRound(4, ((subTotal * taxP) / 100));
      csGST = 0;
      kfc = 0;
    } else {
      iGST = 0;
      csGST = 0;
      kfc = 0;
      tax = 0;
    }
    if (cessOnNetAmount) {
      if (cessPer > 0) {
        cess = CommonService.getRound(4, ((subTotal * cessPer) / 100));
        adCess = CommonService.getRound(4, (quantity * adCessPer));
      } else {
        cess = 0;
        adCess = 0;
      }
    } else {
      cess = 0;
      adCess = 0;
    }
    total = CommonService.getRound(
        2, (subTotal + csGST + csGST + iGST + cess + kfc + adCess));
    if (enableMULTIUNIT && _conversion > 0) {
      profitPer = pRateBasedProfitInSales
          ? CommonService.getRound(
              2, (total - (selectedVariant.buyingPrice! * _conversion * quantity)))
          : CommonService.getRound(decimal,
              (total - (selectedVariant.buyingPriceReal! * _conversion * quantity)));
    } else {
      profitPer = pRateBasedProfitInSales
          ? CommonService.getRound(
              2, (total - (selectedVariant.buyingPrice! * quantity)))
          : CommonService.getRound(
              2, (total - (selectedVariant.buyingPriceReal! * quantity)));
    }
    unitValue = _conversion > 0 ? _conversion : 1;
  }
  calculateConversion() {
    if (enableMULTIUNIT) {
      if (saleRate > 0) {
        if (_conversion > 0 && !isPrateEdited) {
          //var r = 0.0;
          if (_focusNodeRate.hasFocus) {
            rate = double.tryParse(_rateController.text) ?? 0;
            // rate = double.tryParse(_rateController.text) * _conversion;
            lastRateStatus = false;
          } else {
            rate =  editItem ? saleRate : (saleRate * _conversion);
            // rate = saleRate; // * _conversion;
            _rateController.text = rate.toStringAsFixed(decimal);
          }
          //rate = r;
          // _rateController.text = r.toStringAsFixed(decimal);
          pRate = selectedVariant.buyingPrice! * _conversion;
          rPRate = selectedVariant.buyingPriceReal! * _conversion;
        } else {
          rate = (_rateController.text.isNotEmpty
              ? (double.tryParse(_rateController.text))
              : 0) ?? 0;
        }
      } else {
        rate = (_rateController.text.isNotEmpty
            ? (double.tryParse(_rateController.text))
            : 0)?? 0;
      }
    } else {
      if (_focusNodeRate.hasFocus) {
        rate = double.tryParse(_rateController.text)!;
        lastRateStatus = false;
      } else if (saleRate > 0) {
        _rateController.text = saleRate.toStringAsFixed(decimal);
        rate = saleRate;
      } else {
        rate = (_rateController.text.isNotEmpty
            ? double.tryParse(_rateController.text)
            : 0)!;
      }
    }
    if (_focusNodeQuantity.hasFocus) {
      quantity = (_quantityController.text.isNotEmpty
          ? double.tryParse(_quantityController.text)
          : 0)!;
    } else {
      quantity = (_quantityController.text.isNotEmpty
          ? double.tryParse(_quantityController.text)
          : 0)!;
    }
    freeQty = (_freeQuantityController.text.isNotEmpty
        ? double.tryParse(_freeQuantityController.text)
        : 0)!;
    rRate = taxMethod == 'MINUS'
        ? cessOnNetAmount
            ? CommonService.getRound(
                4, (100 * rate) / (100 + taxP + kfcP + cessPer))
            : CommonService.getRound(4, (100 * rate) / (100 + taxP + kfcP))
        : rate;
    discount = (_discountController.text.isNotEmpty
        ? double.tryParse(_discountController.text)
        : 0)!;
    double? discP = _discountPercentController.text.isNotEmpty
        ? double.tryParse(_discountPercentController.text)?? 0 
        : 0;
    double? disc = _discountController.text.isNotEmpty
        ? double.tryParse(_discountController.text)??0 
        : 0;
    double? qt = _quantityController.text.isNotEmpty
        ? double.tryParse(_quantityController.text)
        : 0;
    double? sRate = _rateController.text.isNotEmpty
        ? double.tryParse(_rateController.text)
        : 0;
    if (_focusNodeDiscountPer.hasFocus) {
      _discountController.text = _discountPercentController.text.isNotEmpty &&
              selectedTaxOption == 'With Tax'
          ? (((qt! * rRate!) * discP) / 100).toStringAsFixed(2) 
          : (((qt! * rate!) * discP) / 100).toStringAsFixed(2);
      discount = (_discountController.text.isNotEmpty
          ? double.tryParse(_discountController.text)
          : 0)!;
      discountPercent = double.tryParse(_discountPercentController.text) ?? 0;
    }

    if (_focusNodeDiscount.hasFocus) {
      _discountPercentController.text =
          _discountController.text.isNotEmpty && selectedTaxOption == 'With Tax'
              ? ((disc * 100) / (qt! * rRate!)).toStringAsFixed(2)
              : ((disc * 100) / (qt! * rate!)).toStringAsFixed(2);
      discountPercent = (_discountController.text.isNotEmpty
          ? double.tryParse(_discountPercentController.text)
          : 0)!;
      // discount = discountPercent > 0
      // ?
      double.tryParse(_discountController.text);
      // : discount;
    }
    rDisc = taxMethod == 'MINUS'
        ? CommonService.getRound(
            4,
            ((discount * 100) /
                (cessOnNetAmount
                    ? (taxP + 100 + cessPer + kfcP)
                    : (taxP + 100 + kfcP))))
        : discount;
    gross = selectedTaxOption == 'With Tax'
        ? CommonService.getRound(decimal, ((rRate * quantity)))
        : CommonService.getRound(decimal, ((rate * quantity)));
    subTotal = CommonService.getRound(decimal, (gross - rDisc));
    if (taxP > 0) {
      tax = CommonService.getRound(4, ((subTotal * taxP) / 100));
    }
    if (companyTaxMode == 'INDIA') {
      kfc = isKFC ? CommonService.getRound(4, ((subTotal * kfcP) / 100)) : 0;
      double csPer = taxP / 2;
      iGST = 0;
      csGST = CommonService.getRound(4, ((subTotal * csPer) / 100));
    } else if (companyTaxMode == 'GULF') {
      iGST = CommonService.getRound(4, ((subTotal * taxP) / 100));
      csGST = 0;
      kfc = 0;
    } else {
      iGST = 0;
      csGST = 0;
      kfc = 0;
      tax = 0;
    }
    if (cessOnNetAmount) {
      if (cessPer > 0) {
        cess = CommonService.getRound(4, ((subTotal * cessPer) / 100));
        adCess = CommonService.getRound(4, (quantity * adCessPer));
      } else {
        cess = 0;
        adCess = 0;
      }
    } else {
      cess = 0;
      adCess = 0;
    }
    total = CommonService.getRound(
        2, (subTotal + csGST + csGST + iGST + cess + kfc + adCess));
    if (enableMULTIUNIT && _conversion > 0) {
      profitPer = pRateBasedProfitInSales
          ? CommonService.getRound(
              2, (total - (selectedVariant.buyingPrice! * _conversion * quantity)))
          : CommonService.getRound(decimal,
              (total - (selectedVariant.buyingPriceReal! * _conversion * quantity)));
    } else {
      profitPer = pRateBasedProfitInSales
          ? CommonService.getRound(
              2, (total - (selectedVariant.buyingPrice! * quantity)))
          : CommonService.getRound(
              2, (total - (selectedVariant.buyingPriceReal! * quantity)));
    }
    unitValue = _conversion > 0 ? _conversion : 1;
  }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          backgroundColor: bagroundColor,
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Add Item to Sales'),
            titleTextStyle: const TextStyle(fontFamily: 'poppins'),
            leading: IconButton(
                onPressed: () {
                  setState(() {
                    nextWidget = 0;
                    itemNameControl.clear();
                    selectedQuantity = '';
                    _quantityController.clear();
                    clearValue();
                  });
                },
                icon: const Icon(Icons.arrow_back)),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings, color: white))
            ],
          ),
          body: 
          // ref.watch(productsProvider).when(
          //       data: (data) {
          //         List<String> itemNames =
          //         itemCodeViseChek 
          //         ? data.map((e) => e.code!).toList()
          //         : data.map((item) => item.name!).toList();
          //         return

            // StreamBuilder<List<StockItem>>(
            // stream: (salesTypeData!.type == 'SALES-O' ||
            //     salesTypeData!.type == 'SALES-Q')
            // ? isStockProductOnlyInSalesQO
            //     ? api.fetchStockProductLikes(
            //         DateUtil.dateDMY2YMD(formattedDate), itemNameControl.text)
            //     : api.fetchNoStockProductLikes(
            //         DateUtil.dateDMY2YMD(formattedDate), itemNameControl.text)
            // : api.fetchStockProductLikes(
            //     DateUtil.dateDMY2YMD(formattedDate), itemNameControl.text),
            // // fetchStockProducts(itemNameControl.text),
            // builder: (context, snapshot) {
            //     if (snapshot.hasError) {
            //                     return Text('Error: ${snapshot.error}');
            //                   }
            //                   //  else if (snapshot.connectionState == ConnectionState.waiting){
            //                   //    isLoading == true;
            //                   // }
            //                   else if (!snapshot.hasData) {
            //                     return const Text('No data found');
            //                   }
                   
            //     final itemNameListDisplay = snapshot.data!
            //         .map((item) => item.name)
            //         .where((name) => name != null)
            //         .cast<String>()
            //         .toList();

            //     return
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          width: MediaQuery.sizeOf(context).width,
                          color: white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '  Item Name',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 12,
                                    child:
                                     StreamBuilder(
                                      stream: (salesTypeData!.type == 'SALES-O' ||
                salesTypeData!.type == 'SALES-Q')
            ? isStockProductOnlyInSalesQO
                ? api.fetchStockProducts(
                    DateUtil.dateDMY2YMD(formattedDate))
                : api.fetchNoStockProducts(
                    DateUtil.dateDMY2YMD(formattedDate))
            : api.fetchStockProducts(
                DateUtil.dateDMY2YMD(formattedDate),),
            // fetchStockProducts(itemNameControl.text), ,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              //  else if (snapshot.connectionState == ConnectionState.waiting){
                              //    isLoading == true;
                              // }
                              else if (!snapshot.hasData) {
                                return const Text('No data found');
                              }
                   
                final itemNameListDisplay =
                itemCodeViseChek
                ? snapshot.data!
                    .map((item) => item.code)
                    .where((name) => name != null)
                    .cast<String>()
                    .toList()
                : snapshot.data!
                    .map((item) => item.name)
                    .where((name) => name != null)
                    .cast<String>()
                    .toList();
                                        return EasyAutocomplete(
                                          // progressIndicatorBuilder:
                                          //     const CircularProgressIndicator(),
                                          controller: itemNameControl,
                                          inputTextStyle: const TextStyle(
                                              fontFamily: 'poppins', fontSize: 14),
                                          suggestionTextStyle:
                                              const TextStyle(fontFamily: 'poppins'),
                                          decoration:  const InputDecoration(
                                                                  //               suffixIcon:  Visibility(
                                                                  //   visible: enableBarcode,
                                                                  //   child: IconButton(
                                                                  //       onPressed: () {
                                                                  //         searchProductBarcode();
                                                                  //       },
                                                                  //       icon: const Icon(Icons.document_scanner)),
                                                                  // ),
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 5),
                                            border: OutlineInputBorder(),
                                          ),
                                          suggestions: itemNameListDisplay,
                                          onChanged: (value) {
                                            // print('onChanged value: $value');
                                          },
                                          onSubmitted: (value) async{
                                            // clearValue();
                                            // itemNameControl.text = '';
                                            // setState(() {
                                            
                                               selectedItem = 
                                              itemCodeViseChek 
                                              ? snapshot.data!.firstWhere(
                                                (element) => element.code == value)
                                              : snapshot.data!.firstWhere(
                                                (element) => element.name == value,
                                              );
                                              
                                               itemNameControl.text = selectedItem.name!;
                                              _dropDownUnit = 0;
                                              rate = 0;
                                              quantity = 0;
                                              _quantityController.text = '';
                                              _discountController.text = '';
                                              _discountPercentController.text = '';
                                              tax = 0;
                                              _rateController.text = '';
                                              discount = 0;
                                              discountPercent = 0;
                                              subTotal = 0;
                                              total = 0;
                                              gross = 0;
                                              _autoVariantSelect = selectedItem.hasVariant! ? true : false;
                                              selectedQuantity =
                                                  selectedItem.quantity.toString();
                                              selectedItemId = selectedItem.id!;
                                               fetchedData = selectedItemId != null
                                                 ? salesTypeData!.type == 'SALE-0' || salesTypeData!.type == 'SALE-Q'
                                                 ? isStockProductOnlyInSalesQO
                                        ? await api.fetchNoStockVariants(selectedItemId.toString())
                                        : await api.fetchStockVariants(selectedItemId!)
                                        : _autoVariantSelect 
                                        ? await api.fetchStockVariantListStream(selectedItemId!) 
                                        :await api.fetchStockVariants(selectedItemId!)
                                                  : null
                                                  ;
                                              if (fetchedData != null) {
                                                fetchedData.listen((variants) {
                                                 selectedVariant = variants.firstWhere(
                                                    (element) =>
                                                        element.itemId == selectedItemId,
                                                    orElse: () => StockProduct.empty(),
                                                  );
                                                  if (_autoVariantSelect) {
                                                  stockVariantProductList.clear();
                                                   stockVariantProductList.addAll(variants) ;
                                                }
                                                  Future<double?> rateFuture;
                                                  if (salesTypeData!.rateType == 'MRP') {
                                                    rateFuture = Future.value(
                                                        selectedVariant.sellingPrice);
                                                  } else if (salesTypeData!.rateType ==
                                                      'WHOLESALE') {
                                                    rateFuture = Future.value(
                                                        selectedVariant.wholeSalePrice);
                                                  } else if (salesTypeData!.rateType ==
                                                      'RETAIL') {
                                                    rateFuture = Future.value(
                                                        selectedVariant.retailPrice);
                                                  } else if (salesTypeData!.rateType ==
                                                      'SPRETAIL') {
                                                    rateFuture = Future.value(
                                                        selectedVariant.spRetailPrice);
                                                  } else if (rateTypeItem!.name == 'MRP') {
                                                    rateFuture = Future.value(
                                                        selectedVariant.sellingPrice);
                                                  } else if (rateTypeItem!.name == 'RETAIL') {
                                                    rateFuture = Future.value(
                                                        selectedVariant.retailPrice);
                                                  } else if (rateTypeItem!.name == 'SPRETAIL') {
                                                    rateFuture = Future.value(
                                                        selectedVariant.spRetailPrice);
                                                  } else if (rateTypeItem!.name == 'BRANCH') {
                                                    rateFuture = Future.value(
                                                        selectedVariant.branch);
                                                  }else if (rateTypeItem!.name == 'WHOLESALE') {
                                                    rateFuture = Future.value(
                                                        selectedVariant.wholeSalePrice);
                                                  } else {
                                                    rateFuture = Future.value(null);
                                                  }
                                                  rateFuture.then((rate) {
                                                    if (rate != null) {
                                                      _rateController.text =
                                                          rate.toStringAsFixed(2);
                                                       
                                                    }
                                                  });
                                                   salesTypeData!.type != 'SALES-ES' 
                                                   ?taxP = selectedVariant.tax! ?? 0
                                                   :taxP = 0;
                                                });
                                              }
                                            // });
                                            // print('onSubmitted value: $selectedItemId');
                                          },
                                        );
                                      }
                                    ),
                                  ),
                                   Visibility(
                                    visible: itemCodeVise,
                                     child: Flexible(
                                                               // flex: 1,
                                                               child: Visibility(
                                                                 visible: itemCodeVise,
                                                                 child: Checkbox(
                                                                 activeColor: kPrimaryColor,
                                                                 value: itemCodeViseChek,
                                                                 onChanged: (value) {
                                                                setState(() {
                                                                 itemCodeViseChek = value!;
                                                                });
                                                                 },),
                                                               )),
                                   ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
    //                           Consumer(builder: (context, ref, child) {
    //                            final stockVariants = ref.watch(stockVariantsProvider(selectedItemId??0));
    //                              return stockVariants.when(
    //   data: (items) => ListView.builder(
    //     itemCount: 1,
    //     shrinkWrap: true,
    //     itemBuilder: (context, index) {
    //        if (items.isEmpty) {
    //             return const Center(
    //               child: Text('No items found.'),
    //             );
    //           }
    //       final item = items[index];
    //       return ListTile(
    //         title: Text(item.tax.toString()),
    //         subtitle: Text(item.itemId.toString()),
    //       );
    //     },
    //   ),
    //   loading: () => CircularProgressIndicator(),
    //   error: (err, stack) => Text('Error: $err'),
    // );
    //                           },),
                              StreamBuilder(
                                stream: selectedItemId != null
                                   ? salesTypeData!.type == 'SALE-0' || salesTypeData!.type == 'SALE-Q'
                                   ? isStockProductOnlyInSalesQO
                                    ? api.fetchNoStockVariants(selectedItemId.toString())
                                    : api.fetchStockVariants(selectedItemId!)
                                    // : api.fetchStockVariants(0)
                                    :api.fetchStockVariants(selectedItemId!)
                                    :api.fetchStockVariants(0),
                                builder: (context, snapshot) {
                                  // if (snapshot.connectionState ==
                                  //     ConnectionState.waiting) {
                                  //   return const Center(
                                  //       child: CircularProgressIndicator());
                                  // }
                                  if (snapshot.hasData ){
                                     if( snapshot.data!.isEmpty) {
                                        if (oldBill) {
                                          selectedVariant = StockProduct(
                        adCessPer: cartModel!.adCessPer,
                        branch: 0,
                        brand: 0,
                        buyingPrice: cartModel!.pRate,
                        buyingPriceReal: cartModel!.rPRate,
                        categoryId: 0,
                        cess: cartModel!.cess,
                        cessPer: cartModel!.cessPer,
                        color: 0,
                        company: 0,
                        estUniqueCode: 0,
                        expDate: cartModel!.expDate,
                        free: cartModel!.free,
                        hsnCode: cartModel!.hashCode.toString(),
                        itemId: cartModel!.itemId,
                        locationId: lId,
                        locked: 'N',
                        mfrId: 0,
                        minimumRate: cartModel!.minimumRate,
                        name: cartModel!.itemName,
                        oBarcode: '',
                        productId: cartModel!.uniqueCode,
                        quantity: cartModel!.quantity,
                        rackId: 0,
                        retailPrice: cartModel!.rate,
                        sellingPrice: cartModel!.rate,
                        serialNo: cartModel!.serialNo,
                        size: 0,
                        spRetailPrice: cartModel!.rate,
                        stockValuation: '',
                        subcategoryId: 0,
                        supplierId: 0,
                        tax: cartModel!.taxP,
                        taxType: 'T',
                        unitId: cartModel!.unitId,
                        wholeSalePrice: cartModel!.rate);
                            
                                   return  Form(
                                    key: _resetKey,
                                    autovalidateMode: AutovalidateMode.always,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: ContainerFieldWidget(
                                                    widget: TextFormField(
                                                      controller:
                                                          _quantityController,
                                                      focusNode:
                                                          _focusNodeQuantity,
                                                      // autofocus: true,
                                                      validator: (value) {
                                                        if (outOfStock) {
                                                          return 'No Stock';
                                                        }
                                                        return null;
                                                      },
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal: true),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter(
                                                            RegExp(r'[0-9]'),
                                                            allow: true,
                                                            replacementString:
                                                                '.')
                                                      ],
                                                      decoration: InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 4,
                                                                  vertical: 10),
                                                          hintStyle:
                                                              const TextStyle(
                                                                  color: grey,
                                                                  fontFamily:
                                                                      'poppins',
                                                                  fontSize: 12),
                                                          hintText: selectedQuantity
                                                                  .isEmpty
                                                              ? ''
                                                              : 'Available quantity $selectedQuantity',
                                                          border:
                                                              const OutlineInputBorder()),
                                                      onChanged: (value) {
                                                        if (value.isNotEmpty) {
                                                          bool cartQ = false;
                                                          setState(() {
                                                            if (totalItem > 0) {
                                                              double cartS = 0,
                                                                  cartQt = 0;
                                                              for (var element
                                                                  in cartItem) {
                                                                if (element.uniqueCode ==selectedVariant.productId) {
                                                                  cartQt += element.quantity! +
                                                                      element.free!;
                                                                  cartS = element.stock!;
                                                                }
                                                              }
                                                              if (cartS > 0) {
                                                                if (cartS <cartQt +double.tryParse(value)!) {
                                                                  cartQ = true;
                                                                }
                                                              }
                                                            }
                                                            outOfStock = isLockQtyOnlyInSales
                                                                ? (double.tryParse(value)!)  * unitValue + freeQty  > 
                                                                 (_autoVariantSelect ?  stockVariantProductList.fold(0.0 ,  (a, b) => a + double.parse(b.quantity.toString())) : 
                                                                 selectedVariant.quantity! )
                                                                    ? true
                                                                    : cartQ
                                                                        ? true
                                                                        : false
                                                                : negativeStock
                                                                    ? false
                                                                    : salesTypeData!.type == 'SALES-O' || salesTypeData!.type == 'SALES-Q'
                                                                        ? isStockProductOnlyInSalesQO
                                                                            ? ((double.tryParse(value)! * unitValue) + freeQty) > 
                                                                             (_autoVariantSelect ?  stockVariantProductList.fold(0.0 ,  (a, b) => a + double.parse(b.quantity.toString())) :
                                                                            selectedVariant.quantity!)
                                                                                ? true
                                                                                : cartQ
                                                                                    ? true
                                                                                    : false
                                                                            : false
                                                                        : ((double.tryParse(value)! * unitValue) + freeQty) >
                                                                          (_autoVariantSelect ?  stockVariantProductList.fold(0.0 ,  (a, b) => a + double.parse(b.quantity.toString())) :
                                                                         selectedVariant.quantity!)
                                                                            ? true
                                                                            : cartQ
                                                                                ? true
                                                                                : false;
                                                            calculateConversion();
                                                          });
                                                        }
                                                      },
                                                    ),
                                                    headTxt: 'Quantity')),
                                                     Visibility(
                                                            visible: isFreeQty,
                                                            child: Expanded(
                                                                child: ContainerFieldWidget(widget: TextFormField(
                                                                  controller: _freeQuantityController,
                                                                  focusNode: _focusNodeFreeQuantity,
                                                                  // autofocus: true,
                                                                  validator: (value) {
                                                                    if (outOfStock) {
                                                                        return 'No Stock';
                                                                    }
                                                                    return null;
                                                                  },
                                                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                      allow: true, replacementString: '.')
                                                                  ],
                                                                  decoration: const InputDecoration(
                                                                     contentPadding:
                                                               EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 4,
                                                                  vertical: 10),
                                    border: OutlineInputBorder(
                                    
                                    ),
                                    labelText: 'Free',
                                    hintText: '0.0'),
                                       onChanged: (value) {
                                        if (value.isNotEmpty) {
                                    bool cartQ = false;
                                    setState(() {
                                      if (totalItem > 0) {
                                        double cartS = 0, cartQt = 0;
                                        for (var element in cartItem) {
                                          if (element.uniqueCode ==
                                              selectedVariant.productId) {
                                            cartQt +=
                                                element.quantity! + element.free!;
                                            cartS = element.stock!;
                                          }
                                        }
                                        if (cartS > 0) {
                                          if (cartS <
                                              cartQt + double.tryParse(value)!) {
                                            cartQ = true;
                                          }
                                        }
                                      }
                                                                
                                      outOfStock = isLockQtyOnlyInSales
                                          ? ((quantity * unitValue) +
                                                      double.tryParse(value)!) >
                                                  selectedVariant.quantity!
                                              ? true
                                              : cartQ
                                                  ? true
                                                  : false
                                          : negativeStock
                                              ? false
                                              : salesTypeData!.type == 'SALES-O' ||
                                                      salesTypeData!.type ==
                                                          'SALES-Q'
                                                  ? isStockProductOnlyInSalesQO
                                                      ? ((quantity * unitValue) +
                                                                  double.tryParse(
                                                                      value)!) >
                                                              selectedVariant.quantity!
                                                          ? true
                                                          : cartQ
                                                              ? true
                                                              : false
                                                      : false
                                                  : ((quantity * unitValue) +
                                                              double.tryParse(
                                                                  value)!) >
                                                          selectedVariant.quantity!
                                                      ? true
                                                      : cartQ
                                                          ? true
                                                          : false;
                                      calculate();
                                    });
                                    }
                                    },
                                  ), headTxt: 'Quantity')),
                                    ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Visibility(
                                              visible: enableMULTIUNIT,
                                              child: Expanded(
                                                  child: ContainerFieldWidget(
                                                      widget: Container(
                                                          margin:
                                                              const EdgeInsets.only(
                                                                  bottom: 7),
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  left: 5),
                                                          width:
                                                              MediaQuery.of(context)
                                                                  .size
                                                                  .width,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: grey),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(3)),
                                                          child: FutureBuilder(
                                                            future: api.fetchUnitOf(
                                                                selectedItemId!),
                                                            builder: (BuildContext
                                                                    context,
                                                                AsyncSnapshot
                                                                    snapshot) {
                                                              List<UnitModel>
                                                                  unitListData = [];
                                                              if (snapshot.hasData) {
                                                                // unitListData
                                                                //     .clear();
                                                                for (var i = 0;
                                                                    i <snapshot.data.length;i++) {
                                                                  if (defaultUnitID.toString().isNotEmpty) {
                                                                    if (snapshot.data[i].id == defaultUnitID! -1) {
                                                                      _dropDownUnit =snapshot.data[i].id;
                                                                      _conversion =snapshot.data[i].conversion;
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
                                                              return snapshot.data !=null &&
                                                                      snapshot.data!.length > 0
                                                                  ? DropdownButtonHideUnderline(
                                                                      child: DropdownButton<String>(
                                                                        isExpanded:true,
                                                                      
                                                                        hint: Text(_dropDownUnit > 0
                                                                            ? UnitSettings.getUnitName(_dropDownUnit)
                                                                            : 'Unit',
                                                                            style: const TextStyle(
                                                                              fontFamily: 'poppins',
                                                                              color: black,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w400
                                                                            ),
                                                                            ),
                                                                        items: snapshot.data!.map<DropdownMenuItem<String>>(
                                                                                (item) {
                                                                          return DropdownMenuItem<String>(
                                                                            value: item.id.toString(),
                                                                            child: Text(item.name!,
                                                                                style: const TextStyle(
                                                                                  fontSize: 12,
                                                                                  color: black,
                                                                                  fontFamily: 'poppins')),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:(value) {
                                                                          setState(() {
                                                                            bool cartQ = false;
                                                                            _dropDownUnit =int.tryParse(value!)!;
                                                                            for (var i =0; i < unitListData.length;i++) {
                                                                              UnitModel _unit = unitListData[i];
                                                                              if (_unit.unit == int.tryParse(value)) {
                                                                                double? _rate = _unit.rate == 'MRP'
                                                                                    ? selectedVariant.sellingPrice
                                                                                    : _unit.rate == 'WHOLESALE'
                                                                                        ? selectedVariant.wholeSalePrice
                                                                                        : _unit.rate == 'RETAIL'
                                                                                            ? selectedVariant.retailPrice
                                                                                            : _unit.rate == 'SPRETAIL'
                                                                                                ? selectedVariant.spRetailPrice
                                                                                                : rateTypeItem!.name == 'MRP'
                                                                                                    ? selectedVariant.sellingPrice
                                                                                                    : rateTypeItem!.name == 'RETAIL'
                                                                                                        ? selectedVariant.retailPrice
                                                                                                    : rateTypeItem!.name == 'BRANCH'
                                                                                                        ? selectedVariant.branch
                                                                                                    : rateTypeItem!.name == 'SPRETAIL'
                                                                                                        ? selectedVariant.spRetailPrice
                                                                                                        : rateTypeItem!.name == 'WHOLESALE'
                                                                                                            ? selectedVariant.wholeSalePrice
                                                                                                            : rate;
                                                                                if (_unit.rate!.isNotEmpty) {
                                                                                  rateTypeItem = rateTypeList.firstWhere((element) => element.name == _unit.rate);
                                                                                }
                                                                                rate =_rate!;
                                                                                saleRate = _rate;
                                                                                _rateController.text = saleRate > 0
                                                                                    ? saleRate.toStringAsFixed(2)
                                                                                    : '';
                                                                                _conversion = _unit.conversion!;
                                                                                if (quantity > 0 || freeQty > 0) {
                                                                                  if (totalItem > 0) {
                                                                                    double cartS = 0, cartQt = 0;
                                                                                    for (var element in cartItem) {
                                                                                      if (element.uniqueCode == selectedVariant.productId) {
                                                                                        cartQt += element.quantity! + element.free!;
                                                                                        cartS = element.stock!;
                                                                                      }
                                                                                    }
                                                                                    if (cartS > 0) {
                                                                                      if (cartS < cartQt + quantity + freeQty) {
                                                                                        cartQ = true;
                                                                                      }
                                                                                    }
                                                                                  } else {
                                                                                    cartQ = false;
                                                                                  }
                                                                                  outOfStock = isLockQtyOnlyInSales
                                                                                      ? ((quantity * _conversion) + freeQty) > selectedVariant.quantity!
                                                                                          ? true
                                                                                          : cartQ
                                                                                              ? true
                                                                                              : false
                                                                                      : negativeStock
                                                                                          ? false
                                                                                          : salesTypeData!.type == 'SALES-O' || salesTypeData!.type == 'SALES-Q'
                                                                                              ? isStockProductOnlyInSalesQO
                                                                                                  ? ((quantity * _conversion) + freeQty) > selectedVariant.quantity!
                                                                                                      ? true
                                                                                                      : cartQ
                                                                                                          ? true
                                                                                                          : false
                                                                                                  : false
                                                                                              : ((quantity * _conversion) + freeQty) > selectedVariant.quantity!
                                                                                                  ? true
                                                                                                  : cartQ
                                                                                                      ? true
                                                                                                      : false;
                                                                                }
                                                                                break;
                                                                              }
                                                                            }
                                                                            calculate();
                                                                          });
                                                                        },
                                                                      ),
                                                                    )
                                                                  : DropdownButtonHideUnderline(
                                                                      child: DropdownButton<String>(
                                                                        isExpanded: true,
                                                                        
                                                                        hint: Text(_dropDownUnit > 0
                                                                            ? UnitSettings.getUnitName(_dropDownUnit)
                                                                            : 'Unit',style: const TextStyle(
                                                                              fontFamily: 'poppins',
                                                                              color: black,
                                                                              fontWeight: FontWeight.w400
                                                                            ),),
                                                                        items: unitListSettings.map<DropdownMenuItem<String>>((item) {
                                                                          return DropdownMenuItem<String>(
                                                                            value: item.key.toString(),
                                                                            child:Text(
                                                                              item.value,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                  fontFamily: 'poppins',
                                                                                  color: black),
                                                                            ),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:(value) {
                                                                          setState(() {
                                                                            _dropDownUnit = int.tryParse(value!)!;
                                                                            calculate();
                                                                            // for (var i = 0;
                                                                            //     i < unitListData.length;
                                                                            //     i++) {
                                                                            //   UnitModel
                                                                            //       _unit =
                                                                            //       unitListData[i];
                                                                            //   if (_unit.unit ==
                                                                            //       int.tryParse(value)) {
                                                                            //     _conversion = _unit.conversion!;
                                                                            //     break;
                                                                            //   }
                                                                            // }
                                                                            // calculate(
                                                                            //     selectedVariant);
                                                                          });
                                                                        },
                                                                      ),
                                                                    );
                                                            },
                                                          )),
                                                      headTxt: 'Unit')),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: ContainerFieldWidget(
                                                    widget: TextField(
                                                      controller: _rateController,
                                                      focusNode: _focusNodeRate,
                                                      readOnly: isItemRateEditLocked,
                                                      keyboardType:
                                                          const TextInputType.numberWithOptions(decimal: true),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter(
                                                            RegExp(r'[0-9]'),
                                                            allow: true,
                                                            replacementString:
                                                                '.')
                                                      ],
                                                      decoration: const InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          5),
                                                          border:
                                                              OutlineInputBorder()),
                                                      onChanged: (value) {
                                                         if (value.isNotEmpty) {
                                        isPrateEdited = true;
                                      }
                                                        if (value.isNotEmpty) {
                                                          if (isMinimumRate) {
                                                            double minRate =
                                                                selectedVariant
                                                                        .minimumRate ??
                                                                    0;
                                                            if (double.tryParse(
                                                                    _rateController
                                                                        .text)! >=
                                                                minRate) {
                                                              setState(() {
                                                                isMinimumRatedLock =
                                                                    false;
                                                                calculateConversion();
                                                              });
                                                            } else {
                                                              setState(() {
                                                                isMinimumRatedLock =
                                                                    true;
                                                              });
                                                            }
                                                          } else {
                                                            setState(() {
                                                              editItem
                                                              ? calculateConversion()
                                                              : calculateConversion();
                                                            });
                                                          }
                                                        }
                                                      },
                                                    ),
                                                    headTxt: 'Rate(Price/Unit)')),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            salesTypeData!.type == 'SALES-ES'
                                            ?const SizedBox()
                                           : Expanded(
                                                child: ContainerFieldWidget(
                                                    widget: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 7),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                3),
                                                      ),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton<
                                                            String>(
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'poppins',
                                                              color: black),
                                                          value:
                                                              selectedTaxOption,
                                                          items: [
                                                            const DropdownMenuItem(
                                                              value: 'With Tax',
                                                              child: Text(
                                                                  'With Tax'),
                                                            ),
                                                            DropdownMenuItem(
                                                              onTap: () {
                                                                salesTypeData!
                                                                              .id ==
                                                                          1 ||
                                                                      salesTypeData!
                                                                              .id ==
                                                                          2 ?
                                                                          selectedTaxOption == 'Without Tax'
                                                                          ? Fluttertoast.showToast(msg: "Can't select")
                                                                          :null
                                                                          :null;
                                                              },
                                                              enabled: salesTypeData!
                                                                              .id ==
                                                                          1 ||
                                                                      salesTypeData!
                                                                              .id ==
                                                                          2
                                                                  ? false
                                                                  : true,
                                                              value:
                                                                  'Without Tax',
                                                              child: const Text(
                                                                  'Without Tax'),
                                                            ),
                                                          ],
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedTaxOption = value!;
                                                              value == 'Without Tax' 
                                                                  ? isTax = false
                                                                  : isTax = true;
                                                              calculateConversion();
                                                            });
                                                          },
                                                          isExpanded: true,
                                                        ),
                                                      ),
                                                    ),
                                                    headTxt: 'Tax')),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                        } else{
                                         return const Center(
                                        child: Text('Select a Item'));
                                        }
                                        
                                  }
                                  else {
                                  final fetchedData = snapshot.data!;
                                  selectedVariant = fetchedData.firstWhere(
                                    (element) =>
                                        element.itemId == selectedItemId,
                                    orElse: () => StockProduct.empty(),
                                  );
                                  List<UnitModel> unitListData = [];
                                  for (var i = 0;
                                      i < unitListData.length;
                                      i++) {
                                    // UnitModel _unit = unitListData[i];
                                  }
                                  // double? _rate = salesTypeData!.rateType ==
                                  //         'MRP'
                                  //     ? selectedVariant.sellingPrice
                                  //     : salesTypeData!.rateType == 'WHOLESALE'
                                  //         ? selectedVariant.wholeSalePrice
                                  //         : salesTypeData!.rateType == 'RETAIL'
                                  //             ? selectedVariant.retailPrice
                                  //             : salesTypeData!.rateType ==
                                  //                     'SPRETAIL'
                                  //                 ? selectedVariant
                                  //                     .spRetailPrice
                                  //                 : rateType == '1'
                                  //                     ? selectedVariant
                                  //                         .sellingPrice
                                  //                     : rateType == '2'
                                  //                         ? selectedVariant
                                  //                             .retailPrice
                                  //                         : rateType == '3'
                                  //                             ? selectedVariant
                                  //                                 .wholeSalePrice
                                  //                             : rate;
                                  // if (salesTypeData!.rateType.isNotEmpty) {
                                  //   rateTypeItem = rateTypeList.firstWhere(
                                  //       (element) =>
                                  //           element.name ==
                                  //           salesTypeData!.rateType);
                                  // }
                                  // rate = _rate!;
                                  // saleRate = _rate;
                                  // if (saleRate > 0) {
                                  //   _rateController.text = _rate.toString();
                                  // }
                                  // final unitId = data!.map((e) => e.unitId);
                                  return Form(
                                    key: _resetKey,
                                    autovalidateMode: AutovalidateMode.always,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: ContainerFieldWidget(
                                                    widget: TextFormField(
                                                      controller:
                                                          _quantityController,
                                                      focusNode:
                                                          _focusNodeQuantity,
                                                      // autofocus: true,
                                                      validator: (value) {
                                                        if (outOfStock) {
                                                          return 'No Stock';
                                                        }
                                                        return null;
                                                      },
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal: true),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter(
                                                            RegExp(r'[0-9]'),
                                                            allow: true,
                                                            replacementString:
                                                                '.')
                                                      ],
                                                      decoration: InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 4,
                                                                  vertical: 10),
                                                          hintStyle:
                                                              const TextStyle(
                                                                  color: grey,
                                                                  fontFamily:
                                                                      'poppins',
                                                                  fontSize: 12),
                                                          hintText: selectedQuantity
                                                                  .isEmpty
                                                              ? ''
                                                              : 'Available quantity $selectedQuantity',
                                                          border:
                                                              const OutlineInputBorder()),
                                                      onChanged: (value) {
                                                        if (value.isNotEmpty) {
                                                          bool cartQ = false;
                                                          setState(() {
                                                            if (totalItem > 0) {
                                                              double cartS = 0,
                                                                  cartQt = 0;
                                                              for (var element
                                                                  in cartItem) {
                                                                if (element.uniqueCode ==selectedVariant.productId) {
                                                                  cartQt += element.quantity! +
                                                                      element.free!;
                                                                  cartS = oldBill ? (element.quantity+selectedVariant.quantity!) : element.stock!;
                                                                }
                                                              }
                                                              if (cartS > 0) {
                                                                if (cartS <cartQt +double.tryParse(value)!) {
                                                                  cartQ = true;
                                                                }
                                                              }
                                                            }
                                                            outOfStock = isLockQtyOnlyInSales
                                                                ? (double.tryParse(value)!)  * unitValue + freeQty  > 
                                                                 (_autoVariantSelect ?  stockVariantProductList.fold(0.0 ,  (a, b) => a + double.parse(b.quantity.toString())) : 
                                                                 selectedVariant.quantity! )
                                                                    ? true
                                                                    : cartQ
                                                                        ? true
                                                                        : false
                                                                : negativeStock
                                                                    ? false
                                                                    : salesTypeData!.type == 'SALES-O' || salesTypeData!.type == 'SALES-Q'
                                                                        ? isStockProductOnlyInSalesQO
                                                                            ? ((double.tryParse(value)! * unitValue) + freeQty) > 
                                                                             (_autoVariantSelect ?  stockVariantProductList.fold(0.0 ,  (a, b) => a + double.parse(b.quantity.toString())) :
                                                                            selectedVariant.quantity!)
                                                                                ? true
                                                                                : cartQ
                                                                                    ? true
                                                                                    : false
                                                                            : false
                                                                        : ((double.tryParse(value)! * unitValue) + freeQty) >
                                                                          (_autoVariantSelect ?  stockVariantProductList.fold(0.0 ,  (a, b) => a + double.parse(b.quantity.toString())) :
                                                                         selectedVariant.quantity!)
                                                                            ? true
                                                                            : cartQ
                                                                                ? true
                                                                                : false;
                                                            calculateConversion();
                                                          });
                                                        }
                                                      },
                                                    ),
                                                    headTxt: 'Quantity')),
                                                     Visibility(
                                                            visible: isFreeQty,
                                                            child: Expanded(
                                                                child: ContainerFieldWidget(widget: TextFormField(
                                                                  controller: _freeQuantityController,
                                                                  focusNode: _focusNodeFreeQuantity,
                                                                  // autofocus: true,
                                                                  validator: (value) {
                                                                    if (outOfStock) {
                                                                        return 'No Stock';
                                                                    }
                                                                    return null;
                                                                  },
                                                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                      allow: true, replacementString: '.')
                                                                  ],
                                                                  decoration: const InputDecoration(
                                                                     contentPadding:
                                                               EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 4,
                                                                  vertical: 10),
                                    border: OutlineInputBorder(
                                    
                                    ),
                                    labelText: 'Free',
                                    hintText: '0.0'),
                                       onChanged: (value) {
                                        if (value.isNotEmpty) {
                                    bool cartQ = false;
                                    setState(() {
                                      if (totalItem > 0) {
                                        double cartS = 0, cartQt = 0;
                                        for (var element in cartItem) {
                                          if (element.uniqueCode ==
                                              selectedVariant.productId) {
                                            cartQt +=
                                                element.quantity! + element.free!;
                                            cartS = element.stock!;
                                          }
                                        }
                                        if (cartS > 0) {
                                          if (cartS <
                                              cartQt + double.tryParse(value)!) {
                                            cartQ = true;
                                          }
                                        }
                                      }
                                                                
                                      outOfStock = isLockQtyOnlyInSales
                                          ? ((quantity * unitValue) +
                                                      double.tryParse(value)!) >
                                                  selectedVariant.quantity!
                                              ? true
                                              : cartQ
                                                  ? true
                                                  : false
                                          : negativeStock
                                              ? false
                                              : salesTypeData!.type == 'SALES-O' ||
                                                      salesTypeData!.type ==
                                                          'SALES-Q'
                                                  ? isStockProductOnlyInSalesQO
                                                      ? ((quantity * unitValue) +
                                                                  double.tryParse(
                                                                      value)!) >
                                                              selectedVariant.quantity!
                                                          ? true
                                                          : cartQ
                                                              ? true
                                                              : false
                                                      : false
                                                  : ((quantity * unitValue) +
                                                              double.tryParse(
                                                                  value)!) >
                                                          selectedVariant.quantity!
                                                      ? true
                                                      : cartQ
                                                          ? true
                                                          : false;
                                      calculate();
                                    });
                                    }
                                    },
                                  ), headTxt: 'Quantity')),
                                    ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Visibility(
                                              visible: enableMULTIUNIT,
                                              child: Expanded(
                                                  child: ContainerFieldWidget(
                                                      widget: Container(
                                                          margin:
                                                              const EdgeInsets.only(
                                                                  bottom: 7),
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  left: 5),
                                                          width:
                                                              MediaQuery.of(context)
                                                                  .size
                                                                  .width,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: grey),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(3)),
                                                          child: FutureBuilder(
                                                            future: api.fetchUnitOf(
                                                                selectedItemId!),
                                                            builder: (BuildContext
                                                                    context,
                                                                AsyncSnapshot
                                                                    snapshot) {
                                                              List<UnitModel>
                                                                  unitListData = [];
                                                              if (snapshot.hasData) {
                                                                // unitListData
                                                                //     .clear();
                                                                for (var i = 0;
                                                                    i <snapshot.data.length;i++) {
                                                                  if (defaultUnitID.toString().isNotEmpty) {
                                                                    if (snapshot.data[i].id == defaultUnitID! -1) {
                                                                      _dropDownUnit =snapshot.data[i].id;
                                                                      _conversion =snapshot.data[i].conversion;
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
                                                              return snapshot.data !=null &&
                                                                      snapshot.data!.length > 0
                                                                  ? DropdownButtonHideUnderline(
                                                                      child: DropdownButton<String>(
                                                                        isExpanded:true,
                                                                      
                                                                        hint: Text(_dropDownUnit > 0
                                                                            ? UnitSettings.getUnitName(_dropDownUnit)
                                                                            : 'Unit',
                                                                            style: const TextStyle(
                                                                              fontFamily: 'poppins',
                                                                              color: black,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w400
                                                                            ),
                                                                            ),
                                                                        items: snapshot.data!.map<DropdownMenuItem<String>>(
                                                                                (item) {
                                                                          return DropdownMenuItem<String>(
                                                                            value: item.id.toString(),
                                                                            child: Text(item.name!,
                                                                                style: const TextStyle(
                                                                                  fontSize: 12,
                                                                                  color: black,
                                                                                  fontFamily: 'poppins')),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:(value) {
                                                                          setState(() {
                                                                            bool cartQ = false;
                                                                            _dropDownUnit =int.tryParse(value!)!;
                                                                            for (var i =0; i < unitListData.length;i++) {
                                                                              UnitModel _unit = unitListData[i];
                                                                              if (_unit.unit == int.tryParse(value)) {
                                                                                double? _rate = _unit.rate == 'MRP'
                                                                                    ? selectedVariant.sellingPrice
                                                                                    : _unit.rate == 'WHOLESALE'
                                                                                        ? selectedVariant.wholeSalePrice
                                                                                        : _unit.rate == 'RETAIL'
                                                                                            ? selectedVariant.retailPrice
                                                                                            : _unit.rate == 'SPRETAIL'
                                                                                                ? selectedVariant.spRetailPrice
                                                                                                : rateTypeItem!.name == 'MRP'
                                                                                                    ? selectedVariant.sellingPrice
                                                                                                    : rateTypeItem!.name == 'RETAIL'
                                                                                                        ? selectedVariant.retailPrice
                                                                                                    : rateTypeItem!.name == 'SPRETAIL'
                                                                                                        ? selectedVariant.spRetailPrice
                                                                                                    : rateTypeItem!.name == 'BRANCH'
                                                                                                        ? selectedVariant.branch
                                                                                                        : rateTypeItem!.name == 'WHOLESALE'
                                                                                                            ? selectedVariant.wholeSalePrice
                                                                                                            : rate;
                                                                                if (_unit.rate!.isNotEmpty) {
                                                                                  rateTypeItem = rateTypeList.firstWhere((element) => element.name == _unit.rate);
                                                                                }
                                                                                rate =_rate!;
                                                                                saleRate = _rate;
                                                                                _rateController.text = saleRate > 0
                                                                                    ? saleRate.toStringAsFixed(2)
                                                                                    : '';
                                                                                _conversion = _unit.conversion!;
                                                                                if (quantity > 0 || freeQty > 0) {
                                                                                  if (totalItem > 0) {
                                                                                    double cartS = 0, cartQt = 0;
                                                                                    for (var element in cartItem) {
                                                                                      if (element.uniqueCode == selectedVariant.productId) {
                                                                                        cartQt += element.quantity! + element.free!;
                                                                                        cartS = element.stock!;
                                                                                      }
                                                                                    }
                                                                                    if (cartS > 0) {
                                                                                      if (cartS < cartQt + quantity + freeQty) {
                                                                                        cartQ = true;
                                                                                      }
                                                                                    }
                                                                                  } else {
                                                                                    cartQ = false;
                                                                                  }
                                                                                  outOfStock = isLockQtyOnlyInSales
                                                                                      ? ((quantity * _conversion) + freeQty) > selectedVariant.quantity!
                                                                                          ? true
                                                                                          : cartQ
                                                                                              ? true
                                                                                              : false
                                                                                      : negativeStock
                                                                                          ? false
                                                                                          : salesTypeData!.type == 'SALES-O' || salesTypeData!.type == 'SALES-Q'
                                                                                              ? isStockProductOnlyInSalesQO
                                                                                                  ? ((quantity * _conversion) + freeQty) > selectedVariant.quantity!
                                                                                                      ? true
                                                                                                      : cartQ
                                                                                                          ? true
                                                                                                          : false
                                                                                                  : false
                                                                                              : ((quantity * _conversion) + freeQty) > selectedVariant.quantity!
                                                                                                  ? true
                                                                                                  : cartQ
                                                                                                      ? true
                                                                                                      : false;
                                                                                }
                                                                                break;
                                                                              }
                                                                            }
                                                                            calculate();
                                                                          });
                                                                        },
                                                                      ),
                                                                    )
                                                                  : DropdownButtonHideUnderline(
                                                                      child: DropdownButton<String>(
                                                                        isExpanded: true,
                                                                        
                                                                        hint: Text(_dropDownUnit > 0
                                                                            ? UnitSettings.getUnitName(_dropDownUnit)
                                                                            : 'Unit',style: const TextStyle(
                                                                              fontFamily: 'poppins',
                                                                              color: black,
                                                                              fontWeight: FontWeight.w400
                                                                            ),),
                                                                        items: unitListSettings.map<DropdownMenuItem<String>>((item) {
                                                                          return DropdownMenuItem<String>(
                                                                            value: item.key.toString(),
                                                                            child:Text(
                                                                              item.value,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                  fontFamily: 'poppins',
                                                                                  color: black),
                                                                            ),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:(value) {
                                                                          setState(() {
                                                                            _dropDownUnit = int.tryParse(value!)!;
                                                                            calculate();
                                                                            // for (var i = 0;
                                                                            //     i < unitListData.length;
                                                                            //     i++) {
                                                                            //   UnitModel
                                                                            //       _unit =
                                                                            //       unitListData[i];
                                                                            //   if (_unit.unit ==
                                                                            //       int.tryParse(value)) {
                                                                            //     _conversion = _unit.conversion!;
                                                                            //     break;
                                                                            //   }
                                                                            // }
                                                                            // calculate(
                                                                            //     selectedVariant);
                                                                          });
                                                                        },
                                                                      ),
                                                                    );
                                                            },
                                                          )),
                                                      headTxt: 'Unit')),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: ContainerFieldWidget(
                                                    widget: TextField(
                                                      controller: _rateController,
                                                      focusNode: _focusNodeRate,
                                                      readOnly: isItemRateEditLocked,
                                                      keyboardType:
                                                          const TextInputType.numberWithOptions(decimal: true),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter(
                                                            RegExp(r'[0-9]'),
                                                            allow: true,
                                                            replacementString:
                                                                '.')
                                                      ],
                                                      decoration: const InputDecoration(
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          5),
                                                          border:
                                                              OutlineInputBorder()),
                                                      onChanged: (value) {
                                                         if (value.isNotEmpty) {
                                        isPrateEdited = true;
                                      }
                                                        if (value.isNotEmpty) {
                                                          if (isMinimumRate) {
                                                            double minRate =
                                                                selectedVariant
                                                                        .minimumRate ??
                                                                    0;
                                                            if (double.tryParse(
                                                                    _rateController
                                                                        .text)! >=
                                                                minRate) {
                                                              setState(() {
                                                                isMinimumRatedLock =
                                                                    false;
                                                                calculateConversion();
                                                              });
                                                            } else {
                                                              setState(() {
                                                                isMinimumRatedLock =
                                                                    true;
                                                              });
                                                            }
                                                          } else {
                                                            setState(() {
                                                              editItem
                                                              ? calculateConversion()
                                                              : calculateConversion();
                                                            });
                                                          }
                                                        }
                                                      },
                                                    ),
                                                    headTxt: 'Rate(Price/Unit)')),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            salesTypeData!.type == 'SALES-ES'
                                            ?const SizedBox()
                                           : Expanded(
                                                child: ContainerFieldWidget(
                                                    widget: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 7),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                3),
                                                      ),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton<
                                                            String>(
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'poppins',
                                                              color: black),
                                                          value:
                                                              selectedTaxOption,
                                                          items: [
                                                            const DropdownMenuItem(
                                                              value: 'With Tax',
                                                              child: Text(
                                                                  'With Tax'),
                                                            ),
                                                            DropdownMenuItem(
                                                              onTap: () {
                                                                salesTypeData!
                                                                              .id ==
                                                                          1 ||
                                                                      salesTypeData!
                                                                              .id ==
                                                                          2 ?
                                                                          selectedTaxOption == 'Without Tax'
                                                                          ? Fluttertoast.showToast(msg: "Can't select")
                                                                          :null
                                                                          :null;
                                                              },
                                                              enabled: salesTypeData!
                                                                              .id ==
                                                                          1 ||
                                                                      salesTypeData!
                                                                              .id ==
                                                                          2
                                                                  ? false
                                                                  : true,
                                                              value:
                                                                  'Without Tax',
                                                              child: const Text(
                                                                  'Without Tax'),
                                                            ),
                                                          ],
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedTaxOption = value!;
                                                              value == 'Without Tax' 
                                                                  ? isTax = false
                                                                  : isTax = true;
                                                              calculateConversion();
                                                            });
                                                          },
                                                          isExpanded: true,
                                                        ),
                                                      ),
                                                    ),
                                                    headTxt: 'Tax')),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                  }
                                  }
                                  else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                    
                                  }
                                  return const Center(child: CircularProgressIndicator());
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        selectedItemId == null
                            ? const SizedBox()
                            : StreamBuilder(
                                stream: selectedItemId != null
                                    ? api.fetchStockVariants(selectedItemId!)
                                    : api.fetchStockVariants(0),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return 
                                    oldBill
                                    ?
                                       Container(
                                    width: MediaQuery.of(context).size.width,
                                    color: white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Column(
                                      children: [
                                        const Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            'Totals & Taxes',
                                            style: TextStyle(
                                                fontFamily: 'poppins',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        const Divider(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Subtotal (Rate x Qty)',
                                              style: TextStyle(
                                                  fontFamily: 'poppins'),
                                            ),
                                            Text(
                                              '\u20B9 ${gross.toStringAsFixed(3)}',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            children: [
                                              const Text(
                                                'Discount',
                                                style: TextStyle(
                                                    fontFamily: 'poppins'),
                                              ),
                                              const Spacer(),
                                              Flexible(
                                                flex: 2,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.orange),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3)),
                                                  height: 35,
                                                  child: TextField(
                                                    controller:
                                                        _discountPercentController,
                                                    focusNode:
                                                        _focusNodeDiscountPer,
                                                    keyboardType:
                                                        const TextInputType
                                                            .numberWithOptions(
                                                            decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter(
                                                          RegExp(r'[0-9]'),
                                                          allow: true,
                                                          replacementString:
                                                              '.')
                                                    ],
                                                    onChanged: (value) {
                                                      setState(() {
                                                        calculateConversion();
                                                      });
                                                    },
                                                    decoration: InputDecoration(
                                                      suffixIcon: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .orange[100],
                                                            border: const Border(
                                                                left: BorderSide(
                                                                    color: Colors
                                                                        .orange)),
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            3),
                                                                topRight: Radius
                                                                    .circular(
                                                                        3))),
                                                        width: 25,
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.percent_sharp,
                                                            color:
                                                                Colors.orange,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 6,
                                                              horizontal: 3),
                                                      border:
                                                          const OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                flex: 2,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3)),
                                                  height: 35,
                                                  child: TextField(
                                                    focusNode:
                                                        _focusNodeDiscount,
                                                    controller:
                                                        _discountController,
                                                    keyboardType:
                                                        const TextInputType
                                                            .numberWithOptions(
                                                            decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter(
                                                          RegExp(r'[0-9]'),
                                                          allow: true,
                                                          replacementString:
                                                              '.')
                                                    ],
                                                    textAlign: TextAlign.right,
                                                    decoration: InputDecoration(
                                                      prefixIcon: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[100],
                                                          border: const Border(
                                                              right: BorderSide(
                                                                  color: grey)),
                                                        ),
                                                        width: 25,
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons
                                                                .currency_rupee_outlined,
                                                            color: Colors.grey,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 6,
                                                              horizontal: 3),
                                                      border:
                                                          const OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none),
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        calculateConversion();
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        salesTypeData!.type == 'SALES-ES'
                                        ?const SizedBox()
                                       : SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(children: [
                                            const Text(
                                              'Tax %      ',
                                              style: TextStyle(
                                                  fontFamily: 'poppins'),
                                            ),
                                            const Spacer(),
                                            Flexible(
                                              flex: 2,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.orange),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3)),
                                                height: 35,
                                                child: TextField(
                                                  controller:
                                                      TextEditingController(
                                                          text:
                                                              taxP.toString()),
                                                  readOnly: true,
                                                  decoration: InputDecoration(
                                                    suffixIcon: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .orange[100],
                                                          border: const Border(
                                                              left: BorderSide(
                                                                  color: Colors
                                                                      .orange)),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          3),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          3))),
                                                      width: 25,
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.percent_sharp,
                                                          color: Colors.orange,
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 6,
                                                            horizontal: 3),
                                                    border:
                                                        const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide
                                                                    .none),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              flex: 2,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border:
                                                        Border.all(color: grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3)),
                                                height: 35,
                                                child: TextField(
                                                  controller:
                                                      TextEditingController(
                                                          text: tax
                                                              .toStringAsFixed(
                                                                  3)),
                                                  textAlign: TextAlign.right,
                                                  readOnly: true,
                                                  decoration: InputDecoration(
                                                    prefixIcon: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[100],
                                                        border: const Border(
                                                            right: BorderSide(
                                                                color: grey)),
                                                      ),
                                                      width: 20,
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons
                                                              .currency_rupee_outlined,
                                                          color: Colors.grey,
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 6,
                                                            horizontal: 3),
                                                    border:
                                                        const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide
                                                                    .none),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Row(
                                              children: [
                                                const Text(
                                                  'Total Amount',
                                                  style: TextStyle(
                                                      fontFamily: 'poppins',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                const Spacer(),
                                                Container(
                                                    decoration:
                                                        const BoxDecoration(),
                                                    child: Text(
                                                      "\u20B9  ${total.toStringAsFixed(3)}",
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ))
                                              ],
                                            ))
                                      ],
                                    ),
                                  )
                                    :Center(child: const Text('stock not availble'));
                                  }
                                  final fetchedData = snapshot.data!;
                                  selectedVariant = fetchedData.firstWhere(
                                    (element) =>
                                        element.itemId == selectedItemId,
                                    orElse: () => StockProduct.empty(),
                                  );
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    color: white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Column(
                                      children: [
                                        const Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            'Totals & Taxes',
                                            style: TextStyle(
                                                fontFamily: 'poppins',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        const Divider(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Subtotal (Rate x Qty)',
                                              style: TextStyle(
                                                  fontFamily: 'poppins'),
                                            ),
                                            Text(
                                              '\u20B9 ${gross.toStringAsFixed(3)}',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            children: [
                                              const Text(
                                                'Discount',
                                                style: TextStyle(
                                                    fontFamily: 'poppins'),
                                              ),
                                              const Spacer(),
                                              Flexible(
                                                flex: 2,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.orange),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3)),
                                                  height: 35,
                                                  child: TextField(
                                                    controller:
                                                        _discountPercentController,
                                                    focusNode:
                                                        _focusNodeDiscountPer,
                                                    keyboardType:
                                                        const TextInputType
                                                            .numberWithOptions(
                                                            decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter(
                                                          RegExp(r'[0-9]'),
                                                          allow: true,
                                                          replacementString:
                                                              '.')
                                                    ],
                                                    onChanged: (value) {
                                                      setState(() {
                                                        calculateConversion();
                                                      });
                                                    },
                                                    decoration: InputDecoration(
                                                      suffixIcon: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .orange[100],
                                                            border: const Border(
                                                                left: BorderSide(
                                                                    color: Colors
                                                                        .orange)),
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            3),
                                                                topRight: Radius
                                                                    .circular(
                                                                        3))),
                                                        width: 25,
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.percent_sharp,
                                                            color:
                                                                Colors.orange,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 6,
                                                              horizontal: 3),
                                                      border:
                                                          const OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                flex: 2,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3)),
                                                  height: 35,
                                                  child: TextField(
                                                    focusNode:
                                                        _focusNodeDiscount,
                                                    controller:
                                                        _discountController,
                                                    keyboardType:
                                                        const TextInputType
                                                            .numberWithOptions(
                                                            decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter(
                                                          RegExp(r'[0-9]'),
                                                          allow: true,
                                                          replacementString:
                                                              '.')
                                                    ],
                                                    textAlign: TextAlign.right,
                                                    decoration: InputDecoration(
                                                      prefixIcon: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[100],
                                                          border: const Border(
                                                              right: BorderSide(
                                                                  color: grey)),
                                                        ),
                                                        width: 25,
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons
                                                                .currency_rupee_outlined,
                                                            color: Colors.grey,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 6,
                                                              horizontal: 3),
                                                      border:
                                                          const OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide
                                                                      .none),
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        calculateConversion();
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        salesTypeData!.type == 'SALES-ES'
                                        ?const SizedBox()
                                       : SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(children: [
                                            const Text(
                                              'Tax %      ',
                                              style: TextStyle(
                                                  fontFamily: 'poppins'),
                                            ),
                                            const Spacer(),
                                            Flexible(
                                              flex: 2,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.orange),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3)),
                                                height: 35,
                                                child: TextField(
                                                  controller:
                                                      TextEditingController(
                                                          text:
                                                              taxP.toString()),
                                                  readOnly: true,
                                                  decoration: InputDecoration(
                                                    suffixIcon: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .orange[100],
                                                          border: const Border(
                                                              left: BorderSide(
                                                                  color: Colors
                                                                      .orange)),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          3),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          3))),
                                                      width: 25,
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.percent_sharp,
                                                          color: Colors.orange,
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 6,
                                                            horizontal: 3),
                                                    border:
                                                        const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide
                                                                    .none),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              flex: 2,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border:
                                                        Border.all(color: grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3)),
                                                height: 35,
                                                child: TextField(
                                                  controller:
                                                      TextEditingController(
                                                          text: tax
                                                              .toStringAsFixed(
                                                                  3)),
                                                  textAlign: TextAlign.right,
                                                  readOnly: true,
                                                  decoration: InputDecoration(
                                                    prefixIcon: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[100],
                                                        border: const Border(
                                                            right: BorderSide(
                                                                color: grey)),
                                                      ),
                                                      width: 20,
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons
                                                              .currency_rupee_outlined,
                                                          color: Colors.grey,
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 6,
                                                            horizontal: 3),
                                                    border:
                                                        const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide
                                                                    .none),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Row(
                                              children: [
                                                const Text(
                                                  'Total Amount',
                                                  style: TextStyle(
                                                      fontFamily: 'poppins',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                const Spacer(),
                                                Container(
                                                    decoration:
                                                        const BoxDecoration(),
                                                    child: Text(
                                                      "\u20B9  ${total.toStringAsFixed(3)}",
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ))
                                              ],
                                            ))
                                      ],
                                    ),
                                  );
                                },
                              )
                      ],
                    ),
                  ),
             
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const Center(child: CircularProgressIndicator());
              // } else
          //      if (snapshot.hasError) {
          //   return AlertDialog(
          //     title: const Text(
          //       'An Error Occurred!',
          //       textAlign: TextAlign.center,
          //       style: TextStyle(
          //         color: Colors.redAccent,
          //       ),
          //     ),
          //     content: Text(
          //       "${snapshot.error}",
          //       style: const TextStyle(
          //         color: Colors.blueAccent,
          //       ),
          //     ),
          //     actions: <Widget>[
          //       TextButton(
          //         child: const Text(
          //           'Go Back',
          //           style: TextStyle(
          //             color: Colors.redAccent,
          //           ),
          //         ),
          //         onPressed: () {
          //           Navigator.of(context).pop();
          //         },
          //       )
          //     ],
          //   );
          // } 
          // else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //       return const Center(child: Text('No items found'));
          //     } 
          //     return const Center(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       CircularProgressIndicator(),
          //       SizedBox(height: 20),
          //       Text('This may take some time..')
          //     ],
          //   ),
          // );
              
          //   },
          // ),
                 
              //   },
              //   error: (error, stackTrace) => Center(
              //     child: Text(error.toString()),
              //   ),
              //   loading: () => const Center(
              //     child: CircularProgressIndicator(),
              //   ),
              // ),
         
          bottomNavigationBar: Container(
            width: MediaQuery.of(context).size.width,
            // decoration: const BoxDecoration(
            //   boxShadow: [
            //     BoxShadow(color: grey, blurRadius: .8, spreadRadius: 100),
            //   ],
            // ),
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.grey,
                      onTap: () {
                        editItem
                            ? setState(() {
                                clearValue();
                                removeProduct(position!);
                                calculateTotal();
                                nextWidget = 0;
                              })
                            : setState(() {
                                List<UnitModel> unitListData = [];
                                print(selectedVariant.name);
                                calculateText(selectedVariant);
                    
                                isVariantSelected = false;
                                if (quantity > 0 || isFreeItem) {
                                  if (outOfStock) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: const Text(
                                          'Sorry stock not available.'),
                                      duration: const Duration(seconds: 3),
                                      action: SnackBarAction(
                                        label: 'Click',
                                        onPressed: () {
                                          // print('Action is clicked');
                                        },
                                        textColor: Colors.white,
                                        disabledTextColor: Colors.grey,
                                      ),
                                      backgroundColor: Colors.red,
                                    ));
                                  } else {
                                    if (isMinimumRatedLock) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: const Text(
                                            'Sorry rate is limited.'),
                                        duration:
                                            const Duration(seconds: 1),
                                        action: SnackBarAction(
                                          label: 'Click',
                                          onPressed: () {
                                            // print('Action is clicked');
                                          },
                                          textColor: Colors.white,
                                          disabledTextColor: Colors.grey,
                                        ),
                                        backgroundColor: Colors.red,
                                      ));
                                    } else {
                                      bool profitable = true;
                                      // if (_autoVariantSelect) {
                                      //   double qty = 0;
                                      //   for (StockProduct product
                                      //       in _autoStockVariant) {
                                      //     if (qty == quantity) {
                                      //       break;
                                      //     }
                                      //     qty += product.quantity;
                                      //     addProduct(CartItem(
                                      //         id: totalItem + 1,
                                      //         itemId: product.itemId,
                                      //         itemName: product.name,
                                      //         quantity: product.quantity,
                                      //         rate: rate,
                                      //         rRate: rRate,
                                      //         uniqueCode: product.productId,
                                      //         gross: gross,
                                      //         discount: discount,
                                      //         discountPercent: discountPercent,
                                      //         rDiscount: rDisc,
                                      //         fCess: kfc,
                                      //         serialNo: '',
                                      //         tax: tax,
                                      //         taxP: taxP,
                                      //         unitId: _dropDownUnit,
                                      //         unitValue: unitValue,
                                      //         pRate: pRate,
                                      //         rPRate: rPRate,
                                      //         barcode: barcode,
                                      //         expDate: expDate,
                                      //         free: free,
                                      //         fUnitId: fUnitId,
                                      //         cdPer: cdPer,
                                      //         cDisc: cDisc,
                                      //         net: subTotal,
                                      //         cess: cess,
                                      //         total: total,
                                      //         profitPer: profitPer,
                                      //         fUnitValue: fUnitValue,
                                      //         adCess: adCess,
                                      //         iGST: iGST,
                                      //         cGST: csGST,
                                      //         sGST: csGST,
                                      //         stock: product.quantity));
                                      //   }
                                      // } else {
                                      if (isEnableProfitlessSalesWarning) {
                                        if (profitPer > 0) {
                                          profitable = true;
                                        } else {
                                          profitable = false;
                                        }
                                      }
                                      if (profitable) {
                                        bool isUnit = true;
                                        if (enableMULTIUNIT) {
                                          if (_dropDownUnit <= 0) {
                                            int? united = unitListData !=
                                                    null
                                                ? unitListData.isNotEmpty
                                                    ? unitListData[0].sUnit
                                                    : unitData.isNotEmpty
                                                        ? unitData
                                                            .firstWhere(
                                                                (element) =>
                                                                    element
                                                                        .name ==
                                                                    'NOS')
                                                            .id
                                                        : 0
                                                : 0;
                                            _dropDownUnit = united!;
                                            double? unitedValue = unitListData !=
                                                    null
                                                ? unitListData.isNotEmpty
                                                    ? unitListData[0]
                                                        .conversion
                                                    : unitData.isNotEmpty
                                                        ? unitData
                                                            .firstWhere(
                                                                (element) =>
                                                                    element
                                                                        .name ==
                                                                    'NOS')
                                                            .conversion
                                                        : 1
                                                : 0;
                                            _conversion = unitedValue!;
                                          }
                                          isUnit = _dropDownUnit > 0
                                              ? true
                                              : false;
                                          if (unitData.isEmpty && !isUnit) {
                                            unitValue = 1;
                                            _conversion = 0;
                                            isUnit = true;
                                          }
                                        } else {
                                          _conversion = 0;
                                          unitValue = 1;
                                        }
                                        if (isUnit) {
                                          // if (editItem) {
                                          //   cartItem[position!].adCess = adCess;
                                          //   cartItem[position!].quantity =
                                          //       quantity;
                                          //   cartItem[position!].rate = rate;
                                          //   cartItem[position!].rRate = rRate;
                                          //   cartItem[position!].uniqueCode =
                                          //       uniqueCode;
                                          //   cartItem[position!].gross = gross;
                                          //   cartItem[position!].discount =
                                          //       discount;
                                          //   cartItem[position!].discountPercent =
                                          //       discountPercent;
                                          //   cartItem[position!].rDiscount = rDisc;
                                          //   cartItem[position!].fCess = kfc;
                                          //   cartItem[position!].serialNo =
                                          //       _serialNoController.text;
                                          //   cartItem[position!].tax = tax;
                                          //   cartItem[position!].taxP = taxP;
                                          //   cartItem[position!].unitId =
                                          //       _dropDownUnit;
                                          //   cartItem[position!].unitValue =
                                          //       unitValue ?? 1;
                                          //   cartItem[position!].pRate = pRate;
                                          //   cartItem[position!].rPRate = rPRate;
                                          //   cartItem[position!].barcode = barcode;
                                          //   cartItem[position!].expDate = expDate;
                                          //   cartItem[position!].free = freeQty;
                                          //   cartItem[position!].fUnitId = fUnitId;
                                          //   cartItem[position!].cdPer = cdPer;
                                          //   cartItem[position!].cDisc = cDisc;
                                          //   cartItem[position!].net = subTotal;
                                          //   cartItem[position!].cess = cess;
                                          //   cartItem[position!].total = total;
                                          //   cartItem[position!].profitPer =
                                          //       profitPer;
                                          //   cartItem[position!].fUnitValue =
                                          //       fUnitValue;
                                          //   cartItem[position!].adCess = adCess;
                                          //   cartItem[position!].iGST = iGST;
                                          //   cartItem[position!].cGST = csGST;
                                          //   cartItem[position!].sGST = csGST;
                                          //   cartItem[position!].stock =
                                          //       selectedVariant.quantity;
                                          //   editItem = false;
                                          // }
                                          // if {
                                          if(quantity <=0){
                                            Fluttertoast.showToast(msg: '0 Quantity Not Allowed');
                                          }
                                          else{
                                          addProduct(
                                              CartItem(
                                                  id: totalItem + 1,
                                                  itemId: selectedVariant
                                                      .itemId!,
                                                  itemName:
                                                      selectedVariant.name!,
                                                  quantity: quantity,
                                                  rate: rate,
                                                  rRate: rRate,
                                                  uniqueCode: uniqueCode,
                                                  gross: gross,
                                                  discount: discount,
                                                  discountPercent:
                                                      discountPercent,
                                                  rDiscount: rDisc,
                                                  fCess: kfc,
                                                  serialNo:
                                                      _serialNoController
                                                          .text,
                                                  tax: tax,
                                                  taxP: taxP,
                                                  unitId: _dropDownUnit,
                                                  unitValue: unitValue ?? 1,
                                                  pRate: pRate,
                                                  rPRate: rPRate,
                                                  barcode: barcode,
                                                  expDate: expDate,
                                                  free: freeQty,
                                                  fUnitId: fUnitId,
                                                  cdPer: cdPer,
                                                  cDisc: cDisc,
                                                  net: subTotal,
                                                  cess: cess,
                                                  total: total,
                                                  profitPer: profitPer,
                                                  fUnitValue: fUnitValue,
                                                  adCess: adCess,
                                                  iGST: iGST,
                                                  cGST: csGST,
                                                  sGST: csGST,
                                                  stock: selectedVariant
                                                      .quantity!,
                                                  minimumRate:
                                                      selectedVariant
                                                          .minimumRate!,
                                                          adCessPer: adCessPer,
                                                          cessPer: cessPer
                                                          ),
                                              -1);
                                          }
                                          // }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: const Text(
                                                'Please select Unit'),
                                            duration:
                                                const Duration(seconds: 1),
                                            action: SnackBarAction(
                                              label: 'Click',
                                              onPressed: () {
                                                // print('Action is clicked');
                                              },
                                              textColor: Colors.white,
                                              disabledTextColor:
                                                  Colors.grey,
                                            ),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: const Text(
                                              'Sorry Non Profitable Rate.'),
                                          duration:
                                              const Duration(seconds: 1),
                                          action: SnackBarAction(
                                            label: 'Click',
                                            onPressed: () {
                                              // print('Action is clicked');
                                            },
                                            textColor: Colors.white,
                                            disabledTextColor: Colors.grey,
                                          ),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                      // }
                                    }
                                  }
                                }
                                if (quantity > 0) {
                                  clearValue();
                                  // nextWidget = 0;
                                }
                              });
                      },
                      child: Container(
                        height: 60,
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            editItem ? 'Delete' : 'Save & New',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.white,
                      onTap: () {
                        !editItem ? setState(() {
                        print(selectedVariant.name);
                        calculateText(selectedVariant);
                        setState(() {
                          isVariantSelected = false;
                          if (quantity > 0 || isFreeItem) {
                            if (outOfStock) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: const Text(
                                    'Sorry stock not available.'),
                                duration: const Duration(seconds: 3),
                                action: SnackBarAction(
                                  label: 'Click',
                                  onPressed: () {
                                    // print('Action is clicked');
                                  },
                                  textColor: Colors.white,
                                  disabledTextColor: Colors.grey,
                                ),
                                backgroundColor: Colors.red,
                              ));
                            } else {
                              if (isMinimumRatedLock) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content:
                                      const Text('Sorry rate is limited.'),
                                  duration: const Duration(seconds: 1),
                                  action: SnackBarAction(
                                    label: 'Click',
                                    onPressed: () {
                                      // print('Action is clicked');
                                    },
                                    textColor: Colors.white,
                                    disabledTextColor: Colors.grey,
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                              } else {
                                bool profitable = true;
                                // if (_autoVariantSelect) {
                                //   double qty = 0;
                                //   for (StockProduct product
                                //       in _autoStockVariant) {
                                //     if (qty == quantity) {
                                //       break;
                                //     }
                                //     qty += product.quantity;
                                //     addProduct(CartItem(
                                //         id: totalItem + 1,
                                //         itemId: product.itemId,
                                //         itemName: product.name,
                                //         quantity: product.quantity,
                                //         rate: rate,
                                //         rRate: rRate,
                                //         uniqueCode: product.productId,
                                //         gross: gross,
                                //         discount: discount,
                                //         discountPercent: discountPercent,
                                //         rDiscount: rDisc,
                                //         fCess: kfc,
                                //         serialNo: '',
                                //         tax: tax,
                                //         taxP: taxP,
                                //         unitId: _dropDownUnit,
                                //         unitValue: unitValue,
                                //         pRate: pRate,
                                //         rPRate: rPRate,
                                //         barcode: barcode,
                                //         expDate: expDate,
                                //         free: free,
                                //         fUnitId: fUnitId,
                                //         cdPer: cdPer,
                                //         cDisc: cDisc,
                                //         net: subTotal,
                                //         cess: cess,
                                //         total: total,
                                //         profitPer: profitPer,
                                //         fUnitValue: fUnitValue,
                                //         adCess: adCess,
                                //         iGST: iGST,
                                //         cGST: csGST,
                                //         sGST: csGST,
                                //         stock: product.quantity));
                                //   }
                                // } else {
                                if (isEnableProfitlessSalesWarning) {
                                  if (profitPer > 0) {
                                    profitable = true;
                                  } else {
                                    profitable = false;
                                  }
                                }
                                if (profitable) {
                                  bool isUnit = true;
                                  if (enableMULTIUNIT) {
                                    if (_dropDownUnit <= 0) {
                                      int? united = unitListData != null
                                          ? unitListData.isNotEmpty
                                              ? unitListData[0].sUnit
                                              : unitData.isNotEmpty
                                                  ? unitData
                                                      .firstWhere(
                                                          (element) =>
                                                              element
                                                                  .name ==
                                                              'NOS')
                                                      .id
                                                  : 0
                                          : 0;
                                      _dropDownUnit = united!;
                                      double? unitedValue = unitListData !=
                                              null
                                          ? unitListData.isNotEmpty
                                              ? unitListData[0].conversion
                                              : unitData.isNotEmpty
                                                  ? unitData
                                                      .firstWhere(
                                                          (element) =>
                                                              element
                                                                  .name ==
                                                              'NOS')
                                                      .conversion
                                                  : 1
                                          : 0;
                                      _conversion = unitedValue!;
                                    }
                                    isUnit =_dropDownUnit > 0 ? true : false;
                                    if (unitData.isEmpty && !isUnit) {
                                      unitValue = 1;
                                      _conversion = 0;
                                      isUnit = true;
                                    }
                                  } else {
                                    _conversion = 0;
                                    unitValue = 1;
                                  }
                                  if (isUnit) {
                                    if (editItem) {
                                      // unitValue = cartModel!.unitValue!;
                                      cartItem[position!].adCess = adCess;
                                      cartItem[position!].quantity =
                                          quantity;
                                      cartItem[position!].rate = rate;
                                      cartItem[position!].rRate = rRate;
                                      cartItem[position!].uniqueCode =
                                          uniqueCode;
                                      cartItem[position!].gross = gross;
                                      cartItem[position!].discount =
                                          discount;
                                      cartItem[position!].discountPercent =
                                          discountPercent;
                                      cartItem[position!].rDiscount = rDisc;
                                      cartItem[position!].fCess = kfc;
                                      cartItem[position!].serialNo =
                                          _serialNoController.text;
                                      cartItem[position!].tax = tax;
                                      cartItem[position!].taxP = taxP;
                                      cartItem[position!].unitId =
                                          _dropDownUnit;
                                      cartItem[position!].unitValue =
                                          unitValue ?? 1;
                                      cartItem[position!].pRate = pRate;
                                      cartItem[position!].rPRate = rPRate;
                                      cartItem[position!].barcode = barcode;
                                      cartItem[position!].expDate = expDate;
                                      cartItem[position!].free = freeQty;
                                      cartItem[position!].fUnitId = fUnitId;
                                      cartItem[position!].cdPer = cdPer;
                                      cartItem[position!].cDisc = cDisc;
                                      cartItem[position!].net = subTotal;
                                      cartItem[position!].cess = cess;
                                      cartItem[position!].total = total;
                                      cartItem[position!].profitPer =
                                          profitPer;
                                      cartItem[position!].fUnitValue =
                                          fUnitValue;
                                      cartItem[position!].adCess = adCess;
                                      cartItem[position!].iGST = iGST;
                                      cartItem[position!].cGST = csGST;
                                      cartItem[position!].sGST = csGST;
                                      cartItem[position!].stock =
                                          selectedVariant.quantity!;
                                      editItem = false;
                                      calculateTotal();
                                    }
                                     else {
                                      if (!keyItemsVariantStock &&
                                              _autoVariantSelect) {
                                            double qty = 0,
                                                tQty = 0,
                                                balanceQty = 0;
                                            for (StockProduct variantProduct
                                                in stockVariantProductList) {
                                              qty = ((variantProduct.quantity)! >
                                                      quantity
                                                  ? quantity
                                                  : variantProduct.quantity)!;
                                              uniqueCode =
                                                  variantProduct.productId!;
                                              double addQuantity =
                                                  balanceQty > 0
                                                      ? (balanceQty == qty
                                                          ? qty
                                                          : (balanceQty >= qty
                                                              ? qty
                                                              : balanceQty))
                                                      : qty;

                                              calculateTextBatch(
                                                  selectedVariant, addQuantity);
                                              cartItem.add(CartItem(
                                                  id: totalItem + 1,
                                                  itemId: selectedVariant.itemId!,
                                                  itemName: selectedVariant.name!,
                                                  quantity: addQuantity,
                                                  rate: rate,
                                                  rRate: rRate,
                                                  uniqueCode: uniqueCode,
                                                  gross: gross,
                                                  discount: discount,
                                                  discountPercent:
                                                      discountPercent,
                                                  rDiscount: rDisc,
                                                  fCess: kfc,
                                                  serialNo:
                                                      _serialNoController.text,
                                                  tax: tax,
                                                  taxP: taxP,
                                                  unitId: _dropDownUnit,
                                                  unitValue: unitValue ?? 1,
                                                  pRate: pRate,
                                                  rPRate: rPRate,
                                                  barcode: barcode,
                                                  expDate: expDate,
                                                  free: freeQty,
                                                  fUnitId: fUnitId,
                                                  cdPer: cdPer,
                                                  cDisc: cDisc,
                                                  net: subTotal,
                                                  cess: cess,
                                                  total: total,
                                                  profitPer: profitPer,
                                                  fUnitValue: fUnitValue,
                                                  adCess: adCess,
                                                  iGST: iGST,
                                                  cGST: csGST,
                                                  sGST: csGST,
                                                  stock: variantProduct.quantity!,
                                                  minimumRate:
                                                      selectedVariant.minimumRate!,
                                                  adCessPer: adCessPer,
                                                  cessPer: cessPer
                                                  ));

                                              tQty += addQuantity;
                                              balanceQty = quantity - tQty;
                                              if (tQty >= quantity ||
                                                  balanceQty == 0) {
                                                break;
                                              } else {
                                                //
                                              }
                                            }
                                          } else {
                                            if(quantity <=0){
                                              Fluttertoast.showToast(msg: '0 Quantity Not Allowed');
                                            }
                                            else{
                                      addProduct(
                                          CartItem(
                                              id: totalItem + 1,
                                              itemId:
                                                  selectedVariant.itemId!,
                                              itemName:
                                                  selectedVariant.name!,
                                              quantity: quantity,
                                              rate: rate,
                                              rRate: rRate,
                                              uniqueCode: uniqueCode,
                                              gross: gross,
                                              discount: discount,
                                              discountPercent:
                                                  discountPercent,
                                              rDiscount: rDisc,
                                              fCess: kfc,
                                              serialNo:
                                                  _serialNoController.text,
                                              tax: tax,
                                              taxP: taxP,
                                              unitId: _dropDownUnit,
                                              unitValue: unitValue ?? 1,
                                              pRate: pRate,
                                              rPRate: rPRate,
                                              barcode: barcode,
                                              expDate: expDate,
                                              free: freeQty,
                                              fUnitId: fUnitId,
                                              cdPer: cdPer,
                                              cDisc: cDisc,
                                              net: subTotal,
                                              cess: cess,
                                              total: total,
                                              profitPer: profitPer,
                                              fUnitValue: fUnitValue,
                                              adCess: adCess,
                                              iGST: iGST,
                                              cGST: csGST,
                                              sGST: csGST,
                                              stock:
                                                  selectedVariant.quantity!,
                                              minimumRate: selectedVariant
                                                  .minimumRate!,
                                                  adCessPer: adCessPer,
                                                  cessPer: cessPer
                                                  ),
                                          -1);
                                            }
                                          }
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content:
                                          const Text('Please select Unit'),
                                      duration: const Duration(seconds: 1),
                                      action: SnackBarAction(
                                        label: 'Click',
                                        onPressed: () {
                                          // print('Action is clicked');
                                        },
                                        textColor: Colors.white,
                                        disabledTextColor: Colors.grey,
                                      ),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text(
                                        'Sorry Non Profitable Rate.'),
                                    duration: const Duration(seconds: 1),
                                    action: SnackBarAction(
                                      label: 'Click',
                                      onPressed: () {
                                        // print('Action is clicked');
                                      },
                                      textColor: Colors.white,
                                      disabledTextColor: Colors.grey,
                                    ),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                                // }
                              }
                            }
                          }
                          if (quantity > 0) {
                            
                            clearValue();
                            calculateTotal();
                            nextWidget = 0;
                          }
                        });
                        },):
                       setState(() {
                          List<UnitModel> unitListData = [];
                        print(selectedVariant.name);
                        calculateText(selectedVariant);
                        setState(() {
                          
                          isVariantSelected = false;
                          if (quantity > 0 || isFreeItem) {
                            if (outOfStock) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: const Text(
                                    'Sorry stock not available.'),
                                duration: const Duration(seconds: 3),
                                action: SnackBarAction(
                                  label: 'Click',
                                  onPressed: () {
                                    // print('Action is clicked');
                                  },
                                  textColor: Colors.white,
                                  disabledTextColor: Colors.grey,
                                ),
                                backgroundColor: Colors.red,
                              ));
                            } else {
                              if (isMinimumRatedLock) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content:
                                      const Text('Sorry rate is limited.'),
                                  duration: const Duration(seconds: 1),
                                  action: SnackBarAction(
                                    label: 'Click',
                                    onPressed: () {
                                      // print('Action is clicked');
                                    },
                                    textColor: Colors.white,
                                    disabledTextColor: Colors.grey,
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                              } else {
                                bool profitable = true;
                                // if (_autoVariantSelect) {
                                //   double qty = 0;
                                //   for (StockProduct product
                                //       in _autoStockVariant) {
                                //     if (qty == quantity) {
                                //       break;
                                //     }
                                //     qty += product.quantity;
                                //     addProduct(CartItem(
                                //         id: totalItem + 1,
                                //         itemId: product.itemId,
                                //         itemName: product.name,
                                //         quantity: product.quantity,
                                //         rate: rate,
                                //         rRate: rRate,
                                //         uniqueCode: product.productId,
                                //         gross: gross,
                                //         discount: discount,
                                //         discountPercent: discountPercent,
                                //         rDiscount: rDisc,
                                //         fCess: kfc,
                                //         serialNo: '',
                                //         tax: tax,
                                //         taxP: taxP,
                                //         unitId: _dropDownUnit,
                                //         unitValue: unitValue,
                                //         pRate: pRate,
                                //         rPRate: rPRate,
                                //         barcode: barcode,
                                //         expDate: expDate,
                                //         free: free,
                                //         fUnitId: fUnitId,
                                //         cdPer: cdPer,
                                //         cDisc: cDisc,
                                //         net: subTotal,
                                //         cess: cess,
                                //         total: total,
                                //         profitPer: profitPer,
                                //         fUnitValue: fUnitValue,
                                //         adCess: adCess,
                                //         iGST: iGST,
                                //         cGST: csGST,
                                //         sGST: csGST,
                                //         stock: product.quantity));
                                //   }
                                // } else {
                                if (isEnableProfitlessSalesWarning) {
                                  if (profitPer > 0) {
                                    profitable = true;
                                  } else {
                                    profitable = false;
                                  }
                                }
                                if (profitable) {
                                  bool isUnit = true;
                                  if (enableMULTIUNIT) {
                                    if (_dropDownUnit <= 0) {
                                      int? united = unitListData != null
                                          ? unitListData.isNotEmpty
                                              ? unitListData[0].sUnit
                                              : unitData.isNotEmpty
                                                  ? unitData
                                                      .firstWhere(
                                                          (element) =>
                                                              element
                                                                  .name ==
                                                              'NOS')
                                                      .id
                                                  : 0
                                          : 0;
                                      _dropDownUnit = united!;
                                      double? unitedValue = unitListData !=
                                              null
                                          ? unitListData.isNotEmpty
                                              ? unitListData[0].conversion
                                              : unitData.isNotEmpty
                                                  ? unitData
                                                      .firstWhere(
                                                          (element) =>
                                                              element
                                                                  .name ==
                                                              'NOS')
                                                      .conversion
                                                  : 1
                                          : 0;
                                      _conversion = unitedValue!;
                                    }
                                    isUnit =
                                        _dropDownUnit > 0 ? true : false;
                                    if (unitData.isEmpty && !isUnit) {
                                      unitValue = 1;
                                      _conversion = 0;
                                      isUnit = true;
                                    }
                                  } else {
                                    _conversion = 0;
                                    unitValue = 1;
                                  }
                                  if (isUnit) {
                                    if (editItem) {
                                      cartItem[position!].adCess = adCess;
                                      cartItem[position!].quantity =
                                          quantity;
                                      cartItem[position!].rate = rate;
                                      cartItem[position!].rRate = rRate;
                                      cartItem[position!].uniqueCode =
                                          uniqueCode;
                                      cartItem[position!].gross = gross;
                                      cartItem[position!].discount =
                                          discount;
                                      cartItem[position!].discountPercent =
                                          discountPercent;
                                      cartItem[position!].rDiscount = rDisc;
                                      cartItem[position!].fCess = kfc;
                                      cartItem[position!].serialNo =
                                          _serialNoController.text;
                                      cartItem[position!].tax = tax;
                                      cartItem[position!].taxP = taxP;
                                      cartItem[position!].unitId =
                                          _dropDownUnit;
                                      cartItem[position!].unitValue =
                                          unitValue ?? 1;
                                      cartItem[position!].pRate = pRate;
                                      cartItem[position!].rPRate = rPRate;
                                      cartItem[position!].barcode = barcode;
                                      cartItem[position!].expDate = expDate;
                                      cartItem[position!].free = freeQty;
                                      cartItem[position!].fUnitId = fUnitId;
                                      cartItem[position!].cdPer = cdPer;
                                      cartItem[position!].cDisc = cDisc;
                                      cartItem[position!].net = subTotal;
                                      cartItem[position!].cess = cess;
                                      cartItem[position!].total = total;
                                      cartItem[position!].profitPer =
                                          profitPer;
                                      cartItem[position!].fUnitValue =
                                          fUnitValue;
                                      cartItem[position!].adCess = adCess;
                                      cartItem[position!].iGST = iGST;
                                      cartItem[position!].cGST = csGST;
                                      cartItem[position!].sGST = csGST;
                                      cartItem[position!].stock =
                                          selectedVariant.quantity!;
                                      editItem = false;
                                      calculateTotal();
                                    } 
                                    else {
                                      if (quantity <= 0) {
                                        Fluttertoast.showToast(msg: '0 Quantity Not Allowed');
                                      }
                                      else{
                                      addProduct(
                                          CartItem(
                                              id: totalItem + 1,
                                              itemId:
                                                  selectedVariant.itemId!,
                                              itemName:
                                                  selectedVariant.name!,
                                              quantity: quantity,
                                              rate: rate,
                                              rRate: rRate,
                                              uniqueCode: uniqueCode,
                                              gross: gross,
                                              discount: discount,
                                              discountPercent:
                                                  discountPercent,
                                              rDiscount: rDisc,
                                              fCess: kfc,
                                              serialNo:
                                                  _serialNoController.text,
                                              tax: tax,
                                              taxP: taxP,
                                              unitId: _dropDownUnit,
                                              unitValue: unitValue ?? 1,
                                              pRate: pRate,
                                              rPRate: rPRate,
                                              barcode: barcode,
                                              expDate: expDate,
                                              free: freeQty,
                                              fUnitId: fUnitId,
                                              cdPer: cdPer,
                                              cDisc: cDisc,
                                              net: subTotal,
                                              cess: cess,
                                              total: total,
                                              profitPer: profitPer,
                                              fUnitValue: fUnitValue,
                                              adCess: adCess,
                                              iGST: iGST,
                                              cGST: csGST,
                                              sGST: csGST,
                                              stock:
                                                  selectedVariant.quantity!,
                                              minimumRate: selectedVariant
                                                  .minimumRate!,
                                                  adCessPer: adCessPer,
                                                  cessPer: cessPer
                                                  ),
                                          -1);
                                      }
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content:
                                          const Text('Please select Unit'),
                                      duration: const Duration(seconds: 1),
                                      action: SnackBarAction(
                                        label: 'Click',
                                        onPressed: () {
                                          // print('Action is clicked');
                                        },
                                        textColor: Colors.white,
                                        disabledTextColor: Colors.grey,
                                      ),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text(
                                        'Sorry Non Profitable Rate.'),
                                    duration: const Duration(seconds: 1),
                                    action: SnackBarAction(
                                      label: 'Click',
                                      onPressed: () {
                                        // print('Action is clicked');
                                      },
                                      textColor: Colors.white,
                                      disabledTextColor: Colors.grey,
                                    ),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                                // }
                              }
                            }
                          }
                          if (quantity > 0) {
                            debugPrint("unit ==== ${unitValue.toString()}");
                            clearValue();
                            nextWidget = 0;
                          }
                        });
                       },);
                      },
                      child: Container(
                        height: 60,
                        color: kPrimaryColor,
                        child:  Center(
                          child: Text(
                            editItem?'Edit': 'Save',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  bool isData = false;

  scannerWidget() {
    return Column(
      children: <Widget>[
        Expanded(flex: 4, child: _buildQrViewLedger(context)),
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                if (result != null)
                  Text(
                      'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                else
                  const Text('Scan a code'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return Text('Flash: ${snapshot.data}');
                            },
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getCameraInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return Text(
                                    'Camera facing ${describeEnum(snapshot.data!)}');
                              } else {
                                return const Text('loading');
                              }
                            },
                          )),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller?.pauseCamera();
                        },
                        child:
                            const Text('pause', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller?.resumeCamera();
                        },
                        child: const Text('resume',
                            style: TextStyle(fontSize: 20)),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  bool customerReusableProduct =
      ComSettings.appSettings('bool', 'key-customer-reusable-product', false)
          ? true
          : false;

  callNumber(number) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(number);
    } catch (e) {
      debugPrint(e as String?);
    }
  }

  OptionRateType? rateTypeItem;

  widgetRateType() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<OptionRateType>(
        hint: const Text('select rate type'),
        style:
            const TextStyle(fontFamily: 'poppins', color: black, fontSize: 15),
        items: rateTypeList.map((item) {
          return DropdownMenuItem<OptionRateType>(
            value: item,
            child: Text(item.name),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            rateTypeItem = value;
          });
        },
        value: rateTypeItem,
      ),
    );
  }

  //declare
  bool outOfStock = false,
      enableMULTIUNIT = false,
      pRateBasedProfitInSales = false,
      negativeStock = false,
      cessOnNetAmount = false,
      negativeStockStatus = false,
      enableKeralaFloodCess = false,
      useUniqueCodeAsBarcode = false,
      useOldBarcode = false,
      isMinimumRatedLock = false;

  bool isItemData = false;
  String itemLike = 'a';
  selectProductWidget() {
    if (salesmanAsVehicle) {
      double squareFeet =
          vehicleData != null ? vehicleData['Salary'].toDouble() : 0;
      if (squareFeet > 0) {
        _quantityController.text = squareFeet.toString();
      }
    }
    if (!itemStockAll) {
      return FutureBuilder<List<StockItem>>(
        future: (salesTypeData!.type == 'SALES-O' ||
                salesTypeData!.type == 'SALES-Q')
            ? isStockProductOnlyInSalesQO
                ? api.fetchStockProductLike(
                    DateUtil.dateDMY2YMD(formattedDate), itemLike)
                : api.fetchNoStockProductLike(
                    DateUtil.dateDMY2YMD(formattedDate), itemLike)
            : api.fetchStockProductLike(
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

                                //   itemDisplay = items.where((item) {
                                //     // var itemName = itemCodeVise
                                //     //     ? item.code.toString().toLowerCase() +
                                //     //         ' ' +
                                //     //         item.name.toLowerCase()
                                //     //     : item.name.toLowerCase();
                                //     // return itemName.contains(text);
                                //   }).toList();
                              });
                            },
                            autofocus: true,
                          ),
                        )
                      : InkWell(
                          child: Card(
                            child: ListTile(
                              title: Text(
                                  'Name : ${itemCodeVise ? '${itemDisplay[index - 1].code} ' + itemDisplay[index - 1].name : itemDisplay[index - 1].name}'),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Qty :${itemDisplay[index - 1].quantity}'),
                                  // TextButton(
                                  //     onPressed: () {
                                  // if (singleProduct) {
                                  //   addProduct(CartItem(
                                  // id: totalAdd Item 1,
                                  // itemId: product.itemId,
                                  // itemName: product.name,
                                  // quantity: 1,
                                  // rate: rate,
                                  // rRate: rRate,
                                  // uniqueCode: uniqueCode,
                                  // gross: gross,
                                  // discount: discount,
                                  // discountPercent: discountPercent,
                                  // rDiscount: rDisc,
                                  // fCess: kfc,
                                  // serialNo: '',
                                  // tax: tax,
                                  // taxP: taxP,
                                  // unitId: _dropDownUnit,
                                  // unitValue: unitValue,
                                  // pRate: pRate,
                                  // rPRate: rPRate,
                                  // barcode: barcode,
                                  // expDate: expDate,
                                  // free: free,
                                  // fUnitId: fUnitId,
                                  // cdPer: cdPer,
                                  // cDisc: cDisc,
                                  // net: subTotal,
                                  // cess: cess,
                                  // total: total,
                                  // profitPer: profitPer,
                                  // fUnitValue: fUnitValue,
                                  // adCess: adCess,
                                  // iGST: iGST,
                                  // cGST: csGST,
                                  // sGST: csGST));
                                  // } else {
                                  // Fluttertoast.showToast(
                                  // msg: 'this is not Completed');
                                  // }
                                  // },
                                  // child: const Card(
                                  //     child: Text(' + ',
                                  //         style: TextStyle(
                                  //             fontSize: 25, color: blue))))
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
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          suffixIcon: Visibility(
                            visible: enableBarcode,
                            child: IconButton(
                                onPressed: () {
                                  searchProductBarcode();
                                },
                                icon: const Icon(Icons.document_scanner)),
                          ),
                          border: const OutlineInputBorder(),
                          label: const Text('Search...')),
                      onChanged: (text) {
                        text = text.toLowerCase();
                        setState(() {
                          itemLike = text.toLowerCase();
                        });
                      },
                      autofocus: true,
                    ),
                  ),
                  Card(
                    color: grey.shade300,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('No Product Found'),
                            SizedBox(height: 20),
                            Text('type again')
                          ],
                        ),
                      ),
                    ),
                  )
                ],
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
            ? isStockProductOnlyInSalesQO
                ? api.fetchStockProduct(DateUtil.dateDMY2YMD(formattedDate))
                : api.fetchNoStockProduct(DateUtil.dateDMY2YMD(formattedDate))
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
                                  var itemName = itemCodeVise
                                      ? '${item.code.toString().toLowerCase()} ' +
                                          item.name.toLowerCase()
                                      : item.name.toLowerCase();
                                  return itemName.contains(text);
                                }).toList();
                              });
                            },
                          ),
                        )
                      : InkWell(
                          child: Card(
                            child: ListTile(
                              title: Text(
                                  'Name : ${itemCodeVise ? '${itemDisplay[index - 1].code} ' + itemDisplay[index - 1].name : itemDisplay[index - 1].name}'),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Qty :${itemDisplay[index - 1].quantity}'),
                                  // TextButton(
                                  //     onPressed: () {
                                  // if (singleProduct) {
                                  //   addProduct(CartItem(
                                  // id: totalAdd Item 1,
                                  // itemId: product.itemId,
                                  // itemName: product.name,
                                  // quantity: 1,
                                  // rate: rate,
                                  // rRate: rRate,
                                  // uniqueCode: uniqueCode,
                                  // gross: gross,
                                  // discount: discount,
                                  // discountPercent: discountPercent,
                                  // rDiscount: rDisc,
                                  // fCess: kfc,
                                  // serialNo: '',
                                  // tax: tax,
                                  // taxP: taxP,
                                  // unitId: _dropDownUnit,
                                  // unitValue: unitValue,
                                  // pRate: pRate,
                                  // rPRate: rPRate,
                                  // barcode: barcode,
                                  // expDate: expDate,
                                  // free: free,
                                  // fUnitId: fUnitId,
                                  // cdPer: cdPer,
                                  // cDisc: cDisc,
                                  // net: subTotal,
                                  // cess: cess,
                                  // total: total,
                                  // profitPer: profitPer,
                                  // fUnitValue: fUnitValue,
                                  // adCess: adCess,
                                  // iGST: iGST,
                                  // cGST: csGST,
                                  // sGST: csGST));
                                  // } else {
                                  // Fluttertoast.showToast(
                                  // msg: 'this is not Completed');
                                  // }
                                  // },
                                  // child: const Card(
                                  //     child: Text(' + ',
                                  //         style: TextStyle(
                                  //             fontSize: 25, color: blue))))
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

  bool isBarcodePicker = false;
      

  int positionID = 0;
  // List<StockProduct> _autoStockVariant = [];
  // double _stockVariantQuantity = 0;

  clearValue() {
    _quantityController.text = '';
    selectedQuantity = '';
    _freeQuantityController.text = '';
    itemNameControl.text = '';
    _rateController.text = '';
    _discountController.text = '';
    _discountPercentController.text = '';
    _serialNoController.text = '';
    taxP = 0;
    tax = 0;
    gross = 0;
    subTotal = 0;
    total = 0;
    quantity = 0;
    rate = 0;
    saleRate = 0;
    discount = 0;
    discountPercent = 0;
    rDisc = 0;
    rRate = 0;
    rateOff = 0;
    kfcP = 0;
    kfc = 0;
    unitValue = 1;
    _conversion = 0;
    freeQty = 0;
    fUnitId = 0;
    fUnitValue = 0;
    cdPer = 0;
    cDisc = 0;
    cess = 0;
    cessPer = 0;
    adCessPer = 0;
    profitPer = 0;
    adCess = 0;
    iGST = 0;
    csGST = 0;
    pRate = 0;
    rPRate = 0;
    uniqueCode = 0;
    _dropDownUnit = 0;
    barcode = 0;
  }

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _freeQuantityController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _discountPercentController =
      TextEditingController();
  final TextEditingController _serialNoController = TextEditingController();

  final FocusNode _focusNodeQuantity = FocusNode();
  final FocusNode _focusNodeFreeQuantity = FocusNode();
  final FocusNode _focusNodeRate = FocusNode();
  final FocusNode _focusNodeDiscountPer = FocusNode();
  final FocusNode _focusNodeDiscount = FocusNode();

  final _resetKey = GlobalKey<FormState>();
  String expDate = '2000-01-01';
  DataJson? unit;
  int _dropDownUnit = 0, fUnitId = 0, uniqueCode = 0, barcode = 0;

  double taxP = 0,
      tax = 0,
      gross = 0,
      subTotal = 0,
      total = 0,
      quantity = 0,
      rate = 0,
      saleRate = 0,
      currentRate = 0,
      discount = 0,
      discountPercent = 0,
      rDisc = 0,
      rRate = 0,
      rateOff = 0,
      kfcP = 0,
      kfc = 0,
      unitValue = 1,
      _conversion = 0,
      freeQty = 0,
      fUnitValue = 0,
      cdPer = 0,
      cDisc = 0,
      cess = 0,
      cessPer = 0,
      adCessPer = 0,
      profitPer = 0,
      adCess = 0,
      iGST = 0,
      csGST = 0,
      pRate = 0,
      rPRate = 0;

  calculate(StockProduct product) {
    if (enableMULTIUNIT) {
      if (saleRate > 0) {
        if (_conversion > 0) {
          //var r = 0.0;
          if (_focusNodeRate.hasFocus) {
            rate = double.tryParse(_rateController.text) ?? 0;
            // rate = double.tryParse(_rateController.text) * _conversion;
            lastRateStatus = false;
          } else {
            rate =  editItem ? saleRate : (saleRate * _conversion);
            // rate = saleRate; // * _conversion;
            _rateController.text = rate.toStringAsFixed(decimal);
          }
          //rate = r;
          // _rateController.text = r.toStringAsFixed(decimal);
          pRate = product.buyingPrice! * _conversion;
          rPRate = product.buyingPriceReal! * _conversion;
        } else {
          rate = (_rateController.text.isNotEmpty
              ? (double.tryParse(_rateController.text))
              : 0) ?? 0;
        }
      } else {
        rate = (_rateController.text.isNotEmpty
            ? (double.tryParse(_rateController.text))
            : 0)?? 0;
      }
    } else {
      if (_focusNodeRate.hasFocus) {
        rate = double.tryParse(_rateController.text)!;
        lastRateStatus = false;
      } else if (saleRate > 0) {
        _rateController.text = saleRate.toStringAsFixed(decimal);
        rate = saleRate;
      } else {
        rate = (_rateController.text.isNotEmpty
            ? double.tryParse(_rateController.text)
            : 0)!;
      }
    }
    if (_focusNodeQuantity.hasFocus) {
      quantity = (_quantityController.text.isNotEmpty
          ? double.tryParse(_quantityController.text)
          : 0)!;
    } else {
      quantity = (_quantityController.text.isNotEmpty
          ? double.tryParse(_quantityController.text)
          : 0)!;
    }
    freeQty = (_freeQuantityController.text.isNotEmpty
        ? double.tryParse(_freeQuantityController.text)
        : 0)!;
    rRate = taxMethod == 'MINUS'
        ? cessOnNetAmount
            ? CommonService.getRound(
                4, (100 * rate) / (100 + taxP + kfcP + cessPer))
            : CommonService.getRound(4, (100 * rate) / (100 + taxP + kfcP))
        : rate;
    discount = (_discountController.text.isNotEmpty
        ? double.tryParse(_discountController.text)
        : 0)!;
    double? discP = _discountPercentController.text.isNotEmpty
        ? double.tryParse(_discountPercentController.text)?? 0 
        : 0;
    double? disc = _discountController.text.isNotEmpty
        ? double.tryParse(_discountController.text)??0 
        : 0;
    double? qt = _quantityController.text.isNotEmpty
        ? double.tryParse(_quantityController.text)
        : 0;
    double? sRate = _rateController.text.isNotEmpty
        ? double.tryParse(_rateController.text)
        : 0;
    if (_focusNodeDiscountPer.hasFocus) {
      _discountController.text = _discountPercentController.text.isNotEmpty &&
              selectedTaxOption == 'With Tax'
          ? (((qt! * rRate!) * discP) / 100).toStringAsFixed(2) 
          : (((qt! * rate!) * discP) / 100).toStringAsFixed(2);
      discount = (_discountController.text.isNotEmpty
          ? double.tryParse(_discountController.text)
          : 0)!;
      discountPercent = double.tryParse(_discountPercentController.text) ?? 0;
    }

    if (_focusNodeDiscount.hasFocus) {
      _discountPercentController.text =
          _discountController.text.isNotEmpty && selectedTaxOption == 'With Tax'
              ? ((disc * 100) / (qt! * rRate!)).toStringAsFixed(2)
              : ((disc * 100) / (qt! * rate!)).toStringAsFixed(2);
      discountPercent = (_discountController.text.isNotEmpty
          ? double.tryParse(_discountPercentController.text)
          : 0)!;
      // discount = discountPercent > 0
      // ?
      double.tryParse(_discountController.text);
      // : discount;
    }
    rDisc = taxMethod == 'MINUS'
        ? CommonService.getRound(
            4,
            ((discount * 100) /
                (cessOnNetAmount
                    ? (taxP + 100 + cessPer + kfcP)
                    : (taxP + 100 + kfcP))))
        : discount;
    gross = selectedTaxOption == 'With Tax'
        ? CommonService.getRound(decimal, ((rRate * quantity)))
        : CommonService.getRound(decimal, ((rate * quantity)));
    subTotal = CommonService.getRound(decimal, (gross - rDisc));
    if (taxP > 0) {
      tax = CommonService.getRound(4, ((subTotal * taxP) / 100));
    }
    if (companyTaxMode == 'INDIA') {
      kfc = isKFC ? CommonService.getRound(4, ((subTotal * kfcP) / 100)) : 0;
      double csPer = taxP / 2;
      iGST = 0;
      csGST = CommonService.getRound(4, ((subTotal * csPer) / 100));
    } else if (companyTaxMode == 'GULF') {
      iGST = CommonService.getRound(4, ((subTotal * taxP) / 100));
      csGST = 0;
      kfc = 0;
    } else {
      iGST = 0;
      csGST = 0;
      kfc = 0;
      tax = 0;
    }
    if (cessOnNetAmount) {
      if (cessPer > 0) {
        cess = CommonService.getRound(4, ((subTotal * cessPer) / 100));
        adCess = CommonService.getRound(4, (quantity * adCessPer));
      } else {
        cess = 0;
        adCess = 0;
      }
    } else {
      cess = 0;
      adCess = 0;
    }
    total = CommonService.getRound(
        2, (subTotal + csGST + csGST + iGST + cess + kfc + adCess));
    if (enableMULTIUNIT && _conversion > 0) {
      profitPer = pRateBasedProfitInSales
          ? CommonService.getRound(
              2, (total - (product.buyingPrice! * _conversion * quantity)))
          : CommonService.getRound(decimal,
              (total - (product.buyingPriceReal! * _conversion * quantity)));
    } else {
      profitPer = pRateBasedProfitInSales
          ? CommonService.getRound(
              2, (total - (product.buyingPrice! * quantity)))
          : CommonService.getRound(
              2, (total - (product.buyingPriceReal! * quantity)));
    }
    unitValue = _conversion > 0 ? _conversion : 1;
  }

  calculateText(StockProduct product) {
    double discP = (_discountPercentController.text.isNotEmpty
        ? double.tryParse(_discountPercentController.text)
        : 0)!;
    double disc = (_discountController.text.isNotEmpty
        ? double.tryParse(_discountController.text)
        : 0)!;
    double qt = (_quantityController.text.isNotEmpty
        ? double.tryParse(_quantityController.text)
        : 0)!;
    double sRate = (_rateController.text.isNotEmpty
        ? double.tryParse(_rateController.text)
        : 0)!;

    if (enableMULTIUNIT && rate > 0 && _conversion > 0) {
      rate = rate; // * _conversion;
      pRate = product.buyingPrice! * _conversion;
      rPRate = product.buyingPriceReal! * _conversion;
    } else {
      pRate = product.buyingPrice!;
      rPRate = product.buyingPriceReal!;
    }
    quantity = qt;
    freeQty = (_freeQuantityController.text.isNotEmpty
        ? double.tryParse(_freeQuantityController.text)
        : 0)!;
    rRate = taxMethod == 'MINUS'
        ? cessOnNetAmount
            ? CommonService.getRound(
                4, (100 * rate) / (100 + taxP + kfcP + cessPer))
            : CommonService.getRound(4, (100 * rate) / (100 + taxP + kfcP))
        : rate;
    discount = disc;
    discountPercent = discP;
    if (discP > 0) {
      discount = selectedTaxOption == 'With Tax'
          ? double.parse((((qt * rRate) * discP) / 100).toStringAsFixed(2))
          : double.parse((((qt * rate) * discP) / 100).toStringAsFixed(2));
      _discountController.text = discount.toStringAsFixed(2);
      discountPercent = discP;
    } else if (disc > 0) {
      discountPercent = selectedTaxOption == 'With Tax'
          ? double.parse(((disc * 100) / (qt * sRate)).toStringAsFixed(2))
          : double.parse(((disc * 100) / (qt * rate)).toStringAsFixed(2));
      _discountPercentController.text = discountPercent.toStringAsFixed(2);
      discount = disc;
    }

    rDisc = taxMethod == 'MINUS'
        ? CommonService.getRound(
            4,
            ((discount * 100) /
                (cessOnNetAmount
                    ? (taxP + 100 + cessPer + kfcP)
                    : (taxP + 100 + kfcP))))
        : discount;
    gross = selectedTaxOption == 'With Tax'
        ? CommonService.getRound(decimal, ((rRate * quantity)))
        : CommonService.getRound(decimal, ((rate * quantity)));
    subTotal = CommonService.getRound(decimal, (gross - rDisc));
    if (taxP > 0) {
      tax = CommonService.getRound(4, ((subTotal * taxP) / 100));
    }
    if (companyTaxMode == 'INDIA') {
      kfc = isKFC ? CommonService.getRound(4, ((subTotal * kfcP) / 100)) : 0;
      double csPer = taxP / 2;
      iGST = 0;
      csGST = CommonService.getRound(4, ((subTotal * csPer) / 100));
    } else if (companyTaxMode == 'GULF') {
      iGST = CommonService.getRound(4, ((subTotal * taxP) / 100));
      csGST = 0;
      kfc = 0;
    } else {
      iGST = 0;
      csGST = 0;
      kfc = 0;
      tax = 0;
    }
    if (cessOnNetAmount) {
      if (cessPer > 0) {
        cess = CommonService.getRound(4, ((subTotal * cessPer) / 100));
        adCess = CommonService.getRound(4, (quantity * adCessPer));
      } else {
        cess = 0;
        adCess = 0;
      }
    } else {
      cess = 0;
      adCess = 0;
    }
    total = CommonService.getRound(
        2, (subTotal + csGST + csGST + iGST + cess + kfc + adCess));
    if (enableMULTIUNIT && _conversion > 0) {
      profitPer = pRateBasedProfitInSales
          ? CommonService.getRound(
              2, (total - (product.buyingPrice! * _conversion * quantity)))
          : CommonService.getRound(decimal,
              (total - (product.buyingPriceReal! * _conversion * quantity)));
    } else {
      profitPer = pRateBasedProfitInSales
          ? CommonService.getRound(
              2, (total - (product.buyingPrice! * quantity)))
          : CommonService.getRound(
              2, (total - (product.buyingPriceReal! * quantity)));
    }
    unitValue = _conversion > 0 ? _conversion : 1;
  }

  bool lastRateStatus = true;
bool editItem = false;
  int? position;

  cartProduct() {
    setState(() {
      calculateTotal();
    });
    return loadReturnForm
        ? salesReturnForm()
        : Column(
            children: [
              salesHeaderWidget(),
              totalItem > 0
                  ? Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: cartItem.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: blue.shade100,
                            elevation: 5.0,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(
                                        text: '${cartItem[index].itemName}\n',
                                        style: const TextStyle(
                                            color: black,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // const SizedBox(
                                            //   height: 1.0,
                                            // ),
                                            RichText(
                                              maxLines: 1,
                                              text: TextSpan(
                                                  text:
                                                      '${cartItem[index].id}/',
                                                  style: TextStyle(
                                                      color: Colors
                                                          .blueGrey.shade800,
                                                      fontSize: 10.0),
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            '${cartItem[index].uniqueCode}/${cartItem[index].itemId}',
                                                        style: const TextStyle(
                                                            fontSize: 10.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ]),
                                            ),
                                            RichText(
                                              maxLines: 1,
                                              text: TextSpan(
                                                  text: 'Unit: ',
                                                  style: TextStyle(
                                                      color: Colors
                                                          .blueGrey.shade800,
                                                      fontSize: 12.0),
                                                  children: [
                                                    TextSpan(
                                                        text:
                                                            '${UnitSettings.getUnitName(cartItem[index].unitId!)}\n',
                                                        style: const TextStyle(
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PlusMinusButtons(
                                        addQuantity: () {
                                          if (oldBill) {
                                            api
                                                .getStockOf(
                                                    cartItem[index].itemId!)
                                                .then((value) {
                                              cartItem[index].stock = value;
                                              setState(() {
                                                bool cartQ = false;
                                                if (totalItem > 0) {
                                                  double cartS = 0, cartQt = 0;
                                                  for (var element
                                                      in cartItem) {
                                                    if (element.itemId ==
                                                        cartItem[index]
                                                            .itemId) {
                                                      cartQt +=
                                                          element.quantity!;
                                                      cartS = element.stock!;
                                                    }
                                                  }
                                                  cartS =
                                                      oldBill ? value : cartS;
                                                  if (cartS > 0) {
                                                    if (cartS < cartQt + 1) {
                                                      cartQ = true;
                                                    }
                                                  }
                                                }
                                                outOfStock =
                                                    isLockQtyOnlyInSales
                                                        ? cartItem[index]
                                                                        .quantity! +
                                                                    1 >
                                                                cartItem[index]
                                                                    .stock!
                                                            ? true
                                                            : cartQ
                                                                ? true
                                                                : false
                                                        : negativeStock
                                                            ? false
                                                            : salesTypeData!.type ==
                                                                        'SALES-O' ||
                                                                    salesTypeData!
                                                                            .type ==
                                                                        'SALES-Q'
                                                                ? isStockProductOnlyInSalesQO
                                                                    ? cartItem[index].quantity! +
                                                                                1 >
                                                                            cartItem[index]
                                                                                .stock!
                                                                        ? true
                                                                        : cartQ
                                                                            ? true
                                                                            : false
                                                                    : false
                                                                : cartItem[index].quantity! +
                                                                            1 >
                                                                        cartItem[index]
                                                                            .stock!
                                                                    ? true
                                                                    : cartQ
                                                                        ? true
                                                                        : false;
                                                if (outOfStock) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: const Text(
                                                        'Sorry stock not available.'),
                                                    duration: const Duration(
                                                        seconds: 10),
                                                    action: SnackBarAction(
                                                      label: 'Click',
                                                      onPressed: () {
                                                        // print('Action is clicked');
                                                      },
                                                      textColor: Colors.white,
                                                      disabledTextColor:
                                                          Colors.grey,
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ));
                                                } else {
                                                  updateProduct(
                                                      cartItem[index],
                                                      cartItem[index]
                                                              .quantity! +
                                                          1,
                                                      index);
                                                }
                                              });
                                            });
                                          } else {
                                            setState(() {
                                              bool cartQ = false;
                                              if (totalItem > 0) {
                                                double cartS = 0, cartQt = 0;
                                                for (var element in cartItem) {
                                                  if (element.itemId ==
                                                      cartItem[index].itemId) {
                                                    cartQt += element.quantity!;
                                                    cartS = element.stock!;
                                                  }
                                                }
                                                // cartS = oldBill?:cartS;
                                                if (cartS > 0) {
                                                  if (cartS < cartQt + 1) {
                                                    cartQ = true;
                                                  }
                                                }
                                              }
                                              outOfStock = isLockQtyOnlyInSales
                                                  ? ((cartItem[index].quantity! *
                                                                      cartItem[index]
                                                                          .unitValue!) +
                                                                  cartItem[index]
                                                                      .free!) +
                                                              1 >
                                                          cartItem[index].stock!
                                                      ? true
                                                      : cartQ
                                                          ? true
                                                          : false
                                                  : negativeStock
                                                      ? false
                                                      : salesTypeData!.type ==
                                                                  'SALES-O' ||
                                                              salesTypeData!
                                                                      .type ==
                                                                  'SALES-Q'
                                                          ? isStockProductOnlyInSalesQO
                                                              ? ((cartItem[index].quantity! * cartItem[index].unitValue!) +
                                                                              cartItem[index]
                                                                                  .free!) +
                                                                          1 >
                                                                      cartItem[
                                                                              index]
                                                                          .stock!
                                                                  ? true
                                                                  : cartQ
                                                                      ? true
                                                                      : false
                                                              : false
                                                          : cartItem[index]
                                                                          .quantity! +
                                                                      1 >
                                                                  cartItem[
                                                                          index]
                                                                      .stock!
                                                              ? true
                                                              : cartQ
                                                                  ? true
                                                                  : false;
                                              if (outOfStock) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: const Text(
                                                      'Sorry stock not available.'),
                                                  duration: const Duration(
                                                      seconds: 10),
                                                  action: SnackBarAction(
                                                    label: 'Click',
                                                    onPressed: () {
                                                      // print('Action is clicked');
                                                    },
                                                    textColor: Colors.white,
                                                    disabledTextColor:
                                                        Colors.grey,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ));
                                              } else {
                                                updateProduct(
                                                    cartItem[index],
                                                    cartItem[index].quantity! +
                                                        1,
                                                    index);
                                              }
                                            });
                                          }

                                          //  cart.addQuantity(
                                          //      cartItem[index].id!);
                                          //  dbHelper!
                                          //      .updateQuantity(Cart(
                                          //          id: index,
                                          //          productId: index.toString(),
                                          //          productName: provider
                                          //              .cart[index].productName,
                                          //          initialPrice: provider
                                          //              .cart[index].initialPrice,
                                          //          productPrice: provider
                                          //              .cart[index].productPrice,
                                          //          quantity: ValueNotifier(
                                          //              cartItem[index]
                                          //                  .quantity!.value),
                                          //          unitTag: provider
                                          //              .cart[index].unitTag,
                                          //          image: provider
                                          //              .cart[index].image))
                                          //      .then((value) {
                                          //    setState(() {
                                          //      cart.addTotalPrice(double.parse(
                                          //          provider
                                          //              .cart[index].productPrice
                                          //              .toString()));
                                          //    });
                                          //  });
                                        },
                                        deleteQuantity: () {
                                          setState(() {
                                            updateProduct(
                                                cartItem[index],
                                                cartItem[index].quantity! - 1,
                                                index);
                                          });

                                          //  cart.deleteQuantity(
                                          //      cartItem[index].id!);
                                          //  cart.removeTotalPrice(double.parse(
                                          //      cartItem[index].productPrice
                                          //          .toString()));
                                        },
                                        text:
                                            cartItem[index].quantity.toString(),
                                      ),
                                      RichText(
                                        maxLines: 1,
                                        text: TextSpan(
                                            text: 'Rate: ',
                                            style: TextStyle(
                                                color: Colors.blueGrey.shade800,
                                                fontSize: 13.0),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${cartItem[index].rate}\n',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12.0)),
                                            ]),
                                      ),
                                      // IconButton(
                                      // onPressed: () {
                                      //  dbHelper!.deleteCartItem(
                                      //      cartItem[index].id!);
                                      //  provider
                                      //      .removeItem(cartItem[index].id!);
                                      //  provider.removeCounter();
                                      // },
                                      // icon: Icon(
                                      // Icons.edit,
                                      // color: Colors.blue.shade800,
                                      // )),
                                      PopUpMenuAction(
                                        onDelete: () {
                                          setState(() {
                                            removeProduct(index);
                                          });
                                        },
                                        onEdit: () {
                                          setState(() {
                                            editItem = true;
                                            position = index;
                                            cartModel =
                                                cartItem.elementAt(position!);
                                            _rateController.text =
                                                cartModel!.rate!.toString();
                                            _quantityController.text =
                                                cartModel!.quantity!.toString();
                                            _freeQuantityController.text =
                                                cartModel!.free.toString();
                                            _discountController.text =
                                                cartModel!.discount.toString();
                                            _discountPercentController.text =
                                                cartModel!.discountPercent
                                                    .toString();
                                            _serialNoController.text =
                                                cartModel!.serialNo!;
                                            _dropDownUnit = cartModel!.unitId!;
                                            nextWidget = 3;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  RichText(
                                    text: TextSpan(
                                        text: 'Gross:',
                                        style: TextStyle(
                                            color: Colors.blueGrey.shade800,
                                            fontSize: 12.0),
                                        children: [
                                          TextSpan(
                                              text:
                                                  '${cartItem[index].gross}    ',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.0)),
                                          TextSpan(
                                              text: 'Disc:',
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${cartItem[index].discountPercent}% ${cartItem[index].discount}    ',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12.0)),
                                              ]),
                                          TextSpan(
                                              text: 'Net:',
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${cartItem[index].net}    ',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12.0)),
                                              ]),
                                          isTax
                                              ? TextSpan(
                                                  text:
                                                      'Tax:${cartItem[index].taxP}% ',
                                                  style: const TextStyle(
                                                      fontSize: 12.0),
                                                  children: [
                                                      TextSpan(
                                                          text:
                                                              '${cartItem[index].tax}    ',
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      12.0)),
                                                    ])
                                              : const TextSpan(text: ''),
                                          TextSpan(
                                              text: 'Total:',
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${cartItem[index].total}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12.0)),
                                              ]),
                                        ]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Text("No items in Cart"),
                    ),
              footerWidget(),
            ],
          );
  }

  productTrackingList(StockProduct product) {
    var ledId = ledgerModel!.id.toString().isNotEmpty
        ? ledgerModel!.id.toString()
        : '0';
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
                          setState(() {
                            rate = data[index]['Rate'].toDouble();
                            saleRate = data[index]['Rate'].toDouble();
                            _rateController.text = saleRate.toStringAsFixed(2);
                            calculate(product);
                          });
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

  lastRateOfLedger(StockProduct product) {
    var ledId = ledgerModel!.id.toString().isNotEmpty
        ? ledgerModel!.id.toString()
        : '0';
    api.getProductTracking(product.itemId, ledId).then((value) {
      List<dynamic> data = value;
      Map item = data.firstWhere(
          (element) =>
              element['Supplier'].toString().toLowerCase() ==
              ledgerModel!.name.toString().toLowerCase(),
          orElse: () => {});
      if (item != null && item.isNotEmpty) {
        setState(() {
          rate = item['Rate'].toDouble();
          saleRate = item['Rate'].toDouble();
          _rateController.text = saleRate.toStringAsFixed(2);
          calculate(product);
        });
      }
    });
  }

  salesReturnForm() {
    int _id = oldBill
        ? returnBillId > 0
            ? returnBillId
            : 0
        : 0;
    var data = [
      {'ledger': ledgerModel, 'id': _id}
    ];
    return SalesReturn(
      fromSale: true,
      data: data,
    );
  }

  bool loadReturnForm = false;
  double returnAmount = 0;
  int returnBillId = 0, commissionAccount = 0, bankAccount = 0;
  var commissionLedgerData, bankLedgerData;
  String? bankLedgerName;
  TextEditingController returnEntryNoController = TextEditingController();
  TextEditingController returnAmountController = TextEditingController();
  TextEditingController commissionAmountController = TextEditingController();
  TextEditingController bankAmountController = TextEditingController();

  void addProduct(product, int index) {
    index = isFreeItem
        ? index
        : cartItem.indexWhere((i) => i.itemId == product.itemId);

    if (index != -1) {
      updateProduct(
          product, cartItem[index].quantity! + product.quantity, index);
    } else {
      cartItem.add(product);
      calculateTotal();
    }
  }

  void removeProduct(int index) {
    // int index = cartItem.indexWhere((i) => i.itemId == product.itemId);
    // cartItem[index].quantity = 1;
    //  cartItem.removeAt(index); //((item) => item.id == product.id);
    if (index >= 0 && index < cartItem.length) {
      cartItem.removeAt(index);
    }

    //((item) => item.id == product.id);
    //  if (index >= 0 && index < cartItem.length) {
    // setState(() {
    //   cartItem.removeAt(index);
    // });
  }

  void updateProduct(product, qty, int index) {
    // int index = cartItem.indexWhere((i) => i.itemId == product.itemId);
    cartItem[index].quantity = qty;
    cartItem[index].discount = double.parse(
        (((qty * cartItem[index].rate) * cartItem[index].discountPercent) / 100)
            .toStringAsFixed(2));

    cartItem[index].gross = CommonService.getRound(
        4, (cartItem[index].rRate! * cartItem[index].quantity!));
    cartItem[index].net = CommonService.getRound(
        4, (cartItem[index].gross! - cartItem[index].rDiscount!));
    if (cartItem[index].taxP! > 0) {
      cartItem[index].tax = CommonService.getRound(
          4, ((cartItem[index].net! * cartItem[index].taxP!) / 100));
      if (companyTaxMode == 'INDIA') {
        cartItem[index].fCess = 0; //isKFC
        //     ? CommonService.getRound(decimal, ((cartItem[index].net * kfcPer) / 100))
        //     : 0;
        double csPer = cartItem[index].taxP! / 2;
        double csGST =
            CommonService.getRound(4, ((cartItem[index].net! * csPer) / 100));
        cartItem[index].sGST = csGST;
        cartItem[index].cGST = csGST;
      } else if (companyTaxMode == 'GULF') {
        cartItem[index].cGST = 0;
        cartItem[index].sGST = 0;
        cartItem[index].iGST = CommonService.getRound(
            4, ((cartItem[index].net! * cartItem[index].taxP!) / 100));
      } else {
        cartItem[index].cGST = 0;
        cartItem[index].sGST = 0;
        cartItem[index].fCess = 0;
      }
    }
    cartItem[index].total = CommonService.getRound(
        4,
        (cartItem[index].net! +
            cartItem[index].cGST! +
            cartItem[index].sGST! +
            cartItem[index].iGST! +
            cartItem[index].cess! +
            cartItem[index].fCess! +
            cartItem[index].adCess!));
    cartItem[index].profitPer = CommonService.getRound(
        4,
        cartItem[index].total! -
            cartItem[index].rPRate! * cartItem[index].quantity!);

    if (cartItem[index].quantity == 0) removeProduct(index);

    calculateTotal();
  }

  salesHeaderWidget() {
    return Center(
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 100,
              height: 30,
              child: Visibility(
                  visible: manualInvoiceNumberInSales,
                  child: TextField(
                    controller: invoiceNoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Invoice No'),
                    ),
                  )),
            ),
            const SizedBox(
              width: 10,
            ),
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
            const SizedBox(
              width: 10,
            ),

            PopupMenuButton<String>(
              icon: const Icon(Icons.settings, color: blue),
              onSelected: (value) {
                if (companyTaxMode == 'INDIA') {
                  setState(() {
                    if (salesData != null) {
                      if (value == 'Generate E-Way Bill') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => GenerateEWaybill(
                                      data: salesData,
                                      type: 'SALES',
                                    )));
                      } else if (value == 'Generate e-Invoice') {
                        if (salesTypeData!.eInvoice) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => GenerateE_Invoice(
                                        data: salesData,
                                        type: 'SALES',
                                      )));
                        }
                      } else if (value == 'Edit  e-Invoice') {
                        if (salesTypeData!.eInvoice) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => GenerateE_Invoice(
                                        data: salesData,
                                        type: 'SALES',
                                      )));
                        }
                      }
                    }
                  });
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'Generate E-Way Bill',
                  child: Text('Generate E-Way Bill'),
                ),
                const PopupMenuItem<String>(
                  value: 'Generate e-Invoice',
                  child: Text('Generate e-Invoice'),
                ),
                const PopupMenuItem<String>(
                  value: 'Edit  e-Invoice',
                  child: Text('Edit  e-Invoice Details'),
                ),
              ],
            ),
            // const Text(
            //   'Cash Bill: ',
            //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            // ),
            // Checkbox(
            //   checkColor: Colors.greenAccent,
            //   activeColor: Colors.red,
            //   value: _isCashBill,
            //   onChanged: (bool value) {
            //     setState(() {
            //       _isCashBill = value;
            //     });
            //   },
            // ),
          ],
        ),
        oldBill
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('EntryNo : ${dataDynamic[0]['EntryNo']}',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    width: 10,
                  ),
                  Text('InvoiceNo : ${dataDynamic[0]['InvoiceNo']}',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              )
            : Container(),
        ListTile(
          title: Text(ledgerModel!.name!,
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold)),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ledgerModel!.address1!),
            ],
          ),
        ),
        InkWell(
            child: const SizedBox(
              height: 26,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      'Add Item',
                      style: TextStyle(
                          color: blue,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  )),
            ),
            onTap: () {
              setState(() {
                nextWidget = 2;
              });
            }),
      ],
    ));
  }

  footerWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.blue[50],
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                    "SubTotal : ${CommonService.getRound(decimal, totalGrossValue).toStringAsFixed(decimal)}",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[300])),
                Text(
                    "Discount : ${CommonService.getRound(decimal, totalDiscount).toStringAsFixed(decimal)}",
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[300])),
              ],
            ),
            Visibility(
              visible: isTax,
              child: companyTaxMode == 'INDIA'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("GST :- ",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                        Text(
                            "CGST : ${CommonService.getRound(decimal, taxTotalCartValue / 2).toStringAsFixed(decimal)}",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[400])),
                        Text(
                            "SGST : ${CommonService.getRound(decimal, taxTotalCartValue / 2).toStringAsFixed(decimal)}",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[400])),
                        Text(
                            "IGST : ${CommonService.getRound(decimal, 0).toStringAsFixed(decimal)}",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[400])),
                        Text(
                            " = ${CommonService.getRound(decimal, taxTotalCartValue).toStringAsFixed(decimal)}",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[400])),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("VAT : ",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[400])),
                        Text(
                            CommonService.getRound(decimal, taxTotalCartValue)
                                .toStringAsFixed(decimal),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[400])),
                      ],
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Total : ",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[500])),
                Text(
                    CommonService.getRound(decimal, totalCartValue)
                        .toStringAsFixed(decimal),
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[500])),
              ],
            ),
            Card(
              elevation: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 145,
                    height: 40,
                    child: TextField(
                      controller: controllerCashReceived,
                      focusNode: _focusNodeCashReceived,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter(RegExp(r'[0-9]'),
                            allow: true, replacementString: '.')
                      ],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Cash Received'),
                      ),
                      onChanged: (value) {
                        setState(() {
                          balanceCalculate();
                        });
                      },
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'Bill Balance : ${ComSettings.appSettings('bool', 'key-round-off-amount', false) ? _balance.toStringAsFixed(decimal) : _balance.roundToDouble().toString()}',
                        // style: TextStyle(fontSize: 10),
                      ),
                      Text(
                        'OB:${ledgerModel!.balance}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),
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
                          controller: controllerNarration,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Narration',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: _isReturnInSales,
                    child: Card(
                      elevation: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            height: 3,
                          ),
                          SizedBox(
                            width: 100,
                            height: 35,
                            child: TextField(
                              controller: returnEntryNoController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Bill No :',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true)
                              ],
                              onChanged: (value) {
                                setState(() {
                                  returnBillId = int.tryParse(value)!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  loadReturnForm = true;
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.blue.shade100),
                                // foregroundColor:
                                //     MaterialStateProperty.all(white)
                              ),
                              child: const Text('Return Bill')),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 100,
                            height: 35,
                            child: TextField(
                              controller: returnAmountController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Amount',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true, replacementString: '.')
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    returnAmount = double.tryParse(value)!;
                                    grandTotal = grandTotal - returnAmount;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 2,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: deviceSize!.width - 125,
                            height: 55,
                            child: DropdownSearch<dynamic>(
                              popupProps:
                                  PopupPropsMultiSelection.modalBottomSheet(
                                      showSearchBox: true,
                                      constraints: BoxConstraints(
                                        maxHeight: deviceSize!.height - 110,
                                      )),
                              asyncItems: (String filter) =>
                                  api.getLedgerDataByParent(filter, 0, 0, 0, 0),
                              dropdownDecoratorProps:
                                  const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    label: Text('Select Unit')),
                              ),
                              onChanged: (dynamic data) {
                                commissionLedgerData = data;
                                commissionAccount = data.id;
                              },
                              selectedItem: commissionLedgerData,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: 55,
                            child: TextField(
                              controller: commissionAmountController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Amount',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true, replacementString: '.')
                              ],
                            ),
                          ),
                        ]),
                  ),
                  Card(
                    elevation: 2,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: deviceSize!.width - 125,
                            height: 55,
                            child: DropdownSearch<dynamic>(
                              popupProps:
                                  PopupPropsMultiSelection.modalBottomSheet(
                                      showSearchBox: true,
                                      constraints: BoxConstraints(
                                        maxHeight: deviceSize!.height - 110,
                                      )),
                              asyncItems: (String filter) =>
                                  widgetBankAccount(filter),
                              dropdownDecoratorProps:
                                  const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Card A/C'),
                              ),
                              onChanged: (dynamic data) {
                                bankLedgerData = data;
                                bankLedgerName = data.name;
                                bankAccount = data.id;
                              },
                              selectedItem: bankLedgerData,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: 55,
                            child: TextField(
                              controller: bankAmountController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Amount',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                    allow: true, replacementString: '.')
                              ],
                              onChanged: (value) {
                                setState(() {
                                  balanceCalculate();
                                });
                              },
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(
                    height: deviceSize!.height / 5,
                    child: Container(
                      color: white,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: otherAmountList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            _controllers.add(TextEditingController());
                            _controllers[index].text =
                                otherAmountList[index]['Amount'].toString();

                            // List<FocusNode> _focusNodes =
                            //     List<FocusNode>.generate(otherAmountList.length,
                            //         (int ind) => FocusNode());

                            return Card(
                              elevation: 5,
                              child: Row(children: [
                                expandStyle(
                                    2,
                                    Container(
                                        margin: const EdgeInsets.only(left: 2),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              '${otherAmountList[index]['LedName']} : '),
                                        ))),
                                SizedBox(
                                  height: 35,
                                  width: 100,
                                  child: TextField(
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder()),
                                      controller:
                                          TextEditingController.fromValue(
                                              TextEditingValue(
                                                  text: otherAmountList[index]
                                                          ['Amount']
                                                      .toString(),
                                                  selection: TextSelection(
                                                      baseOffset: 0,
                                                      extentOffset:
                                                          otherAmountList[index]
                                                                  ['Amount']
                                                              .toString()
                                                              .length))),
                                      // focusNode: _focusNodes[index],
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter(
                                            RegExp(r'[0-9]'),
                                            allow: true,
                                            replacementString: '.')
                                      ],
                                      // onChanged: (String str) {
                                      //   var cartTotal = totalCartValue;
                                      //   try {
                                      //     if (str.isNotEmpty &&
                                      //         ComSettings.oKNumeric(str)) {
                                      //       otherAmountList[index]['Amount'] =
                                      //           double.tryParse(str);
                                      //       otherAmountList[index]
                                      //               ['Percentage'] =
                                      //           CommonService.getRound(
                                      //               decimal,
                                      //               ((double.tryParse(str) *
                                      //                       100) /
                                      //                   cartTotal));
                                      //       var netTotal = (cartTotal -
                                      //               returnAmount) +
                                      //           otherAmountList.fold(
                                      //               0.0,
                                      //               (t, e) =>
                                      //                   t +
                                      //                   double.parse(e[
                                      //                               'Symbol'] ==
                                      //                           '-'
                                      //                       ? (e['Amount'] * -1)
                                      //                           .toString()
                                      //                       : e['Amount']
                                      //                           .toString()));
                                      //       setState(() {
                                      //         grandTotal = netTotal;
                                      //       });
                                      //     }
                                      //   } on FormatException {
                                      //     debugPrint('ex');
                                      //   }
                                      // },
                                      onSubmitted: (String str) {
                                        var cartTotal = totalCartValue;
                                        if (str.isNotEmpty) {
                                          try {
                                            otherAmountList[index]['Amount'] =
                                                double.tryParse(str);
                                            otherAmountList[index]
                                                    ['Percentage'] =
                                                CommonService.getRound(
                                                    decimal,
                                                    ((double.tryParse(str)! *
                                                            100) /
                                                        cartTotal));
                                            var netTotal = (cartTotal -
                                                    returnAmount) +
                                                otherAmountList.fold(
                                                    0.0,
                                                    (t, e) =>
                                                        t +
                                                        double.parse(e[
                                                                    'Symbol'] ==
                                                                '-'
                                                            ? (e['Amount'] * -1)
                                                                .toString()
                                                            : e['Amount']
                                                                .toString()));
                                            setState(() {
                                              grandTotal = netTotal;
                                            });
                                          } on FormatException {
                                            debugPrint('ex');
                                          }
                                        }
                                      }),
                                )
                              ]),
                            );
                          }),
                    ),
                  ),
                ],
              ),
            ),
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
                const Text('GrandTotal : ',
                    style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
                Text(
                    grandTotal > 0
                        ? ComSettings.appSettings(
                                'bool', 'key-round-off-amount', false)
                            ? CommonService.getRound(decimal, grandTotal)
                                .toString()
                            : CommonService.getRound(decimal, grandTotal)
                                .roundToDouble()
                                .toString()
                        : ComSettings.appSettings(
                                'bool', 'key-round-off-amount', false)
                            ? CommonService.getRound(
                                    decimal, totalCartValue - returnAmount)
                                .toString()
                            : CommonService.getRound(
                                    decimal,
                                    (totalCartValue - returnAmount)
                                        .roundToDouble())
                                .toString(),
                    style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double totalGrossValue = 0;
  double totalDiscount = 0;
  double totalNet = 0;
  double totalCess = 0;
  double totalIgST = 0;
  double totalCgST = 0;
  double totalSgST = 0;
  double totalFCess = 0;
  double totalAdCess = 0;
  double totalRDiscount = 0;
  double taxTotalCartValue = 0;
  double totalCartValue = 0;
  double totalProfit = 0;
  int get totalItem => cartItem.length;

  void clearCart() {
    for (var f in cartItem) {
      f.quantity = 1;
    }
    setState(() {
      cartItem = [];
      calculateTotal();
    });
  }

  void calculateTotal() {
    totalGrossValue = 0;
    totalDiscount = 0;
    totalRDiscount = 0;
    totalNet = 0;
    totalCess = 0;
    totalIgST = 0;
    totalCgST = 0;
    totalSgST = 0;
    totalFCess = 0;
    totalAdCess = 0;
    taxTotalCartValue = 0;
    totalCartValue = 0;
    totalProfit = 0;
    grandTotal = 0;

    for (var f in cartItem) {
      totalGrossValue += f.gross!;
      totalDiscount += f.discount!;
      totalRDiscount += f.rDiscount!;
      totalNet += f.net!;
      totalCess += f.cess!;
      totalIgST += f.iGST!;
      totalCgST += f.cGST!;
      totalSgST += f.sGST!;
      totalFCess += f.fCess!;
      totalAdCess += f.adCess!;
      taxTotalCartValue += f.tax!;
      totalCartValue += f.total!;
      totalProfit += f.profitPer!;
    }
    grandTotal = (totalCartValue - returnAmount) +
        otherAmountList.fold(
            0.0,
            (t, e) =>
                t +
                double.parse(e['Symbol'] == '-'
                    ? (e['Amount'] * -1).toString()
                    : e['Amount'].toString()));
  }

  expandStyle(int flex, Widget child) => Expanded(flex: flex, child: child);

  Future<void> _removeItemDialog(BuildContext context, int index) async {
    return showDialog(
      context: context,
      builder: (context) {
        return (StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Do you want to remove?'),
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
                    updateProduct(
                        cartItem[index],
                        cartItem[index].quantity! - cartItem[index].quantity!,
                        index);
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

  String barcodeValueText = '0';

  searchProductBarcode() {
    return showDialog(
      context: context,
      builder: (context) {
        return (StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Type Barcode'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  barcodeValueText = value;
                });
              },
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () {
                        scannerProductWidget();
                      },
                      icon: const Icon(Icons.document_scanner)),
                  border: const OutlineInputBorder(),
                  labelText: "barcode"),
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
                  Navigator.pop(context);
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
                    isBarcodePicker = true;
                    nextWidget = 3;
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

  showMore(context, bool newBill) {
    ConfirmAlertBox(
        buttonColorForNo: Colors.red,
        buttonColorForYes: Colors.green,
        icon: Icons.check,
        onPressedNo: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Sale(
                thisSale: thisSale, oldSale: false
                ))
              );
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

  Future _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => {formattedDate = DateFormat('dd-MM-yyyy').format(picked)});
    }
  }

  showEditDialog(context, dataDynamic) {
    ConfirmAlertBox(
        buttonColorForNo: Colors.red,
        buttonColorForYes: Colors.green,
        icon: Icons.check,
        onPressedNo: () {
          Navigator.of(context).pop();
        },
        onPressedYes: () {
          Navigator.of(context).pop();
          fetchSale(context, dataDynamic);
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage:
            'Do you want to edit or delete\nRefNo:${dataDynamic['Id']}',
        title: 'Update',
        context: context);
  }

  showDetails(context, data) {
    dataDynamic = [
      {
        'RealEntryNo': data['Id'],
        'EntryNo': data['Id'],
        'InvoiceNo': data['Id'],
        'Type': salesTypeData!.id
      }
    ];
    Navigator.pushReplacementNamed(context, '/preview_show',
        arguments: {'title': 'Sale'});
  }

  fetchSale(context, data) {
    
    // selectedItemId = cartModel!.id;
     setState(() {
      isLoading = true;
    });
    double billTotal = 0, billCash = 0;

    api.fetchSalesInvoice(data['Id'], salesTypeData!.id).then((value) {
      if (value != null) {
        salesData = value;
        var information = value['Information'][0];
        var particulars = value['Particulars'];
        // var serialNO = value['SerialNO'];
        // var deliveryNoteDetails = value['DeliveryNote'];
        otherAmountList = value['otherAmount'];
        formattedDate = DateUtil.dateDMY(information['DDate']);
        rateTypeItem = rateTypeList.firstWhere((element) => 
        element.id.toString() ==
         information['Stype'].toString());
        dataDynamic = [
          {
            'RealEntryNo': information['RealEntryNo'],
            'EntryNo': information['EntryNo'],
            'InvoiceNo': information['InvoiceNo'],
            'Type': salesTypeData!.id
          }
        ];
        
        invoiceNo = information['InvoiceNo'];
        invoiceNoController.text = invoiceNo;
        billCash = double.tryParse(information['CashReceived'].toString())!;
        billTotal = double.tryParse(information['GrandTotal'].toString())!;
        returnAmount = double.tryParse(information['ReturnAmount'].toString())!;
        selectedItemId = information['itemId'];
        returnBillId = information['ReturnNo'];
        controllerNarration.text = information['Narration'];
     
       
        if (apiV != 'v19/') {
          Object _bankLedgerName = information['BankName'] != null
              ? information['BankName'].toString()
              : 0;
          double? _bankLedgerAmount = information['bankamount'] != null
              ? double.tryParse(information['bankamount'].toString())
              : 0;
          if (_bankLedgerAmount! > 0) {
            bankAmountController.text = _bankLedgerAmount.toString();
            bankLedgerData = cashBankACList.firstWhere((element) =>
                element.name.toLowerCase() ==
                _bankLedgerName.toString().toLowerCase());
            bankLedgerName = bankLedgerData.name;

          } else {
            bankAmountController.text = '';
            bankLedgerData = null;
            bankLedgerName = '';
          }
          int? _commissionLedgerAc = information['CareOff'] != null
              ? int.tryParse(information['CareOff'].toString())
              : 0;
          double? _commissionLedgerAmount = information['CareOffAmount'] != null
              ? double.tryParse(information['CareOffAmount'].toString())
              : 0;
          if (_commissionLedgerAmount! > 0) {
            commissionAmountController.text =
                _commissionLedgerAmount.toString();
            commissionAccount = _commissionLedgerAc!;
            api.getCustomerDetail(_commissionLedgerAc).then((ledgerData) =>
                commissionLedgerData = LedgerModel(
                    id: _commissionLedgerAc, name: ledgerData.name!));
          } else {
            commissionAmountController.text = '';
            commissionLedgerData = null;
            commissionAccount = 0;
          }
        }
        CustomerModel cModel = CustomerModel(
            id: information['Customer'],
            name: information['ToName'],
            address1: information['Add1'],
            address2: information['Add2'],
            address3: information['Add3'],
            address4: information['Add4'],
            balance: information['Balance'].toString(),
            city: '',
            email: '',
            phone: '',
            route: '',
            state: '',
            stateCode: '',
            taxNumber: information['gstno']);
        ledgerModel =  cModel;
        nameControl.text = cModel.id == acId ?  cashAc :cModel.name!;
        selectedCustomerId =  cModel.id;
        addressControl.text = cModel.address1!;
        siteNameControl.text = cModel.address2!;
        
        // api
        //     .getCustomerDetail(ledgerModel.id)
        //     .then((ledgerData) => accountModel = ledgerData);
        ScopedModel.of<MainModel>(context).addCustomer(cModel);
  //       cartModel =
  // cartItem.elementAt(position!);
        for (var product in particulars) {
          addProduct(  
              CartItem(
                  stock: 0,
                  minimumRate: 0,
                  id: totalItem + 1,
                  itemId: product['itemId'],
                  itemName: product['itemname'],
                  quantity: double.tryParse(product['Qty'].toString())!,
                  rate: double.tryParse(product['Rate'].toString())!,
                  rRate: double.tryParse(product['RealRate'].toString())!,
                  uniqueCode: product['UniqueCode'],
                  gross: double.tryParse(product['GrossValue'].toString())!,
                  discount: double.tryParse(product['Disc'].toString())!,
                  discountPercent:
                      double.tryParse(product['DiscPersent'].toString())!,
                  rDiscount: double.tryParse(product['RDisc'].toString())!,
                  fCess: double.tryParse(product['Fcess'].toString())!,
                  serialNo: product['serialno'].toString(),
                  tax: double.tryParse(product['CGST'].toString())! +
                      double.tryParse(product['SGST'].toString())! +
                      double.tryParse(product['IGST'].toString())!,
                  taxP: double.tryParse(product['igst'].toString())!,
                  unitId: product['Unit'],
                  unitValue: double.tryParse(product['UnitValue'].toString())!,
                  pRate: double.tryParse(product['Prate'].toString())!,
                  rPRate: double.tryParse(product['Rprate'].toString())!,
                  barcode: product['UniqueCode'],
                  expDate: '2020-01-01',
                  free: double.tryParse(product['freeQty'].toString())!,
                  fUnitId: int.tryParse(product['Funit'].toString())!,
                  cdPer: 0, //product['']cdPer,
                  cDisc: 0, //product['']cDisc,
                  net: double.tryParse(product['Net'].toString())!, //subTotal,
                  cess: double.tryParse(product['cess'].toString())!, //cess,
                  total: double.tryParse(product['Total'].toString())!, //total,
                  profitPer: 0, //product['']profitPer,
                  fUnitValue: double.tryParse(
                      product['FValue'].toString())!, //fUnitValue,
                  adCess:
                      double.tryParse(product['adcess'].toString())!, //adCess,
                  iGST: double.tryParse(product['IGST'].toString())!,
                  cGST: double.tryParse(product['CGST'].toString())!,
                  sGST: double.tryParse(product['SGST'].toString())!,
                  cessPer: double.tryParse(product['cessper'].toString())!,
                  adCessPer: double.tryParse(product['adcessper'].toString())!,
                  ),
                  
              -1);
        } 
        userDateCheck(information['DDate'].toString());
      }

      setState(() {
        widgetID = false;
        grandTotal = billTotal - returnAmount;
        if (billCash > 0) {
          controllerCashReceived.text = billCash.toString();
          _balance = controllerCashReceived.text.isNotEmpty
              ? grandTotal > 0
                  ? grandTotal - double.tryParse(controllerCashReceived.text)!
                  : ((totalCartValue) -
                      double.tryParse(controllerCashReceived.text)!)
              : grandTotal > 0
                  ? grandTotal
                  : totalCartValue;
        }
        if (returnAmount > 0) {
          returnAmountController.text = returnAmount.toString();
          returnEntryNoController.text = returnBillId.toString();
        }
        // nextWidget = 4;
        
        editItem = true;
        oldBill = true;
      });
      // Navigator.pushReplacementNamed(context, '/preview_show',
      // arguments: {'title': 'Sale'});
    });
  }

  Widget _buildQrViewLedger(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreatedLedger,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Widget _buildQrViewProduct(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreatedProduct,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreatedLedger(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        loadScanner = false;
        var _id = result!.code!.isNotEmpty
            ? int.tryParse(result!.code!.replaceAll('http://', ''))
            : 0;
        ledgerDataModel = LedgerModel(id: _id!, name: 'A');
        nextWidget = 1;
        isData = false;
      });
    });
  }

  void _onQRViewCreatedProduct(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        productScanner = false;
        var _id = result!.code!.isNotEmpty
            ? int.tryParse(result!.code!.replaceAll('http://', ''))
            : 0;
        // ledgerDataModel = LedgerModel(id: _id, name: 'A');
        // nextWidget = 1;
        // isData = false;
        barcodeValueText = _id.toString();
        isBarcodePicker = true;
        nextWidget = 3;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    // log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
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

  salesManVehicle() {
    return salesmanAsVehicle
        ? Row(
            children: [
              // const Text('Vehicle No'),
              SizedBox(
                width: 120,
                // child: Expanded(
                //   child: TextField(
                //     decoration: const InputDecoration(
                //       border: OutlineInputBorder(),
                //       label: Text('No'),
                //     ),
                //     onChanged: (value) {
                //       setState(() {
                //         // customerName =
                //         //     value.isNotEmpty ? value.toUpperCase() : 'CASH';
                //       });
                //     },
                //   ),
                // ),
                child: DropdownSearch<dynamic>(
                  popupProps: const PopupPropsMultiSelection.modalBottomSheet(
                      showSearchBox: true,
                      constraints: BoxConstraints(
                        maxHeight: 300,
                      )),
                  asyncItems: (String filter) => getSalesManListData(filter),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'V No')),
                  onChanged: (dynamic data) {
                    vehicleData = otherRegSalesManList.firstWhere((element) =>
                        element['Auto'].toString() == data.id.toString());
                    vehicleName = vehicleData['Name'];
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  // enabled: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: Text(vehicleName),
                  ),
                ),
              ),
            ],
          )
        : SimpleAutoCompleteTextField(
            key: keyVehicleName,
            controller: vehicleNameControl,
            clearOnSubmit: false,
            suggestions: vehicleNameListDisplay,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Vehicle No'),
          );
  }

  Future<List<dynamic>> getSalesManListData(String filter) async {
    var dd = filter.isEmpty
        ? otherRegSalesManList
        : otherRegSalesManList
            .where((element) => element['Name']
                .toString()
                .toLowerCase()
                .contains(filter.toLowerCase()))
            .toList();
    List<DataJson> dataResult = [];
    for (var data in dd) {
      dataResult.add(DataJson(
          id: data['Auto'],
          name: data['Name'].trim().split(' ')[0].toString()));
    }
    return dataResult;
  }

  showBottom0(BuildContext ctx) {
    showModalBottomSheet(
        isScrollControlled: true,
        elevation: 5,
        context: ctx,
        builder: (ctx) => Padding(
              padding: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controllerNarration,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Narration...',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Visibility(
                    visible: _isReturnInSales,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: returnEntryNoController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Bill No :',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                  allow: true)
                            ],
                            onChanged: (value) {
                              setState(() {
                                returnBillId = int.tryParse(value)!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                loadReturnForm = true;
                              });
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    kPrimaryDarkColor),
                                foregroundColor:
                                    MaterialStateProperty.all(white)),
                            child: const Text('Return Bill')),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            controller: returnAmountController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Amount :',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                  allow: true, replacementString: '.')
                            ],
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  returnAmount = double.tryParse(value)!;
                                  grandTotal = grandTotal - returnAmount;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    // height: deviceSize.height / 6,
                    child: Container(
                      color: white,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: otherAmountList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            _controllers.add(TextEditingController());
                            _controllers[index].text =
                                otherAmountList[index]['Amount'].toString();
                            return Container(
                                padding: const EdgeInsets.only(
                                    top: 0, right: 10, left: 10),
                                child: Row(children: <Widget>[
                                  expandStyle(
                                      2,
                                      Container(
                                          margin:
                                              const EdgeInsets.only(top: 35),
                                          child: Text(otherAmountList[index]
                                              ['LedName']))),
                                  expandStyle(
                                      1,
                                      TextFormField(
                                          controller:
                                              TextEditingController.fromValue(
                                                  TextEditingValue(
                                            text: otherAmountList[index]
                                                    ['Amount']
                                                .toString(),
                                            // selection: TextSelection(
                                            //     baseOffset: 0,
                                            //     extentOffset:
                                            //         otherAmountList[index]
                                            //                 ['Amount']
                                            //             .toString()
                                            //             .length)
                                          )),
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter(
                                                RegExp(r'[0-9]'),
                                                allow: true)
                                          ],
                                          onFieldSubmitted: (String str) {
                                            var cartTotal = totalCartValue;
                                            if (str.isNotEmpty) {
                                              try {
                                                otherAmountList[index]
                                                        ['Amount'] =
                                                    double.tryParse(str);
                                                otherAmountList[index]
                                                        ['Percentage'] =
                                                    CommonService.getRound(
                                                        decimal,
                                                        ((double.tryParse(
                                                                    str)! *
                                                                100) /
                                                            cartTotal));
                                                var netTotal = (cartTotal -
                                                        returnAmount) +
                                                    otherAmountList.fold(
                                                        0.0,
                                                        (t, e) =>
                                                            t +
                                                            double.parse(
                                                                e['Symbol'] ==
                                                                        '-'
                                                                    ? (e['Amount'] *
                                                                            -1)
                                                                        .toString()
                                                                    : e['Amount']
                                                                        .toString()));
                                                setState(() {
                                                  grandTotal = netTotal;
                                                });
                                              } on FormatException {
                                                debugPrint('ex');
                                              }
                                            }
                                          }))
                                ]));
                          }),
                    ),
                  ),
                ],
              ),
            ));

    // child: Column(
    //   mainAxisSize: MainAxisSize.min,
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     TextField(
    //       controller: _otherDiscountController,
    //       focusNode: _focusNodeOtherDiscount,
    //       keyboardType:
    //           TextInputType.numberWithOptions(decimal: true),
    //       decoration: InputDecoration(labelText: 'Other Discount'),
    //     ),
    //     TextField(
    //       controller: _otherChargesController,
    //       focusNode: _focusNodeOtherCharges,
    //       keyboardType:
    //           TextInputType.numberWithOptions(decimal: true),
    //       decoration: InputDecoration(labelText: 'Other Charges'),
    //     ),
    //     TextField(
    //       controller: narrationController,
    //       decoration: InputDecoration(labelText: 'Narration'),
    //     ),
    //     const SizedBox(
    //       height: 15,
    //     ),
    //     Text(calculateGrandTotal()),
    //     Center(
    //         child: ElevatedButton(
    //             onPressed: () {
    //               setState(() {
    //                 calculateGrandTotal();
    //               });
    //             },
    //             child: const Text('Submit')))
    //   ],
    // ),
  }

  // var _dropDownBankValue = '';
  // widgetBankAccount() {
  //   return DropdownButton<String>(
  //     hint: Text(_dropDownBankValue.isNotEmpty
  //         ? _dropDownBankValue.split('-')[1]
  //         : 'Select bank account'),
  //     items: cashBankACList.map<DropdownMenuItem<String>>((item) {
  //       return DropdownMenuItem<String>(
  //         value: item.id.toString() + "-" + item.name,
  //         child: Text(item.name),
  //       );
  //     }).toList(),
  //     onChanged: (value) {
  //       setState(() {
  //         _dropDownBankValue = value;
  //         bankLedgerData = value;
  //         bankAccount = int.parse(value.split('-')[0]);
  //         bankLedgerName = value.split('-')[1];
  //       });
  //     },
  //   );
  // }

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

  void balanceCalculate() {
    double? cashReceived = controllerCashReceived.text.trim().isNotEmpty
        ? double.tryParse(controllerCashReceived.text)
        : 0;
    double bankAmount = bankAmountController.text.trim().isNotEmpty
        ? double.parse(bankAmountController.text.trim())
        : 0;
    _balance = (cashReceived! > 0 || bankAmount > 0)
        ? grandTotal > 0
            ? grandTotal - cashReceived - bankAmount
            : ((totalCartValue) - cashReceived - bankAmount)
        : grandTotal > 0
            ? grandTotal
            : totalCartValue;
  }

  Future<void> searchBill(BuildContext context, int type) async {
    TextEditingController _controller = TextEditingController();
    String valueText;
    _controller.text = '';

    return showDialog(
        context: context,
        builder: (BuildContext cx) {
          return AlertDialog(
            title: const Text('Type EntryNo'),
            content: TextField(
              onChanged: (value) {
                valueText = value;
              },
              controller: _controller,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "EntryNo"),
              keyboardType: const TextInputType.numberWithOptions(),
              inputFormatters: [
                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                    allow: true, replacementString: '.')
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(cx);
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
                  Navigator.pop(cx);
                  if (_controller.text.isNotEmpty) {
                    dataDynamic = [
                      {
                        'Type': type,
                        'InvoiceNo': _controller.text,
                        'EntryNo': int.tryParse(_controller.text) ?? 0,
                        'Id': int.tryParse(_controller.text) ?? 0
                      }
                    ];
                    fetchSale(context, dataDynamic[0]);
                  }
                },
              ),
            ],
          );
        });
  }

  selectedRateTypeData(
      List<OptionRateType> rateTypeList, StockProduct product) {
    List<ProductRating> result = [];
    int _id = -1;
    for (OptionRateType data in rateTypeList) {
      var _rate = data.name == 'RETAIL'
          ? product.retailPrice
          : data.name == 'SPRETAIL'
              ? product.spRetailPrice
              : data.name == 'WHOLESALE'
                  ? product.wholeSalePrice
                  : data.name == 'BRANCH'
                      ? product.branch
                      : product.sellingPrice;
      result.add(ProductRating(
          id: _id++,
          name: (data.name == 'SPRETAIL' ? labelSpRate : data.name),
          rate: _rate));
    }
    return result;
  }

  scannerProductWidget() {
    return Column(
      children: <Widget>[
        Expanded(flex: 4, child: _buildQrViewProduct(context)),
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                if (result != null)
                  Text(
                      'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                else
                  const Text('Scan a code'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return Text('Flash: ${snapshot.data}');
                            },
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getCameraInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return Text(
                                    'Camera facing ${describeEnum(snapshot.data!)}');
                              } else {
                                return const Text('loading');
                              }
                            },
                          )),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller?.pauseCamera();
                        },
                        child:
                            const Text('pause', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller?.resumeCamera();
                        },
                        child: const Text('resume',
                            style: TextStyle(fontSize: 20)),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  addProductButtonWidget() {
    // return ElevatedButton(
    //   style: ElevatedButton.styleFrom(
    //       foregroundColor: white,
    //       backgroundColor: kPrimaryColor,
    //       elevation: 0,
    //       disabledForegroundColor: grey.withOpacity(0.38),
    //       disabledBackgroundColor: grey.withOpacity(0.12)),
    //   child: const Center(
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         Icon(
    //           Icons.shopping_bag,
    //           color: white,
    //         ),
    //         SizedBox(
    //           width: 4.0,
    //         ),
    //         Text(
    //           "Add Product To Cart",
    //           style: TextStyle(color: white),
    //         ),
    //       ],
    //     ),
    //   ),
    //   onPressed: () {
    //     setState(() {
    //       if (ledgerDataModel!.name.toUpperCase() == 'CASH') {
    //         if (salesTypeData!.rateType.isNotEmpty) {
    //           rateType = salesTypeData!.id.toString();
    //         }
    //         nextWidget = 2;
    //       } else {
    //         if (salesTypeData!.type == 'SALES-BB') {
    //           if (ledgerModel!.taxNumber!.isNotEmpty) {
    //             if (salesTypeData!.rateType.isNotEmpty) {
    //               rateType = salesTypeData!.id.toString();
    //             }
    //             nextWidget = 2;
    //           } else if (!blockTaxLedgerOnB2CorBOS) {
    //             if (salesTypeData!.rateType.isNotEmpty) {
    //               rateType = salesTypeData!.id.toString();
    //             }
    //             nextWidget = 2;
    //           } else {
    //             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //                 content:
    //                     Text('B2B Invoice not allow without a TAX number')));
    //           }
    //         } else {
    //           if (blockTaxLedgerOnB2CorBOS) {
    //             if ((salesTypeData!.type == 'SALES-BC' ||
    //                     salesTypeData!.type == 'SALES-BOS') &&
    //                 ledgerModel!.taxNumber!.isNotEmpty) {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                   const SnackBar(content: Text('Tax Registered Ledger')));
    //               return;
    //             }
    //           }
    //           if (salesTypeData!.rateType.isNotEmpty) {
    //             rateType = salesTypeData!.id.toString();
    //           }
    //           nextWidget = 2;
    //         }
    //       }
    //     });
    //   },
    // );
  }

  rateTypeWidget() {
    return Card(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        widgetRateType(),
        const SizedBox(
          width: 40,
        ),
        const Text('Taxable'),
        Checkbox(
          value: taxable,
          onChanged: (value) {
            setState(() {
              isTaxTypeLocked = value!;
            });
          },
        ),
      ]),
    );
  }

  cashCustomerWidget() {
    return SizedBox(
      width: deviceSize!.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            child: Text(ledgerDataModel!.name,
                style: const TextStyle(fontSize: 20)),
            onTap: () {
              setState(() {
                nextWidget = 0;
                nameLike = 'a';
                customerNameControl.text = '';
              });
            },
          ),
        ),
      ),
    );
  }

  addressLineWidget() {
    addressControl.text = "${ledgerModel!.address1!} ${ledgerModel!.address2!}";
    return TextField(
      controller: addressControl,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Address',
          labelText: 'Address'),
    );
  }

  siteLineWidget() {
    siteNameControl.text =
        "${ledgerModel!.address3!} ${ledgerModel!.address4!}";
    return TextField(
      controller: siteNameControl,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Site Name',
          labelText: 'Site Name'),
    );
  }

  mobileNoWidget() {
    mobileNoControl.text = ledgerModel!.phone!;
    return TextField(
      controller: mobileNoControl,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Mobile',
          labelText: 'Mobile'),
    );
  }
}

String _otherAmountTotal(var otherAmountData) {
  var data = otherAmountData;
  var a = data.fold(
      0.0,
      (t, e) =>
          t +
          double.parse(e['Symbol'] == '-'
              ? (e['Amount'] * -1).toString()
              : e['Amount'].toString()));
  return a.toString();
}

class ProductRating {
  int? id;
  String? name;
  double? rate;
  ProductRating({this.id, this.name, this.rate});
}
