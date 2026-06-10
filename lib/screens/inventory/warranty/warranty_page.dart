import 'dart:convert';

import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/stock_product.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/screens/html_previews/purchase_return_preview.dart';
import 'package:sheraccerp/screens/inventory/cart.dart';
import 'package:sheraccerp/screens/inventory/warranty/warranty_cart_model.dart';
import 'package:sheraccerp/screens/inventory/warranty/warranty_complaint_model.dart';
import 'package:sheraccerp/screens/inventory/warranty/warranty_customer_model.dart';
import 'package:sheraccerp/screens/inventory/warranty/warranty_replace_model.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/service/com_service.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/color_palette.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/container_textfield_widget.dart';
import 'package:sheraccerp/widget/pdf_screen.dart';
import 'package:sheraccerp/widget/progress_hud.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pw;

class Warranty extends StatefulWidget {
  const Warranty({super.key});

  @override
  State<Warranty> createState() => _WarrantyState();
}

class _WarrantyState extends State<Warranty> {
   final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false, buttonEvent = false;
  DioService api = DioService();
  Size? deviceSize;
  String? formattedDate ;
  String? warrentyformattedDate ;
  DateTime now = DateTime.now();
  int page = 1, pageTotal = 0, totalRecords = 0;
  int lId = 0, groupId = 0, areaId = 0, routeId = 0;
  var salesManId = 0;
  int saleAccount = 0, acId = 0, decimal = 2;
   List<WarrantyCart> cart  = [];
   List<WarrantyRepalceModel> replacementCart = [];
   WarrantyCustomerModel? customer ;
   List<WarrantyComplaintModel> complaint = [];
   Future<List<dynamic>>? _getledgerListData;
   Future<List<dynamic>>? _getProductList;
   Future<List<dynamic>>? _getAllProductList;
   late List<dynamic> itemNameList;
    late List<String> names;
   bool isTax = true,
      otherAmountLoaded = false,
      valueMore = false,
      lastRecord = false,
      widgetID = true,
      previewData = false,
      oldBill = false,
      itemCodeVise = false,
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
      isFreeQty = false,
      gstVerified = false,
      gstValidation = false,
      isAdminUser = false,
      taxable = true,
      taxGroupUpdate = false;

  bool isLoading = false; 
  bool isPrLoading = false; 
    final List<String> statusOptions = [
    'Pending',
    // 'Repair',
    // 'Replace',
    // 'Reject',
    // 'Transfer To Mfr',
    // 'Sales Return',
  ];  
  var nameLike = "a"; 
  
   @override
  void initState() {
    super.initState();
    formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);
    warrentyformattedDate =  
     getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);  

    // loadSettings();
     salesManId = ComSettings.appSettings(
            'int', 'key-dropdown-default-salesman-view', 1) -
        1;
    lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    isAdminUser =
        companyUserData!.userType.toUpperCase() == 'ADMIN' ? true : false;  
    // isSalesManWiseLedger =
    //  ComSettings.getStatus('KEY SALESMAN WISE LEDGER', settings!);
    loadSettings();
    // _fetchProductList();
    //  _getledgerListData = isSalesManWiseLedger
    //       ? api.getLedgerBySalesMan(salesManId,)
    //       : api.getLedgersAll(); 
    // getLedger(nameLike);   
  }
   CompanyInformation? companySettings;
   List<CompanySettings>? settings;
   
   loadSettings() {
        companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();
    isSalesManWiseLedger = 
        ComSettings.getStatus('KEY SALESMAN WISE LEDGER', settings!);
    taxGroupUpdate = 
        ComSettings.getStatus('KEY TAXGROUP UPDATE', settings!);     
        _getledgerListData = isSalesManWiseLedger
          ? api.getLedgerBySalesMan(salesManId,)
          : api.getLedgersAll();
        _getProductList = api.fetchStockProductLike(DateUtil.dateDMY2YMD(formattedDate),nameLike);
        _getAllProductList = api.fetchNoStockProductLike(DateUtil.dateDMY2YMD(formattedDate),nameLike);
          
   }
  //  void _fetchProductList() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     final fetchedList = await api.fetchStockProductLike(
  //       DateUtil.dateDMY2YMD(formattedDate),
  //       itemNameLike,
  //     );
  //     setState(() {
  //       itemNameList = fetchedList;
  //       names = itemNameList
  //           .map((e) => isSalesManWiseLedger ? e.name : e['LedName'])
  //           .where((name) => name != null)
  //           .cast<String>()
  //           .toList();
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     print('Error fetching product list: $e');
  //   }
  // }  
  
  //  getLedger(String like){
     
  //  }
