import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/cart_item.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/product_register_model.dart';
import 'package:sheraccerp/models/sales_model.dart';
import 'package:sheraccerp/models/unit_model.dart';
import 'package:sheraccerp/models/voucher_type_model.dart';
import 'package:sheraccerp/scoped-models/main.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/service/com_service.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/color_palette.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/loading.dart';
import 'package:sheraccerp/widget/popup_menu_action.dart';
import 'package:sheraccerp/widget/progress_hud.dart';

class PurchaseOrder extends StatefulWidget {
  const PurchaseOrder({Key? key}) : super(key: key);

  @override
  State<PurchaseOrder> createState() => _PurchaseOrderState();
}

class _PurchaseOrderState extends State<PurchaseOrder> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DioService dio = DioService();
  var ledgerModel, productModel, productModelPrize;
  List<dynamic> purchaseAccountList = [];
  DateTime now = DateTime.now();
  String? formattedDate, invDate = '', _narration = '';
  TextEditingController invNoController = TextEditingController();
  TextEditingController supplierNameController = TextEditingController();
  TextEditingController productNameController = TextEditingController();
  double _balance = 0;
  List<dynamic> otherAmountList = [];
  bool isTax = true,
      _isCashBill = false,
      otherAmountLoaded = false,
      valueMore = false,
      _isLoading = false,
      widgetID = true,
      oldBill = false,
      newPurchaseOrder = false,
      lastRecord = false;
  List<CartItemP> cartItem = [];
  CartItemP? cartModel;
  int page = 1, pageTotal = 0, totalRecords = 0,_dropDownUnit = 0;
  List<ProductPurchaseModel> itemDisplay = [];
  List<ProductPurchaseModel> items = [];
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
    enableKeralaFloodCess = false;
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
        voucherTypeData = voucherTypeList.firstWhere(
        (element) => element.voucher.toLowerCase() == 'purchase order');
  }

  @override
  Widget build(BuildContext context) {
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
            content: const Text('Do you want to exit Purchase'),
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
      appBar:newPurchaseOrder? AppBar(
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
                    var stType = 'PO_Update';
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
                          'type': 'PO',
                          'cashPaid': cashPaidController.text.isNotEmpty
                              ? cashPaidController.text
                              : '0',
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
                    var stType = 'PO_Insert';
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
                          'type': 'PO',
                          'cashPaid': cashPaidController.text.isNotEmpty
                              ? cashPaidController.text
                              : '0',
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
                  icon: Image.asset('assets/icons/Save instagram@2x.png',scale: 1.6,)),
        ],
        title: const Text('Purchase Order'),
        titleTextStyle: const TextStyle(
          fontFamily: 'poppins'
        ),
      ) : null,
      body: ProgressHUD(
          inAsyncCall: _isLoading, opacity: 0.0, child: selectWidget()),
    );
  }

  widgetPrefix() {
    return Scaffold(
      backgroundColor: bagroundColor,
        key: _scaffoldKey,
        appBar: AppBar(
          actions: [
            TextButton(
                style: TextButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)
                  ),
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
          title: const Text('Purchase Order'),
          titleTextStyle: const TextStyle(
            fontFamily: 'poppins'
          ),
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
        var statement = 'PurchaseOrderList';

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
        ? newPurchaseOrderWidget(newPurchaseOrder)
        //  selectLedgerWidget()
        : nextWidget == 1
            ? addItemWidget()
            // purchaseHeaderWidget()
            : nextWidget == 2
                ? selectProductWidget()
                : nextWidget == 3
                    ? itemDetails()
                    : nextWidget == 4
                        ? cartProduct()
                        : Container(
                            padding: const EdgeInsets.all(2.0),
                            child: const Text('No Widget'),
                          );
  }

  int? selectedCustomerId = 0; 
  newPurchaseOrderWidget(newPurchaseOrder){
   if (newPurchaseOrder) {
     setState(() {
       newPurchaseOrder = true;
     });
   }
   return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
     child: Scaffold(
      backgroundColor: bagroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Purchase Order'),
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
          padding: const EdgeInsets.symmetric(horizontal: 5),
          width: MediaQuery.of(context).size.width,
          height: 35,
          decoration: BoxDecoration(
        border: Border.all(color: grey),
        borderRadius: BorderRadius.circular(3),
          ),
          child: dataDynamic.isEmpty
          ? const Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_drop_down_rounded,
                color: grey,
              ))
          : dataDynamic[0]['EntryNo'].toString().isEmpty
              ? const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: grey,
                  ))
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    !oldBill
                    ? (int.parse(dataDynamic[0]['EntryNo'].toString()) + 1).toString()
                    : dataDynamic[0]['EntryNo'].toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w400,
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
                      ' Supplier',
                       style: TextStyle(
                       fontFamily: 'poppins',
                       fontSize: 14,
                       fontWeight: FontWeight.w500),
                     ),
                     const SizedBox(
                      height: 4,
                     ),
                       FutureBuilder<List<dynamic>>(
                                  future: dio.getSalesListData('', 'sales_list/supplier'),
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
                                         controller: supplierNameController,
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
                                            ledgerModel = selectedSupplier ;
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
                                        cartModel = cartItem.elementAt(position!);
                                        selectedProducteId = 
                                        cartModel!.id;
                                        productNameController.text =
                                        cartModel!.itemName;
                                        rate = cartModel!.rate;
                                        controllerRate.text =
                                            cartModel!.rate.toString();
                                        controllerQuantity.text =
                                            cartModel!.quantity.toString();
                                            quantity = 
                                            cartModel!.quantity;
                                        controllerQuantity.text =
                                            cartModel!.quantity.toString();
                                        controllerDiscount.text =
                                            cartModel!.discount.toString();
                                        controllerDiscountPer.text =
                                            cartModel!.discountPercent.toString();
                                        controllerMrp.text = 
                                            cartModel!.mrp.toString();
                                        controllerBranch.text = 
                                            cartModel!.branch.toString();
                                        controllerRetail.text = 
                                            cartModel!.retail.toString();
                                        controllerWholeSale.text = 
                                            cartModel!.wholesale.toString();      
                                            subTotal = cartModel!.net;
                                            net = cartModel!.net;
                                            tax = cartModel!.tax;
                                            taxP = cartModel!.taxP;
                                            total = cartModel!.total;
                                            
                                        // _serialNoController.text =
                                        //     cartModel.serialNo;
                                            nextWidget = 1;
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
                                                        '# ${index +1}',
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
                  onTap: oldBill
                  ?() {
                    if (cartItem.isNotEmpty) {
                    setState(() {
                      _isLoading = true;
                    });
                    delete(context);
                  } else {
                    showInSnackBar('No items found on bill');
                  }
                  }
                  :()async {
                    if (totalItem > 0 &&  selectedCustomerId != null) {
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
                    var stType = 'PO_Insert';
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
                          'type': 'PO',
                          'cashPaid': cashPaidController.text.isNotEmpty
                              ? cashPaidController.text
                              : '0',
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
                      selectedCustomerId = 0;
                      supplierNameController.text = '';
                      clearValue();
                      totalCartTotal = 0;
                      // Navigator.pushReplacementNamed(context, '/purchaseOrder');
                      Fluttertoast.showToast(
                        backgroundColor: green,
                        msg:'Bill Saved');
                      // showMore(context, 'Saved');
                    } else {
                      showInSnackBar('Error enter data correctly');
                    }
                    }
                    else {
                       Fluttertoast.showToast(
                        backgroundColor: red,
                        msg:selectedCustomerId == null ?'Select Supplier' :"Can't Save without any Product" );
                    }
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
              )),
              Expanded(child: 
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: oldBill 
                  ? () async {
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
                    var stType = 'PO_Update';
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
                          'type': 'PO',
                          'cashPaid': cashPaidController.text.isNotEmpty
                              ? cashPaidController.text
                              : '0',
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
                  }
                  :()async {
                    if (totalItem > 0 &&  selectedCustomerId != null) {
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
                    var stType = 'PO_Insert';
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
                          'type': 'PO',
                          'cashPaid': cashPaidController.text.isNotEmpty
                              ? cashPaidController.text
                              : '0',
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
                      Navigator.pushReplacementNamed(context, '/purchaseOrder');
                      Fluttertoast.showToast(
                        backgroundColor: green,
                        msg:'Bill Saved');
                      // showMore(context, 'Saved');
                    } else {
                      showInSnackBar('Error enter data correctly');
                    }
                    }
                    else {
                       Fluttertoast.showToast(
                        backgroundColor: red,
                        msg:selectedCustomerId == null ?'Select Supplier' :"Can't Save without any Product" );
                    }
                  },
                  child: Container(
                                height: 60,
                                color: kPrimaryColor,
                                child:  Center(
                                  child:Text(
                                    oldBill? 'Edit' :'Save',
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
              )
              )
        ]),
      ),
     ),
   );
  }

  int? selectedProducteId;
  var selectedItem;
  String? selectedTaxOption = 'With Tax';

   addItemWidget(){
    List<UnitModel> unitList = [];
    //  if (editItem) {
    //   // adCessPer = double.tryParse(productModel['adcessper'].toString());
    //   // cessPer = double.tryParse(productModel['cessper'].toString());
    //   taxP = cartItem.elementAt(position!).taxP;
    //   // kfcP = double.tryParse(productModel['KFC'].toString());
    //   quantity = cartItem[position!].quantity;
    //   if (quantity > 0 && !editableQuantity) {
    //     controllerQuantity.text = quantity.toString();
    //   }
    //   rate = cartItem.elementAt(position!).rate;
    //   if (rate > 0 && !editableRate) {
    //     controllerRate.text = rate.toString();
    //   }
    //   if (cartItem.elementAt(position!).rRate > 0) {
    //     rRate = cartItem.elementAt(position!).rRate;
    //   }
    //   mrp = cartItem.elementAt(position!).mrp;
    //   if (mrp > 0 && !editableMrp) {
    //     controllerMrp.text = mrp.toString();
    //   }
    //   retail = cartItem.elementAt(position!).retail;
    //   if (retail > 0 && !editableRetail) {
    //     controllerRetail.text = retail.toString();
    //   }
    //   wholeSale = cartItem.elementAt(position!).wholesale;
    //   if (wholeSale > 0 && !editableWSale) {
    //     controllerWholeSale.text = wholeSale.toString();
    //   }
    //   spRetail = cartItem.elementAt(position!).spRetail;
    //   branch = cartItem.elementAt(position!).branch;
    //   if (branch > 0 && !editableBranch) {
    //     controllerBranch.text = branch.toString();
    //   }
    //   discount = cartItem.elementAt(position!).discount;
    //   if (discount > 0 && !editableDiscount) {
    //     controllerDiscount.text = discount.toString();
    //   }
    //   discountPer = cartItem.elementAt(position!).discountPercent;
    //   if (discountPer > 0 && !editableDiscountP) {
    //     controllerDiscountPer.text = discountPer.toString();
    //   }
    //   subTotal = cartItem.elementAt(position!).gross;
    //   net = cartItem.elementAt(position!).net;
    //   if (taxP > 0) {
    //     tax = cartItem.elementAt(position!).tax;
    //     iGST = cartItem.elementAt(position!).iGST;
    //     csGST = cartItem.elementAt(position!).cGST;
    //   } else {
    //     iGST = 0;
    //     csGST = 0;
    //     tax = 0;
    //   }
    //   total = cartItem.elementAt(position!).total;
    // } else {
      // adCessPer = double.tryParse(selectedItem['adcessper'].toString())!;
      // cessPer = double.tryParse(selectedItem['cessper'].toString())!;
      // taxP = double.tryParse(selectedItem['tax'].toString())!;
      // kfcP = double.tryParse(selectedItem['KFC'].toString())!;
      // rate = double.tryParse(productModelPrize['prate'].toString())!;
      // if (rate > 0 && !editableRate) {
      //   controllerRate.text = rate.toString();
      // }
      // if (double.tryParse(productModelPrize['realprate'].toString())! > 0) {
      //   rRate = double.tryParse(productModelPrize['realprate'].toString())!;
      // }
      // mrp = double.tryParse(productModelPrize['mrp'].toString())!;
      // if (mrp > 0 && !editableMrp) {
      //   controllerMrp.text = mrp.toString();
      // }
      // retail = double.tryParse(productModelPrize['retail'].toString())!;
      // if (retail > 0 && !editableRetail) {
      //   controllerRetail.text = retail.toString();
      // }
      // wholeSale = double.tryParse(productModelPrize['wsrate'].toString())!;
      // if (wholeSale > 0 && !editableWSale) {
      //   controllerWholeSale.text = wholeSale.toString();
      // }
      // spRetail = double.tryParse(productModelPrize['spretail'].toString())!;
      // branch = double.tryParse(productModelPrize['branch'].toString())!;
      // if (branch > 0 && !editableBranch) {
      //   controllerBranch.text = branch.toString();
      // }
    // }

    calculate() {
      quantity = (controllerQuantity.text.isNotEmpty
          ? double.tryParse(controllerQuantity.text)
          : 0)!;
      rate = (controllerRate.text.isNotEmpty
          ? double.tryParse(controllerRate.text)
          : 0)!;
           if (enableMULTIUNIT) {
        if (currentRate > 0) {
          if (conversion > 0 ) {
            if (focusNodeRate.hasFocus ) {
              rate = double.tryParse(controllerRate.text)?? 0;
              // rate = double.tryParse(_rateController.text) * _conversion;
              // lastRateStatus = false;
            } else {
              rate =  (currentRate * conversion);
              // rate = saleRate; // * _conversion;
              controllerRate.text = rate.toStringAsFixed(decimal);
            }
            
          } else {
            rate = (controllerRate.text.isNotEmpty
                ? double.tryParse(controllerRate.text)
                : 0)?? 0;
          }
        }
       else {
        rate = (controllerRate.text.isNotEmpty
            ? double.tryParse(controllerRate.text)
            : 0) ?? 0;
      }
      }
      else{
        if (focusNodeRate.hasFocus) {
         rate =  double.tryParse(controllerRate.text) ?? 0 ; 
        } else if (currentRate > 0){
          controllerRate.text = currentRate.toStringAsFixed(decimal);
          rate = currentRate;
        } else{
           rate = (controllerRate.text.isNotEmpty
                ? double.tryParse(controllerRate.text)
                : 0)?? 0;
        }
      }
      if (focusNodeDiscountPer.hasFocus) {
        controllerDiscount.text = controllerDiscountPer.text.isNotEmpty
            ? (((quantity * rate) * discountPer) / 100).toStringAsFixed(2)
            : '';
        discount = (controllerDiscount.text.isNotEmpty
            ? double.tryParse(controllerDiscount.text)
            : 0)!;
        discountPer = (double.tryParse(controllerDiscountPer.text))?? 0;
      }

      if (focusNodeDiscount.hasFocus) {
        controllerDiscountPer.text = controllerDiscount.text.isNotEmpty
            ? ((discount * 100) / (quantity * rate)).toStringAsFixed(2)
            : '';
        discountPer = (controllerDiscount.text.isNotEmpty
            ? double.tryParse(controllerDiscount.text)
            : 0)!;
        double.tryParse(controllerDiscount.text);
      }
      // discount = (controllerDiscount.text.isNotEmpty
      //     ? double.tryParse(controllerDiscount.text)
      //     : 0)!;
      // discountPer = (controllerDiscountPer.text.isNotEmpty
      //     ? double.tryParse(controllerDiscountPer.text)
      //     : 0)!;
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
      child: Scaffold(
        backgroundColor: bagroundColor,
        appBar: AppBar(
          title: const Text('Add Item to Purchase Order'),
          // centerTitle: true,
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(' Item Name',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                     FutureBuilder(
                            future: dio.fetchAllProductPurchase(),
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
                             
                              final purchasePr = snapshot.data;
                          
                              List<String> prName =
                                 purchasePr!
                                  .map((e) => e.itemName)
                                  .where((element) => element != null)
                                  .cast<String>()
                                  .toList();
                          
                              return EasyAutocomplete(
                                inputTextStyle: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                    border: OutlineInputBorder(),
                                    ),
                                controller: productNameController,
                                suggestions: prName,
                                onChanged: (p0) {
                                 
                                },
                                onSubmitted: (value) async {
                                  
                                  selectedItem =
                                   purchasePr.firstWhere(
                                    (element) => element.itemName == value,
                                  );
                                  quantity = 0;
                                  controllerQuantity.text = '';
                                  controllerDiscountPer.text = '';
                                  controllerDiscount.text = '';
                                  unitValue = 1;
                                  _dropDownUnit = 0;
                                  rate = 0;
                                  // currentRate = 0;
                                  // rPRate = 0;
                                  mrp = 0;
                                  retail = 0;
                                  wholeSale = 0;
                                  spRetail = 0;
                                  branch = 0;
                                  // grossTotal = 0;
                                  net = 0;
                                  tax = 0 ;
                                  total = 0;
                                  discountPer = 0;
                                  discount = 0;
                                  conversion = 0;
                                 
                                  selectedProducteId = selectedItem.slNo;
                                  print(selectedProducteId);
                                  final fetchedPrice = await dio
                                      .fetchProductPrize(selectedProducteId!);
                                 
                                  productModelPrize = fetchedPrice.toList();
                          
                                 adCessPer = double.tryParse(selectedItem.adCessPer.toString())!;
      cessPer = double.tryParse(selectedItem.cessPer.toString())!;
      taxP = double.tryParse(selectedItem!.tax.toString())?? 0;
      // kfcP = double.tryParse(selectedItem!.KFC.toString())?? 0;
      rate = double.tryParse(productModelPrize[0]['prate'].toString())!;
      if (rate > 0 && !editableRate) {
        controllerRate.text = rate.toString();
      }
      currentRate = rate;
      if (double.tryParse(productModelPrize[0]['realprate'].toString())! > 0) {
        rRate = double.tryParse(productModelPrize[0]['realprate'].toString())!;
      }
      mrp = double.tryParse(productModelPrize[0]['mrp'].toString())!;
      if (mrp > 0 && !editableMrp) {
        controllerMrp.text = mrp.toString();
      }
      retail = double.tryParse(productModelPrize[0]['retail'].toString())!;
      if (retail > 0 && !editableRetail) {
        controllerRetail.text = retail.toString();
      }
      wholeSale = double.tryParse(productModelPrize[0]['wsrate'].toString())!;
      if (wholeSale > 0 && !editableWSale) {
        controllerWholeSale.text = wholeSale.toString();
      }
      spRetail = double.tryParse(productModelPrize[0]['spretail'].toString())!;
      branch = double.tryParse(productModelPrize[0]['branch'].toString())!;
      if (branch > 0 && !editableBranch) {
        controllerBranch.text = branch.toString();
      }
                                //     currentRate =
                                //   double.tryParse(productModelPrize[0]['prate'].toString()) ?? 0;
                                //   pRate = currentRate;
                                //   if (pRate > 0 && !focusNodeRate.hasFocus) {
                                //   controllerRate.text = pRate.toString();
                                //    }
                                //    else {
                                //     controllerRate.text = '';
                                //   }
                                //    if (currentRate > 0 && !focusNodeRate.hasFocus &&
                                //    controllerRate.text.isEmpty) {
                                //    controllerRate.text = _conversion > 0
                                //    ? (pRate * _conversion).toStringAsFixed(decimal)
                                //    : pRate.toStringAsFixed(decimal);
                                //    pRate = _conversion > 0 ? pRate * _conversion : pRate;
                                //  }
                                 
                                 
                                //    double.tryParse(productModelPrize[0]['realprate'].toString()) == 0
                                //    ? 0
                                //    : rPRate =
                                //    double.tryParse(productModelPrize[0]['realprate'].toString()) ??
                                //    0;
                          
                                //   // pRate = double.tryParse(
                                //   //         productModelPrize[0]['prate'].toString()) ??
                                //   //     0;
                                //   // if (pRate > 0 && !focusNodeRate.hasFocus) {
                                //   //   controllerRate.text = pRate.toString();
                                //   // } else {
                                //   //   controllerRate.text = '';
                                //   // }
                          
                                //   // rPRate = double.tryParse(productModelPrize[0]
                                //   //             ['realprate']
                                //   //         .toString()) ??
                                //   //     0;
                                //   mrp = double.tryParse(
                                //           productModelPrize[0]['mrp'].toString()) ??
                                //       0;
                                //   if (mrp > 0 && !focusNodeMrp.hasFocus) {
                                //     controllerMrp.text = mrp.toString();
                                //   } else {
                                //     controllerMrp.text = '';
                                //   }
                          
                                //   retail = double.tryParse(productModelPrize[0]
                                //               ['retail']
                                //           .toString()) ??
                                //       0;
                                //   if (retail > 0 && !focusNodeRetail.hasFocus) {
                                //     controllerRetail.text = retail.toString();
                                //   } else {
                                //     controllerRetail.text = '';
                                //   }
                          
                                //   wholeSale = double.tryParse(productModelPrize[0]
                                //               ['wsrate']
                                //           .toString()) ??
                                //       0;
                                //   if (wholeSale > 0 && !focusNodeWholeSale.hasFocus) {
                                //     controllerWholeSale.text = wholeSale.toString();
                                //   } else {
                                //     controllerWholeSale.text = '';
                                //   }
                          
                                //   spRetail = double.tryParse(productModelPrize[0]
                                //               ['spretail']
                                //           .toString()) ??
                                //       0;
                                //   branch = double.tryParse(productModelPrize[0]
                                //               ['branch']
                                //           .toString()) ??
                                //       0;
                                //   if (branch > 0 && !focusNodeBranch.hasFocus) {
                                //     controllerBranch.text = branch.toString();
                                //   } else {
                                //     controllerBranch.text = '';
                                //   }
                          
                                //   taxP = selectedItem.tax ?? 0;
                                
                                },
                              );
                            },
                          ),
                           selectedProducteId == null
                        ? SizedBox()
                        : const SizedBox(
                            height: 4,
                          ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
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
                          ),
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
                                  focusNode: focusNodeRate,
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
                            // Expanded(child: 
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     const Text(
                            //       ' Tax Option',
                            //       style: TextStyle(
                            //                    fontFamily: 'poppins',
                            //                    fontSize: 14,
                            //                    fontWeight: FontWeight.w500),),
                            //                    const SizedBox(
                            //                     height: 2,
                            //                    ),
                            //                                 Container(
                            //                                   height: 40,
                            //                       padding:
                            //                           const EdgeInsets.only(
                            //                               left: 5),
                            //                       decoration: BoxDecoration(
                            //                         border: Border.all(
                            //                             color: Colors.grey),
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 3),
                            //                       ),
                            //                       child:
                            //                           DropdownButtonHideUnderline(
                            //                         child: DropdownButton<
                            //                             String>(
                            //                           style: const TextStyle(
                            //                               fontFamily:
                            //                                   'poppins',
                            //                               color: black),
                            //                           value:
                            //                               selectedTaxOption,
                            //                           items: const [
                            //                             DropdownMenuItem(
                            //                               value: 'With Tax',
                            //                               child: Text(
                            //                                   'With Tax'),
                            //                             ),
                            //                             DropdownMenuItem(
                            //                               // enabled: salesTypeData!
                            //                               //                 .id ==
                            //                               //             1 ||
                            //                               //         salesTypeData!
                            //                               //                 .id ==
                            //                               //             2
                            //                               //     ? false
                            //                               //     : true,
                            //                               value:
                            //                                   'Without Tax',
                            //                               child: Text(
                            //                                   'Without Tax'),
                            //                             ),
                            //                           ],
                            //                           onChanged: (value) {
                            //                             setState(() {
                            //                               selectedTaxOption = value!;
                            //                               value == 'Without Tax' 
                            //                                   ? isTax = false
                            //                                   : isTax = true;
                            //                               calculate();
                            //                             });
                            //                           },
                            //                           isExpanded: true,
                            //                         ),
                            //                       ),
                            //                     ),
                            //   ],
                            // )
                            // ),
                            Expanded(child: 
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  ' Sub Total',
                                  style: TextStyle(
                                               fontFamily: 'poppins',
                                               fontSize: 14,
                                               fontWeight: FontWeight.w500),),
                                               const SizedBox(
                                                height: 2,
                                               ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: grey
                                ),
                                borderRadius: BorderRadius.circular(3)
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(subTotal.toStringAsFixed(decimal),
                                ),
                              ),
                            )
                              ],
                            )
                            )
                        //      Expanded(
                        //     child: Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     const Text(' Gross',
                        //         style: TextStyle(
                        //             fontFamily: 'poppins',
                        //             fontSize: 14,
                        //             fontWeight: FontWeight.w400)),
                        //     InkWell(
                        //       onTap: () {
                        //         controllerGross.text =
                        //             grossTotal.toStringAsFixed(decimal);
                        //         showModalBottomSheet(
                        //           context: context,
                        //           builder: (BuildContext context) => Padding(
                        //             padding: EdgeInsets.only(
                        //                 bottom: MediaQuery.of(context)
                        //                     .viewInsets
                        //                     .bottom),
                        //             child: Column(
                        //               children: [
                        //                 const SizedBox(height: 16),
                        //                 Padding(
                        //                   padding: const EdgeInsets.symmetric(
                        //                       horizontal: 8),
                        //                   child: TextField(
                        //                     keyboardType: const TextInputType
                        //                         .numberWithOptions(
                        //                         decimal: true),
                        //                     inputFormatters: [
                        //                       FilteringTextInputFormatter(
                        //                           RegExp(r'[0-9]'),
                        //                           allow: true,
                        //                           replacementString: '.')
                        //                     ],
                        //                     decoration: const InputDecoration(
                        //                         border: OutlineInputBorder(),
                        //                         hintText: 'Gross Amount',
                        //                         labelText:
                        //                             'Enter gross amount'),
                        //                     controller: controllerGross,
                        //                     autofocus: true,
                        //                   ),
                        //                 ),
                        //                 const SizedBox(height: 10),
                        //                 ElevatedButton(
                        //                   style: ElevatedButton.styleFrom(
                        //                       backgroundColor: kPrimaryColor,
                        //                       shape: RoundedRectangleBorder(
                        //                           borderRadius:
                        //                               BorderRadius.circular(
                        //                                   5))),
                        //                   onPressed: () {
                        //                     Navigator.of(context).pop();
                        //                     setState(() {
                        //                       calculateGross(
                        //                           controllerGross.text);
                        //                     });
                        //                   },
                        //                   child: const Text(
                        //                     "Done",
                        //                     style: TextStyle(color: white),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         );
                        //       },
                        //       child: Container(
                        //         width: MediaQuery.of(context).size.width,
                        //         height: 35,
                        //         padding:
                        //             const EdgeInsets.symmetric(horizontal: 5),
                        //         decoration: BoxDecoration(
                        //             border: Border.all(color: grey),
                        //             borderRadius: BorderRadius.circular(3)),
                        //         child: Align(
                        //             alignment: Alignment.centerRight,
                        //             child: Text(
                        //                 grossTotal.toStringAsFixed(decimal))),
                        //       ),
                        //     ),
                        //   ],
                        // ))
                    ],
                  ),
                  const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width/3.5,
                            child: const Text('Discount',
                            textScaler: TextScaler.linear(1),
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    // fontSize: 13,
                                    fontWeight: FontWeight.w400)),
                          ),
                          // const Spacer(),
                          Flexible(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.orange),
                                  borderRadius: BorderRadius.circular(3)),
                              height: 35,
                              child: TextField(
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 13),
                                controller: controllerDiscountPer,
                                focusNode: focusNodeDiscountPer,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                      allow: true, replacementString: '.')
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    discountPer = double.tryParse(value) ?? 0;
                                    calculate();
                                  });
                                },
                                decoration: InputDecoration(
                                  suffixIcon: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        border: const Border(
                                            left: BorderSide(
                                                color: Colors.orange)),
                                        borderRadius: const BorderRadius.only(
                                            bottomRight: Radius.circular(3),
                                            topRight: Radius.circular(3))),
                                    width: 25,
                                    child: const Center(
                                      child: Icon(
                                        Icons.percent_sharp,
                                        color: Colors.orange,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 3),
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)),
                              height: 35,
                              child: TextField(
                                focusNode: focusNodeDiscount,
                                style: const TextStyle(fontSize: 13),
                                controller: controllerDiscount,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                      allow: true, replacementString: '.')
                                ],
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: const Border(
                                          right: BorderSide(color: grey)),
                                    ),
                                    width: 25,
                                    child: const Center(
                                      child: Icon(
                                        Icons.currency_rupee_outlined,
                                        color: Colors.grey,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 3),
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    discount = double.tryParse(value) ?? 0;
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
                      height: 6,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width/3.5,
                          child: Text('Net',
                              style: TextStyle(
                                  fontFamily: 'poppins',
                                  // fontSize: 13,
                                  fontWeight: FontWeight.w400)),
                        ),
                        // const SizedBox(width: 4),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: grey),
                                borderRadius: BorderRadius.circular(3)),
                            height: 35,
                            child: TextField(
                              style: const TextStyle(fontSize: 13),
                              controller: TextEditingController(
                                  text: net.toStringAsFixed(decimal)),
                              readOnly: true,
                              // keyboardType:
                              //     const TextInputType
                              //         .numberWithOptions(
                              //         decimal: true),
                              // inputFormatters: [
                              //   FilteringTextInputFormatter(
                              //       RegExp(r'[0-9]'),
                              //       allow: true,
                              //       replacementString:
                              //           '.')
                              // ],
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                prefixIcon: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: const Border(
                                        right: BorderSide(color: grey)),
                                  ),
                                  width: 25,
                                  child: const Center(
                                    child: Icon(
                                      Icons.currency_rupee_outlined,
                                      color: Colors.grey,
                                      size: 15,
                                    ),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 3),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none),
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                      const SizedBox(
                      height: 6,
                    ),
                    Visibility(
                      visible: isTax,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width/3.5,
                              child: Text(
                                  '${(companyTaxMode == 'INDIA' ? 'GST ' : companyTaxMode == 'GULF' ? 'VAT ' : 'Tax ')}',
                                  style: const TextStyle(
                                      fontFamily: 'poppins',
                                      // fontSize: 13,
                                      fontWeight: FontWeight.w400)),
                            ),
                            // const Spacer(),
                            Flexible(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.circular(3)),
                                height: 35,
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 13),
                                  readOnly: true,
                                  controller: TextEditingController(
                                      text: taxP.toStringAsFixed(decimal)),
                                  // focusNode: focusNodeDiscount,
                                  //   keyboardType:
                                  //       const TextInputType
                                  //           .numberWithOptions(
                                  //           decimal: true),
                                  //   inputFormatters: [
                                  //     FilteringTextInputFormatter(
                                  //         RegExp(r'[0-9]'),
                                  //         allow: true,
                                  //         replacementString:
                                  //             '.')
                                  //   ],
                                  //                   onChanged: (value) {
                                  //                     setState(() {
                                  //   editableDiscountP = true;
                                  //   discountPer = double.tryParse(value)!;
                                  //   // calculate();
                                  // });
                                  //                   },
                                  decoration: InputDecoration(
                                    suffixIcon: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          border: const Border(
                                              left: BorderSide(
                                                  color: Colors.orange)),
                                          borderRadius: const BorderRadius.only(
                                              bottomRight: Radius.circular(3),
                                              topRight: Radius.circular(3))),
                                      width: 25,
                                      child: const Center(
                                        child: Icon(
                                          Icons.percent_sharp,
                                          color: Colors.orange,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 3),
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: grey),
                                    borderRadius: BorderRadius.circular(3)),
                                height: 35,
                                child: TextField(
                                  readOnly: true,
                                  style: const TextStyle(fontSize: 13),
                                  controller: TextEditingController(
                                      text: tax.toStringAsFixed(decimal)),
                                  // focusNode:
                                  //     focusNodeDiscountPer,
                                  // controller:
                                  //     controllerDiscountPer,
                                  // keyboardType:
                                  //     const TextInputType
                                  //         .numberWithOptions(
                                  //         decimal: true),
                                  // inputFormatters: [
                                  //   FilteringTextInputFormatter(
                                  //       RegExp(r'[0-9]'),
                                  //       allow: true,
                                  //       replacementString:
                                  //           '.')
                                  // ],
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    prefixIcon: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        border: const Border(
                                            right: BorderSide(color: grey)),
                                      ),
                                      width: 25,
                                      child: const Center(
                                        child: Icon(
                                          Icons.currency_rupee_outlined,
                                          color: Colors.grey,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 3),
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                      const SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width/3.5,
                          child: Text('Total ',
                              style: TextStyle(
                                  fontFamily: 'poppins',
                                  // fontSize: 13,
                                  fontWeight: FontWeight.w400)),
                        ),
                        // const SizedBox(width: 4),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: grey),
                                borderRadius: BorderRadius.circular(3)),
                            height: 35,
                            child: TextField(
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                              controller: TextEditingController(
                                  text: total.toStringAsFixed(decimal)),
                              readOnly: true,
                              // keyboardType:
                              //     const TextInputType
                              //         .numberWithOptions(
                              //         decimal: true),
                              // inputFormatters: [
                              //   FilteringTextInputFormatter(
                              //       RegExp(r'[0-9]'),
                              //       allow: true,
                              //       replacementString:
                              //           '.')
                              // ],
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                prefixIcon: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: const Border(
                                        right: BorderSide(color: grey)),
                                  ),
                                  width: 25,
                                  child: const Center(
                                    child: Icon(
                                      Icons.currency_rupee_outlined,
                                      color: Colors.grey,
                                      size: 15,
                                    ),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 3),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none),
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                      const SizedBox(
                      height: 6,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width/3.5,
                            child: const Text('MRP',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    // fontSize: 13,
                                    fontWeight: FontWeight.w400)),
                          ),
                          // const Spacer(),
                          // Flexible(
                          //   flex: 2,
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //         border: Border.all(color: Colors.orange),
                          //         borderRadius: BorderRadius.circular(3)),
                          //     height: 35,
                          //     child: TextField(
                          //       style: const TextStyle(fontSize: 14),
                          //       controller: controllerMrpPercentage,
                          //       focusNode: focusNodeMrpPercentage,
                          //       keyboardType:
                          //           const TextInputType.numberWithOptions(
                          //               decimal: true),
                          //       inputFormatters: [
                          //         FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          //             allow: true, replacementString: '.')
                          //       ],
                          //       onChanged: (value) {
                          //         setState(() {
                          //           mrpPercentage = double.tryParse(value)?? 0;
                          //           calculateRate();
                          //         });
                          //       },
                          //       decoration: InputDecoration(
                          //         suffixIcon: Container(
                          //           decoration: BoxDecoration(
                          //               color: Colors.orange[100],
                          //               border: const Border(
                          //                   left: BorderSide(
                          //                       color: Colors.orange)),
                          //               borderRadius: const BorderRadius.only(
                          //                   bottomRight: Radius.circular(3),
                          //                   topRight: Radius.circular(3))),
                          //           width: 25,
                          //           child: const Center(
                          //             child: Icon(
                          //               Icons.percent_sharp,
                          //               color: Colors.orange,
                          //               size: 15,
                          //             ),
                          //           ),
                          //         ),
                          //         contentPadding: const EdgeInsets.symmetric(
                          //             vertical: 6, horizontal: 3),
                          //         border: const OutlineInputBorder(
                          //             borderSide: BorderSide.none),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(width: 4),
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)),
                              height: 35,
                              child: TextField(
                                style: const TextStyle(fontSize: 13),
                                // focusNode: focusNodeMrp,
                                controller: controllerMrp,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                      allow: true, replacementString: '.')
                                ],
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: const Border(
                                          right: BorderSide(color: grey)),
                                    ),
                                    width: 25,
                                    child: const Center(
                                      child: Icon(
                                        Icons.currency_rupee_outlined,
                                        color: Colors.grey,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 3),
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    mrp = double.tryParse(value)?? 0;
                                    calculateRate();
                                  });
                                },
                              ),
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
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width/3.5,
                            child: const Text('Retail',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    // fontSize: 13,
                                    fontWeight: FontWeight.w400)),
                          ),
                          // const Spacer(),
                          // Flexible(
                          //   flex: 2,
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //         border: Border.all(color: Colors.orange),
                          //         borderRadius: BorderRadius.circular(3)),
                          //     height: 35,
                          //     child: TextField(
                          //       style: const TextStyle(fontSize: 13),
                          //       controller: controllerRetailPercentage,
                          //       focusNode: focusNodeRetailPercentage,
                          //       keyboardType:
                          //           const TextInputType.numberWithOptions(
                          //               decimal: true),
                          //       inputFormatters: [
                          //         FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          //             allow: true, replacementString: '.')
                          //       ],
                          //       onChanged: (value) {
                          //         setState(() {
                          //           retailPercentage = double.tryParse(value)?? 0;
                          //           calculateRate();
                          //         });
                          //       },
                          //       decoration: InputDecoration(
                          //         suffixIcon: Container(
                          //           decoration: BoxDecoration(
                          //               color: Colors.orange[100],
                          //               border: const Border(
                          //                   left: BorderSide(
                          //                       color: Colors.orange)),
                          //               borderRadius: const BorderRadius.only(
                          //                   bottomRight: Radius.circular(3),
                          //                   topRight: Radius.circular(3))),
                          //           width: 25,
                          //           child: const Center(
                          //             child: Icon(
                          //               Icons.percent_sharp,
                          //               color: Colors.orange,
                          //               size: 15,
                          //             ),
                          //           ),
                          //         ),
                          //         contentPadding: const EdgeInsets.symmetric(
                          //             vertical: 6, horizontal: 3),
                          //         border: const OutlineInputBorder(
                          //             borderSide: BorderSide.none),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(width: 4),
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)),
                              height: 35,
                              child: TextField(
                                style: const TextStyle(fontSize: 13),
                                // focusNode: focusNodeRetail,
                                controller: controllerRetail,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                      allow: true, replacementString: '.')
                                ],
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: const Border(
                                          right: BorderSide(color: grey)),
                                    ),
                                    width: 25,
                                    child: const Center(
                                      child: Icon(
                                        Icons.currency_rupee_outlined,
                                        color: Colors.grey,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 3),
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    retail = double.tryParse(value)?? 0;
                                    calculateRate();
                                  });
                                },
                              ),
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
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width/3.5,
                            child: const Text('Wholesale',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    // fontSize: 12.5,
                                    fontWeight: FontWeight.w300)),
                          ),
                          // const Spacer(),
                          // Flexible(
                          //   flex: 2,
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //         border: Border.all(color: Colors.orange),
                          //         borderRadius: BorderRadius.circular(3)),
                          //     height: 35,
                          //     child: TextField(
                          //       style: const TextStyle(fontSize: 13),
                          //       controller: controllerWholeSalePercentage,
                          //       focusNode: focusNodeWholeSalePercentage,
                          //       keyboardType:
                          //           const TextInputType.numberWithOptions(
                          //               decimal: true),
                          //       inputFormatters: [
                          //         FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          //             allow: true, replacementString: '.')
                          //       ],
                          //       onChanged: (value) {
                          //         setState(() {
                          //           wholeSalePercentage =
                          //               double.tryParse(value) ?? 0;
                          //           calculateRate();
                          //         });
                          //       },
                          //       decoration: InputDecoration(
                          //         suffixIcon: Container(
                          //           decoration: BoxDecoration(
                          //               color: Colors.orange[100],
                          //               border: const Border(
                          //                   left: BorderSide(
                          //                       color: Colors.orange)),
                          //               borderRadius: const BorderRadius.only(
                          //                   bottomRight: Radius.circular(3),
                          //                   topRight: Radius.circular(3))),
                          //           width: 25,
                          //           child: const Center(
                          //             child: Icon(
                          //               Icons.percent_sharp,
                          //               color: Colors.orange,
                          //               size: 15,
                          //             ),
                          //           ),
                          //         ),
                          //         contentPadding: const EdgeInsets.symmetric(
                          //             vertical: 6, horizontal: 3),
                          //         border: const OutlineInputBorder(
                          //             borderSide: BorderSide.none),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(width: 4),
                          Flexible(
                            flex: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)),
                              height: 35,
                              child: TextField(
                                style: const TextStyle(fontSize: 13),
                                // focusNode: focusNodeWholeSale,
                                controller: controllerWholeSale,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                      allow: true, replacementString: '.')
                                ],
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: const Border(
                                          right: BorderSide(color: grey)),
                                    ),
                                    width: 25,
                                    child: const Center(
                                      child: Icon(
                                        Icons.currency_rupee_outlined,
                                        color: Colors.grey,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 3),
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    wholeSale = double.tryParse(value)?? 0;
                                    calculateRate();
                                  });
                                },
                              ),
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
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width/3.5,
                            child: const Text('Branch',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    // fontSize: 13,
                                    fontWeight: FontWeight.w400)),
                          ),
                          // const Spacer(),
                          // Flexible(
                          //   flex: 2,
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //         border: Border.all(color: Colors.orange),
                          //         borderRadius: BorderRadius.circular(3)),
                          //     height: 35,
                          //     child: TextField(
                          //       style: const TextStyle(fontSize: 13),
                          //       controller: controllerBranchPercentage,
                          //       focusNode: focusNodeBranchPercentage,
                          //       keyboardType:
                          //           const TextInputType.numberWithOptions(
                          //               decimal: true),
                          //       inputFormatters: [
                          //         FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          //             allow: true, replacementString: '.')
                          //       ],
                          //       onChanged: (value) {
                          //         setState(() {
                          //           branchPercentage = double.tryParse(value)?? 0;
                          //           calculateRate();
                          //         });
                          //       },
                          //       decoration: InputDecoration(
                          //         suffixIcon: Container(
                          //           decoration: BoxDecoration(
                          //               color: Colors.orange[100],
                          //               border: const Border(
                          //                   left: BorderSide(
                          //                       color: Colors.orange)),
                          //               borderRadius: const BorderRadius.only(
                          //                   bottomRight: Radius.circular(3),
                          //                   topRight: Radius.circular(3))),
                          //           width: 25,
                          //           child: const Center(
                          //             child: Icon(
                          //               Icons.percent_sharp,
                          //               color: Colors.orange,
                          //               size: 15,
                          //             ),
                          //           ),
                          //         ),
                          //         contentPadding: const EdgeInsets.symmetric(
                          //             vertical: 6, horizontal: 3),
                          //         border: const OutlineInputBorder(
                          //             borderSide: BorderSide.none),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(width: 4),
                          Flexible(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)),
                              height: 35,
                              child: TextField(
                                style: const TextStyle(fontSize: 13),
                                // focusNode: focusNodeBranch,
                                controller: controllerBranch,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter(RegExp(r'[0-9]'),
                                      allow: true, replacementString: '.')
                                ],
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      border: const Border(
                                          right: BorderSide(color: grey)),
                                    ),
                                    width: 25,
                                    child: const Center(
                                      child: Icon(
                                        Icons.currency_rupee_outlined,
                                        color: Colors.grey,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 3),
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    branch = double.tryParse(value)?? 0;
                                    calculateRate();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                      ],
                    ),
              )
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
                  onTap:editItem ? () {
                     setState(() {
                      cartItem.removeAt(position!);
                      clearValue();
                      calculateTotal();
                      nextWidget = 0;
                    });
                  } :() {
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
                    else {
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

                      // if (editItem) {
                      //   cartItem[position!].adCess = adCess;
                      //   cartItem[position!].barcode = barcode;
                      //   cartItem[position!].branch = branch;
                      //   cartItem[position!].branchPer = branchPer;
                      //   cartItem[position!].cDisc = cDisc;
                      //   cartItem[position!].cGST = csGST;
                      //   cartItem[position!].cdPer = cdPer;
                      //   cartItem[position!].cess = cess;
                      //   cartItem[position!].discount = discount;
                      //   cartItem[position!].discountPercent = discountPer;
                      //   // cartItem[position!].expDate = expDate;
                      //   // cartItem[position!].expense = expense;
                      //   cartItem[position!].fCess = fCess;
                      //   cartItem[position!].fUnitId = fUnitId;
                      //   cartItem[position!].fUnitValue = fUnitValue;
                      //   cartItem[position!].free = free;
                      //   cartItem[position!].gross = subTotal;
                      //   cartItem[position!].iGST = iGST;
                      //   // cartItem[position!].id = cartItem.length + 1;
                      //   // cartItem[position!].itemId = productModel['slno'];
                      //   // cartItem[position!].itemName = productModel['itemname'];
                      //   // cartItem[position!].location = locationId;
                      //   cartItem[position!].mrp = mrp;
                      //   cartItem[position!].mrpPer = mrpPer;
                      //   cartItem[position!].net = net;
                      //   cartItem[position!].profitPer = profitPer;
                      //   cartItem[position!].quantity = quantity;
                      //   cartItem[position!].rRate = rRate;
                      //   cartItem[position!].rate = rate;
                      //   cartItem[position!].retail = retail;
                      //   cartItem[position!].retailPer = retailPer;
                      //   cartItem[position!].sGST = csGST;
                      //   cartItem[position!].serialNo = serialNo;
                      //   cartItem[position!].spRetail = spRetail;
                      //   cartItem[position!].spRetailPer = spRetailPer;
                      //   cartItem[position!].tax = tax;
                      //   cartItem[position!].taxP = taxP;
                      //   cartItem[position!].total = total;
                      //   cartItem[position!].uniqueCode = uniqueCode;
                      //   // cartItem[position!].unitId = unit.id;
                      //   // cartItem[position!].unitName = unit.name;
                      //   cartItem[position!].unitValue = unitValue;
                      //   cartItem[position!].wholesale = wholeSale;
                      //   cartItem[position!].wholesalePer = wholesalePer;
                      // } else {
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
                            itemId: selectedItem.slNo,
                            itemName: selectedItem.itemName,
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
                      // }
                      if (cartItem.isNotEmpty) {
                        editItem = false;
                        // nextWidget = 0;
                        clearValue();
                        calculateTotal();
                      }
                    });
                  }
                  },
                  child: Container(
                                height: 60,
                                color: Colors.white,
                                child:  Center(
                                  child: Text(
                                    editItem ? 'Delete': 'Save & New',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                ),
              )),
              Expanded(child: 
              Material(
                color: Colors.transparent,
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
                    else {
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
                            itemId: selectedItem.slNo,
                            itemName: selectedItem.itemName,
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
                      if (cartItem.isNotEmpty ) {
                        editItem = false;
                        nextWidget = 0;
                        clearValue();
                        calculateTotal();
                      }
                    });
                    }
                  },
                  child: Container(
                                height: 60,
                                color: kPrimaryColor,
                                child:  const Center(
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
              )
              )
        ]),
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
                  return InkWell(
                    onTap: () {
                      showEditDialog(context, dataDisplay[index]);
                    },
                    child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        height: 80,
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
        // ListView.builder(
        //     itemCount: dataDisplay.length + 1,
        //     itemBuilder: (BuildContext context, int index) {
        //       if (index == dataDisplay.length) {
        //         return Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: Center(
        //             child: Opacity(
        //               opacity: isLoadingData ? 1.0 : 00,
        //               child: const CircularProgressIndicator(),
        //             ),
        //           ),
        //         );
        //       } else {
        //         return Card(
        //           elevation: 2,
        //           child: ListTile(
        //             title: Text(dataDisplay[index]['Name']),
        //             subtitle: Text('Date: ' +
        //                 dataDisplay[index]['Date'] +
        //                 ' / EntryNo : ' +
        //                 dataDisplay[index]['Id'].toString()),
        //             trailing: Text(
        //                 'Total : ' + dataDisplay[index]['Total'].toString()),
        //             onTap: () {
        //               showEditDialog(context, dataDisplay[index]);
        //             },
        //           ),
        //         );
        //       }
        //     },
        //     controller: _scrollController,
        //   )
        : Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("No items in Purchase Order",
              style: TextStyle(
                fontFamily: 'poppins'
              ),
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
                  label: const Text('Take New Purchase Order',
                  style: TextStyle(
                fontFamily: 'poppins'
              ),
                  ))
            ],
          ));
  }

  bool isData = false;

