// import 'dart:convert';

// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
// import 'package:intl/intl.dart';
// import 'package:scoped_model/scoped_model.dart';
// import 'package:sheraccerp/app_settings_page.dart';
// import 'package:sheraccerp/models/cart_item.dart';
// import 'package:sheraccerp/models/company.dart';
// import 'package:sheraccerp/models/stock_item.dart';
// import 'package:sheraccerp/models/stock_product.dart';
// import 'package:sheraccerp/scoped-models/mains.dart';
// import 'package:sheraccerp/service/api_dio.dart';
// import 'package:sheraccerp/service/com_service.dart';
// import 'package:sheraccerp/shared/constants.dart';
// import 'package:sheraccerp/util/color_palette.dart';
// import 'package:sheraccerp/util/dateUtil.dart';
// import 'package:sheraccerp/util/res_color.dart';
// import 'package:sheraccerp/widget/popup_menu_action.dart';
// import 'package:sheraccerp/widget/progress_hud.dart';

// class StockTransfer extends StatefulWidget {
//   const StockTransfer({Key? key}) : super(key: key);

//   @override
//   State<StockTransfer> createState() => _StockTransferState();
// }

// class _StockTransferState extends State<StockTransfer> {
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   DioService dio = DioService();
//   Size? deviceSize;
//   StockItem? productModel;
//   DateTime now = DateTime.now();
//   String? formattedDate, _narration = '';
//   bool valueMore = false,
//       _isLoading = false,
//       widgetID = true,
//       oldBill = false,
//       lastRecord = false,
//       buttonEvent = false;
//   List<CartItemST> cartItem = [];
//   int page = 1, pageTotal = 0, totalRecords = 0;
//   List<dynamic> itemDisplay = [];
//   List<dynamic> items = [];
//   List<dynamic> locationData = [];
//   bool enableMULTIUNIT = false,
//       cessOnNetAmount = false,
//       enableKeralaFloodCess = false,
//       useUNIQUECODEASBARCODE = false,
//       useOLDBARCODE = false,
//       realPRATEBASEDPROFITPERCENTAGE = false,
//       keyItemsVariantStock = false,
//       taxGroupUpdate = false;
//   int salesManId = 0, decimal = 2, locationFromId = 0, locationToId = 0;

//   @override
//   void initState() {
//     super.initState();
//     formattedDate = DateFormat('dd-MM-yyyy').format(now);
//     loadSettings();
//   }

//   loadSettings() {
//     CompanyInformation companySettings =
//         ScopedModel.of<MainModel>(context).getCompanySettings();
//     List<CompanySettings> settings =
//         ScopedModel.of<MainModel>(context).getSettings();

//     taxMethod = companySettings.taxCalculation!;
//     enableMULTIUNIT = ComSettings.getStatus('ENABLE MULTI-UNIT', settings);
//     companyTaxMode = ComSettings.getValue('PACKAGE', settings);
//     cessOnNetAmount = ComSettings.getStatus('CESS ON NET AMOUNT', settings);
//     enableKeralaFloodCess = false;
//     useUNIQUECODEASBARCODE =
//         ComSettings.getStatus('USE UNIQUECODE AS BARCODE', settings);
//     useOLDBARCODE = ComSettings.getStatus('USE OLD BARCODE', settings);
//     realPRATEBASEDPROFITPERCENTAGE =
//         ComSettings.getStatus('REAL PRATE BASED PROFIT PERCENTAGE', settings);

//     salesManId = ComSettings.appSettings(
//             'int', 'key-dropdown-default-salesman-view', 1) -
//         1;
//     decimal = (ComSettings.getValue('DECIMAL', settings).toString().isNotEmpty
//         ? int.tryParse(ComSettings.getValue('DECIMAL', settings).toString())
//         : 2)!;
//     keyItemsVariantStock =
//         ComSettings.getStatus('KEY LOCK SALES DISCOUNT', settings);
//     taxGroupUpdate = 
//         ComSettings.getStatus('KEY TAXGROUP UPDATE', settings!);     

//     locationData.clear();
//     if (locationList.isNotEmpty) {
//       locationData = locationList;
//       try {
//         if (locationList
//                 .where((element) => element.value == '')
//                 .map((e) => e.key)
//                 .first ==
//             1) {
//           locationData.removeAt(0);
//           locationData.insert(
//               0, AppSettingsMap(key: 0, value: 'Select Branch'));
//         }
//       } catch (ex) {
//         debugPrint(ex.toString());
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     deviceSize = MediaQuery.of(context).size;
//     return PopScope(
//         canPop: false,
//         onPopInvoked: (didPop) async {
//           if (didPop) {
//             return;
//           }
//           final NavigatorState navigator = Navigator.of(context);
//           final bool? shouldPop = await _onWillPop();
//           if (shouldPop ?? false) {
//             navigator.pop();
//           }
//         },
//         child: widgetID ? widgetPrefix() : widgetSuffix());
//   }

//   _onWillPop() async {
//     return (await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Are you sure?'),
//             content: const Text('Do you want to exit Stock Transfer'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: const Text('No'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: const Text('Yes'),
//               ),
//             ],
//           ),
//         )) ??
//         false;
//   }

//   widgetSuffix() {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: bagroundColor,
//       appBar: AppBar(
//         actions: [
//           Visibility(
//             visible: oldBill,
//             child: IconButton(
//                 color: red,
//                 iconSize: 40,
//                 onPressed: () {
//                   if (buttonEvent) {
//                     return;
//                   } else {
//                     if (cartItem.isNotEmpty) {
//                       setState(() {
//                         _isLoading = true;
//                         buttonEvent = true;
//                       });
//                       delete(context);
//                     } else {
//                       showInSnackBar('No items found on bill');
//                       setState(() {
//                         buttonEvent = false;
//                       });
//                     }
//                   }
//                 },
//                 icon: Image.asset('assets/icons/ic_delete.png',scale: 3.3,)),
//           ),
//           oldBill
//               ? IconButton(
//                   color: green, 
//                   iconSize: 40,
//                   onPressed: () async {
//                     if (buttonEvent) {
//                       return;
//                     } else {
//                       setState(() {
//                         _isLoading = true;
//                         buttonEvent = true;
//                       });
//                       var inf = '[' +
//                           json.encode({
//                             'fromId': locationFromId,
//                             'toId': locationToId
//                           }) +
//                           ']';
//                       var jsonItem = CartItemST.encodeCartToJson(cartItem);
//                       var items = json.encode(jsonItem);
//                       var stType = 'Update';
//                       var data = '[' +
//                           json.encode({
//                             'entryNo': dataDynamic[0]['EntryNo'],
//                             'date': DateUtil.dateYMD(formattedDate),
//                             'total': totalCartTotal,
//                             'narration': _narration,
//                             'Salesman': salesManId,
//                             'location': '0',
//                             'statementtype': stType,
//                             'fyId': currentFinancialYear!.id
//                           }) +
//                           ']';

//                       final body = {
//                         'information': inf,
//                         'data': data,
//                         'particular': items
//                       };
//                       bool _state = await dio.stockTransfer(body);
//                       setState(() {
//                         _isLoading = false;
//                       });
//                       if (_state) {
//                         cartItem.clear();
//                         showMore(context, 'Edited');
//                       } else {
//                         showInSnackBar('Error enter data correctly');
//                         setState(() {
//                           buttonEvent = false;
//                         });
//                       }
//                     }
//                   },
//                   icon: Image.asset('assets/icons/ic_edit.png',scale: 3.3,))
//               : IconButton(
//                   color: blue,
//                   iconSize: 40,
//                   onPressed: () async {
//                     if (buttonEvent) {
//                       return;
//                     } else {
//                       setState(() {
//                         _isLoading = true;
//                         buttonEvent = true;
//                       });
//                       var inf = '[' +
//                           json.encode({                  
//                             'fromId': locationFromId,
//                             'toId': locationToId
//                           }) +
//                           ']';
//                       var jsonItem = CartItemST.encodeCartToJson(cartItem);
//                       var items = json.encode(jsonItem);
//                       var stType = 'Insert';
//                       var data = '[' +
//                           json.encode({
//                             'date': DateUtil.dateYMD(formattedDate),
//                             'total': totalCartTotal,
//                             'narration': _narration,
//                             'Salesman': salesManId,
//                             'location': '0',
//                             'statementtype': stType,
//                             'fyId': currentFinancialYear!.id
//                           }) +
//                           ']';

//                       final body = {
//                         'information': inf,
//                         'data': data,
//                         'particular': items
//                       };
//                       debugPrint('body: $body');
//                       bool _state = await dio.stockTransfer(body);
//                       setState(() {
//                         _isLoading = false;
//                       });
//                       if (_state) {
//                         cartItem.clear();
//                         showMore(context, 'Saved');
//                       } else {
//                         showInSnackBar('Error enter data correctly');
//                         setState(() {
//                           buttonEvent = false;
//                         });
//                       }
//                     }
//                   },
//                   icon: Icon(Icons.save,color: white,)),
//         ],
//         title: const Text('Stock Transfer'),
//         titleTextStyle: TextStyle(
//           fontFamily: 'poppins',
//           color: white
//         ),
//       ),
//       body: ProgressHUD(
//           inAsyncCall: _isLoading, opacity: 0.0, child: selectWidget()),
//     );
//   }

//   widgetPrefix() {
//     return Scaffold(
//       backgroundColor: bagroundColor,
//         key: _scaffoldKey,
//         appBar: AppBar(
//           actions: [
//             TextButton(
//                 style: TextButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5)
//                   ),
//                   foregroundColor: Colors.white,
//                   backgroundColor: Colors.blue[700],
//                 ),
//                 onPressed: () async {
//                   setState(() {
//                     widgetID = false;
//                   });
//                 },
//                 child: const Text(
//                   " New ",
//                   style: TextStyle(
//                       color: Colors.white, fontWeight: FontWeight.bold),
//                 )),
//           ],
//           title: const Text('Stock Transfer'),
//           titleTextStyle: const TextStyle(fontFamily: 'poppins',color: white),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 8
//           ),
//           child: Container(
//             child: previousBill(),
//           ),
//         ));
//   }

//   final ScrollController _scrollController = ScrollController();
//   bool isLoadingData = false;
//   List dataDisplay = [];

//   void _getMoreData() async {
//     if (!lastRecord) {
//       if (dataDisplay.isEmpty ||
//           // ignore: curly_braces_in_flow_control_structures
//           dataDisplay.length < totalRecords) if (!isLoadingData) {
//         setState(() {
//           isLoadingData = true;
//         });

//         List tempList = [];
//         var statement = 'StockTransferList';

//         dio
//             .getPaginationList(statement, page, '1', '0',
//                 DateUtil.dateYMD(formattedDate), salesManId.toString())
//             .then((value) {
//           if (value.isEmpty) {
//             return;
//           }
//           final response = value;
//           pageTotal = response[1][0]['Filtered'];
//           totalRecords = response[1][0]['Total'];
//           page++;
//           for (int i = 0; i < response[0].length; i++) {
//             tempList.add(response[0][i]);
//           }

