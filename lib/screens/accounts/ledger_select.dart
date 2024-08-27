import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/customer_model.dart';
import 'package:sheraccerp/models/ledger_parent.dart';
import 'package:sheraccerp/models/other_registrations.dart';
import 'package:sheraccerp/scoped-models/main.dart';
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
  DioService api = DioService();
bool _loading = true,
      _showQty = false,
      _ob = true,
      _gAll = true,
      isSalesManWiseLedger = false,
      _0b = false;
var _ledger, _id, locationId, _dropDownBranchId;
  String? fromDate, toDate, sType = 'Summery', area = '0', route = '0';
  dynamic areaModel, routeModel;
  var statement = '';
  var salesMan = '0';
  var mode = '';
  DateTime now = DateTime.now();
  String radioButtonItem = 'All';
  int rdId = 1, groupId = 0;
  String selectedGroupValues = '', selectedStockValue = '';
  dynamic selectedItem;
  List<CompanySettings> settings = [];

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
   groupId =
        ComSettings.appSettings('int', 'key-dropdown-default-group-view', 0) -
            1;
    isSalesManWiseLedger =
        ComSettings.getStatus('KEY SALESMAN WISE LEDGER', settings);
    int salesManId = ComSettings.appSettings(
            'int', 'key-dropdown-default-salesman-view', 1) -
        1;
    if (arguments.isNotEmpty) {
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
        ];
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
      areaModel = otherRegAreaList.first;
    }
    if (otherRegRouteList.isNotEmpty) {
      routeModel = otherRegRouteList.first;
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
                  height: 10,
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
                //       debugPrint('key-dropdown-default-location-view: $value');
                //       dropDownBranchId = value - 1;
                //     },
                //   ),
                // ),
                ContainerFieldWidget(
                    widget: DropdownSearch<dynamic>(
                      popupProps:
                          const PopupPropsMultiSelection.modalBottomSheet(
                              showSearchBox: true,
                              constraints: BoxConstraints(
                                maxHeight: 300,
                              )),
                      asyncItems: (String filter) =>
                          api.getSalesListData(filter, 'sales_list/location'),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      onChanged: (dynamic data) {
                        locationId = data;
                      },
                    ),
                    headTxt: 'Select Branch'),
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
                            statement = '';
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
                                    route!)));
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
                    ContainerFieldWidget(
                        widget: DropdownSearch<dynamic>(
                          popupProps:
                              const PopupPropsMultiSelection.modalBottomSheet(
                                  showSearchBox: true,
                                  constraints: BoxConstraints(
                                    maxHeight: 300,
                                  )),
                          asyncItems: (String filter) => api.getSalesListData(
                              filter, 'sales_list/location'),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onChanged: (dynamic data) {
                            locationId = data;
                          },
                        ),
                        headTxt: 'Select Branch'),
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
                                            route!)));
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
                                            route!)));
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
                                                    route!)));
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
                                // Row(
                                //   children: [
                                //     Text('Opening Balance'),
                                //     Checkbox(
                                //       value: _ob,
                                //       onChanged: (value) {
                                //         setState(() {
                                //           _ob = value;
                                //         });
                                //       },
                                //     ),
                                //   ],
                                // ),
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
                                                    route!)));
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
                                                        route!)));
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
                                                            route!)));
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
                                              ContainerFieldWidget(
                                                  widget: DropdownSearch<dynamic>(
                                                    popupProps:
                                                        const PopupPropsMultiSelection
                                                            .modalBottomSheet(
                                                            showSearchBox: true,
                                                            constraints:
                                                                BoxConstraints(
                                                                    maxHeight:
                                                                        300)),
                                                    asyncItems: (String filter) =>
                                                        api.getSalesListData(
                                                            filter,
                                                            'sales_list/location'),
                                                    dropdownDecoratorProps:
                                                        const DropDownDecoratorProps(
                                                      dropdownSearchDecoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                    ),
                                                    onChanged: (dynamic data) {
                                                      locationId = data;
                                                    },
                                                  ),
                                                  headTxt: 'Select Branch'),
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
                                                                  route!)));
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
                                                        icon: const Icon(Icons
                                                            .keyboard_arrow_down),
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
                                                        icon: const Icon(Icons
                                                            .keyboard_arrow_down),
                                                        items: otherRegRouteList.map(
                                                            (OtherRegistrationModel
                                                                items) {
                                                          return DropdownMenuItem<
                                                              OtherRegistrationModel>(
                                                            value: items,
                                                            child:
                                                                Text(items.name),
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
                                                  headTxt: 'Select Route')
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
                                                    ContainerFieldWidget(
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
                                                                    (_ob ? '1': '0'),
                                                                    DateUtil.dateDMY2YMD(
                                                                        fromDate),
                                                                    DateUtil.dateDMY2YMD(
                                                                        toDate),
                                                                    'Closing Report',
                                                                    '',
                                                                    statement,
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
                                                                    route!)));
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
                                                                        route!)));
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
                                                                            route!)));
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
                                                                                    : 'ReceivblesCreditOnly'
                                                                        : selectedGroupValues == 'Invoice Wise'
                                                                            ? 'InvoiceWiseBalanceCustomers'
                                                                            : selectedGroupValues == 'Detailed'
                                                                                ? 'Receivable_Master_Detail'
                                                                                : selectedGroupValues == 'Due Bill Date'
                                                                                    ? 'DueBillBalance_Report'
                                                                                    : 'ReceivblesDebitOnly';

                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (BuildContext context) => ReportView(
                                                                                selectedItem.id.toString(),
                                                                                (_ob ? '1' : '0'),
                                                                                DateUtil.dateDMY2YMD(fromDate),
                                                                                DateUtil.dateDMY2YMD(toDate),
                                                                                mode,
                                                                                selectedItem.name,
                                                                                statement,
                                                                                salesMan,
                                                                                locationId != null ? [locationId.id] : [_dropDownBranchId],
                                                                                area!,
                                                                                route!)));
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
                                                                    ContainerFieldWidget(
                                                                        widget: DropdownSearch<
                                                                            dynamic>(
                                                                          popupProps: const PopupPropsMultiSelection
                                                                              .modalBottomSheet(
                                                                              showSearchBox: true,
                                                                              constraints: BoxConstraints(
                                                                                maxHeight: 300,
                                                                              )),
                                                                          asyncItems: (String filter) => api.getSalesListData(
                                                                              filter,
                                                                              'sales_list/location'),
                                                                          dropdownDecoratorProps:
                                                                              const DropDownDecoratorProps(
                                                                            dropdownSearchDecoration:
                                                                                InputDecoration(
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
                                                                    ContainerFieldWidget(
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
                                                                              items: otherRegAreaList.map((OtherRegistrationModel items) {
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
                                                                            'Select Area'),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    ContainerFieldWidget(
                                                                        widget: DropdownSearch<
                                                                            dynamic>(
                                                                          popupProps: const PopupPropsMultiSelection
                                                                              .modalBottomSheet(
                                                                              showSearchBox: true,
                                                                              constraints: BoxConstraints(maxHeight: 300)),
                                                                          asyncItems: (String filter) => api.getSalesListData(
                                                                              filter,
                                                                              'sales_list/salesMan'),
                                                                          dropdownDecoratorProps:
                                                                              const DropDownDecoratorProps(
                                                                            dropdownSearchDecoration:
                                                                                InputDecoration(
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
                                                                            DateUtil.dateDMY2YMD(fromDate),
                                                                            DateUtil.dateDMY2YMD(toDate), statement, '', 
                                                                          statement, salesMan, locationId != null ?
                                                                           [locationId.id] : [_dropDownBranchId], area!, route!)));
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
                                                                              .modalBottomSheet(
                                                                              showSearchBox: true,
                                                                              constraints: BoxConstraints(
                                                                                maxHeight: 300,
                                                                              )),
                                                                          asyncItems: (String filter) => api.getSalesListData(
                                                                              filter,
                                                                              'sales_list/location'),
                                                                          dropdownDecoratorProps:
                                                                              const DropDownDecoratorProps(
                                                                            dropdownSearchDecoration:
                                                                                InputDecoration(
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
                                                                            [locationId.id] : [_dropDownBranchId], area!, route!)));
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
}
