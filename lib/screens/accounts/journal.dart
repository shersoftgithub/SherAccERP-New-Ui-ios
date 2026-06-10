import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/ledger_name_model.dart';
import 'package:sheraccerp/screens/html_previews/jv_preview.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/service/com_service.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/color_palette.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/progress_hud.dart';

// import '../../models/company.dart';
// import '../../models/ledger_name_model.dart';
// import '../../scoped-models/main.dart';
// import '../../service/api_dio.dart';
// import '../../service/com_service.dart';
// import '../../shared/constants.dart';
// import '../../util/dateUtil.dart';
// import '../../util/res_color.dart';
// import '../../widget/progress_hud.dart';

class Journal extends StatefulWidget {
  const Journal({Key? key}) : super(key: key);

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  DioService api = DioService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Size? deviceSize;
  DateTime now = DateTime.now();
  String? formattedDate, narration = '',projectId = '-1';
  List<LedgerModel>? ledgerList = [];
  List<DataJson> projectList = [];
  LedgerModel? ledgerDebitData, ledgerCreditData;
  bool _isLoading = false,
      isSelected = false,
      oldVoucher = false,
      valueMore = false,
      widgetID = true,
      lastRecord = false,
      isProjectSoftware = false,
      buttonEvent = false,
      isNarrationAsCalculator = false;
  int refNo = 0;
  int page = 1, pageTotal = 0, totalRecords = 0;
  int locationId = 1, salesManId = 0, decimal = 2;
  List<CompanySettings>? settings;
  CompanyInformation? companySettings;
  final TextEditingController _controllerAmount = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controllerNarration = TextEditingController();
  double amount = 0;

