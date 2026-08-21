import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/customer_model.dart';
import 'package:sheraccerp/models/ledger_name_model.dart';
import 'package:sheraccerp/models/ledger_parent.dart';
import 'package:sheraccerp/models/other_registrations.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/screens/report_view.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/container_textfield_widget.dart';

class LedgerSelect extends StatefulWidget {
  const LedgerSelect({Key? key}) : super(key: key);

  @override
  State<LedgerSelect> createState() => _LedgerSelectState();
}

class _LedgerSelectState extends State<LedgerSelect> {
  TextEditingController editingController = TextEditingController();
  List<dynamic> items = [];
  List<dynamic> itemDisplay = [];
  List<DataJson> projectList = [];
  DioService api = DioService();
bool _loading = true,
      _showQty = false,
      _ob = true,
      _gAll = true,
      isSalesManWiseLedger = false,
      isAdminUser = false,
      isProjectSoftware = false,
      _0b = false;
var _ledger, _id, locationId, _dropDownBranchId;
   String? fromDate,
      toDate,
      sType = 'Summery',
      area = '0',
      route = '0',
      projectId = '0';
  dynamic areaModel, routeModel;
  var statement = '';
  var salesMan = '0';
  var mode = '';
  DateTime now = DateTime.now();
  String radioButtonItem = 'All';
  int rdId = 1, groupId = 0,areaId = 0, routeId = 0;
  String selectedGroupValues = '', selectedStockValue = '';
  dynamic selectedItem;
  List<CompanySettings> settings = [];
  List<OtherRegistrationModel> otherRegAreaDataList = [];
  List<OtherRegistrationModel> otherRegRouteDataList = [];
  List<LedgerModel> cashBankACList = [];
  List<LedgerModel> cashBankACListAll = [];
  var accountId = '', accountName = '';
  List<String> statusType = ['', 'PENDING', 'CLEARED', 'BOUNCED', 'CANCELLED'];
  String dropDownType = '', dropDownStatusType = '';
  bool showProfit = false;
  bool showSalesProfit = false;
  @override
  void initState() {
    super.initState();
    settings = ScopedModel.of<MainModel>(context).getSettings();
    fromDate = DateUtil.datePickerDMY(now);
    toDate = DateUtil.datePickerDMY(now);
    Map arguments = argumentsPass;
    if (locationList.isNotEmpty) {
      _dropDownBranchId = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first;
    }
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
        api.getCashBankAc().then((value) {
      setState(() {
        cashBankACListAll.addAll(value);
      });
    });
   groupId =
        ComSettings.appSettings('int', 'key-dropdown-default-group-view', 0) -
            1;
    areaId =
        ComSettings.appSettings('int', 'key-dropdown-default-area-view', 0) - 1;
    routeId =
        ComSettings.appSettings('int', 'key-dropdown-default-route-view', 0) -
            1;        
    isSalesManWiseLedger =
        ComSettings.getStatus('KEY SALESMAN WISE LEDGER', settings);
    int salesManId = ComSettings.appSettings(
            'int', 'key-dropdown-default-salesman-view', 1) -
        1;
        isAdminUser = 
        companyUserData!.userType.toUpperCase() == 'ADMIN' ? true : false;
    if (!isAdminUser) {
      locationId = ComSettings.appSettings(
              'int', 'key-dropdown-default-location-view', 2) -
          1;
      salesMan = (ComSettings.appSettings(
                  'int', 'key-dropdown-default-salesman-view', 1) -
              1)
          .toString();
      OtherRegistrationModel otherData = otherRegLocationList.firstWhere(
          (element) => element.id == locationId,
          orElse: () => OtherRegistrationModel(
              add1: '',
              add2: '',
              add3: '',
              description: '',
              email: '',
              id: locationId,
              name: defaultLocation,
              type: ''));
      locationId = DataJson(id: otherData.id, name: otherData.name);
    }    


     if (arguments != null) {
      mode = arguments['mode'];
      if (mode == "ledger") {
        _loading = true;
        statement = 'Ledger_Report';
        (isSalesManWiseLedger
                ? api.getLedgerBySalesMan(salesManId)
                : (groupId > 1
                    ? api.getLedgerByGroup(groupId)
                    : api.getLedgerAll()))
            .then((value) {
          setState(() {
            items.addAll(value);
            itemDisplay = items;
          });
        });
      } else if (mode == "billByBill") {
        statement = 'InvoiceWiseBalanceCustomers';
        _loading = false;
      } else if (mode == "DayBook") {
        statement = 'Day_Book';
        _loading = false;
        _ledger = 'CASH';
        _id = 0;
      } else if (mode == "ReceiptList" ||
          mode == 'PaymentList' ||
          mode == 'JournalList') {
        statement = mode;
        _loading = false;
        _ledger = 'CASH';
        _id = 0;
      }else if(mode == "BankReceiptList" ||
       mode == "BankPaymentList"){
        statement = mode;
        _loading = false;
         api.getLedgerGroupAll().then((value) {
          setState(() {
            itemDisplay.addAll(value);
            selectedItem = itemDisplay.firstWhere(
                (element) => element.name == '',
                orElse: (() => {'id': 0, 'name': ''}));
            selectedStockValue = selectedItem.name;
          });
        });
      } else if (mode == "CashBook") {
        statement = 'Ledger_Report';
        _loading = false;
        _ledger = 'CASH';
        _id = 0;
        mode = 'ledger';
        api.getLedger('CASH').then((value) {
          setState(() {
            // items.addAll(value);
            // itemDisplay = items;
            _ledger = value[0]['LedName'];
            _id = value[0]['Ledcode'];
          });
        });
      } else if (mode == "TrialBalance") {
        statement = 'Trial_Balance';
        _loading = false;
        _ledger = 'CASH';
        _id = 0;
      } else if (mode == "CashFlow") {
        api.getLedgerAll().then((value) {
          setState(() {
            items.addAll(value);
            itemDisplay = items;
          });
        });
        statement = 'Cash Flow';
      } else if (mode == "FundFlow") {
        statement = 'Fund Flow';
        _loading = false;
        _ledger = 'CASH';
        _id = 0;
      } else if (mode == "InvoiceWiseBalanceCustomers") {
        statement = 'InvoiceWiseBalanceCustomers';
        _loading = false;
        _ledger = 'CASH';
        _id = 0;
      } else if (mode == "InvoiceWiseBalanceSuppliers") {
        statement = 'InvoiceWiseBalanceSuppliers';
        _loading = false;
        _ledger = 'CASH';
        _id = 0;
      } else if (mode == "GroupList") {
        api.getLedgerGroupAll().then((value) {
          setState(() {
            items.addAll(value);
            itemDisplay = items;
          });
        });
        statement = 'SummeryAll';
        _loading = true;
        _id = 0;
        _ob = false;
      } else if (mode == "LedgerList") {
        _ledger = '';
        statement = 'SummeryAll';
        _loading = false;
        _id = 0;
        _ob = false;
      } else if (mode == "closingReport") {
        statement = 'Closing Report';
        _loading = false;
      } else if (mode == "P&LAccount") {
        statement = 'LAccount';
        _loading = false;
        List<dynamic> groupValues = [
          {'id': '1', 'name': 'Group'},
          {'id': '2', 'name': 'Group & Ledger'}
        ];
        List<dynamic> stockValue = [
          {'id': '1', 'name': 'Prate'},
          {'id': '2', 'name': 'RealPrate'}
        ];
        setState(() {
          items.addAll(groupValues);
          itemDisplay.addAll(stockValue);
          selectedGroupValues = items[0]['name'];
          selectedStockValue = itemDisplay[0]['name'];
        });
      } else if (mode == "BalanceSheet") {
        statement = 'BalanceSheet';
        _loading = false;
        List<dynamic> groupValues = [
          {'id': '1', 'name': 'Group'},
          {'id': '2', 'name': 'Detailed'}
        ];
        List<dynamic> stockValue = [
          {'id': '1', 'name': 'Prate'},
          {'id': '2', 'name': 'RealPrate'}
        ];
        setState(() {
          items.addAll(groupValues);
          itemDisplay.addAll(stockValue);
          selectedGroupValues = items[0]['name'];
          selectedStockValue = itemDisplay[0]['name'];
        });
      } else if (mode == 'Payable') {
        statement = 'ReceivblesCreditOnly';
        _loading = false;
        List<dynamic> groupValues = [
          {'id': '1', 'name': 'Normal'},
          {'id': '2', 'name': 'Invoice Wise'},
          {'id': '3', 'name': 'Detailed'},
          {'id': '4', 'name': 'Due Bill Date'},
        ];
        //  List<dynamic> groupValues = [
        //   {'id': '1', 'name': 'Normal'},
        //   {'id': '2', 'name': 'Invoice Wise'},
        //   {'id': '3', 'name': 'Detailed'},
        //   {'id': '4', 'name': 'Due Bill Date'},
        //   {'id': '5', 'name': 'Due Bills'},
        //   {'id': '6', 'name': 'Ageing Report'},
        //   {'id': '7', 'name': 'Receipt Wise Invoice Balance'},
        //   {'id': '8', 'name': 'Payment Wise Invoice Balance'},
        //   {'id': '9', 'name': 'B2B Customer Balance'},
        //   {'id': '10', 'name': 'Bill Ageing Creditors'},
        //   {'id': '11', 'name': 'Nearly Due Report'},
        // ];
        // List<dynamic> stockValue = [
        //   {'id': '13', 'name': 'SUPPLIERS'},
        //   {'id': '9', 'name': 'ACCOUNTS PAYABLE'}
        // ];
        setState(() {
          items.addAll(groupValues);
          selectedGroupValues = items[0]['name'];
        });
        api.getLedgerGroupAll().then((value) {
          setState(() {
            itemDisplay.addAll(value);
            selectedItem = itemDisplay.firstWhere(
                (element) => element.name == 'SUPPLIERS',
                orElse: (() => {'id': 13, 'name': 'SUPPLIERS'}));
            selectedStockValue = selectedItem.name;
          });
        });
      } else if (mode == 'Receivable') {
        statement = 'ReceivblesDebitOnly';
        _loading = false;
        List<dynamic> groupValues = [
          {'id': '1', 'name': 'Normal'},
          {'id': '2', 'name': 'Invoice Wise'},
          {'id': '3', 'name': 'Detailed'},
          {'id': '4', 'name': 'Due Bill Date'},
          {'id': '5', 'name': 'Due Bills'},
          {'id': '6', 'name': 'Receipt Wise Invoice Balance'},
        ];
        //  List<dynamic> groupValues = [
        //   {'id': '1', 'name': 'Normal'},
        //   {'id': '2', 'name': 'Invoice Wise'},
        //   {'id': '3', 'name': 'Detailed'},
        //   {'id': '4', 'name': 'Due Bill Date'},
        //   {'id': '5', 'name': 'Due Bills'},
        //   {'id': '6', 'name': 'Ageing Report'},
        //   {'id': '7', 'name': 'Receipt Wise Invoice Balance'},
        //   {'id': '8', 'name': 'Payment Wise Invoice Balance'},
        //   {'id': '9', 'name': 'B2B Customer Balance'},
        //   {'id': '10', 'name': 'Bill Ageing Creditors'},
        //   {'id': '11', 'name': 'Nearly Due Report'},
        // ];
        setState(() {
          items.addAll(groupValues);
          selectedGroupValues = items[0]['name'];
        });
        api.getLedgerGroupAll().then((value) {
          setState(() {
            itemDisplay.addAll(value);
            selectedItem = itemDisplay.firstWhere(
                (element) => element.name == 'CUSTOMERS',
                orElse: (() => {'id': 12, 'name': 'CUSTOMERS'}));
            selectedStockValue = selectedItem.name;
          });
        });
      } else if (mode == 'selectedLedger') {
        setState(() {
          _loading = false;
          _ledger = arguments['name'];
          _id = arguments['id'];
          _showQty = true;
          mode = 'ledger';
        });
      }
    }

    if (otherRegAreaList.isNotEmpty) {
      otherRegAreaDataList.addAll(otherRegAreaList);
      if (areaId > 1) {
        areaModel = otherRegAreaDataList.firstWhere(
            (element) => element.id == areaId,
            orElse: () => OtherRegistrationModel.emptyData());
      } else {
        otherRegAreaDataList.add(OtherRegistrationModel.emptyData());
        areaModel = otherRegAreaDataList.last;
      }
    }

    if (otherRegRouteList.isNotEmpty) {
      otherRegRouteDataList.addAll(otherRegRouteList);
      if (routeId > 1) {
        areaModel = otherRegRouteDataList.firstWhere(
            (element) => element.id == routeId,
            orElse: () => OtherRegistrationModel.emptyData());
      } else {
        otherRegRouteDataList.add(OtherRegistrationModel.emptyData());
        routeModel = otherRegRouteDataList.last;
      }
    }
        isProjectSoftware = ComSettings.getStatus('PROJECT SOFTWARE', settings);
    if (isProjectSoftware) {
      api.getProject().then((value) {
        projectList = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                });
              },
              icon: const Icon(Icons.clear))
        ],
        titleTextStyle:
            const TextStyle(fontFamily: 'poppins', 
            fontWeight: FontWeight.w500),
        title: Text(mode == 'ledger'
            ? 'Ledger Report'
            : mode == 'billByBill'
                ? 'Bill By Bill'
                : mode == 'closingReport'
                    ? 'Closing Report'
                    : mode == 'DayBook'
                        ? 'Day Book'
                        : mode == 'TrialBalance'
                            ? 'Trial Balance'
                            : mode == 'CashFlow'
                                ? 'Cash Flow'
                                : mode == 'FundFlow'
                                    ? 'Fund Flow'
                                    : mode == 'InvoiceWiseBalanceCustomers'
                                        ? 'Invoice Wise Balance Customers'
                                        : mode == 'InvoiceWiseBalanceSuppliers'
                                            ? 'Invoice Wise Balance Suppliers'
                                            : mode == 'GroupList'
                                                ? 'Group List'
                                                : mode == 'LedgerList'
                                                    ? 'Ledger List'
                                                    : mode == 'P&LAccount'
                                                        ? 'P&L Account'
                                                        : mode == 'BalanceSheet'
                                                            ? 'Balance Sheet'
                                                            : mode == 'Payable'
                                                                ? 'Payable'
                                                                : mode ==
                                                                        'Receivable'
                                                                    ? 'Receivable'
                                                                    : mode ==
                                                                            'ReceiptList'
                                                                        ? 'Receipt List'
                                                                        : mode ==
                                                                                'PaymentList'
                                                                            ? 'Payment List'
                                                                            : mode == 'JournalList'
                                                                                ? 'Journal List'
                                                                                : mode == 'BankPaymentList'
                                                                                   ? 'Bank Payment List'
                                                                                   : mode == 'BankReceiptList'
                                                                                     ? 'Bank Receipt List'
                                                                                     : 'Select'),
      ),
      body: _loading ? _loadLedger() : _loadWidget(),
    );
  }

  _loadLedger() {
        return Column(
    children: [
      ClipRRect(
        clipBehavior: Clip.antiAlias,
        child: _searchBar(),
      ),
      Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return _listItem(index);
          },
          itemCount: itemDisplay.length,
        ),
      ),
    ],
  );
    // return ListView.builder(
    //   // shrinkWrap: true,
    //   itemBuilder: (context, index) {
    //     return index == 0 ? ClipRRect(
    //       clipBehavior: Clip.antiAlias,
    //       child: _searchBar(),) : _listItem(index - 1);
    //   },
    //   itemCount: itemDisplay.length + 1,
    // );
  }

  var stmtType = 'Closing Report';