//           setState(() {
//             isLoadingData = false;
//             dataDisplay.addAll(tempList);
//             lastRecord = tempList.isNotEmpty ? false : true;
//           });
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   int nextWidget = 0;
//   Widget selectWidget() {
//     return nextWidget == 0
//         ? purchaseHeaderWidget()
//         : nextWidget == 1
//             ? selectProductWidget()
//             : nextWidget == 2
//                 ? itemDetailWidget()
//                 : nextWidget == 3
//                     ? cartProduct()
//                     : Container(
//                         padding: const EdgeInsets.all(2.0),
//                         child: const Text('No Widget'),
//                       );
//   }

//   previousBill() {
//     _getMoreData();
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//           _scrollController.position.maxScrollExtent) {
//         _getMoreData();
//       }
//     });

//     return dataDisplay.isNotEmpty
//         ? ListView.builder(
//             itemCount: dataDisplay.length + 1,
//             itemBuilder: (BuildContext context, int index) {
//               if (index == dataDisplay.length) {
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Center(
//                     child: Opacity(
//                       opacity: isLoadingData ? 1.0 : 00,
//                       child: const CircularProgressIndicator(),
//                     ),
//                   ),
//                 );
//               } else {
//                 return Container(
//                    margin: const EdgeInsets.symmetric(vertical: 2),
//                     // height: 80, boxshadow: true, offset Offset(0.6.6),blurRadius:6,color: Color(0xff000000).withOpacity(0.06),
//                      constraints: const BoxConstraints(
//                           maxHeight: 110,
//                           minHeight: 80
//                         ),
//                     decoration: BoxDecoration(
//                       color: white,
//                       borderRadius: BorderRadius.circular(3),
//                       boxShadow: [
//                         BoxShadow(
//                           offset: const Offset(0, 5),
//                           blurRadius: 6,
//                           color: const Color(0xff000000).withOpacity(0.06),
//                         ),
//                       ],
//                     ),
//                     padding: const EdgeInsets.all(10),
//                   child: 
//                   IntrinsicHeight(
//                     child: Row(
//                         children: [
//                           Expanded(
//                             flex: 3,
//                             child: InkWell(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     dataDisplay[index]['StockFrom'] +
//                           ' >>> ' +
//                           dataDisplay[index]['StockTo'],
//                                     // maxLines: 1,
//                                     style: const TextStyle(
//                                       // fontSize: 16,
//                                       color: ColorPalette.timberGreen,
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     height: 5,
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text(
//                                         'Date :${dataDisplay[index]['Date']}',
//                                         maxLines: 1,
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: ColorPalette.timberGreen
//                                               .withOpacity(0.44),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                           left: 5,
//                                           top: 2,
//                                           right: 5,
//                                         ),
//                                         child: Icon(
//                                           Icons.circle,
//                                           size: 5,
//                                           color: ColorPalette.timberGreen
//                                               .withOpacity(0.44),
//                                         ),
//                                       ),
//                                       Text(
//                                         'EntryNo :${dataDisplay[index]['Id'].toString()}',
//                                         maxLines: 1,
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: ColorPalette.timberGreen
//                                               .withOpacity(0.44),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               onTap: () {
//                                 showEditDialog(context, dataDisplay[index]);
//                               },
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: InkWell(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   const Text(
//                                     'Total',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: ColorPalette.nileBlue,
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Align(
//                                       alignment: Alignment.centerRight,
//                                       child: Text(
//                                           '${dataDisplay[index]['Total'].toStringAsFixed(decimal)}'),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               onTap: () {
//                                 // showDetails(context, dataDisplay[index]);
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                   )
//                   // ListTile(
//                   //   title: Text(dataDisplay[index]['StockFrom'] +
//                   //       ' >>> ' +
//                   //       dataDisplay[index]['StockTo']),
//                   //   subtitle: Text('Date: ' +
//                   //       dataDisplay[index]['Date'] +
//                   //       ' / EntryNo : ' +
//                   //       dataDisplay[index]['Id'].toString()),
//                   //   trailing: Text(
//                   //       'Total : ' + dataDisplay[index]['Total'].toString()),
//                   //   onTap: () {
//                   //     showEditDialog(context, dataDisplay[index]);
//                   //   },
//                   // ),
//                 );
//               }
//             },
//             controller: _scrollController,
//           )
//         : Center(
//             child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text("No items in Stock Transfer",
//               style: TextStyle(fontFamily: 'poppins'),),
//               TextButton.icon(
//                   style: ButtonStyle(
//                     shape: MaterialStatePropertyAll(RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(5)
//                     )),
//                     backgroundColor:
//                         MaterialStateProperty.all<Color>(kPrimaryColor),
//                     foregroundColor:
//                         MaterialStateProperty.all<Color>(Colors.white),
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       widgetID = false;
//                     });
//                   },
//                   icon: const Icon(Icons.shopping_bag),
//                   label: const Text('Take New Stock Transfer',
//                   style: TextStyle(fontFamily: 'poppins'),
//                   ))
//             ],
//           ));
//   }

//   bool isData = false;

//   purchaseHeaderWidget() {
//     return 
//        Center(
//           child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     const Text(
//                       'Date  ',
//                       style: TextStyle(fontWeight: FontWeight.w500,
//                       fontFamily: 'poppins',
//                       fontSize: 14
//                       ),
//                     ),
//                     InkWell(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 5,
//                           vertical: 3
//                         ),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: grey,width: .7),
//                           borderRadius: BorderRadius.circular(3)
//                           ),
//                         child: Row(
//                           children: [
//                             Text(
//                               formattedDate!,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 15
//                               ),
//                             ),
//                             const SizedBox(
//                               width: 8,
//                             ),
//                             const Icon(Icons.calendar_month,
//                             size: 20,
//                             color: grey,
//                             )
//                           ],
//                         ),
//                       ),
//                       onTap: () => _selectDate(),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   child: Row(
//                     // mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       const Text(
//                         'From ',
//                         style: TextStyle(
//                           fontFamily: 'poppins',
//                           fontWeight: FontWeight.w500),
//                       ),
//                       Expanded(
//                         child: Container(
//                           // height: 35,
//                           // width: 130,
//                           padding: const EdgeInsets.symmetric(horizontal: 2),
//                            decoration: BoxDecoration(
//                                                 border: Border.all(color: grey,),
//                                                 borderRadius: BorderRadius.circular(3)
//                                                 ),
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<int>(
//                               isExpanded: true,
//                               hint: const Text('Select Branch',style: TextStyle(
//                                 fontFamily: 'poppins',
//                                 fontSize: 14,
//                                 // fontWeight: FontWeight.w500
//                               ),),
//                               value: locationFromId,
//                               items: locationData
//                                   .map<DropdownMenuItem<int>>((value) {
//                                 return DropdownMenuItem<int>(
//                                   value: value.key,
//                                   child: Text(value.value,style: const TextStyle(
//                                      fontFamily: 'poppins',
//                                      fontSize: 14,
//                                 // fontWeight: FontWeight.w500
//                                   ),),
//                                 );
//                               }).toList(),
//                               onChanged: (value) {
//                                 setState(() {
//                                   locationFromId = value!;
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 8,
//                       ),
//                       // const Icon(Icons.forward),
//                       // const Spacer(),
//                       const Text(
//                         'To ',
//                         style: TextStyle(
//                           fontFamily: 'poppins',
//                           fontWeight: FontWeight.w500),
//                       ),
//                       Expanded(
//                         child: Container(
//                           //  height: 35,
//                           // width: 130,
//                           padding: const EdgeInsets.symmetric(horizontal: 2),
//                            decoration: BoxDecoration(
//                                                 border: Border.all(color: grey,),
//                                                 borderRadius: BorderRadius.circular(3)
//                                                 ),
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<int>(
//                               hint: const Text('Select Branch',
//                               style: TextStyle(
//                                                     fontFamily: 'poppins',
//                                                     fontSize: 14,
//                                                     // fontWeight: FontWeight.w500
//                                                     ),
//                               ),
//                               value: locationToId,
//                               items: locationData
//                                   .map<DropdownMenuItem<int>>((value) {
//                                 return DropdownMenuItem<int>(
//                                   value: value.key,
//                                   child: Text(value.value,
//                                   style: TextStyle(
//                                                     fontFamily: 'poppins',
//                                                     fontSize: 14,
//                                                     // fontWeight: FontWeight.w500
//                                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (value) {
//                                 setState(() {
//                                   locationToId = value!;
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//           InkWell(
//               child:  Container(
//                 width: 100,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(5),color: kPrimaryColor,),
//                 child: Center(
//                   child: Text(
//                     'Add Item',
//                     style: TextStyle(
//                         color: white,
//                         fontSize: 16,
//                         fontFamily: 'poppins',
//                         fontWeight: FontWeight.w500),
//                   ),
//                 ),
//               ),
//               onTap: () {
//                 setState(() {
//                   nextWidget = 1;
//                 });
//               }),
//         ],
//       ));
   
//   }

//   bool isItemData = false;
//   selectProductWidget() {
//     setState(() {
//       if (items.isNotEmpty) isItemData = true;
//     });
//     return FutureBuilder<List<StockItem>>(
//       future: dio.fetchStockProductByLocation(
//           locationFromId.toString(), DateUtil.dateDMY2YMD(formattedDate)),
//       builder: (ctx, snapshot) {
//         if (snapshot.hasData) {
//           if (snapshot.data!.isNotEmpty) {
//             var data = snapshot.data;
//             if (!isItemData) {
//               itemDisplay = data!;
//               items = data;
//             }
//             return 
//             Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Column(
//             children: [
//               Row(    
//                 children: [
//                   Flexible(
//                     child: TextField(
//                       decoration: const InputDecoration(
//                         contentPadding: EdgeInsets.symmetric(
//                             horizontal: 5, vertical: 8),
//                         border: OutlineInputBorder(),
//                         label: Text('Search...'),
//                       ),
//                       onChanged: (text) {
//                         text = text.toLowerCase();
//                         setState(() {
//                           itemDisplay = items.where((item) {
//                             var itemName = item.name.toLowerCase();
//                             return itemName.contains(text);
//                           }).toList();
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10), 
//               Expanded(
//                 child: ListView.separated(
//                   separatorBuilder: (context, index) => const SizedBox(
//                     height: 6,
//                   ),
//                   itemBuilder: (context, index) {
//                     return InkWell(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(3),
//                         ),
//                         child: ListTile(
//                           title: Text(itemDisplay[index].name),
//                           trailing: Text('Qty : ${itemDisplay[index].quantity}'),
//                         ),
//                       ),
//                       onTap: () {
//                         setState(() {
//                           productModel = itemDisplay[index];
//                           nextWidget = 2;
//                           isItemData = false;
//                         });
//                       },
//                     );
//                   },
//                   itemCount: itemDisplay.length,
//                 ),
//               ),
//             ],
//           ),
//         );
//             //  Padding(
//             //    padding: const EdgeInsets.symmetric(
//             //     horizontal: 16,
//             //     vertical: 8
//             //    ),
//             //    child: ListView.separated(
//             //     separatorBuilder: (context, index) => const SizedBox(
//             //       height: 6,
//             //     ),
//             //     // shrinkWrap: true,
//             //     itemBuilder: (context, index) {
//             //       return index == 0
//             //           ? Row(
//             //             children: [
//             //               Flexible(
//             //                 child: TextField(
//             //                   decoration: const InputDecoration(
//             //                     contentPadding: EdgeInsets.symmetric(
//             //                       horizontal: 5,
//             //                       vertical: 8
//             //                     ),
//             //                     border: OutlineInputBorder(),
//             //                     label: Text('Search...'),
//             //                   ),
//             //                   onChanged: (text) {
//             //                     text = text.toLowerCase();
//             //                     setState(() {
//             //                       itemDisplay = items.where((item) {
//             //                         var itemName = item.name.toLowerCase();
//             //                         return itemName.contains(text);
//             //                       }).toList();
//             //                     });
//             //                   },
//             //                 ),
//             //               ),
//             //             ],
//             //           )
//             //           : InkWell(
//             //               child: Container(
//             //                 decoration: BoxDecoration(
//             //                 color: white,
//             //                 border: Border.all(color: grey),
//             //                 borderRadius: BorderRadius.circular(3)
//             //               ),
//             //                 child: ListTile(
//             //                   title: Text(itemDisplay[index - 1].name),
//             //                   trailing:
//             //                       Text('Qty :${itemDisplay[index - 1].quantity}'),
//             //                 ),
//             //               ),
//             //               onTap: () {
//             //                 setState(() {
//             //                   productModel = itemDisplay[index - 1];
//             //                   nextWidget = 2;
//             //                   isItemData = false;
//             //                 });
//             //               },
//             //             );
//             //     },
//             //     itemCount: itemDisplay.length + 1,
//             //                ),
//             //  );
//           } else {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [SizedBox(height: 20), Text('No Data Found..')],
//               ),
//             );
//           }
//         } else if (snapshot.hasError) {
//           return AlertDialog(
//             title: const Text(
//               'An Error Occurred!',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.redAccent,
//               ),
//             ),
//             content: Text(
//               "${snapshot.error}",
//               style: const TextStyle(
//                 color: Colors.blueAccent,
//               ),
//             ),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text(
//                   'Go Back',
//                   style: TextStyle(
//                     color: Colors.redAccent,
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               )
//             ],
//           );
//         }
//         return const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text('This may take some time..')
//             ],
//           ),
//         );
//       },
//     );
//   }

//   itemDetailWidget() {
//     keyItemsVariantStock = productModel!.hasVariant!;
//     return productModel!.hasVariant!
//         ? showVariantDialog(productModel!.id!, productModel!.name!,
//             productModel!.quantity.toString())
//         : selectStockLedger();
//   }

//   selectStockLedger() {
//     return FutureBuilder(
//         future: dio.fetchStockTransferItemVariant(
//             productModel!.id!, locationFromId.toString(),taxGroupUpdate),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             if (snapshot.data!.length > 0) {
//               return itemDetails(snapshot.data![0]);
//             } else {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 20),
//                     const Text('Stock Ledger Data Missing...'),
//                     TextButton(
//                         onPressed: () {
//                           setState(() {
//                             nextWidget = 1;
//                           });
//                         },
//                         child: const Text('Select Product Again'))
//                   ],
//                 ),
//               );
//             }
//           } else if (snapshot.hasError) {
//             return AlertDialog(
//               title: const Text(
//                 'An Error Occurred!',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.redAccent,
//                 ),
//               ),
//               content: Text(
//                 "${snapshot.error}",
//                 style: const TextStyle(
//                   color: Colors.blueAccent,
//                 ),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   child: const Text(
//                     'Go Back',
//                     style: TextStyle(
//                       color: Colors.redAccent,
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 )
//               ],
//             );
//           }
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 CircularProgressIndicator(),
//                 SizedBox(height: 20),
//                 Text('This may take some time..')
//               ],
//             ),
//           );
//         });
//   }

//   bool isVariantSelected = false;
//   int positionID = 0;
//   showVariantDialog(int id, String name, String quantity) {
//     return FutureBuilder<List<StockProduct>>(
//       future: dio.fetchStockVariant(id,taxGroupUpdate,0),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           if (snapshot.data!.isNotEmpty) {
//             return isVariantSelected
//                 ? itemDetails(snapshot.data![positionID])
//                 : keyItemsVariantStock
//                     ? SizedBox(
//                         height: deviceSize!.height - 20,
//                         width: 400.0,
//                         child: ListView(children: [
//                           Center(child: Text(name + ' / ' + quantity)),
//                           ListView.builder(
//                             shrinkWrap: true,
//                             itemCount: snapshot.data!.length,
//                             itemBuilder: (BuildContext context, int index) {
//                               return Card(
//                                 elevation: 5,
//                                 child: ListTile(
//                                     title: Text(
//                                         'Id: ${snapshot.data![index].productId} / Quantity : ${snapshot.data![index].quantity} '),
//                                     subtitle: Text(ComSettings.appSettings(
//                                             'bool',
//                                             'key-item-sale-retail',
//                                             false)
//                                         ? 'Mrp : ${snapshot.data![index].sellingPrice} / Retail : ${snapshot.data![index].retailPrice}'
//                                         : 'Rate : ${snapshot.data![index].sellingPrice}'),
//                                     onTap: () {
//                                       setState(() {
//                                         isVariantSelected = true;
//                                         positionID = index;
//                                       });
//                                     }),
//                               );
//                             },
//                           ),
//                         ]),
//                       )
//                     : itemDetails(snapshot.data![0]);
//           } else {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   SizedBox(height: 20),
//                   Text('No Data Found..')
//                 ],
//               ),
//             );
//           }
//         } else if (snapshot.hasError) {
//           return AlertDialog(
//             title: const Text(
//               'An Error Occurred!',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.redAccent,
//               ),
//             ),
//             content: Text(
//               "${snapshot.error}",
//               style: const TextStyle(
//                 color: Colors.blueAccent,
//               ),
//             ),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text(
//                   'Go Back',
//                   style: TextStyle(
//                     color: Colors.redAccent,
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               )
//             ],
//           );
//         }
//         return const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text('This may take some time..')
//             ],
//           ),
//         );
//       },
//     );
//   }

//   TextEditingController controllerQuantity = TextEditingController();
//   TextEditingController controllerRate = TextEditingController();
//   TextEditingController controllerDiscountPer = TextEditingController();
//   TextEditingController controllerDiscount = TextEditingController();
//   TextEditingController controllerMrp = TextEditingController();
//   TextEditingController controllerRetail = TextEditingController();
//   TextEditingController controllerWholeSale = TextEditingController();
//   TextEditingController controllerBranch = TextEditingController();

//   double quantity = 0,
//       rate = 0,
//       subTotal = 0,
//       mrp = 0,
//       retail = 0,
//       wholeSale = 0,
//       spRetail = 0,
//       branch = 0,
//       rRate = 0,
//       rateOff = 0,
//       unitValue = 1;
//   String expDate = '1900-01-01', serialNo = '',cBarcode = '';
//   int uniqueCode = 0, stUniqueCode = 0, fUnitId = 0, barcode = 0;
//   bool editableMrp = false,
//       editableRetail = false,
//       editableWSale = false,
//       editableBranch = false,
//       editableRate = false,
//       editableQuantity = false,
//       editableDiscount = false,
//       editableDiscountP = false,
//       autoVariantSelect = false;

//   itemDetails(StockProduct product) {
//     if (editItem) {
//       quantity = cartItem[position!].quantity;
//       uniqueCode = cartItem[position!].uniqueCode;
//       cBarcode = cartItem[position!]!.cBarcode ?? '';
//       if (quantity > 0 && !editableQuantity) {
//         controllerQuantity.text = quantity.toString();
//       }
//       rate = cartItem.elementAt(position!).rate;
//       if (rate > 0 && !editableRate) {
//         controllerRate.text = rate.toString();
//       }
//       if (cartItem.elementAt(position!).rRate > 0) {
//         rRate = cartItem.elementAt(position!).rRate;
//       }
//       mrp = cartItem.elementAt(position!).mrp;
//       if (mrp > 0 && !editableMrp) {
//         controllerMrp.text = mrp.toString();
//       }
//       retail = cartItem.elementAt(position!).retail;
//       if (retail > 0 && !editableRetail) {
//         controllerRetail.text = retail.toString();
//       }
//       wholeSale = cartItem.elementAt(position!).wholesale;
//       if (wholeSale > 0 && !editableWSale) {
//         controllerWholeSale.text = wholeSale.toString();
//       }
//       spRetail = cartItem.elementAt(position!).spRetail;
//       branch = cartItem.elementAt(position!).branch;
//       if (branch > 0 && !editableBranch) {
//         controllerBranch.text = branch.toString();
//       }

//       subTotal = cartItem.elementAt(position!).gross;
//     } else {
//       uniqueCode = product.productId!;
//       rate = double.tryParse(product.buyingPrice.toString())!;
//       if (rate > 0 && !editableRate) {
//         controllerRate.text = rate.toString();
//       }
//       if (double.tryParse(product.buyingPriceReal.toString())! > 0) {
//         rRate = double.tryParse(product.buyingPriceReal.toString())!;
//       }
//       mrp = double.tryParse(product.sellingPrice.toString())!;
//       if (mrp > 0 && !editableMrp) {
//         controllerMrp.text = mrp.toString();
//       }
//       retail = double.tryParse(product.retailPrice.toString())!;
//       if (retail > 0 && !editableRetail) {
//         controllerRetail.text = retail.toString();
//       }
//       wholeSale = double.tryParse(product.wholeSalePrice.toString())!;
//       if (wholeSale > 0 && !editableWSale) {
//         controllerWholeSale.text = wholeSale.toString();
//       }
//       spRetail = double.tryParse(product.spRetailPrice.toString())!;
//       branch = double.tryParse(product.branch.toString())!;
//       if (branch > 0 && !editableBranch) {
//         controllerBranch.text = branch.toString();
//       }
//       cBarcode = product.cBarcode!;
//     }

//     calculate() {
//       quantity = controllerQuantity.text.isNotEmpty
//           ? double.tryParse(controllerQuantity.text)!
//           : 0;
//       rate = controllerRate.text.isNotEmpty
//           ? double.tryParse(controllerRate.text)!
//           : 0;
//       rRate = taxMethod == 'MINUS'
//           ? CommonService.getRound(decimal, (100 * rate) / (100))
//           : rate;
//       subTotal = CommonService.getRound(decimal, (rate * quantity));
//       // unitValue = _conversion > 0 ? _conversion : 1;
//     }

//     calculateRate() {
//       mrp = controllerMrp.text.isNotEmpty
//           ? double.tryParse(controllerMrp.text)!
//           : 0;
//       retail = controllerRetail.text.isNotEmpty
//           ? double.tryParse(controllerRetail.text)!
//           : 0;
//       wholeSale = controllerWholeSale.text.isNotEmpty
//           ? double.tryParse(controllerWholeSale.text)!
//           : 0;
//       branch = controllerBranch.text.isNotEmpty
//           ? double.tryParse(controllerBranch.text)!
//           : 0;
//       rate = controllerRate.text.isNotEmpty
//           ? double.tryParse(controllerRate.text)!
//           : 0;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: 8
//       ),
//       child: Column(
//         children: [
//           Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                   'Item : ${editItem ? cartItem.elementAt(position!).itemName : product.name}',
//                   style: const TextStyle(
//                     fontFamily: 'poppins'
//                   ),
//                   )),
//           Row(
//             children: [
//               Expanded(
//                   child: MaterialButton(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5)
//                   ),
//                 onPressed: () {
//                   setState(() {
//                     editItem = false;
//                     nextWidget = 1;
//                   });
//                 },
//                 color: kPrimaryColor,
//                 child: const Text("Back",
//                 style: TextStyle(
//                   fontFamily: 'poppins',
//                   color: white
//                 ),
//                 ),
//               )),
//               const SizedBox(
//                 width: 4,
//               ),
//               Expanded(
//                   child: MaterialButton(
//                     shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5)
//                   ),
//                 onPressed: () {
//                   setState(() {
//                     editItem = false;
//                     nextWidget = 3;
//                     clearValue();
//                   });
//                 },
//                 color: kPrimaryColor,
//                 child: const Text("Cancel",
//                  style: TextStyle(
//                   fontFamily: 'poppins',
//                   color: white
//                 ),
//                 ),
//               )),
//               const SizedBox(
//                 width: 4,
//               ),
//               Expanded(
//                   child: MaterialButton(
//                     shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5)
//                   ),
//                 onPressed: () {
//                   bool cartQ = false;
//                   setState(() {
//                     rate = (controllerRate.text.isNotEmpty
//                         ? double.tryParse(controllerRate.text)
//                         : rate)!;
//                     mrp = (controllerMrp.text.isNotEmpty
//                         ? double.tryParse(controllerMrp.text)
//                         : mrp)!;
//                     retail = (controllerRetail.text.isNotEmpty
//                         ? double.tryParse(controllerRetail.text)
//                         : retail)!;
//                     wholeSale = (controllerWholeSale.text.isNotEmpty
//                         ? double.tryParse(controllerWholeSale.text)
//                         : wholeSale)!;
//                     // spRetail = controllerSPRetail.text.length>0? double.tryParse(controllerSPRetail.text):spRetail;
//                     branch = (controllerBranch.text.isNotEmpty
//                         ? double.tryParse(controllerBranch.text)
//                         : branch)!;
//                     quantity = (controllerQuantity.text.isNotEmpty
//                         ? double.tryParse(controllerQuantity.text)
//                         : quantity)!;
      
//                     if (product.quantity! >= quantity) {
//                       double cartS = 0, cartQt = 0;
//                       for (var element in cartItem) {
//                         if (element.uniqueCode == product.productId) {
//                           cartQt += element.quantity;
//                           cartS = element.stock;
//                         }
//                       }
//                       if (cartS > 0) {
//                         if (cartS < cartQt + quantity) {
//                           cartQ = true;
//                         }
//                       }
      
//                       if (cartQ) {
//                         showInSnackBar('Available Qty is ${cartS - cartQt}');
//                         isVariantSelected = false;
//                       } else {
//                         if (editItem) {
//                           cartItem[position!].barcode = barcode;
//                           cartItem[position!].branch = branch;
//                           cartItem[position!].gross = subTotal;
//                           cartItem[position!].mrp = mrp;
//                           cartItem[position!].quantity = quantity;
//                           cartItem[position!].rRate = rRate;
//                           cartItem[position!].rate = rate;
//                           cartItem[position!].retail = retail;
//                           cartItem[position!].serialNo = serialNo;
//                           cartItem[position!].spRetail = spRetail;
//                           cartItem[position!].uniqueCode = uniqueCode;
//                           cartItem[position!].unitValue = unitValue;
//                           cartItem[position!].wholesale = wholeSale;
//                           cartItem[position!].stUniqueCode = stUniqueCode;
//                           cartItem[position!].cBarcode = cBarcode;
//                         } else {
//                           cartItem.add(CartItemST(
//                               barcode: barcode,
//                               branch: branch,
//                               gross: subTotal,
//                               id: cartItem.length + 1,
//                               itemId: product.itemId!,
//                               itemName: product.name!,
//                               mrp: mrp,
//                               quantity: quantity,
//                               rRate: rRate,
//                               rate: rate,
//                               retail: retail,
//                               serialNo: serialNo,
//                               spRetail: spRetail,
//                               uniqueCode: uniqueCode,
//                               unitId: 0,
//                               unitName: '',
//                               unitValue: unitValue,
//                               wholesale: wholeSale,
//                               stUniqueCode: stUniqueCode,
//                               stock: product.quantity!,
//                               cBarcode: cBarcode));
//                         }
//                         if (cartItem.isNotEmpty) {
//                           nextWidget = 3;
//                           editItem = false;
//                           isVariantSelected = false;
//                           clearValue();
//                         }
//                       }
//                     } else {
//                       showInSnackBar('Available Qty is ${product.quantity}');
//                       isVariantSelected = false;
//                     }
//                   });
//                 },
//                 color: kPrimaryColor,
//                 child: Text(editItem ? "Edit" : "Add",
//                  style: const TextStyle(
//                   fontFamily: 'poppins',
//                   color: white
//                 ),
//                 ),
//               )),
//             ],
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           TextField(
//             controller: controllerQuantity,
//             textAlign: TextAlign.right,
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 5,
//                 vertical: 8
//               ),
//               border: const OutlineInputBorder(),
//               label: Text('Available Quantity is ${product.quantity}'),
//               labelStyle:  const TextStyle(
//                   fontFamily: 'poppins',
//                 ),
//             ),
//             keyboardType:
//                 const TextInputType.numberWithOptions(decimal: true),
//             inputFormatters: [
//               FilteringTextInputFormatter(RegExp(r'[0-9]'),
//                   allow: true, replacementString: '.')
//             ],
//             onChanged: (value) {
//               setState(() {
//                 editableQuantity = true;
//                 quantity = double.tryParse(value)?? 0;
//                 calculate();
//               });
//             },
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//           TextField(
//             controller: controllerRate,
//             textAlign: TextAlign.right,
//             decoration: const InputDecoration(
//                contentPadding: EdgeInsets.symmetric(
//                 horizontal: 5,
//                 vertical: 8
//               ),
//                labelStyle:  TextStyle(
//                   fontFamily: 'poppins',
//                 ),
//                 border: OutlineInputBorder(), label: Text('P Rate')),
//             keyboardType:
//                 const TextInputType.numberWithOptions(decimal: true),
//             inputFormatters: [
//               FilteringTextInputFormatter(RegExp(r'[0-9]'),
//                   allow: true, replacementString: '.')
//             ],
//             onChanged: (value) {
//               setState(() {
//                 editableRate = true;
//                 rate = double.tryParse(value)!;
//                 calculate();
//               });
//             },
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               const Text('Subtotal : ',
//               style: TextStyle(
//                 fontFamily: 'poppins'
//               ),
//               ),
//               Text(subTotal.toStringAsFixed(decimal)),
//             ],
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//           SizedBox(
//             width: MediaQuery.of(context).size.width,
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: SizedBox(
//                         width: MediaQuery.of(context).size.width,
//                         child: Row(
//                           children: [
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width /5.5,
//                               child: const Text('MRP',
//                                textScaler: TextScaler.linear(.9),
//                                style: TextStyle(
//                                 fontFamily: 'poppins'
//                                ),
//                               )),
//                             Expanded(
//                               flex: 1,
//                               child: 
//                             TextField(
//                       controller: controllerMrp,
//                       textAlign: TextAlign.right,
//                       decoration:  const InputDecoration(
//                         constraints: BoxConstraints(
//                           maxHeight: 35,
//                         ),
//                          contentPadding: EdgeInsets.symmetric(
//                     horizontal: 5,
//                     vertical: 5
//                   ),
//                           border: OutlineInputBorder(), 
//                          ),
//                       keyboardType:
//                           const TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: [
//                         FilteringTextInputFormatter(RegExp(r'[0-9]'),
//                             allow: true, replacementString: '.')
//                       ],
//                       onChanged: (value) {
//                         setState(() {
//                           editableMrp = true;
//                           mrp = double.tryParse(value)!;
//                           calculateRate();
//                         });
//                       },
//                     ),
//                             )
//                           ],
//                         ),
//                       ) ),
//                       const SizedBox(
//                         width: 4,
//                       ),
//                     Expanded(
//                       child: SizedBox(
//                         width: MediaQuery.of(context).size.width,
//                         child: Row(
//                           children: [
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width /5.5,
//                               child: const Text('Retail',
//                                textScaler: TextScaler.linear(.9),
//                                style: TextStyle(
//                                 fontFamily: 'poppins'
//                                ),
//                               )),
//                             Expanded(child: 
//                              TextField(
//                   controller: controllerRetail,
//                   textAlign: TextAlign.right,
//                   decoration: const InputDecoration(
//                     constraints: BoxConstraints(
//                           maxHeight: 35,
//                         ),
//                          contentPadding: EdgeInsets.symmetric(
//                     horizontal: 5,
//                     vertical: 5
//                   ),
//                       border: OutlineInputBorder(),),
//                   keyboardType:
//                       const TextInputType.numberWithOptions(decimal: true),
//                   inputFormatters: [
//                     FilteringTextInputFormatter(RegExp(r'[0-9]'),
//                         allow: true, replacementString: '.')
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       editableRetail = true;
//                       retail = double.tryParse(value)!;
//                       calculateRate();
//                     });
//                   },
//                 ),
//                             )
//                           ],
//                         ),
//                       ) ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 8,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: SizedBox(
//                         width: MediaQuery.of(context).size.width,
//                         child: Row(
//                           children: [
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width /5.5,
//                               child: const Text('WholeSale',
//                                textScaler: TextScaler.linear(.9),
//                                style: TextStyle(
//                                 fontFamily: 'poppins'
//                                ),
//                               )),
//                             Expanded(child: 
//                            TextField(
//                   controller: controllerWholeSale,
//                   textAlign: TextAlign.right,
//                   decoration: const InputDecoration(
//                     constraints: BoxConstraints(
//                           maxHeight: 35,
//                         ),
//                          contentPadding: EdgeInsets.symmetric(
//                     horizontal: 5,
//                     vertical: 5
//                   ),
//                       border: OutlineInputBorder(),),
//                   keyboardType:
//                       const TextInputType.numberWithOptions(decimal: true),
//                   inputFormatters: [
//                     FilteringTextInputFormatter(RegExp(r'[0-9]'),
//                         allow: true, replacementString: '.')
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       editableWSale = true;
//                       wholeSale = double.tryParse(value)!;
//                       calculateRate();
//                     });
//                   },
//                 ),
//                             )
//                           ],
//                         ),
//                       ) ),
//                       const SizedBox(
//                         width: 4,
//                       ),
//                     Expanded(
//                       child: SizedBox(
//                         width: MediaQuery.of(context).size.width,
//                         child: Row(
//                           children: [
//                             SizedBox(
//                               width: MediaQuery.of(context).size.width /5.5,
//                               child: const Text('Branch',
//                                textScaler: TextScaler.linear(.9),
//                                style: TextStyle(
//                                 fontFamily: 'poppins'
//                                ),
//                               )),
//                             Expanded(child: 
//                              TextField(
//                   controller: controllerBranch,
//                   textAlign: TextAlign.right,
//                   decoration: const InputDecoration(
//                     constraints: BoxConstraints(
//                           maxHeight: 35,
//                         ),
//                          contentPadding: EdgeInsets.symmetric(
//                     horizontal: 5,
//                     vertical: 5
//                   ),
//                       border: OutlineInputBorder(),),
//                   keyboardType:
//                       const TextInputType.numberWithOptions(decimal: true),
//                   inputFormatters: [
//                     FilteringTextInputFormatter(RegExp(r'[0-9]'),
//                         allow: true, replacementString: '.')
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       editableBranch = true;
//                       branch = double.tryParse(value)!;
//                       calculateRate();
//                     });
//                   },
//                 ),
//                             )
//                           ],
//                         ),
//                       ) ),
//                   ],
//                 ),
                
//               ],
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               // SizedBox(
//               //   height: 30,
//               //   width: 100,
//               //   child: TextField(
//               //     controller: controllerMrp,
//               //     textAlign: TextAlign.right,
//               //     decoration: const InputDecoration(
//               //        contentPadding: EdgeInsets.symmetric(
//               //   horizontal: 5,
//               //   vertical: 5
//               // ),
//               //         border: OutlineInputBorder(), 
//               //         label: Text('MRP')),
//               //     keyboardType:
//               //         const TextInputType.numberWithOptions(decimal: true),
//               //     inputFormatters: [
//               //       FilteringTextInputFormatter(RegExp(r'[0-9]'),
//               //           allow: true, replacementString: '.')
//               //     ],
//               //     onChanged: (value) {
//               //       setState(() {
//               //         editableMrp = true;
//               //         mrp = double.tryParse(value)!;
//               //         calculateRate();
//               //       });
//               //     },
//               //   ),
//               // ),
//               // SizedBox(
//               //   height: 30,
//               //   width: 100,
//               //   child: TextField(
//               //     controller: controllerRetail,
//               //     textAlign: TextAlign.right,
//               //     decoration: const InputDecoration(
//               //         border: OutlineInputBorder(), label: Text('Retail')),
//               //     keyboardType:
//               //         const TextInputType.numberWithOptions(decimal: true),
//               //     inputFormatters: [
//               //       FilteringTextInputFormatter(RegExp(r'[0-9]'),
//               //           allow: true, replacementString: '.')
//               //     ],
//               //     onChanged: (value) {
//               //       setState(() {
//               //         editableRetail = true;
//               //         retail = double.tryParse(value)!;
//               //         calculateRate();
//               //       });
//               //     },
//               //   ),
//               // ),
//             ],
//           ),
//           const SizedBox(
//             height: 2,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               // SizedBox(
//               //   height: 30,
//               //   width: 100,
//               //   child: TextField(
//               //     controller: controllerWholeSale,
//               //     textAlign: TextAlign.right,
//               //     decoration: const InputDecoration(
//               //         border: OutlineInputBorder(), label: Text('WholeSale')),
//               //     keyboardType:
//               //         const TextInputType.numberWithOptions(decimal: true),
//               //     inputFormatters: [
//               //       FilteringTextInputFormatter(RegExp(r'[0-9]'),
//               //           allow: true, replacementString: '.')
//               //     ],
//               //     onChanged: (value) {
//               //       setState(() {
//               //         editableWSale = true;
//               //         wholeSale = double.tryParse(value)!;
//               //         calculateRate();
//               //       });
//               //     },
//               //   ),
//               // ),
//               // SizedBox(
//               //   height: 30,
//               //   width: 100,
//               //   child: TextField(
//               //     controller: controllerBranch,
//               //     textAlign: TextAlign.right,
//               //     decoration: const InputDecoration(
//               //         border: OutlineInputBorder(), label: Text('Branch')),
//               //     keyboardType:
//               //         const TextInputType.numberWithOptions(decimal: true),
//               //     inputFormatters: [
//               //       FilteringTextInputFormatter(RegExp(r'[0-9]'),
//               //           allow: true, replacementString: '.')
//               //     ],
//               //     onChanged: (value) {
//               //       setState(() {
//               //         editableBranch = true;
//               //         branch = double.tryParse(value)!;
//               //         calculateRate();
//               //       });
//               //     },
//               //   ),
//               // ),
//             ],
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Total :',
//                 style: TextStyle(
//                   fontFamily: 'poppins',
//                   fontSize: 15,
//                 fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 totalCartTotal.toStringAsFixed(decimal),
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   bool editItem = false;
//   int? position;

//   cartProduct() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 16
//       ),
//       child: Column(
//         children: [
//           purchaseHeaderWidget(),
//           const SizedBox(
//             height: 8,
//           ),
//           ListView.separated(
//             shrinkWrap: true,
//             itemCount: cartItem.length,
//             separatorBuilder: (BuildContext context, int index) =>
//                 const SizedBox(
//                   height: 8,
//                 ),
//             itemBuilder: (context, index) {
//               return Container(
//                 decoration: BoxDecoration(
//                   color: white,
//                   border: Border.all(
//                     color: grey
//                   ),
//                   borderRadius: BorderRadius.circular(3)
//                 ),
//                 child: ListTile(
//                   title: Text(cartItem[index].itemName,
//                   style: const TextStyle(
//                     fontFamily: 'poppins'
//                   ),
//                   ),
//                   subtitle: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Q:${cartItem[index].quantity}'),
//                           Text(cartItem[index].unitName),
//                           Text(
//                               'R:${CommonService.getRound(decimal, cartItem[index].rate)}'),
//                           Text(
//                               ' = ${CommonService.getRound(decimal, cartItem[index].gross)}'),
//                         ],
//                       ),
//                     ],
//                   ),
//                   trailing: PopUpMenuAction(
//                     onDelete: () {
//                       setState(() {
//                         cartItem.removeAt(index);
//                       });
//                     },
//                     onEdit: () {
//                       setState(() {
//                         editItem = true;
//                         position = index;
//                         nextWidget = 2;
//                         productModel = StockItem(
//                             code: cartItem[index].itemId.toString(),
//                             hasVariant: false,
//                             id: cartItem[index].id,
//                             name: cartItem[index].itemName,
//                             quantity: cartItem[index].quantity);
//                       });
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//          Expanded(
//           child:  footerWidget(),
//          )
//         ],
//       ),
//     );
//   }

//   footerWidget() {
//     calculateTotal();
//     return Container(
//       padding: const EdgeInsets.all(5.0),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               const Text('Total : ',
//                   style: TextStyle(
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.w600,
//                       fontFamily: 'poppins')),
//               Text(
//                   totalCartTotal > 0
//                       ? ComSettings.appSettings(
//                               'bool', 'key-round-off-amount', false)
//                           ? CommonService.getRound(decimal, totalCartTotal)
//                               .toString()
//                           : CommonService.getRound(decimal, totalCartTotal)
//                               .roundToDouble()
//                               .toString()
//                       : ComSettings.appSettings(
//                               'bool', 'key-round-off-amount', false)
//                           ? CommonService.getRound(decimal, totalCartTotal)
//                               .toString()
//                           : CommonService.getRound(
//                                   decimal, totalCartTotal.roundToDouble())
//                               .toString(),
//                   style: const TextStyle(
//                      fontSize: 18.0,
//                       fontWeight: FontWeight.w600,
//                       ))
//             ],
//           ),
//           // const Divider(
//           //   height: 1,
//           //   thickness: 1,
//           // ),
//         ],
//       ),
//     );
//   }

//   double taxTotalCartValue = 0, totalCartTotal = 0;
//   calculateTotal() {
//     taxTotalCartValue = 0;
//     totalCartTotal = 0;
//     for (var f in cartItem) {
//       totalCartTotal += f.gross;
//     }
//   }

//   void showInSnackBar(String value) {
//     setState(() {
//       _isLoading = false;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
//   }

//   clearValue() {
//     controllerQuantity.text = '';
//     controllerRate.text = '';
//     controllerDiscountPer.text = '';
//     controllerDiscount.text = '';
//     controllerBranch.text = '';
//     controllerMrp.text = '';
//     controllerRetail.text = '';
//     controllerWholeSale.text = '';
//     editableQuantity = false;
//     editableMrp = false;
//     editableRetail = false;
//     editableWSale = false;
//     editableBranch = false;
//     editableRate = false;
//     editableDiscount = false;
//     editableDiscountP = false;
//   }

//   Future _selectDate() async {
//     DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: DateTime.now(),
//         firstDate: DateTime(2000),
//         lastDate: DateTime(2100));
//     if (picked != null) {
//       setState(() => formattedDate = DateFormat('dd-MM-yyyy').format(picked));
//     }
//   }

//   showEditDialog(context, dataDynamic) {
//     ConfirmAlertBox(
//         buttonColorForNo: Colors.red,
//         buttonColorForYes: Colors.green,
//         icon: Icons.check,
//         onPressedNo: () {
//           Navigator.of(context).pop();
//         },
//         onPressedYes: () {
//           Navigator.of(context).pop();
//           fetchPurchase(context, dataDynamic);
//         },
//         buttonTextForNo: 'No',
//         buttonTextForYes: 'YES',
//         infoMessage:
//             'Do you want to edit or delete\nRefNo:${dataDynamic['Id']}',
//         title: 'Update',
//         context: context);
//   }

//   fetchPurchase(context, data) {
//     DioService api = DioService();
//     String narration = '';

//     api.fetchStockTransfer(data['Id'], 'Pr_Find').then((value) {
//       if (value != null) {
//         var information = value[0][0];
//         var particulars = value[1];
//         // var serialNO = value[2];
//         // var deliveryNoteDetails = value['DeliveryNote'];
//         formattedDate = DateUtil.dateDMY(information['DDate']);
//         dataDynamic = [
//           {
//             'RealEntryNo': information['EntryNo'],
//             'EntryNo': information['EntryNo'],
//             'InvoiceNo': information['Sup_Inv'],
//             'Type': '0'
//           }
//         ];
//         narration = information['Narration'];
//         locationFromId = information['Fromname'];
//         locationToId = information['Toname'];
//         cartItem.clear();
//         for (var product in particulars) {
//           double _gross = (double.tryParse(product['Rate'].toString())! *
//               double.tryParse(product['Qty'].toString())!);
//           cartItem.add(CartItemST(
//               barcode: barcode,
//               branch: double.tryParse(product['Branch'].toString())!,
//               gross: _gross,
//               id: cartItem.length + 1,
//               itemId: int.parse(product['ItemName'].toString()),
//               itemName: product['ProductName'].toString(),
//               mrp: double.tryParse(product['MRP'].toString())!,
//               quantity: double.tryParse(product['Qty'].toString())!,
//               rRate: double.tryParse(product['RealPrate'].toString())!,
//               rate: double.tryParse(product['Rate'].toString())!,
//               retail: double.tryParse(product['Retail'].toString())!,
//               serialNo: '',
//               spRetail: double.tryParse(product['SpRetail'].toString())!,
//               uniqueCode: product['Uniquecode'],
//               unitId: product['Unit'],
//               unitName: '',
//               unitValue: double.tryParse(product['Unitvalue'].toString())!,
//               wholesale: double.tryParse(product['WsRate'].toString())!,
//               stUniqueCode: product['StockUniquecode'],
//               stock: 0,
//               cBarcode: product['St_CBarcode']));
//         }
//       }

//       setState(() {
//         widgetID = false;
//         _narration = narration;
//         nextWidget = 3;
//         oldBill = true;
//       });
//     });
//   }

//   delete(context) {
//     ConfirmAlertBox(
//         buttonColorForNo: Colors.red,
//         buttonColorForYes: Colors.green,
//         icon: Icons.check,
//         onPressedNo: () {
//           Navigator.of(context).pop();
//           setState(() {
//             _isLoading = false;
//           });
//         },
//         onPressedYes: () {
//           Navigator.of(context).pop();
//           deleteData();
//         },
//         buttonTextForNo: 'No',
//         buttonTextForYes: 'YES',
//         infoMessage: 'Do you want to Delete',
//         title: 'Delete Bill',
//         context: context);
//   }

//   deleteData() {
//     dio.deleteStockTransfer(dataDynamic[0]['EntryNo'], 'Delete').then((value) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (value) {
//         cartItem.clear();
//         clearValue();
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return Expanded(
//               child: AlertDialog(
//                 title: const Text('Stock Transfer Deleted'),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                       Navigator.pushReplacementNamed(context, '/stockTransfer');
//                     },
//                     child: const Text('CANCEL'),
//                   )
//                 ],
//               ),
//             );
//           },
//         );
//       }
//     });
//   }
// }

// showMore(context, purchaseState) {
//   ConfirmAlertBox(
//       buttonColorForNo: Colors.white,
//       buttonColorForYes: Colors.green,
//       icon: Icons.check,
//       onPressedYes: () {
//         Navigator.of(context).pop();
//         Navigator.pushReplacementNamed(context, '/stockTransfer');
//       },
//       // buttonTextForNo: 'No',
//       buttonTextForYes: 'OK',
//       infoMessage: 'Stock Transfer $purchaseState',
//       title: 'SAVED',
//       context: context);
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/app_settings_page.dart';
import 'package:sheraccerp/models/cart_item.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/stock_item.dart';
import 'package:sheraccerp/models/stock_product.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/service/com_service.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/color_palette.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/popup_menu_action.dart';
import 'package:sheraccerp/widget/progress_hud.dart';


class _ItemDetailForm extends StatefulWidget {
  final StockProduct product;
  final bool editItem;
  final CartItemST? editingCartItem; 
  final int decimal;
  final String taxMethod;
  final double runningTotal;
  final void Function(
    double qty,
    double rate,
    double mrp,
    double retail,
    double wholeSale,
    double branch,
    double subTotal,
    double rRate,
    double spRetail,
    String cBarcode,
    int uniqueCode,
    int stUniqueCode,
  ) onCommit;
  final VoidCallback onBack;
  final VoidCallback onCancel;

  const _ItemDetailForm({
    Key? key,
    required this.product,
    required this.editItem,
    this.editingCartItem,
    required this.decimal,
    required this.taxMethod,
    required this.runningTotal,
    required this.onCommit,
    required this.onBack,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<_ItemDetailForm> createState() => _ItemDetailFormState();
}

class _ItemDetailFormState extends State<_ItemDetailForm> {
  late final TextEditingController _qty;
  late final TextEditingController _rate;
  late final TextEditingController _mrp;
  late final TextEditingController _retail;
  late final TextEditingController _wsale;
  late final TextEditingController _branch;

  late double subTotal;
  late double rRate;
  late double spRetail;
  late int uniqueCode;
  late int stUniqueCode;
  late String cBarcode;

  @override
  void initState() {
    super.initState();

    double initQty, initRate, initMrp, initRetail, initWsale, initBranch;

    if (widget.editItem && widget.editingCartItem != null) {
      final ci = widget.editingCartItem!;
      initQty     = ci.quantity;
      initRate    = ci.rate;
      initMrp     = ci.mrp;
      initRetail  = ci.retail;
      initWsale   = ci.wholesale;
      initBranch  = ci.branch;
      rRate       = ci.rRate;
      spRetail    = ci.spRetail;
      uniqueCode  = ci.uniqueCode;
      stUniqueCode = ci.stUniqueCode;
      cBarcode    = ci.cBarcode ?? '';
      subTotal    = ci.gross;
    } else {
      final p = widget.product;
      initQty     = 0;
      initRate    = double.tryParse(p.buyingPrice.toString())    ?? 0;
      initMrp     = double.tryParse(p.sellingPrice.toString())   ?? 0;
      initRetail  = double.tryParse(p.retailPrice.toString())    ?? 0;
      initWsale   = double.tryParse(p.wholeSalePrice.toString()) ?? 0;
      initBranch  = double.tryParse(p.branch.toString())         ?? 0;
      rRate       = double.tryParse(p.buyingPriceReal.toString()) ?? 0;
      spRetail    = double.tryParse(p.spRetailPrice.toString())  ?? 0;
      uniqueCode  = p.productId ?? 0;
      stUniqueCode = 0;
      cBarcode    = p.cBarcode ?? '';
      subTotal    = 0;
    }

    _qty    = TextEditingController(text: initQty   > 0 ? initQty.toString()   : '');
    _rate   = TextEditingController(text: initRate  > 0 ? initRate.toString()  : '');
    _mrp    = TextEditingController(text: initMrp   > 0 ? initMrp.toString()   : '');
    _retail = TextEditingController(text: initRetail > 0 ? initRetail.toString() : '');
    _wsale  = TextEditingController(text: initWsale  > 0 ? initWsale.toString()  : '');
    _branch = TextEditingController(text: initBranch > 0 ? initBranch.toString() : '');
  }

  @override
  void dispose() {
    _qty.dispose();
    _rate.dispose();
    _mrp.dispose();
    _retail.dispose();
    _wsale.dispose();
    _branch.dispose();
    super.dispose();
  }

  void _recalculate() {
    final qty  = double.tryParse(_qty.text)  ?? 0;
    final rate = double.tryParse(_rate.text) ?? 0;
    setState(() {
      rRate    = widget.taxMethod == 'MINUS' ? (100 * rate) / 100 : rate;
      subTotal = _round(rate * qty);
    });
  }

  double _round(double v) => CommonService.getRound(widget.decimal, v);

  void _tryCommit() {
    final qty  = double.tryParse(_qty.text)    ?? 0;
    final rate = double.tryParse(_rate.text)   ?? 0;
    final mrp  = double.tryParse(_mrp.text)    ?? 0;
    final ret  = double.tryParse(_retail.text) ?? 0;
    final ws   = double.tryParse(_wsale.text)  ?? 0;
    final br   = double.tryParse(_branch.text) ?? 0;
    final sub  = _round(rate * qty);

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid quantity'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final available = widget.product.quantity ?? 0;
    if (!widget.editItem && available < qty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Available qty is $available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onCommit(qty, rate, mrp, ret, ws, br, sub, rRate, spRetail, cBarcode, uniqueCode, stUniqueCode);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final itemName = widget.editItem && widget.editingCartItem != null
        ? widget.editingCartItem!.itemName
        : (p.name ?? '');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            itemName,
            style: TextStyle(
              fontFamily: 'poppins',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: kPrimaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _field(
          controller: _qty,
          label: 'Quantity  (Available: ${p.quantity})',
          onChanged: (_) => _recalculate(),
        ),
        const SizedBox(height: 10),

        _field(
          controller: _rate,
          label: 'Purchase Rate',
          onChanged: (_) => _recalculate(),
        ),
        const SizedBox(height: 10),

        _summaryRow('Subtotal', subTotal.toStringAsFixed(widget.decimal)),
        const SizedBox(height: 16),

        Row(children: [
          Expanded(child: _smallField(controller: _mrp,    label: 'MRP')),
          const SizedBox(width: 10),
          Expanded(child: _smallField(controller: _retail, label: 'Retail')),
        ]),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(child: _smallField(controller: _wsale,  label: 'Wholesale')),
          const SizedBox(width: 10),
          Expanded(child: _smallField(controller: _branch, label: 'Branch')),
        ]),
        const SizedBox(height: 16),

        _summaryRow(
          'Cart Total',
          widget.runningTotal.toStringAsFixed(widget.decimal),
          valueColor: kPrimaryColor,
        ),
        const SizedBox(height: 24),

        Row(children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: widget.onBack,
              child: const Text('Back', style: TextStyle(fontFamily: 'poppins')),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: widget.onCancel,
              child: const Text('Cancel', style: TextStyle(fontFamily: 'poppins')),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _tryCommit,
              child: Text(
                widget.editItem ? 'Update' : 'Add to cart',
                style: const TextStyle(fontFamily: 'poppins', color: Colors.white),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter(RegExp(r'[0-9.]'), allow: true)],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'poppins', color: Colors.grey.shade500, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onChanged: onChanged,
    );
  }

  Widget _smallField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter(RegExp(r'[0-9.]'), allow: true)],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'poppins', color: Colors.grey.shade500, fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        isDense: true,
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(fontFamily: 'poppins', color: Colors.grey.shade600)),
        Text(value,
            style: TextStyle(
              fontFamily: 'poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: valueColor ?? Colors.black87,
            )),
      ]),
    );
  }
}


class StockTransfer extends StatefulWidget {
  const StockTransfer({Key? key}) : super(key: key);

  @override
  State<StockTransfer> createState() => _StockTransferState();
}

class _StockTransferState extends State<StockTransfer>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final DioService dio = DioService();

  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  bool enableMULTIUNIT = false,
      cessOnNetAmount = false,
      keyItemsVariantStock = false,
      taxGroupUpdate = false;
  int salesManId = 0, decimal = 2;
  List<dynamic> locationData = [];

  int locationFromId = 0, locationToId = 0;

  int _screen = 0;

  List<CartItemST> cartItem = [];
  bool oldBill = false, buttonEvent = false, _isLoading = false;
  String _narration = '';
  double totalCartTotal = 0;

  StockItem? productModel;
  StockProduct? _selectedProduct; 
  bool editItem = false;
  int? editPosition;

  List<dynamic> _allItems = [];
  List<dynamic> _filteredItems = [];
  bool _itemDataLoaded = false;
  int _itemDataFromLocation = -1; 
  final TextEditingController _searchCtrl = TextEditingController();

  bool isVariantSelected = false;
  int positionID = 0;

  final ScrollController _scrollCtrl = ScrollController();
  List dataDisplay = [];
  bool isLoadingData = false, lastRecord = false;
  int page = 1, totalRecords = 0;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
    _scrollCtrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSettings();
      _getMoreData();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 100) {
      _getMoreData();
    }
  }


  void loadSettings() {
    final cs = ScopedModel.of<MainModel>(context).getCompanySettings();
    final st = ScopedModel.of<MainModel>(context).getSettings();

    taxMethod = cs.taxCalculation!;
    enableMULTIUNIT = ComSettings.getStatus('ENABLE MULTI-UNIT', st);
    companyTaxMode = ComSettings.getValue('PACKAGE', st);
    cessOnNetAmount = ComSettings.getStatus('CESS ON NET AMOUNT', st);
    salesManId = ComSettings.appSettings(
            'int', 'key-dropdown-default-salesman-view', 1) - 1;
    decimal = int.tryParse(ComSettings.getValue('DECIMAL', st).toString()) ?? 2;
    keyItemsVariantStock = ComSettings.getStatus('KEY LOCK SALES DISCOUNT', st);
    taxGroupUpdate = ComSettings.getStatus('KEY TAXGROUP UPDATE', st);

    locationData = [];
    if (locationList.isNotEmpty) {
      locationData = List.from(locationList);
      try {
        if (locationList.where((e) => e.value == '').map((e) => e.key).first == 1) {
          locationData.removeAt(0);
          locationData.insert(0, AppSettingsMap(key: 0, value: 'Select Branch'));
        }
      } catch (_) {}
    }
    setState(() {});
  }

  void _getMoreData() {
    if (lastRecord || isLoadingData) return;
    if (dataDisplay.isNotEmpty &&
        dataDisplay.length >= totalRecords &&
        totalRecords > 0) return;

    setState(() => isLoadingData = true);

    dio
        .getPaginationList('StockTransferList', page, '1', '0',
            DateUtil.dateYMD(formattedDate), salesManId.toString())
        .then((value) {
      if (!mounted) return;
      if (value.isEmpty) {
        setState(() => isLoadingData = false);
        return;
      }
      totalRecords = value[1][0]['Total'];
      page++;
      final temp = List.from(value[0]);
      setState(() {
        isLoadingData = false;
        dataDisplay.addAll(temp);
        lastRecord = temp.isEmpty;
      });
    });
  }


  void _to(int screen) {
    setState(() => _screen = screen);
    _fadeCtrl.forward(from: 0);
  }

  void _openNewForm() {
    cartItem.clear();
    oldBill = false;
    buttonEvent = false;
    _narration = '';
    locationFromId = 0;
    locationToId = 0;
    editItem = false;
    editPosition = null;
    _selectedProduct = null;
    _allItems = [];
    _filteredItems = [];
    _itemDataLoaded = false;
    _itemDataFromLocation = -1;
    _to(1);
  }

  void _backToList() {
    page = 1;
    lastRecord = false;
    dataDisplay.clear();
    _getMoreData();
    _to(0);
  }

  Future<bool> _onWillPop() async {
    if (_screen == 2 || _screen == 3) { _to(1); return false; }
    if (_screen == 1) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Leave this transfer?'),
          content: const Text('Unsaved changes will be lost.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay')),
            TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Leave')),
          ],
        ),
      );
      if (leave == true) _backToList();
      return false;
    }
    return true;
  }


  double _calcTotal() {
    totalCartTotal = 0;
    for (final f in cartItem) totalCartTotal += f.gross;
    return totalCartTotal;
  }


  void _onItemCommit(
    double qty, double rate, double mrp, double retail,
    double wholeSale, double branch, double subTotal,
    double rRate, double spRetail, String cBarcode,
    int uniqueCode, int stUniqueCode,
  ) {
    final p = _selectedProduct!;

    if (!editItem) {
      double cartQty = 0, cartStock = 0;
      for (final el in cartItem) {
        if (el.uniqueCode == p.productId) {
          cartQty  += el.quantity;
          cartStock = el.stock;
        }
      }
      if (cartStock > 0 && cartStock < cartQty + qty) {
        _showSnack('Available qty is ${cartStock - cartQty}');
        return;
      }
    }

    setState(() {
      if (editItem && editPosition != null) {
        cartItem[editPosition!]
          ..branch      = branch
          ..gross       = subTotal
          ..mrp         = mrp
          ..quantity    = qty
          ..rRate       = rRate
          ..rate        = rate
          ..retail      = retail
          ..spRetail    = spRetail
          ..uniqueCode  = uniqueCode
          ..wholesale   = wholeSale
          ..stUniqueCode = stUniqueCode
          ..cBarcode    = cBarcode;
      } else {
        cartItem.add(CartItemST(
          barcode:      0,
          branch:       branch,
          gross:        subTotal,
          id:           cartItem.length + 1,
          itemId:       p.itemId!,
          itemName:     p.name!,
          mrp:          mrp,
          quantity:     qty,
          rRate:        rRate,
          rate:         rate,
          retail:       retail,
          serialNo:     '',
          spRetail:     spRetail,
          uniqueCode:   uniqueCode,
          unitId:       0,
          unitName:     '',
          unitValue:    1,
          wholesale:    wholeSale,
          stUniqueCode: stUniqueCode,
          stock:        p.quantity ?? 0,
          cBarcode:     cBarcode,
        ));
      }
      editItem        = false;
      editPosition    = null;
      isVariantSelected = false;
      _selectedProduct  = null;
    });
    _to(1); 
  }


  Future<void> _save() async {
    if (buttonEvent) return;
    if (cartItem.isEmpty) { _showSnack('Add at least one item'); return; }
    if (locationFromId == 0 || locationToId == 0) {
      _showSnack('Select From and To branch');
      return;
    }
    setState(() { _isLoading = true; buttonEvent = true; });

    final inf   = '[${json.encode({'fromId': locationFromId, 'toId': locationToId})}]';
    final items = json.encode(CartItemST.encodeCartToJson(cartItem));
    final data  = '[${json.encode({
      'date': DateUtil.dateYMD(formattedDate),
      'total': _calcTotal(),
      'narration': _narration,
      'Salesman': salesManId,
      'location': '0',
      'statementtype': 'Insert',
      'fyId': currentFinancialYear!.id,
    })}]';

    final ok = await dio.stockTransfer({'information': inf, 'data': data, 'particular': items});
    setState(() => _isLoading = false);
    if (ok) { cartItem.clear(); _showMore(context, 'Saved'); }
    else    { _showSnack('Error — check entries'); setState(() => buttonEvent = false); }
  }

  Future<void> _update() async {
    if (buttonEvent) return;
    setState(() { _isLoading = true; buttonEvent = true; });

    final inf   = '[${json.encode({'fromId': locationFromId, 'toId': locationToId})}]';
    final items = json.encode(CartItemST.encodeCartToJson(cartItem));
    final data  = '[${json.encode({
      'entryNo': dataDynamic[0]['EntryNo'],
      'date': DateUtil.dateYMD(formattedDate),
      'total': _calcTotal(),
      'narration': _narration,
      'Salesman': salesManId,
      'location': '0',
      'statementtype': 'Update',
      'fyId': currentFinancialYear!.id,
    })}]';

    final ok = await dio.stockTransfer({'information': inf, 'data': data, 'particular': items});
    setState(() => _isLoading = false);
    if (ok) { cartItem.clear(); _showMore(context, 'Updated'); }
    else    { _showSnack('Error — check entries'); setState(() => buttonEvent = false); }
  }

  void _delete() {
    if (buttonEvent) return;
    ConfirmAlertBox(
      buttonColorForNo: Colors.red,
      buttonColorForYes: Colors.green,
      icon: Icons.delete_outline,
      onPressedNo: () => Navigator.of(context).pop(),
      onPressedYes: () {
        Navigator.of(context).pop();
        setState(() => _isLoading = true);
        dio.deleteStockTransfer(dataDynamic[0]['EntryNo'], 'Delete').then((ok) {
          setState(() => _isLoading = false);
          if (ok) {
            cartItem.clear();
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Transfer deleted'),
                actions: [TextButton(
                  onPressed: () { Navigator.pop(context); Navigator.pushReplacementNamed(context, '/stockTransfer'); },
                  child: const Text('OK'),
                )],
              ),
            );
          }
        });
      },
      buttonTextForNo:  'No',
      buttonTextForYes: 'Yes',
      infoMessage: 'Delete this transfer?',
      title: 'Delete',
      context: context,
    );
  }


  void _showEditDialog(dynamic row) {
    ConfirmAlertBox(
      buttonColorForNo: Colors.red,
      buttonColorForYes: Colors.green,
      icon: Icons.edit_outlined,
      onPressedNo: () => Navigator.of(context).pop(),
      onPressedYes: () { Navigator.of(context).pop(); _fetchBill(row); },
      buttonTextForNo:  'No',
      buttonTextForYes: 'Yes',
      infoMessage: 'Edit or delete  Ref No: ${row['Id']}',
      title: 'Open bill',
      context: context,
    );
  }

  void _fetchBill(dynamic data) {
    setState(() => _isLoading = true);
    dio.fetchStockTransfer(data['Id'], 'Pr_Find').then((value) {
      if (value == null) { setState(() => _isLoading = false); return; }
      final info   = value[0][0];
      final parts  = value[1] as List;

      formattedDate  = DateUtil.dateDMY(info['DDate']);
      dataDynamic    = [{'RealEntryNo': info['EntryNo'], 'EntryNo': info['EntryNo'], 'InvoiceNo': info['Sup_Inv'], 'Type': '0'}];
      _narration     = info['Narration'] ?? '';
      locationFromId = info['Fromname'];
      locationToId   = info['Toname'];

      cartItem.clear();
      for (final p in parts) {
        final gross = (double.tryParse(p['Rate'].toString()) ?? 0) *
                      (double.tryParse(p['Qty'].toString())  ?? 0);
        cartItem.add(CartItemST(
          barcode:      0,
          branch:       double.tryParse(p['Branch'].toString())    ?? 0,
          gross:        gross,
          id:           cartItem.length + 1,
          itemId:       int.parse(p['ItemName'].toString()),
          itemName:     p['ProductName'].toString(),
          mrp:          double.tryParse(p['MRP'].toString())       ?? 0,
          quantity:     double.tryParse(p['Qty'].toString())       ?? 0,
          rRate:        double.tryParse(p['RealPrate'].toString()) ?? 0,
          rate:         double.tryParse(p['Rate'].toString())      ?? 0,
          retail:       double.tryParse(p['Retail'].toString())    ?? 0,
          serialNo:     '',
          spRetail:     double.tryParse(p['SpRetail'].toString())  ?? 0,
          uniqueCode:   p['Uniquecode'],
          unitId:       p['Unit'],
          unitName:     '',
          unitValue:    double.tryParse(p['Unitvalue'].toString()) ?? 1,
          wholesale:    double.tryParse(p['WsRate'].toString())    ?? 0,
          stUniqueCode: p['StockUniquecode'],
          stock:        0,
          cBarcode:     p['St_CBarcode'] ?? '',
        ));
      }

      setState(() { _isLoading = false; oldBill = true; buttonEvent = false; });
      _to(1);
    });
  }


  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null) setState(() => formattedDate = DateFormat('dd-MM-yyyy').format(picked));
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final should = await _onWillPop();
        if (should && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: _buildAppBar(),
        body: ProgressHUD(
          inAsyncCall: _isLoading,
          opacity: 0,
          child: FadeTransition(opacity: _fadeAnim, child: _buildBody()),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    final titles = ['Stock Transfer', 'Stock Transfer', 'Select Product', 'Item Details'];
    return AppBar(
      backgroundColor: kPrimaryColor,
      elevation: 0,
      leading: _screen == 0
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back_sharp, color: Colors.white, ),
              onPressed: () async {
                final should = await _onWillPop();
                if (should && mounted) Navigator.of(context).pop();
              },
            ),
      title: Text(titles[_screen],
          style: const TextStyle(fontFamily: 'poppins', fontSize: 18, color: Colors.white)),
      actions: [
        if (_screen == 0)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _openNewForm,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New', style: TextStyle(fontFamily: 'poppins')),
            ),
          ),
        if (_screen == 1) ...[
          if (oldBill)
            IconButton(
              tooltip: 'Delete',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: Colors.white),
            ),
          IconButton(
            tooltip: oldBill ? 'Update' : 'Save',
            onPressed: oldBill ? _update : _save,
            icon: Icon(oldBill ? Icons.edit : Icons.save, 
                color: Colors.white),
          ),
        ],
      ],
    );
  }

  Widget _buildBody() {
    switch (_screen) {
      case 0: return listScreen();
      case 1: return cartScreen();
      case 2: return productPicker();
      case 3: return itemDetailScreen();
      default: return const SizedBox.shrink();
    }
  }


  Widget listScreen() {
    if (dataDisplay.isEmpty && isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (dataDisplay.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.swap_horiz_rounded, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text('No transfers yet',
            style: TextStyle(fontFamily: 'poppins', fontSize: 16, color: Colors.grey.shade400)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: _openNewForm,
          icon: const Icon(Icons.add),
          label: const Text('New Transfer', style: TextStyle(fontFamily: 'poppins')),
        ),
      ]));
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: dataDisplay.length + 1,
      itemBuilder: (_, i) {
        if (i == dataDisplay.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Opacity(
              opacity: isLoadingData ? 1 : 0,
              child: const CircularProgressIndicator())));
        }
        return _buildBillCard(dataDisplay[i]);
      },
    );
  }

  Widget _buildBillCard(dynamic item) {
    return GestureDetector(
      onTap: () => _showEditDialog(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.swap_horiz_rounded, color: kPrimaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${item['StockFrom']}  →  ${item['StockTo']}',
                  style: const TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(item['Date'].toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(width: 12),
                Icon(Icons.tag, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 2),
                Text(item['Id'].toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Total', style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontFamily: 'poppins')),
              Text(item['Total'].toStringAsFixed(decimal),
                  style: TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.w700, fontSize: 15, color: kPrimaryColor)),
            ]),
          ]),
        ),
      ),
    );
  }


  Widget cartScreen() {
    _calcTotal();
    return Column(children: [
      transferHeader(),
      Expanded(child: cartItem.isEmpty ? _emptyCart() : cartList()),
      cartFooter(),
    ]);
  }

  Widget transferHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Date
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Date', style: TextStyle(fontFamily: 'poppins', fontSize: 13, color: Colors.grey.shade500)),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                Text(formattedDate, style: const TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey.shade400),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        // From / To
        Row(children: [
          Expanded(child: _branchDropdown('From', locationFromId, (v) {
            setState(() {
              locationFromId = v!;
              // Invalidate product cache when branch changes
              _allItems = [];
              _filteredItems = [];
              _itemDataLoaded = false;
              _itemDataFromLocation = -1;
            });
          })),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward, color: kPrimaryColor, size: 20),
          ),
          Expanded(child: _branchDropdown('To', locationToId, (v) => setState(() => locationToId = v!))),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimaryColor,
              side: BorderSide(color: kPrimaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (locationFromId == 0) { _showSnack('Select a From branch first'); return; }
              _to(2);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add item', style: TextStyle(fontFamily: 'poppins')),
          ),
        ),
      ]),
    );
  }

  Widget _branchDropdown(String label, int value, ValueChanged<int?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontFamily: 'poppins', fontSize: 12, color: Colors.grey.shade500)),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            value: value,
            style: const TextStyle(fontFamily: 'poppins', fontSize: 13, color: Colors.black87),
            items: locationData.map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(
              value: e.key,
              child: Text(e.value, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'poppins', fontSize: 13)),
            )).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ]);
  }

  Widget _emptyCart() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.shopping_bag_outlined, size: 56, color: Colors.grey.shade300),
    const SizedBox(height: 12),
    Text('No items added yet',
        style: TextStyle(fontFamily: 'poppins', color: Colors.grey.shade400, fontSize: 15)),
  ]));

  Widget cartList() => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: cartItem.length,
    itemBuilder: (_, i) => cartRow(i),
  );

  Widget cartRow(int index) {
    final ci = cartItem[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        title: Text(ci.itemName,
            style: const TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(children: [
            _chip('Qty',   ci.quantity.toString()),
            const SizedBox(width: 6),
            _chip('Rate',  CommonService.getRound(decimal, ci.rate).toString()),
            const SizedBox(width: 6),
            _chip('Total', CommonService.getRound(decimal, ci.gross).toString(), color: kPrimaryColor),
          ]),
        ),
        trailing: PopUpMenuAction(
          onDelete: () => setState(() => cartItem.removeAt(index)),
          onEdit: () {
            setState(() {
              editItem     = true;
              editPosition = index;
              // Build a minimal StockItem so the detail screen can show the name
              productModel = StockItem(
                code:       ci.itemId.toString(),
                hasVariant: false,
                id:         ci.id,
                name:       ci.itemName,
                quantity:   ci.quantity,
              );
            });
            _loadProductForEdit(ci);
          },
        ),
      ),
    );
  }

  void _loadProductForEdit(CartItemST ci) {
    setState(() => _isLoading = true);
    dio
        .fetchStockTransferItemVariant(
            ci.itemId, locationFromId.toString(), taxGroupUpdate)
        .then((data) {
      setState(() => _isLoading = false);
      if (data == null || data.isEmpty) {
        _showSnack('Could not load item data');
        return;
      }
      setState(() => _selectedProduct = data[0]);
      _to(3);
    });
  }

  Widget _chip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey.shade600).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichText(text: TextSpan(children: [
        TextSpan(text: '$label: ',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontFamily: 'poppins')),
        TextSpan(text: value,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: color ?? Colors.black87, fontFamily: 'poppins')),
      ])),
    );
  }

  Widget cartFooter() {
    _calcTotal();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${cartItem.length} item${cartItem.length == 1 ? '' : 's'}',
              style: TextStyle(fontFamily: 'poppins', fontSize: 12, color: Colors.grey.shade400)),
          Text('Grand Total',
              style: TextStyle(fontFamily: 'poppins', fontSize: 13, color: Colors.grey.shade600)),
        ]),
        Text(totalCartTotal.toStringAsFixed(decimal),
            style: TextStyle(fontFamily: 'poppins', fontSize: 22, fontWeight: FontWeight.w700, color: kPrimaryColor)),
      ]),
    );
  }

  Widget productPicker() {
    if (_itemDataFromLocation != locationFromId) {
      _itemDataLoaded = false;
      _allItems = [];
      _filteredItems = [];
      _itemDataFromLocation = locationFromId;
    }

    if (_itemDataLoaded) return _productPickerContent();

    return FutureBuilder<List<StockItem>>(
      future: dio.fetchStockProductByLocation(
          locationFromId.toString(), DateUtil.dateDMY2YMD(formattedDate)),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return _errorState(snap.error.toString(), () => _to(1));
        if (!snap.hasData || snap.data!.isEmpty) return _emptyState('No stock in this branch');
        _allItems       = snap.data!;
        _filteredItems  = List.from(_allItems);
        _itemDataLoaded = true;
        return _productPickerContent();
      },
    );
  }

  Widget _productPickerContent() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(fontFamily: 'poppins', color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _filteredItems = List.from(_allItems));
                    })
                : null,
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (q) {
            final lower = q.toLowerCase();
            setState(() => _filteredItems = _allItems
                .where((i) => (i as StockItem).name!.toLowerCase().contains(lower))
                .toList());
          },
        ),
      ),
      Expanded(
        child: _filteredItems.isEmpty
            ? _emptyState('No products match your search')
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredItems.length,
                itemBuilder: (_, i) {
                  final item = _filteredItems[i] as StockItem;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        productModel      = item;
                        editItem          = false;
                        editPosition      = null;
                        isVariantSelected = false;
                        positionID        = 0;
                        _selectedProduct  = null;
                      });
                      _resolveProduct(item);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Row(children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.inventory_2_outlined, color: kPrimaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(item.name ?? '',
                            style: const TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.w500, fontSize: 14))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (item.quantity ?? 0) > 0
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Qty: ${item.quantity}',
                              style: TextStyle(fontFamily: 'poppins', fontSize: 12, fontWeight: FontWeight.w600,
                                  color: (item.quantity ?? 0) > 0 ? Colors.green.shade700 : Colors.red.shade700)),
                        ),
                      ]),
                    ),
                  );
                },
              ),
      ),
    ]);
  }

  void _resolveProduct(StockItem item) {
    if (item.hasVariant == true && keyItemsVariantStock) {
      _to(3);
      return;
    }

    setState(() => _isLoading = true);
    dio
        .fetchStockTransferItemVariant(item.id!, locationFromId.toString(), taxGroupUpdate)
        .then((data) {
      setState(() => _isLoading = false);
      if (data == null || data.isEmpty) {
        _showSnack('Stock ledger data missing');
        return;
      }
      setState(() => _selectedProduct = data[0]);
      _to(3);
    });
  }

  Widget itemDetailScreen() {
    if (productModel?.hasVariant == true && !editItem && _selectedProduct == null) {
      return variantPicker();
    }

    if (_selectedProduct == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return _ItemDetailForm(
      key: ValueKey('${_selectedProduct!.productId}_${editItem}_$editPosition'),
      product:          _selectedProduct!,
      editItem:         editItem,
      editingCartItem:  editItem && editPosition != null ? cartItem[editPosition!] : null,
      decimal:          decimal,
      taxMethod:        taxMethod,
      runningTotal:     totalCartTotal,
      onCommit:         _onItemCommit,
      onBack:           () { setState(() => _selectedProduct = null); _to(2); },
      onCancel:         () { setState(() { editItem = false; editPosition = null; _selectedProduct = null; }); _to(1); },
    );
  }

  Widget variantPicker() {
    return FutureBuilder<List<StockProduct>>(
      future: dio.fetchStockVariant(productModel!.id!, taxGroupUpdate, 0),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return _errorState(snap.error.toString(), () => _to(2));
        if (!snap.hasData || snap.data!.isEmpty) return _emptyState('No variants found');

        final variants = snap.data!;

        if (isVariantSelected) {
          return _ItemDetailForm(
            key: ValueKey('variant_${variants[positionID].productId}'),
            product:         variants[positionID],
            editItem:        false,
            editingCartItem: null,
            decimal:         decimal,
            taxMethod:       taxMethod,
            runningTotal:    totalCartTotal,
            onCommit:        _onItemCommit,
            onBack:          () => setState(() => isVariantSelected = false),
            onCancel:        () { setState(() { isVariantSelected = false; }); _to(1); },
          );
        }

        return Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            color: kPrimaryColor.withOpacity(0.06),
            child: Text(productModel!.name ?? '',
                style: TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.w600,
                    fontSize: 15, color: kPrimaryColor)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: variants.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => setState(() { isVariantSelected = true; positionID = i; }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(children: [
                    Expanded(child: Text('Code: ${variants[i].productId}',
                        style: const TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.w500))),
                    _chip('Qty', variants[i].quantity.toString()),
                    const SizedBox(width: 6),
                    _chip('MRP', variants[i].sellingPrice.toString()),
                  ]),
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }


  Widget _emptyState(String msg) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
    const SizedBox(height: 12),
    Text(msg, textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'poppins', color: Colors.grey.shade400, fontSize: 14)),
  ]));

  Widget _errorState(String err, VoidCallback retry) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade300),
        const SizedBox(height: 12),
        const Text('Something went wrong',
            style: TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(err, textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'poppins', fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: retry, child: const Text('Retry')),
      ]),
    ),
  );
}


void _showMore(BuildContext context, String state) {
  ConfirmAlertBox(
    buttonColorForNo: Colors.blue,
    buttonColorForYes: Colors.green,
    icon: Icons.check_circle_outline,
    onPressedYes: () {
      Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, '/stockTransfer');
    },
    onPressedNo: () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      // Navigator.pushReplacementNamed(context, '/stockTransfer');
    },
    // buttonTextColorForNo: '',
    buttonTextForNo: 'Back',
    buttonTextForYes: 'OK',
    infoMessage: 'Stock Transfer $state',
    title: 'Success',
    context: context,
  );
}