String itemNameLike = 'a';
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
    // if (nextWidget == 3) {
    //   return (await showDialog(
    //         context: context,
    //         builder: (context) => AlertDialog(
    //           title: const Text('Back'),
    //           content: const Text('Select Item Again?'),
    //           actions: [
    //             TextButton(
    //               onPressed: () {
    //                 setState(() {
    //                   nextWidget = 2;
    //                   clearValue();
    //                 });
    //                 Navigator.of(context).pop(false);
    //               },
    //               child: const Text('Select'),
    //             ),
    //           ],
    //         ),
    //       )) ??
    //       false;
    // } else if (loadReturnForm) {
    //   setState(() {
    //     loadReturnForm = false;
    //     returnBillId = getReturnBillNo != null
    //         ? getReturnBillNo > 0
    //             ? getReturnBillNo
    //             : 0
    //         : 0;
    //     returnEntryNoController.text = getReturnBillNo != null
    //         ? getReturnBillNo > 0
    //             ? getReturnBillNo.toString()
    //             : ''
    //         : '';
    //     returnAmount = getReturnBillAmount != null
    //         ? getReturnBillAmount > 0
    //             ? getReturnBillAmount
    //             : 0
    //         : 0;
    //     returnAmountController.text = getReturnBillAmount != null
    //         ? getReturnBillAmount > 0
    //             ? getReturnBillAmount.toString()
    //             : ''
    //         : '';
    //     if (returnAmount > 0) {
    //       grandTotal = grandTotal - returnAmount;
    //     }
    //   });
    // } else {
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to exit Warranty Page'),
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
    // }
  }
   widgetSuffix() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bagroundColor,
          key: _scaffoldKey,
          appBar: (nextWidget != 1 && nextWidget != 2) ? AppBar(
            title: const Text("Warranty"),
            titleTextStyle: const TextStyle(
              fontFamily: 'poppins',
              color: white
            ),
            // actions: [
            //   Visibility(
            //     visible: enableBarcode,
            //     child: IconButton(
            //         onPressed: () {
            //           searchProductBarcode();
            //         },
            //         icon: const Icon(Icons.document_scanner)),
            //   ),
            //   Visibility(
            //     visible: oldBill,
            //     child: IconButton(
            //         color: red,
            //         iconSize: 40,
            //         onPressed: () {
            //           if (buttonEvent) {
            //             return;
            //           } else {
            //             if (companyUserData!.deleteData) {
            //               if (totalItem > 0) {
            //                 setState(() {
            //                   _isLoading = true;
            //                   buttonEvent = true;
            //                 });
            //                 deleteDeliveryNote(context);
            //               } else {
            //                 Fluttertoast.showToast(
            //                     msg: 'Please select at least one bill');
            //                 setState(() {
            //                   buttonEvent = false;
            //                 });
            //               }
            //             } else {
            //               Fluttertoast.showToast(
            //                   msg: 'Permission denied\ncan`t delete');
            //               setState(() {
            //                 buttonEvent = false;
            //               });
            //             }
            //           }
            //         },
            //         icon: const Icon(Icons.delete_forever)),
            //   ),
            //   oldBill
            //       ? IconButton(
            //           color: green,
            //           iconSize: 40,
            //           onPressed: () {
            //             if (buttonEvent) {
            //               return;
            //             } else {
            //               if (companyUserData!.updateData) {
            //                 if (totalItem > 0) {
            //                   setState(() {
            //                     _isLoading = true;
            //                     buttonEvent = true;
            //                   });
            //                   updateDeliveryNote();
            //                 } else {
            //                   Fluttertoast.showToast(
            //                       msg: 'Please select at least one bill');
            //                   setState(() {
            //                     buttonEvent = false;
            //                   });
            //                 }
            //               } else {
            //                 Fluttertoast.showToast(
            //                     msg: 'Permission denied\ncan`t edit');
            //                 setState(() {
            //                   buttonEvent = false;
            //                 });
            //               }
            //             }
            //           },
            //           icon: const Icon(Icons.edit))
            //       : IconButton(
            //           color: white,
            //           iconSize: 40,
            //           onPressed: () {
            //             if (buttonEvent) {
            //               return;
            //             } else {
            //               if (companyUserData!.insertData) {
            //                 if (totalItem > 0) {
            //                   setState(() {
            //                     _isLoading = true;
            //                     buttonEvent = true;
            //                   })
            //                   saveDeliveryNote();
            //                 } else {
            //                   Fluttertoast.showToast(
            //                       msg: 'Please add at least one item');
            //                   setState(() {
            //                     buttonEvent = false;
            //                   });
            //                 }
            //               } else {
            //                 Fluttertoast.showToast(
            //                     msg: 'Permission denied\ncan`t save');
            //                 setState(() {
            //                   buttonEvent = false;
            //                 });
            //               }
            //             }
            //           },
            //           icon:Image.asset('assets/icons/Save instagram@2x.png',scale: 1.6,)),
            // ],  
          ): null,
          body: ProgressHUD(
              inAsyncCall: _isLoading, opacity: 0.0, child: selectWidget())),
    );
  }

  widgetPrefix() {
    return Scaffold(
      backgroundColor: bagroundColor,
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text("Warranty "),
          titleTextStyle: const TextStyle(
            fontFamily: 'poppins',
            color: white
          ),
          actions: [
            TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue[700],
                ),
                 onPressed: () async {
        setState(() {
          isLoading = true; 
        });
        try {
          final value = await api.getWarrantyEntryNo('Reseed');
          debugPrint(value);
          setState(() {
            entryNo = value;
            entryNoController .text = entryNo;
            widgetID = false; 
          });
        } catch (error) {
          debugPrint("Error: $error");
        } finally {
          setState(() {
            isLoading = false; 
          });
        }
      },
                child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          :  const Text(
                  'New',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
          ],
        ),
        body: Padding(
           padding: const EdgeInsets.symmetric(
                horizontal: 16,vertical: 8
              ),
          child: Container(
            child: isPrLoading ? const Center(child: CircularProgressIndicator()) : previousBill(),
          ),
        ));
  }
    final ScrollController _scrollController = ScrollController();
    QRViewController? controller;
  bool isLoadingData = false;
  List dataDisplay = [];

    @override
  void dispose() {
    _scrollController.dispose();
    if (controller != null) {
      controller!.dispose();
    }
    super.dispose();
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
        var statement = 'WarrantyEntry';
        var locationId = lId.toString().trim().isNotEmpty ? lId : 1;

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
                return InkWell(
                  onTap: () {
                    debugPrint(dataDisplay.toString());
                    // showEditDialog(context, dataDisplay[index]['Id']);
                  },
                  child: Container(
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
                              child: InkWell(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: ColorPalette.nileBlue,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            ''),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  showPreview(context, dataDisplay[index]['Id']);
                                },
                              ),
                            ), 
                          ],
                        ),
                      )),
                );
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
              const Text("No items in Warranty Note",
              style: TextStyle(
                fontFamily: 'poppins'
              ),
              ),
              TextButton.icon(
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll( RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    ),),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(kPrimaryColor),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                   onPressed: () async {
        setState(() {
          isLoading = true; 
        });
        try {
          final value = await api.getWarrantyEntryNo('Reseed');
          debugPrint(value);
          setState(() {
            entryNo = value;
            entryNoController .text = entryNo;
            widgetID = false; 
          });
        } catch (error) {
          debugPrint("Error: $error");
        } finally {
          setState(() {
            isLoading = false; 
          });
        }
      },
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Take New Warranty',
                   style: TextStyle(
                fontFamily: 'poppins'
              ),
                  ))
            ],
          ));
  }
  
  int nextWidget = 0; 
  selectWidget() {
    return nextWidget == 0
        // ? loadScanner
        //     ? scannerWidget()
        //     // : loadReturnForm
        //     // ? salesReturnForm()
        //     :
          ?  warrantyWidget()
        // selectLedgerWidget()
        : nextWidget == 1
            ? itemDetailWidget()
            : nextWidget == 2
              ? warrantyPreview()
              : const Text('No Widget') ;
  }


  final expandedHeight = 472.0;
  final collapsedHeight =   200.0;
  final collaps = 300.0;
 bool isExpanded = false;
 bool editItem = false;
 final animationDuration = const Duration(milliseconds: 400);
 final entryNoController = TextEditingController();
 final customerNameController = TextEditingController();
 final mobileController = TextEditingController();
 String entryNo = '';
 var query = 'a';
  var selectedSupplier;
 int? position;  
  int? selectedSupplierId;
  warrantyWidget(){
    return Scaffold(
      backgroundColor: bagroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4
              ),
              width: MediaQuery.of(context).size.width,
              color: white,
             child: Row(
                          children: [
                            Expanded(
                                child: ContainerFieldWidget(
                                    widget: 
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 15,
                                      ),
                                      child: TextField(
                                        controller: entryNoController,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
          ),
          // controller: entryNoController,
          decoration: const InputDecoration(
        //     prefixIcon: Visibility(
        //       visible: isAdminUser,
        //       child: Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           const SizedBox(
        //             width: 4,
        //           ),
        //          InkWell(
        //   // onTap: () async {
        //   //   setState(() {
        //   //     try {
        //   //       hasUserModifiedEntry = true;  
        //   //       int entryNumber = int.parse(entryNoController.text); 
        //   //       entryNumber--; 
        //   //       entryNoController.text = entryNumber.toString(); 
        //   //     } catch (e) {
        //   //       debugPrint("Error parsing entry number: $e");
        //   //     }
        //   //     dataDynamic = [
        //   //       {
        //   //         'Type': salesTypeData!.type,
        //   //         'InvoiceNo': entryNoController.text,
        //   //         'EntryNo': int.parse(entryNoController.text),
        //   //         'Id': int.parse(entryNoController.text)
        //   //       }
        //   //     ];
        //   //     _balance = 0;
        //   //     controllerNarration.text = '';
        //   //     // returnEntryNoController.text = '';
        //   //     returnAmountController.text = '';
        //   //     returnAmount = 0;
        //   //     otherAmountList = [];
        //   //     controllerCashReceived.text = '';
        //   //     cartItem.clear();
        //   //   });
        //   //   await fetchSale(context, dataDynamic[0]);
        //   //   setState(() {
        //   //     if (hasUserModifiedEntry) {
        //   //       entryNoController.text = dataDynamic[0]['EntryNo'].toString();
        //   //     }
        //   //   });
        //   // },
        //   child: const Icon(
        //     Icons.arrow_back_ios_rounded,
        //   ),
        // ),
        //         ],
        //       ),
        //     ),
        //     suffixIcon: Visibility(
        //       visible: isAdminUser,
        //       child: const Row(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        // //           InkWell(
        // //             onTap: () async {
        // //     setState(() {
        // //       try {
        // //         hasUserModifiedEntry = true;  
        // //         int entryNumber = int.parse(entryNoController.text); 
        // //         entryNumber++; 
        // //         entryNoController.text = entryNumber.toString(); 
        // //       } catch (e) {
        // //         debugPrint("Error parsing entry number: $e");
        // //       }
        // //       dataDynamic = [
        // //         {
        // //           'Type': salesTypeData!.type,
        // //           'InvoiceNo': entryNoController.text,
        // //           'EntryNo': int.parse(entryNoController.text),
        // //           'Id': int.parse(entryNoController.text)
        // //         }
        // //       ];
        // //        _balance = 0;
        // // controllerNarration.text = '';
        // //       // returnEntryNoController.text = '';
        // //       returnAmountController.text = '';
        // //       returnAmount = 0;
        // //       otherAmountList = [];
        // //       controllerCashReceived.text = '';
        // //       cartItem.clear();
        // //     });
        // //     await fetchSale(context, dataDynamic[0]);
        // //     setState(() {
        // //       if (hasUserModifiedEntry) {
        // //         entryNoController.text = dataDynamic[0]['EntryNo'].toString();
        // //       }
        // //     });
        // //   },
        // //             child: const Icon(Icons.arrow_forward_ios_rounded),
        // //           ),     
        //           SizedBox(
        //             width: 4,
        //           )
        //         ],
        //       ),
        //     ),  
            constraints: BoxConstraints(maxHeight: 40),
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) async{
            cart.clear();
            replacementCart.clear();
            complaint.clear();
            await fetchWarranty(context, entryNoController.text);
          },
          //  onSubmitted: (value) async{
          //                                           setState(() {
          //                                             hasUserModifiedEntry = true;  
          //                                               dataDynamic = [ 
          //                                            {
          //                                            'Type': salesTypeData!.type,
          //                                            'InvoiceNo': value,
          //                                            'EntryNo': int.parse(value) ?? 0,
          //                                            'Id': int.parse(value) ?? 0
          //                                            }
          //                                         ];
          //                                          _balance = 0;
          //                                         controllerNarration.text = '';
          //     // returnEntryNoController.text = '';
          //     returnAmountController.text = '';
          //     returnAmount = 0;
          //     otherAmountList = [];
          //     controllerCashReceived.text = '';
          //                                         cartItem.clear();                                     
          //                                           });
          //                                           await fetchSale(context, dataDynamic[0]);
          //                                            setState(() {
          //     if (hasUserModifiedEntry) {
          //       entryNoController.text = dataDynamic[0]['EntryNo'].toString();
          //     }
          //   });
          //                                         },
                                            keyboardType: TextInputType.number,
        )
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
            const SizedBox(
              height: 8,
            ),
            AnimatedContainer(
              duration: animationDuration,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4
              ),
              height: isExpanded ? expandedHeight : collapsedHeight,
              width: MediaQuery.of(context).size.width,
              color: white,
              child:  Column(
                children: [
                  !oldBill
                  ?  FutureBuilder(
                                future: _getledgerListData,
                                builder: (context, snapshot) {
                                  if(snapshot.connectionState == ConnectionState.waiting){
                                   return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData) {
                                    return const Text('No data found');
                                  }
                                  final supplierList = snapshot.data;

                                  final names = supplierList!
                                      .map((e) => isSalesManWiseLedger? e.name: e['LedName'])
                                      .where((name) => name != null)
                                      .cast<String>()
                                      .toList();
                                  return  ContainerFieldWidget(widget: EasyAutocomplete(
                                    progressIndicatorBuilder: isLoading == true
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : null,
                                    controller: customerNameController,
                                    // oldBill
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
                                      setState(() {
                                        // getLedger(value);
                                        nameLike = value.isNotEmpty
                                            ? value.toLowerCase()
                                            : 'a';
                                      });
                                    },
                                    onSubmitted: (value) {
                                      setState(() {
                                        final selectedSupplier = 
                                        isSalesManWiseLedger ? supplierList.firstWhere((element) => element.name == value)
                                            : supplierList.firstWhere((element) =>
                                           element['LedName'] == value);
                                        selectedSupplierId =
                                           isSalesManWiseLedger? selectedSupplier.id : selectedSupplier['Ledcode'];
                                        _isLoading = true;
                                        api.getCustomerDetail(selectedSupplierId!)
                                            .then((value) {
                                          setState(() {
                                            mobileController.text = value.phone! ?? '';
                                            // customer!.customerName = value.name;
                                            _isLoading = false;
                                          });
                                        });
                                      });
                                    },
                                  )
                               , headTxt: 'Customer');
                                  }
                                  ,
                              )     
                 : ContainerFieldWidget(
                    widget: TextField(
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14
                      ),
                      controller: customerNameController,
                      maxLines: null,
                      readOnly: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 6
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        )
                      ),
                    ),
                    headTxt: 'Customer'),
                    const SizedBox(
                      height: 4,
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
                                            borderRadius:
                                                BorderRadius.circular(3)),
                                        child: ExpansionTile(
                                          // enableFeedback: false,
                                          controlAffinity:
                                              ListTileControlAffinity.platform,
                                          title: const Text(
                                            'Details',
                                            style: TextStyle(
                                              fontFamily: 'poppins',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                          children:  [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2
                                              ),
                                              child: Column(
                                                children: [
                                                  //  ContainerFieldWidget(
                                                  //               widget: TextField(
                                                  //                 maxLines: null,
                                                  //                 // controller:
                                                  //                 readOnly: true,
                                                  //                 decoration: InputDecoration(
                                                  //                     contentPadding: EdgeInsets.symmetric(
                                                  //                         vertical:
                                                  //                             10,
                                                  //                         horizontal:
                                                  //                             5),
                                                  //                     border:
                                                  //                         OutlineInputBorder()),
                                                  //               ),
                                                  //               headTxt:
                                                  //                   'Mobile'),
                                                  //                   SizedBox(
                                                  //                     height: 4,
                                                  //                   ),
                                                                    ContainerFieldWidget(
                                                                      widget: TextField(
                                                                  maxLines: null,
                                                                  controller: mobileController,
                                                                  readOnly: true,
                                                                  decoration: const InputDecoration(
                                                                      contentPadding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              10,
                                                                          horizontal:
                                                                              5),
                                                                      border:
                                                                          OutlineInputBorder()),
                                                                ), headTxt: 'Mobile'),
                                    //                               DropDownSettingsTile<int>(
                                    //   enabled: defaultBranch,
                                    //   leading: const Text('Default Branch',
                                    //   style: TextStyle(
                                    //       fontFamily: 'poppins',
                                    //       fontWeight: FontWeight.w500,
                                    //       fontSize: 15),
                                    //   ),
                                    //   title: '',
                                    //   settingKey:
                                    //       'key-dropdown-default-location-view',
                                    //   values: locationList.isNotEmpty
                                    //       ? {
                                    //           for (var e in locationList)
                                    //             e.key + 1: e.value
                                    //         }
                                    //       : {
                                    //           2: '',
                                    //         },
                                    //   selected: locationList.isNotEmpty
                                    //       ? locationList[0].key + 1
                                    //       : 2,
                                    //   onChange: (value) {
                                    //     debugPrint(
                                    //         'key-dropdown-default-location-view: $value');
                                    //   },
                                    // ),
                                                                    const SizedBox(
                                                                      height: 4,
                                                                    ),
//                                                                ContainerFieldWidget(
//   widget: DropdownButtonFormField<int>(
//     value: locationList.isNotEmpty
//         ? locationList.first.key + 1 // Default value must match the calculated item value
//         : null, // Handle empty list
//     items: locationList.map<DropdownMenuItem<int>>((location) {
//       final itemValue = location.key + 1; // Match this with the default value
//       return DropdownMenuItem<int>(
//         value: itemValue, // Use the unique value
//         child: Text(
//           location.value, // Display the value as text
//           style: const TextStyle(
//             fontFamily: 'poppins',
//             fontSize: 14,
//           ),
//         ),
//       );
//     }).toList(),
//     onChanged: (value) {
//       setState(() {
//         selectedWlocation = value!;
//       });
//     },
//     decoration: const InputDecoration(
//       constraints: BoxConstraints(maxHeight: 40),
//       contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
//       focusedBorder: OutlineInputBorder(
//         borderSide: BorderSide(color: Colors.grey),
//       ),
//       border: OutlineInputBorder(
//         borderSide: BorderSide(color: Colors.grey),
//       ),
//     ),
//   ),
//   headTxt: 'Warrenty Location',
// ),

                                                                    const SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    const ContainerFieldWidget(
                                                                      widget: TextField(
                                                                  maxLines: null,
                                                                  // controller:
                                                                  readOnly: true,
                                                                  decoration: InputDecoration(
                                                                      contentPadding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              10,
                                                                          horizontal:
                                                                              5),
                                                                      border:
                                                                          OutlineInputBorder()),
                                                                ), headTxt: 'Replace Location'),
                                                                  const SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    const ContainerFieldWidget(
                                                                      widget: TextField(
                                                                  maxLines: null,
                                                                  // controller:
                                                                  readOnly: true,
                                                                  decoration: InputDecoration(
                                                                      contentPadding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              10,
                                                                          horizontal:
                                                                              5),
                                                                      border:
                                                                          OutlineInputBorder()),
                                                                ), headTxt: 'Salesman'),
                                                                    // Row(
                                                                    //   children: [
                                                                    //     Expanded(child: ContainerFieldWidget(widget: widget, headTxt: '')),
                                                                    //     Expanded(child: ContainerFieldWidget(widget: widget, headTxt: ''))
                                                                    //   ],
                                                                    // )
                                                ],
                                              ),
                                              )
                                    //         Padding(
                                    //           padding: const EdgeInsets.symmetric(
                                    //               vertical: 2, horizontal: 8),
                                    //           child:
                                    //            selectedCustomerId != null
                                    //               ? 
                                    //                FutureBuilder(
                                    //                   future: selectedCustomerId !=
                                    //                           null
                                    //                       ? api.getCustomerDetail(
                                    //                           selectedCustomerId!)
                                    //                       : api.getCustomerDetail(
                                    //                           0),
                                    //                   builder:
                                    //                       (context, snapshot) {
                                    //                     // if (snapshot.data ==
                                    //                     //     null) {
                                    //                     //   return const SizedBox();
                                    //                     // }
                                    //                     if (snapshot
                                    //                             .connectionState ==
                                    //                         ConnectionState
                                    //                             .waiting) {
                                    //                       return const CircularProgressIndicator();
                                    //                     } else if (snapshot
                                    //                         .hasError) {
                                    //                       return Text(
                                    //                           'Error: ${snapshot.error}');
                                    //                     }
                                    //                      else if (!snapshot
                                    //                         .hasData) {
                                    //                       return const Text(
                                    //                           'No data found');
                                    //                     }
                                    //                     ledgerModel = snapshot.data!;
                                    // ledgerModel!.name = ledgerModel!.name;
                                    // ledgerModel!.address1 = ledgerModel!.address1;
                                    // ledgerModel!.address2 = ledgerModel!.address2;
                                    // ledgerModel!.address3 = ledgerModel!.address3;
                                    // ledgerModel!.address4 = ledgerModel!.taxNumber ;
                                    //                     final data =
                                    //                         snapshot.data;
                                    //                     addressControl.text =
                                    //                         "${ledgerModel!.address1} ${data!.address2} ${data.address3}";
                                    //                     return Column(
                                    //                       children: [
                                    //                         ContainerFieldWidget(
                                    //                             widget: TextField(
                                    //                               maxLines: null,
                                    //                               controller:
                                    //                                   addressControl,
                                    //                               readOnly: true,
                                    //                               decoration: const InputDecoration(
                                    //                                   contentPadding: EdgeInsets.symmetric(
                                    //                                       vertical:
                                    //                                           10,
                                    //                                       horizontal:
                                    //                                           5),
                                    //                                   border:
                                    //                                       OutlineInputBorder()),
                                    //                             ),
                                    //                             headTxt:
                                    //                                 'Address'),
                                    //                         const SizedBox(
                                    //                             height: 6),
                                    //                         ContainerFieldWidget(
                                    //                             widget: TextField(
                                    //                               controller: TextEditingController(
                                    //                                   text: snapshot
                                    //                                       .data!
                                    //                                       .phone),
                                    //                               decoration: const InputDecoration(
                                    //                                   contentPadding: EdgeInsets.symmetric(
                                    //                                       vertical:
                                    //                                           8,
                                    //                                       horizontal:
                                    //                                           5),
                                    //                                   border:
                                    //                                       OutlineInputBorder()),
                                    //                             ),
                                    //                             headTxt: 'Phone'),
                                    //                         const SizedBox(
                                    //                             height: 6),
                                    //                          ContainerFieldWidget(
                                    //                             widget: Container(
                                    //                               padding: const EdgeInsets.only(left: 5),
                                    //                               alignment: Alignment.centerLeft,
                                    //                               width: MediaQuery.of(context).size.width,
                                    //                               height: 48,
                                    //                               decoration: BoxDecoration(border: Border.all(color: grey),borderRadius: BorderRadius.circular(3)),
                                    //                               child: Text(ledgerModel!.taxNumber!),
                                    //                             ),
                                    //                             headTxt: 'Tax Number'),
                                    //                          ],
                                    //                     );
                                    //                   }):Column(
                                    //                       children: [
                                    //                         ContainerFieldWidget(
                                    //                             widget: TextField(
                                    //                               maxLines: null,
                                    //                               controller:
                                    //                                   addressControl,
                                    //                               readOnly: true,
                                    //                               decoration: const InputDecoration(
                                    //                                   contentPadding: EdgeInsets.symmetric(
                                    //                                       vertical:
                                    //                                           10,
                                    //                                       horizontal:
                                    //                                           5),
                                    //                                   border:
                                    //                                       OutlineInputBorder()),
                                    //                             ),
                                    //                             headTxt:
                                    //                                 'Address'),
                                    //                         const SizedBox(
                                    //                             height: 6),
                                    //                         ContainerFieldWidget(
                                    //                             widget: TextField(
                                    //                               controller: TextEditingController(
                                    //                                   text: ''),
                                    //                               decoration: const InputDecoration(
                                    //                                   contentPadding: EdgeInsets.symmetric(
                                    //                                       vertical:
                                    //                                           10,
                                    //                                       horizontal:
                                    //                                           5),
                                    //                                   border:
                                    //                                       OutlineInputBorder()),
                                    //                             ),
                                    //                             headTxt: 'Phone'),
                                    //                         const SizedBox(
                                    //                             height: 6),
                                    //                          ContainerFieldWidget(
                                    //                             widget:  TextField(
                                    //                               controller: TextEditingController(
                                    //                                   text: ''),
                                    //                               decoration: const InputDecoration(
                                    //                                   contentPadding: EdgeInsets.symmetric(
                                    //                                       vertical:
                                    //                                           10,
                                    //                                       horizontal:
                                    //                                           5),
                                    //                                   border:
                                    //                                       OutlineInputBorder()),
                                    //                             ),
                                    //                             headTxt: 'Tax Number'),
                                    //                       ],
                                    //                     ),
                                    //         )                                      
                                          ],
                                          onExpansionChanged: (newIsExpanded) {
                                            setState(() {
                                              isExpanded = newIsExpanded;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 8,
                                  )
                                  ],
                                ),
                              ),
                            ),
                   const SizedBox(
                    height: 4,
                   ),
                   ElevatedButton(
                            onPressed: () {
                              if(selectedSupplierId != null){
                              setState(() {
                                nextWidget = 1;
                                warrentyformattedDate = getToDay;
                                editItem = false;
                              });
                              }else{
                                Fluttertoast.showToast(
                                  backgroundColor: red,
                                  msg: 'Please Select Customer');
                              }
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
                ],
              )
            ),
            const SizedBox(
              height: 8,
            ),
            if(cart.isNotEmpty || replacementCart.isNotEmpty)
                 Container(
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
                                  itemCount: cart.length ,
                                  // scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          editItem = true;
                                          position = index;
                                          nextWidget = 1;
                                          if(cart.isNotEmpty && position == index && position! < cart.length){
                                             itemNameContrroler.text = cart[index].productName!;
                                          qtyContrroler.text = cart[index].qty.toString();
                                          selectedStatus = cart[index].status!;
                                          entryNo = cart[index].entryNo.toString();
                                          wDate = cart[index].wDate!;
                                          auto = cart[index].auto!;
                                          barcode = cart[index].barcode!;
                                          itemId = cart[index].itemId!;
                                          serialNo = cart[index].serialNo!;
                                          qty = cart[index].qty!;
                                          sRate = cart[index].sRate!;
                                          sRateContrroler.text = cart[index].sRate.toString();
                                          total = cart[index].total!;
                                          narration = cart[index].narration!;
                                          eType = cart[index].eType!;
                                          gid = cart[index].gid!;
                                          location = cart[index].location!;
                                          warrentyformattedDate = DateUtil.dateDMY(cart[index].warrantyDate!);
                                          fyId = cart[index].fyId!;
                                          transferStatus = cart[index].transferStatus!;
                                          productName = cart[index].productName!;
                                          }
                                          if(replacementCart.isNotEmpty && position == index && position! < replacementCart.length ){
                                          reItemNameContrroler.text = replacementCart[index].productName!;
                                          reQtyContrroler.text = replacementCart[index].qty.toString();
                                          // selectedStatus = replacementCart[index].status!;
                                          reEntryNo = replacementCart[index].entryNo.toString();
                                          reWDate = replacementCart[index].wDate!;
                                          reAauto = cart[index].auto!;
                                          reBarcode = replacementCart[index].barcode!;
                                          reSelectedItemId = replacementCart[index].itemId!;
                                          reSerialNo = replacementCart[index].serialNo!;
                                          reQty = replacementCart[index].qty!;
                                          reSrate = replacementCart[index].sRate! ?? 0;
                                          reSrateContrroler.text = replacementCart[index].sRate.toString();
                                          reTotal = replacementCart[index].total!;
                                          narration = replacementCart[index].narration!;
                                          narrationContrroler.text = replacementCart[index].narration!;
                                          reEtype = replacementCart[index].eType!;
                                          reGid = replacementCart[index].gid!;
                                          reLocation = replacementCart[index].location!;
                                          reWarrantyDate = replacementCart[index].warrantyDate!;
                                          reFyId = replacementCart[index].fyId!;
                                          reTransferStatus = replacementCart[index].transferStatus!;
                                          reItemNameContrroler.text = replacementCart[index].productName!;
                                          }
                                          if(complaint.isNotEmpty && position == index && position! < complaint.length){
                                            complaintsContrroler.text = complaint[index].complaint!.toString();
                                          } 
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
                                                         '# ${index + 1}',
                                                        style:
                                                            const TextStyle(
                                                                fontSize: 12),
                                                      )),
                                                  Flexible(
                                                    child: Tooltip(
                                                      message: cart[index].productName,
                                                      child: Text(
                                                           ' ${cart[index].productName}',
                                                           overflow: TextOverflow.ellipsis,
                                                          //  maxLines: 1,
                                                          style: const TextStyle(
                                                              color: black,
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              fontFamily:
                                                                  'poppins')),
                                                    ),
                                                  ),
                                                  // const Spacer(),
                                                  
                                                ]),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Row(
                                                  children: [
                                                    const Text(
                                                      'Barcode ',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily:
                                                              'poppins'),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      "${cart[index].barcode!.toStringAsFixed(0)}",
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
                                                        'Status ',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .orange[700],
                                                                fontWeight: FontWeight.w500,
                                                            fontFamily:
                                                                'poppins'),
                                                      ),
                                                    //   Text(
                                                    //  ' ',   // cartItem[index]
                                                    //     //     .discountPercent!
                                                    //     //     .toStringAsFixed(
                                                    //     //         2),
                                                    //     style: TextStyle(
                                                    //         fontSize: 12,
                                                    //         color: Colors
                                                    //             .orange[700],
                                                    //         fontFamily:
                                                    //             'poppins'),
                                                    //   ),
                                                      const Spacer(),
                                                      Text(
                                                        '${cart[index].status!}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
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
                                                  const Text(
                                                    'Qty',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    '${cart[index].qty}',
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
                                                    'SRate ',
                                                    style: TextStyle(
                                                        fontSize: 12,),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                   '₹ ${double.tryParse(cart[index].sRate.toString())}',
                                                    style: const TextStyle(
                                                        fontSize: 12,),
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
                  child: Container(
                                height: 60,
                                color: Colors.white,
                                child:   Center(
                                  child: 
                                   Text(
                                    oldBill
                                     ? 'Delete'
                                     : 'Save & New',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                )),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      oldBill
                    ? setState(() {
                      editWarranty();
                    })
                    : setState(() {
                      if(buttonEvent){
                        return;
                      }
                      else{
                      if(cart.isNotEmpty || replacementCart.isNotEmpty){
                        isLoading = true;
                      saveWarranty();
                      }else{
                        Fluttertoast.showToast(msg: 'Atleast Add 1 Item');
                      }
                      }
                    }); 
                    },
                    child: Container(
                                  height: 60,
                                  color: kPrimaryColor,
                                  child:   Center(
                                    child: 
                                     Text(
                                      oldBill
                                     ? 'Edit'
                                     : 'Save',
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
                ))
            ],
          ),
        ),
    );
  }


  final itemNameContrroler = TextEditingController();
  final reItemNameContrroler = TextEditingController();
  final qtyContrroler = TextEditingController();
  final reQtyContrroler = TextEditingController();
  final sRateContrroler = TextEditingController();
  final reSrateContrroler = TextEditingController();
  final narrationContrroler = TextEditingController();
  final complaintsContrroler = TextEditingController();
  String selectedStatus = 'Pending';
  int selectedWlocation  = 1;
  String? wDate;
  int? auto;
  int? barcode;
  int? itemId;
  String? serialNo;
  String? reSerialNo;
  int? qty;
  int? reUniquecode;
  double? sRate;
  double? total;
  String? narration;
  String? eType;
  String? status;
  int? gid;
  int? location;
  String? warrantyDate;
  int? fyId;
  int? transferStatus;
  String? productName;
  String? reProductName;
  int? selectedItemId;
  int? reSelectedItemId;
  String? reEtype;
  String? reStatus;
  String? reWDate;
  String? reWarrantyDate;
  String?  reEntryNo;
  int?  reAauto;
  int?  reBarcode;
  int?  reQty;
  int?  reGid;
  int?  reLocation;
  int?  reFyId;
  int?  reTransferStatus;
  double?  reSrate ;
  double? reTotal;
  bool _isSaleInfoLoading = false;
  var selectedItem;
  var fetchedData;
  StockProduct? selectedVariant;
  itemDetailWidget(){
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            setState(() {
              // itemNameList.clear();
              itemNameContrroler.text = '';
              warrentyformattedDate = '';
              clearValue();
              nextWidget = 0;
            }); 
          }, icon: const Icon(Icons.arrow_back)),
         title: const Text("Item Details"),
            titleTextStyle: const TextStyle(
              fontFamily: 'poppins',
              color: white
            ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4
              ),
              width: MediaQuery.of(context).size.width,
              color: white,
              child:  Column(
                children: [
                   const Text('Damaged',
                                                style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500
                                                ),
                                                ),
                        const SizedBox(
                          height: 4,
                        ),
                  !editItem
                  ?FutureBuilder(
                                future: _getProductList,
                                builder: (context, snapshot) {
                                  if(snapshot.connectionState == ConnectionState.waiting){
                                   return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData) {
                                    return const Text('No data found');
                                  }
                                  var itemNameList = snapshot.data;
                                  var names = itemNameList!
                                      .map((e) =>  e.name)
                                      .where((name) => name != null)
                                      .cast<String>()
                                      .toList();
                                  return ContainerFieldWidget(widget: 
                                  EasyAutocomplete(
                                    progressIndicatorBuilder:  const Center(
                                            child: CircularProgressIndicator())
                                        ,
                                    controller: itemNameContrroler,
                                    inputTextStyle: const TextStyle(
                                        fontFamily: 'poppins', fontSize: 14),
                                    suggestionTextStyle:
                                        const TextStyle(fontFamily: 'poppins'),
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 5),
                                        border: OutlineInputBorder()),
                                    suggestions: names,
                                    // asyncSuggestions: (searchValue) async{
                                    //    await api.fetchStockProductLike(
                                    //     DateUtil.dateDMY2YMD(formattedDate), searchValue).then((e) {
                                    //       for(var items in e){
                                    //         if(!itemNameList.any((element) => element.id == items.id)){
                                    //           itemNameList.add(items);
                                    //         }
                                    //       }
                                    //       // itemNameList.contains(e);
                                    //       // itemNameList.addAll(e);
                                    //       // names.add(itemNameList)
                                    //       // names.addAll(e.);
                                    //     } );
                                    //     itemNameLike = searchValue.isNotEmpty
                                    //         ? searchValue.toLowerCase()
                                    //         : 'a';
                                    //         // return itemNameList;
                                    //         // setState(() {
                                    //          var namesN = itemNameList.map((e) => e.name)
                                    //   .where((name) => name != null)
                                    //   .cast<String>()
                                    //   .toList();
                                    //         // });
                                    //       return  name ;
                                    // },
                                    onChanged: (value) {
                                      setState(() {
                                       api.fetchStockProductLike(
                                        DateUtil.dateDMY2YMD(formattedDate), value).then((e) {
                                          for(var items in e){
                                            if(!itemNameList.any((element) => element.id == items.id)){
                                              itemNameList.add(items);
                                            }
                                          }
                                        } );
                                        itemNameLike = value.isNotEmpty
                                            ? value.toLowerCase()
                                            : 'a';
                                      });
                                    },
                                    onSubmitted: (value) async {
                                    setState(() {
                                      _isLoading = true;
                                      _isSaleInfoLoading = true;
                                    });
                                    final selectedItem = 
                                    itemNameList.firstWhere((element) => element.name == value);  

  if (selectedItem != null) {
    // itemNameContrroler.text = '';
    qtyContrroler.text = '';
    sRateContrroler.text = '';
    selectedItemId = selectedItem.id;
    final fetchedData = await api.fetchWarrentyItemFromSalesList(
      selectedSupplierId!,
      selectedItemId!,
    );
     setState(() {
        _isSaleInfoLoading = false; 
        _isLoading = false;
      });

    if (fetchedData.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Warranty Items",
              style: TextStyle(fontFamily: 'poppins'),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 6,
                  );
                },
                shrinkWrap: true,
                itemCount: fetchedData.length,
                itemBuilder: (context, index) {
                  final item = fetchedData[index];
                  String wDate = item['WarrentyMonth'];
                  String saleDate = item['DDate'];
                  
                  
                  return InkWell(
                    onTap: () {
                           setState(() {
                         sRateContrroler.text = item['Rate'].toString();
                         warrentyformattedDate = item['WarrentyMonth'].toString();
                         barcode = item['UniqueCode'];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
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
                                                      child: Row(
                                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text('SRate',
                                                          style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily:
                                                              'poppins'),),
                                                        Spacer(),
                                                        Text(
                        "${double.tryParse(item['Rate'].toString()) ?? 0.0}",
                        style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                      ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Row(
                                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text('WDate',
                                                          style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily:
                                                              'poppins'),),
                                                        Spacer(),
                                                        Text(
                        "${wDate.trimRight()}",
                        style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                      ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Row(
                                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text('Supplier',
                                                          style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily:
                                                              'poppins'),),
                                                        const Spacer(),
                                                        Flexible(
                                                          flex: 5,
                                                          child: Align(
                                                            alignment: Alignment.centerRight,
                                                            child: Text(
                                                                                  "${item['supplier']}",
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  textAlign: TextAlign.right,
                                                                                  style: const TextStyle(
                                                            fontSize: 12,
                                                                                                                ),
                                                                                ),
                                                          ),
                                                        ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Row(
                                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text('Sales Date',
                                                          style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily:
                                                              'poppins'),),
                                                        const Spacer(),
                                                        Text(
                                                                              "${saleDate.trimRight()}",
                                                                              overflow: TextOverflow.ellipsis,
                                                                              textAlign: TextAlign.right,
                                                                              style: const TextStyle(
                                                        fontSize: 12,
                                                                                                            ),
                                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Row(
                                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text('Sales Days',
                                                          style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily:
                                                              'poppins'),),
                                                        const Spacer(),
                                                        Flexible(
                                                          flex: 5,
                                                          child: Align(
                                                            alignment: Alignment.centerRight,
                                                            child: Text(
                                                                                  "${item['Days']}",
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  textAlign: TextAlign.right,
                                                                                  style: const TextStyle(
                                                            fontSize: 12,
                                                                                                                ),
                                                                                ),
                                                          ),
                                                        ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                 ),
                                                 ),
                    ),
                  );
                  //  ListTile(
                  //   title: Text(
                  //     "Rate: ${double.tryParse(item['Rate'].toString()) ?? 0.0}",
                  //     style: const TextStyle(fontFamily: 'poppins'),
                  //   ),
                  //   subtitle: Text(
                  //     "Warranty Date: ${item['WarrentyMonth']}",
                  //     style: const TextStyle(fontFamily: 'poppins'),
                  //   ),
                  //   onTap: () {
                  //     setState(() {
                  //       sRateContrroler.text = item['Rate'].toString();
                  //       warrentyformattedDate = item['WarrentyMonth'].toString();
                  //     });
                  //     Navigator.pop(context);
                  //   },
                  // );
                
                },
              ),
            ),
          );
        },
      );
    } else {
      setState(() {
        qtyContrroler.clear();
        warrentyformattedDate = getToDay;
        _isSaleInfoLoading = false; 
      });
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "No Sale",
          style: TextStyle(fontFamily: 'poppins'),
        ),
        content: const Text("There are no sales data available."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
    }
  } else {
    setState(() {
      qtyContrroler.clear();
      warrentyformattedDate = getToDay;
      _isSaleInfoLoading = false; 
    });
  }
},

                                    // onSubmitted: (value) {
                                    //   setState(() {                                    
                                    //     final selectedItem = 
                                    //    itemNameList.firstWhere((element) => element.name == value);                                  
                                    //     selectedItemId =
                                    //        selectedItem.id ;
                                    //        var data = api.fetchWarrentyItemFromSalesList(selectedSupplierId!,selectedItemId!).then((value) {
                                    //       debugPrint(value.toString());
                                    //     });
                                    //   });
                                    // },
                                  )
                               , headTxt: 'Item Name');
                                   },
                              )  
                 
    //               ?  FutureBuilder(
    //   future: _getProductList, 
    //   builder: (context, snapshot) {
    //     // if (_isLoading) {
    //     //   return const Center(child: CircularProgressIndicator());
    //     // }
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //     if (snapshot.hasError) {
    //       return Text('Error: ${snapshot.error}');
    //     } else if (itemNameList.isEmpty) {
    //       return const Text('No data found');
    //     }
    //     return ContainerFieldWidget(
    //       widget: EasyAutocomplete(
    //         // progressIndicatorBuilder: _isLoading
    //         //     ? const Center(child: CircularProgressIndicator())
    //         //     : null,
    //         controller: itemNameContrroler,
    //         inputTextStyle: const TextStyle(fontFamily: 'poppins', fontSize: 14),
    //         suggestionTextStyle: const TextStyle(fontFamily: 'poppins'),
    //         decoration: const InputDecoration(
    //           contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
    //           border: OutlineInputBorder(),
    //         ),
    //         suggestions: names,
    //         onChanged: (value) {
    //           itemNameLike = value.isNotEmpty ? value.toLowerCase() : 'a';
    //           _fetchProductList(); 
    //         },
    //         onSubmitted: (value) {
    //           final selectedSupplier = isSalesManWiseLedger
    //               ? itemNameList.firstWhere((element) => element.name == value)
    //               : itemNameList.firstWhere(
    //                   (element) => element['LedName'] == value);
    //           selectedSupplierId = isSalesManWiseLedger
    //               ? selectedSupplier.id
    //               : selectedSupplier['Ledcode'];
    //           setState(() {
    //             _isLoading = true;
    //           });
    //           api.getCustomerDetail(selectedSupplierId!).then((value) {
    //             setState(() {
    //               mobileController.text = value.phone ?? '';
    //               _isLoading = false;
    //             });
    //           });
    //         },
    //       ),
    //       headTxt: 'Item Name',
    //     );
    //   },
    // )
                 
                  : ContainerFieldWidget(
                    widget: TextField(
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14
                      ),
                      controller: itemNameContrroler,
                      maxLines: null,
                      readOnly: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 6
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        )
                      ),
                    ), headTxt: 'Item Name'),
                    const SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ContainerFieldWidget(
                          widget: TextField(
                            keyboardType: TextInputType.number,
                             style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14
                      ),
                          controller: qtyContrroler,
                      // readOnly: true,
                      decoration: const InputDecoration(
                        constraints: BoxConstraints(
                          maxHeight: 40
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 6
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        )
                      ),
                    ), headTxt: 'Qty')),
                    const SizedBox(
                      width: 4,
                    ),
                        Expanded(child: ContainerFieldWidget(widget:
                         DropdownButtonFormField<String>(
          value: selectedStatus,
          items: statusOptions.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status,
               style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14
                      ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedStatus = value!;
            });
          },
          decoration: const InputDecoration(
             constraints: BoxConstraints(
                          maxHeight: 40
                        ),
            contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ), headTxt: 'Status'))
                      ],
                    ),
              const SizedBox(
                      height: 6,
                    ),
                           Row(
                      children: [
                        Expanded(
                          child: ContainerFieldWidget(
                          widget: TextField(
                             style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14
                      ),
                          controller: sRateContrroler,
                      readOnly: true,
                      decoration: const InputDecoration(
                        constraints: BoxConstraints(
                          maxHeight: 40
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 6
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        )
                      ),
                    ), headTxt: 'SRate')),
                    const SizedBox(
                      width: 4,
                    ),
                        Expanded(
                          child: ContainerFieldWidget(
                            widget: InkWell(
                              onTap: () {
                                _selectWarrentyDate();
                              },
                              child: Container(
                                          height: 40,
                                          // margin: const EdgeInsets.only(
                                          //   bottom: 15,
                                          // ),
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
                                                warrentyformattedDate!,
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
                           headTxt: 'Warrenty Date'))
                     
                      ],
                    ),
                   const SizedBox(
                    height: 6,
                   ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
                     padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4
              ),
                    width: MediaQuery.of(context).size.width,
                    color: white,
                    child: Column(
                      children: [
                        const Text('Complaint',
                                                style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500
                                                ),
                                                ),
                        const SizedBox(
                          height: 4,
                        ),
                        TextField(
                          maxLines: null,
                          controller: complaintsContrroler,
                          decoration: const InputDecoration(
                            labelText: 'Complaint..',
                            labelStyle: TextStyle(
                              fontFamily: 'poppins',
                              color: grey,
                              fontSize: 13
                            ),
                            constraints: BoxConstraints(
                              maxHeight: 45
                            ),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5
                            )
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        )        
                      ],
                    ),
                   ),
                   const SizedBox(
                    height: 8,
                   ),
                Container(
                        padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4
              ),
                    width: MediaQuery.of(context).size.width,
                    color: white,
                    child: Column(
                      children: [
                        const Text('Replacement',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500
                        ),
                        ) ,
                        const SizedBox(
                          height: 4,
                        ),
                        FutureBuilder(
                                future: _getProductList,
                                builder: (context, snapshot) {
                                  if(snapshot.connectionState == ConnectionState.waiting){
                                   return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData) {
                                    return const Text('No data found');
                                  }
                                  var itemNameList = snapshot.data;
                                  var names = itemNameList!
                                      .map((e) =>  e.name)
                                      .where((name) => name != null)
                                      .cast<String>()
                                      .toList();
                                  return ContainerFieldWidget(widget: 
                                  EasyAutocomplete(
                                    progressIndicatorBuilder:  const Center(
                                            child: CircularProgressIndicator())
                                        ,
                                    controller: reItemNameContrroler,
                                    inputTextStyle: const TextStyle(
                                        fontFamily: 'poppins', fontSize: 14),
                                    suggestionTextStyle:
                                        const TextStyle(fontFamily: 'poppins'),
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 5),
                                        border: OutlineInputBorder()),
                                    suggestions: names,
                                    // asyncSuggestions: (searchValue) async{
                                    //    await api.fetchStockProductLike(
                                    //     DateUtil.dateDMY2YMD(formattedDate), searchValue).then((e) {
                                    //       for(var items in e){
                                    //         if(!itemNameList.any((element) => element.id == items.id)){
                                    //           itemNameList.add(items);
                                    //         }
                                    //       }
                                    //       // itemNameList.contains(e);
                                    //       // itemNameList.addAll(e);
                                    //       // names.add(itemNameList)
                                    //       // names.addAll(e.);
                                    //     } );
                                    //     itemNameLike = searchValue.isNotEmpty
                                    //         ? searchValue.toLowerCase()
                                    //         : 'a';
                                    //         // return itemNameList;
                                    //         // setState(() {
                                    //          var namesN = itemNameList.map((e) => e.name)
                                    //   .where((name) => name != null)
                                    //   .cast<String>()
                                    //   .toList();
                                    //         // });
                                    //       return  name ;
                                    // },
                                    onChanged: (value) {
                                      setState(() {
                                       api.fetchNoStockProductLike(
                                        DateUtil.dateDMY2YMD(formattedDate), value).then((e) {
                                          for(var items in e){
                                            if(!itemNameList.any((element) => element.id == items.id)){
                                              itemNameList.add(items);
                                            }
                                          }
                                        } );
                                        itemNameLike = value.isNotEmpty
                                            ? value.toLowerCase()
                                            : 'a';
                                      });
                                    },
                                    onSubmitted: (value) async{
                                      // setState(() {
                                      //   _isLoading = true;
                                      // });
                                        selectedItem =  snapshot.data!.firstWhere(
                                                (element) => element.name == value, 
                                              );
                                              setState(() {
                                                reSelectedItemId = selectedItem.id;
                                              });
                                              // setState(() {
                                              //   _isLoading = true;
                                              // });
                                       var fetchedData = 
                                       await api.fetchNoStockVariant(reSelectedItemId.toString(),taxGroupUpdate,0); 
                                        // setState(() {
                                        //         _isLoading = false;
                                        //       });  
                                              if(fetchedData != null){
                                                for(var item in fetchedData){
                                                 setState(() {
                                                    reSrateContrroler.text = item['mrp'].toString();
                                                  reSerialNo = item['serialno'].toString();
                                                  reUniquecode = item['uniquecode'];
                                                  // _isLoading = false;
                                                 });
                                                }
                                                // selectedVariant = fetchedData.first;
                                                // reSrateContrroler.text = selectedVariant!.sellingPrice!.toString();
                                              }  
                                      //         setState(() {
                                      //   _isLoading = false;
                                      // });  
                                    },
                                    
                                  )
                               , headTxt: 'Item Name');
                                   },
                              )  ,
                               const SizedBox(
                      height: 6,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ContainerFieldWidget(
                          widget: TextField(
                            keyboardType: TextInputType.number,
                             style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14
                      ),
                          controller: reQtyContrroler,
                      // readOnly: true,
                      decoration: const InputDecoration(
                        constraints: BoxConstraints(
                          maxHeight: 40
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 6
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        )
                      ),
                    ), headTxt: 'Qty')),
                    const SizedBox(
                      width: 4,
                    ),
                        Expanded(child: ContainerFieldWidget(widget:
                         TextField(
                             style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14
                      ),
                          controller: reSrateContrroler,
                      // readOnly: true,
                      decoration: const InputDecoration(
                        constraints: BoxConstraints(
                          maxHeight: 40
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 6
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        )
                      ),
                    ), headTxt: 'SRate'))
                      ],
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    ContainerFieldWidget(widget:
                         TextField(
                             style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14
                      ),
                          controller: narrationContrroler,
                      // readOnly: true,
                      decoration: const InputDecoration(
                        constraints: BoxConstraints(
                          maxHeight: 40
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 6
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: grey
                          )
                        )
                      ),
                    ), headTxt: 'Narration')
                      ],
                    ),
                )
          ],
        )),
        bottomNavigationBar: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                                height: 60,
                                color: Colors.white,
                                child:   Center(
                                  child: 
                                   Text(
                                    editItem
                                    ? 'Delete'
                                    : 'Save & New',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                )),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      editItem            
                      ? setState(() {
                        reWDate = DateUtil.dateYMD(formattedDate);
                          reEtype = 'R';
                          reStatus = '';
                          reProductName = reItemNameContrroler.text;
                          
                        updateProduct(WarrantyCart(
                          entryNo: int.parse(entryNo),
                          wDate: wDate,
                          auto: auto,
                          barcode: barcode,
                          itemId: itemId,
                          serialNo: serialNo,
                          qty: qty,
                          sRate: double.tryParse(sRateContrroler.text),
                          total: total,
                          narration: narration,
                          eType: eType,
                          status: selectedStatus,
                          gid: gid,
                          location: location,
                          warrantyDate: warrantyDate,
                          fyId: currentFinancialYear!.id,
                          transferStatus: transferStatus,
                          productName: productName,
                      ), 0);
                      if(reItemNameContrroler.text.isNotEmpty){
                        updateReplacement(WarrantyRepalceModel(
                          auto: reAauto,
                          barcode: reBarcode,
                          eType: reEtype ,
                          entryNo: int.parse(reEntryNo!),
                          fyId: currentFinancialYear!.id,
                          gid: reGid,
                          itemId: reSelectedItemId,
                          location: reLocation,
                          narration: narration,
                          productName: reProductName,
                          qty: reQty,
                          sRate: reSrate,
                          serialNo: reSerialNo,
                          status: reStatus,
                          total: reTotal,
                          transferStatus: reTransferStatus,
                          wDate: reWDate,
                          warrantyDate: reWarrantyDate,
                        ), -1);
    //                      replacementCart[index].entryNo = int.parse(reEntryNo!);
    // replacementCart[index].wDate = reWDate;
    // replacementCart[index].auto = reAauto;
    // replacementCart[index].barcode = reBarcode;
    // replacementCart[index].itemId = reSelectedItemId;
    // replacementCart[index].serialNo = reSerialNo;
    // replacementCart[index].qty = reQty;
    // replacementCart[index].sRate = reSrate;
    // replacementCart[index].total = reTotal?.toDouble();
    // replacementCart[index].narration = narration;
    // replacementCart[index].eType = reEtype;
    // replacementCart[index].status = reStatus;
    // replacementCart[index].gid = reGid;
    // replacementCart[index].location = reLocation;
    // replacementCart[index].warrantyDate = reWarrantyDate;
    // replacementCart[index].transferStatus = reTransferStatus;
    // replacementCart[index].productName = reProductName;
                      }
    //                   if(reItemNameContrroler.text.isNotEmpty){
    //                         cart[index].entryNo = int.parse(entryNo);
    // cart[index].wDate = wDate;
    // cart[index].auto = auto;
    // cart[index].barcode = barcode;
    // cart[index].itemId = itemId;
    // cart[index].serialNo = serialNo;
    // cart[index].qty = qty;
    // cart[index].sRate = sRate;
    // cart[index].total = total?.toDouble();
    // cart[index].narration = narration;
    // cart[index].eType = eType;
    // cart[index].status = selectedStatus;
    // cart[index].gid = gid;
    // cart[index].location = location;
    // cart[index].warrantyDate = warrantyDate;
    // cart[index].transferStatus = transferStatus;
    // cart[index].productName = productName;
    //                   }
                      nextWidget = 0;
                      clearValue();
                      debugPrint(cart.toList().toString());
                      })
                      : setState(() {
                         qty = (qtyContrroler.text.isNotEmpty
          ? int.tryParse(qtyContrroler.text)
          : 0);
                         sRate = (sRateContrroler.text.isNotEmpty
          ? double.tryParse(sRateContrroler.text)
          : 0);
                      int?   reQty = (reQtyContrroler.text.isNotEmpty
          ? int.tryParse(reQtyContrroler.text)
          : 0);
                      double?  reSrate = (reSrateContrroler.text.isNotEmpty
          ? double.tryParse(reSrateContrroler.text)
          : 0);
                        sRate = double.tryParse(sRateContrroler.text);
                         total = (qty ?? 0) * (sRate ?? 0);
                       double?  reTotal = (reQty ?? 0) * (reSrate ?? 0);
                       if (itemNameContrroler.text.isNotEmpty && qtyContrroler.text.isNotEmpty) {
                          addProduct(WarrantyCart(
                          entryNo: int.parse(entryNo),
                          wDate: DateUtil.dateYMD(formattedDate),
                          auto: 0,
                          barcode: barcode,
                          itemId: selectedItemId,
                          serialNo: '',
                          qty: int.tryParse(qtyContrroler.text),
                          sRate: double.tryParse(sRateContrroler.text),
                          total: total,
                          narration: '',
                          eType: 'D',
                          status: selectedStatus,
                          gid: 0,
                          location: lId,
                          warrantyDate: DateUtil.dateYMD1(warrentyformattedDate),
                          fyId: currentFinancialYear!.id,
                          transferStatus: 0,
                          productName: itemNameContrroler.text,
                        ), -1);
                       }
                        if(reItemNameContrroler.text.isNotEmpty){
                          
                           addReplacement(
            WarrantyRepalceModel(
              entryNo: int.parse(entryNo),
          wDate: DateUtil.dateYMD(formattedDate),
          auto: 0,
          barcode: reUniquecode,
          itemId: reSelectedItemId,
          serialNo: reSerialNo,
          qty: reQty,
          sRate: reSrate,
          total: reTotal,
          narration: narrationContrroler.text,
          eType: 'R',
          status: '',
          gid: 0,
          location: lId,
          warrantyDate: DateUtil.dateYMD(formattedDate),
          fyId: currentFinancialYear!.id,
          transferStatus: 0,
          productName: reItemNameContrroler.text
            ), -1);
                        }
                    if(complaintsContrroler.text.isNotEmpty){
                       addComplaints(
            WarrantyComplaintModel(
            complaint: complaintsContrroler.text,
            gid: 0,
          ), -1);
                    }    
                         debugPrint(cart.toList().toString());
                         nextWidget = 0;
                         clearValue();
                        //  cart.clear();
                      }); 
                    },
                    child: Container(
                                  height: 60,
                                  color: kPrimaryColor,
                                  child:   Center(
                                    child: 
                                     Text(
                                      editItem
                                     ? 'Edit'
                                     : 'Save',
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
                ))
            ],
          ),
        ),
    );
  }

