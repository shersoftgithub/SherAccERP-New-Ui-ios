import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
import 'package:sheraccerp/widget/progress_hud.dart';

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
  DateTime now = DateTime.now();
  int page = 1, pageTotal = 0, totalRecords = 0;
  int lId = 0, groupId = 0, areaId = 0, routeId = 0;
  var salesManId = 0;
  int saleAccount = 0, acId = 0, decimal = 2;
   List<WarrantyCart> cart  = [];
   List<WarrantyRepalceModel> replacementCart = [];
   WarrantyCustomerModel? customer ;
   List<WarrantyComplaintModel> complaint = [];
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
      taxable = true;

  bool isLoading = false; 
    final List<String> statusOptions = [
    'Pending',
    'Repair',
    'Replace',
    'Reject',
    'Transfer To Mfr',
    'Sales Return',
  ];   
  
   @override
  void initState() {
    super.initState();
    formattedDate =
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
          appBar: nextWidget != 1? AppBar(
            title: const Text("Warranty"),
            titleTextStyle: const TextStyle(
              fontFamily: 'poppins'
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
            fontFamily: 'poppins'
          ),
          actions: [
            Visibility(
              visible: previewData,
              child: TextButton(
                  style: TextButton.styleFrom(
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
                    'New Warranty Note',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
            ),
          ],
        ),
        body: Padding(
           padding: const EdgeInsets.symmetric(
                horizontal: 16,vertical: 8
              ),
          child: Container(
            child: previousBill(),
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
                    showEditDialog(context, dataDisplay[index]['Id']);
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
                            // Expanded(
                            //   flex: 2,
                            //   child: InkWell(
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.end,
                            //       children: [
                            //         const Text(
                            //           'Total',
                            //           style: TextStyle(
                            //             fontSize: 14,
                            //             color: ColorPalette.nileBlue,
                            //           ),
                            //         ),
                            //         Expanded(
                            //           child: Align(
                            //             alignment: Alignment.centerRight,
                            //             child: Text(
                            //                 '${dataDisplay[index]['Total'].toStringAsFixed(decimal)}'),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //     onTap: () {
                            //       // showDetails(context, dataDisplay[index]);
                            //     },
                            //   ),
                            // ), 
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
                  onPressed: () {
                    setState(() {
                      widgetID = false;
                    });
                  },
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Take New DeliveryNote',
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
            : Text('No Widget') ;
  }


  final expandedHeight = 472.0;
  final collapsedHeight =   160.0;
  final collaps = 300.0;
 bool isExpanded = false;
 final animationDuration = const Duration(milliseconds: 400);
 final entryNoController = TextEditingController();
 final customerNameController = TextEditingController();
 String entryNo = '';
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
                  ContainerFieldWidget(
                    widget: TextField(
                      style: TextStyle(
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
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
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
                                                                ), headTxt: 'Warranty Location'),
                                                                    SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    ContainerFieldWidget(
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
                                                                  SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    ContainerFieldWidget(
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
                                  ],
                                ),
                              ),
                            ),
                ],
              )
            ),
            const SizedBox(
              height: 8,
            ),
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
                                          nextWidget = 1;
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
                                          total = cart[index].total!;
                                          narration = cart[index].narration!;
                                          eType = cart[index].eType!;
                                          gid = cart[index].gid!;
                                          location = cart[index].location!;
                                          warrantyDate = cart[index].warrantyDate!;
                                          fyId = cart[index].fyId!;
                                          transferStatus = cart[index].transferStatus!;
                                          productName = cart[index].productName!;

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
                                                         '# ${cart[index].auto}',
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
                                                  Text(
                                                    'Qty',
                                                    style: const TextStyle(
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
                                                   '₹ ${cart[index].sRate!.toStringAsFixed(2)}',
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
                                child:  const Center(
                                  child: 
                                   Text(
                                     'Delete',
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
                    setState(() {
                      editWarranty();
                    });
                    },
                    child: Container(
                                  height: 60,
                                  color: kPrimaryColor,
                                  child:  const Center(
                                    child: 
                                     Text(
                                     'Edit',
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
  final qtyContrroler = TextEditingController();
  String selectedStatus = 'Pending';
  String? wDate;
  int? auto;
  int? barcode;
  int? itemId;
  String? serialNo;
  int? qty;
  int? sRate;
  int? total;
  String? narration;
  String? eType;
  String? status;
  int? gid;
  int? location;
  String? warrantyDate;
  int? fyId;
  int? transferStatus;
  String? productName;
  itemDetailWidget(){
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            setState(() {
              nextWidget = 0;
            }); 
          }, icon: const Icon(Icons.arrow_back)),
         title: const Text("Item Details"),
            titleTextStyle: const TextStyle(
              fontFamily: 'poppins'
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
                  ContainerFieldWidget(
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
                        Expanded(child: ContainerFieldWidget(
                          widget: TextField(
                             style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14
                      ),
                          controller: qtyContrroler,
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
                    )
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
                                child:  const Center(
                                  child: 
                                   Text(
                                     'Delete',
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
                      setState(() {
                        updateProduct(WarrantyCart(
                          entryNo: int.parse(entryNo),
                          wDate: wDate,
                          auto: auto,
                          barcode: barcode,
                          itemId: itemId,
                          serialNo: serialNo,
                          qty: qty,
                          sRate: sRate,
                          total: total,
                          narration: narration,
                          eType: eType,
                          status: selectedStatus,
                          gid: gid,
                          location: location,
                          warrantyDate: warrantyDate,
                          fyId: fyId,
                          transferStatus: transferStatus,
                          productName: productName,
                      ), 0);
                      nextWidget = 0;
                      debugPrint(cart.toList().toString());
                      });
                    },
                    child: Container(
                                  height: 60,
                                  color: kPrimaryColor,
                                  child:  const Center(
                                    child: 
                                     Text(
                                     'Edit',
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
    
    'information':mapValue,
    'particular': json.encode(combinedList),
    'complaints': json.encode(complaintList),
  };
  
  
  debugPrint(json.encode(body).toString());
  api.editWarranty(body).then((value) {
    if (CommonService().isNumeric(value) && int.tryParse(value)! > 0) {
      Fluttertoast.showToast(
        backgroundColor: green,
        msg: 'Warranty Updated');
    }else {
        showErrorDialog(context, value.toString());
      }
  });
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
        var compliant = value[3];
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
          sRate: product['Srate'],
          total: product['Total'],
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
          sRate: items['Srate'],
          total: items['Total'],
          narration: items['Narration'],
          eType: items['EType'],
          status: items['Status'],
          gid: items['Gid'],
          location: items['Location'],
          warrantyDate: items['WarrantyDate'],
          fyId: items['FyId'] ?? 0,
          transferStatus: items['TransferStatus'],
          productName: items['ProductName']
            ), -1);
        }
        for(var cm in compliant){
          addCompliants(WarrantyComplaintModel(
            complaint: cm['Complaints'],
            gid: cm['gid']
          ), -1);
        }
        
        setState(() {
          widgetID = false;
        });
      }
    });
    
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
    cart[index].total = total;
    cart[index].narration = narration;
    cart[index].eType = eType;
    cart[index].status = selectedStatus;
    cart[index].gid = gid;
    cart[index].location = location;
    cart[index].warrantyDate = warrantyDate;
    cart[index].transferStatus = transferStatus;
    cart[index].productName = productName;
   }
   void addCompliants(cmp ,int index){
    complaint.add(cmp);
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
}