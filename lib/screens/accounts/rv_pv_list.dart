import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/ledger_name_model.dart';
import 'package:sheraccerp/models/other_registrations.dart';
import 'package:sheraccerp/models/rp_model.dart';
import 'package:sheraccerp/models/voucher_type_model.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/screens/accounts/r_p_voucher.dart';
import 'package:sheraccerp/screens/html_previews/rpv_preview.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/color_palette.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/container_textfield_widget.dart';
import 'package:sheraccerp/widget/loading.dart';

class RvPvList extends StatefulWidget {
  const RvPvList({super.key});

  @override
  State<RvPvList> createState() => _RvPvListState();
}

class _RvPvListState extends State<RvPvList> {
  String? fromDate;
  var _data;
  int menuId = 0;
  String? toDate;
  bool loadReport = false,
      stockValuation = false,
      isType = false,
      classic = true,
      newMode = false,
      isAdminUser = false;
  var itemId,
      itemName,
      customer,
      supplier,
      mfr,
      category,
      subCategory,
      salesMan,
      project,
      taxGroup;    
  DateTime now = DateTime.now();
  DioService api = DioService();
  final controller = ScrollController();
  double offset = 0;
  DataJson? location;
  String title = 'Rv Pv';
  bool isBranchSelected = false;
  int locationId = 1;
  VoucherType voucherTypeData = VoucherType.emptyData();
  String? formattedDate;
  List<CompanySettings>? settings;
  CompanyInformation? companySettings;
  List<RpVoucherParticularModel> particularList = [];
  LedgerModel? ledData;

  @override
  void initState() {
    super.initState();
    fromDate = DateFormat('dd-MM-yyyy').format(now);
    toDate = DateFormat('dd-MM-yyyy').format(now);
    formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);
    isAdminUser = companyUserData!.userType.toUpperCase() == 'ADMIN' ? true : false;
    
    // if (!isAdminUser) {
      // locationId = ComSettings.appSettings(
      //         'int', 'key-dropdown-default-location-view', 2) -
      //     1;
      // OtherRegistrationModel otherData = otherRegLocationList.firstWhere(
      //     (element) => element.id == locationId,
      //     orElse: () => OtherRegistrationModel(
      //         add1: '',
      //         add2: '',
      //         add3: '',
      //         description: '',
      //         email: '',
      //         id: locationId,
      //         name: defaultLocation,
      //         type: ''));
      // location = DataJson(id: otherData.id, name: otherData.name);