void saveWarranty()  {
  setState(() {
    _isLoading = true;
     isLoading = true; 
     buttonEvent = true;
  });
  final cartList = cart.map((item) => item.toMap()).toList();
  final replacementCartList = replacementCart.map((item) => item.toMap()).toList();
  final combinedList = cartList + replacementCartList;

  final complaintList = complaint.map((item) => item.toMap()).toList();
  
  var mapValue = json.encode({
    "entryNo": entryNo, 
    'date': DateUtil.dateYMD(formattedDate),
    'customer':selectedSupplierId,
    'location':lId,
    'mobile':mobileController.text,
    'userId':lId,
    'warrantyLocation':lId,
    'salesman':salesManId,
  });
  final body = {
    'information': mapValue,
    'particular': json.encode(combinedList),
    'complaints': json.encode(complaintList),
  };
  
  
  debugPrint(json.encode(body).toString());
  api.addWarranty(body).then((value) async{
    if (CommonService().isNumeric(value) && int.tryParse(value)! > 0) {
      Fluttertoast.showToast(
        backgroundColor: green,
        msg: 'Warranty Saved');
        showMore(context, true);
         setState(() {
          _isLoading = false;
          isLoading = false; 
          buttonEvent = false;
        });
       
    }else {
        showErrorDialog(context, value.toString());
      }
  });
}
   

