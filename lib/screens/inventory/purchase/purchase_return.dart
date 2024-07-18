import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/cart_item.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/sales_model.dart';
import 'package:sheraccerp/models/stock_item.dart';
import 'package:sheraccerp/models/stock_product.dart';
import 'package:sheraccerp/models/unit_model.dart';
import 'package:sheraccerp/models/voucher_type_model.dart';
import 'package:sheraccerp/scoped-models/main.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/service/com_service.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/container_textfield_widget.dart';
import 'package:sheraccerp/widget/popup_menu_action.dart';
import 'package:sheraccerp/widget/progress_hud.dart';

class PurchaseReturn extends StatefulWidget {
  const PurchaseReturn({Key? key}) : super(key: key);

  @override
  State<PurchaseReturn> createState() => _PurchaseReturnState();
}

class _PurchaseReturnState extends State<PurchaseReturn> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DioService dio = DioService();
  Size? deviceSize;
  var ledgerModel;
  StockItem? productModel;
  List<dynamic> purchaseAccountList = [];
  DateTime now = DateTime.now();
  String? formattedDate, invDate = '', _narration = '';
  TextEditingController invNoController = TextEditingController();
   final TextEditingController customerNameController = TextEditingController();
   final TextEditingController productNameController = TextEditingController();
  double _balance = 0;
  List<dynamic> otherAmountList = [];
  bool isTax = true,
      _isCashBill = false,
      otherAmountLoaded = false,
      valueMore = false,
      _isLoading = false,
      widgetID = true,
      oldBill = false,
      lastRecord = false,
      newPurchaseReturn = false,
      keyItemsVariantStock = false;
  List<CartItemP> cartItem = [];
  int page = 1, pageTotal = 0, totalRecords = 0,_dropDownUnit = 0;
  List<dynamic> itemDisplay = [];
  List<dynamic> items = [];
  List<dynamic> ledgerDisplay = [];
  List<dynamic> _ledger = [];
  List<SerialNOModel> serialNoData = [];
  bool enableMULTIUNIT = false,
      cessOnNetAmount = false,
      enableKeralaFloodCess = false,
      useUNIQUECODEASBARCODE = false,
      useOLDBARCODE = false,
      realPRATEBASEDPROFITPERCENTAGE = false;
  int locationId = 1, salesManId = 0, decimal = 2;
  VoucherType? voucherTypeData;

  @override
  void initState() {
    super.initState();
    formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);

    invDate = DateFormat('dd-MM-yyyy').format(now);
    dio.getPurchaseAC().then((value) {
      setState(() {
        purchaseAccountList.addAll(value);
      });
    });
    loadSettings();
  }

  loadSettings() {
    CompanyInformation companySettings =
        ScopedModel.of<MainModel>(context).getCompanySettings();
    List<CompanySettings> settings =
        ScopedModel.of<MainModel>(context).getSettings();

    taxMethod = companySettings.taxCalculation!;
    enableMULTIUNIT = ComSettings.getStatus('ENABLE MULTI-UNIT', settings);
    companyTaxMode = ComSettings.getValue('PACKAGE', settings);
    cessOnNetAmount = ComSettings.getStatus('CESS ON NET AMOUNT', settings);
    enableKeralaFloodCess =
        ComSettings.getStatus('ENABLE KERALA FLOOD CESS', settings);
    useUNIQUECODEASBARCODE =
        ComSettings.getStatus('USE UNIQUECODE AS BARCODE', settings);
    useOLDBARCODE = ComSettings.getStatus('USE OLD BARCODE', settings);
    realPRATEBASEDPROFITPERCENTAGE =
        ComSettings.getStatus('REAL PRATE BASED PROFIT PERCENTAGE', settings);

    salesManId = ComSettings.appSettings(
            'int', 'key-dropdown-default-salesman-view', 1) -
        1;
    locationId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    decimal = (ComSettings.getValue('DECIMAL', settings).toString().isNotEmpty
        ? int.tryParse(ComSettings.getValue('DECIMAL', settings).toString())
        : 2)!;
    keyItemsVariantStock =
        ComSettings.getStatus('KEY LOCK SALES DISCOUNT', settings);

        voucherTypeData = voucherTypeList.firstWhere(
        (element) => element.voucher.toLowerCase() == 'purchase return');
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
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
        child: widgetID ? widgetPrefix() : widgetSuffix());
  }

  _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit Purchase Return'),
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

  widgetSuffix() {
    return Scaffold(
      backgroundColor: bagroundColor,
      key: _scaffoldKey,
      appBar:newPurchaseReturn? AppBar(
        actions: [
          Visibility(
            visible: oldBill,
            child: IconButton(
                color: red,
                iconSize: 40,
                onPressed: () {
                  if (cartItem.isNotEmpty) {
                    setState(() {
                      _isLoading = true;
                    });
                    delete(context);
                  } else {
                    showInSnackBar('No items found on bill');
                  }
                },
                icon: const Icon(Icons.delete_forever)),
          ),
          oldBill
              ? IconButton(
                  color: green,
                  iconSize: 40,
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    var inf = '[${json.encode({
                          'id': ledgerModel.id,
                          'name': ledgerModel.name,
                          'invNo': invNoController.text.isNotEmpty
                              ? invNoController.text
                              : '0',
                          'invDate': DateUtil.dateYMD(invDate)
                        })}]';
                    var jsonItem = CartItemP.encodeCartToJson(cartItem);
                    var items = json.encode(jsonItem);
                    var stType = 'Pr_Update';
                    var data = '[${json.encode({
                          'entryNo': dataDynamic[0]['EntryNo'],
                          'date': DateUtil.dateYMD(formattedDate),
                          'grossValue': totalGrossValue,
                          'discount': totalDiscount,
                          'net': totalNet,
                          'cess': totalCess,
                          'total': totalCartTotal,
                          'otherCharges': 0,
                          'otherDiscount': 0,
                          'grandTotal': totalCartTotal,
                          'taxType': isTax ? 'T' : 'N.T',
                          'purchaseAccount': purchaseAccountList[0]['id'],
                          'narration': _narration,
                          'type': 'PR',
                          'cashPaid': '0',
                          'igst': totalIgST,
                          'cgst': totalCgST,
                          'sgst': totalSgST,
                          'fCess': totalFCess,
                          'adCess': totalAdCess,
                          'Salesman': salesManId,
                          'location': locationId,
                          'statementtype': stType,
                          'fyId': currentFinancialYear!.id,
                          'frmId': voucherTypeData!.id
                        })}]';

                    final body = {
                      'information': inf,
                      'data': data,
                      'particular': items,
                      'serialNoData': json
                          .encode(SerialNOModel.encodedToJson(serialNoData)),
                    };
                    bool _state = await dio.addPurchase(body);
                    setState(() {
                      _isLoading = false;
                    });
                    if (_state) {
                      cartItem.clear();
                      showMore(context, 'Edited');
                    } else {
                      showInSnackBar('Error enter data correctly');
                    }
                  },
                  icon: const Icon(Icons.edit))
              : IconButton(
                  color: blue,
                  iconSize: 40,
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    var inf = '[${json.encode({
                          'id': ledgerModel.id,
                          'name': ledgerModel.name,
                          'invNo': invNoController.text.isNotEmpty
                              ? invNoController.text
                              : '0',
                          'invDate': DateUtil.dateYMD(invDate)
                        })}]';
                    var jsonItem = CartItemP.encodeCartToJson(cartItem);
                    var items = json.encode(jsonItem);
                    var stType = 'Pr_Insert';
                    var data = '[${json.encode({
                          'date': DateUtil.dateYMD(formattedDate),
                          'grossValue': totalGrossValue,
                          'discount': totalDiscount,
                          'net': totalNet,
                          'cess': totalCess,
                          'total': totalCartTotal,
                          'otherCharges': 0,
                          'otherDiscount': 0,
                          'grandTotal': totalCartTotal,
                          'taxType': isTax ? 'T' : 'N.T',
                          'purchaseAccount': purchaseAccountList[0]['id'],
                          'narration': _narration,
                          'type': 'PR',
                          'cashPaid': '0',
                          'igst': totalIgST,
                          'cgst': totalCgST,
                          'sgst': totalSgST,
                          'fCess': totalFCess,
                          'adCess': totalAdCess,
                          'Salesman': salesManId,
                          'location': locationId,
                          'statementtype': stType,
                          'fyId': currentFinancialYear!.id,
                          'frmId': voucherTypeData!.id
                        })}]';

                    final body = {
                      'information': inf,
                      'data': data,
                      'particular': items,
                      'serialNoData': json
                          .encode(SerialNOModel.encodedToJson(serialNoData)),
                    };
                    bool _state = await dio.addPurchase(body);
                    setState(() {
                      _isLoading = false;
                    });
                    if (_state) {
                      cartItem.clear();
                      showMore(context, 'Saved');
                    } else {
                      showInSnackBar('Error enter data correctly');
                    }
                  },
                  icon:  Image.asset('assets/icons/Save instagram@2x.png',scale: 1.6,)),
        ],
        titleTextStyle: const TextStyle(fontFamily: 'poppins'),
        title: const Text('Purchase Return'),
      ):null,
      body: ProgressHUD(
          inAsyncCall: _isLoading, opacity: 0.0, child: selectWidget()),
    );
  }

  widgetPrefix() {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: [
            TextButton(
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
                child: const Text(
                  " New ",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'poppins'),
                )),
          ],
          titleTextStyle: const TextStyle(fontFamily: 'poppins'),
          title: const Text('Purchase Return'),
        ),
        body: Container(
          child: previousBill(),
        ));
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
        var statement = 'PurchaseReturnList';

        dio
            .getPaginationList(statement, page, '1', '0',
                DateUtil.dateYMD(formattedDate), salesManId.toString())
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

  int nextWidget = 0;
  Widget selectWidget() {
    return nextWidget == 0
        ? newPurchaseReturnWidget(newPurchaseReturn)
        // selectLedgerWidget()
        : nextWidget == 1
            ? addItemWidget()
            // purchaseHeaderWidget()
            : nextWidget == 2
                ? selectProductWidget()
                : nextWidget == 3
                    ? itemDetailWidget()
                    : nextWidget == 4
                        ? cartProduct()
                        : Container(
                            padding: const EdgeInsets.all(2.0),
                            child: const Text('No Widget'),
                          );
  }
  int? selectedCustomerId;
  newPurchaseReturnWidget(newPurchaseReturn){
     if(newPurchaseReturn){
    setState(() {
      newPurchaseReturn = true;
    });
   }
    return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: Scaffold(
      backgroundColor: bagroundColor,
      appBar: AppBar(
        title: const Text("Purchase Return"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'poppins'
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
             Container(
              color: white,
              padding:const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8
              ),
               child: Column(
                 children: [
                                       Row(
                                        children: [
                                            Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Text(
                                            ' Bill No',
                                            style: TextStyle(
                                                fontFamily: 'poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            width:
                                                MediaQuery.of(context).size.width,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                border: Border.all(color: grey),
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                            child: dataDynamic[0]['EntryNo'].toString().isEmpty
                                                ? const Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Icon(
                                                      Icons.arrow_drop_down_rounded,
                                                      color: grey,
                                                    ))
                                                : Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      dataDynamic[0]['EntryNo'].toString(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                          )
                                        ],
                                      )),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                          Expanded(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              const Text(
                                                ' Date',
                                                style: TextStyle(
                                                    fontFamily: 'poppins',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                               InkWell(
                                                onTap: () => _selectDate('f'),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  width:
                                                      MediaQuery.of(context).size.width,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: grey),
                                                      borderRadius:
                                                          BorderRadius.circular(3)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        formattedDate!,
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 13),
                                                      ),
                                                      const Icon(
                                                        Icons.calendar_month,
                                                        size: 18,
                                                        color: grey,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                                        
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                        Row(
                                        children: [
                                            Expanded(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              const Text(
                                                ' Inv.No',
                                                style: TextStyle(
                                                    fontFamily: 'poppins',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                             TextField(
                                decoration: const InputDecoration(
                                  constraints: BoxConstraints(
                                    maxHeight: 35
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 5
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                controller: invNoController,
                                // onChanged: (value) {
                                //   setState(() {
                                //     invNoController.text = value;
                                //   });
                                // },
                              ),
                                            ],
                                          )),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                           Expanded(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              const Text(
                                                ' Inv.Date',
                                                style: TextStyle(
                                                    fontFamily: 'poppins',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                              InkWell(
                                                onTap: () => _selectDate('t'),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  width:
                                                      MediaQuery.of(context).size.width,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: grey),
                                                      borderRadius:
                                                          BorderRadius.circular(3)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        invDate!,
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 13),
                                                      ),
                                                      const Icon(
                                                        Icons.calendar_month,
                                                        size: 18,
                                                        color: grey,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                                           ],
                                      ),
                 ],
               ),
             ),
             const SizedBox(
              height: 8,
             ),
             Container(
              color: white,
              padding:const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ' Customer',
                     style: TextStyle(
                     fontFamily: 'poppins',
                     fontSize: 14,
                     fontWeight: FontWeight.w500),
                   ),
                   const SizedBox(
                    height: 4,
                   ),
                     FutureBuilder<List<dynamic>>(
                                future: dio.getCustomerNameList(),
                                builder: (context, snapshot) {
                                  // if(snapshot.connectionState == ConnectionState.waiting){
                                  //  return CircularProgressIndicator();
                                  // }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData) {
                                    return const Text('No data found');
                                  }
                                    // snapshot.data = ledgerModel;
                                  final supplierList = snapshot.data;

                                  final names = supplierList!
                                      .map((e) => e.name)
                                      .where((name) => name != null)
                                      .cast<String>()
                                      .toList();

                                  return EasyAutocomplete(
                                    progressIndicatorBuilder: const Center(
                                            child: CircularProgressIndicator())
                                       ,
                                       controller: customerNameController,
                                    // controller: oldBill
                                    //     ? selectedSupplierId == acId
                                    //         ? TextEditingController(
                                    //             text: cashAc)
                                    //         : supplierController
                                    //     : supplierController,
                                    inputTextStyle: const TextStyle(
                                        fontFamily: 'poppins', fontSize: 14),
                                    suggestionTextStyle:
                                        const TextStyle(fontFamily: 'poppins'),
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 5),
                                        border: OutlineInputBorder()),
                                    suggestions: names,
                                    onChanged: (value) {
                                      // setState(() {
                                      //   query = value.isNotEmpty
                                      //       ? value.toLowerCase()
                                      //       : 'a';
                                      // });
                                    },
                                    onSubmitted: (value) {
                                      setState(() {
                                        final selectedSupplier =
                                            supplierList.firstWhere((element) =>
                                                element.name == value);
                                        selectedCustomerId =
                                            selectedSupplier.id;
                                          // ledgerModel = selectedSupplier ;
                                        // _isLoading = true;
                                        dio
                                            .getCustomerDetail(
                                                selectedCustomerId!)
                                            .then((value) {
                                          setState(() {
                                            ledgerModel = value;
                                            _isLoading = false;
                                          });
                                        });
                                      });
                                    },
                                  );
                                },
                              ),
                  //  EasyAutocomplete(
                  //   inputTextStyle: const TextStyle(
                  //     fontFamily: 'poppins',
                  //     fontSize: 14
                  //   ),
                  //   progressIndicatorBuilder: const CircularProgressIndicator() ,
                  //   decoration: const InputDecoration(
                  //     contentPadding: EdgeInsets.symmetric(
                  //       horizontal: 5,
                  //       vertical: 5
                  //     ),
                  //     border: OutlineInputBorder()
                  //   ),
                  //   asyncSuggestions: (searchValue) async {
                  //     return await fetchSuggestions(searchValue);
                  //   // final getCustomer =   dio.getCustomerNameList().then((value) => ledgerModel = value);
                  //   // final data = getCustomer;
                  //   // final nameList =   getCustomer.then((value) => value.map((e) => e.name).toList());
                  //   // return nameList;
                  //   },
                  //   suggestions: itemName,
                  //   onChanged: (text) {
                      
                  //   },
                  //   onSubmitted: (p0) {
                      
                  //   },
                  //  ),
                   const SizedBox(
                    height: 4,
                   ),
                    ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3))),
                                  onPressed: () {
                                    setState(() {
                                      editItem = false;
                                      nextWidget = 1;
                                    });
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // SizedBox(width: 10),
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
                                )
                ],
              ),
             ),
             const SizedBox(
              height: 8,
             ),
              cartItem.isNotEmpty
                          ? Container(
                               constraints: BoxConstraints(maxHeight: 300),
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
                                         nextWidget = 1;
                                         });
                                      //  setState(() {
                                      //       editItem = true;
                                      //   position = index;
                                      //   cartModel = cartItem.elementAt(position!);
                                      //   selectedProducteId = 
                                      //   cartModel!.id;
                                      //   productNameController.text =
                                      //   cartModel!.itemName!;
                                      //   rate = cartModel!.rate!;
                                      //   _rateController.text =
                                      //       cartModel!.rate.toString();
                                      //   _quantityController.text =
                                      //       cartModel!.quantity.toString();
                                      //       quantity = 
                                      //       cartModel!.quantity!;
                                      //   _quantityController.text =
                                      //       cartModel!.quantity.toString();
                                      //   _discountController.text =
                                      //       cartModel!.discount.toString();
                                      //   _discountPercentController.text =
                                      //       cartModel!.discountPercent.toString();
                                      //       gross = cartModel!.gross!;
                                      //       total = cartModel!.total!;
                                      //   // _serialNoController.text =
                                      //   //     cartModel.serialNo;
                                      //       nextWidget = 1;
                                      //  });
                                      
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
                                                      "${cartItem[index].quantity!.toStringAsFixed(0)} ${UnitSettings.getUnitName(cartItem[index].unitId!)} x ${('selectedTaxOption' == 'With Tax' ? cartItem[index].rate!.toStringAsFixed(2) : cartItem[index].rate!.toStringAsFixed(2))} = ₹ ${cartItem[index].gross}",
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
                                                        cartItem[index].discountPercent!
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
                            cartItem.isNotEmpty?
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
                                  Text('₹   ${CommonService.getRound(decimal, totalCartTotal).toStringAsFixed(decimal)}',style:const 
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
      bottomNavigationBar: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
             Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.grey,
                            onTap: () {
                    //           oldBill 
                    //           ? setState(() {
                    //               if (buttonEvent) {
                    //   return;
                    // } else {
                    //   if (totalItem > 0) {
                    //     if (companyUserData!.deleteData) {
                    //       setState(() {
                    //         _isLoading = true;
                    //       });
                    //       deleteSale();
                    //     } else {
                    //       Fluttertoast.showToast(
                    //           msg: 'Permission denied\ncan`t delete');
                    //       setState(() {
                    //         buttonEvent = false;
                    //       });
                    //     }
                    //   } else {
                    //     Fluttertoast.showToast(
                    //         msg: 'Please select atleast one bill');
                    //     setState(() {
                    //       buttonEvent = false;
                    //     });
                    //   }
                    // }
                    //           },)
                    //           : setState(() {
                                
                    //           },);
                            },
                            child: Container(
                              height: 60,
                              color: Colors.white,
                              child:  Center(
                                child: Text(
                                  oldBill ? 'Delete': 'Save & New',
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
                            splashColor: Colors.grey,
                            onTap: () {
                            
                            },
                            child: Container(
                              height: 60,
                              color: kPrimaryColor,
                              child:  Center(
                                child:Text(
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
      ),
    ),
  );
  }
  
  var selectedItem;
  String? selectedTaxOption = 'With Tax';
  dynamic productModelPrize;
  int? selectedProducteId; 
  addItemWidget(){
    List<UnitModel> unitList = [];
     calculate() {
      quantity = (controllerQuantity.text.isNotEmpty
          ? double.tryParse(controllerQuantity.text)
          : 0)!;
      rate = (controllerRate.text.isNotEmpty
          ? double.tryParse(controllerRate.text)
          : 0)!;
      discount = (controllerDiscount.text.isNotEmpty
          ? double.tryParse(controllerDiscount.text)
          : 0)!;
      discountPer = (controllerDiscountPer.text.isNotEmpty
          ? double.tryParse(controllerDiscountPer.text)
          : 0)!;
       if (_focusNodeDiscountPer.hasFocus) {
        controllerDiscount.text = controllerDiscountPer.text.isNotEmpty
        && selectedTaxOption == 'With Tax'
            ? (((quantity * rRate) * discountPer) / 100).toStringAsFixed(2)
            : (((quantity * rate) * discountPer) / 100).toStringAsFixed(2);
        discount = (controllerDiscount.text.isNotEmpty
            ? double.tryParse(controllerDiscount.text)
            : 0)!;
        discountPer = double.tryParse(controllerDiscountPer.text)?? 0;
      }
      if (_focusNodeDiscount.hasFocus) {
        controllerDiscountPer.text = controllerDiscount.text.isNotEmpty
        && selectedTaxOption == 'With Tax'
            ? ((discount * 100) / (quantity * rRate)).toStringAsFixed(2)
            : ((discount * 100) / (quantity * rate)).toStringAsFixed(2);
        discountPer = (controllerDiscount.text.isNotEmpty
            ? double.tryParse(controllerDiscountPer.text)
            : 0)!;
        double.tryParse(controllerDiscount.text);
        
      }    
      rRate = taxMethod == 'MINUS'
          ? CommonService.getRound(decimal, (100 * rate) / (100 + taxP))
          : rate;
      rDisc = taxMethod == 'MINUS'
          ? CommonService.getRound(decimal, ((discount * 100) / (taxP + 100)))
          : discount;
       gross = selectedTaxOption == 'With Tax'
        ? CommonService.getRound(decimal, ((rRate * quantity)))
        : CommonService.getRound(decimal, ((rate * quantity)));    
      // gross = CommonService.getRound(decimal, ((rRate * quantity)));
      subTotal = CommonService.getRound(decimal, (gross - rDisc));    
      // subTotal = CommonService.getRound(decimal, (rate * quantity));
      net = CommonService.getRound(decimal, (subTotal - discount));
      if (taxP > 0) {
        tax = CommonService.getRound(decimal, ((subTotal * taxP) / 100));
      }
      if (companyTaxMode == 'INDIA') {
        double csPer = taxP / 2;
        iGST = 0;
        csGST = CommonService.getRound(decimal, ((subTotal * csPer) / 100));
      } else if (companyTaxMode == 'GULF') {
        iGST = CommonService.getRound(decimal, ((subTotal * taxP) / 100));
        csGST = 0;
      } else {
        iGST = 0;
        csGST = 0;
        tax = 0;
      }
      total = CommonService.getRound(
          decimal, (net + csGST + csGST + iGST + cess + adCess));
      // total = net + tax;
      if (mrp > 0) {
        profitPer = realPRATEBASEDPROFITPERCENTAGE
            ? CommonService.getRound(decimal, (((mrp - rRate) * 100) / rRate))
            : CommonService.getRound(decimal, (((mrp - rate) * 100) / rate));
      }
      if (retail > 0) {
        retailPer = realPRATEBASEDPROFITPERCENTAGE
            ? CommonService.getRound(
                decimal, (((retail - rRate) * 100) / rRate))
            : CommonService.getRound(decimal, (((retail - rate) * 100) / rate));
      }
      if (wholeSale > 0) {
        wholesalePer = realPRATEBASEDPROFITPERCENTAGE
            ? CommonService.getRound(
                decimal, (((wholeSale - rRate) * 100) / rRate))
            : CommonService.getRound(
                decimal, (((wholeSale - rate) * 100) / rate));
      }
      if (spRetail > 0) {
        spRetailPer = realPRATEBASEDPROFITPERCENTAGE
            ? CommonService.getRound(
                decimal, (((spRetail - rRate) * 100) / rRate))
            : CommonService.getRound(
                decimal, (((spRetail - rate) * 100) / rate));
      }
      if (branch > 0) {
        branchPer = realPRATEBASEDPROFITPERCENTAGE
            ? CommonService.getRound(
                decimal, (((branch - rRate) * 100) / rRate))
            : CommonService.getRound(decimal, (((branch - rate) * 100) / rate));
      }

      // unitValue = _conversion > 0 ? _conversion : 1;
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bagroundColor,
        appBar: AppBar(
          title: const Text('Add Item'),
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontFamily: 'poppins',
          ),
          leading: IconButton(
            onPressed: (){
              setState(() {
                clearValue();
                nextWidget = 0;
              });
            }, icon: const Icon(Icons.arrow_back)),
        ),
        body: Column(
          children: [
            Container(
              padding:const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6
            ),
            color: white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Text(
                  ' Item Name',
                   style: TextStyle(
                   fontFamily: 'poppins',
                   fontSize: 14,
                   fontWeight: FontWeight.w500),
                 ),
                 const SizedBox(
                  height: 4,
                 ),
                 FutureBuilder(
  future: dio.fetchStockProduct(DateUtil.dateDMY2YMD(formattedDate)),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else if (!snapshot.hasData) {
      return const Text('No data found');
    }

    final purchasePr = snapshot.data;

    List<String> prName = purchasePr!
        .map((e) => e.name)
        .where((element) => element != null)
        .cast<String>()
        .toList();

    return EasyAutocomplete(
      inputTextStyle: const TextStyle(
      fontFamily: 'poppins',
      fontSize: 14),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(
        vertical: 5, horizontal: 5),
        border: OutlineInputBorder(),
      ),
      controller: productNameController,
      suggestions: prName,
      onChanged: (p0) {},
      onSubmitted: (value) async {
        clearValue();
        selectedItem = purchasePr.firstWhere(
        (element) => element.name == value,
        );

        productNameController.text = selectedItem.name;
        selectedProducteId = selectedItem.id;
        var sProducts = await dio.fetchStockVariant(selectedProducteId!);

        if (sProducts != null && sProducts.isNotEmpty) {
          var stockProduct = sProducts.first;
          taxP = stockProduct.tax!;
          cessPer = double.tryParse(stockProduct.cessPer.toString()) ?? 0.0;
          taxP = double.tryParse(stockProduct.tax.toString()) ?? 0.0;
          rate = double.tryParse(stockProduct.buyingPrice.toString()) ?? 0.0;
          
          if (rate > 0 && !editableRate) {
            controllerRate.text = rate.toString();
          }

          rRate = double.tryParse(stockProduct.buyingPriceReal.toString()) ?? 0.0;
          mrp = double.tryParse(stockProduct.sellingPrice.toString()) ?? 0.0;

          if (mrp > 0 && !editableMrp) {
            controllerMrp.text = mrp.toString();
          }

          retail = double.tryParse(stockProduct.retailPrice.toString()) ?? 0.0;

          if (retail > 0 && !editableRetail) {
            controllerRetail.text = retail.toString();
          }

          wholeSale = double.tryParse(stockProduct.wholeSalePrice.toString()) ?? 0.0;

          if (wholeSale > 0 && !editableWSale) {
            controllerWholeSale.text = wholeSale.toString();
          }

          spRetail = double.tryParse(stockProduct.spRetailPrice.toString()) ?? 0.0;
          branch = double.tryParse(stockProduct.branch.toString()) ?? 0.0;

          if (branch > 0 && !editableBranch) {
            controllerBranch.text = branch.toString();
          }
        } else {}
      },
    );
  },
),
const SizedBox(
  height: 4,
),

              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(' Quantity',
                              style: TextStyle(
                                             fontFamily: 'poppins',
                                             fontSize: 14,
                                             fontWeight: FontWeight.w500),),
                                             const SizedBox(
                                            height: 2,
                                           ),
                                            SizedBox(
                                height: 40,
                                child: TextFormField(
                                  controller: controllerQuantity,
                                  // focusNode: _focusNodeQuantity,
                                  textAlign: TextAlign.right,
                                  keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                        allow: true, replacementString: '.')
                                  ],
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5
                                    ),
                                      border: OutlineInputBorder(),),
                                  onChanged: (value) {
                                    setState(() {
                                      calculate();
                                    });
                                  },
                                ),
                              ),
                        ],
                      )
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                        Visibility(
                        visible: enableMULTIUNIT,
                        child: Expanded(
                          child: FutureBuilder(
                            future: dio.fetchUnitOf(selectedProducteId?? 0),
                            builder: (BuildContext context,
                                AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                unitList.clear();
                                for (var i = 0;
                                    i < snapshot.data.length;
                                    i++) {
                                  if (defaultUnitID.toString().isNotEmpty) {
                                    if (snapshot.data[i].id ==
                                        defaultUnitID! - 1) {
                                      _dropDownUnit = snapshot.data[i].id;
                                      conversion =
                                          snapshot.data[i].conversion;
                                    }
                                  }
                                  unitList.add(UnitModel(
                                      id: snapshot.data[i].id,
                                      itemId: snapshot.data[i].itemId,
                                      conversion: snapshot.data[i].conversion,
                                      name: snapshot.data[i].name,
                                      pUnit: snapshot.data[i].pUnit,
                                      sUnit: snapshot.data[i].sUnit,
                                      unit: snapshot.data[i].unit,
                                      rate: ''));
                                }
                              }
                              return snapshot.hasData
                                  ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        const Text(' Unit',
                                        style: TextStyle(
                                        fontFamily: 'poppins',
                                        fontSize: 14,
                                        color: black,
                                        fontWeight: FontWeight.w500),),
                                        const SizedBox(
                                        height: 2,
                                        ),
                                      Container(
                                        height: 40,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: grey),
                                          borderRadius: BorderRadius.circular(3)
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                              hint: Text(_dropDownUnit > 0
                                                  ? UnitSettings.getUnitName(
                                                      _dropDownUnit)
                                                  : 'SKU',
                                                  style: const TextStyle(
                                        fontFamily: 'poppins',
                                        fontSize: 14,
                                        color: black,
                                        fontWeight: FontWeight.w500),
                                                  ),
                                              items: snapshot.data
                                                  .map<DropdownMenuItem<String>>(
                                                      (item) {
                                                return DropdownMenuItem<String>(
                                                  value: item.id.toString(),
                                                  child: Text(item.name,style: const TextStyle(
                                        fontFamily: 'poppins',
                                        fontSize: 14,
                                        color: black,
                                        fontWeight: FontWeight.w500),),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _dropDownUnit =
                                                      int.tryParse(value!)!;
                                                  for (var i = 0;
                                                      i < unitList.length;
                                                      i++) {
                                                    UnitModel _unit = unitList[i];
                                                    if (_unit.unit ==
                                                        int.tryParse(value)) {
                                                      conversion = _unit.conversion!;
                                                      break;
                                                    }
                                                  }
                                                  calculate();
                                                });
                                              },
                                            ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : Container();
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 4,
              ),
                Row(
                    children: [
                      Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  const Text(' Price',
                            style: TextStyle(
                   fontFamily: 'poppins',
                   fontSize: 14,
                   fontWeight: FontWeight.w500),),
                   const SizedBox(
                    height: 2,
                   ),
                                TextField(
                                  controller: controllerRate,
                                  // focusNode: _focusNodeRate,
                                  textAlign: TextAlign.right,
                                  keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                        allow: true, replacementString: '.')
                                  ],
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsetsDirectional.symmetric(
                                      horizontal: 5,
                                      vertical: 5
                                    ), 
                                    constraints: BoxConstraints(
                                      maxHeight: 40
                                    ),
                                      border: OutlineInputBorder(),),
                                  onChanged: (value) {
                                    setState(() {
                                      calculate();
                                    });
                                  },
                                ),
                              ],
                            )),
                            const SizedBox(
                              width: 4,
                            ),
                            Expanded(child: 
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  ' Tax Option',
                                  style: TextStyle(
                                               fontFamily: 'poppins',
                                               fontSize: 14,
                                               fontWeight: FontWeight.w500),),
                                               const SizedBox(
                                                height: 2,
                                               ),
                                                            Container(
                                                              height: 40,
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
                                                      items: const [
                                                        DropdownMenuItem(
                                                          value: 'With Tax',
                                                          child: Text(
                                                              'With Tax'),
                                                        ),
                                                        DropdownMenuItem(
                                                          // enabled: salesTypeData!
                                                          //                 .id ==
                                                          //             1 ||
                                                          //         salesTypeData!
                                                          //                 .id ==
                                                          //             2
                                                          //     ? false
                                                          //     : true,
                                                          value:
                                                              'Without Tax',
                                                          child: Text(
                                                              'Without Tax'),
                                                        ),
                                                      ],
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedTaxOption = value!;
                                                          value == 'Without Tax' 
                                                              ? isTax = false
                                                              : isTax = true;
                                                          calculate();
                                                        });
                                                      },
                                                      isExpanded: true,
                                                    ),
                                                  ),
                                                ),
                              ],
                            )
                            )
                    ],
                  )
              ],
            ),
            ),
            const SizedBox(
              height: 8,
            ),
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
                                                        controllerDiscountPer,
                                                    focusNode:
                                                        _focusNodeDiscountPer,
                                                        textAlign: TextAlign.right,
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
                                                        calculate();
                                                      });
                                                    },
                                                    onSubmitted: (value) {
                                                      setState(() {
                                                        calculate();
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
                                                        controllerDiscount,
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
                                                        calculate();
                                                      });
                                                    },
                                                    onSubmitted: (value) {
                                                      setState(() {
                                                        calculate();
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
                                        SizedBox(
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
                                                  textAlign: TextAlign.right,
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
          ],
        ),
        bottomNavigationBar: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                     if (quantity <= 0) {
                      Fluttertoast.showToast(
                        backgroundColor: red,
                        msg: '0 Quantity Not Allowed');
                    }
                    else if(rate <= 0){
                       Fluttertoast.showToast(
                        backgroundColor: red,
                        msg: '0 Rate Not Allowed');
                    }
                    else{
                       setState(() {
                      unit ??= DataJson(id: 0, name: '');
                      rate = (controllerRate.text.isNotEmpty
                          ? double.tryParse(controllerRate.text)
                          : rate)!;
                      mrp = (controllerMrp.text.isNotEmpty
                          ? double.tryParse(controllerMrp.text)
                          : mrp)!;
                      retail = (controllerRetail.text.isNotEmpty
                          ? double.tryParse(controllerRetail.text)
                          : retail)!;
                      wholeSale = (controllerWholeSale.text.isNotEmpty
                          ? double.tryParse(controllerWholeSale.text)
                          : wholeSale)!;
                      // spRetail = controllerSPRetail.text.length>0? double.tryParse(controllerSPRetail.text):spRetail;
                      branch = (controllerBranch.text.isNotEmpty
                          ? double.tryParse(controllerBranch.text)
                          : branch)!;
                      quantity = (controllerQuantity.text.isNotEmpty
                          ? double.tryParse(controllerQuantity.text)
                          : quantity)!;

                      if (selectedItem.quantity! >= quantity) {
                        if (editItem) {
                          cartItem[position!].adCess = adCess;
                          cartItem[position!].barcode = barcode;
                          cartItem[position!].branch = branch;
                          cartItem[position!].branchPer = branchPer;
                          cartItem[position!].cDisc = cDisc;
                          cartItem[position!].cGST = csGST;
                          cartItem[position!].cdPer = cdPer;
                          cartItem[position!].cess = cess;
                          cartItem[position!].discount = discount;
                          cartItem[position!].discountPercent = discountPer;
                          // cartItem[position!].expDate = expDate;
                          // cartItem[position!].expense = expense;
                          cartItem[position!].fCess = fCess;
                          cartItem[position!].fUnitId = fUnitId;
                          cartItem[position!].fUnitValue = fUnitValue;
                          cartItem[position!].free = free;
                          cartItem[position!].gross = subTotal;
                          cartItem[position!].iGST = iGST;
                          // cartItem[position!].id = cartItem.length + 1;
                          // cartItem[position!].itemId = productModel['slno'];
                          // cartItem[position!].itemName = productModel['itemname'];
                          // cartItem[position!].location = locationId;
                          cartItem[position!].mrp = mrp;
                          cartItem[position!].mrpPer = mrpPer;
                          cartItem[position!].net = net;
                          cartItem[position!].profitPer = profitPer;
                          cartItem[position!].quantity = quantity;
                          cartItem[position!].rRate = rRate;
                          cartItem[position!].rate = rate;
                          cartItem[position!].retail = retail;
                          cartItem[position!].retailPer = retailPer;
                          cartItem[position!].sGST = csGST;
                          cartItem[position!].serialNo = serialNo;
                          cartItem[position!].spRetail = spRetail;
                          cartItem[position!].spRetailPer = spRetailPer;
                          cartItem[position!].tax = tax;
                          cartItem[position!].taxP = taxP;
                          cartItem[position!].total = total;
                          cartItem[position!].uniqueCode = uniqueCode;
                          // cartItem[position!].unitId = unit.id;
                          // cartItem[position!].unitName = unit.name;
                          cartItem[position!].unitValue = unitValue;
                          cartItem[position!].wholesale = wholeSale;
                          cartItem[position!].wholesalePer = wholesalePer;
                        } else {
                          cartItem.add(CartItemP(
                              adCess: adCess,
                              barcode: barcode,
                              branch: branch,
                              branchPer: branchPer,
                              cDisc: cDisc,
                              cGST: csGST,
                              cdPer: cdPer,
                              cess: cess,
                              discount: discount,
                              discountPercent: discountPer,
                              expDate: expDate,
                              expense: expense,
                              fCess: fCess,
                              fUnitId: fUnitId,
                              fUnitValue: fUnitValue,
                              free: free,
                              gross: subTotal,
                              iGST: iGST,
                              id: cartItem.length + 1,
                              itemId: selectedItem.id!,
                              itemName: selectedItem.name!,
                              location: locationId,
                              mrp: mrp,
                              mrpPer: mrpPer,
                              net: net,
                              profitPer: profitPer,
                              quantity: quantity,
                              rRate: rRate,
                              rate: rate,
                              retail: retail,
                              retailPer: retailPer,
                              sGST: csGST,
                              serialNo: serialNo,
                              spRetail: spRetail,
                              spRetailPer: spRetailPer,
                              tax: tax,
                              taxP: taxP,
                              total: total,
                              uniqueCode: uniqueCode,
                              unitId: unit.id!,
                              unitName: unit.name,
                              unitValue: unitValue,
                              wholesale: wholeSale,
                              wholesalePer: wholesalePer,
                              estUniqueCode: 0,
                              brand: 0,
                              company: 0,
                              size: 0,
                              color: 0,
                              expenseQty: 0));
                        }
                        if (cartItem.isNotEmpty) {
                          // nextWidget = 0;
                          editItem = false;
                          clearValue();
                          calculateTotal();
                        }
                      } else {
                        showInSnackBar('Available Qty is ${selectedItem.quantity}');
                      }
                    });
                    }
                  },
                  child: Container(
                            height: 60,
                            color: Colors.white,
                            child: Center(
                              child: Text(editItem ? 'Delete' :'Save & New',
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
              Expanded(
                child:InkWell(
                  onTap: () {
                    if (quantity <= 0) {
                      Fluttertoast.showToast(
                        backgroundColor: red,
                        msg: '0 Quantity Not Allowed');
                    }
                    else if(rate <= 0){
                       Fluttertoast.showToast(
                        backgroundColor: red,
                        msg: '0 Rate Not Allowed');
                    }
                    else{
                       setState(() {
                      unit ??= DataJson(id: 0, name: '');
                      rate = (controllerRate.text.isNotEmpty
                          ? double.tryParse(controllerRate.text)
                          : rate)!;
                      mrp = (controllerMrp.text.isNotEmpty
                          ? double.tryParse(controllerMrp.text)
                          : mrp)!;
                      retail = (controllerRetail.text.isNotEmpty
                          ? double.tryParse(controllerRetail.text)
                          : retail)!;
                      wholeSale = (controllerWholeSale.text.isNotEmpty
                          ? double.tryParse(controllerWholeSale.text)
                          : wholeSale)!;
                      // spRetail = controllerSPRetail.text.length>0? double.tryParse(controllerSPRetail.text):spRetail;
                      branch = (controllerBranch.text.isNotEmpty
                          ? double.tryParse(controllerBranch.text)
                          : branch)!;
                      quantity = (controllerQuantity.text.isNotEmpty
                          ? double.tryParse(controllerQuantity.text)
                          : quantity)!;

                      if (selectedItem.quantity! >= quantity) {
                        if (editItem) {
                          cartItem[position!].adCess = adCess;
                          cartItem[position!].barcode = barcode;
                          cartItem[position!].branch = branch;
                          cartItem[position!].branchPer = branchPer;
                          cartItem[position!].cDisc = cDisc;
                          cartItem[position!].cGST = csGST;
                          cartItem[position!].cdPer = cdPer;
                          cartItem[position!].cess = cess;
                          cartItem[position!].discount = discount;
                          cartItem[position!].discountPercent = discountPer;
                          // cartItem[position!].expDate = expDate;
                          // cartItem[position!].expense = expense;
                          cartItem[position!].fCess = fCess;
                          cartItem[position!].fUnitId = fUnitId;
                          cartItem[position!].fUnitValue = fUnitValue;
                          cartItem[position!].free = free;
                          cartItem[position!].gross = subTotal;
                          cartItem[position!].iGST = iGST;
                          // cartItem[position!].id = cartItem.length + 1;
                          // cartItem[position!].itemId = productModel['slno'];
                          // cartItem[position!].itemName = productModel['itemname'];
                          // cartItem[position!].location = locationId;
                          cartItem[position!].mrp = mrp;
                          cartItem[position!].mrpPer = mrpPer;
                          cartItem[position!].net = net;
                          cartItem[position!].profitPer = profitPer;
                          cartItem[position!].quantity = quantity;
                          cartItem[position!].rRate = rRate;
                          cartItem[position!].rate = rate;
                          cartItem[position!].retail = retail;
                          cartItem[position!].retailPer = retailPer;
                          cartItem[position!].sGST = csGST;
                          cartItem[position!].serialNo = serialNo;
                          cartItem[position!].spRetail = spRetail;
                          cartItem[position!].spRetailPer = spRetailPer;
                          cartItem[position!].tax = tax;
                          cartItem[position!].taxP = taxP;
                          cartItem[position!].total = total;
                          cartItem[position!].uniqueCode = uniqueCode;
                          // cartItem[position!].unitId = unit.id;
                          // cartItem[position!].unitName = unit.name;
                          cartItem[position!].unitValue = unitValue;
                          cartItem[position!].wholesale = wholeSale;
                          cartItem[position!].wholesalePer = wholesalePer;
                        } else {
                          cartItem.add(CartItemP(
                              adCess: adCess,
                              barcode: barcode,
                              branch: branch,
                              branchPer: branchPer,
                              cDisc: cDisc,
                              cGST: csGST,
                              cdPer: cdPer,
                              cess: cess,
                              discount: discount,
                              discountPercent: discountPer,
                              expDate: expDate,
                              expense: expense,
                              fCess: fCess,
                              fUnitId: fUnitId,
                              fUnitValue: fUnitValue,
                              free: free,
                              gross: subTotal,
                              iGST: iGST,
                              id: cartItem.length + 1,
                              itemId: selectedItem.id!,
                              itemName: selectedItem.name!,
                              location: locationId,
                              mrp: mrp,
                              mrpPer: mrpPer,
                              net: net,
                              profitPer: profitPer,
                              quantity: quantity,
                              rRate: rRate,
                              rate: rate,
                              retail: retail,
                              retailPer: retailPer,
                              sGST: csGST,
                              serialNo: serialNo,
                              spRetail: spRetail,
                              spRetailPer: spRetailPer,
                              tax: tax,
                              taxP: taxP,
                              total: total,
                              uniqueCode: uniqueCode,
                              unitId: unit.id!,
                              unitName: unit.name,
                              unitValue: unitValue,
                              wholesale: wholeSale,
                              wholesalePer: wholesalePer,
                              estUniqueCode: 0,
                              brand: 0,
                              company: 0,
                              size: 0,
                              color: 0,
                              expenseQty: 0));
                        }
                        if (cartItem.isNotEmpty) {
                          nextWidget = 0;
                          editItem = false;
                          clearValue();
                          calculateTotal();
                        }
                      } else {
                        showInSnackBar('Available Qty is ${selectedItem.quantity}');
                      }
                    });
                    }
                  },
                  child: Container(
                            height: 60,
                            color: kPrimaryColor,
                            child:  Center(
                              child: Text('Save',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                ), )
            ],
          ),
        ),
      ),
    );
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
                return Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text(dataDisplay[index]['Name']),
                    subtitle: Text('Date: ' +
                        dataDisplay[index]['Date'] +
                        ' / EntryNo : ' +
                        dataDisplay[index]['Id'].toString()),
                    trailing: Text(
                        'Total : ' + dataDisplay[index]['Total'].toString()),
                    onTap: () {
                      showEditDialog(context, dataDisplay[index]);
                    },
                  ),
                );
              }
            },
            controller: _scrollController,
          )
        : Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("No items in Purchase Return",
              style: TextStyle(fontFamily: 'poppins'),
              ),
              TextButton.icon(
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    )),
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
                  label: const Text('Take New Purchase Return',
                  style: TextStyle(fontFamily: 'poppins'),))
            ],
          ));
  }

  bool isData = false;

  selectLedgerWidget() {
    setState(() {
      if (_ledger.isNotEmpty) isData = true;
    });
    return FutureBuilder<List<dynamic>>(
      future: dio.getSalesListData('', 'sales_list/supplier'),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            if (!isData) {
              ledgerDisplay = data!;
              _ledger = data;
            }
            return ListView.builder(
              // shrinkWrap: true,
              itemBuilder: (context, index) {
                return index == 0
                    ? Container(
                        color: bagroundColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: white,
                            child: Row(
                              children: [
                                Flexible(
                                  child: SizedBox(
                                    height: 50,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        label: Text(
                                          'Search...',
                                          style:
                                              TextStyle(fontFamily: 'poppins'),
                                        ),
                                      ),
                                      onChanged: (text) {
                                        text = text.toLowerCase();
                                        setState(() {
                                          ledgerDisplay = _ledger.where((item) {
                                            var itemName =
                                                item.name.toLowerCase();
                                            return itemName.contains(text);
                                          }).toList();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    isData = false;
                                    Navigator.pushReplacementNamed(
                                        context, '/ledger',
                                        arguments: {'parent': 'SUPPLIERS'});
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: kPrimaryColor),
                                    child: const Icon(
                                      Icons.add,
                                      color: white,
                                    ),
                                  ),
                                ),
                                // IconButton(
                                //   icon: const Icon(
                                //     Icons.add_circle,
                                //     color: kPrimaryColor,
                                //   ),
                                //   onPressed: () {
                                //     isData = false;
                                //     Navigator.pushReplacementNamed(
                                //         context, '/ledger',
                                //         arguments: {'parent': 'SUPPLIERS'});
                                //   },
                                // )
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: bagroundColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                ledgerModel = ledgerDisplay[index - 1];
                                nextWidget = 1;
                                isData = false;
                              });
                            },
                            child: Container(
                                padding: const EdgeInsets.all(5),
                                color: white,
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: grey),
                                      borderRadius: BorderRadius.circular(3)),
                                  child: ListTile(
                                      title: Text(
                                    ledgerDisplay[index - 1].name,
                                    style:
                                        const TextStyle(fontFamily: 'poppins'),
                                  )),
                                )
                                // InkWell(
                                //   child: Card(
                                //     child: ListTile(
                                //         title: Text(ledgerDisplay[index - 1].name)),
                                //   ),
                                //   onTap: () {
                                //     setState(() {
                                //       ledgerModel = ledgerDisplay[index - 1];
                                //       nextWidget = 1;
                                //       isData = false;
                                //     });
                                //   },
                                // ),
                                ),
                          ),
                        ),
                      );
              },
              itemCount: ledgerDisplay.length + 1,
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [SizedBox(height: 20), Text('No Data Found..')],
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('This may take some time..')
            ],
          ),
        );
      },
    );
  }

  purchaseHeaderWidget() {
    return Center(
        child: Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            itemCount: 1,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'poppins',
                                  fontSize: 15),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            InkWell(
                              child: Container(
                                width: MediaQuery.sizeOf(context).width / 2,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                height: 40,
                                decoration: BoxDecoration(
                                    border: Border.all(color: grey),
                                    borderRadius: BorderRadius.circular(3)),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formattedDate!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'poppins'),
                                      ),
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        color: grey,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () => _selectDate('f'),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            Container(
                              width: 120,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: kPrimaryColor),
                              child: Row(
                                children: [
                                  Checkbox(
                                    checkColor: kPrimaryColor,
                                    activeColor: white,
                                    side: const BorderSide(color: white),
                                    value: isTax,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isTax = value!;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'Tax',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: white,
                                        fontFamily: 'poppins'),
                                  ),
                                ],
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
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Inv.No',
                              style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width / 2,
                              height: 40,
                              child: TextField(
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 8
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                controller: invNoController,
                                // onChanged: (value) {
                                //   setState(() {
                                //     invNoController.text = value;
                                //   });
                                // },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Inv.Date',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              InkWell(
                                child: Container(
                                    width: MediaQuery.sizeOf(context).width / 2,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: grey),
                                        borderRadius: BorderRadius.circular(3)),
                                    child: Center(
                                        child: Text(
                                      invDate!,
                                      style: const TextStyle(
                                          fontFamily: 'poppins',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ))),
                                onTap: () => _selectDate('t'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 40,
                      decoration: BoxDecoration(
                          border: Border.all(width: .4, color: grey),
                          borderRadius: BorderRadius.circular(5)),
                      child: Center(
                        child: Text(ledgerModel.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor)),
                      ),
                    )
                    // ListTile(
                    //   title:
                    // ),
                  ],
                ),
              );
            }),
        InkWell(
            child: Container(
              width: 110,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3), color: kPrimaryColor),
              height: 40,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.add,
                    color: white,
                  ),
                  Text(
                    'Add Item',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      color: white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              setState(() {
                nextWidget = 2;
              });
            }),
      ],
    ));
  }

  bool isItemData = false;
  selectProductWidget() {
    setState(() {
      if (items.isNotEmpty) isItemData = true;
    });
    return FutureBuilder<List<StockItem>>(
      future: dio.fetchStockProduct(DateUtil.dateDMY2YMD(formattedDate)),
      builder: (ctx, snapshot) {
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
                    ? Container(
                        color: bagroundColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Container(
                            color: white,
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Flexible(
                                  child: SizedBox(
                                    height: 50,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        label: Text(
                                          'Search...',
                                          style:
                                              TextStyle(fontFamily: 'poppins'),
                                        ),
                                      ),
                                      onChanged: (text) {
                                        text = text.toLowerCase();
                                        setState(() {
                                          itemDisplay = items.where((item) {
                                            var itemName =
                                                item.name.toLowerCase();
                                            return itemName.contains(text);
                                          }).toList();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      items = [];
                                      itemDisplay = [];
                                      isItemData = false;
                                    });
                                    Navigator.pushNamed(context, '/product');
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: kPrimaryColor),
                                    child: const Icon(
                                      Icons.add,
                                      color: white,
                                    ),
                                  ),
                                ),
                                // IconButton(
                                //   icon: const Icon(
                                //     Icons.add_circle,
                                //     color: kPrimaryColor,
                                //   ),
                                //   onPressed: () {
                                //     setState(() {
                                //       items = [];
                                //       itemDisplay = [];
                                //       isItemData = false;
                                //     });
                                //     Navigator.pushNamed(context, '/product');
                                //   },
                                // )
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: bagroundColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                productModel = itemDisplay[index - 1];
                                nextWidget = 3;
                                isItemData = false;
                              });
                            },
                            child: Container(
                                padding: const EdgeInsets.all(5),
                                color: white,
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: grey),
                                      borderRadius: BorderRadius.circular(3)),
                                  child: ListTile(
                                    title: Text(
                                      itemDisplay[index - 1].name,
                                      style: const TextStyle(
                                          fontFamily: 'poppins'),
                                    ),
                                    trailing: Text(
                                        'Qty :${itemDisplay[index - 1].quantity}'),
                                  ),
                                )),
                          ),
                        ),
                      );
                //  InkWell(
                //     child: Card(
                //       child: ListTile(
                //         title: Text(itemDisplay[index - 1].name),
                //         trailing:
                //             Text('Qty :${itemDisplay[index - 1].quantity}'),
                //       ),
                //     ),
                //     onTap: () {
                //       setState(() {
                //         productModel = itemDisplay[index - 1];
                //         nextWidget = 3;
                //         isItemData = false;
                //       });
                //     },
                //   );
              },
              itemCount: itemDisplay.length + 1,
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [SizedBox(height: 20), Text('No Data Found..')],
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('This may take some time..')
            ],
          ),
        );
      },
    );
  }

  itemDetailWidget() {
    return productModel!.hasVariant!
        ? showVariantDialog(productModel!.id!, productModel!.name!,
            productModel!.quantity.toString())
        : selectStockLedger();
  }

  selectStockLedger() {
    return FutureBuilder(
        future: dio.fetchStockVariant(productModel!.id!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.length > 0) {
              return itemDetails(snapshot.data![0]);
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text('Stock Ledger Data Missing...'),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            nextWidget = 2;
                          });
                        },
                        child: const Text('Select Product Again'))
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('This may take some time..')
              ],
            ),
          );
        });
  }

  bool isVariantSelected = false;
  int positionID = 0;
  showVariantDialog(int id, String name, String quantity) {
    return FutureBuilder<List<StockProduct>>(
      future: dio.fetchStockVariant(id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            return isVariantSelected
                ? itemDetails(snapshot.data![positionID])
                : keyItemsVariantStock
                    ? SizedBox(
                        height: deviceSize!.height - 20,
                        width: 400.0,
                        child: ListView(children: [
                          Center(child: Text(name + ' / ' + quantity)),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                elevation: 5,
                                child: ListTile(
                                    title: Text(
                                        'Id: ${snapshot.data![index].productId} / Quantity : ${snapshot.data![index].quantity} '),
                                    subtitle: Text(ComSettings.appSettings(
                                            'bool',
                                            'key-item-sale-retail',
                                            false)
                                        ? 'Mrp : ${snapshot.data![index].sellingPrice} / Retail : ${snapshot.data![index].retailPrice}'
                                        : 'Rate : ${snapshot.data![index].sellingPrice}'),
                                    onTap: () {
                                      setState(() {
                                        isVariantSelected = true;
                                        positionID = index;
                                      });
                                    }),
                              );
                            },
                          ),
                        ]),
                      )
                    : itemDetails(snapshot.data![0]);
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('This may take some time..')
            ],
          ),
        );
      },
    );
  }

  TextEditingController controllerQuantity = TextEditingController();
  TextEditingController controllerRate = TextEditingController();
  TextEditingController controllerDiscountPer = TextEditingController();
  TextEditingController controllerDiscount = TextEditingController();
  TextEditingController controllerMrp = TextEditingController();
  TextEditingController controllerRetail = TextEditingController();
  TextEditingController controllerWholeSale = TextEditingController();
  TextEditingController controllerBranch = TextEditingController();
   FocusNode _focusNodeQuantity = FocusNode();
  FocusNode _focusNodeRate = FocusNode();
  FocusNode _focusNodeDiscount = FocusNode();
  FocusNode _focusNodeDiscountPer = FocusNode();

  double quantity = 0,
      rate = 0,
      subTotal = 0,
      gross = 0,
      discount = 0,
      discountPer = 0,
      net = 0,
      tax = 0,
      total = 0,
      mrp = 0,
      retail = 0,
      wholeSale = 0,
      branch = 0,
      taxP = 0,
      rDisc = 0,
      rRate = 0,
      rateOff = 0,
      kfcP = 0,
      fCess = 0,
      unitValue = 1,
      conversion = 0,
      free = 0,
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
      expense = 0,
      mrpPer = 0,
      wholesalePer = 0,
      retailPer = 0,
      spRetail = 0,
      spRetailPer = 0,
      branchPer = 0;
  String expDate = '1900-01-01', serialNo = '';
  var unit;
  int uniqueCode = 0, fUnitId = 0, barcode = 0;
  bool editableMrp = false,
      editableRetail = false,
      editableWSale = false,
      editableBranch = false,
      editableRate = false,
      editableQuantity = false,
      editableDiscount = false,
      editableDiscountP = false;

  itemDetails(StockProduct product) {
    uniqueCode = product.productId!;
    barcode = product.productId!;
    if (editItem) {
      taxP = cartItem.elementAt(position!).taxP;
      quantity = cartItem[position!].quantity;
      if (quantity > 0 && !editableQuantity) {
        controllerQuantity.text = quantity.toString();
      }
      rate = cartItem.elementAt(position!).rate;
      if (rate > 0 && !editableRate) {
        controllerRate.text = rate.toString();
      }
      if (cartItem.elementAt(position!).rRate > 0) {
        rRate = cartItem.elementAt(position!).rRate;
      }
      mrp = cartItem.elementAt(position!).mrp;
      if (mrp > 0 && !editableMrp) {
        controllerMrp.text = mrp.toString();
      }
      retail = cartItem.elementAt(position!).retail;
      if (retail > 0 && !editableRetail) {
        controllerRetail.text = retail.toString();
      }
      wholeSale = cartItem.elementAt(position!).wholesale;
      if (wholeSale > 0 && !editableWSale) {
        controllerWholeSale.text = wholeSale.toString();
      }
      spRetail = cartItem.elementAt(position!).spRetail;
      branch = cartItem.elementAt(position!).branch;
      if (branch > 0 && !editableBranch) {
        controllerBranch.text = branch.toString();
      }
      discount = cartItem.elementAt(position!).discount;
      if (discount > 0 && !editableDiscount) {
        controllerDiscount.text = discount.toString();
      }
      discountPer = cartItem.elementAt(position!).discountPercent;
      if (discountPer > 0 && !editableDiscountP) {
        controllerDiscountPer.text = discountPer.toString();
      }
      subTotal = cartItem.elementAt(position!).gross;
      net = cartItem.elementAt(position!).net;
      if (taxP > 0) {
        tax = cartItem.elementAt(position!).tax;
        iGST = cartItem.elementAt(position!).iGST;
        csGST = cartItem.elementAt(position!).cGST;
      } else {
        iGST = 0;
        csGST = 0;
        tax = 0;
      }
      total = cartItem.elementAt(position!).total;
    } else {
      adCessPer = double.tryParse(product.adCessPer.toString())!;
      cessPer = double.tryParse(product.cessPer.toString())!;
      taxP = double.tryParse(product.tax.toString())!;
      // kfcP = double.tryParse(product.kfc.toString())!;
      rate = double.tryParse(product.buyingPrice.toString())!;
      if (rate > 0 && !editableRate) {
        controllerRate.text = rate.toString();
      }
      if (double.tryParse(product.buyingPriceReal.toString())! > 0) {
        rRate = double.tryParse(product.buyingPriceReal.toString())!;
      }
      mrp = double.tryParse(product.sellingPrice.toString())!;
      if (mrp > 0 && !editableMrp) {
        controllerMrp.text = mrp.toString();
      }
      retail = double.tryParse(product.retailPrice.toString())!;
      if (retail > 0 && !editableRetail) {
        controllerRetail.text = retail.toString();
      }
      wholeSale = double.tryParse(product.wholeSalePrice.toString())!;
      if (wholeSale > 0 && !editableWSale) {
        controllerWholeSale.text = wholeSale.toString();
      }
      spRetail = double.tryParse(product.spRetailPrice.toString())!;
      branch = double.tryParse(product.branch.toString())!;
      if (branch > 0 && !editableBranch) {
        controllerBranch.text = branch.toString();
      }
    }

    calculate() {
      quantity = (controllerQuantity.text.isNotEmpty
          ? double.tryParse(controllerQuantity.text)
          : 0)!;
      rate = (controllerRate.text.isNotEmpty
          ? double.tryParse(controllerRate.text)
          : 0)!;
      discount = (controllerDiscount.text.isNotEmpty
          ? double.tryParse(controllerDiscount.text)
          : 0)!;
      discountPer = (controllerDiscountPer.text.isNotEmpty
          ? double.tryParse(controllerDiscountPer.text)
          : 0)!;
      rRate = taxMethod == 'MINUS'
          ? CommonService.getRound(decimal, (100 * rate) / (100 + taxP))
          : rate;
      rDisc = taxMethod == 'MINUS'
          ? CommonService.getRound(decimal, ((discount * 100) / (taxP + 100)))
          : discount;
      subTotal = CommonService.getRound(decimal, (rate * quantity));
      net = CommonService.getRound(decimal, (subTotal - discount));
      if (taxP > 0) {
        tax = CommonService.getRound(decimal, ((subTotal * taxP) / 100));
      }
      if (companyTaxMode == 'INDIA') {
        double csPer = taxP / 2;
        iGST = 0;
        csGST = CommonService.getRound(decimal, ((subTotal * csPer) / 100));
      } else if (companyTaxMode == 'GULF') {
        iGST = CommonService.getRound(decimal, ((subTotal * taxP) / 100));
        csGST = 0;
      } else {
        iGST = 0;
        csGST = 0;
        tax = 0;
      }
      total = CommonService.getRound(
          decimal, (net + csGST + csGST + iGST + cess + adCess));
      // total = net + tax;
      if (mrp > 0) {
        profitPer = realPRATEBASEDPROFITPERCENTAGE
            ? CommonService.getRound(decimal, (((mrp - rRate) * 100) / rRate))
            : CommonService.getRound(decimal, (((mrp - rate) * 100) / rate));
      }
      if (retail > 0) {
        retailPer = realPRATEBASEDPROFITPERCENTAGE
            ? CommonService.getRound(
                decimal, (((retail - rRate) * 100) / rRate))
            : CommonService.getRound(decimal, (((retail - rate) * 100) / rate));
      }
      if (wholeSale > 0) {
        wholesalePer = realPRATEBASEDPROFITPERCENTAGE
            ? CommonService.getRound(
                decimal, (((wholeSale - rRate) * 100) / rRate))
            : CommonService.getRound(
                decimal, (((wholeSale - rate) * 100) / rate));
      }
      if (spRetail > 0) {
        spRetailPer = realPRATEBASEDPROFITPERCENTAGE
            ? CommonService.getRound(
                decimal, (((spRetail - rRate) * 100) / rRate))
            : CommonService.getRound(
                decimal, (((spRetail - rate) * 100) / rate));
      }
      if (branch > 0) {
        branchPer = realPRATEBASEDPROFITPERCENTAGE
            ? CommonService.getRound(
                decimal, (((branch - rRate) * 100) / rRate))
            : CommonService.getRound(decimal, (((branch - rate) * 100) / rate));
      }

      // unitValue = _conversion > 0 ? _conversion : 1;
    }

    calculateRate() {
      mrp = (controllerMrp.text.isNotEmpty
          ? double.tryParse(controllerMrp.text)
          : 0)!;
      retail = (controllerRetail.text.isNotEmpty
          ? double.tryParse(controllerRetail.text)
          : 0)!;
      wholeSale = (controllerWholeSale.text.isNotEmpty
          ? double.tryParse(controllerWholeSale.text)
          : 0)!;
      branch = (controllerBranch.text.isNotEmpty
          ? double.tryParse(controllerBranch.text)
          : 0)!;
      rate = (controllerRate.text.isNotEmpty
          ? double.tryParse(controllerRate.text)
          : 0)!;
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Item',
                  style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.only(top: 8, left: 5),
                width: MediaQuery.sizeOf(context).width,
                height: 45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: grey)),
                child: Text(
                  '${editItem ? cartItem.elementAt(position!).itemName : product.name}',
                  style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () {
                      setState(() {
                        editItem = false;
                        nextWidget = 2;
                      });
                    },
                    child: const Text(
                      "Back",
                      style: TextStyle(fontFamily: 'poppins', color: white),
                    ),
                  )),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () {
                      setState(() {
                        editItem = false;
                        nextWidget = 4;
                        clearValue();
                      });
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontFamily: 'poppins', color: white),
                    ),
                  )),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () {
                      setState(() {
                        unit ??= DataJson(id: 0, name: '');
                        rate = (controllerRate.text.isNotEmpty
                            ? double.tryParse(controllerRate.text)
                            : rate)!;
                        mrp = (controllerMrp.text.isNotEmpty
                            ? double.tryParse(controllerMrp.text)
                            : mrp)!;
                        retail = (controllerRetail.text.isNotEmpty
                            ? double.tryParse(controllerRetail.text)
                            : retail)!;
                        wholeSale = (controllerWholeSale.text.isNotEmpty
                            ? double.tryParse(controllerWholeSale.text)
                            : wholeSale)!;
                        // spRetail = controllerSPRetail.text.length>0? double.tryParse(controllerSPRetail.text):spRetail;
                        branch = (controllerBranch.text.isNotEmpty
                            ? double.tryParse(controllerBranch.text)
                            : branch)!;
                        quantity = (controllerQuantity.text.isNotEmpty
                            ? double.tryParse(controllerQuantity.text)
                            : quantity)!;
      
                        if (product.quantity! >= quantity) {
                          if (editItem) {
                            cartItem[position!].adCess = adCess;
                            cartItem[position!].barcode = barcode;
                            cartItem[position!].branch = branch;
                            cartItem[position!].branchPer = branchPer;
                            cartItem[position!].cDisc = cDisc;
                            cartItem[position!].cGST = csGST;
                            cartItem[position!].cdPer = cdPer;
                            cartItem[position!].cess = cess;
                            cartItem[position!].discount = discount;
                            cartItem[position!].discountPercent = discountPer;
                            // cartItem[position!].expDate = expDate;
                            // cartItem[position!].expense = expense;
                            cartItem[position!].fCess = fCess;
                            cartItem[position!].fUnitId = fUnitId;
                            cartItem[position!].fUnitValue = fUnitValue;
                            cartItem[position!].free = free;
                            cartItem[position!].gross = subTotal;
                            cartItem[position!].iGST = iGST;
                            // cartItem[position!].id = cartItem.length + 1;
                            // cartItem[position!].itemId = productModel['slno'];
                            // cartItem[position!].itemName = productModel['itemname'];
                            // cartItem[position!].location = locationId;
                            cartItem[position!].mrp = mrp;
                            cartItem[position!].mrpPer = mrpPer;
                            cartItem[position!].net = net;
                            cartItem[position!].profitPer = profitPer;
                            cartItem[position!].quantity = quantity;
                            cartItem[position!].rRate = rRate;
                            cartItem[position!].rate = rate;
                            cartItem[position!].retail = retail;
                            cartItem[position!].retailPer = retailPer;
                            cartItem[position!].sGST = csGST;
                            cartItem[position!].serialNo = serialNo;
                            cartItem[position!].spRetail = spRetail;
                            cartItem[position!].spRetailPer = spRetailPer;
                            cartItem[position!].tax = tax;
                            cartItem[position!].taxP = taxP;
                            cartItem[position!].total = total;
                            cartItem[position!].uniqueCode = uniqueCode;
                            // cartItem[position!].unitId = unit.id;
                            // cartItem[position!].unitName = unit.name;
                            cartItem[position!].unitValue = unitValue;
                            cartItem[position!].wholesale = wholeSale;
                            cartItem[position!].wholesalePer = wholesalePer;
                          } else {
                            cartItem.add(CartItemP(
                                adCess: adCess,
                                barcode: barcode,
                                branch: branch,
                                branchPer: branchPer,
                                cDisc: cDisc,
                                cGST: csGST,
                                cdPer: cdPer,
                                cess: cess,
                                discount: discount,
                                discountPercent: discountPer,
                                expDate: expDate,
                                expense: expense,
                                fCess: fCess,
                                fUnitId: fUnitId,
                                fUnitValue: fUnitValue,
                                free: free,
                                gross: subTotal,
                                iGST: iGST,
                                id: cartItem.length + 1,
                                itemId: product.itemId!,
                                itemName: product.name!,
                                location: locationId,
                                mrp: mrp,
                                mrpPer: mrpPer,
                                net: net,
                                profitPer: profitPer,
                                quantity: quantity,
                                rRate: rRate,
                                rate: rate,
                                retail: retail,
                                retailPer: retailPer,
                                sGST: csGST,
                                serialNo: serialNo,
                                spRetail: spRetail,
                                spRetailPer: spRetailPer,
                                tax: tax,
                                taxP: taxP,
                                total: total,
                                uniqueCode: uniqueCode,
                                unitId: unit.id,
                                unitName: unit.name,
                                unitValue: unitValue,
                                wholesale: wholeSale,
                                wholesalePer: wholesalePer,
                                estUniqueCode: 0,
                                brand: 0,
                                company: 0,
                                size: 0,
                                color: 0,
                                expenseQty: 0));
                          }
                          if (cartItem.isNotEmpty) {
                            nextWidget = 4;
                            editItem = false;
                            clearValue();
                          }
                        } else {
                          showInSnackBar('Available Qty is ${product.quantity}');
                        }
                      });
                    },
                    child: Text(
                      editItem ? "Edit" : "Add",
                      style: const TextStyle(fontFamily: 'poppins', color: white),
                    ),
                  )),
                  const SizedBox(
                    width: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ContainerFieldWidget(
                  widget: TextField(
                    controller: controllerQuantity,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10
                      ),
                        border: const OutlineInputBorder(),
                        labelStyle: const TextStyle(color: grey),
                        labelText: 'Available Quantity is ${product.quantity}'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          allow: true, replacementString: '.')
                    ],
                    onChanged: (value) {
                      setState(() {
                        editableQuantity = true;
                        quantity = double.tryParse(value)?? 0;
                        calculate();
                      });
                    },
                  ),
                  headTxt: 'Quantity'),
              const SizedBox(
                height: 10,
              ),
              ContainerFieldWidget(
                  widget: DropdownSearch<dynamic>(
                    popupProps: const PopupPropsMultiSelection.modalBottomSheet(
                        showSearchBox: true,
                        constraints: BoxConstraints(
                          maxHeight: 300,
                        )),
                    asyncItems: (String filter) =>
                        dio.getSalesListData(filter, 'sales_list/unit'),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                         contentPadding: EdgeInsets.symmetric(
                        horizontal: 10
                      ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    onChanged: (dynamic data) {
                      unit = data;
                      calculate();
                    },
                  ),
                  headTxt: 'Select Unit'),
              const SizedBox(
                height: 10,
              ),
              ContainerFieldWidget(
                  widget: TextField(
                    controller: controllerRate,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          allow: true, replacementString: '.')
                    ],
                    onChanged: (value) {
                      setState(() {
                        editableRate = true;
                        rate = double.tryParse(value)?? 0;
                        calculate();
                      });
                    },
                  ),
                  headTxt: 'P Rate'),
              const SizedBox(
                height: 10,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     const Text('Subtotal :'),
              //     Text(subTotal.toStringAsFixed(decimal)),
              //   ],
              // ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width / 2,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'MRP',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 30,
                                width: 100,
                                child: TextField(
                                  controller: controllerMrp,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                    horizontal: 5
                                     ),
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                        allow: true, replacementString: '.')
                                  ],
                                  textAlign: TextAlign.right,
                                  onChanged: (value) {
                                    setState(() {
                                      editableMrp = true;
                                      mrp = double.tryParse(value)?? 0;
                                      calculateRate();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Retail',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 30,
                                width: 100,
                                child: TextField(
                                  controller: controllerRetail,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                    horizontal: 5
                                     ),
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                        allow: true, replacementString: '.')
                                  ],
                                  textAlign: TextAlign.right,
                                  onChanged: (value) {
                                    setState(() {
                                      editableRetail = true;
                                      retail = double.tryParse(value)?? 0;
                                      calculateRate();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'WholeSale',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 30,
                                width: 100,
                                child: TextField(
                                  controller: controllerWholeSale,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                    horizontal: 5
                                     ),
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                        allow: true, replacementString: '.')
                                  ],
                                  textAlign: TextAlign.right,
                                  onChanged: (value) {
                                    setState(() {
                                      editableWSale = true;
                                      wholeSale = double.tryParse(value)?? 0;
                                      calculateRate();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Branch',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 30,
                                width: 100,
                                child: TextField(
                                  controller: controllerBranch,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                    horizontal: 5
                                     ),
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                        allow: true, replacementString: '.')
                                  ],
                                  textAlign: TextAlign.right,
                                  onChanged: (value) {
                                    setState(() {
                                      editableBranch = true;
                                      branch = double.tryParse(value)?? 0 ;
                                      calculateRate();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width / 2,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              Container(
                                width: 120,
                                height: 30,
                                decoration: BoxDecoration(
                                    border: Border.all(color: grey),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4,right: 4),
                                  child: Text(
                                    subTotal.toStringAsFixed(decimal),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Discount',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 30,
                                width: 45,
                                child: TextField(
                                  controller: controllerDiscountPer,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                    horizontal: 5
                                     ),
                                      border: OutlineInputBorder(),
                                      label: Text('%')),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                        allow: true, replacementString: '.')
                                  ],
                                  textAlign: TextAlign.right,
                                  onChanged: (value) {
                                    setState(() {
                                      editableDiscountP = true;
                                      discountPer = double.tryParse(value)?? 0;
                                      calculate();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              SizedBox(
                                height: 30,
                                width: 72,
                                child: TextField(
                                  controller: controllerDiscount,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                    horizontal: 5
                                     ),
                                    border: OutlineInputBorder(
                                      
                                    ),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                        allow: true, replacementString: '.')
                                  ],
                                  textAlign: TextAlign.right,
                                  onChanged: (value) {
                                    setState(() {
                                      editableDiscount = true;
                                      discount = double.tryParse(value)?? 0;
                                      calculate();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Net',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              Container(
                                  width: 120,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: grey),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4,right: 4),
                                    child: Text(net.toStringAsFixed(decimal),textAlign: TextAlign.right,),
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Visibility(
                            visible: isTax,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isTax
                                      ? 'Tax ${taxP.toStringAsFixed(0)} %'
                                      : 'Tax',
                                  style: const TextStyle(
                                      fontFamily: 'poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Container(
                                    width: 120,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: grey)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4,right: 4),
                                      child: Text(tax.toStringAsFixed(decimal),textAlign: TextAlign.right,),
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                              Container(
                                width: 120,
                                height: 30,
                                decoration: BoxDecoration(
                                    border: Border.all(color: grey),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4,right: 4),
                                  child: Text(
                                    total.toStringAsFixed(decimal),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(
                          //   height: 20,
                          // )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     const Text('Discount'),
              //     SizedBox(
              //       height: 30,
              //       width: 50,
              //       child: TextField(
              //         controller: controllerDiscountPer,
              //         decoration: const InputDecoration(
              //             border: OutlineInputBorder(), label: Text(' % ')),
              //         keyboardType:
              //             const TextInputType.numberWithOptions(decimal: true),
              //         inputFormatters: [
              //           FilteringTextInputFormatter(RegExp(r'[0-9]'),
              //               allow: true, replacementString: '.')
              //         ],
              //         onChanged: (value) {
              //           setState(() {
              //             editableDiscountP = true;
              //             discountPer = double.tryParse(value)!;
              //             calculate();
              //           });
              //         },
              //       ),
              //     ),
              //     SizedBox(
              //       height: 30,
              //       width: 100,
              //       child: TextField(
              //         controller: controllerDiscount,
              //         decoration: const InputDecoration(
              //             border: OutlineInputBorder(), label: Text('discount')),
              //         keyboardType:
              //             const TextInputType.numberWithOptions(decimal: true),
              //         inputFormatters: [
              //           FilteringTextInputFormatter(RegExp(r'[0-9]'),
              //               allow: true, replacementString: '.')
              //         ],
              //         onChanged: (value) {
              //           setState(() {
              //             editableDiscount = true;
              //             discount = double.tryParse(value)!;
              //             calculate();
              //           });
              //         },
              //       ),
              //     ),
              //   ],
              // ),
              // const Divider(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     SizedBox(
              //       height: 30,
              //       width: 100,
              //       child: TextField(
              //         controller: controllerMrp,
              //         decoration: const InputDecoration(
              //             border: OutlineInputBorder(), label: Text('MRP')),
              //         keyboardType:
              //             const TextInputType.numberWithOptions(decimal: true),
              //         inputFormatters: [
              //           FilteringTextInputFormatter(RegExp(r'[0-9]'),
              //               allow: true, replacementString: '.')
              //         ],
              //         onChanged: (value) {
              //           setState(() {
              //             editableMrp = true;
              //             mrp = double.tryParse(value)!;
              //             calculateRate();
              //           });
              //         },
              //       ),
              //     ),
              //     SizedBox(
              //       height: 30,
              //       width: 100,
              //       child: TextField(
              //         controller: controllerRetail,
              //         decoration: const InputDecoration(
              //             border: OutlineInputBorder(), label: Text('Retail')),
              //         keyboardType:
              //             const TextInputType.numberWithOptions(decimal: true),
              //         inputFormatters: [
              //           FilteringTextInputFormatter(RegExp(r'[0-9]'),
              //               allow: true, replacementString: '.')
              //         ],
              //         onChanged: (value) {
              //           setState(() {
              //             editableRetail = true;
              //             retail = double.tryParse(value)!;
              //             calculateRate();
              //           });
              //         },
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 2,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     SizedBox(
              //       height: 30,
              //       width: 100,
              //       child: TextField(
              //         controller: controllerWholeSale,
              //         decoration: const InputDecoration(
              //             border: OutlineInputBorder(), label: Text('WholeSale')),
              //         keyboardType:
              //             const TextInputType.numberWithOptions(decimal: true),
              //         inputFormatters: [
              //           FilteringTextInputFormatter(RegExp(r'[0-9]'),
              //               allow: true, replacementString: '.')
              //         ],
              //         onChanged: (value) {
              //           setState(() {
              //             editableWSale = true;
              //             wholeSale = double.tryParse(value)!;
              //             calculateRate();
              //           });
              //         },
              //       ),
              //     ),
              //     SizedBox(
              //       height: 30,
              //       width: 100,
              //       child: TextField(
              //         controller: controllerBranch,
              //         decoration: const InputDecoration(
              //             border: OutlineInputBorder(), label: Text('Branch')),
              //         keyboardType:
              //             const TextInputType.numberWithOptions(decimal: true),
              //         inputFormatters: [
              //           FilteringTextInputFormatter(RegExp(r'[0-9]'),
              //               allow: true, replacementString: '.')
              //         ],
              //         onChanged: (value) {
              //           setState(() {
              //             editableBranch = true;
              //             branch = double.tryParse(value)!;
              //             calculateRate();
              //           });
              //         },
              //       ),
              //     ),
              //   ],
              // ),
              // const Divider(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     const Text('Net :'),
              //     Text(net.toStringAsFixed(decimal)),
              //   ],
              // ),
              // Visibility(
              //   visible: isTax,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(isTax ? 'Tax ${taxP.toStringAsFixed(0)} % : ' : 'Tax :'),
              //       Text(tax.toStringAsFixed(decimal)),
              //     ],
              //   ),
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     const Text(
              //       'Total :',
              //       style: TextStyle(fontWeight: FontWeight.bold),
              //     ),
              //     Text(
              //       total.toStringAsFixed(decimal),
              //       style: const TextStyle(fontWeight: FontWeight.bold),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  bool editItem = false;
  int? position;

  cartProduct() {
    return Column(
      children: [
        purchaseHeaderWidget(),
        const SizedBox(
          height: 6,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              itemCount: cartItem.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(
                    height: 5,
                  ),
              itemBuilder: (context, index) {
                return 
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                     color: grey, width: .5),
                     borderRadius:
                    BorderRadius.circular(3),
                    color: Colors.grey.withOpacity(.1)),
                  child: ListTile(
                    title: Text(cartItem[index].itemName,
                    style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 14,
                    ),
                    ),
                    subtitle: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Q:${cartItem[index].quantity}',
                             style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 12,
                    ),
                            ),
                            Text(cartItem[index].unitName,
                             style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 12,
                    ),
                            ),
                            Text(
                                'R:${CommonService.getRound(decimal, cartItem[index].rate)}',
                                 style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 12,
                    ),
                                ),
                            Text(
                                ' = ${CommonService.getRound(decimal, cartItem[index].gross)}',
                                 style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 12,
                    ),
                                ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            cartItem[index].discount > 0
                                ? Text(
                                    ' discount ${CommonService.getRound(decimal, cartItem[index].discount)}',
                                     style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 12,
                    ),
                                    )
                                : Container(),
                            isTax
                                ? Text('Tax ${cartItem[index].tax}',
                                 style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 12,
                    ),
                                )
                                : Container(),
                            Text(
                              'Total = ${CommonService.getRound(decimal, cartItem[index].total)}',
                              style: const TextStyle(
                                fontFamily: 'poppins'
                                ,fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopUpMenuAction(
                      onDelete: () {
                        setState(() {
                          cartItem.removeAt(index);
                        });
                      },
                      onEdit: () {
                        setState(() {
                          editItem = true;
                          position = index;
                          nextWidget = 3;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Divider(
          height: 2,
          thickness: 1,
        ),
        footerWidget(),
      ],
    );
  }

  // TextEditingController cashPaidController = TextEditingController();
  footerWidget() {
    calculateTotal();
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('GrandTotal : ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'poppins',
                      color: Colors.red)),
              Text(
                  totalCartTotal > 0
                      ? ComSettings.appSettings(
                              'bool', 'key-round-off-amount', false)
                          ? CommonService.getRound(decimal, totalCartTotal)
                              .toString()
                          : CommonService.getRound(decimal, totalCartTotal)
                              .roundToDouble()
                              .toString()
                      : ComSettings.appSettings(
                              'bool', 'key-round-off-amount', false)
                          ? CommonService.getRound(decimal, totalCartTotal)
                              .toString()
                          : CommonService.getRound(
                                  decimal, totalCartTotal.roundToDouble())
                              .toString(),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'poppins',
                      color: Colors.red))
            ],
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  double totalGrossValue = 0,
      totalDiscount = 0,
      totalNet = 0,
      totalCess = 0,
      totalIgST = 0,
      totalCgST = 0,
      totalSgST = 0,
      totalFCess = 0,
      totalAdCess = 0,
      taxTotalCartValue = 0,
      totalCartTotal = 0,
      totalProfit = 0;
      int get totalItem => cartItem.length;
  calculateTotal() {
    totalGrossValue = 0;
    totalDiscount = 0;
    totalNet = 0;
    totalCess = 0;
    totalIgST = 0;
    totalCgST = 0;
    totalSgST = 0;
    totalFCess = 0;
    totalAdCess = 0;
    taxTotalCartValue = 0;
    totalCartTotal = 0;
    totalProfit = 0;
    for (var f in cartItem) {
      totalGrossValue += f.gross;
      totalDiscount += f.discount;
      totalNet += f.net;
      totalCess += f.cess;
      totalIgST += f.iGST;
      totalCgST += f.cGST;
      totalSgST += f.sGST;
      totalFCess += f.fCess;
      totalAdCess += f.adCess;
      taxTotalCartValue += f.tax;
      totalCartTotal += f.total;
      totalProfit += f.profitPer;
    }
  }

  void showInSnackBar(String value) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  clearValue() {
    controllerQuantity.text = '';
    controllerRate.text = '';
    controllerDiscountPer.text = '';
    controllerDiscount.text = '';
    controllerBranch.text = '';
    controllerMrp.text = '';
    controllerRetail.text = '';
    controllerWholeSale.text = '';
    productNameController.text ='';
    editableQuantity = false;
    editableMrp = false;
    editableRetail = false;
    editableWSale = false;
    editableBranch = false;
    editableRate = false;
    editableDiscount = false;
    editableDiscountP = false;
    _dropDownUnit = 0;
    quantity = 0;
    gross = 0;
    total = 0;
    tax = 0;
    taxP = 0;
  }

  Future _selectDate(String type) async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => {
            if (type == 'f')
              {formattedDate = DateFormat('dd-MM-yyyy').format(picked)}
            else
              {invDate = DateFormat('dd-MM-yyyy').format(picked)}
          });
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
          fetchPurchase(context, dataDynamic);
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage:
            'Do you want to edit or delete\nRefNo:${dataDynamic['Id']}',
        title: 'Update',
        context: context);
  }

  fetchPurchase(context, data) {
    DioService api = DioService();
    double billTotal = 0, billCash = 0;
    String narration = ' ';

    api.fetchPurchaseInvoiceSp(data['Id'], 'Pr_Find',voucherTypeData!.id).then((value) {
      if (value != null) {
        var information = value['Information'][0];
        var particulars = value['Particulars'];
        // var serialNO = value['SerialNO'];
        // var deliveryNoteDetails = value['DeliveryNote'];
        otherAmountList = []; //value['otherAmount'];

        formattedDate = DateUtil.dateDMY(information['DDate']);

        dataDynamic = [
          {
            'RealEntryNo': information['EntryNo'],
            'EntryNo': information['EntryNo'],
            'InvoiceNo': information['Sup_Inv'],
            'Type': 0
          }
        ];
        billCash = double.tryParse(information['CashPaid'].toString())!;
        billTotal = double.tryParse(information['GrandTotal'].toString())!;
        narration = information['Narration'];
        DataJson cModel =
            DataJson(id: information['Supplier'], name: information['FromSup']);
        ledgerModel = cModel;
        cartItem.clear();
        for (var product in particulars) {
          cartItem.add(CartItemP(
              adCess: double.tryParse(product['adcess'].toString())!,
              barcode: barcode,
              branch: double.tryParse(product['Branch'].toString())!,
              branchPer: double.tryParse(product['branchp'].toString())!,
              cDisc: double.tryParse(product['cdisc'].toString())!,
              cGST: double.tryParse(product['CGST'].toString())!,
              cdPer: double.tryParse(product['cdiscper'].toString())!,
              cess: double.tryParse(product['cess'].toString())!,
              discount: double.tryParse(product['Disc'].toString())!,
              discountPercent:
                  double.tryParse(product['DiscPersent'].toString())!,
              expDate: product['expDate'],
              expense: double.tryParse(product['Expenses'].toString())!,
              fCess: double.tryParse(product['Fcess'].toString())!,
              fUnitId: int.tryParse(product['Funit'].toString())!,
              fUnitValue: double.tryParse(product['FValue'].toString())!,
              free: double.tryParse(product['freeQty'].toString())!,
              gross: double.tryParse(product['GrossValue'].toString())!,
              iGST: double.tryParse(product['IGST'].toString())!,
              id: cartItem.length + 1,
              itemId: product['ItemId'],
              itemName: product['ProductName'],
              location: int.tryParse(product['Location'].toString())!,
              mrp: double.tryParse(product['Mrp'].toString())!,
              mrpPer: double.tryParse(product['Profit'].toString())!,
              net: double.tryParse(product['Net'].toString())!,
              profitPer: double.tryParse(product['Profit'].toString())!,
              quantity: double.tryParse(product['Qty'].toString())!,
              rRate: double.tryParse(product['RealPrate'].toString())!,
              rate: double.tryParse(product['PRate'].toString())!,
              retail: double.tryParse(product['Retail'].toString())!,
              retailPer: double.tryParse(product['retailp'].toString())! ?? 0,
              sGST: double.tryParse(product['SGST'].toString())!,
              serialNo: product['serialno'],
              spRetail: double.tryParse(product['Spretail'].toString())!,
              spRetailPer: double.tryParse(product['spretailp'].toString())!,
              tax: double.tryParse(product['IGST'].toString())!,
              taxP: double.tryParse(product['tax'].toString())!,
              total: double.tryParse(product['Total'].toString())!,
              uniqueCode: product['UniqueCode'],
              unitId: product['Unit'],
              unitName: '',
              unitValue: double.tryParse(product['UnitValue'].toString())!,
              wholesale: double.tryParse(product['WSrate'].toString())!,
              wholesalePer: double.tryParse(product['wsalesp'].toString())!,
              estUniqueCode: 0,
              brand: 0,
              company: 0,
              size: 0,
              color: 0,
              expenseQty: 0));
        }
      }

      setState(() {
        widgetID = false;
        if (billCash > 0) {
          // cashPaidController.text = billCash.toStringAsFixed(decimal);
        }
        _narration = narration;
        nextWidget = 4;
        oldBill = true;
      });
    });
  }

  delete(context) {
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
          deleteData();
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage: 'Do you want to Delete',
        title: 'Delete Bill',
        context: context);
  }

  deleteData() {
    dio.deletePurchase(dataDynamic[0]['EntryNo'], 'Pr_Delete',voucherTypeData!.id).then((value) {
      setState(() {
        _isLoading = false;
      });
      if (value) {
        cartItem.clear();
        clearValue();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Expanded(
              child: AlertDialog(
                title: const Text('Purchase Return Deleted'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/purchaseReturn');
                    },
                    child: const Text('CANCEL'),
                  )
                ],
              ),
            );
          },
        );
      }
    });
  }
}

showMore(context, purchaseState) {
  var form = 'PURCHASE RETURN';
  var title = 'Purchase Return';
  var size = "2";
  ConfirmAlertBox(
      buttonColorForNo: Colors.red,
      buttonColorForYes: Colors.green,
      icon: Icons.check,
      onPressedNo: () {
        // Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, '/purchaseReturn');
      },
      onPressedYes: () {
        Navigator.of(context).pop();
        rateType = '1';
        var data = '[' +
            json.encode({
              'statement': 'PurchaseReturnFind',
              'entryNo': dataDynamic[0]['EntryNo'].toString(),
              'saleFormId': 1,
              'fyId': currentFinancialYear!.id
            }) +
            ']';
        final body = {
          'information': '[{}]',
          'data': data,
          'particular': '[{}]',
          'otherAmount': '[{}]'
        };

        // Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, '/purchase_return_preview_show',
            arguments: {'title': 'PurchaseReturn'});
      },
      buttonTextForNo: 'No',
      buttonTextForYes: 'YES',
      infoMessage:
          'Do you want to print\nEntryNo : ${dataDynamic[0]['EntryNo']}',
      title: 'SAVED',
      context: context);
}