      int salesManId = ComSettings.appSettings(
              'int', 'key-dropdown-default-salesman-view', 1) -
          1;
      if (salesManId > 0) {
        salesMan = DataJson(id: salesManId, name: '');
      }
      loadSettings();
    // }
  }  

  String cashAc = '';
  int cashId = 0;
  int decimal = 2;

  loadSettings() {
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();

     cashAc =
        ComSettings.getValue('CASH A/C', settings!).toString().trim() ?? 'CASH';
      acId = mainAccount
        .firstWhere((element) => element['LedName'] == cashAc)['LedCode'];
    cashId =
        ComSettings.appSettings('int', 'key-dropdown-default-cash-ac', 0) - 1;
    var acModel = cashId > 0
        ? mainAccount.firstWhere((element) => element['LedCode'] == cashId,
            orElse: () => {'LedName': cashAc, 'LedCode': acId})
        : {'LedName': cashAc, 'LedCode': acId};
    acId = cashId > 0 ? acModel['LedCode'] : acId;
    cashAc = cashId > 0 ? acModel['LedName'] : cashAc;
    if (acId > 0) {
      _dropDownValue = '$acId-$cashAc';
      accountId = acId.toString();
      accountName = cashAc;
    }
    locationId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    decimal = ComSettings.getValue('DECIMAL', settings!).toString().isNotEmpty
        ? int.tryParse(ComSettings.getValue('DECIMAL', settings!).toString())!
        : 2;
    isMultiRvPv = ComSettings.getStatus('KEY MULTI RV-PV', settings!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getArguments();
  }

  void _getArguments() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      setState(() {
        title = arguments['mode']?.toString() ?? 'Rv Pv';
      });
    }
    if (voucherTypeList.isNotEmpty) {
      voucherTypeData = title == 'Payment'
          ? voucherTypeList.firstWhere(
              (element) => element.voucher.toLowerCase() == 'payment')
          : title == 'Receipt'
              ? voucherTypeList.firstWhere(
                  (element) => element.voucher.toLowerCase() == 'receipt')
                  : title == 'Receipt Order'
                  ? voucherTypeList.firstWhere((element) =>
                      element.voucher.toLowerCase() == 'receipt order')
                      : title == 'Payment Order'
                       ? voucherTypeList.firstWhere((element) =>
                          element.voucher.toLowerCase() == 'Payment order')
                            : VoucherType.emptyData();
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
                loadReport = false;
                isLoadingData = false;
                valueMore = false;
                lastRecord = false;
                page = 1;
                pageTotal = 0;
                totalRecords = 0;
                dataDisplay = [];
                dataDisplayHead = [];
              });
            },
            icon: Image.asset('assets/icons/ic_filter.png', scale: 3.3),
          ),
        ],
        titleTextStyle: const TextStyle(
          fontFamily: 'poppins',
          color: white
        ),
        title: Text('$title Report'),
      ),
      body: loadReport ? reportView(title) : selectData(title),
    );
  }

  reportView(title) {
    List<dynamic> dataFirmList = [
      {'FormId': title== 'Payment' ? 1 : 2}
    ];
    String statement = title == 'Payment' ? 'PVList' : 'RVList';
    controller.addListener(onScroll);
    return _rvPvListData(statement, dataFirmList, title);
  }

    @override
  void dispose() {
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  bool isLoadingData = false, valueMore = false, lastRecord = false;
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  int page = 1, pageTotal = 0, totalRecords = 0;

  void _getMoreData(String statementType, var dataSType) async {
    if (!lastRecord) {
      if ((dataDisplay.isEmpty || dataDisplay.length < totalRecords) &&
          !isLoadingData) {
        setState(() {
          isLoadingData = true;
        });

        List tempList = [];
         var _location = '0';
        if(isAdminUser){
          if (isBranchSelected) {
              if (location != null) {
          _location = location!.id.toString() ?? '0';
        }
          }else{
          _location = locationId.toString();
        }
        }else{
                if (location != null) {
          _location = location!.id.toString() ?? '0';
        }
          }
        // statement, page, '1', salesTypeData.id.toString(), ' ', ' '

        var dataJsonS = '[' +
            json.encode({
              'statementType': statementType.isEmpty ? '' : statementType,
              'sDate': fromDate!.isEmpty ? '' : formatYMD(fromDate),
              'eDate': toDate!.isEmpty ? '' : formatYMD(toDate),
              'itemId':  '0',
              'customerId': '0',
              'supplierId':  '0',
              'mfr':  '0',
              'category':  '0',
              'subcategory':  '0',
              'location':int.tryParse(_location.toString()),
              'project': '0',
              'salesman': '0',
              'salesType': jsonEncode({'id': 0}),
              "page": page,
              'areaId': 0,
              'groupId': 0,
              'taxGroup': 0,
            }) +
            ']';
            debugPrint(dataJsonS);
        api.getListPageReport(dataJsonS).then((value) {
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
            dataDisplayHead.addAll(response[1]);
            lastRecord = tempList.isNotEmpty ? false : true;
          });
        });
      }
    }
  }

  List dataDisplay = [];
  List dataDisplayHead = [];

  _rvPvListData(String statementType, var dataSType, String title) {
    _getMoreData(statementType, dataSType);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData(statementType, dataSType);
      }
    });

   return dataDisplay.isNotEmpty
    ?
     Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: RefreshIndicator(
            onRefresh: () async {},
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemCount: dataDisplay.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == dataDisplay.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isLoadingData ? 1.0 : 0.0,
                      child: const Center(
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorPalette.nileBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3, 
                          child: InkWell(
                          onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RPVoucher(
                                    oldRvPv: true,
                                  ),
                                  settings: RouteSettings(
                                    arguments: {
                                      'dataDynamic': [
                                        {
                                          'RealEntryNo': dataDisplay[index]['entryno'],
                                          'EntryNo': dataDisplay[index]['entryno'],
                                          'Id': dataDisplay[index]['entryno'],
                                          'Type': '0'
                                        }
                                      ],
                                      'mode': title,
                                      'fromDaily':'1'
                                    },
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: const BoxDecoration(
                                          color: ColorPalette.timberGreen,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          dataDisplay[index]['Name'],
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: ColorPalette.timberGreen,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 120),
                                        child: _buildInfoChip(
                                          icon: Icons.calendar_today_outlined,
                                          text: dataDisplay[index]['Date'],
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 120),
                                        child: _buildInfoChip(
                                          icon: Icons.numbers_outlined,
                                          text: 'Entry: ${dataDisplay[index]['entryno']}',
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                          indent: 4,
                          endIndent: 4,
                          color: Colors.grey,
                        ),
                        
                        Expanded(
                          flex: 2, 
                          child: InkWell(
                            onTap: () {
                              showDetails(
                                context,
                                title,
                                int.tryParse(dataDisplay[index]['entryno'].toString())!,
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${dataDisplay[index]['total'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: ColorPalette.nileBlue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ColorPalette.nileBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'View',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: ColorPalette.nileBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                }
              },
              controller: _scrollController,
            ),
          ),
        ) : isLoadingData
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 12, 62, 150),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading $title...',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  title == 'Payment' ? Icons.payments_outlined : Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  title == 'Payment' ? 'No Payments Yet' : 'No Receipts Yet',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your $title list is empty',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 24),
                // ElevatedButton(
                //   onPressed: () {
                //     // Add action to create new item
                //   },
                //   style: ElevatedButton.styleFrom(
                //     foregroundColor: Colors.white,
                //     backgroundColor: ColorPalette.nileBlue,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 24,
                //       vertical: 12,
                //     ),
                //   ),
                //   child: const Text(
                //     'Create New',
                //     style: TextStyle(
                //       fontWeight: FontWeight.w600,
                //     ),
                //   ),
                // ),
              ],
            ),
          );
  
  }

 Widget _buildInfoChip({
  required IconData icon,
  required String text,
  required Color color,
}) {
  return Container(
    constraints: const BoxConstraints(maxWidth: 120),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 10,
          color: color,
        ),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    ),
  );
}

  var _dropDownValue = '';
  var accountId = '', accountName = '';
  String?  narration = '', projectId = '-1';
  int refNo = 0, acId = 0;
  bool oldVoucher = false,
       isMultiRvPv = false,
       isSelected = false;
  double? balance = 0, total = 0, amount = 0, discount = 0,oldBalance = 0;  
  var footerMessage = '';   

  showDetails(context, mode, int id) {
    //fetchVoucher(context, data, mode) {
    double voucherTotal = 0;
    int row = 0;
    api
        .fetchVoucher(
            id, mode == 'Payment' ? 'FindPv' : 'FindRv', voucherTypeData.id)
        .then((value) {
      if (value != null) {
        var information = value[0][0];
        var particulars = value[1];
        var _footerMessage = value[2][0]['s_Value'];
        footerMessage = _footerMessage;
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

        voucherTotal = double.tryParse(information['Total'].toString())!;
        _dropDownValue = information['LedCode'].toString() +
            '-' +
        information['LedName'].toString();
        accountName = information['LedName'].toString();
        accountId = information['LedCode'].toString();
        acId = information['LedCode'];
        var particular = null;
        oldVoucher = true;
        if (isMultiRvPv) {
          for (var part in particulars) {
            particularList.add(RpVoucherParticularModel(
                id: part['LedCode'],
                name: part['LedName'],
                amount: double.tryParse(part['Amount'].toString())!,
                discount: double.tryParse(part['Discount'].toString())!,
                total: double.tryParse(part['Total'].toString())!,
                narration: part['Narration'].toString(),
                balance: '0',
                phone: ''));
            ledData = LedgerModel(id: 0, name: '');
            isSelected = false;
            //   amount = double.tryParse(part['Amount'].toString());
            //   discount = double.tryParse(part['Discount'].toString());
            //   total = double.tryParse(part['Total'].toString());
            //   narration = part['Narration'].toString();
          }
        } else {
          var part1 = particulars[0];
          ledData = LedgerModel(id: part1['LedCode'], name: part1['LedName']);
          amount = double.tryParse(part1['Amount'].toString());
          discount = double.tryParse(part1['Discount'].toString());
          total = double.tryParse(part1['Total'].toString());
          narration = part1['Narration'].toString();
          particular = '[' +
              json.encode({
                'amount': amount,
                'discount': discount,
                'total': total,
                'narration': narration,
                'Ledid': ledData!.id
              }) +
              ']';
        }
        if (isMultiRvPv) {
          // particularList
        } else {
          getOldBalance(
              ledData!.id,
              (mode == 'Payment' ? 'SupplierOB' : 'CustomerOB'),
              mode,
              DateUtil.dateYMD(formattedDate),
              information['EntryNo']);
        }

        var dataAll = [
          {
            'entryNo': dataDynamic[0]['EntryNo'].toString(),
            'date': formatDMY(formattedDate),
            'debitAccount': accountId,
            'amount': amount,
            'discount': discount,
            'total': total,
            'particular': particular,
            'account': accountName,
            'name': ledData!.name,
            'balance': 0,
            'oldBalance': oldBalance,
            'message': _footerMessage
          }
        ];
        actionShow(mode, context, dataAll);
      }
    });
  }

  getOldBalance(int Id, String statement, String type, String date, entryno) {
    api.getBalance(Id, statement, type, date, entryno).then((value) {
      oldBalance = double.parse(value['oldBalance'].toString());
    });
  }

  String formatDMY(value) {
    var dateTime = DateFormat("dd-mm-yyyy").parse(value.toString());
    return DateFormat("yyyy-mm-dd").format(dateTime);
  }

  Future<String?> selectPositionDialog(BuildContext context, int length) async {
  return await showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text('Select SlNo'),
        children: List.generate(
          length,
          (index) => SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, index.toString());
            },
            child: Text('${index + 1}'),
          ),
        ),
      );
    },
  );  
}

  actionShow(mode, context, data) async {
  var form = mode == 'Payment' ? 'PAYMENT' : 'RECEIPT';
  var title = mode == 'Payment' ? 'Payment Voucher' : 'Receipt Voucher';
  
  ConfirmAlertBox(
    buttonColorForNo: Colors.red,
    buttonColorForYes: Colors.green,
    icon: Icons.check,
    onPressedNo: () {
      // clearData();
      particularList = [];
      Navigator.of(context).pop();
    },
    onPressedYes: () async {  
      Navigator.of(context).pop();
      
      if (isMultiRvPv) {
        final value = await selectPositionDialog(context, particularList.length);
        if (value != null) {  
          int index = int.parse(value);
          RpVoucherParticularModel partData = particularList[index];
          ledData = LedgerModel(id: partData.id, name: partData.name);
          var particular = '[${json.encode({
            'amount': partData.amount,
            'discount': partData.discount,
            'total': partData.total,
            'narration': partData.narration,
            'Ledid': ledData!.id
          })}]';
          
          data = [
            {
              'entryNo': oldVoucher
                  ? dataDynamic[0]['EntryNo'].toString()
                  : refNo.toString(),
              'date': formatDMY(formattedDate),
              'debitAccount': accountId,
              'amount': partData.amount,
              'discount': partData.discount,
              'total': partData.total,
              'particular': particular,
              'account': accountName,
              'name': ledData!.name,
              'balance': partData.balance.toString() == "0"
                  ? '0 Dr'
                  : partData.balance,
              'oldBalance': oldBalance,
              'message': footerMessage
            }
          ];
          particularList = [];
          // clearData();
          return sentToPreview(title, form, data);
        }else{
          particularList = [];
          // clearData();
        }
      } else {
        // clearData();
        return sentToPreview(title, form, data);
      }
    },
    buttonTextForNo: 'No',
    buttonTextForYes: 'YES',
    infoMessage: 'Do you want to preview \nRefNo:${data[0]['entryNo']}',
    title: 'Print Voucher',
    context: context,
  );
}

  sentToPreview(String title, String form, var data) {
    // Future<dynamic> printBluetooth(
    //     BuildContext context,
    //     String title,
    //     CompanyInformation companySettings,
    //     List<CompanySettings> settings,
    //     data,
    //     byteImage,
    //     size,
    //     form) async {
    var dataAll = [data, form];
    // Navigator.push(context,
    //     MaterialPageRoute(builder: (_) => BtPrint(dataAll, byteImage)));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => RVPreviewShow(title: title, dataAll: dataAll)));
  }

  Widget selectData(String title) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Date Range Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        fontFamily: 'poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // From Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'poppins',
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _selectDate('f'),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          fromDate!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'poppins',
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down_outlined,
                                        color: Colors.grey.shade500,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // To Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'poppins',
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _selectDate('t'),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          toDate!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'poppins',
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down_outlined,
                                        color: Colors.grey.shade500,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Branch Selection (Admin only)
              Visibility(
                visible: isAdminUser,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Branch Selection',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                          fontFamily: 'poppins',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ContainerFieldWidget(
                        widget: DropdownSearch<dynamic>(
                          popupProps: PopupPropsMultiSelection.dialog(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Search branch...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            dialogProps: DialogProps(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          asyncItems: (String filter) =>
                              api.getSalesListData(filter, 'sales_list/location'),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              hintText: 'Select branch',
                              hintStyle: const TextStyle(
                                fontFamily: 'poppins',
                                color: Colors.grey,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: kPrimaryColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          onChanged: (dynamic data) {
                            location = data;
                            isBranchSelected = true;
                          },
                        ),
                        headTxt: 'Select Branch',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Show Button
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      kPrimaryColor,
                      kPrimaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    setState(() {
                      loadReport = true;
                      location = isAdminUser
                          ? isBranchSelected
                              ? location
                              : DataJson(id: 1, name: defaultLocation)
                          : location;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.filter_alt_rounded,
                        color: white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Show Report',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          color: white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Optional: Add a reset button
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Add reset functionality if needed
                },
                child: const Text(
                  'Reset Filters',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future _selectDate(String type) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100)
    );
    if (picked != null) {
      setState(() {
        if (type == 'f') {
          fromDate = DateFormat('dd-MM-yyyy').format(picked);
        } else {
          toDate = DateFormat('dd-MM-yyyy').format(picked);
        }
      });
    }
  }
  
  String formatYMD(value) {
    var dateTime = DateFormat("dd-MM-yyyy").parse(value.toString());
    return DateFormat("yyyy-MM-dd").format(dateTime);
  }

   void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

}