var _dropDownValue = '';
  _loadWidget() {
    return mode == "ledger"
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _ledger, 
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: kPrimaryColor,
                      fontSize: 18,
                      fontFamily: 'poppins'),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      const Text(
                        'From ',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            fontFamily: 'poppins'),
                      ),
                      InkWell(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                              border: Border.all(color: grey),
                              borderRadius: BorderRadius.circular(3)),
                          child: Row(
                            children: [
                              Text(
                                fromDate!,
                                style: const TextStyle(
                                    // fontWeight: FontWeight.w500,
                                    // fontSize: 15,
                                    fontFamily: 'poppins'),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              const Icon(
                                Icons.calendar_month_outlined,
                                color: grey,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                        onTap: () => _selectDate('f'),
                      ),
                      const Spacer(),
                      const Text(
                        'To ',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            fontFamily: 'poppins'),
                      ),
                      InkWell(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                              border: Border.all(color: grey),
                              borderRadius: BorderRadius.circular(3)),
                          child: Row(
                            children: [
                              Text(
                                toDate!,
                                style: const TextStyle(
                                    // fontWeight: FontWeight.w500,
                                    // fontSize: 15,
                                    fontFamily: 'poppins'),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              const Icon(
                                Icons.calendar_month_outlined,
                                color: grey,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                        onTap: () => _selectDate('t'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Text(
                      'Opening Balance',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          fontFamily: 'poppins'),
                    ),
                    Checkbox(
                      value: _ob,
                      activeColor: kPrimaryColor,
                      onChanged: (value) {
                        setState(() {
                          _ob = value!;
                        });
                      },
                    ),
                    // const Text(
                    //   'Show Qty',
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.w500,
                    //       fontSize: 15,
                    //       fontFamily: 'poppins'),
                    // ),
                    // Checkbox(
                    //   value: _showQty,
                    //   activeColor: kPrimaryColor,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _showQty = value!;
                    //     });
                    //   },
                    // )
                  ],
                ),
                 const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    const Text(
                      'Show Qty',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          fontFamily: 'poppins'),
                    ),
                    Checkbox(
                      value: _showQty,
                      activeColor: kPrimaryColor,
                      onChanged: (value) {
                        setState(() {
                          _showQty = value!;
                        });
                      },
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                // Card(
                //   elevation: 2,
                //   child: DropDownSettingsTile<int>(
                //     title: 'Branch',
                //     settingKey: 'key-dropdown-default-location-view',
                //     values: locationList.isNotEmpty
                //         ? {for (var e in locationList) e.key + 1: e.value}
                //         : {
                //             2: '',
                //           },
                //     selected: 2,
                //     onChange: (value) {
                //       debugPrint('key-dropdown-default-location-view: $value');
                //       dropDownBranchId = value - 1;
                //     },
                //   ),
                // ),
                Visibility(
                  visible: isAdminUser,
                  child: ContainerFieldWidget(
                      widget: DropdownSearch<dynamic>(
                        popupProps:
                            const PopupPropsMultiSelection.dialog(
                                showSearchBox: true,
                                // constraints: BoxConstraints(
                                //   maxHeight: 300,
                                // )
                                ),
                        asyncItems: (String filter) =>
                            api.getSalesListData(filter, 'sales_list/location'),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                                               contentPadding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8
                      ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        onChanged: (dynamic data) {
                          locationId = data;
                        },
                      ),
                      headTxt: 'Select Branch'),
                ),
                  Visibility(
                    visible: !isAdminUser,
                    child: Row(
                      children: [
                        const Text('Default Branch',
                         style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          fontFamily: 'poppins'),
                        ),
                        Checkbox(
                          value: locationId == null,
                          activeColor: kPrimaryColor,
                          onChanged: (value) {
                            setState(() {
                              locationId = null;
                            });
                          },
                        )
                      ],
                    )),
                const SizedBox(
                  height: 10,
                ),
                projectWidget(),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        statement = _showQty ? 'Ledger_Report_Qty' : statement;
                        List<int> branches = locationId != null
                            ? [locationId.id]
                            : otherRegLocationList.map((e) => e.id).toList();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => ReportView(
                                    _id.toString(),
                                    (_ob ? '1' : '0'),
                                    DateUtil.dateDMY2YMD(fromDate),
                                    DateUtil.dateDMY2YMD(toDate),
                                    'ledger',
                                    _ledger,
                                    statement,
                                    salesMan,
                                    branches,
                                    area!,
                                    route!,
                                   '0')));
                      },
                      style: ButtonStyle(
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(kPrimaryColor),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text(
                        'Show',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            fontFamily: 'poppins'),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                )
              ],
            ),
          )
        : mode == "DayBook"
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ledger,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: kPrimaryColor,
                          fontFamily: 'poppins'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          const Text(
                            'From ',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                fontFamily: 'poppins'),
                          ),
                          InkWell(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)),
                              child: Row(
                                children: [
                                  Text(
                                    fromDate!,
                                    style: const TextStyle(
                                        // fontWeight: FontWeight.w500,
                                        // fontSize: 15,
                                        fontFamily: 'poppins'),
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: grey,
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                            onTap: () => _selectDate('f'),
                          ),
                          const Spacer(),
                          const Text(
                            'To ',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                fontFamily: 'poppins'),
                          ),
                          InkWell(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                  border: Border.all(color: grey),
                                  borderRadius: BorderRadius.circular(3)),
                              child: Row(
                                children: [
                                  Text(
                                    toDate!,
                                    style: const TextStyle(
                                        // fontWeight: FontWeight.w500,
                                        // fontSize: 15,
                                        fontFamily: 'poppins'),
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: grey,
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                            onTap: () => _selectDate('t'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Card(
                    //   elevation: 2,
                    //   child: DropDownSettingsTile<int>(
                    //     title: 'Branch',
                    //     settingKey: 'key-dropdown-default-location-view',
                    //     values: locationList.isNotEmpty
                    //         ? {for (var e in locationList) e.key + 1: e.value}
                    //         : {
                    //             2: '',
                    //           },
                    //     selected: 2,
                    //     onChange: (value) {
                    //       debugPrint(
                    //           'key-dropdown-default-location-view: $value');
                    //       dropDownBranchId = value - 1;
                    //     },
                    //   ),
                    // ),
                    Visibility(
                      visible: isAdminUser,
                      child: ContainerFieldWidget(
                          widget: DropdownSearch<dynamic>(
                            popupProps:
                                const PopupPropsMultiSelection.dialog(
                                    showSearchBox: true,
                                    // constraints: BoxConstraints(
                                    //   maxHeight: 300,
                                    // )
                                    ),
                            asyncItems: (String filter) => api.getSalesListData(
                                filter, 'sales_list/location'),
                            dropdownDecoratorProps: const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                         contentPadding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8
                        ),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            onChanged: (dynamic data) {
                              locationId = data;
                            },
                          ),
                          headTxt: 'Select Branch'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ReportView(
                                            _id.toString(),
                                            (_ob ? '1' : '0'),
                                            DateUtil.dateDMY2YMD(fromDate),
                                            DateUtil.dateDMY2YMD(toDate),
                                            'Day Book',
                                            _ledger,
                                            statement,
                                            salesMan,
                                            locationId != null
                                                ? [locationId.id]
                                                : [_dropDownBranchId],
                                            area!,
                                            route!,
                                            '0')));
                          },
                          style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(kPrimaryColor),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: const Text(
                            'Show',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                fontFamily: 'poppins'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : mode == "TrialBalance"
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      children: [
                        // Text(
                        //   _ledger,
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.bold, fontSize: 18),
                        // ),
                        SizedBox(
                           width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              const Text(
                                'From ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    fontFamily: 'poppins'),
                              ),
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: grey),
                                      borderRadius: BorderRadius.circular(3)),
                                  child: Row(
                                    children: [
                                      Text(
                                        fromDate!,
                                        style: const TextStyle(
                                            // fontWeight: FontWeight.w500,
                                            // fontSize: 15,
                                            fontFamily: 'poppins'),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        color: grey,
                                        size: 20,
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () => _selectDate('f'),
                              ),
                              const Spacer(),
                              const Text(
                                'To ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    fontFamily: 'poppins'),
                              ),
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: grey),
                                      borderRadius: BorderRadius.circular(3)),
                                  child: Row(
                                    children: [
                                      Text(
                                        toDate!,
                                        style: const TextStyle(
                                            // fontWeight: FontWeight.w500,
                                            // fontSize: 15,
                                            fontFamily: 'poppins'),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        color: grey,
                                        size: 20,
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () => _selectDate('t'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // Card(
                        //   elevation: 2,
                        //   child: DropDownSettingsTile<int>(
                        //     title: 'Branch',
                        //     settingKey: 'key-dropdown-default-location-view',
                        //     values: locationList.isNotEmpty
                        //         ? {
                        //             for (var e in locationList)
                        //               e.key + 1: e.value
                        //           }
                        //         : {
                        //             2: '',
                        //           },
                        //     selected: 2,
                        //     onChange: (value) {
                        //       debugPrint(
                        //           'key-dropdown-default-location-view: $value');
                        //       dropDownBranchId = value - 1;
                        //     },
                        //   ),
                        // ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ReportView(
                                            _id.toString(),
                                            (_ob ? '1' : '0'),
                                            DateUtil.dateDMY2YMD(fromDate),
                                            DateUtil.dateDMY2YMD(toDate),
                                            'Trial Balance',
                                            _ledger,
                                            statement,
                                            salesMan,
                                            locationId != null
                                                ? [locationId.id]
                                                : [_dropDownBranchId],
                                            area!,
                                            route!,
                                            '0')));
                          },
                          style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(kPrimaryColor),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: const Text(
                            'Show',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                fontFamily: 'poppins'),
                          ),
                        )
                      ],
                    ),
                  )
                : mode == 'CashFlow'
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _ledger,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: kPrimaryColor,
                                  fontFamily: 'poppins'),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                               width: MediaQuery.of(context).size.width,
                              child: Row(
                                children: [
                                  const Text(
                                    'From ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        fontFamily: 'poppins'),
                                  ),
                                  InkWell(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: grey),
                                          borderRadius: BorderRadius.circular(3)),
                                      child: Row(
                                        children: [
                                          Text(
                                            fromDate!,
                                            style: const TextStyle(
                                                // fontWeight: FontWeight.w500,
                                                // fontSize: 15,
                                                fontFamily: 'poppins'),
                                          ),
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          const Icon(
                                            Icons.calendar_month_outlined,
                                            color: grey,
                                            size: 20,
                                          )
                                        ],
                                      ),
                                    ),
                                    onTap: () => _selectDate('f'),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    'To ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        fontFamily: 'poppins'),
                                  ),
                                  InkWell(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: grey),
                                          borderRadius: BorderRadius.circular(3)),
                                      child: Row(
                                        children: [
                                          Text(
                                            toDate!,
                                            style: const TextStyle(
                                                // fontWeight: FontWeight.w500,
                                                // fontSize: 15,
                                                fontFamily: 'poppins'),
                                          ),
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          const Icon(
                                            Icons.calendar_month_outlined,
                                            color: grey,
                                            size: 20,
                                          )
                                        ],
                                      ),
                                    ),
                                    onTap: () => _selectDate('t'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ReportView(
                                                    _id.toString(),
                                                    (_ob ? '1' : '0'),
                                                    DateUtil.dateDMY2YMD(
                                                        fromDate),
                                                    DateUtil.dateDMY2YMD(
                                                        toDate),
                                                    'Cash Flow',
                                                    _ledger,
                                                    statement,
                                                    salesMan,
                                                    locationId != null
                                                        ? [locationId.id]
                                                        : [_dropDownBranchId],
                                                    area!,
                                                    route!,
                                                    '0')));
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            kPrimaryColor),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                  ),
                                  child: const Text(
                                    'Show',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        fontFamily: 'poppins'),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    : mode == 'FundFlow'
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            child: Column(
                              children: [
                                SizedBox(
                                   width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    children: [
                                      const Text(
                                        'From ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            fontFamily: 'poppins'),
                                      ),
                                      InkWell(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: grey),
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          child: Row(
                                            children: [
                                              Text(
                                                fromDate!,
                                                style: const TextStyle(
                                                    // fontWeight: FontWeight.w500,
                                                    // fontSize: 15,
                                                    fontFamily: 'poppins'),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              const Icon(
                                                Icons.calendar_month_outlined,
                                                color: grey,
                                                size: 20,
                                              )
                                            ],
                                          ),
                                        ),
                                        onTap: () => _selectDate('f'),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'To ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            fontFamily: 'poppins'),
                                      ),
                                      InkWell(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: grey),
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          child: Row(
                                            children: [
                                              Text(
                                                toDate!,
                                                style: const TextStyle(
                                                    // fontWeight: FontWeight.w500,
                                                    // fontSize: 15,
                                                    fontFamily: 'poppins'),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              const Icon(
                                                Icons.calendar_month_outlined,
                                                color: grey,
                                                size: 20,
                                              )
                                            ],
                                          ),
                                        ),
                                        onTap: () => _selectDate('t'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const Text('Show Closing Stock',
                                    style: TextStyle(
                                      fontFamily: 'poppins'
                                    ),),
                                    Checkbox(
                                      value: _ob,
                                      activeColor: kPrimaryColor,
                                      onChanged: (value) {
                                        setState(() {
                                          _ob = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                // Card(
                                //   elevation: 2,
                                //   child: DropDownSettingsTile<int>(
                                //     title: 'Branch',
                                //     settingKey:
                                //         'key-dropdown-default-location-view',
                                //     values: locationList.isNotEmpty
                                //         ? Map.fromIterable(locationList,
                                //             key: (e) => e.key + 1,
                                //             value: (e) => e.value)
                                //         : {
                                //             2: '',
                                //           },
                                //     selected: 2,
                                //     onChange: (value) {
                                //       debugPrint(
                                //           'key-dropdown-default-location-view: $value');
                                //       dropDownBranchId = value - 1;
                                //     },
                                //   ),
                                // ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ReportView(
                                                    _id.toString(),
                                                    (_ob ? '1' : '0'),
                                                    DateUtil.dateDMY2YMD(
                                                        fromDate),
                                                    DateUtil.dateDMY2YMD(
                                                        toDate),
                                                    'Fund Flow',
                                                    _ledger,
                                                    statement,
                                                    salesMan,
                                                    locationId != null
                                                        ? [locationId.id]
                                                        : [_dropDownBranchId],
                                                    area!,
                                                    route!,
                                                    '0')));
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(3))),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            kPrimaryColor),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                  ),
                                  child: const Text(
                                    'Show',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        fontFamily: 'poppins'),
                                  ),
                                )
                              ],
                            ),
                          )
                        : mode == 'InvoiceWiseBalanceCustomers'
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                child: Column(
                                  children: [
                                    SizedBox(
                                       width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        children: [
                                          const Text(
                                            'From ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                fontFamily: 'poppins'),
                                          ),
                                          InkWell(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 5),
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: grey),
                                                  borderRadius:
                                                      BorderRadius.circular(3)),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    fromDate!,
                                                    style: const TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight.w500,
                                                        // fontSize: 15,
                                                        fontFamily: 'poppins'),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  const Icon(
                                                    Icons.calendar_month_outlined,
                                                    color: grey,
                                                    size: 20,
                                                  )
                                                ],
                                              ),
                                            ),
                                            onTap: () => _selectDate('f'),
                                          ),
                                          const Spacer(),
                                          const Text(
                                            'To ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                fontFamily: 'poppins'),
                                          ),
                                          InkWell(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 5),
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: grey),
                                                  borderRadius:
                                                      BorderRadius.circular(3)),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    toDate!,
                                                    style: const TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight.w500,
                                                        // fontSize: 15,
                                                        fontFamily: 'poppins'),
                                                  ),
                                                  const SizedBox(
                                                    width: 2,
                                                  ),
                                                  const Icon(
                                                    Icons.calendar_month_outlined,
                                                    color: grey,
                                                    size: 20,
                                                  )
                                                ],
                                              ),
                                            ),
                                            onTap: () => _selectDate('t'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (BuildContext
                                                        context) =>
                                                    ReportView(
                                                        _id.toString(),
                                                        (_ob ? '1' : '0'),
                                                        DateUtil.dateDMY2YMD(
                                                            fromDate),
                                                        DateUtil.dateDMY2YMD(
                                                            toDate),
                                                        'Invoice Wise Balance Customers',
                                                        _ledger,
                                                        statement,
                                                        salesMan,
                                                        locationId != null
                                                            ? [locationId.id]
                                                            : [
                                                                _dropDownBranchId
                                                              ],
                                                        area!,
                                                        route!,
                                                        '0')));
                                      },
                                      style: ButtonStyle(
                                        shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                kPrimaryColor),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                      ),
                                      child: const Text(
                                        'Show',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            fontFamily: 'poppins'),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : mode == 'InvoiceWiseBalanceSuppliers'
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                           width: MediaQuery.of(context).size.width,
                                          child: Row(
                                            children: [
                                              const Text(
                                                'From ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    fontFamily: 'poppins'),
                                              ),
                                              InkWell(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 5),
                                                  decoration: BoxDecoration(
                                                      border:
                                                          Border.all(color: grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        fromDate!,
                                                        style: const TextStyle(
                                                            // fontWeight:
                                                            //     FontWeight.w500,
                                                            // fontSize: 15,
                                                            fontFamily:
                                                                'poppins'),
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      const Icon(
                                                        Icons
                                                            .calendar_month_outlined,
                                                        color: grey,
                                                        size: 20,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                onTap: () => _selectDate('f'),
                                              ),
                                              const Spacer(),
                                              const Text(
                                                'To ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    fontFamily: 'poppins'),
                                              ),
                                              InkWell(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 5),
                                                  decoration: BoxDecoration(
                                                      border:
                                                          Border.all(color: grey),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3)),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        toDate!,
                                                        style: const TextStyle(
                                                            // fontWeight:
                                                            //     FontWeight.w500,
                                                            // fontSize: 15,
                                                            fontFamily:
                                                                'poppins'),
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      const Icon(
                                                        Icons
                                                            .calendar_month_outlined,
                                                        color: grey,
                                                        size: 20,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                onTap: () => _selectDate('t'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        ReportView(
                                                            _id.toString(),
                                                            (_ob ? '1' : '0'),
                                                            DateUtil
                                                                .dateDMY2YMD(
                                                                    fromDate),
                                                            DateUtil
                                                                .dateDMY2YMD(
                                                                    toDate),
                                                            'Invoice Wise Balance Suppliers',
                                                            _ledger,
                                                            statement,
                                                            salesMan,
                                                            locationId != null
                                                            ? [locationId.id]
                                                            : [
                                                                _dropDownBranchId
                                                              ],
                                                            area!,
                                                            route!,
                                                            '0')));
                                          },
                                          style: ButtonStyle(
                                            shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(kPrimaryColor),
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                          ),
                                          child: const Text(
                                            'Show',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                                fontFamily: 'poppins'),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : mode == 'GroupList'
                                    ? SingleChildScrollView(
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 16),
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  _ledger,
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 18,
                                                      color: kPrimaryColor,
                                                      fontFamily: 'poppins'),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              SizedBox(
                                                 width: MediaQuery.of(context).size.width,
                                                child: Row(
                                                  children: [
                                                    const Text(
                                                      'From ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14,
                                                          fontFamily: 'poppins'),
                                                    ),
                                                    InkWell(
                                                      child: Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 5),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: grey),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(3)),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              fromDate!,
                                                              style: const TextStyle(
                                                                  // fontWeight:
                                                                  //     FontWeight
                                                                  //         .w500,
                                                                  // fontSize: 15,
                                                                  fontFamily:
                                                                      'poppins'),
                                                            ),
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            const Icon(
                                                              Icons
                                                                  .calendar_month_outlined,
                                                              color: grey,
                                                              size: 20,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      onTap: () => _selectDate('f'),
                                                    ),
                                                    const Spacer(),
                                                    const Text(
                                                      'To ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14,
                                                          fontFamily: 'poppins'),
                                                    ),
                                                    InkWell(
                                                      child: Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 5),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: grey),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(3)),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              toDate!,
                                                              style: const TextStyle(
                                                                  // fontWeight:
                                                                  //     FontWeight
                                                                  //         .w500,
                                                                  // fontSize: 15,
                                                                  fontFamily:
                                                                      'poppins'),
                                                            ),
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            const Icon(
                                                              Icons
                                                                  .calendar_month_outlined,
                                                              color: grey,
                                                              size: 20,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      onTap: () => _selectDate('t'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                width: MediaQuery.sizeOf(context)
                                                    .width,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(3),
                                                    border:
                                                        Border.all(color: grey)),
                                                child: Row(
                                                  children: [
                                                    Radio(
                                                      value: 1,
                                                      activeColor: kPrimaryColor,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          rdId = 1;
                                                          radioButtonItem = 'All';
                                                          _gAll = true;
                                                          _ob = false;
                                                          _0b = false;
                                                        });
                                                      },
                                                      groupValue: rdId,
                                                    ),
                                                    const Text(
                                                      'All',
                                                      style: TextStyle(
                                                          // fontWeight:
                                                          //     FontWeight.w500,
                                                          // fontSize: 15,
                                                          fontFamily: 'poppins'),
                                                    ),
                                                    const Spacer(),
                                                    Radio(
                                                      value: 2,
                                                      activeColor: kPrimaryColor,
                                                      groupValue: rdId,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          rdId = 2;
                                                          radioButtonItem =
                                                              'Balance';
                                                          _ob = true;
                                                          _gAll = false;
                                                          _0b = false;
                                                        });
                                                      },
                                                    ),
                                                    const Text(
                                                      'Balance',
                                                      style: TextStyle(
                                                          // fontWeight:
                                                          //     FontWeight.w500,
                                                          // fontSize: 15,
                                                          fontFamily: 'poppins'),
                                                    ),
                                                    const Spacer(),
                                                    Radio(
                                                      value: 3,
                                                      activeColor: kPrimaryColor,
                                                      groupValue: rdId,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          rdId = 3;
                                                          radioButtonItem =
                                                              '0 Balance';
                                                          _0b = true;
                                                          _gAll = false;
                                                          _ob = false;
                                                        });
                                                      },
                                                    ),
                                                    const Text(
                                                      '0 Balance',
                                                      style: TextStyle(
                                                          // fontWeight:
                                                          //     FontWeight.w500,
                                                          // fontSize: 15,
                                                          fontFamily: 'poppins'),
                                                    ),
                                                    const Spacer()
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Visibility(
                                                visible: isAdminUser,
                                                child: ContainerFieldWidget(
                                                    widget: DropdownSearch<dynamic>(
                                                      popupProps:
                                                          const PopupPropsMultiSelection
                                                              .dialog(
                                                              showSearchBox: true,
                                                              // constraints:
                                                              //     BoxConstraints(
                                                              //         maxHeight:
                                                              //             300)
                                                                          ),
                                                      asyncItems: (String filter) =>
                                                          api.getSalesListData(
                                                              filter,
                                                              'sales_list/location'),
                                                      dropdownDecoratorProps:
                                                          const DropDownDecoratorProps(
                                                        dropdownSearchDecoration:
                                                            InputDecoration(
                                                                      contentPadding: EdgeInsets.symmetric(
                                                                      horizontal: 4,
                                                                      vertical: 8
                                                                      ),
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                      ),
                                                      onChanged: (dynamic data) {
                                                        locationId = data;
                                                      },
                                                    ),
                                                    headTxt: 'Select Branch'),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                width: MediaQuery.sizeOf(context)
                                                    .width,
                                                decoration: BoxDecoration(
                                                    border:
                                                        Border.all(color: grey),
                                                    borderRadius:
                                                        BorderRadius.circular(3)),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton(
                                                    isExpanded: true,
                                                    icon: const Icon(Icons
                                                        .keyboard_arrow_down),
                                                    items: [
                                                      'Summery',
                                                      'Simple',
                                                      'Ledger Model',
                                                      'Summery Area Wise',
                                                      'Group & Ledger',
                                                      'PV/RV Report',
                                                      'Salesman Wise Group List',
                                                      'Group List All Groups',
                                                      'Balance Order By Date',
                                                      'Summery Route Wise'
                                                    ].map((String items) {
                                                      return DropdownMenuItem(
                                                        value: items,
                                                        child: Text(items),
                                                      );
                                                    }).toList(),
                                                    value: sType,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sType = value;
                                                        statement = value ==
                                                                'Summery'
                                                            ? 'SummeryAll'
                                                            : value == 'Simple'
                                                                ? 'SimpleGList'
                                                                : value ==
                                                                        'Ledger Model'
                                                                    ? 'Ledger_Model'
                                                                    : value ==
                                                                            'Summery Area Wise'
                                                                        ? 'SummeryAreaWise'
                                                                        : value ==
                                                                               'Summery Route Wise'
                                                                        ? 'SummeryRouteWise'
                                                                            : value ==                                                                                 'Group & Ledger'
                                                                            ? 'Group_Ledger'
                                                                            : value == 'PV/RV Report'
                                                                                ? 'PV/RV Report'
                                                                                : value == 'Salesman Wise Group List'
                                                                                    ? 'SalesmanGroupList'
                                                                                    : value == 'Group List All Groups'
                                                                                        ? 'GroupListAllGroups'
                                                                                        : value == 'Balance Order By Date'
                                                                                            ? 'Balance Order By Date'
                                                                                            : 'SummeryAll';
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  statement = sType == 'Summery'
                                                      ? _gAll
                                                          ? 'SummeryAll'
                                                          : _ob
                                                              ? 'SummeryBalanceOnly'
                                                              : 'SummeryZeroBalanceOnly'
                                                      : statement;
                                                       if (sType ==
                                                    'Summery Route Wise') {
                                                  area = route;
                                                }
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              ReportView(
                                                                  _id.toString(),
                                                                  (_ob ? '1' : '0'),
                                                                  DateUtil
                                                                      .dateDMY2YMD(
                                                                          fromDate),
                                                                  DateUtil
                                                                      .dateDMY2YMD(
                                                                          toDate),
                                                                  'GroupList',
                                                                  _ledger,
                                                                  statement,
                                                                  salesMan,
                                                                  locationId !=
                                                                          null
                                                                      ? [
                                                                          locationId
                                                                              .id
                                                                        ]
                                                                      : [
                                                                          _dropDownBranchId
                                                                        ],
                                                                  area!,
                                                                  route!,
                                                                  '0')));
                                                },
                                                style: ButtonStyle(
                                                  shape: MaterialStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3))),
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(kPrimaryColor),
                                                  foregroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.white),
                                                ),
                                                child: const Text(
                                                  'Show',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 15,
                                                      fontFamily: 'poppins'),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              ContainerFieldWidget(
                                                  widget: Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    padding: const EdgeInsets
                                                        .symmetric(horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: grey),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                3)),
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child: DropdownButton<
                                                          OtherRegistrationModel>(
                                                        isExpanded: true,
                                                        icon: const Icon(Icons.keyboard_arrow_down),
                                                        items: otherRegAreaList.map(
                                                            (OtherRegistrationModel
                                                                items) {
                                                          return DropdownMenuItem<
                                                              OtherRegistrationModel>(
                                                            value: items,
                                                            child:
                                                                Text(items.name),
                                                          );
                                                        }).toList(),
                                                        value: areaModel,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            areaModel = value;
                                                            area = value!.id
                                                                .toString();
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  headTxt: 'Select Area'),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              ContainerFieldWidget(
                                                  widget: Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    padding: const EdgeInsets
                                                        .symmetric(horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: grey),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                3)),
                                                    child:
                                                        DropdownButtonHideUnderline(
                                                      child: DropdownButton<
                                                      OtherRegistrationModel>(
                                                    icon: const Icon(Icons
                                                        .keyboard_arrow_down),
                                                    items: otherRegRouteDataList
                                                        .map(
                                                            (OtherRegistrationModel
                                                                items) {
                                                      return DropdownMenuItem<
                                                          OtherRegistrationModel>(
                                                        value: items,
                                                        child: Text(items.name),
                                                      );
                                                    }).toList(),
                                                    value: routeModel,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        routeModel = value;
                                                        route =
                                                            value!.id.toString();
                                                      });
                                                    },
                                                  ),
                                                    ),
                                                  ),
                                                  headTxt: 'Select Route'),
                                                  Visibility(
                                                                      visible: isAdminUser,
                                                                      child: ContainerFieldWidget(
                                                                          widget: DropdownSearch<
                                                                              dynamic>(
                                                                            popupProps: const PopupPropsMultiSelection
                                                                                .dialog(
                                                                                showSearchBox: true,
                                                                                // constraints: BoxConstraints(maxHeight: 300)
                                                                                ),
                                                                            asyncItems: (String filter) => api.getSalesListData(
                                                                                filter,
                                                                                'sales_list/salesMan'),
                                                                            dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration:
                                                                                  InputDecoration(
                                                                                                           contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                            ),
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                            onChanged:
                                                                                (dynamic data) {
                                                                              salesMan =
                                                                                  data.id.toString();
                                                                            },
                                                                          ),
                                                                          headTxt:
                                                                              'Select Salesman'),
                                                                    ),
                                            ],
                                          ),
                                        ),
                                    )
                                    : mode == 'LedgerList'
                                        ? const Center(child: Text('empty'))
                                        : mode == 'closingReport'
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 16),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                       width: MediaQuery.of(context).size.width,
                                                      child: Row(
                                                        children: [
                                                          const Text(
                                                            'From ',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'poppins'),
                                                          ),
                                                          InkWell(
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          5),
                                                              decoration: BoxDecoration(
                                                                  border:
                                                                      Border.all(
                                                                          color:
                                                                              grey),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3)),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    fromDate!,
                                                                    style: const TextStyle(
                                                                        // fontWeight:
                                                                        //     FontWeight
                                                                        //         .w500,
                                                                        // fontSize:
                                                                        //     15,
                                                                        fontFamily:
                                                                            'poppins'),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  const Icon(
                                                                    Icons
                                                                        .calendar_month_outlined,
                                                                    color: grey,
                                                                    size: 20,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            onTap: () =>
                                                                _selectDate('f'),
                                                          ),
                                                          const Spacer(),
                                                          const Text(
                                                            'To ',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'poppins'),
                                                          ),
                                                          InkWell(
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          5),
                                                              decoration: BoxDecoration(
                                                                  border:
                                                                      Border.all(
                                                                          color:
                                                                              grey),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3)),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    toDate!,
                                                                    style: const TextStyle(
                                                                        // fontWeight:
                                                                        //     FontWeight
                                                                        //         .w500,
                                                                        // fontSize:
                                                                        //     15,
                                                                        fontFamily:
                                                                            'poppins'),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  const Icon(
                                                                    Icons
                                                                        .calendar_month_outlined,
                                                                    color: grey,
                                                                    size: 20,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            onTap: () =>
                                                                _selectDate('t'),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      width: MediaQuery.sizeOf(
                                                              context)
                                                          .width,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: grey),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3)),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                          isExpanded: true,
                                                          icon: const Icon(Icons
                                                              .keyboard_arrow_down),
                                                          items: [
                                                            'Closing Report',
                                                            'Style1',
                                                            'Style2',
                                                            'Style4',
                                                            'Style5',
                                                            'Daily Sheet',
                                                            'Daily / Monthly',
                                                            'AsperMart'
                                                          ].map((String items) {
                                                            return DropdownMenuItem(
                                                              value: items,
                                                              child:
                                                                  Text(items),
                                                            );
                                                          }).toList(),
                                                          value: stmtType,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              stmtType = value!;
                                                              statement = value;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Visibility(
                                                      visible: isAdminUser,
                                                      child: ContainerFieldWidget(
                                                          widget: DropdownSearch<
                                                              dynamic>(
                                                            popupProps: const PopupPropsMultiSelection
                                                                .dialog(
                                                                showSearchBox:
                                                                    true,
                                                                // constraints:
                                                                //     BoxConstraints(
                                                                //   maxHeight: 300,
                                                                // )
                                                                ),
                                                            asyncItems: (String
                                                                    filter) =>
                                                                api.getSalesListData(
                                                                    filter,
                                                                    'sales_list/location'),
                                                            dropdownDecoratorProps:
                                                                const DropDownDecoratorProps(
                                                              dropdownSearchDecoration:
                                                                  InputDecoration(
                                                                            contentPadding: EdgeInsets.symmetric(
                                                                            horizontal: 4,
                                                                            vertical: 8
                                                                            ),
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                            ),
                                                            onChanged:
                                                                (dynamic data) {
                                                              locationId = data;
                                                            },
                                                          ),
                                                          headTxt:
                                                              'Select Branch'),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                     Container(
                                                      margin: const EdgeInsets.only(bottom: 16),
                                                      padding: const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade50,
                                                        borderRadius: BorderRadius.circular(16),
                                                        border: Border.all(color: Colors.grey.shade200),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          // Container(
                                                          //   padding: const EdgeInsets.all(8),
                                                          //   decoration: BoxDecoration(
                                                          //     color: kPrimaryColor.withOpacity(0.1),
                                                          //     borderRadius: BorderRadius.circular(12),
                                                          //   ),
                                                          //   child: const Icon(
                                                          //     Icons.person_2_rounded,
                                                          //     size: 20,
                                                          //     color: kPrimaryColor,
                                                          //   ),
                                                          // ),
                                                          const SizedBox(width: 12),
                                                          Expanded(
                                                            child: const Text(
                                                              'Show Profit',
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                fontFamily: 'poppins',
                                                                // fontSize: 14,
                                                                // fontWeight: FontWeight.w600,
                                                                color: Colors.black87,
                                                              ),
                                                            ),
                                                          ),
                                                          Switch(
                                                            value: showProfit,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                showProfit = value;
                                                                // defaultChanges = true;
                                                              });
                                                            },
                                                            activeColor: kPrimaryColor,
                                                            activeTrackColor: kPrimaryColor.withOpacity(0.3),
                                                            inactiveThumbColor: Colors.grey.shade400,
                                                            inactiveTrackColor: Colors.grey.shade200,
                                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 16),
                                                      padding: const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade50,
                                                        borderRadius: BorderRadius.circular(16),
                                                        border: Border.all(color: Colors.grey.shade200),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          // Container(
                                                          //   padding: const EdgeInsets.all(8),
                                                          //   decoration: BoxDecoration(
                                                          //     color: kPrimaryColor.withOpacity(0.1),
                                                          //     borderRadius: BorderRadius.circular(12),
                                                          //   ),
                                                          //   child: const Icon(
                                                          //     Icons.person_2_rounded,
                                                          //     size: 20,
                                                          //     color: kPrimaryColor,
                                                          //   ),
                                                          // ),
                                                          const SizedBox(width: 12),
                                                          Expanded(
                                                            child: const Text(
                                                              'Show Sales Profit',
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                fontFamily: 'poppins',
                                                                // fontSize: 14,
                                                                // fontWeight: FontWeight.w600,
                                                                color: Colors.black87,
                                                              ),
                                                            ),
                                                          ),
                                                          Switch(
                                                            value: showSalesProfit,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                showSalesProfit = value;
                                                                // defaultChanges = true;
                                                              });
                                                            },
                                                            activeColor: kPrimaryColor,
                                                            activeTrackColor: kPrimaryColor.withOpacity(0.3),
                                                            inactiveThumbColor: Colors.grey.shade400,
                                                            inactiveTrackColor: Colors.grey.shade200,
                                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (BuildContext context) => ReportView(
                                                                    '0',
                                                                    (_ob ? '1': '0'),
                                                                    DateUtil.dateDMY2YMD(
                                                                        fromDate),
                                                                    DateUtil.dateDMY2YMD(
                                                                        toDate),
                                                                    'Closing Report',
                                                                      locationId != null
                                                                      ? locationId.name
                                                                      :'',
                                                                    statement,
                                                                    salesMan,
                                                                    locationId !=
                                                                            null
                                                                        ? [
                                                                            locationId.id
                                                                          ]
                                                                        : [
                                                                            0
                                                                          ],
                                                                   showProfit ? '1' : '0',// area!,
                                                                   showSalesProfit ? '1' : '0', // route!,
                                                                    '0')));
                                                      },
                                                      style: ButtonStyle(
                                                        shape:
                                                            MaterialStatePropertyAll(
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    kPrimaryColor),
                                                        foregroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                                    Colors
                                                                        .white),
                                                      ),
                                                      child: const Text(
                                                        'Show',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 15,
                                                            fontFamily:
                                                                'poppins'),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : mode == 'P&LAccount'
                                                ? Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 16),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'From ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'poppins'),
                                                            ),
                                                            InkWell(
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        5),
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color:
                                                                            grey),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            3)),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      fromDate!,
                                                                      style: const TextStyle(
                                                                          // fontWeight: FontWeight
                                                                          //     .w500,
                                                                          // fontSize:
                                                                          //     15,
                                                                          fontFamily:
                                                                              'poppins'),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    const Icon(
                                                                      Icons
                                                                          .calendar_month_outlined,
                                                                      color:
                                                                          grey,
                                                                      size: 20,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              onTap: () =>
                                                                  _selectDate(
                                                                      'f'),
                                                            ),
                                                            const Spacer(),
                                                            const Text(
                                                              'To ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'poppins'),
                                                            ),
                                                            InkWell(
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        5),
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color:
                                                                            grey),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            3)),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      toDate!,
                                                                      style: const TextStyle(
                                                                          // fontWeight: FontWeight
                                                                          //     .w500,
                                                                          // fontSize:
                                                                          //     15,
                                                                          fontFamily:
                                                                              'poppins'),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 2,
                                                                    ),
                                                                    const Icon(
                                                                      Icons
                                                                          .calendar_month_outlined,
                                                                      color:
                                                                          grey,
                                                                      size: 20,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              onTap: () =>
                                                                  _selectDate(
                                                                      't'),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        // const Text(
                                                        //     'Report Type      '),

                                                        ContainerFieldWidget(
                                                            widget: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                              width: MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width,
                                                              decoration: BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                          color:
                                                                              grey),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3)),
                                                              child:
                                                                  DropdownButtonHideUnderline(
                                                                child:
                                                                    DropdownButton(
                                                                        isExpanded:
                                                                            true,
                                                                        items: items.map((dynamic
                                                                            items) {
                                                                          return DropdownMenuItem(
                                                                            value:
                                                                                items['name'].toString(),
                                                                            child:
                                                                                Text(items['name'].toString()),
                                                                          );
                                                                        }).toList(),
                                                                        value:
                                                                            selectedGroupValues,
                                                                        onChanged:
                                                                            ((value) {
                                                                          setState(
                                                                              () {
                                                                            selectedGroupValues =
                                                                                value!;
                                                                          });
                                                                        })),
                                                              ),
                                                            ),
                                                            headTxt:
                                                                'Report Type'),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        ContainerFieldWidget(
                                                            widget: Container(
                                                              width: MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                              decoration: BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                          color:
                                                                              grey),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3)),
                                                              child:
                                                                  DropdownButtonHideUnderline(
                                                                child:
                                                                    DropdownButton(
                                                                        isExpanded:
                                                                            true,
                                                                        items: itemDisplay.map((dynamic
                                                                            items) {
                                                                          return DropdownMenuItem(
                                                                            value:
                                                                                items['name'].toString(),
                                                                            child:
                                                                                Text(items['name'].toString()),
                                                                          );
                                                                        }).toList(),
                                                                        value:
                                                                            selectedStockValue,
                                                                        onChanged:
                                                                            ((value) {
                                                                          setState(
                                                                              () {
                                                                            selectedStockValue =
                                                                                value!;
                                                                          });
                                                                        })),
                                                              ),
                                                            ),
                                                            headTxt:
                                                                'Stock Valuation'),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (BuildContext context) => ReportView(
                                                                        '0',
                                                                        (_ob ? '1' : '0'),
                                                                        DateUtil.dateDMY2YMD(
                                                                            fromDate),
                                                                        DateUtil.dateDMY2YMD(
                                                                            toDate),
                                                                        'P&L Account',
                                                                        selectedStockValue,
                                                                        selectedGroupValues,
                                                                        salesMan,
                                                                        locationId !=
                                                                                null
                                                                            ? [
                                                                                locationId.id
                                                                              ]
                                                                            : [
                                                                                _dropDownBranchId
                                                                              ],
                                                                        area!,
                                                                        route!,
                                                                        '0')));
                                                          },
                                                          style: ButtonStyle(
                                                            shape:
                                                                MaterialStatePropertyAll(
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                              ),
                                                            ),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(
                                                                        kPrimaryColor),
                                                            foregroundColor:
                                                                MaterialStateProperty
                                                                    .all<Color>(
                                                                        Colors
                                                                            .white),
                                                          ),
                                                          child: const Text(
                                                            'Show',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 15,
                                                                fontFamily:
                                                                    'poppins'),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : mode == 'BalanceSheet'
                                                    ? Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 20,
                                                                vertical: 16),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                const Text(
                                                                  'From ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          'poppins'),
                                                                ),
                                                                InkWell(
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            5),
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                grey),
                                                                        borderRadius:
                                                                            BorderRadius.circular(3)),
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          fromDate!,
                                                                          style: const TextStyle(
                                                                              // fontWeight: FontWeight.w500,
                                                                              // fontSize: 15,
                                                                              fontFamily: 'poppins'),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        const Icon(
                                                                          Icons
                                                                              .calendar_month_outlined,
                                                                          color:
                                                                              grey,
                                                                          size:
                                                                              20,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  onTap: () =>
                                                                      _selectDate(
                                                                          'f'),
                                                                ),
                                                                const Spacer(),
                                                                const Text(
                                                                  'To ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          'poppins'),
                                                                ),
                                                                InkWell(
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            5),
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                grey),
                                                                        borderRadius:
                                                                            BorderRadius.circular(3)),
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          toDate!,
                                                                          style: const TextStyle(
                                                                              // fontWeight: FontWeight.w500,
                                                                              // fontSize: 15,
                                                                              fontFamily: 'poppins'),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        const Icon(
                                                                          Icons
                                                                              .calendar_month_outlined,
                                                                          color:
                                                                              grey,
                                                                          size:
                                                                              20,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  onTap: () =>
                                                                      _selectDate(
                                                                          't'),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            ContainerFieldWidget(
                                                                widget:
                                                                    Container(
                                                                  width: MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color:
                                                                              grey),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              3)),
                                                                  child:
                                                                      DropdownButtonHideUnderline(
                                                                    child: DropdownButton(
                                                                        isExpanded: true,
                                                                        items: items.map((dynamic items) {
                                                                          return DropdownMenuItem(
                                                                            value:
                                                                                items['name'].toString(),
                                                                            child:
                                                                                Text(items['name'].toString()),
                                                                          );
                                                                        }).toList(),
                                                                        value: selectedGroupValues,
                                                                        onChanged: ((value) {
                                                                          setState(
                                                                              () {
                                                                            selectedGroupValues =
                                                                                value!;
                                                                          });
                                                                        })),
                                                                  ),
                                                                ),
                                                                headTxt:
                                                                    'Report Type'),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            ContainerFieldWidget(
                                                                widget:
                                                                    Container(
                                                                  width: MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color:
                                                                              grey),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              3)),
                                                                  child:
                                                                      DropdownButtonHideUnderline(
                                                                    child: DropdownButton(
                                                                        isExpanded: true,
                                                                        items: itemDisplay.map((dynamic items) {
                                                                          return DropdownMenuItem(
                                                                            value:
                                                                                items['name'].toString(),
                                                                            child:
                                                                                Text(items['name'].toString()),
                                                                          );
                                                                        }).toList(),
                                                                        value: selectedStockValue,
                                                                        onChanged: ((value) {
                                                                          setState(
                                                                              () {
                                                                            selectedStockValue =
                                                                                value!;
                                                                          });
                                                                        })),
                                                                  ),
                                                                ),
                                                                headTxt:
                                                                    'Stock Valuation'),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (BuildContext context) => ReportView(
                                                                            '0',
                                                                            (_ob ? '1' : '0'),
                                                                            DateUtil.dateDMY2YMD(
                                                                                fromDate),
                                                                            DateUtil.dateDMY2YMD(
                                                                                toDate),
                                                                            'BalanceSheet',
                                                                            selectedStockValue,
                                                                            selectedGroupValues,
                                                                            salesMan,
                                                                            locationId != null
                                                                                ? [
                                                                                    locationId.id
                                                                                  ]
                                                                                : [
                                                                                    _dropDownBranchId
                                                                                  ],
                                                                            area!,
                                                                            route!,
                                                                            '0')));
                                                              },
                                                              style:
                                                                  ButtonStyle(
                                                                shape:
                                                                    MaterialStatePropertyAll(
                                                                  RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                  ),
                                                                ),
                                                                backgroundColor:
                                                                    MaterialStateProperty.all<
                                                                            Color>(
                                                                        kPrimaryColor),
                                                                foregroundColor:
                                                                    MaterialStateProperty.all<
                                                                            Color>(
                                                                        Colors
                                                                            .white),
                                                              ),
                                                              child: const Text(
                                                                'Show',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        15,
                                                                    fontFamily:
                                                                        'poppins'),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    : mode == 'Payable' ||
                                                            mode == 'Receivable'
                                                        ? Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        16),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Text(
                                                                      'From ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          fontSize:
                                                                              14,
                                                                          fontFamily:
                                                                              'poppins'),
                                                                    ),
                                                                    InkWell(
                                                                      child:
                                                                          Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                8,
                                                                            vertical:
                                                                                5),
                                                                        decoration: BoxDecoration(
                                                                            border:
                                                                                Border.all(color: grey),
                                                                            borderRadius: BorderRadius.circular(3)),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Text(
                                                                              fromDate!,
                                                                              style: const TextStyle(
                                                                                // fontWeight: FontWeight.w500,
                                                                                //  fontSize: 15, 
                                                                                 fontFamily: 'poppins'),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 2,
                                                                            ),
                                                                            const Icon(
                                                                              Icons.calendar_month_outlined,
                                                                              color: grey,
                                                                              size: 20,
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      onTap: () =>
                                                                          _selectDate(
                                                                              'f'),
                                                                    ),
                                                                    const Spacer(),
                                                                    const Text(
                                                                      'To ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          fontSize:
                                                                              14,
                                                                          fontFamily:
                                                                              'poppins'),
                                                                    ),
                                                                    InkWell(
                                                                      child:
                                                                          Container(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                8,
                                                                            vertical:
                                                                                5),
                                                                        decoration: BoxDecoration(
                                                                            border:
                                                                                Border.all(color: grey),
                                                                            borderRadius: BorderRadius.circular(3)),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Text(
                                                                              toDate!,
                                                                              style: const TextStyle(
                                                                                // fontWeight: FontWeight.w500,
                                                                                //  fontSize: 15, 
                                                                                 fontFamily: 'poppins'),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 2,
                                                                            ),
                                                                            const Icon(
                                                                              Icons.calendar_month_outlined,
                                                                              color: grey,
                                                                              size: 20,
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      onTap: () =>
                                                                          _selectDate(
                                                                              't'),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                ContainerFieldWidget(
                                                                    widget:
                                                                        Container(
                                                                      width: MediaQuery.sizeOf(
                                                                              context)
                                                                          .width,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              5),
                                                                      decoration: BoxDecoration(
                                                                          border: Border.all(
                                                                              color:
                                                                                  grey),
                                                                          borderRadius:
                                                                              BorderRadius.circular(3)),
                                                                      child:
                                                                          DropdownButtonHideUnderline(
                                                                        child: DropdownButton(
                                                                            isExpanded: true,
                                                                            items: items.map((dynamic items) {
                                                                              return DropdownMenuItem(
                                                                                value: items['name'].toString(),
                                                                                child: Text(items['name'].toString()),
                                                                              );
                                                                            }).toList(),
                                                                            value: selectedGroupValues,
                                                                            onChanged: ((value) {
                                                                              setState(() {
                                                                                selectedGroupValues = value!;
                                                                              });
                                                                            })),
                                                                      ),
                                                                    ),
                                                                    headTxt:
                                                                        'ReportType'),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                ContainerFieldWidget(
                                                                    widget: itemDisplay
                                                                            .isEmpty
                                                                        ? Container(
                                                                            width:
                                                                                MediaQuery.sizeOf(context).width,
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 3),
                                                                            decoration:
                                                                                BoxDecoration(border: Border.all(color: grey), borderRadius: BorderRadius.circular(3)),
                                                                            child:
                                                                                DropdownButtonHideUnderline(
                                                                              child: DropdownButton(
                                                                                  isExpanded: true,
                                                                                  items: [
                                                                                    LedgerParent(id: 12, name: 'CUSTOMERS'),
                                                                                  ].map((dynamic items) {
                                                                                    return DropdownMenuItem(
                                                                                      value: items,
                                                                                      child: Text(items.name.toString()),
                                                                                    );
                                                                                  }).toList(),
                                                                                  value: selectedItem,
                                                                                  onChanged: ((value) {
                                                                                    setState(() {
                                                                                      selectedItem = value;
                                                                                    });
                                                                                  })),
                                                                            ),
                                                                          )
                                                                        : Container(
                                                                            width:
                                                                                MediaQuery.sizeOf(context).width,
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 3),
                                                                            decoration:
                                                                                BoxDecoration(border: Border.all(color: grey), borderRadius: BorderRadius.circular(3)),
                                                                            child:
                                                                                DropdownButtonHideUnderline(
                                                                              child: DropdownButton(
                                                                                  isExpanded: true,
                                                                                  items: itemDisplay.map((dynamic items) {
                                                                                    return DropdownMenuItem(
                                                                                      value: items,
                                                                                      child: Text(items.name.toString()),
                                                                                    );
                                                                                  }).toList(),
                                                                                  value: selectedItem,
                                                                                  onChanged: ((value) {
                                                                                    setState(() {
                                                                                      selectedItem = value;
                                                                                    });
                                                                                  })),
                                                                            ),
                                                                          ),
                                                                    headTxt:
                                                                        'Group'),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                 ContainerFieldWidget(widget:  DropdownSearch<
                                                                    dynamic>(
                                                                  popupProps: const PopupPropsMultiSelection
                                                                                .dialog(
                                                                                showSearchBox: true,
                                                                                // constraints: BoxConstraints(
                                                                                //   maxHeight: 300,
                                                                                // )
                                                                                ),
                                                                                 asyncItems: (String filter) => api.getSalesListData(
                                                                          filter,
                                                                          'sales_list/customer'),
                                                                  // onFind: (String
                                                                  //         filter) =>
                                                                  //     api.getSalesListData(
                                                                  //         filter,
                                                                  //         'sales_list/customer'),
                                                                   dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration:
                                                                                  InputDecoration(
                                                                                                           contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                            ),
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                  onChanged:
                                                                      (dynamic
                                                                          data) {
                                                                    // _ledger = itemDisplay[index].name;
                                                                    // _id = itemDisplay[index].id;
                                                                    // customer = data;
                                                                    _id =
                                                                        data.id;
                                                                  },
                                                                  // showSearchBox:
                                                                  //     true,
                                                                ), headTxt: 'Select Customer'),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                 Visibility(
                                                                      visible: isAdminUser,
                                                                      child: ContainerFieldWidget(
                                                                          widget: DropdownSearch<
                                                                              dynamic>(
                                                                            popupProps: const PopupPropsMultiSelection
                                                                                .dialog(
                                                                                showSearchBox: true,
                                                                                // constraints: BoxConstraints(maxHeight: 300)
                                                                                ),
                                                                            asyncItems: (String filter) => api.getSalesListData(
                                                                                filter,
                                                                                'sales_list/salesMan'),
                                                                            dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration:
                                                                                  InputDecoration(
                                                                                                           contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                            ),
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                            onChanged:
                                                                                (dynamic data) {
                                                                              salesMan =
                                                                                  data.id.toString();
                                                                            },
                                                                          ),
                                                                          headTxt:
                                                                              'Select Salesman'),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                // const Divider(),
                                                                ContainerFieldWidget(widget:DropdownSearch<
                                                                    dynamic>(
                                                                  popupProps: const PopupPropsMultiSelection
                                                                                .dialog(
                                                                                showSearchBox: true,
                                                                                // constraints: BoxConstraints(
                                                                                //   maxHeight: 300,
                                                                                // )
                                                                                ),
                                                                                asyncItems: (String filter) => api.getSalesListData(
                                                                          filter,
                                                                          'sales_list/location'),
                                                                  // onFind: (String
                                                                  //         filter) =>
                                                                  //     api.getSalesListData(
                                                                  //         filter,
                                                                  //         'sales_list/location'),
                                                                  dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration:
                                                                                  InputDecoration(
                                                                                                           contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                            ),
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                  onChanged:
                                                                      (dynamic
                                                                          data) {
                                                                    locationId =
                                                                        data;
                                                                  },
                                                                  // showSearchBox:
                                                                  //     true,
                                                                ),headTxt: 'Select Location',),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                        statement = mode ==
                                                                            'Payable'
                                                                        ? selectedGroupValues ==
                                                                                'Invoice Wise'
                                                                            ? 'InvoiceWiseBalanceSuppliers'
                                                                            : selectedGroupValues == 'Detailed'
                                                                                ? 'Receivable_Details'
                                                                                : selectedGroupValues == 'Due Bill Date'
                                                                                    ? 'DueBillBalance_Report'
                                                                                    : selectedGroupValues == 'Due Bills'
                                                                                        ? 'DueBills_Receivable'
                                                                                        : selectedGroupValues == 'Ageing Report'
                                                                                            ? 'Receivable_Ageing'
                                                                                            : selectedGroupValues == 'Receipt Wise Invoice Balance'
                                                                                                ? 'ReceiptWiseCustomerbalance'
                                                                                                : selectedGroupValues == 'Payment Wise Invoice Balance'
                                                                                                    ? 'PaymentWiseSupplierbalance'
                                                                                                    : selectedGroupValues == 'B2B Customer Balance'
                                                                                                        ? 'B2B_Customer_Balance'
                                                                                                        : selectedGroupValues == 'Bill Ageing Creditors'
                                                                                                            ? 'Bill_Ageing_Creditors'
                                                                                                            : selectedGroupValues == 'Nearly Due Report'
                                                                                                                ? 'Nearly_Due_Report'
                                                                                                                : 'ReceivblesCreditOnly'
                                                                        : selectedGroupValues == 'Invoice Wise'
                                                                            ? 'InvoiceWiseBalanceCustomers'
                                                                            : selectedGroupValues == 'Detailed'
                                                                                ? 'Receivable_Master_Detail'
                                                                                : selectedGroupValues == 'Due Bill Date'
                                                                                    ? 'DueBillBalance_Report'
                                                                                    : selectedGroupValues == 'Due Bills'
                                                                                        ? 'DueBills_Receivable'
                                                                                        : selectedGroupValues == 'Ageing Report'
                                                                                            ? 'DueBills_Receivable'
                                                                                            : selectedGroupValues == 'Receipt Wise Invoice Balance'
                                                                                                ? 'ReceiptWiseCustomerbalance'
                                                                                                : selectedGroupValues == 'Payment Wise Invoice Balance'
                                                                                                    ? 'DueBills_Receivable'
                                                                                                    : selectedGroupValues == 'B2B Customer Balance'
                                                                                                        ? 'DueBills_Receivable'
                                                                                                        : selectedGroupValues == 'Bill Ageing Creditors'
                                                                                                            ? 'DueBills_Receivable'
                                                                                                            : selectedGroupValues == 'Nearly Due Report'
                                                                                                                ? 'DueBills_Receivable'
                                                                                                                : 'ReceivblesDebitOnly';
                                                                    // statement = mode ==
                                                                    //         'Payable'
                                                                    //     ? selectedGroupValues ==
                                                                    //             'Invoice Wise'
                                                                    //         ? 'InvoiceWiseBalanceSuppliers'
                                                                    //         : selectedGroupValues == 'Detailed'
                                                                    //             ? 'Receivable_Details'
                                                                    //             : selectedGroupValues == 'Due Bill Date'
                                                                    //                 ? 'DueBillBalance_Report'
                                                                    //                 : 'ReceivblesCreditOnly'
                                                                    //     : selectedGroupValues == 'Invoice Wise'
                                                                    //         ? 'InvoiceWiseBalanceCustomers'
                                                                    //         : selectedGroupValues == 'Detailed'
                                                                    //             ? 'Receivable_Master_Detail'
                                                                    //             : selectedGroupValues == 'Due Bill Date'
                                                                    //                 ? 'DueBillBalance_Report'
                                                                    //                 : 'ReceivblesDebitOnly';

                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (BuildContext context) => ReportView(
                                                                                selectedGroupValues == 'Due Bills' ? (_id != null ? _id.toString() : '0') : selectedItem.id.toString(),
                                                                                (_ob ? '1' : '0'),
                                                                                DateUtil.dateDMY2YMD(fromDate),
                                                                                DateUtil.dateDMY2YMD(toDate),
                                                                                mode,
                                                                                selectedItem.name,
                                                                                statement,
                                                                                salesMan,
                                                                                locationId != null ? [locationId.id] : [_dropDownBranchId],
                                                                                area!,
                                                                                route!,
                                                                                _id != null ? _id.toString() : '0')));
                                                                  },
                                                                  style:
                                                                      ButtonStyle(
                                                                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5))),
                                                                    backgroundColor:
                                                                        MaterialStateProperty.all<Color>(
                                                                            kPrimaryColor),
                                                                    foregroundColor: MaterialStateProperty.all<
                                                                            Color>(
                                                                        Colors
                                                                            .white),
                                                                  ),
                                                                  child:
                                                                      const Text(
                                                                    'Show',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            15,
                                                                        fontFamily:
                                                                            'poppins'),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        : mode == 'PaymentList' ||
                                                                mode ==
                                                                    'ReceiptList'
                                                            ? Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        16),
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                       width: MediaQuery.of(context).size.width,
                                                                      child: Row(
                                                                        children: [
                                                                          const Text(
                                                                            'From ',
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 14,
                                                                                fontFamily: 'poppins'),
                                                                          ),
                                                                          InkWell(
                                                                            child:
                                                                                Container(
                                                                              padding:
                                                                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                                              decoration:
                                                                                  BoxDecoration(border: Border.all(color: grey), borderRadius: BorderRadius.circular(3)),
                                                                              child:
                                                                                  Row(
                                                                                children: [
                                                                                  Text(
                                                                                    fromDate!,
                                                                                    style: const TextStyle(
                                                                                      // fontWeight: FontWeight.w500,
                                                                                      //  fontSize: 15,
                                                                                        fontFamily: 'poppins'),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 2,
                                                                                  ),
                                                                                  const Icon(
                                                                                    Icons.calendar_month_outlined,
                                                                                    color: grey,
                                                                                    size: 20,
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            onTap: () =>
                                                                                _selectDate('f'),
                                                                          ),
                                                                          const Spacer(),
                                                                          const Text(
                                                                            'To ',
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 14,
                                                                                fontFamily: 'poppins'),
                                                                          ),
                                                                          InkWell(
                                                                            child:
                                                                                Container(
                                                                              padding:
                                                                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                                              decoration:
                                                                                  BoxDecoration(border: Border.all(color: grey), borderRadius: BorderRadius.circular(3)),
                                                                              child:
                                                                                  Row(
                                                                                children: [
                                                                                  Text(
                                                                                    toDate!,
                                                                                    style: const TextStyle(
                                                                                      // fontWeight: FontWeight.w500,
                                                                                      //  fontSize: 15, 
                                                                                       fontFamily: 'poppins'),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 2,
                                                                                  ),
                                                                                  const Icon(
                                                                                    Icons.calendar_month_outlined,
                                                                                    color: grey,
                                                                                    size: 20,
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            onTap: () =>
                                                                                _selectDate('t'),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Visibility(
                                                                      visible: true,//isAdminUser,
                                                                      child:ContainerFieldWidget(
                                                                        widget:  widgetAccount(), 
                                                                      headTxt: 'Select Account'),),
                                                                     const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                     ContainerFieldWidget(
                                                                          widget: DropdownSearch<
                                                                              dynamic>(
                                                                            popupProps: const PopupPropsMultiSelection
                                                                                .dialog(
                                                                                showSearchBox: true,
                                                                                // constraints: BoxConstraints(
                                                                                //   maxHeight: 300,
                                                                                // )
                                                                                ),
                                                                            asyncItems: (String filter) => api.getLedgerAll(),
                                                                            dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration:
                                                                                  InputDecoration(
                                                                                                           contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                            ),
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                            onChanged:
                                                                                (dynamic data) {
                                                                              _ledger =
                                                                                  data;
                                                                            },
                                                                          ),
                                                                          headTxt:
                                                                              'Select Ledger'),
                                                                              const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      //   ContainerFieldWidget(
                                                                      //     widget: Container(
                                                                      //       width: MediaQuery.sizeOf(context).width,
                                                                      //       padding: const EdgeInsets.symmetric(horizontal: 3),
                                                                      //       decoration: BoxDecoration(
                                                                      //         border: Border.all(color: grey),
                                                                      //         borderRadius: BorderRadius.circular(3),
                                                                      //       ),
                                                                      //       child: DropdownButtonHideUnderline(
                                                                      //         child: DropdownButton<dynamic>(
                                                                      //           isExpanded: true,
                                                                      //           hint: const Text('Select a group',
                                                                      //           style: TextStyle(
                                                                      //             color: black,
                                                                      //             fontFamily: 'poppins'
                                                                      //           ),
                                                                      //           ), 
                                                                      //           items: itemDisplay.map((dynamic item) {
                                                                      //             return DropdownMenuItem(
                                                                      //               value: item,
                                                                      //               child: Text(item.name.toString()),
                                                                      //             );
                                                                      //           }).toList(),
                                                                      //           value: itemDisplay.contains(selectedItem) ? selectedItem : null,
                                                                      //           onChanged: (value) {
                                                                      //             setState(() {
                                                                      //               selectedItem = value; 
                                                                      //             });
                                                                      //           },
                                                                      //         ),
                                                                      //       ),
                                                                      //     ),
                                                                      //     headTxt: 'Group',
                                                                      //   ),
                                                                      //         const SizedBox(
                                                                      //   height:
                                                                      //       10,
                                                                      // ),
                                                                    Visibility(
                                                                      visible: isAdminUser,
                                                                      child: ContainerFieldWidget(
                                                                          widget: DropdownSearch<
                                                                              dynamic>(
                                                                            popupProps: const PopupPropsMultiSelection
                                                                                .dialog(
                                                                                showSearchBox: true,
                                                                                // constraints: BoxConstraints(
                                                                                //   maxHeight: 300,
                                                                                // )
                                                                                ),
                                                                            asyncItems: (String filter) => api.getSalesListData(
                                                                                filter,
                                                                                'sales_list/location'),
                                                                            dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration:
                                                                                  InputDecoration(
                                                                                                           contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                            ),
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                            onChanged:
                                                                                (dynamic data) {
                                                                              locationId =
                                                                                  data;
                                                                            },
                                                                          ),
                                                                          headTxt:
                                                                              'Select Branch'),
                                                                    ),
                                                                    Visibility(
                                                                      visible: isAdminUser,
                                                                      child: const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                    otherRegAreaDataList.isNotEmpty
                                                                    ? ContainerFieldWidget(
                                                                        widget:
                                                                            Container(
                                                                          width:
                                                                              MediaQuery.sizeOf(context).width,
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 5),
                                                                          decoration: BoxDecoration(
                                                                              border: Border.all(color: grey),
                                                                              borderRadius: BorderRadius.circular(3)),
                                                                          child:
                                                                              DropdownButtonHideUnderline(
                                                                            child:
                                                                                DropdownButton<OtherRegistrationModel>(
                                                                              isExpanded: true,
                                                                              icon: const Icon(Icons.keyboard_arrow_down),
                                                                              items: otherRegAreaDataList.map((OtherRegistrationModel items) {
                                                                                return DropdownMenuItem<OtherRegistrationModel>(
                                                                                  value: items,
                                                                                  child: Text(items.name),
                                                                                );
                                                                              }).toList(),
                                                                              value: areaModel,
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  areaModel = value;
                                                                                  area = value!.id.toString();
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        headTxt:
                                                                            'Select Area')
                                                                        : const SizedBox(),
                                                                   otherRegAreaDataList.isNotEmpty
                                                                   ? const SizedBox(
                                                                      height:
                                                                          10,
                                                                    )
                                                                   : const SizedBox(),
                                                                    Visibility(
                                                                      visible: isAdminUser,
                                                                      child: ContainerFieldWidget(
                                                                          widget: DropdownSearch<
                                                                              dynamic>(
                                                                            popupProps: const PopupPropsMultiSelection
                                                                                .dialog(
                                                                                showSearchBox: true,
                                                                                // constraints: BoxConstraints(maxHeight: 300)
                                                                                ),
                                                                            asyncItems: (String filter) => api.getSalesListData(
                                                                                filter,
                                                                                'sales_list/salesMan'),
                                                                            dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration:
                                                                                  InputDecoration(
                                                                                                           contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                            ),
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                            onChanged:
                                                                                (dynamic data) {
                                                                              salesMan =
                                                                                  data.id.toString();
                                                                            },
                                                                          ),
                                                                          headTxt:
                                                                              'Select Salesman'),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                          MaterialPageRoute(builder: (BuildContext context) =>
                                                                           ReportView((_ledger != null && _ledger is! String) ? _ledger.id.toString() : '0', (_ob ? '1' : '0'),
                                                                            DateUtil.dateDMY2YMD(fromDate),
                                                                            DateUtil.dateDMY2YMD(toDate), statement, '', 
                                                                          statement, salesMan, locationId != null ?
                                                                           [locationId.id] : [_dropDownBranchId], area!, route!,accountId)));
                                                                      },
                                                                      style:
                                                                          ButtonStyle(
                                                                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5))),
                                                                        backgroundColor:
                                                                            MaterialStateProperty.all<Color>(kPrimaryColor),
                                                                        foregroundColor:
                                                                            MaterialStateProperty.all<Color>(Colors.white),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        'Show',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w500,
                                                                            fontSize:
                                                                                15,
                                                                            fontFamily:
                                                                                'poppins'),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                             : mode == 'BankReceiptList' || 
                                                               mode == 'BankPaymentList' 
                                                             ? Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        16),
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                       width: MediaQuery.of(context).size.width,
                                                                      child: Row(
                                                                        children: [
                                                                          const Text(
                                                                            'From ',
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 14,
                                                                                fontFamily: 'poppins'),
                                                                          ),
                                                                          InkWell(
                                                                            child:
                                                                                Container(
                                                                              padding:
                                                                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                                              decoration:
                                                                                  BoxDecoration(border: Border.all(color: grey), borderRadius: BorderRadius.circular(3)),
                                                                              child:
                                                                                  Row(
                                                                                children: [
                                                                                  Text(
                                                                                    fromDate!,
                                                                                    style: const TextStyle(
                                                                                      // fontWeight: FontWeight.w500,
                                                                                      //  fontSize: 15,
                                                                                        fontFamily: 'poppins'),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 2,
                                                                                  ),
                                                                                  const Icon(
                                                                                    Icons.calendar_month_outlined,
                                                                                    color: grey,
                                                                                    size: 20,
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            onTap: () =>
                                                                                _selectDate('f'),
                                                                          ),
                                                                          const Spacer(),
                                                                          const Text(
                                                                            'To ',
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 14,
                                                                                fontFamily: 'poppins'),
                                                                          ),
                                                                          InkWell(
                                                                            child:
                                                                                Container(
                                                                              padding:
                                                                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                                              decoration:
                                                                                  BoxDecoration(border: Border.all(color: grey), borderRadius: BorderRadius.circular(3)),
                                                                              child:
                                                                                  Row(
                                                                                children: [
                                                                                  Text(
                                                                                    toDate!,
                                                                                    style: const TextStyle(
                                                                                      // fontWeight: FontWeight.w500,
                                                                                      //  fontSize: 15, 
                                                                                       fontFamily: 'poppins'),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 2,
                                                                                  ),
                                                                                  const Icon(
                                                                                    Icons.calendar_month_outlined,
                                                                                    color: grey,
                                                                                    size: 20,
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            onTap: () =>
                                                                                _selectDate('t'),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    ContainerFieldWidget(
                                                                          widget: Container(
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
          hint: Text(_dropDownValue.isNotEmpty
              ? _dropDownValue.split('-')[1]
              : 'Select bank account',
              style: const TextStyle(
                fontFamily: 'poppins',
                color: black
              ),
              ),
          items: cashBankACList.map<DropdownMenuItem<String>>((item) {
            return DropdownMenuItem<String>(
              value: item.id.toString() + "-" + item.name,
              child: Text(item.name,
              style: const TextStyle(
                fontFamily: 'poppins',
                color: black
              ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _dropDownValue = value!;
              accountId = value.split('-')[0];
              accountName = value.split('-')[1];
            });
          },
        ),
      ),
    ),
                                                                          headTxt:
                                                                              'Bank Account'),
                                                                      const SizedBox(
                                                                        height: 10,
                                                                      ),
                                                                      Visibility(
                                                                      visible: isAdminUser,
                                                                      child: ContainerFieldWidget(
                                                                          widget: DropdownSearch<
                                                                              dynamic>(
                                                                            popupProps: const PopupPropsMultiSelection
                                                                                .dialog(
                                                                                showSearchBox: true,
                                                                                // constraints: BoxConstraints(
                                                                                //   maxHeight: 300,
                                                                                // )
                                                                                ),
                                                                            asyncItems: (String filter) => api.getSalesListData(
                                                                                filter,
                                                                                'sales_list/location'),
                                                                            dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration:
                                                                                  InputDecoration(
                                                                                                           contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                            ),
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                            onChanged:
                                                                                (dynamic data) {
                                                                              locationId =
                                                                                  data;
                                                                            },
                                                                          ),
                                                                          headTxt:
                                                                              'Select Branch'),
                                                                    ),
                                                                    const SizedBox(
                                                                        height: 10,
                                                                      ),
                                                                               TextButton(
                                                                      onPressed:
                                                                          () {
                                                                             statement = mode ==
                                                                            'BankReceiptList'
                                                                            ? 'BankReceipt_Report'
                                                                            : 'BankPayment_Report';
                                                                            // String ledCode = _ledger.id?.toString() ?? (_ledger.id != null ? _ledger.id.toString() : '');
                                                                        Navigator.push(
                                                                            context,
                                                                          MaterialPageRoute(builder: (BuildContext context) =>
                                                                           ReportView('0', (_ob ? '1' : '0'),
                                                                            DateUtil.dateDMY2YMD(fromDate),
                                                                            DateUtil.dateDMY2YMD(toDate),mode, dropDownStatusType, 
                                                                          statement, salesMan, locationId != null ?
                                                                           [locationId.id] : [_dropDownBranchId], _dropDownValue!, route!,'0')));
                                                                      },
                                                                      style:
                                                                          ButtonStyle(
                                                                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5))),
                                                                        backgroundColor:
                                                                            MaterialStateProperty.all<Color>(kPrimaryColor),
                                                                        foregroundColor:
                                                                            MaterialStateProperty.all<Color>(Colors.white),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        'Show',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w500,
                                                                            fontSize:
                                                                                15,
                                                                            fontFamily:
                                                                                'poppins'),
                                                                      ),
                                                                    ),
                                                                              const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      ContainerFieldWidget(
                                                                          widget: DropdownSearch<
                                                                              dynamic>(
                                                                            popupProps: const PopupPropsMultiSelection
                                                                                .dialog(
                                                                                showSearchBox: true,
                                                                                // constraints: BoxConstraints(
                                                                                //   maxHeight: 300,
                                                                                // )
                                                                                ),
                                                                            asyncItems: (String filter) => api.getLedgerAll(),
                                                                            dropdownDecoratorProps:
                                                                                const DropDownDecoratorProps(
                                                                              dropdownSearchDecoration:
                                                                                  InputDecoration(
                                                                                                           contentPadding: EdgeInsets.symmetric(
                                                                                            horizontal: 4,
                                                                                            vertical: 8
                                                                                            ),
                                                                                border: OutlineInputBorder(),
                                                                              ),
                                                                            ),
                                                                            onChanged:
                                                                                (dynamic data) {
                                                                              _ledger =
                                                                                  data;
                                                                            },
                                                                          ),
                                                                          headTxt:
                                                                              'Select Ledger'),
                                                                              const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
//                                                                       ContainerFieldWidget(
//                                                                           widget:  Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 5
//             ),
//             decoration: BoxDecoration(
//               border: Border.all(color: grey),
//               borderRadius: BorderRadius.circular(3)
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 isExpanded: true,
//                 hint: const Text('Status'),
//                 value: dropDownStatusType,
//                 items: statusType.map<DropdownMenuItem<String>>((value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     dropDownStatusType = value!;
//                   });
//                 },
//               ),
//             ),
//           ),
//                                                                           headTxt:
//                                                                               'Status'),
//                                                                               const SizedBox(
//                                                                         height:
//                                                                             10,
//                                                                       ),
//                                                                     Visibility(
//                                                                       visible: isAdminUser,
//                                                                       child: ContainerFieldWidget(
//                                                                           widget: DropdownSearch<
//                                                                               dynamic>(
//                                                                             popupProps: const PopupPropsMultiSelection
//                                                                                 .dialog(
//                                                                                 showSearchBox: true,
//                                                                                 // constraints: BoxConstraints(
//                                                                                 //   maxHeight: 300,
//                                                                                 // )
//                                                                                 ),
//                                                                             asyncItems: (String filter) => api.getSalesListData(
//                                                                                 filter,
//                                                                                 'sales_list/location'),
//                                                                             dropdownDecoratorProps:
//                                                                                 const DropDownDecoratorProps(
//                                                                               dropdownSearchDecoration:
//                                                                                   InputDecoration(
//                                                                                                            contentPadding: EdgeInsets.symmetric(
//                                                                                             horizontal: 4,
//                                                                                             vertical: 8
//                                                                                             ),
//                                                                                 border: OutlineInputBorder(),
//                                                                               ),
//                                                                             ),
//                                                                             onChanged:
//                                                                                 (dynamic data) {
//                                                                               locationId =
//                                                                                   data;
//                                                                             },
//                                                                           ),
//                                                                           headTxt:
//                                                                               'Select Branch'),
//                                                                     ),
//                                                                     const SizedBox(
//                                                                         height:
//                                                                             10,
//                                                                       ),
//                                                                     ContainerFieldWidget(
//   widget: Container(
//     width: MediaQuery.sizeOf(context).width,
//     padding: const EdgeInsets.symmetric(horizontal: 3),
//     decoration: BoxDecoration(
//       border: Border.all(color: grey),
//       borderRadius: BorderRadius.circular(3),
//     ),
//     child: DropdownButtonHideUnderline(
//       child: DropdownButton<dynamic>(
//         isExpanded: true,
//         hint: const Text('Select a group',
//         style: TextStyle(
//           color: black,
//           fontFamily: 'poppins'
//         ),
//         ), 
//         items: itemDisplay.map((dynamic item) {
//           return DropdownMenuItem(
//             value: item,
//             child: Text(item.name.toString()),
//           );
//         }).toList(),
//         value: itemDisplay.contains(selectedItem) ? selectedItem : null,
//         onChanged: (value) {
//           setState(() {
//             selectedItem = value; 
//           });
//         },
//       ),
//     ),
//   ),
//   headTxt: 'Group',
// ),
//                                                                               const SizedBox(
//                                                                         height:
//                                                                             10,
//                                                                       ),
                                                                    Visibility(
                                                                      visible: isAdminUser,
                                                                      child: const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                    // ContainerFieldWidget(
                                                                    //     widget:
                                                                    //         Container(
                                                                    //       width:
                                                                    //           MediaQuery.sizeOf(context).width,
                                                                    //       padding: const EdgeInsets
                                                                    //           .symmetric(
                                                                    //           horizontal: 5),
                                                                    //       decoration: BoxDecoration(
                                                                    //           border: Border.all(color: grey),
                                                                    //           borderRadius: BorderRadius.circular(3)),
                                                                    //       child:
                                                                    //           DropdownButtonHideUnderline(
                                                                    //         child:
                                                                    //             DropdownButton<OtherRegistrationModel>(
                                                                    //           isExpanded: true,
                                                                    //           icon: const Icon(Icons.keyboard_arrow_down),
                                                                    //           items: otherRegAreaDataList.map((OtherRegistrationModel items) {
                                                                    //             return DropdownMenuItem<OtherRegistrationModel>(
                                                                    //               value: items,
                                                                    //               child: Text(items.name),
                                                                    //             );
                                                                    //           }).toList(),
                                                                    //           value: areaModel,
                                                                    //           onChanged: (value) {
                                                                    //             setState(() {
                                                                    //               areaModel = value;
                                                                    //               area = value!.id.toString();
                                                                    //             });
                                                                    //           },
                                                                    //         ),
                                                                    //       ),
                                                                    //     ),
                                                                    //     headTxt:
                                                                    //         'Select Area'),
                                                                    // const SizedBox(
                                                                    //   height:
                                                                    //       10,
                                                                    // ),
                                                                    // Visibility(
                                                                    //   visible: isAdminUser,
                                                                    //   child: ContainerFieldWidget(
                                                                    //       widget: DropdownSearch<
                                                                    //           dynamic>(
                                                                    //         popupProps: const PopupPropsMultiSelection
                                                                    //             .dialog(
                                                                    //             showSearchBox: true,
                                                                    //             // constraints: BoxConstraints(maxHeight: 300)
                                                                    //             ),
                                                                    //         asyncItems: (String filter) => api.getSalesListData(
                                                                    //             filter,
                                                                    //             'sales_list/salesMan'),
                                                                    //         dropdownDecoratorProps:
                                                                    //             const DropDownDecoratorProps(
                                                                    //           dropdownSearchDecoration:
                                                                    //               InputDecoration(
                                                                    //                                        contentPadding: EdgeInsets.symmetric(
                                                                    //                         horizontal: 4,
                                                                    //                         vertical: 8
                                                                    //                         ),
                                                                    //             border: OutlineInputBorder(),
                                                                    //           ),
                                                                    //         ),
                                                                    //         onChanged:
                                                                    //             (dynamic data) {
                                                                    //           salesMan =
                                                                    //               data.id.toString();
                                                                    //         },
                                                                    //       ),
                                                                    //       headTxt:
                                                                    //           'Select Salesman'),
                                                                    // ),
                                                                    // const SizedBox(
                                                                    //   height:
                                                                    //       10,
                                                                    // ),
                                                                   
                                                                  ],
                                                                ),
                                                              )
                                                            
                                                              : Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        16),
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                       width: MediaQuery.of(context).size.width,
                                                                      child: Row(
                                                                        children: [
                                                                          const Text(
                                                                            'From ',
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 14,
                                                                                fontFamily: 'poppins'),
                                                                          ),
                                                                          InkWell(
                                                                            child:
                                                                                Container(
                                                                              padding:
                                                                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                                              decoration:
                                                                                  BoxDecoration(border: Border.all(color: grey), borderRadius: BorderRadius.circular(3)),
                                                                              child:
                                                                                  Row(
                                                                                children: [
                                                                                  Text(
                                                                                    fromDate!,
                                                                                    style: const TextStyle(
                                                                                      // fontWeight: FontWeight.w500,
                                                                                      //  fontSize: 15, 
                                                                                       fontFamily: 'poppins'),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 2,
                                                                                  ),
                                                                                  const Icon(
                                                                                    Icons.calendar_month_outlined,
                                                                                    color: grey,
                                                                                    size: 20,
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            onTap: () =>
                                                                                _selectDate('f'),
                                                                          ),
                                                                          const Spacer(),
                                                                          const Text(
                                                                            'To ',
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 14,
                                                                                fontFamily: 'poppins'),
                                                                          ),
                                                                          InkWell(
                                                                            child:
                                                                                Container(
                                                                              padding:
                                                                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                                              decoration:
                                                                                  BoxDecoration(border: Border.all(color: grey), borderRadius: BorderRadius.circular(3)),
                                                                              child:
                                                                                  Row(
                                                                                children: [
                                                                                  Text(
                                                                                    toDate!,
                                                                                    style: const TextStyle(
                                                                                      // fontWeight: FontWeight.w500,
                                                                                      //  fontSize: 15, 
                                                                                       fontFamily: 'poppins'),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 2,
                                                                                  ),
                                                                                  const Icon(
                                                                                    Icons.calendar_month_outlined,
                                                                                    color: grey,
                                                                                    size: 20,
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            onTap: () =>
                                                                                _selectDate('t'),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    // Card(
                                                                    //   elevation: 2,
                                                                    //   child:
                                                                    //       DropDownSettingsTile<int>(
                                                                    //     title: 'Branch',
                                                                    //     settingKey:
                                                                    //         'key-dropdown-default-location-view',
                                                                    //     values: locationList
                                                                    //             .isNotEmpty
                                                                    //         ? {
                                                                    //             for (var e
                                                                    //                 in locationList)
                                                                    //               e.key + 1: e.value
                                                                    //           }
                                                                    //         : {
                                                                    //             2: '',
                                                                    //           },
                                                                    //     selected: 2,
                                                                    //     onChange: (value) {
                                                                    //       debugPrint(
                                                                    //           'key-dropdown-default-location-view: $value');
                                                                    //       dropDownBranchId =
                                                                    //           value - 1;
                                                                    //     },
                                                                    //   ),
                                                                    // ),
                                                                    ContainerFieldWidget(
                                                                        widget: DropdownSearch<
                                                                            dynamic>(
                                                                          popupProps: const PopupPropsMultiSelection
                                                                              .dialog(
                                                                              showSearchBox: true,
                                                                              // constraints: BoxConstraints(
                                                                              //   maxHeight: 300,
                                                                              // )
                                                                              ),
                                                                          asyncItems: (String filter) => api.getSalesListData(
                                                                              filter,
                                                                              'sales_list/location'),
                                                                          dropdownDecoratorProps:
                                                                              const DropDownDecoratorProps(
                                                                            dropdownSearchDecoration:
                                                                                InputDecoration(
                                                                                                         contentPadding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8
                      ),
                                                                              border: OutlineInputBorder(),
                                                                            ),
                                                                          ),
                                                                          onChanged:
                                                                              (dynamic data) {
                                                                            locationId =
                                                                                data;
                                                                          },
                                                                        ),
                                                                        headTxt:
                                                                            'Select Branch'),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (BuildContext context) =>
                                                                             ReportView('0', (_ob ? '1' : '0'),
                                                                             DateUtil.dateDMY2YMD(fromDate), DateUtil.dateDMY2YMD(toDate),
                                                                             statement, '', statement, salesMan, locationId != null ?
                                                                            [locationId.id] : [_dropDownBranchId], area!, route!,'0')));
                                                                      },
                                                                      style:
                                                                          ButtonStyle(
                                                                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5))),
                                                                        backgroundColor:
                                                                            MaterialStateProperty.all<Color>(kPrimaryColor),
                                                                        foregroundColor:
                                                                            MaterialStateProperty.all<Color>(Colors.white),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        'Show',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .w500,
                                                                            fontSize:
                                                                                15,
                                                                            fontFamily:
                                                                                'poppins'),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              );
  }

 var _dropDownValueAcc = '';
  widgetAccount() {
    return Container(
      // height: 35,
      padding: const EdgeInsets.only(left: 3),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
          border: Border.all(color: grey),
          borderRadius: BorderRadius.circular(3)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Center(
            child: Text(
              _dropDownValueAcc.isNotEmpty
                  ? _dropDownValueAcc.split('-')[1]      
                  : 'Select Account',
              style: const TextStyle(
              fontFamily: 'poppins', 
              color: black,
              fontSize: 13,
              fontWeight: FontWeight.w500
              ),
            ),
          ),
          items: cashBankACListAll.map<DropdownMenuItem<String>>((item) {
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
            //  if (!keyLockCashAccount) {
          // if (cashId <= 0) {
          setState(() {
            _dropDownValueAcc = value!;
            accountId = value.split('-')[0];
            accountName = value.split('-')[1];
          });
        // }
          },
        ),
      ),
    );
  }

  _listItem(index) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      color: bagroundColor,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          child: Container(
            // padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            decoration: BoxDecoration(
                border: Border.all(color: grey),
                color: white,
                borderRadius: BorderRadius.circular(3)),
            child: ListTile(
              title: Text(itemDisplay[index].name),
            ),
          ),
        ),
        onTap: () {
          setState(() {
            _loading = false;
            _ledger = itemDisplay[index].name;
            _id = itemDisplay[index].id;

            // api.getCustomerDetail(_id).then((_data) => tempLedgerData =
            //     CustomerModel(
            //         id: _data.id,
            //         name: _ledger,
            //         address1: _data.address1,
            //         address2: _data.address2,
            //         address3: _data.address3,
            //         address4: _data.address4,
            //         balance: _data.balance,
            //         city: _data.city,
            //         email: _data.email,
            //         phone: _data.phone,
            //         route: _data.route,
            //         state: _data.state,
            //         stateCode: _data.stateCode,
            //         taxNumber: _data.taxNumber));
          });
        },
      ),
    );
  }

  _searchBar() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      color: bagroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          color: white,
          child: TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text(
                  'Search...',
                  style: TextStyle(fontFamily: 'poppins'),
                )),
            onChanged: (text) {
              text = text.toLowerCase();
              setState(() {
                itemDisplay = items.where((item) {
                  var itemName = item.name.toString().toLowerCase();
                  return itemName.contains(text);
                }).toList();
              });
            },
          ),
        ),
      ),
    );
  }

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
              dropdownDecoratorProps: DropDownDecoratorProps(dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Select Project')),
              onChanged: (dynamic data) {
                projectId = data.id.toString();
              },
              // showSearchBox: true,
            ),
          )
        : Container();
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
              {fromDate = DateUtil.datePickerDMY(picked)}
            else
              {toDate = DateUtil.datePickerDMY(picked)}
          });
    }
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