void editWarranty() {
  final cartList = cart.map((item) => item.toMap()).toList();
  final replacementCartList = replacementCart.map((item) => item.toMap()).toList();
  final combinedList = cartList + replacementCartList;

  final complaintList = complaint.map((item) => item.toMap()).toList();
  
  var mapValue = json.encode({
    "entryNo": customer!.entryNo, 
    'date': customer!.wDate,
    'customer':customer!.customer,
    'location':customer!.location,
    'mobile':customer!.mobile,
    'userId':customer!.userId,
    'warrantyLocation':customer!.warrantyLocation,
    'salesman':customer!.customer,
  });
  final body = {
    'information': mapValue,
    'particular': json.encode(combinedList),
    'complaints': json.encode(complaintList),
  };
  
  
  debugPrint(json.encode(body).toString());
  api.editWarranty(body).then((value) {
    if (CommonService().isNumeric(value) && int.tryParse(value)! > 0) {
      Fluttertoast.showToast(
        backgroundColor: green,
        msg: 'Warranty Updated');
        showMore(context, false);
    }else {
        showErrorDialog(context, value.toString());
      }
  });
}
 
  warrantyPreview(){
 
    _createPDF('${'Warranty'}_ref_${entryNo}').then((value) => pdfPath = value);
    // var cInformation = customer;
  
    var dParticulars  = cart;
    var rParticulars = replacementCart;
    var complaints = complaint;
    double totalQuantity = dParticulars.fold(
        0, (total, particular) => total + particular.qty!);
        double lineTotal = dParticulars.fold(
        0, (total, particular) => total + particular.total!);

   return Scaffold(
        appBar: AppBar(
          title: Text('Warranty Preview'),
          actions: [
            IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () {
                  setState(
                    () {
                      Future.delayed(const Duration(milliseconds: 0), () {
                      _createPDF(
                        '',
                        )
                          .then((value) =>
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PDFScreen(
                                pathPDF: pdfPath,
                                subject: 'Warranty',
                                text: 'this is Warranty',
                              )))
                      );
                      // try {
                      //   debugPrint('pdf generating');
                      //   LayoutCallbackWithData builder;
                      //   PdfPageFormat pageFormat;
                      //   // builder = generateInvoice;
                      //   // generateInvoice(pageFormat, data).then((value) {
                      //   //   build(context);
                      //   debugPrint('pdf generated sucess');
                      //   // });
                      // } catch (ex) {
                      //   debugPrint(ex.toString());
                      // }
                      });
                    },
                  );
                }),
            // IconButton(
            //     icon: const Icon(Icons.list),
            //     onPressed: () {
            //       argumentsPass = {
            //         'mode': 'selectedLedger',
            //         'name': dataInformation['ToName'],
            //         'id': dataInformation['Customer']
            //       };
            //       Navigator.pushNamed(
            //         context,
            //         '/select_ledger',
            //       );
            //     }),
            // IconButton(
            //     icon: const Icon(Icons.picture_in_picture),
            //     onPressed: () {
            //       sample image for test
            //       _capturePng().then((value) async {
            //         // Path tempDir = await getTemporaryDirectzory();
            //         var tempDir = await getTemporaryDirectory();
            //         var path = '${tempDir.path}/image.png';
            //         var iss = await File(path).exists();
            //         if (iss)
            //           OpenFile.open(path);
            //         File files = await File(path).create();
            //         await files.writeAsBytesSync(value);
            //       });
            //     }),
            // IconButton(
            //     icon: const Icon(Icons.print),
            //     onPressed: () {
            //       _capturePng().then((value) => {
            //             setState(() {
            //               byteImage = value;
            //               askPrintDevice(
            //                   context,
            //                   '${title}_ref_${dataInformation['RealEntryNo']}',
            //                   companySettings!,
            //                   settings!,
            //                   data,
            //                   byteImage!,
            //                   customerBalance,
            //                   printerType,
            //                   printerDevice,
            //                   printModel);
            //             })
            //           });
            //     })
          
          ],
        ),
        body:
        //  entryNo > 0
            // ? 
            SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: _isLoading
                  ? Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(
                            strokeWidth: 5,
                            color: Colors.grey,
                            backgroundColor: Colors.red,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Loading",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SingleChildScrollView(
                          child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey[300], border: Border.all()),
                            child: Center(
                                child: Text(
                              'Wrarranty Invoice',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            decoration: const BoxDecoration(
                                border: Border(
                                    left: BorderSide(),
                                    right: BorderSide(),
                                    bottom: BorderSide())),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "  No                :",
                                      style: TextStyle(fontSize: 9),
                                    ),
                                    Text(
                                      "   ${entryNo.toString()}",
                                      style: const TextStyle(fontSize: 9),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "  Date             :",
                                      style: TextStyle(fontSize: 9),
                                    ),
                                    Text(
                                      "   ${formattedDate}",
                                      style: const TextStyle(fontSize: 9),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "  To                 :",
                                      style: TextStyle(fontSize: 9),
                                    ),
                                    Text(
                                      "   ${customerNameController.text}",
                                      style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                                // color: Colors.grey[300],
                                 border: Border(
                                  left: BorderSide(
                                    width: 1,
                                  ),
                                  right: BorderSide(
                                    width: 1,
                                  ),
                                 )
                                 ),
                            child: Table(
                              border: const TableBorder(
                                horizontalInside: BorderSide
                                    .none, // Remove horizontal borders inside the table
                                verticalInside:
                                    BorderSide(), // Keep vertical borders
                              ),
                              columnWidths: const {
                                0: FixedColumnWidth(15),
                                1: FlexColumnWidth(22),
                                2: FlexColumnWidth(10),
                                3: FlexColumnWidth(10),
                                4: FlexColumnWidth(10),
                                5: FlexColumnWidth(12),
                                6: FlexColumnWidth(12),
                              },
                              children: [
                                TableRow(
                                  children: [
                                  Center(
                                      child: Column(
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                              fontSize: 6,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )),
                                  const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Center(
                                      child: Text(
                                        'Item Name',
                                        style: TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Center(
                                      child: Text(
                                        'Qty',
                                        style: TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Center(
                                      child: Text(
                                        'Srate',
                                        style: TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Center(
                                      child: Text(
                                        'Status',
                                        style: TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Center(
                                      child: Text(
                                        'Total',
                                        style: TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              
                                  const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Center(
                                      child: Text(
                                        'Complaint',
                                        style: TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              
                                ]
                                ),
                              
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(border: Border.all()),
                            child: Table(
                              border: const TableBorder(
                                horizontalInside: BorderSide
                                    .none, // Remove horizontal borders inside the table
                                verticalInside:
                                    BorderSide(), // Keep vertical borders
                              ),
                              columnWidths: const {
                                0: FixedColumnWidth(15),
                                1: FlexColumnWidth(22),
                                2: FlexColumnWidth(10),
                                3: FlexColumnWidth(10),
                                4: FlexColumnWidth(10),
                                5: FlexColumnWidth(12),
                                6: FlexColumnWidth(12),
                              },
                              children: [
                                for (var i = 0; i < dParticulars.length; i++)
                                  TableRow(children: [
                                    Center(
                                        child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            '${i + 1}',
                                            style: const TextStyle(
                                                fontSize: 6,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        dParticulars[i].productName!,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Center(
                                        child: Text(
                                          dParticulars[i].qty!
                                              .toStringAsFixed(2),
                                          style: const TextStyle(
                                              fontSize: 6,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(dParticulars[i].sRate!
                                                .toStringAsFixed(2),
                                            style: const TextStyle(
                                                fontSize: 6,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            dParticulars[i].status
                                                .toString(),
                                            style: const TextStyle(
                                                fontSize: 6,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            dParticulars[i].total!
                                                .toStringAsFixed(2),
                                            style: const TextStyle(
                                                fontSize: 6,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                      Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        i < complaints.length ? complaints[i].complaint! : ''!,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ]),
                                  if(rParticulars.isEmpty)
                                if (7 < 10)
                                  for (var k = 0; k < 8; k++)
                                    TableRow(children: [
                                      Center(
                                          child: Column(
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.all(2.0),
                                            child: Text(
                                              '\n',
                                              style: TextStyle(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      )),
                                      const Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Text(
                                          '',
                                          style: TextStyle(
                                              fontSize: 6,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Center(
                                          child: Text(
                                            '',
                                            style: TextStyle(
                                                fontSize: 6,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: const [
                                            Text(
                                              '',
                                              style: TextStyle(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: const [
                                            Text(
                                              '',
                                              style: TextStyle(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: const [
                                            Text(
                                              '',
                                              style: TextStyle(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: const [
                                            Text(
                                              '',
                                              style: TextStyle(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    
                                    ]),
                             
                              ],
                            ),
                          ),
                          if(rParticulars.isNotEmpty)
                          Container(
                            height: 15,
                            decoration: BoxDecoration(
                              border: Border.all()
                            ),
                            child: Center(child: Text('Replace',
                             style: TextStyle(
                                              fontSize: 6,
                                              fontWeight: FontWeight.bold),
                            )),
                          ),
                      if(rParticulars.isNotEmpty)
                           Container(
          decoration: const BoxDecoration(
                                // color: Colors.grey[300],
                                 border: Border(
                                  left: BorderSide(
                                    width: 1,
                                  ),
                                  right: BorderSide(
                                    width: 1,
                                  ),
                                 )
                                 ),
            
            child: Table(
                border: const TableBorder(
                                horizontalInside: BorderSide
                                    .none, // Remove horizontal borders inside the table
                                verticalInside:
                                    BorderSide(), // Keep vertical borders
                              ),
              columnWidths: const {
                  0: FixedColumnWidth(15),
                  1: FlexColumnWidth(22),
                  2: FlexColumnWidth(10),
                  3: FlexColumnWidth(10),
                  4: FlexColumnWidth(22),
              },
              children: [
                // Table header
                TableRow(
                    children: [
                                  Center(
                                      child: Column(
                                    children: const [
                                      Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                              fontSize: 6,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )),
                                  const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Center(
                                      child: Text(
                                        'Item Name',
                                        style: TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Center(
                                      child: Text(
                                        'Qty',
                                        style: TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Center(
                                      child: Text(
                                        'Srate',
                                        style: TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Center(
                                      child: Text(
                                        'Narration',
                                        style: TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ]
                ),

                // Replacement cart data rows
                
              ],
            ),
          ),
          if(rParticulars.isNotEmpty)
          Container(
            decoration: BoxDecoration(border: Border.all()),
            child: Table(
              border: const TableBorder(
                                horizontalInside: BorderSide
                                    .none, // Remove horizontal borders inside the table
                                verticalInside:
                                    BorderSide(), // Keep vertical borders
                              ),
                              columnWidths: const {
                                0: FixedColumnWidth(15),
                  1: FlexColumnWidth(22),
                  2: FlexColumnWidth(10),
                  3: FlexColumnWidth(10),
                  4: FlexColumnWidth(22),
                              },
              children: [
                for (var i = 0; i < rParticulars.length; i++)
                  TableRow(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                                fontSize: 6, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          rParticulars[i].productName ?? '',
                          style: const TextStyle(
                              fontSize: 7, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Center(
                          child: Text(
                            rParticulars[i].qty!.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 6, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Center(
                          child: Text(
                            rParticulars[i].sRate!.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 6, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Center(
                          child: Text(
                            
                            rParticulars[i].narration ?? '',
                            style: const TextStyle(
                                fontSize: 6, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (5 < 10)
                                  for (var k = 0; k < 8; k++)
                                    TableRow(children: [
                                      Center(
                                          child: Column(
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.all(2.0),
                                            child: Text(
                                              '\n',
                                              style: TextStyle(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      )),
                                      const Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Text(
                                          '',
                                          style: TextStyle(
                                              fontSize: 6,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Center(
                                          child: Text(
                                            '',
                                            style: TextStyle(
                                                fontSize: 6,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: const [
                                            Text(
                                              '',
                                              style: TextStyle(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: const [
                                            Text(
                                              '',
                                              style: TextStyle(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                    ]),
                             
              ],
            ),
          )
                       
                        ],
                      ))),
            ),
          )
          // : const Center(child: Text('Not Found'))
          );
          
  }
  
      // Container(
                          //   decoration: BoxDecoration(
                          //       color: Colors.grey[300],
                          //       border: const Border(
                          //           bottom: BorderSide(),
                          //           left: BorderSide(),
                          //           right: BorderSide())),
                          //   child: Table(
                          //     border: const TableBorder(
                          //       horizontalInside: BorderSide
                          //           .none, // Remove horizontal borders inside the table
                          //       verticalInside:
                          //           BorderSide(), // Keep vertical borders
                          //     ),
                          //     columnWidths: const {
                          //       0: FixedColumnWidth(15),
                          //       1: FlexColumnWidth(20),
                          //       2: FlexColumnWidth(10),
                          //       3: FlexColumnWidth(10),
                          //       4: FlexColumnWidth(10),
                          //       5: FlexColumnWidth(20),
                          //     },
                          //     children: [
                          //       TableRow(children: [
                          //         Center(
                          //             child: Column(
                          //           children: const [
                          //             Padding(
                          //               padding: EdgeInsets.all(2.0),
                          //               child: Text(
                          //                 '',
                          //                 style: TextStyle(
                          //                     fontSize: 6,
                          //                     fontWeight: FontWeight.bold),
                          //               ),
                          //             ),
                          //           ],
                          //         )),
                          //         const Padding(
                          //           padding: EdgeInsets.all(2.0),
                          //           child: Center(
                          //             child: Text(
                          //               'Total',
                          //               style: TextStyle(
                          //                   fontSize: 6,
                          //                   fontWeight: FontWeight.bold),
                          //             ),
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.all(2.0),
                          //           child: Center(
                          //             child: Text(
                          //               totalQuantity.toStringAsFixed(2),
                          //               style: const TextStyle(
                          //                   fontSize: 6,
                          //                   fontWeight: FontWeight.bold),
                          //             ),
                          //           ),
                          //         ),
                          //         const Padding(
                          //           padding: EdgeInsets.all(2.0),
                          //           child: Center(
                          //             child: Text(
                          //               '',
                          //               style: TextStyle(
                          //                   fontSize: 6,
                          //                   fontWeight: FontWeight.bold),
                          //             ),
                          //           ),
                          //         ),
                          //         const Padding(
                          //           padding: EdgeInsets.all(2.0),
                          //           child: Center(
                          //             child: Text(
                          //               '',
                          //               style: TextStyle(
                          //                   fontSize: 6,
                          //                   fontWeight: FontWeight.bold),
                          //             ),
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding: const EdgeInsets.all(2.0),
                          //           child: Row(
                          //             mainAxisAlignment: MainAxisAlignment.end,
                          //             children: [
                          //               Text(
                          //                 '${lineTotal.toStringAsFixed(2)} ',
                          //                 style: const TextStyle(
                          //                     fontSize: 6,
                          //                     fontWeight: FontWeight.bold),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ]),
                          //     ],
                          //   ),
                          // ),
                         
                          // Container(
                          //   width: MediaQuery.of(context).size.width,
                          //   height: 108,
                          //   decoration: const BoxDecoration(
                          //     border: Border(
                          //       // top: BorderSide(color: Colors.black, width: 2),
                          //       right:
                          //           BorderSide(color: Colors.black, width: 1),
                          //       bottom:
                          //           BorderSide(color: Colors.black, width: 1),
                          //       left: BorderSide(color: Colors.black, width: 1),
                          //     ),
                          //   ),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.start,
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         // Expanded(
                          //         //   child: SizedBox(
                          //         //     width:
                          //         //         MediaQuery.of(context).size.width / 2,
                          //         //     child: Column(
                          //         //       crossAxisAlignment:
                          //         //           CrossAxisAlignment.start,
                          //         //       children: [
                          //         //         const Text(
                          //         //           "Amount In Words :",
                          //         //           style: TextStyle(
                          //         //               fontSize: 8,
                          //         //               decoration:
                          //         //                   TextDecoration.underline),
                          //         //         ),
                          //         //         Text(
                          //         //           NumberToWord().convertDouble(
                          //         //               'en',
                          //         //               double.tryParse(dataInformation[
                          //         //                       'GrandTotal']
                          //         //                   .toString())),
                          //         //           style: const TextStyle(
                          //         //             fontSize: 8,
                          //         //           ),
                          //         //         )
                          //         //       ],
                          //         //     ),
                          //         //   ),
                          //         // ),
                          //         // Expanded(
                          //         //   child: SizedBox(
                          //         //     width:
                          //         //         MediaQuery.of(context).size.width / 2,
                          //         //     child: Column(
                          //         //       crossAxisAlignment:
                          //         //           CrossAxisAlignment.end,
                          //         //       children: [
                          //         //         Row(
                          //         //           mainAxisAlignment:
                          //         //               MainAxisAlignment.spaceBetween,
                          //         //           children: [
                          //         //             Column(
                          //         //               crossAxisAlignment:
                          //         //                   CrossAxisAlignment.start,
                          //         //               children: [
                          //         //                 for (var i = 0;
                          //         //                     i < otherAmount.length;
                          //         //                     i++)
                          //         //                   Text(
                          //         //                     "${otherAmount[i]['LedName']} ",
                          //         //                     style: const TextStyle(
                          //         //                       fontSize: 7,
                          //         //                     ),
                          //         //                   ),
                          //         //                 // const Text(
                          //         //                 //   "Return Amt         :",
                          //         //                 //   style: TextStyle(
                          //         //                 //     fontSize: 8,
                          //         //                 //   ),
                          //         //                 // ),
                          //         //                 const Text(
                          //         //                   "BILL AMOUNT    :",
                          //         //                   style: TextStyle(
                          //         //                     fontSize: 8,
                          //         //                   ),
                          //         //                 ),
                          //         //                 const Text(
                          //         //                   "OB                        :",
                          //         //                   style: TextStyle(
                          //         //                     fontSize: 8,
                          //         //                   ),
                          //         //                 ),
                          //         //                 const Text(
                          //         //                   "Cash Paid   :",
                          //         //                   style: TextStyle(
                          //         //                     fontSize: 8,
                          //         //                   ),
                          //         //                 ),
                          //         //                 const Text(
                          //         //                   "Balance               :",
                          //         //                   style: TextStyle(
                          //         //                     fontSize: 8,
                          //         //                   ),
                          //         //                 ),
                          //         //                 const SizedBox(
                          //         //                   height: 5,
                          //         //                 ),
                          //         //                 // const Text(
                          //         //                 //   "NET AMOUNT    :",
                          //         //                 //   style: TextStyle(
                          //         //                 //       fontSize: 8,
                          //         //                 //       fontWeight:
                          //         //                 //           FontWeight.bold),
                          //         //                 // )
                          //         //               ],
                          //         //             ),
                          //         //             Column(
                          //         //               crossAxisAlignment:
                          //         //                   CrossAxisAlignment.end,
                          //         //               children: [
                          //         //                 for (var i = 0;
                          //         //                     i < otherAmount.length;
                          //         //                     i++)
                          //         //                   Text(
                          //         //                     "${otherAmount[i]['Amount'].toStringAsFixed(2)} ",
                          //         //                     style: const TextStyle(
                          //         //                         fontSize: 8,
                          //         //                         fontWeight:
                          //         //                             FontWeight.bold),
                          //         //                   ),
                          //         //                 // Text(
                          //         //                 //   "${dataInformation['ReturnAmount'].toStringAsFixed(2)} ",
                          //         //                 //   style: const TextStyle(
                          //         //                 //       fontSize: 8,
                          //         //                 //       fontWeight:
                          //         //                 //           FontWeight.bold),
                          //         //                 // ),
                          //         //                 Text(
                          //         //                   "${dataInformation['GrandTotal'].toStringAsFixed(2)} ",
                          //         //                   style: const TextStyle(
                          //         //                       fontSize: 8,
                          //         //                       fontWeight:
                          //         //                           FontWeight.bold),
                          //         //                 ),
                          //         //                 Text(
                          //         //                   "${dataInformation['Balance'].toStringAsFixed(2)} ",
                          //         //                   style: const TextStyle(
                          //         //                       fontSize: 8,
                          //         //                       fontWeight:
                          //         //                           FontWeight.bold),
                          //         //                 ),
                          //         //                 Text(
                          //         //                   "${dataInformation['CashPaid'].toStringAsFixed(2)} ",
                          //         //                   style: const TextStyle(
                          //         //                       fontSize: 8,
                          //         //                       fontWeight:
                          //         //                           FontWeight.bold),
                          //         //                 ),
                          //         //                 Text(
                          //         //                   "${(double.parse(dataInformation['GrandTotal'].toStringAsFixed(2)) + double.parse(dataInformation['Balance'].toStringAsFixed(2)) - double.parse(dataInformation['CashPaid'].toStringAsFixed(2))).toStringAsFixed(2)} ",
                          //         //                   style: const TextStyle(
                          //         //                       fontSize: 8,
                          //         //                       fontWeight:
                          //         //                           FontWeight.bold),
                          //         //                 ),
                          //         //                 const SizedBox(
                          //         //                   height: 5,
                          //         //                 ),
                          //         //                 // Text(
                          //         //                 //   "${(lineTotal - dataInformation['ReturnAmount'] + otherAmount.fold(0.0, (t, e) => t + double.parse(e['Symbol'] == '-' ? (e['Amount'] * -1).toString() : e['Amount'].toString()))).toStringAsFixed(2)} ",
                          //         //                 //   style: const TextStyle(
                          //         //                 //       fontSize: 8,
                          //         //                 //       fontWeight:
                          //         //                 //           FontWeight.bold),
                          //         //                 // ),
                          //         //               ],
                          //         //             )
                          //         //           ],
                          //         //         ),
                          //         //       ],
                          //         //     ),
                          //         //   ),
                          //         // ),                              
                          //       ],
                          //     ),
                          //   ),
                          // )
  
  var pdfPath = '';
  Future<String> _createPDF(
    String title,
   ) async {
    
  return makePDF( title)
      .then((value) => savePreviewPDF(value, title));
}
Future<pw.Document> makePDF(
    String title,
   ) async {
   var dParticulars  = cart;
    var rParticulars = replacementCart;
    var complaints = complaint;
    double totalQuantity = dParticulars.fold(
        0, (total, particular) => total + particular.qty!);
        double lineTotal = dParticulars.fold(
        0, (total, particular) => total + particular.total!);

  bool printHeaderOnES =
      ComSettings.appSettings('bool', 'key-print-header-es', false);
  // var taxSale = dataInformation['TaxType'] == 'T' ? true : false;
  // var invoiceHead = Settings.getValue<String>('key-purchase-return-head',
      // defaultValue: 'PURCHASE RETURN');
  // int? decimal = ComSettings.getValue('DECIMAL', settings).toString().isNotEmpty
  //     ? int.tryParse(ComSettings.getValue('DECIMAL', settings).toString())
  //     : 2;
  // bool isItemSerialNo = ComSettings.getStatus('KEY ITEM SERIAL NO', settings);
  // var labelSerialNo =
  //     ComSettings.getValue('KEY ITEM SERIAL NO', settings).toString();
  // labelSerialNo.isNotEmpty ?? 'SerialNo';
  var tableHeaders = ["No", "Item Name", "Qty", "Srate", "Status", "Total"];

  // final imageQr = byteImageQr != null
  //     ? pw.MemoryImage(Uint8List.fromList(byteImageQr!))
  //     : null;

  final pdf = pw.Document();
  var _pageFormat = PdfPageFormat.a4;


       pdf.addPage(pw.MultiPage(
          maxPages: 100,
          pageFormat: PdfPageFormat.a4,
          header: (pw.Context context) => _buildEstimateHeader(
            settings, companySettings,
          ),
         
          build: (pw.Context context) {
            double calculateEstTotalAmount(List<dynamic> perticu) {
              return perticu.fold(
                  0,
                  (total, particular) =>
                      total + particular['Total'].toDouble());
            }

            double calculateEstTotalQuantity(List<dynamic> perticu) {
              return perticu.fold(0,
                  (total, particular) => total + particular['Qty'].toDouble());
            }

            final int totalRowCount = 53; // Desired total row count
            final int existingRowCount = dParticulars.length;

// Calculate the number of empty rows needed
            final int emptyRowCount = totalRowCount - existingRowCount;
            List<pw.Widget> widgets = [
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Table(
                  border: const pw.TableBorder(
                    horizontalInside: pw.BorderSide
                        .none, // Remove horizontal borders inside the table

                    verticalInside: pw.BorderSide(), // Keep vertical borders
                  ),
                  columnWidths: const {
                    0: pw.FixedColumnWidth(15),
                    1: pw.FlexColumnWidth(20),
                    2: pw.FlexColumnWidth(10),
                    3: pw.FlexColumnWidth(10),
                    4: pw.FlexColumnWidth(10),
                    5: pw.FlexColumnWidth(20),
                    6: pw.FlexColumnWidth(20),
                  },
                  children: [
                    for (var i = 0; i < dParticulars.length; i++)
                      pw.TableRow(children: [
                        pw.Center(
                            child: pw.Column(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                '${i + 1}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                          ],
                        )),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Text(
                            dParticulars[i].productName!,
                            style: pw.TextStyle(
                                fontSize: 9, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Row(
                             mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                               pw.Text(
                            dParticulars[i].qty!.toStringAsFixed(2),
                            style: pw.TextStyle(
                                fontSize: 9, fontWeight: pw.FontWeight.bold),
                          ),
                            ]
                          )
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Text(
                                dParticulars[i].sRate!.toStringAsFixed(2),
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(""),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                dParticulars[i].status!,
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Text(
                                dParticulars[i].total!.toStringAsFixed(2),
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Text(
                            i < complaints.length ? complaints[i].complaint! : '',
                            maxLines: 3,
                            style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ]),
                    // if (dataParticulars.length > 45)
                    //   for (var k = 0; k < 45; k++)
                    //     pw.TableRow(children: [
                    //       pw.Center(
                    //           child: pw.Column(
                    //         children: [
                    //           pw.Padding(
                    //             padding: const pw.EdgeInsets.all(2.0),
                    //             child: pw.Text(
                    //               '\n',
                    //               style: pw.TextStyle(
                    //                   fontSize: 6,
                    //                   fontWeight: pw.FontWeight.bold),
                    //             ),
                    //           ),
                    //         ],
                    //       )),
                    //       pw.Padding(
                    //         padding: const pw.EdgeInsets.all(2.0),
                    //         child: pw.Text(
                    //           '',
                    //           style: pw.TextStyle(
                    //               fontSize: 6, fontWeight: pw.FontWeight.bold),
                    //         ),
                    //       ),
                    //       pw.Padding(
                    //         padding: const pw.EdgeInsets.all(2.0),
                    //         child: pw.Center(
                    //           child: pw.Text(
                    //             '',
                    //             style: pw.TextStyle(
                    //                 fontSize: 6,
                    //                 fontWeight: pw.FontWeight.bold),
                    //           ),
                    //         ),
                    //       ),
                    //       pw.Padding(
                    //         padding: const pw.EdgeInsets.all(2.0),
                    //         child: pw.Row(
                    //           mainAxisAlignment: pw.MainAxisAlignment.end,
                    //           children: [
                    //             pw.Text(
                    //               '',
                    //               style: pw.TextStyle(
                    //                   fontSize: 6,
                    //                   fontWeight: pw.FontWeight.bold),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       pw.Padding(
                    //         padding: const pw.EdgeInsets.all(2.0),
                    //         child: pw.Row(
                    //           mainAxisAlignment: pw.MainAxisAlignment.end,
                    //           children: [
                    //             pw.Text(
                    //               '',
                    //               style: pw.TextStyle(
                    //                   fontSize: 6,
                    //                   fontWeight: pw.FontWeight.bold),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       pw.Padding(
                    //         padding: const pw.EdgeInsets.all(2.0),
                    //         child: pw.Row(
                    //           mainAxisAlignment: pw.MainAxisAlignment.end,
                    //           children: [
                    //             pw.Text(
                    //               '',
                    //               style: pw.TextStyle(
                    //                   fontSize: 6,
                    //                   fontWeight: pw.FontWeight.bold),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ]),
                    for (var j = 0; j < emptyRowCount; j++)
                      pw.TableRow(children: [
                        pw.Center(
                            child: pw.Column(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                '\n',
                                style: pw.TextStyle(
                                    fontSize: 6,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                          ],
                        )),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Text(
                            '',
                            style: pw.TextStyle(
                                fontSize: 6, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Center(
                            child: pw.Text(
                              '',
                              style: pw.TextStyle(
                                  fontSize: 6, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Text(
                                '',
                                style: pw.TextStyle(
                                    fontSize: 6,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Text(
                                '',
                                style: pw.TextStyle(
                                    fontSize: 6,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Text(
                                '',
                                style: pw.TextStyle(
                                    fontSize: 6,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                     
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2.0),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Text(
                                '',
                                style: pw.TextStyle(
                                    fontSize: 6,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                     
                      ]),
                 
                  ],
                ),
              ),
              // pw.Container(
              //   decoration: const pw.BoxDecoration(
              //       color: PdfColor.fromInt(0xFFCCCCCC),
              //       border: pw.Border(
              //           bottom: pw.BorderSide(),
              //           left: pw.BorderSide(),
              //           right: pw.BorderSide())),
              //   child: pw.Table(
              //     border: const pw.TableBorder(
              //       horizontalInside: pw.BorderSide
              //           .none, // Remove horizontal borders inside the tabl
              //       verticalInside: pw.BorderSide(), // Keep vertical borders
              //     ),
              //     columnWidths: const {
              //       0: pw.FixedColumnWidth(15),
              //       1: pw.FlexColumnWidth(20),
              //       2: pw.FlexColumnWidth(10),
              //       3: pw.FlexColumnWidth(10),
              //       4: pw.FlexColumnWidth(10),
              //       5: pw.FlexColumnWidth(20),
              //     },
              //     children: [
              //       pw.TableRow(children: [
              //         pw.Center(
              //             child: pw.Column(
              //           children: [
              //             pw.Padding(
              //               padding: const pw.EdgeInsets.all(2.0),
              //               child: pw.Text(
              //                 '',
              //                 style: pw.TextStyle(
              //                     fontSize: 6, fontWeight: pw.FontWeight.bold),
              //               ),
              //             ),
              //           ],
              //         )),
              //         pw.Padding(
              //           padding: const pw.EdgeInsets.all(2.0),
              //           child: pw.Center(
              //             child: pw.Text(
              //               'Total',
              //               style: pw.TextStyle(
              //                   fontSize: 6, fontWeight: pw.FontWeight.bold),
              //             ),
              //           ),
              //         ),
              //         pw.Padding(
              //           padding: const pw.EdgeInsets.all(2.0),
              //           child: pw.Center(
              //             child: pw.Text(
              //               '${calculateEstTotalQuantity(dataParticulars)}',
              //               style: pw.TextStyle(
              //                   fontSize: 6, fontWeight: pw.FontWeight.bold),
              //             ),
              //           ),
              //         ),
              //         pw.Padding(
              //           padding: const pw.EdgeInsets.all(2.0),
              //           child: pw.Center(
              //             child: pw.Text(
              //               '',
              //               style: pw.TextStyle(
              //                   fontSize: 6, fontWeight: pw.FontWeight.bold),
              //             ),
              //           ),
              //         ),
              //         pw.Padding(
              //           padding: const pw.EdgeInsets.all(2.0),
              //           child: pw.Center(
              //             child: pw.Text(
              //               '',
              //               style: pw.TextStyle(
              //                   fontSize: 6, fontWeight: pw.FontWeight.bold),
              //             ),
              //           ),
              //         ),
              //         pw.Padding(
              //           padding: const pw.EdgeInsets.all(2.0),
              //           child: pw.Row(
              //             mainAxisAlignment: pw.MainAxisAlignment.end,
              //             children: [
              //               pw.Text(
              //                 '${calculateEstTotalAmount(dataParticulars).toStringAsFixed(2)} ',
              //                 style: pw.TextStyle(
              //                     fontSize: 6, fontWeight: pw.FontWeight.bold),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ]),
              //     ],
              //   ),
              // ),
           
           ];

            return widgets;
          },
        ));

  documentPDF = pdf;
  return pdf;
}

_buildEstimateHeader(
    company, cSettings,) {
  var companyState = ComSettings.getValue('COMP-STATE', company);
  var companyStateCode = ComSettings.getValue('COMP-STATECODE', company);
  var companyTaxNo = ComSettings.getValue('GST-NO', company);
  return pw.Column(children: [
   pw.Container(),
    pw.Container(
      width: double.infinity,
      height: 30,
      decoration: pw.BoxDecoration(
          color: const pw.PdfColor.fromInt(0xFFCCCCCC),
          border: pw.Border.all()),
      child: pw.Center(
          child: pw.Text(
        'Warranty Invoice',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      )),
    ),
    pw.Container(
      width: double.infinity,
      height: 100,
      decoration: const pw.BoxDecoration(
          border: pw.Border(
              left: pw.BorderSide(),
              right: pw.BorderSide(),
              bottom: pw.BorderSide())),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            height: 8,
          ),
          pw.Row(
            children: [
              pw.Text(
                "  No                :",
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                "   ${entryNo}",
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Text(
                "  Date             :",
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                "   ${formattedDate}",
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Text(
                "  To                :",
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                "    ${customerNameController.text}",
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
          // pw.Row(
          //   crossAxisAlignment: pw.CrossAxisAlignment.start,
          //   children: [
          //     pw.Text(
          //       "  Address       :",
          //       style: const pw.TextStyle(fontSize: 9),
          //     ),
          //     // pw.Column(
          //     //   crossAxisAlignment: pw.CrossAxisAlignment.start,
          //     //   children: [
          //     //     pw.Text(
          //     //       "    ${dataInformation['Add1']}",
          //     //       style: const pw.TextStyle(fontSize: 8),
          //     //     ),
          //     //     pw.Text(
          //     //       "    ${dataInformation['Add2']}",
          //     //       style: const pw.TextStyle(fontSize: 8),
          //     //     ),
          //     //     pw.Text(
          //     //       "    ${dataInformation['Add3']}",
          //     //       style: const pw.TextStyle(fontSize: 8),
          //     //     ),
          //     //     pw.Text(
          //     //       "    ${dataInformation['Add4']}",
          //     //       style: const pw.TextStyle(fontSize: 8),
          //     //     ),
          //     //   ],
          //     // ),
           
          //   ],
          // ),
        ],
      ),
    ),
    pw.Container(
      decoration: pw.BoxDecoration(
          color: const pw.PdfColor.fromInt(0xFFCCCCCC),
          border: pw.Border.all()),
      child: pw.Table(
        border: const pw.TableBorder(
          horizontalInside:
              pw.BorderSide.none, // Remove horizontal borders inside the table

          verticalInside: pw.BorderSide(), // Keep vertical borders
        ),
        columnWidths: const {
          0: pw.FixedColumnWidth(15),
          1: pw.FlexColumnWidth(20),
          2: pw.FlexColumnWidth(10),
          3: pw.FlexColumnWidth(10),
          4: pw.FlexColumnWidth(10),
          5: pw.FlexColumnWidth(20),
          6: pw.FlexColumnWidth(20),
        },
        children: [
          pw.TableRow(children: [
            pw.Center(
                child: pw.Column(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(2.0),
                  child: pw.Text(
                    'No',
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            )),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                child: pw.Text(
                  'Item Name',
                  style:
                      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                child: pw.Text(
                  'Qty',
                  style:
                      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                child: pw.Text(
                  'Srate',
                  style:
                      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                child: pw.Text(
                  'Status',
                  style:
                      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                child: pw.Text(
                  'Total',
                  style:
                      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Center(
                child: pw.Text(
                  'Complaint',
                  style:
                      pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
          ]),
        ],
      ),
    ),
  ]);
}




  showErrorDialog(context, String msg) {
    debugPrint('error save warranty :$msg');
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
          fetchWarranty(context, dataDynamic);
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage:
            'Do you want to edit or delete\nRefNo:${dataDynamic}',
        title: 'Update',
        context: context);
  } 

  fetchWarranty(context,data){
    setState(() {
      isLoading = true;
    });
    api.fetchWarranty(data).then((value) {
      if (value != null) {
         var information = value[0];
        var particulars = value[1];
        var replacement = value[2];
        var complaint = value[3];
        debugPrint(value.toString());
        // debugPrint(particulars.toString());
        entryNo = information[0]['EntryNo'].toString();
        entryNoController.text = entryNo;
        formattedDate = DateUtil.dateDMY(information[0]['WDate']);
        customerNameController.text = information[0]['CustomerName'];
        customer = WarrantyCustomerModel(
          auto: information[0]['Auto'],
          entryNo: information[0]['EntryNo'],
          wDate: information[0]['WDate'],
          customer: information[0]['Customer'],
          location: information[0]['Location'],
          mobile: information[0]['mobile'],
          userId: information[0]['UserID'],
          warrantyLocation: information[0]['WarrentyLocation'],
          salesman: information[0]['salesman'],
          fyId: information[0]['FyID'],
          transferStatus: information[0]['TransferStatus'],
          customerName: information[0]['CustomerName']
        ); 
        for (var product in particulars){
          addProduct( 
               WarrantyCart(
          entryNo: product['EntryNo'],
          wDate: product['WDate'],
          auto: product['Auto'],
          barcode: product['Barcode'],
          itemId: product['Itemid'],
          serialNo: product['Serialno'],
          qty: product['Qty'],
          sRate: product['Srate'].toDouble(),
          total: product['Total'].toDouble(),
          narration: product['Narration'],
          eType: product['EType'],
          status: product['Status'],
          gid: product['Gid'],
          location: product['Location'],
          warrantyDate: product['WarrentyDate'],
          fyId: product['FyId'] ?? 0,
          transferStatus: product['TransferStatus'],
          productName: product['ProductName']
        ), -1);
        }
        for(var items in replacement){
          addReplacement(
            WarrantyRepalceModel(
              entryNo: items['EntryNo'],
          wDate: DateUtil.dateDMY(items['WDate']),
          auto: items['Auto'],
          barcode: items['Barcode'],
          itemId: items['Itemid'],
          serialNo: items['Serialno'],
          qty: items['Qty'],
          sRate: items['Srate'].toDouble(),
          total: items['Total'].toDouble(),
          narration: items['Narration'],
          eType: items['EType'],
          status: items['Status'],
          gid: items['Gid'],
          location: items['Location'],
          warrantyDate: items['WarrentyDate'],
          fyId: items['FyId'] ?? 0,
          transferStatus: items['TransferStatus'],
          productName: items['ProductName']
            ), -1);
        }
        for(var cm in complaint){
          addComplaints(
            WarrantyComplaintModel(
            complaint: cm['Complaints'],
            gid: cm['gid']
          ), -1);
        }
        
        setState(() {
          widgetID = false;
          oldBill = true;
        });
      }
    });
    
  }

  showPreview(context,int id)async{
      setState(() {
          isPrLoading = true;
          // widgetID = false;
        });
    try {
      api.fetchWarranty(id).then((value) {
      if (value != null) {
        var information = value[0];
        var particulars = value[1];
        var replacement = value[2];
        var complaint = value[3];
        debugPrint(value.toString());
        // debugPrint(particulars.toString());
        entryNo = information[0]['EntryNo'].toString();
        entryNoController.text = entryNo;
        formattedDate = DateUtil.dateDMY(information[0]['WDate']);
        customerNameController.text = information[0]['CustomerName'];
        customer = WarrantyCustomerModel(
          auto: information[0]['Auto'],
          entryNo: information[0]['EntryNo'],
          wDate: information[0]['WDate'],
          customer: information[0]['Customer'],
          location: information[0]['Location'],
          mobile: information[0]['mobile'],
          userId: information[0]['UserID'],
          warrantyLocation: information[0]['WarrentyLocation'],
          salesman: information[0]['salesman'],
          fyId: information[0]['FyID'],
          transferStatus: information[0]['TransferStatus'],
          customerName: information[0]['CustomerName']
        ); 
        for (var product in particulars){
          addProduct( 
               WarrantyCart(
          entryNo: product['EntryNo'],
          wDate: product['WDate'],
          auto: product['Auto'],
          barcode: product['Barcode'],
          itemId: product['Itemid'],
          serialNo: product['Serialno'],
          qty: product['Qty'],
          sRate: product['Srate'].toDouble(),
          total: product['Total'].toDouble(),
          narration: product['Narration'],
          eType: product['EType'],
          status: product['Status'],
          gid: product['Gid'],
          location: product['Location'],
          warrantyDate: product['WarrentyDate'],
          fyId: product['FyId'] ?? 0,
          transferStatus: product['TransferStatus'],
          productName: product['ProductName']
        ), -1);
        }
        for(var items in replacement){
          addReplacement(
            WarrantyRepalceModel(
              entryNo: items['EntryNo'],
          wDate: DateUtil.dateDMY(items['WDate']),
          auto: items['Auto'],
          barcode: items['Barcode'],
          itemId: items['Itemid'],
          serialNo: items['Serialno'],
          qty: items['Qty'],
          sRate: items['Srate'].toDouble(),
          total: items['Total'].toDouble(),
          narration: items['Narration'],
          eType: items['EType'],
          status: items['Status'],
          gid: items['Gid'],
          location: items['Location'],
          warrantyDate: items['WarrentyDate'],
          fyId: items['FyId'] ?? 0,
          transferStatus: items['TransferStatus'],
          productName: items['ProductName']
            ), -1);
        }
        for(var cm in complaint){
          addComplaints(
            WarrantyComplaintModel(
            complaint: cm['Complaints'],
            gid: cm['gid']
          ), -1);
        }
        
        setState(() {
          isPrLoading = false;
          nextWidget = 2;
          widgetID = false;
        });
        
      }
    });
    } catch (e) {
      
    }
  }
    
    void addProduct(product, int index) {
    // index = isFreeItem
    //     ? index
    //     : cartItem.indexWhere((i) => i.itemId == product.itemId);

    // if (index != -1) {
    //   updateProduct(
    //       product, cartItem[index].quantity! + product.quantity, index);
    // } else {
      cart.add(product);
      // calculateTotal();
    // }
  }
    void addReplacement(product, int index) {
      replacementCart.add(product);
  }

   void updateProduct(product,int index){
    cart[index].entryNo = int.parse(entryNo);
    cart[index].wDate = wDate;
    cart[index].auto = auto;
    cart[index].barcode = barcode;
    cart[index].itemId = itemId;
    cart[index].serialNo = serialNo;
    cart[index].qty = qty;
    cart[index].sRate = sRate;
    cart[index].total = total?.toDouble();
    cart[index].narration = narration;
    cart[index].eType = eType;
    cart[index].status = selectedStatus;
    cart[index].gid = gid;
    cart[index].location = location;
    cart[index].warrantyDate = warrantyDate;
    cart[index].transferStatus = transferStatus;
    cart[index].productName = productName;
   }
   void updateReplacement(product,int index){
    replacementCart[index].entryNo = int.parse(reEntryNo!);
    replacementCart[index].wDate = reWDate;
    replacementCart[index].auto = reAauto;
    replacementCart[index].barcode = reBarcode;
    replacementCart[index].itemId = reSelectedItemId;
    replacementCart[index].serialNo = reSerialNo;
    replacementCart[index].qty = reQty;
    replacementCart[index].sRate = reSrate;
    replacementCart[index].total = reTotal?.toDouble();
    replacementCart[index].narration = narration;
    replacementCart[index].eType = reEtype;
    replacementCart[index].status = reStatus;
    replacementCart[index].gid = reGid;
    replacementCart[index].location = reLocation;
    replacementCart[index].warrantyDate = reWarrantyDate;
    replacementCart[index].transferStatus = reTransferStatus;
    replacementCart[index].productName = reProductName;
   }

   void addComplaints(cmp ,int index){
    complaint.add(cmp);
   }
  
  clearValue(){
   itemNameContrroler.text = '';
   reItemNameContrroler.text = '';
   qtyContrroler.text = '';
   reQtyContrroler.text = '';
   sRateContrroler.text = '';
   reSrateContrroler.text = '';
   narrationContrroler.text = '';
   complaintsContrroler.text = '';
   selectedWlocation  = 0;
   wDate = '';
   auto = 0;
   barcode = 0;
   itemId = 0;
   serialNo = '';
   reSerialNo = '';
   qty = 0;
   reUniquecode = 0;
   sRate = 0;
   total = 0;
   narration = '';
   eType = '';
   status = '';
   gid = 0;
   location = 0;
   warrantyDate = '';
   fyId = 0;
   transferStatus = 0;
   productName = '';
   reProductName = '';
   selectedItemId = 0;
   reSelectedItemId = 0;
   reEtype = '';
   reStatus = '';
   reWDate = '';
   reWarrantyDate = '';
   reEntryNo = '';
   reAauto = 0;
   reBarcode = 0;
   reQty = 0;
   reGid = 0;
   reLocation = 0;
   reFyId = 0;
   reTransferStatus = 0;
   reSrate = 0;
   reTotal = 0;
  }
   showMore(context, bool newBill) {
    ConfirmAlertBox(
        buttonColorForNo: Colors.red,
        buttonColorForYes: Colors.green,
        icon: Icons.check,
        onPressedNo: () async{
           try {
          final value = await api.getWarrantyEntryNo('Reseed');
          debugPrint(value);
          setState(() {
            entryNo = value;
            entryNoController .text = entryNo;
            // selectedSupplierId = 0;
            // customerNameController.text = '';
            // cart.clear();
            // replacementCart.clear();
            // complaint.clear();
            isLoading = false;
            _isLoading = false;
            buttonEvent = false;
          });
        } catch (error) {
          debugPrint("Error: $error");
        } finally {
          setState(() {
            _isLoading = false;
            isLoading = false; 
            buttonEvent = false;
          });
        }
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const Warranty())
              );
        },
        onPressedYes: () {
          Navigator.of(context).pop();
          setState(() {
            nextWidget = 2;
          });
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage:
            'Do you want to Preview\nEntryNo : ${entryNo}',
        title: newBill ? 'SAVED' : 'EDITED',
        context: context);
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
  Future _selectWarrentyDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => {warrentyformattedDate = DateFormat('dd-MM-yyyy').format(picked)});
    }
  }
}