selectLedgerWidget() {
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
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        decoration: const InputDecoration(
                          constraints: BoxConstraints(
                            // maxHeight: 45
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8
                          ),
                          border: OutlineInputBorder(),
                          label: Text('Search...'),
                        ),
                        onChanged: (text) {
                          text = text.toLowerCase();
                          setState(() {
                            ledgerDisplay = _ledger.where((item) {
                              var itemName = item.name.toLowerCase();
                              return itemName.contains(text);
                            }).toList();
                          });
                        },
                      ),
                    ),
                    IconButton(
                      style: ButtonStyle(
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)
                          )
                        ),
                        backgroundColor: const MaterialStatePropertyAll(kPrimaryColor)
                      ),
                      icon: const Icon(
                        Icons.add,
                        color: white,
                      ),
                      onPressed: () {
                        isData = false;
                        Navigator.pushNamed(context, '/ledger',
                            arguments: {'parent': 'SUPPLIERS'});
                      },
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 4,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            color: white,
                            border: Border.all(
                              color: grey
                            ),
                            borderRadius: BorderRadius.circular(3)
                          ),
                          child: ListTile(
                              title: Text(ledgerDisplay[index].name)),
                        ),
                        onTap: () {
                          setState(() {
                            ledgerModel = ledgerDisplay[index];
                            nextWidget = 1;
                            isData = false;
                          });
                        },
                      ),
                    );
                  },
                  itemCount: ledgerDisplay.length,
                ),
              ),
            ],
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


  // selectLedgerWidget() {
  //   setState(() {
  //     if (_ledger.isNotEmpty) isData = true;
  //   });
  //   return FutureBuilder<List<dynamic>>(
  //     future: dio.getSalesListData('', 'sales_list/supplier'),
  //     builder: (ctx, snapshot) {
  //       if (snapshot.hasData) {
  //         if (snapshot.data!.isNotEmpty) {
  //           var data = snapshot.data;
  //           if (!isData) {
  //             ledgerDisplay = data!;
  //             _ledger = data;
  //           }
  //           return ListView.builder(
  //             // shrinkWrap: true,
  //             itemBuilder: (context, index) {
  //               return index == 0
  //                   ? Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: Row(
  //                         children: [
  //                           Flexible(
  //                             child: TextField(
  //                               decoration: const InputDecoration(
  //                                 border: OutlineInputBorder(),
  //                                 label: Text('Search...'),
  //                               ),
  //                               onChanged: (text) {
  //                                 text = text.toLowerCase();
  //                                 setState(() {
  //                                   ledgerDisplay = _ledger.where((item) {
  //                                     var itemName = item.name.toLowerCase();
  //                                     return itemName.contains(text);
  //                                   }).toList();
  //                                 });
  //                               },
  //                             ),
  //                           ),
  //                           IconButton(
  //                             icon: const Icon(
  //                               Icons.add_circle,
  //                               color: kPrimaryColor,
  //                             ),
  //                             onPressed: () {
  //                               isData = false;
  //                               Navigator.pushNamed(context, '/ledger',
  //                                   arguments: {'parent': 'SUPPLIERS'});
  //                             },
  //                           )
  //                         ],
  //                       ),
  //                     )
  //                   : InkWell(
  //                       child: Card(
  //                         child: ListTile(
  //                             title: Text(ledgerDisplay[index - 1].name)),
  //                       ),
  //                       onTap: () {
  //                         setState(() {
  //                           ledgerModel = ledgerDisplay[index - 1];
  //                           nextWidget = 1;
  //                           isData = false;
  //                         });
  //                       },
  //                     );
  //             },
  //             itemCount: ledgerDisplay.length + 1,
  //           );
  //         } else {
  //           return Center(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: const [SizedBox(height: 20), Text('No Data Found..')],
  //             ),
  //           );
  //         }
  //       } else if (snapshot.hasError) {
  //         return AlertDialog(
  //           title: const Text(
  //             'An Error Occurred!',
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               color: Colors.redAccent,
  //             ),
  //           ),
  //           content: Text(
  //             "${snapshot.error}",
  //             style: const TextStyle(
  //               color: Colors.blueAccent,
  //             ),
  //           ),
  //           actions: <Widget>[
  //             TextButton(
  //               child: const Text(
  //                 'Go Back',
  //                 style: TextStyle(
  //                   color: Colors.redAccent,
  //                 ),
  //               ),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             )
  //           ],
  //         );
  //       }
  //       return Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: const [
  //             CircularProgressIndicator(),
  //             SizedBox(height: 20),
  //             Text('This may take some time..')
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  purchaseHeaderWidget() {
    return Center(
        child: Column(
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Date : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          child: Text(
                            formattedDate!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () => _selectDate('f'),
                        ),
                        const Text(
                          'Tax:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Checkbox(
                          checkColor: Colors.greenAccent,
                          activeColor: Colors.red,
                          value: isTax,
                          onChanged: (bool? value) {
                            setState(() {
                              isTax = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('Inv.No:'),
                        SizedBox(
                          width: 100,
                          height: 20,
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            controller: invNoController,
                          ),
                        ),
                        const Text('Inv.Date:'),
                        InkWell(
                          child: Text(invDate!),
                          onTap: () => _selectDate('t'),
                        ),
                      ],
                    ),
                    ListTile(
                      title: Text(ledgerModel.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
              }),
        ),
        InkWell(
            child: const SizedBox(
              height: 40,
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
 

  bool isItemData = false;
  selectProductWidget() {
    setState(() {
      if (items.isNotEmpty) isItemData = true;
    });
    return FutureBuilder<List<ProductPurchaseModel>>(
      future: dio.fetchAllProductPurchase(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            if (!isItemData) {
              itemDisplay = data!;
              items = data;
            }
            return ListView.builder(
              itemBuilder: (context, index) {
                return index == 0
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Flexible(
                              child: TextField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  label: Text('Search...'),
                                ),
                                onChanged: (text) {
                                  text = text.toLowerCase();
                                  setState(() {
                                    itemDisplay = items.where((item) {
                                      var itemName = item.itemName;
                                      return itemName.contains(text);
                                    }).toList();
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
                                setState(() {
                                  items = [];
                                  itemDisplay = [];
                                  isItemData = false;
                                });
                                Navigator.pushNamed(context, '/product');
                              },
                            )
                          ],
                        ),
                      )
                    : InkWell(
                        child: Card(
                          child: ListTile(
                              title: Text(itemDisplay[index - 1].itemName)),
                        ),
                        onTap: () {
                          setState(() {
                            productModel = itemDisplay[index - 1];
                            nextWidget = 3;
                            isItemData = false;
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

  bool _isPrize = false;
  itemDetails() {
    int id = productModel['slno'];
    dio.fetchProductPrize(id).then((value) {
      productModelPrize = value[0];
      setState(() {
        _isPrize = true;
      });
    });

    return _isPrize ? itemDetailWidget() : const Loading();
  }

  TextEditingController controllerQuantity = TextEditingController();
  TextEditingController controllerRate = TextEditingController();
  TextEditingController controllerDiscountPer = TextEditingController();
  TextEditingController controllerDiscount = TextEditingController();
  TextEditingController controllerMrp = TextEditingController();
  TextEditingController controllerRetail = TextEditingController();
  TextEditingController controllerWholeSale = TextEditingController();
  TextEditingController controllerBranch = TextEditingController();
  FocusNode focusNodeRate = FocusNode();
  FocusNode focusNodeDiscountPer = FocusNode();
  FocusNode focusNodeDiscount = FocusNode();

  double quantity = 0,
      rate = 0,
      currentRate = 0,
      subTotal = 0,
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

  itemDetailWidget() {
    if (editItem) {
      // adCessPer = double.tryParse(productModel['adcessper'].toString());
      // cessPer = double.tryParse(productModel['cessper'].toString());
      taxP = cartItem.elementAt(position!).taxP;
      // kfcP = double.tryParse(productModel['KFC'].toString());
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
      adCessPer = double.tryParse(productModel['adcessper'].toString())!;
      cessPer = double.tryParse(productModel['cessper'].toString())!;
      taxP = double.tryParse(productModel['tax'].toString())!;
      kfcP = double.tryParse(productModel['KFC'].toString())!;
      rate = double.tryParse(productModelPrize['prate'].toString())!;
      if (rate > 0 && !editableRate) {
        controllerRate.text = rate.toString();
      }
      if (double.tryParse(productModelPrize['realprate'].toString())! > 0) {
        rRate = double.tryParse(productModelPrize['realprate'].toString())!;
      }
      mrp = double.tryParse(productModelPrize['mrp'].toString())!;
      if (mrp > 0 && !editableMrp) {
        controllerMrp.text = mrp.toString();
      }
      retail = double.tryParse(productModelPrize['retail'].toString())!;
      if (retail > 0 && !editableRetail) {
        controllerRetail.text = retail.toString();
      }
      wholeSale = double.tryParse(productModelPrize['wsrate'].toString())!;
      if (wholeSale > 0 && !editableWSale) {
        controllerWholeSale.text = wholeSale.toString();
      }
      spRetail = double.tryParse(productModelPrize['spretail'].toString())!;
      branch = double.tryParse(productModelPrize['branch'].toString())!;
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

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Item : ${editItem ? cartItem.elementAt(position!).itemName : productModel['itemname']}')),
            Row(
              children: [
                Expanded(
                    child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      nextWidget = 2;
                      editItem = false;
                    });
                  },
                  child: const Text("Back"),
                  color: blue[400],
                )),
                const SizedBox(
                  width: 2,
                ),
                Expanded(
                    child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      nextWidget = 4;
                      editItem = false;
                      clearValue();
                    });
                  },
                  child: const Text("Cancel"),
                  color: blue[400],
                )),
                const SizedBox(
                  width: 2,
                ),
                Expanded(
                    child: MaterialButton(
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
                            itemId: productModel['slno'],
                            itemName: productModel['itemname'],
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
                        editItem = false;
                        nextWidget = 4;
                        clearValue();
                      }
                    });
                  },
                  child: Text(editItem ? "Edit" : "Add"),
                  color: blue,
                )),
              ],
            ),
            const Divider(),
            TextField(
              controller: controllerQuantity,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text('Quantity')),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                    allow: true, replacementString: '.')
              ],
              onChanged: (value) {
                setState(() {
                  editableQuantity = true;
                  quantity = double.tryParse(value)!;
                  calculate();
                });
              },
            ),
            const Divider(),
            DropdownSearch<dynamic>(
              popupProps: const PopupPropsMultiSelection.modalBottomSheet(
                  showSearchBox: true,
                  constraints: BoxConstraints(maxHeight: 300)),
              asyncItems: (String filter) =>
                  dio.getSalesListData(filter, 'sales_list/unit'),
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                    border: OutlineInputBorder(), label: Text('Select Unit')),
              ),
              onChanged: (dynamic data) {
                unit = data;
                calculate();
              },
            ),
            const Divider(),
            TextField(
              controller: controllerRate,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text('P Rate')),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter(RegExp(r'[0-9]'),
                    allow: true, replacementString: '.')
              ],
              onChanged: (value) {
                setState(() {
                  editableRate = true;
                  rate = double.tryParse(value)!;
                  calculate();
                });
              },
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Subtotal :'),
                Text(subTotal.toStringAsFixed(decimal)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Discount'),
                SizedBox(
                  height: 30,
                  width: 50,
                  child: TextField(
                    controller: controllerDiscountPer,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text(' % ')),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          allow: true, replacementString: '.')
                    ],
                    onChanged: (value) {
                      setState(() {
                        editableDiscountP = true;
                        discountPer = double.tryParse(value)!;
                        calculate();
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 100,
                  child: TextField(
                    controller: controllerDiscount,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text('discount')),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          allow: true, replacementString: '.')
                    ],
                    onChanged: (value) {
                      setState(() {
                        editableDiscount = true;
                        discount = double.tryParse(value)!;
                        calculate();
                      });
                    },
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 30,
                  width: 100,
                  child: TextField(
                    controller: controllerMrp,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text('MRP')),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          allow: true, replacementString: '.')
                    ],
                    onChanged: (value) {
                      setState(() {
                        editableMrp = true;
                        mrp = double.tryParse(value)!;
                        calculateRate();
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 100,
                  child: TextField(
                    controller: controllerRetail,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text('Retail')),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          allow: true, replacementString: '.')
                    ],
                    onChanged: (value) {
                      setState(() {
                        editableRetail = true;
                        retail = double.tryParse(value)!;
                        calculateRate();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 30,
                  width: 100,
                  child: TextField(
                    controller: controllerWholeSale,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text('WholeSale')),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          allow: true, replacementString: '.')
                    ],
                    onChanged: (value) {
                      setState(() {
                        editableWSale = true;
                        wholeSale = double.tryParse(value)!;
                        calculateRate();
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 100,
                  child: TextField(
                    controller: controllerBranch,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text('Branch')),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          allow: true, replacementString: '.')
                    ],
                    onChanged: (value) {
                      setState(() {
                        editableBranch = true;
                        branch = double.tryParse(value)!;
                        calculateRate();
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
                const Text('Net :'),
                Text(net.toStringAsFixed(decimal)),
              ],
            ),
            Visibility(
              visible: isTax,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isTax ? 'Tax ${taxP.toStringAsFixed(0)} % : ' : 'Tax :'),
                  Text(tax.toStringAsFixed(decimal)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  total.toStringAsFixed(decimal),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
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
        const Divider(
          height: 2.0,
          thickness: 2,
        ),
        Expanded(
          child: ListView.separated(
            itemCount: cartItem.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(cartItem[index].itemName),
                subtitle: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Q:${cartItem[index].quantity}'),
                        Text(cartItem[index].unitName),
                        Text(
                            'R:${CommonService.getRound(decimal, cartItem[index].rate)}'),
                        Text(
                            ' = ${CommonService.getRound(decimal, cartItem[index].gross)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cartItem[index].discount > 0
                            ? Text(
                                ' discount ${CommonService.getRound(decimal, cartItem[index].discount)}')
                            : Container(),
                        isTax
                            ? Text('Tax ${cartItem[index].tax}')
                            : Container(),
                        Text(
                          'total = ${CommonService.getRound(decimal, cartItem[index].total)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
              );
            },
          ),
        ),
        const Divider(
          height: 2,
          thickness: 2,
        ),
        footerWidget(),
      ],
    );
  }

  TextEditingController cashPaidController = TextEditingController();
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
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
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
                  style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red))
            ],
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: SizedBox(
                  // width: 30,
                  height: 40,
                  child: TextField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp(r'[0-9]'),
                          allow: true, replacementString: '.')
                    ],
                    decoration: const InputDecoration(
                      label: Text('Cash Paid: '),
                      border: OutlineInputBorder(),
                    ),
                    controller: cashPaidController,
                    onChanged: (value) {
                      setState(() {
                        _balance = double.tryParse(value)! > 0
                            ? totalCartTotal > 0
                                ? totalCartTotal - double.tryParse(value)!
                                : 0
                            : totalCartTotal > 0
                                ? totalCartTotal
                                : 0;
                      });
                    },
                  ),
                ),
              ),
              const Text('Balance : '),
              Text(
                  ComSettings.appSettings('bool', 'key-round-off-amount', false)
                      ? _balance.toStringAsFixed(2)
                      : _balance.roundToDouble().toString()),
            ],
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
    productNameController.text = '';
    selectedProducteId = 0;
    taxP = 0;
    tax = 0;
    mrp = 0;
    branch = 0;
    wholeSale = 0;
    retail = 0;
    subTotal = 0;
    net = 0 ;
    total = 0;
    _dropDownUnit = 0;
    editableQuantity = false;
    editableMrp = false;
    editableRetail = false;
    editableWSale = false;
    editableBranch = false;
    editableRate = false;
    editableDiscount = false;
    editableDiscountP = false;
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

    api.fetchPurchaseInvoiceSp(data['Id'], 'PO_Find',voucherTypeData!.id).then((value) {
      if (value != null) {
        var information = value['Information'][0];
        var particulars = value['Particulars'];
        // var serialNO = value['SerialNO'];
        // var deliveryNoteDetails = value['DeliveryNote'];
        if (value['otherAmount'] != null) {
          otherAmountList = value['otherAmount'];
        }
        // otherAmountList = value['otherAmount'];

        formattedDate = DateUtil.dateDMY(information['DDate']);

        dataDynamic = [
          {
            'RealEntryNo': information['EntryNo'],
            'EntryNo': information['EntryNo'],
            'InvoiceNo': information['Sup_Inv'],
            'Type': '0'
          }
        ];
        billCash = double.tryParse(information['CashPaid'].toString())!;
        billTotal = double.tryParse(information['GrandTotal'].toString())!;
        narration = information['Narration'];
        DataJson cModel =
            DataJson(id: information['Supplier'], name: information['FromSup']);
        ledgerModel = cModel;
        selectedCustomerId = cModel.id;
        supplierNameController.text = cModel.name.toString();
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
          cashPaidController.text = billCash.toStringAsFixed(decimal);
        }
        _narration = narration;
        // nextWidget = 4;
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
    dio.deletePurchase(dataDynamic[0]['EntryNo'], 'PO_Delete',voucherTypeData!.id).then((value) {
      setState(() {
        _isLoading = false;
      });
      if (value) {
        cartItem.clear();
        clearValue();
        Navigator.pushReplacementNamed(context, '/purchaseOrder');
         Fluttertoast.showToast(
          backgroundColor: green,
          msg: 'Sale Bill Deleted'); 
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return Expanded(
        //       child: AlertDialog(
        //         title: const Text('Purchase Order Deleted'),
        //         actions: [
        //           TextButton(
        //             onPressed: () {
        //               Navigator.of(context).pop();
        //               Navigator.pushReplacementNamed(context, '/purchaseOrder');
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
}

showMore(context, purchaseState) {
  ConfirmAlertBox(
      buttonColorForNo: Colors.white,
      buttonColorForYes: Colors.green,
      icon: Icons.check,
      onPressedYes: () {
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, '/purchaseOrder');
      },
      // buttonTextForNo: 'No',
      buttonTextForYes: 'OK',
      infoMessage: 'Purchase Order $purchaseState',
      title: 'SAVED',
      context: context);
}