  @override
  void initState() {
    super.initState();
    formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);
    loadSettings();
    loadAsset();
  }

  loadSettings() {
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();
    salesManId = ComSettings.appSettings(
            'int', 'key-dropdown-default-salesman-view', 1) -
        1;
    locationId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    decimal = (ComSettings.getValue('DECIMAL', settings!).toString().isNotEmpty
        ? int.tryParse(ComSettings.getValue('DECIMAL', settings!).toString())
        : 2)!;
    isNarrationAsCalculator =
        ComSettings.getStatus('KEY NARRATION AS CALCULATOR', settings!);
    isProjectSoftware = ComSettings.getStatus('PROJECT SOFTWARE', settings!);
    loadLedgerData();
     if (isProjectSoftware) {
      api.getProject().then((value) {
        projectList = value;
      });
    }

    api.getLedgerAll().then((value) => ledgerList!.addAll(value));
  }

  @override
  Widget build(BuildContext context) {
    _controllerAmount.selection = TextSelection.fromPosition(
        TextPosition(offset: _controllerAmount.text.length));

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

  widgetSuffix() {
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
                      if (companyUserData!.deleteData) {
                        submitData('DELETE');
                      } else {
                        showInSnackBar('Permission denied\ncan`t delete');
                        setState(() {
                          buttonEvent = false;
                        });
                      }
                    }
                  },
                  icon: Image.asset('assets/icons/ic_delete.png',scale: 3.1,)),
            ),
            oldVoucher
                ? IconButton(
                    color: white,
                    iconSize: 40,
                    onPressed: () {
                      //edit
                       if (buttonEvent) {
                      return;
                    } else {
                      if (companyUserData!.updateData) {
                        submitData('UPDATE');
                      } else {
                        showInSnackBar('Permission denied\ncan`t edit');
                        setState(() {
                          buttonEvent = false;
                        });
                      }
                    }
                    },
                    icon: Image.asset('assets/icons/ic_edit.png',scale: 3.1,))
                : IconButton(
                    color: white,
                    iconSize: 40,
                    onPressed: () {
                      //save
                       if (buttonEvent) {
                      return;
                    } else {
                      if (companyUserData!.insertData) {
                        submitData('INSERT');
                      } else {
                        showInSnackBar('Permission denied\ncan`t save');
                        setState(() {
                          buttonEvent = false;
                        });
                      }
                    }
                    },
                    icon: Image.asset('assets/icons/Save instagram@2x.png',scale: 1.6,)),
          ],
          title: const Text('Journal'),
          titleTextStyle: const TextStyle(fontFamily: 'poppins',
          color: white,
          ),
        ),
        body: ProgressHUD(
          inAsyncCall: _isLoading,
          opacity: 0.0,
          child: _body(),
        ));
  }

  var nameLike = 'a';
  _body() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bagroundColor,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Date ',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                    ),
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 4
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                          color: grey,
                          width: .5
                        )),
                        child: Row(
                          children: [
                            Text(
                              formattedDate!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15,
                                  fontFamily: 'poppins'
                                  ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Icon(Icons.calendar_month,size: 20,color: grey,)
                          ],
                        ),
                      ),
                      onTap: () => _selectDate(),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/ledger',
                                arguments: {'parent': ''});
                  },
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),color: kPrimaryColor),
                      child: const Center(
                        child: Text('Add new ledger',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          color: white
                        ),
                        ),
                      ),
                  ),
                ),
                 const SizedBox(
                  height: 10,
                ),
                projectWidget(),
                const SizedBox(
                  height: 10,
                ),
                DropdownSearch<LedgerModel>(
                  popupProps: const PopupPropsMultiSelection.dialog(
                      isFilterOnline: true,
                      showSearchBox: true,
                      // constraints: BoxConstraints(
                      //   maxHeight: 500,
                      //   minHeight: 200
                      // ),
                      ),
                  asyncItems: (String filter) async {
                    nameLike = filter.isNotEmpty ? filter : 'a';
                    var models = ledgerUserFilterCreation(ledgerList!, nameLike);
                    return models;
                  },
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Select Debit Account"),
                  ),
                  onChanged: (LedgerModel? data) {
                    debugPrint(data.toString());
                    ledgerDebitData = data;
                    setState(() {
                      isSelected = true;
                    });
                  },
                  selectedItem: ledgerDebitData,
                ),
                const SizedBox(
                  height: 10,
                ),
                DropdownSearch<LedgerModel>(
                  popupProps: const PopupPropsMultiSelection.dialog(
                      isFilterOnline: true,
                      showSearchBox: true,
                      // constraints: BoxConstraints(
                      //   maxHeight: 300,
                      // ),
                      ),
                  asyncItems: (String filter) async {
                    nameLike = filter.isNotEmpty ? filter : 'a';
                    var models = ledgerUserFilterCreation(ledgerList!, nameLike);
                    return models;
                  },
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Select Credit Account"),
                  ),
                  onChanged: (LedgerModel? data) {
                    ledgerCreditData = data;
                    setState(() {
                      isSelected = true;
                    });
                  },
                  selectedItem: ledgerCreditData,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controllerAmount,
                        focusNode: _focusNode,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
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
                            amount = (value != null
                                ? value.trim().isNotEmpty
                                    ? double.tryParse(value)
                                    : 0
                                : 0)!;
                          });
                        },
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
                    Expanded(
                      child: TextField(
                        controller: _controllerNarration,
                        decoration:  InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: isNarrationAsCalculator
                            ? 'Enter expression (e.g. 3+4 abcd)'
                            : 'Narration'
                        ),
                        onChanged: (value) {
                          setState(() {
                            narration = value;
                          });
                        },
                        onSubmitted: (value) => _calculateResult(value),
                      ),
                    ),
                  ],
                ),
                // const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
   loadLedgerData() {
    ledgerList!.clear();
    api.getLedgerAll().then((value) => ledgerList!.addAll(value));
  }
  
  widgetPrefix() {
    return Scaffold(
      backgroundColor: bagroundColor,
        key: _scaffoldKey,
        appBar: AppBar(
          actions: [
            TextButton(
                child: const Text(
                  " New ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
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
                }),
          ],
          title: const Text('Journal'),
          titleTextStyle: const TextStyle(fontFamily: 'poppins',
          color: white,
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
        var statement = 'JVList';
        salesManId = salesManId > 0 ? salesManId : 0;
        locationId = locationId > 0 ? locationId : 1;
        api
            .getPaginationList(statement, page, locationId.toString(), '0',
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
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void showInSnackBar(String value) {
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
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

  String formatDMY(value) {
    var dateTime = DateFormat("dd-mm-yyyy").parse(value.toString());
    return DateFormat("yyyy-mm-dd").format(dateTime);
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
                  return 
                  Container(
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              flex: 3,
                              child: InkWell(
                                onTap: () {
                                   showEditDialog(context, dataDisplay[index]);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
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
                            ),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () {
            //                        var dataAll = [
            //   {
            //     'entryNo':
            //         oldVoucher ? dataDynamic[0]['EntryNo'].toString() : refNo,
            //     'date': formatDMY(formattedDate),
            //     'amount': amount,
            //     'particular': particular,
            //     'message': footerMessage,
            //     'dName': ledgerDebitData!.name,
            //     'cName': ledgerCreditData!.name
            //   }
            // ];
            //                       actionShow(context, dataDisplay);
                                },
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
                                            '${dataDisplay[index]['Total'].toStringAsFixed(2)}'),
                                      ),
                                    ),
                                  ],
                                ),
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
              const Text("No data in Journal",
              style: TextStyle(fontFamily: 'poppins'),),
              TextButton.icon(
                style: ButtonStyle(
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                  backgroundColor: MaterialStatePropertyAll(kPrimaryColor),
                ),
                  onPressed: () {
                    setState(() {
                      widgetID = false;
                    });
                  },
                  icon: const Icon(Icons.shopping_bag,color: white,),
                  label: const Text('Take New Journal',
                  style: TextStyle(fontFamily: 'poppins',color: white),))
            ],
          ));
  }

  void submitData(operation) async {
    amount = _controllerAmount.text.isNotEmpty
        ? double.tryParse(_controllerAmount.text.trim())!
        : 0;
    narration =
        _controllerNarration.text.isNotEmpty ? _controllerNarration.text : '';
    if (amount <= 0 || ledgerDebitData == null || ledgerCreditData == null) {
      showInSnackBar('Select Account and amount');
      setState(() {
        buttonEvent = false;
      });
    } else {
      setState(() {
        _isLoading = true;
        buttonEvent = true;
      });
      var particular = '[' +
          json.encode({
            'amount': amount,
            'narration': narration,
            'debitId': ledgerDebitData!.id,
            'creditId': ledgerCreditData!.id
          }) +
          ']';
      var data = [
        {
          'entryNo': oldVoucher ? dataDynamic[0]['EntryNo'].toString() : '0',
          'date': formatDMY(formattedDate),
          'amount': amount,
          'narration': '',
          'time': timeIs,
          'toDevice': 'api',
          'location': locationId,
          'user': userIdC,
          'project': projectId,
          'salesman': salesManId,
          'checkReturn': -1,
          'particular': particular,
          'fyId': currentFinancialYear!.id
        }
      ];
      if (operation == 'DELETE') {
        var _entryNo = oldVoucher ? dataDynamic[0]['EntryNo'].toString() : '0',
            refNo = await api.deleteJournalVoucher(
                _entryNo, formatDMY(formattedDate), userIdC, timeIs);
      } else if (operation == 'UPDATE') {
        refNo = await api.editJournalVoucher(data);
      } else {
        refNo = await api.addJournalVoucher(data);
      }
      if (refNo > 0) {
        setState(() {
          _isLoading = false;
          buttonEvent = false;
          if (operation == 'DELETE') {
            showInSnackBar('Deleted');
          } else {
            var dataAll = [
              {
                'entryNo':
                    oldVoucher ? dataDynamic[0]['EntryNo'].toString() : refNo,
                'date': formatDMY(formattedDate),
                'amount': amount,
                'particular': particular,
                'message': footerMessage,
                'dName': ledgerDebitData!.name,
                'cName': ledgerCreditData!.name
              }
            ];
            actionShow(context, dataAll);
          }
          clearData();
        });
      } else {
        var opr = operation == 'DELETE'
            ? 'error : Cannot delete this journal'
            : operation == 'UPDATE'
                ? 'error : Cannot update this journal'
                : 'error : Cannot save this journal';
        showInSnackBar(opr);
      }
    }
  }

  showEditDialog(context, dataDynamic) {
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
          fetchVoucher(context, dataDynamic);
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage:
            'Do you want to edit or delete\nRefNo:${dataDynamic['Id']}',
        title: 'Update',
        context: context);
  }

  var footerMessage = '';
  fetchVoucher(context, data) {
    int row = 0;
    api.fetchJournalVoucher(data['Id']).then((value) {
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

        // _dropDownValue = information['LedCode'].toString() +
        //     '-' +
        //     information['LedName'].toString();
        // accountName = information['LedName'].toString();
        // accountId = information['LedCode'].toString();
        var part1 = particulars[0];
        ledgerDebitData =
            LedgerModel(id: part1['debitId'], name: part1['debitName']);
        ledgerCreditData =
            LedgerModel(id: part1['creditId'], name: part1['creditName']);
        amount = double.tryParse(information['Amount'].toString())!;
        narration = part1['Narration'].toString();

        setState(() {
          if (row > 0) {
            widgetID = false;
            oldVoucher = true;
            isSelected = true;
            _controllerAmount.text = amount.toString();
            _controllerNarration.text = narration.toString();
          }
        });
      }
    });
  }

  clearData() {
    _controllerAmount.text = '';
    _controllerNarration.text = '';
    amount = 0;
    narration = '';
    ledgerCreditData!.id = 0;
    ledgerDebitData!.id = 0;
    ledgerCreditData!.name = '';
    ledgerDebitData!.name = '';
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

  actionShow(context, data) async {
    var form = 'JOURNAL';
    var title = 'journal Voucher';

    ConfirmAlertBox(
        buttonColorForNo: Colors.red,
        buttonColorForYes: Colors.green,
        icon: Icons.check,
        onPressedNo: () {
          Navigator.of(context).pop();
        },
        onPressedYes: () {
          Navigator.of(context).pop();
          sentToPreview(title, form, data);
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage: 'Do you want to preview \nRefNo:${data[0]['entryNo']}',
        title: 'Print Voucher',
        context: context);
  }

   sentToPreview(String title, String form, var data) {
    var dataAll = [data, form];
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => JvPreviewShow(title: title, dataAll: dataAll)));
  }

  Uint8List? byteImage;
  loadAsset() async {
    // Test image
    ByteData bytes = await rootBundle.load('assets/logo.png');
    final buffer = bytes.buffer;
    byteImage = Uint8List.view(buffer);
  }
  String _result = '';
   // Function to parse the input and calculate
  void _calculateResult(String input) {
    try {
      String operator = '';
      String word = '';
      double? num1, num2;

      if (input.contains('+')) {
        operator = '+';
      } else if (input.contains('-')) {
        operator = '-';
      } else if (input.contains('*')) {
        operator = '*';
      } else if (input.contains('/')) {
        operator = '/';
      }

      if (operator.isNotEmpty) {
        List<String> parts = input.split(operator);
        num1 = double.parse(parts[0]);
        num2 = double.parse(parts[1].split(' ')[0]);
        word = parts[1].split(' ')[1];

        double result;
        switch (operator) {
          case '+':
            result = num1 + num2;
            break;
          case '-':
            result = num1 - num2;
            break;
          case '*':
            result = num1 * num2;
            break;
          case '/':
            result = num1 / num2;
            break;
          default:
            result = 0;
        }

        setState(() {
          _result = '$result';
        });
      } else {
        setState(() {
          _result = '';
        });
      }

      if (_result.isNotEmpty) {
        narration = '$num1 $operator $num2 = $_result $word';
        _controllerNarration.text = narration!;
      } else {
        narration = input;
        _controllerNarration.text = narration!;
      }
    } catch (e) {
      setState(() {
        _result = '';
      });
    }
  }

  getFilterItems(String text) {}
    projectWidget() {
    return isProjectSoftware
        ? SizedBox(
            child: DropdownSearch<dynamic>(
               popupProps: PopupPropsMultiSelection.dialog(
                      isFilterOnline: true,
                      showSearchBox: true,
                      // constraints: BoxConstraints(
                      //   maxHeight: 500,
                      //   minHeight: 200
                      // ),
                      ),
              asyncItems: (String filter) => getProjectListData(filter),
              dropdownDecoratorProps: DropDownDecoratorProps(dropdownSearchDecoration:  InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Select Project')),
              onChanged: (dynamic data) {
                projectId = data.id.toString();
              },
              // showSearchBox: true,
              selectedItem: int.tryParse(projectId!)! > 0
                  ? DataJson(
                      id: int.tryParse(projectId!),
                      name: projectList
                          .firstWhere(
                              (element) => element.id.toString() == projectId,
                              orElse: () => DataJson(id: 0, name: ''))
                          .name)
                  : DataJson(id: 0, name: ''),
            ),
          )
        : Container();
  }
  Future<List<dynamic>> getProjectListData(String filter) async {
    var dd = filter.isEmpty
        ? projectList
        : projectList
            .where((element) => element.name
                .toString()
                .toLowerCase()
                .contains(filter.toLowerCase()))
            .toList();
    List<DataJson> dataResult = [];
    for (var data in dd) {
      dataResult.add(DataJson(id: data.id, name: data.name!.trim().toString()));
    }
    return dataResult;
  }
}
