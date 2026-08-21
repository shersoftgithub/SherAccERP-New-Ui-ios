import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/sales_type.dart';
import 'package:sheraccerp/models/voucher_type_model.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/screens/accounts/bank_voucher.dart';
import 'package:sheraccerp/screens/accounts/r_p_voucher.dart';
import 'package:sheraccerp/screens/inventory/purchase/purchase.dart';
import 'package:sheraccerp/screens/inventory/sales/sale.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/pdf_screen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pw;
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:syncfusion_flutter_core/theme.dart';
import 'package:zoom_widget/zoom_widget.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class ReportView extends StatefulWidget {
  const ReportView(
      this.id,
      this.ob,
      this.sDate,
      this.eDate,
      this.type,
      this.name,
      this.statement,
      this.salesMan,
      this.branchId,
      this.area,
      this.route,
      this.partyId,
      {Key? key})
      : super(key: key);
  final String id;
  final String sDate;
  final String eDate;
  final String ob;
  final String type;
  final String name;
  final String statement;
  final String salesMan;
  final List<int> branchId;
  final String area;
  final String route;
  final String partyId;

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  late Size size;
  var recdset;
  List<dynamic> displayedData = [];
  DioService api = DioService();
  final controller = ScrollController();
  double offset = 0;
  bool fullLedgerReprt = false;
  bool cardWIseLedger = false;
  var _data;
  List<dynamic> location = [
    {'id': 0}
  ];
  List<dynamic> project = [
    {'id': 0}
  ];

  List<CompanySettings>? settings;
  List<ReportDesign>? reportDesignList;
  List<ReportDesign>? reportDesign;
  CompanyInformation? companySettings;
  List<String> tableColumn = [];
  List<String> tableColumnIncome = [];
  List<String> tableColumnExpense = [];
  List<String> tableColumnTotal = [];

  @override
  void initState() {
    controller.addListener(onScroll);
    super.initState();
    location.removeAt(0);
    if (widget.branchId[0] == 0) {
        if(widget.type == "Closing Report"){
        location.add(({'id': '0'}));
      }else{
        for (int i = 0; i < otherRegLocationList.length; i++) {
        location.add(({'id': otherRegLocationList[i].id}));
      }
      }
      // for (int i = 0; i < otherRegLocationList.length; i++) {
      //   location.add(({'id': otherRegLocationList[i].id}));
      // }
    } else {
      for (int i = 0; i < widget.branchId.length; i++) {
        location.add(({'id': widget.branchId[i]}));
      }
    }
    project = [
      {'id': widget.area}
    ];
    loadSettings();
  }

  var companyTaxNo = '';
  loadSettings() {
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();
    reportDesignList = ScopedModel.of<MainModel>(context).getReportDesign();
    companyTaxNo = ComSettings.getValue('GST-NO', settings!);

    var form = widget.type == 'ledger'
        ? 'Ledger Report'
        : widget.statement; //'ReceivblesDebitOnly';
    api.getReportDesignByName(form).then((value) => reportDesign = value);
    fullLedgerReprt = ComSettings.appSettings('bool', 'key-ledger-report-all', false);
    cardWIseLedger = ComSettings.appSettings('bool', 'key-ledger-report-card', false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  int menuId = 0;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Wrap(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(3))),
                                    onPressed: () {
                                      setState(() {});
                                      Navigator.of(context).pop();
                                      showDateBottomSheet(context);
                                    },
                                    child: const Text(
                                      'Date',
                                      style: TextStyle(
                                          fontFamily: 'poppins', color: white),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(3))),
                                    onPressed: () {
                                      setState(() {});
                                      Navigator.of(context).pop();
                                      showParticularsBottomSheet(context);
                                    },
                                    child: const Text(
                                      'Particulars',
                                      style: TextStyle(
                                          fontFamily: 'poppins', color: white),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(3))),
                                    onPressed: () {
                                      setState(() {});
                                      Navigator.of(context).pop();
                                      showDebitBottomSheet(context);
                                    },
                                    child: const Text(
                                      'Debit',
                                      style: TextStyle(
                                          fontFamily: 'poppins', color: white),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(3))),
                                    onPressed: () {
                                      setState(() {});
                                      Navigator.of(context).pop();
                                      showCreditBottomSheet(context);
                                    },
                                    child: const Text(
                                      'Credit',
                                      style: TextStyle(
                                          fontFamily: 'poppins', color: white),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(3))),
                                    onPressed: () {
                                      setState(() {});
                                      Navigator.of(context).pop();
                                      showBalanceBottomSheet(context);
                                    },
                                    child: const Text(
                                      'Balance',
                                      style: TextStyle(
                                          fontFamily: 'poppins', color: white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              icon: Image.asset('assets/icons/ic_filter.png',scale: 3.3,),
            ),
            PopupMenuButton(
              icon: Image.asset('assets/icons/ic_share.png',scale: 3.3,),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  child: Text('PDF'),
                  value: 1,
                ),
                const PopupMenuItem(
                  child: Text('CSV'),
                  value: 2,
                ),
              ],
              onSelected: (
                menuId,
              ) {
                setState(() {
                  if (menuId == 1) {
                     _createPDF('Ledger Report ' +
            widget.name +
            ' Date :' +
            DateUtil.dateDMY(widget.sDate) +
            ' - ' +
            DateUtil.dateDMY(widget.eDate))
        .then((value) {
      // Show a success message or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF downloaded successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      
      if (value.isNotEmpty && !kIsWeb) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PDFScreen(
            pathPDF: value,
            subject: widget.name +
                ' Date :' +
                DateUtil.dateDMY(widget.sDate) +
                ' - ' +
                DateUtil.dateDMY(widget.eDate),
            text: 'this is ' +
                widget.name +
                ' Date :' +
                DateUtil.dateDMY(widget.sDate) +
                ' - ' +
                DateUtil.dateDMY(widget.eDate),
          ),
        ));
      }
    });
                    // _createPDF('Ledger Report ' +
                    //         widget.name +
                    //         ' Date :' +
                    //         DateUtil.dateDMY(widget.sDate) +
                    //         ' - ' +
                    //         DateUtil.dateDMY(widget.eDate))
                    //     .then((value) =>
                    //         Navigator.of(context).push(MaterialPageRoute(
                    //             builder: (_) => PDFScreen(
                    //                   pathPDF: value,
                    //                   subject: widget.name +
                    //                       ' Date :' +
                    //                       DateUtil.dateDMY(widget.sDate) +
                    //                       ' - ' +
                    //                       DateUtil.dateDMY(widget.eDate),
                    //                   text: 'this is ' +
                    //                       widget.name +
                    //                       ' Date :' +
                    //                       DateUtil.dateDMY(widget.sDate) +
                    //                       ' - ' +
                    //                       DateUtil.dateDMY(widget.eDate),
                    //                 ))));
                  } else if (menuId == 2) {
                    Future.delayed(const Duration(milliseconds: 1000), () {
                      _createCSV(widget.name +
                              ' Date :' +
                              DateUtil.dateDMY(widget.sDate) +
                              ' - ' +
                              DateUtil.dateDMY(widget.eDate))
                          .then((value) {
                        var text = 'this is ' +
                            widget.name +
                            ' Date :' +
                            DateUtil.dateDMY(widget.sDate) +
                            ' - ' +
                            DateUtil.dateDMY(widget.eDate);
                        var subject = widget.name +
                            ' Date :' +
                            DateUtil.dateDMY(widget.sDate) +
                            ' - ' +
                            DateUtil.dateDMY(widget.eDate);
                        List<String> paths = [];
                        paths.add(value);
                        urlFileShare(context, text, subject, paths);
                      });
                    });
                  }
                });
              },
            )
            // IconButton(
            //     icon: const Icon(Icons.share_rounded),
            //     onPressed: () {
            //       setState(
            //         () {
            //           Future.delayed(const Duration(milliseconds: 1000), () {
            //             _createPDF(widget.name +
            //                     ' Date :' +
            //                     DateUtil.dateDMY(widget.sDate) +
            //                     ' - ' +
            //                     DateUtil.dateDMY(widget.eDate))
            //                 .then((value) =>
            //                     Navigator.of(context).push(MaterialPageRoute(
            //                         builder: (_) => PDFScreen(
            //                               pathPDF: value,
            //                               subject: widget.name +
            //                                   ' Date :' +
            //                                   DateUtil.dateDMY(widget.sDate) +
            //                                   ' - ' +
            //                                   DateUtil.dateDMY(widget.eDate),
            //                               text: 'this is ' +
            //                                   widget.name +
            //                                   ' Date :' +
            //                                   DateUtil.dateDMY(widget.sDate) +
            //                                   ' - ' +
            //                                   DateUtil.dateDMY(widget.eDate),
            //                             ))));
            //           });
            //         },
            //       );
            //     }),
          ],
          // title: Text(widget.type),
          title: Text(
            (widget.type == 'ledger'
            ? 'Ledger': widget.type == 'ReceiptList'
            ? 'Receipt List' 
            : widget.type == 'PaymentList' 
            ? 'Payment List' 
            : widget.type == 'BankReceiptList'
            ? 'Bank Receipt List'
            : widget.type == 'BankPaymentList'
            ? 'Bank Payment List'
            : widget.type),
            style: const TextStyle(fontFamily: 'poppins',color: white,),
          ),
        ),
        body:Align(
          alignment: Alignment.topCenter,
          child: (widget.type == 'ledger' ||
                  widget.type == 'Day Book' ||
                  widget.type == 'Trial Balance' ||
                  widget.type == 'Cash Flow' ||
                  widget.type == 'Invoice Wise Balance Customers' ||
                  widget.type == 'Invoice Wise Balance Suppliers'
              ? reportView()
              : widget.type == 'Fund Flow'
                  ? reportViewFundFlow()
                  : widget.type == 'Cheque'
                      ? reportViewBankVouchers()
                      : widget.type == 'User Activity'
                          ? reportViewUserActivity()
                          : widget.type == 'Monthly Sales'
                              ? reportViewMonthlySalesReport(widget.branchId)
                              : widget.type == 'Monthly Purchase'
                                  ? reportViewMonthlyPurchase(widget.branchId)
                                  : widget.type == 'Bill By Bill'
                                      ? reportViewSalesBillByBill()
                                      : widget.type == 'GroupList'
                                          ? reportViewGroupList()
                                          : widget.type == 'LedgerList'
                                              ? reportViewLedgerList()
                                              : widget.type ==
                                                      'Closing Report'
                                                  ? reportViewClosingReport()
                                                  : widget.type ==
                                                          'EmployeeList'
                                                      ? reportViewEmployeeList()
                                                      : widget.type ==
                                                              'CustomerCardList'
                                                          ? reportViewCustomerCardList()
                                                          : widget.type ==
                                                                  'P&L Account'
                                                              ? reportViewProfitAndLossAccount()
                                                              : widget.type ==
                                                                      'BalanceSheet'
                                                                  ? reportViewBalanceSheet()
                                                                  : widget.type ==
                                                                              'Payable' ||
                                                                          widget.type ==
                                                                              'Receivable'
                                                                      ? reportViewReceivablePayable()
                                                                      : widget.type == 'PaymentList' ||
                                                                              widget.type == 'ReceiptList' ||
                                                                              widget.type == 'JournalList'
                                                                           ? reportVoucherList()
                                                                          : widget.type == 'BankReceiptList' ||
                                                                                    widget.type == 'BankPaymentList'
                                                                                       ?  reportBankVoucherList()              
                                                                                       : const Center(child: Text('No Report'))),
        ));
  }

   bool classic = false;
  final GlobalKey _globalKey = GlobalKey();

    showEditDialog(context, int _id,String voucher) {
    ConfirmAlertBox(
        buttonColorForNo: Colors.red,
        buttonColorForYes: Colors.green,
        icon: Icons.check,
        onPressedNo: () {
          Navigator.of(context).pop();
        },
        onPressedYes: () {
          Navigator.of(context).pop();
          ComSettings.appSettings('bool', 'key-simple-sales', false)
              ? Navigator.pushNamed(context, '/SimpleSale')
              : Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Sale(
                        oldSale: true,
                        thisSale: false,
                      )));
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage: 'Do you want to edit or delete\nRefNo:$_id',
        title: 'Update $voucher',
        context: context);
  }

  showEditRvPvDialog(context, int _id,String voucher) {
    ConfirmAlertBox(
        buttonColorForNo: Colors.red,
        buttonColorForYes: Colors.green,
        icon: Icons.check,
        onPressedNo: () {
          Navigator.of(context).pop();
        },
        onPressedYes: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const RPVoucher(
            oldRvPv: true,
          ),
          settings: RouteSettings(
            arguments: {
              'dataDynamic': [
                {
                  'RealEntryNo': int.tryParse(_id.toString() ?? '0'),
                  'EntryNo': int.tryParse(_id.toString() ?? '0'),
                  'Id': int.tryParse(_id.toString() ?? '0'),
                  'Type': '0'
                }
              ],
              'mode': voucher == 'RECEIPT' ? 'Receipt' : 'Payment',
              'fromDaily':'1'
            },
          ),
        ),
      );
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage: 'Do you want to edit or delete\nRefNo:$_id',
        title: 'Update $voucher',
        context: context);
  }

  showEditBankRvPvDialog(context, int _id,String voucher) {
    ConfirmAlertBox(
        buttonColorForNo: Colors.red,
        buttonColorForYes: Colors.green,
        icon: Icons.check,
        onPressedNo: () {
          Navigator.of(context).pop();
        },
        onPressedYes: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const BankVoucher(
            oldRvPv: true,
          ),
          settings: RouteSettings(
            arguments: {
              'dataDynamic': [
                {
                  'RealEntryNo': int.tryParse(_id.toString() ?? '0'),
                  'EntryNo': int.tryParse(_id.toString() ?? '0'),
                  'Id': int.tryParse(_id.toString() ?? '0'),
                  'Type': '0'
                }
              ],
              'voucher': voucher == 'BANK-RECEIPT' ? 'Receipt' : 'Payment',
              'fromDaily':'1'
            },
          ),
        ),
      );
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage: 'Do you want to edit or delete\nRefNo:$_id',
        title: 'Update $voucher',
        context: context);
  }

  showEditPurchaseDialog(context, int _id,String voucher) {
    ConfirmAlertBox(
        buttonColorForNo: Colors.red,
        buttonColorForYes: Colors.green,
        icon: Icons.check,
        onPressedNo: () {
          Navigator.of(context).pop();
        },
        onPressedYes: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const Purchase(
                    oldPurchase: true,
                  )));
        },
        buttonTextForNo: 'No',
        buttonTextForYes: 'YES',
        infoMessage: 'Do you want to edit or delete\nRefNo:$_id',
        title: 'Update $voucher',
        context: context);
  }

  void _handleEntryNoTap(Map<String, dynamic> values, BuildContext context, int index) {
  final voucher = values['Voucher']?.toString() ?? '';
  
  if (voucher.startsWith('SALES-')) {
    try {
      final voucherType = voucher;
      // SalesType? sData;
      try {
        salesTypeData = salesTypeList.firstWhere(
          (element) => element.type == voucherType,
        );
      } catch (e) {
        salesTypeData = salesTypeList.firstWhere(
          (element) => element.name.contains(voucherType),
        );
      }
      
      if (salesTypeData != null) {
         dataDynamic = [
          {
            'RealEntryNo': int.tryParse(values['EntryNo']?.toString() ?? '0'),
            'EntryNo': int.tryParse(values['EntryNo']?.toString() ?? '0'),
            'Id': int.tryParse(values['EntryNo']?.toString() ?? '0'),
            'InvoiceNo': int.tryParse(values['EntryNo']?.toString() ?? '0'),
            'Type': salesTypeData!.id.toString()
          }
        ];
        
        showEditDialog(context, int.tryParse(values['EntryNo']?.toString() ?? '0') ?? 0,voucherType);
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sales type not found for voucher: $voucher'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } else if (voucher == 'RECEIPT' || voucher == 'PAYMENT'){
       showEditRvPvDialog(context, int.tryParse(values['EntryNo']?.toString() ?? '0') ?? 0,voucher);
  } else if(voucher == 'BANK-RECEIPT' || voucher == 'BANK-PAYMENT'){
       showEditBankRvPvDialog(context, int.tryParse(values['EntryNo']?.toString() ?? '0') ?? 0,voucher);
  } else if (voucher == 'PURCHASE'){
   VoucherType? voucherTypeData;
     try {
        voucherTypeData = voucherTypeList.firstWhere(
          (element) => element.voucher.toUpperCase() == voucher,
        );
      } catch (e) {
        voucherTypeData = voucherTypeList.firstWhere(
          (element) => element.voucher.toUpperCase().contains(voucher),
        );
      }
     if (voucherTypeData != null) {
         dataDynamic = [
          {
            'RealEntryNo': int.tryParse(values['EntryNo']?.toString() ?? '0'),
            'EntryNo': int.tryParse(values['EntryNo']?.toString() ?? '0'),
            'Id': int.tryParse(values['EntryNo']?.toString() ?? '0'),
            'InvoiceNo': int.tryParse(values['EntryNo']?.toString() ?? '0'),
            'Type': voucherTypeData.id.toString()
          }
        ];
        
        showEditPurchaseDialog(context, int.tryParse(values['EntryNo']?.toString() ?? '0') ?? 0,voucher);
      }  
  }
}

Widget _ledgerCard(Map<String, dynamic> row, int index) {
  String date = row['Date']?.toString() ?? '';
  String particulars = row['Particulars']?.toString() ?? '';
  String voucher = row['Voucher']?.toString() ?? '';
  String debit = row['Debit']?.toString() ?? '';
  String credit = row['Credit']?.toString() ?? '';
  String balance = row['Balance']?.toString() ?? '';
  String entryNo = row['EntryNo']?.toString() ?? '';
  String narration = row['Narration']?.toString() ?? '';

  if (debit.contains('===') || credit.contains('===') || 
      particulars.contains('===') || date.contains('===') || particulars.isEmpty) {
    return const SizedBox.shrink();
  }

  bool isOpeningBalance = particulars.toLowerCase().contains('opening balance');
  bool isClosingBalance = particulars.toLowerCase().contains('closing balance');
  bool isSpecialEntry = isOpeningBalance || isClosingBalance;

  String amount = '';
  String amountType = '';
  Color amountColor = Colors.black;
  
  if (debit.isNotEmpty && debit != '0.00' && debit != '0') {
    amount = debit;
    amountType = 'Dr';
    // amountColor = Colors.red;
  } else if (credit.isNotEmpty && credit != '0.00' && credit != '0') {
    amount = credit;
    amountType = 'Cr';
    // amountColor = Colors.green;
  }

  String balanceDisplay = '';
  if (balance.isNotEmpty && !balance.contains('===')) {
    if (balance.toLowerCase().contains('dr')) {
      balanceDisplay = balance;
    } else if (balance.toLowerCase().contains('cr')) {
      balanceDisplay = balance;
    } else if (balance.isNotEmpty && balance != '0.00' && balance != '0') {
      bool isBalanceDebit = debit.isNotEmpty && debit != '0.00';
      balanceDisplay = '$balance ${isBalanceDebit ? 'Dr' : 'Cr'}';
    }
  }

  return GestureDetector(
    onDoubleTap: () {
       if(companyUserData!.userType == 'Admin'){
        _handleEntryNoTap(
            row, context, index);
      }
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
         decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: white,
              ),
        padding: const EdgeInsets.all(12),      
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (date.isNotEmpty || voucher.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${_formatDate(date)}${voucher.isNotEmpty ? ' · $voucher' : ''} ${entryNo.isNotEmpty ? '#$entryNo' : ''}',
                  style: TextStyle(
                    // fontSize: 12,
                    color: Colors.grey.shade500,
                    // fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    isSpecialEntry ? particulars : (particulars.isNotEmpty ? particulars : '—'),
                    style: TextStyle(
                      fontWeight: isSpecialEntry ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,
                      color:
                      // isOpeningBalance ? Colors.blue : 
                      //        isClosingBalance ? kPrimaryColor : 
                             Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (amount.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Text(
                      '${_formatAmount(amount)} $amountType',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: amountColor,
                      ),
                    ),
                  ),
              ],
            ),
          
            if (balanceDisplay.isNotEmpty)
              if(!isOpeningBalance)
              Container(
                margin: const EdgeInsets.only(top: 4),
                alignment: Alignment.centerRight,
                child: Text(
                  balanceDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
    
            if(widget.statement == 'Ledger_Report_Qty')
             ...row.entries
                .where((entry) =>
                    entry.value != null &&
                    entry.value.toString().trim().isNotEmpty &&
                    !entry.value.toString().contains('===') &&
                    !_isMainField(entry.key))
                .map((entry) {
              return Container(
                margin: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${entry.key}:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if(widget.statement != 'Ledger_Report_Qty')
            if(narration.isNotEmpty)
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                  Divider(
                    thickness: 0.2,
                    color: Colors.grey.shade400,
                  ),
                   Container(
                    margin: const EdgeInsets.only(top: 4),
                    child: Text(
                      narration,
                       style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        // fontWeight: FontWeight.w500,
                      ),
                    ),
                               ),
                 ],
               )
          ],
        ),
      ),
    ),
  );
}

String _formatDate(String date) {
  if (date.isEmpty) return '';
  try {
    if (date.contains('/')) {
      List parts = date.split('/');
      if (parts.length == 3) {
        String day = parts[0];
        String month = _getMonthAbbreviation(int.parse(parts[1]));
        String year = parts[2].substring(parts[2].length - 2);
        return '$day/$month/$year';
      }
    }
    return date;
  } catch (e) {
    return date;
  }
}

String _getMonthAbbreviation(int month) {
  const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 
                  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
  return months[month - 1];
}

String _formatAmount(String amount) {
  try {
    double value = double.parse(amount);
    if (value == value.floor()) {
      return value.toStringAsFixed(0);
    } else {
      return value.toStringAsFixed(2);
    }
  } catch (e) {
    return amount;
  }
}

bool _isMainField(String key) {
  return key == 'Date' ||
      key == 'Particulars' ||
      key == 'Voucher' ||
      key == 'EntryNo' ||
      key == 'Debit' ||
      key == 'Credit' ||
      key == 'Balance';
}

Widget cardView(double totalAmount, String closingBalance) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
         Center(
          child: Text(widget.name +
              ' Date : From ' +
              DateUtil.dateDMY(widget.sDate) +
              ' To ' +
              DateUtil.dateDMY(widget.eDate)),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: white,
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹ ${_formatAmount(totalAmount.toString())}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: white,
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Closing balance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      closingBalance.isNotEmpty ? closingBalance : '0.00',
                      style: const TextStyle(
                        // fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        // color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget headerSection(List<dynamic> data) {
  double totalAmount = 0.0;
  String closingBalance = '';

  for (var row in data) {
    String debit = row['Debit']?.toString() ?? '';
    String credit = row['Credit']?.toString() ?? '';

    if (row['Particulars'] == "Closing Balance") {
      if (debit.isNotEmpty && debit != '0.00') {
        closingBalance = '$debit Dr';
      } else {
        closingBalance = '$credit Cr';
      }
    } else if(row['Particulars'] == ''){
      if (debit.isNotEmpty && debit != '0.00') {
        totalAmount += double.tryParse(debit) ?? 0.0;
      }
      if (credit.isNotEmpty && credit != '0.00') {
        totalAmount += double.tryParse(credit) ?? 0.0;
      }
    }
  }

  return cardView(totalAmount, closingBalance);
}


  reportView() {
      if (widget.type != 'ledger') {
      classic = true;
    }else {
       if(fullLedgerReprt){
        classic = true;
      } else{
        classic = false;
      }
    }

    project = [
      {'id': widget.partyId}
    ];

    var dataJson = '[${json.encode({
          'statementType':
              widget.statement.isEmpty ? 'Ledger_Report' : widget.statement,
          'sDate': widget.sDate.isEmpty ? '' : widget.sDate,
          'eDate': widget.eDate.isEmpty ? '' : widget.eDate,
          'id': widget.id ?? '',
          'Check_openingbalance': widget.ob ?? 0,
          'location': jsonEncode(location),
          'project': jsonEncode(project),
          'salesMan': 0,
          'fyId': currentFinancialYear!.id,
          'partyId': widget.partyId
        })}]';
   return FutureBuilder<List<dynamic>>(
      future: api.fetchLedgerReport(dataJson),
      builder: (ctx, snapshot) {
        debugPrint(snapshot.data.toString());
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            if (widget.statement == 'Ledger_Report_Qty') {
              var filterItems = data;
              for (ReportDesign design in reportDesignList!) {
                if (!design.visibility) {
                  for (var item in filterItems!) {
                    item.remove(design.caption.trim());
                  }
                }
              }
              // Map<String, dynamic> singleItem = {"type": "P"};
              // filterItems.removeWhere(
              //     (element) => element.keys. =>  == singleItem.keys.first);
              data = filterItems;  
            } else {
              var filterItems = data;
              for (ReportDesign design in reportDesign!) {
                if (!design.visibility) {
                  for (var item in filterItems!) {
                    item.remove(design.caption.replaceAll(' ', '').trim());
                  }
                }
              }
            }
            tableColumn = data![0].keys.toList();
            if (widget.type == 'Invoice Wise Balance Customers' ||
                widget.type == 'Invoice Wise Balance Suppliers' ||
                widget.type == 'Payable' ||
                widget.type == 'Receivable') {
              Map<String, dynamic> totalData = {};
              for (int i = 0; i < tableColumn.length; i++) {
                var cell = '';
                if (tableColumn[i].toLowerCase() == ('debit') ||
                    tableColumn[i].toLowerCase() == ('opbalance') ||
                    tableColumn[i].toLowerCase() == ('credit') ||
                    tableColumn[i].toLowerCase() == ('balance') ||
                    tableColumn[i].toLowerCase() == ('amount') ||
                    tableColumn[i].toLowerCase() == ('total')) {
                  cell = data!
                      .fold(
                          0.0,
                          (a, b) =>
                              a +
                              (double.tryParse(b[tableColumn[i]].toString()) ??
                                  0))
                      .toStringAsFixed(2);
                }
                if (i == 0) {
                  cell = 'Total';
                }
                totalData[tableColumn[i]] = cell;
              }
              if (totalData.isNotEmpty) {
                data!.add(totalData);
              }
              _data = data;
            } else {
              _data = data;
            }
            return classic
            ? Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: controller,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(widget.name +
                              ' Date : From ' +
                              DateUtil.dateDMY(widget.sDate) +
                              ' To ' +
                              DateUtil.dateDMY(widget.eDate)),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) => kPrimaryColor),
                            border: TableBorder.all(width: 1.0, color: grey),
                            columnSpacing: 12,
                            dataRowHeight: 20,
                            headingRowHeight: 30,
                            columns: [
                              for (int i = 0; i < tableColumn.length; i++)
                                DataColumn(
                                  label: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      tableColumn[i],
                                      style: const TextStyle(
                                          color: white, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                            rows: data
                                .asMap()
                                .entries
                                .map(
                                  (entry) {
                                    final index = entry.key;
                                    final values = entry.value;
                                    return DataRow(
                                      cells: [
                                        for (int i = 0; i < values.length; i++)
                                          tableColumn[i] == 'EntryNo'
                                              ? DataCell(
                                                  GestureDetector(
                                                    onDoubleTap: () {
                                                      if(companyUserData!.userType == 'Admin'){
                                                      _handleEntryNoTap(
                                                          values, context, index);
                                                    }
                                                    },
                                                    // onLongPress: () {
                                                    //  if(companyUserData!.userType == 'Admin'){
                                                    //    _handleEntryNoTap(
                                                    //       values, context, index);
                                                    //  }
                                                    // },
                                                    child: Align(
                                                      alignment: ComSettings.oKNumeric(
                                                        values[tableColumn[i]] != null
                                                            ? values[tableColumn[i]].toString()
                                                            : '',
                                                      )
                                                          ? Alignment.centerRight
                                                          : Alignment.centerLeft,
                                                      child: Text(
                                                        values[tableColumn[i]] != null
                                                            ? values[tableColumn[i]].toString()
                                                            : '',
                                                        softWrap: true,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : DataCell(
                                                  Align(
                                                    alignment: ComSettings.oKNumeric(
                                                      values[tableColumn[i]] != null
                                                          ? values[tableColumn[i]].toString()
                                                          : '',
                                                    )
                                                        ? Alignment.centerRight
                                                        : Alignment.centerLeft,
                                                    child: Text(
                                                      values[tableColumn[i]] != null
                                                          ? values[tableColumn[i]].toString()
                                                          : '',
                                                      softWrap: true,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                      ],
                                    );
                                  },
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                // ? Padding(
                //     padding: const EdgeInsets.all(5.0),
                //     child: SingleChildScrollView(
                //       scrollDirection: Axis.vertical,
                //       controller: controller,
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Center(
                //               child: Text(widget.name +
                //                   ' Date : From ' +
                //                   DateUtil.dateDMY(widget.sDate) +
                //                   ' To ' +
                //                   DateUtil.dateDMY(widget.eDate))),
                //           SingleChildScrollView(
                //             scrollDirection: Axis.horizontal,
                //             child: DataTable(
                //               headingTextStyle: const TextStyle(
                //                 color: white
                //               ),
                //               headingRowColor: MaterialStateColor.resolveWith(
                //                   (states) => kPrimaryColor),
                //               border: TableBorder.all(
                //                   width: 1.0, color: grey),
                //               columnSpacing: 12,
                //               dataRowHeight: 20,
                //               headingRowHeight: 30,
                //               columns: [
                //                 for (int i = 0; i < tableColumn.length; i++)
                //                   DataColumn(
                //                     label: Align(
                //                       alignment: Alignment.center,
                //                       child: Text(
                //                         tableColumn[i],
                //                         style: const TextStyle(
                //                             // color: Colors.black,
                //                             fontWeight: FontWeight.bold),
                //                         textAlign: TextAlign.center,
                //                       ),
                //                     ),
                //                   ),
                //               ],
                //               rows: data!
                //                   .map(
                //                     (values) => DataRow(
                //                       cells: [
                //                         for (int i = 0; i < values.length; i++)
                //                           DataCell(
                //                             Align(
                //                               alignment: ComSettings.oKNumeric(
                //                                 values[tableColumn[i]] != null
                //                                     ? values[tableColumn[i]]
                //                                         .toString()
                //                                     : '',
                //                               )
                //                                   ? Alignment.centerRight
                //                                   : Alignment.centerLeft,
                //                               child: Text(
                //                                 values[tableColumn[i]] != null
                //                                     ? values[tableColumn[i]]
                //                                         .toString()
                //                                     : '',
                //                                 softWrap: true,
                //                                 overflow: TextOverflow.ellipsis,
                //                                 //style: TextStyle(fontSize: 6),
                //                               ),
                //                             ),
                //                           ),
                //                       ],
                //                     ),
                //                   )
                //                   .toList(),
                //             ),
                //           ),
                //           // SizedBox(height: 500),
                //         ],
                //       ),
                //     ),
                //   )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "ACCOUNT SUMMERY",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  widget.name,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "From  ${widget.sDate}",
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      "To  ${widget.eDate}",
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 0,
                            ),
                            const Divider(
                              color: kPrimaryColor,
                            ),
                            Container(
                              height: 20,
                              color: kPrimaryColor,
                              child: Table(
                                columnWidths: const {
                                  0: FixedColumnWidth(45),
                                  1: FlexColumnWidth(15),
                                  2: FlexColumnWidth(8),
                                  3: FlexColumnWidth(9),
                                  4: FlexColumnWidth(8),
                                },
                                children: const[
                                  TableRow(children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:  [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '  Date',
                                          style: TextStyle(
                                              fontSize: 7,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:  [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '  Description',
                                          style: TextStyle(
                                              fontSize: 7,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children:  [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Debit',
                                          style: TextStyle(
                                              fontSize: 7,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children:  [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Credit',
                                          style: TextStyle(
                                              fontSize: 7,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children:  [
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Balanace",
                                          style: TextStyle(
                                              fontSize: 7,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ]),
                                ],
                                border: TableBorder.all(
                                    width: 1, color: kPrimaryColor),
                              ),
                            ),
                            Table(
                              columnWidths: const {
                                0: FixedColumnWidth(45),
                                1: FlexColumnWidth(15),
                                2: FlexColumnWidth(8),
                                3: FlexColumnWidth(9),
                                4: FlexColumnWidth(8),
                              },
                              children: [
                                for (var i = 0; i < data!.length; i++)
                                  TableRow(children: [
                                    Center(
                                        child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            // '10/20/2020',
                                            '${data![i]['Date']}',

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
                                        '${data![i]['Particulars']}',
                                        style: const TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${data![i]['Debit']}',
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
                                            '${data![i]['Credit']}',
                                            style: const TextStyle(
                                                fontSize: 6,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            "${data![i]['Balance']}",
                                            style: const TextStyle(
                                                fontSize: 6,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]),
                              ],
                              border:
                                  TableBorder.all(width: .1, color: kPrimaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
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
        // By default, show a loading spinner.
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
    // FutureBuilder<List<dynamic>>(
    //   future: _data,
    //   builder: (ctx, snapshot) {
    //     if (snapshot.hasData) {
    //       List<Map<String, dynamic>> data = snapshot.data;
    //       // print(data);
    //       return SingleChildScrollView(
    //         scrollDirection: Axis.vertical,
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: <Widget>[
    //             Text(widget.name +
    //                 'Date : From ' +
    //                 widget.sDate +
    //                 ' To ' +
    //                 widget.eDate),
    //             Padding(
    //               padding: EdgeInsets.only(top: 10.0),
    //               child: Center(
    //                 child: SingleChildScrollView(
    //                   scrollDirection: Axis.horizontal,
    //                   child: DataTable(
    //                     sortColumnIndex: 0,
    //                     sortAscending: true,
    //                     columns: [
    //                       DataColumn(
    //                         label: Text(
    //                           'Date',
    //                           style: TextStyle(
    //                             color: Colors.black,
    //                             fontSize: 18.0,
    //                           ),
    //                         ),
    //                         numeric: false,
    //                         tooltip: "Date",
    //                       ),
    //                       DataColumn(
    //                         label: Text(
    //                           'Particulars',
    //                           style: TextStyle(
    //                             color: Colors.black,
    //                             fontSize: 16.0,
    //                           ),
    //                         ),
    //                         numeric: true,
    //                         tooltip: "Particulars",
    //                       ),
    //                       DataColumn(
    //                         label: Text(
    //                           'Voucher',
    //                           style: TextStyle(
    //                             color: Colors.black,
    //                             fontSize: 16.0,
    //                           ),
    //                         ),
    //                         numeric: true,
    //                         tooltip: "Voucher",
    //                       ),
    //                       DataColumn(
    //                         label: Text(
    //                           'EntryNo',
    //                           style: TextStyle(
    //                             color: Colors.black,
    //                             fontSize: 16.0,
    //                           ),
    //                         ),
    //                         numeric: true,
    //                         tooltip: "EntryNo",
    //                       ),
    //                       DataColumn(
    //                         label: Text(
    //                           'Debit',
    //                           style: TextStyle(
    //                             color: Colors.black,
    //                             fontSize: 16.0,
    //                           ),
    //                         ),
    //                         numeric: true,
    //                         tooltip: "Debit",
    //                       ),
    //                       DataColumn(
    //                         label: Text(
    //                           'Credit',
    //                           style: TextStyle(
    //                             color: Colors.black,
    //                             fontSize: 16.0,
    //                           ),
    //                         ),
    //                         numeric: true,
    //                         tooltip: "Credit",
    //                       ),
    //                       DataColumn(
    //                         label: Text(
    //                           'Balance',
    //                           style: TextStyle(
    //                             color: Colors.black,
    //                             fontSize: 16.0,
    //                           ),
    //                         ),
    //                         numeric: true,
    //                         tooltip: "Balance",
    //                       ),
    //                       DataColumn(
    //                         label: Text(
    //                           'Narration',
    //                           style: TextStyle(
    //                             color: Colors.black,
    //                             fontSize: 16.0,
    //                           ),
    //                         ),
    //                         numeric: true,
    //                         tooltip: "Narration",
    //                       ),
    //                     ],
    //                     rows: data
    //                         .map(
    //                           (values) => DataRow(
    //                             cells: [
    //                               DataCell(
    //                                 Container(
    //                                   width: 100,
    //                                   child: Text(
    //                                     values['Date'],
    //                                     softWrap: true,
    //                                     overflow: TextOverflow.ellipsis,
    //                                     style: TextStyle(
    //                                         fontWeight: FontWeight.w600),
    //                                   ),
    //                                 ),
    //                               ),
    //                               DataCell(
    //                                 Container(
    //                                   width: 60.0,
    //                                   child: Center(
    //                                     child: Text(
    //                                       values['Particulars'].toString(),
    //                                       style: TextStyle(
    //                                           fontWeight: FontWeight.bold),
    //                                     ),
    //                                   ),
    //                                 ),
    //                               ),
    //                               DataCell(
    //                                 Container(
    //                                   child: Text(
    //                                     values['Voucher'].toString(),
    //                                     style: TextStyle(
    //                                         fontWeight: FontWeight.bold),
    //                                   ),
    //                                 ),
    //                               ),
    //                               DataCell(
    //                                 Container(
    //                                   child: Text(
    //                                     values['EntryNo'].toString(),
    //                                     style: TextStyle(
    //                                       fontWeight: FontWeight.bold,
    //                                     ),
    //                                     textAlign: TextAlign.right,
    //                                   ),
    //                                 ),
    //                               ),
    //                               DataCell(
    //                                 Container(
    //                                   child: Text(
    //                                     values['Debit'].toString(),
    //                                     style: TextStyle(
    //                                         fontWeight: FontWeight.bold),
    //                                     textAlign: TextAlign.right,
    //                                   ),
    //                                 ),
    //                               ),
    //                               DataCell(
    //                                 Container(
    //                                   child: Text(
    //                                     values['Credit'].toString(),
    //                                     style: TextStyle(
    //                                         fontWeight: FontWeight.bold),
    //                                     textAlign: TextAlign.right,
    //                                   ),
    //                                 ),
    //                               ),
    //                               DataCell(
    //                                 Container(
    //                                   child: Text(
    //                                     values['Balance'].toString(),
    //                                     style: TextStyle(
    //                                         fontWeight: FontWeight.bold),
    //                                     textAlign: TextAlign.right,
    //                                   ),
    //                                 ),
    //                               ),
    //                               DataCell(
    //                                 Container(
    //                                   child: Text(
    //                                     values['Narration'].toString(),
    //                                     style: TextStyle(
    //                                         fontWeight: FontWeight.bold),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         )
    //                         .toList(),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             // SizedBox(height: 500),
    //           ],
    //         ),
    //       );
    //     } else if (snapshot.hasError) {
    //       return AlertDialog(
    //         title: Text(
    //           'An Error Occurred!',
    //           textAlign: TextAlign.center,
    //           style: TextStyle(
    //             color: Colors.redAccent,
    //           ),
    //         ),
    //         content: Text(
    //           "${snapshot.error}",
    //           style: TextStyle(
    //             color: Colors.blueAccent,
    //           ),
    //         ),
    //         actions: <Widget>[
    //           TextButton(
    //             child: Text(
    //               'Go Back',
    //               style: TextStyle(
    //                 color: Colors.redAccent,
    //               ),
    //             ),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           )
    //         ],
    //       );
    //     }
    //     // By default, show a loading spinner.
    //     return Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: <Widget>[
    //           CircularProgressIndicator(),
    //           SizedBox(height: 20),
    //           Text('This may take some time..')
    //         ],
    //       ),
    //     );
    //   },
    // ),
  }
  
  reportViewReceivablePayable() {
    if (widget.type != 'ledger') {
      classic = true;
    } else {
      if (MediaQuery.of(context).orientation == Orientation.landscape) {
        classic = true;
      } else if(fullLedgerReprt){
        classic = true;
      } else{
        classic = false;
      }
    }

project = [
  {'id': widget.partyId}
];

var dataJson = '[' +
    json.encode({
      'statementType': widget.statement.isEmpty ? '' : widget.statement,
      'sDate': widget.sDate.isEmpty ? '' : widget.sDate,
      'eDate': widget.eDate.isEmpty ? '' : widget.eDate,
      'id': widget.id ?? '',
      'Check_openingbalance': widget.ob ?? 0,
      'location': jsonEncode(location),
      'project': jsonEncode(project),
      'salesMan': int.tryParse(widget.salesMan) ?? 0,
      'fyId': currentFinancialYear!.id,
      'partyId': widget.partyId
    }) +
    ']';
    debugPrint('reportView dataJson: $dataJson');
return FutureBuilder<List<dynamic>>(
  future: api.fetchLedgerReport(dataJson),
  builder: (ctx, snapshot) {
    if (snapshot.hasData) {
      if (snapshot.data!.isNotEmpty) {
        var data = snapshot.data;
        bool totalIsIn = false;
        if (widget.statement == 'Ledger_Report_Qty') {
          var filterItems = data;
          for (ReportDesign design in reportDesignList!) {
            if (!design.visibility) {
              for (var item in filterItems!) {
                item.remove(design.caption.trim());
              }
            }
          }
          // Map<String, dynamic> singleItem = {"type": "P"};
          // filterItems.removeWhere(
          //     (element) => element.keys. =>  == singleItem.keys.first);
          data = filterItems;
        } else {
          var filterItems = data;
          for (ReportDesign design in reportDesign!) {
            if (!design.visibility) {
              for (var item in filterItems!) {
                item.remove(design.caption.replaceAll(' ', '').trim());
              }
            }
          }
        }
        tableColumn = data![0].keys.toList();
        if (widget.statement == 'ReceiptWiseCustomerbalance' ||
            widget.statement == 'PaymentWiseSupplierbalance') {
          data = sortReceiptPaymentReport(data);
        }
        if (widget.type == 'Invoice Wise Balance Customers' ||
            widget.type == 'Invoice Wise Balance Suppliers' ||
            widget.type == 'Payable' ||
            widget.type == 'Receivable') {
          Map<String, dynamic> totalData = {};
          for (int i = 0; i < tableColumn.length; i++) {
            var cell = '';
            if (tableColumn[i].toLowerCase() == ('debit') ||
                tableColumn[i].toLowerCase() == ('opbalance') ||
                tableColumn[i].toLowerCase() == ('credit') ||
                tableColumn[i].toLowerCase() == ('balance') ||
                tableColumn[i].toLowerCase() == ('amount') ||
                tableColumn[i].toLowerCase() == ('total')) {
              cell = data
                  .fold(
                      0.0,
                      (a, b) =>
                          a +
                          (double.tryParse(b[tableColumn[i]].toString()) ??
                              0))
                  .toStringAsFixed(2);
            }
            if (i == 0) {
              cell = 'Total';
            }
            totalData[tableColumn[i]] = cell;
          }
          if (totalData.isNotEmpty & !totalIsIn) {
            data.add(totalData);
            totalIsIn = true;
          }
          _data = data;
        } else {
          _data = data;
        }
        return cardWIseLedger
        ? Column(
          children: [
            headerSection(data),
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: data!.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final row = data![index];
                  return _ledgerCard(row, index);
                },
              ),
            ),
          ],
        )
        : classic
            ? Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(widget.name +
                          ' Date : From ' +
                          DateUtil.dateDMY(widget.sDate) +
                          ' To ' +
                          DateUtil.dateDMY(widget.eDate)),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => kPrimaryColor),
                        border: TableBorder.all(width: 1.0, color: grey),
                        dataRowHeight: 22,
                        headingRowHeight: 30,
                        columns: [
                          for (int i = 0; i < tableColumn.length; i++)
                            DataColumn(
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  tableColumn[i],
                                  style: const TextStyle(
                                      color: white, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                        rows: data
                            .asMap()
                            .entries
                            .map(
                              (entry) {
                                final index = entry.key;
                                final values = entry.value;
                                return DataRow(
                                  cells: [
                                    for (int i = 0; i < values.length; i++)
                                      tableColumn[i] == 'EntryNo'
                                          ? DataCell(
                                              GestureDetector(
                                                onDoubleTap: () {
                                                  if(companyUserData!.userType == 'Admin'){
                                                  _handleEntryNoTap(
                                                      values, context, index);
                                                }
                                                },
                                                // onLongPress: () {
                                                //  if(companyUserData!.userType == 'Admin'){
                                                //    _handleEntryNoTap(
                                                //       values, context, index);
                                                //  }
                                                // },
                                                child: Align(
                                                  alignment: ComSettings.oKNumeric(
                                                    values[tableColumn[i]] != null
                                                        ? values[tableColumn[i]].toString()
                                                        : '',
                                                  )
                                                      ? Alignment.centerRight
                                                      : Alignment.centerLeft,
                                                      // child: Text(
                                                      //   tableColumn[i] == 'Narration'
                                                      //       ? splitNarration(values[tableColumn[i]]?.toString() ?? '')
                                                      //       : (values[tableColumn[i]]?.toString() ?? ''),
                                                      //   softWrap: true,
                                                      //   overflow: TextOverflow.visible,
                                                      // ),
                                                  child: Text(
                                                    values[tableColumn[i]] != null
                                                        ? values[tableColumn[i]].toString()
                                                        : '',
                                                    softWrap: true,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : DataCell(
                                              Align(
                                                alignment: ComSettings.oKNumeric(
                                                  values[tableColumn[i]] != null
                                                      ? values[tableColumn[i]].toString()
                                                      : '',
                                                )
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
                                                    // child: Text(
                                                    //     tableColumn[i] == 'Narration'
                                                    //         ? splitNarration(values[tableColumn[i]]?.toString() ?? '')
                                                    //         : (values[tableColumn[i]]?.toString() ?? ''),
                                                    //     softWrap: true,
                                                    //     overflow: TextOverflow.visible,
                                                    //   ),
                                                child: Text(
                                                  values[tableColumn[i]] != null
                                                      ? values[tableColumn[i]].toString()
                                                      : '',
                                                  softWrap: true,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                  ],
                                );
                              },
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ) : Padding(
                padding: const EdgeInsets.all(8.0),
                child: RepaintBoundary(
                  key: _globalKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              Text(
                              widget.statement == "Ledger_Report" || widget.statement == "Ledger_Report_Qty" 
                              ? 'LEDGER REPORT'
                              : "ACCOUNT SUMMARY",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              widget.name,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "From  ${DateUtil.dateDMY(widget.sDate)}",
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "To  ${DateUtil.dateDMY(widget.eDate)}",
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 0,
                        ),
                        const Divider(
                          color: kPrimaryColor,
                        ),
                        Container(
                          height: 20,
                          color: kPrimaryColor,
                          child: Table(
                            columnWidths: const {
                              0: FixedColumnWidth(45),
                              1: FlexColumnWidth(15),
                              2: FlexColumnWidth(8),
                              3: FlexColumnWidth(9),
                              4: FlexColumnWidth(8),
                            },
                            children: const [
                              TableRow(children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children:  [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '  Date',
                                      style: TextStyle(
                                          fontSize: 7,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children:  [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '  Description',
                                      style: TextStyle(
                                          fontSize: 7,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  children:  [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Debit',
                                      style: TextStyle(
                                          fontSize: 7,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  children:  [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Credit',
                                      style: TextStyle(
                                          fontSize: 7,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  children:  [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Balanace",
                                      style: TextStyle(
                                          fontSize: 7,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ]),
                            ],
                            border: TableBorder.all(
                                width: 1, color: kPrimaryColor),
                          ),
                        ),
                        Table(
                          columnWidths: const {
                            0: FixedColumnWidth(45),
                            1: FlexColumnWidth(15),
                            2: FlexColumnWidth(8),
                            3: FlexColumnWidth(9),
                            4: FlexColumnWidth(8),
                          },
                          children: [
                            for (var i = 0; i < data.length; i++)
                              TableRow(children: [
                                Center(
                                    child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        // '10/20/2020',
                                        '${data[i]['Date']}',

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
                                    '${data[i]['Particulars']}',
                                    style: const TextStyle(
                                        fontSize: 6,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${data[i]['Debit']?? ''}',
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
                                        '${data[i]['Credit'] ?? ''}',
                                        style: const TextStyle(
                                            fontSize: 6,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                        "${data[i]['Balance'] ?? ''}",
                                        style: const TextStyle(
                                            fontSize: 6,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                          ],
                          border:
                              TableBorder.all(width: .4, color: kPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
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


  List<dynamic> sortReceiptPaymentReport(List<dynamic> data) {
    Map<String, List<dynamic>> customerMap = {};

    for (var item in data) {
      String customer = '';

      if (item.containsKey('Customer')) {
        customer = item['Customer']?.toString() ?? '';
      } else if (item.containsKey('Particulars')) {
        customer = item['Particulars']?.toString() ?? '';
      }

      customer = customer.trim();

      if (!customerMap.containsKey(customer)) {
        customerMap[customer] = [];
      }

      customerMap[customer]!.add(item);
    }

    List<dynamic> finalList = [];

    customerMap.forEach((customer, items) {
      List<dynamic> opening = [];
      List<dynamic> transactions = [];
      List<dynamic> pending = [];
      List<dynamic> total = [];
      List<dynamic> others = [];

      for (var row in items) {
        String entryNo =
            (row['EntryNo'] ?? '').toString().trim().toLowerCase();

        if (entryNo.contains('opening')) {
          opening.add(row);
        }

        else if (entryNo.contains('pending')) {
          pending.add(row);
        }

        else if (entryNo.contains('total')) {
          total.add(row);
        }

        else if (entryNo.contains('sales') ||
            entryNo.contains('purchase') ||
            entryNo.contains('receipt') ||
            entryNo.contains('payment') ||
            entryNo.contains('sales-bc')) {
          transactions.add(row);
        } else {
          others.add(row);
        }
      }

      transactions.sort((a, b) {
        DateTime dateA = DateTime.tryParse(
                a['SalesDate']?.toString() ??
                    a['Date']?.toString() ??
                    '') ??
            DateTime(2000);

        DateTime dateB = DateTime.tryParse(
                b['SalesDate']?.toString() ??
                    b['Date']?.toString() ??
                    '') ??
            DateTime(2000);

        return dateA.compareTo(dateB);
      });

      finalList.addAll(opening);
      finalList.addAll(transactions);
      finalList.addAll(others);
      finalList.addAll(pending);
      finalList.addAll(total);
    });

    return finalList;
  }


  reportViewFundFlow() {
    var dataJson = '[' +
        json.encode({
          'statementType': widget.statement.isEmpty ? '' : widget.statement,
          'sDate': widget.sDate.isEmpty ? '' : widget.sDate,
          'eDate': widget.eDate.isEmpty ? '' : widget.eDate,
          'id': widget.id ?? '',
          'Check_openingbalance': widget.ob ?? 0,
          'location': jsonEncode(location),
          'project': jsonEncode(project),
          'salesMan': 0,
          'showClsStock' : widget.ob ?? 0
        }) +
        ']';
    return FutureBuilder<List<dynamic>>(
      future: api.fetchLedgerReport(dataJson),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            _data = data;
            tableColumn = data![0].keys.toList();
            int isLastRow = 0;
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                        child: Text(widget.name +
                            ' Date : From ' +
                            DateUtil.dateDMY(widget.sDate) +
                            ' To ' +
                            DateUtil.dateDMY(widget.eDate))),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            const MaterialStatePropertyAll(kPrimaryColor),
                        border: TableBorder.all(width: 1.0, color: grey),
                        headingTextStyle: const TextStyle(
                            fontFamily: 'poppins',
                            color: white,
                            fontWeight: FontWeight.w500),
                        columnSpacing: 12,
                        dataRowHeight: 20,
                        headingRowHeight: 30,
                        columns: [
                          for (int i = 0; i < tableColumn.length - 1; i++)
                            DataColumn(
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  tableColumn[i],
                                  style: const TextStyle(
                                      // color: Colors.black,
                                      // fontWeight: FontWeight.bold
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                        rows: data
                            .map(
                              (values) => DataRow(
                                color:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (isLastRow == data.length - 1) {
                                    isLastRow++;
                                    return blue;
                                  } else {
                                    isLastRow++;
                                    return white;
                                  }
                                }),
                                cells: [
                                  for (int i = 0; i < values.length - 1; i++)
                                    DataCell(
                                      Align(
                                        alignment: ComSettings.oKNumeric(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                        )
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                          style: TextStyle(
                                              backgroundColor:
                                                  values[tableColumn[3]] == 'H'
                                                      ? red[200]
                                                      : white),
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          //style: TextStyle(fontSize: 6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    // SizedBox(height: 500),
                  ],
                ),
              ),
            );
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
        // By default, show a loading spinner.
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

  reportViewBankVouchers() {
    return FutureBuilder<List<dynamic>>(
      future: api.fetchBankVouchers(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            _data = data;
            tableColumn = data![0].keys.toList();
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        const MaterialStatePropertyAll(kPrimaryColor),
                    border: TableBorder.all(width: 1.0, color: grey),
                    headingTextStyle: const TextStyle(
                        fontFamily: 'poppins',
                        color: white,
                        fontWeight: FontWeight.w500),
                    columnSpacing: 12,
                    dataRowHeight: 20,
                    headingRowHeight: 30,
                    columns: [
                      for (int i = 0; i < tableColumn.length; i++)
                        DataColumn(
                          label: Align(
                            alignment: Alignment.center,
                            child: Text(
                              tableColumn[i],
                              style: const TextStyle(
                                  // color: Colors.black,
                                  // fontWeight: FontWeight.bold
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                    rows: data
                        .map(
                          (values) => DataRow(
                            cells: [
                              for (int i = 0; i < values.length; i++)
                                DataCell(
                                  Align(
                                    alignment: ComSettings.oKNumeric(
                                      values[tableColumn[i]] != null
                                          ? values[tableColumn[i]].toString()
                                          : '',
                                    )
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Text(
                                      values[tableColumn[i]] != null
                                          ? values[tableColumn[i]].toString()
                                          : '',
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      //style: TextStyle(fontSize: 6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            );
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
        // By default, show a loading spinner.
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

  reportViewUserActivity() {
    return FutureBuilder<List<dynamic>>(
      future: api.fetchEventDetails(widget.sDate),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            _data = data;
            tableColumn = data![0].keys.toList();
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        const MaterialStatePropertyAll(kPrimaryColor),
                    border: TableBorder.all(width: 1.0, color: grey),
                    headingTextStyle: const TextStyle(
                        fontFamily: 'poppins',
                        color: white,
                        fontWeight: FontWeight.w500),
                    columnSpacing: 12,
                    dataRowHeight: 20,
                    headingRowHeight: 30,
                    columns: [
                      for (int i = 0; i < tableColumn.length; i++)
                        DataColumn(
                          label: Align(
                            alignment: Alignment.center,
                            child: Text(
                              tableColumn[i],
                              style: const TextStyle(
                                  // color: Colors.black,
                                  // fontWeight: FontWeight.bold
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                    rows: data
                        .map(
                          (values) => DataRow(
                            cells: [
                              for (int i = 0; i < values.length; i++)
                                DataCell(
                                  Align(
                                    alignment: ComSettings.oKNumeric(
                                      values[tableColumn[i]] != null
                                          ? values[tableColumn[i]].toString()
                                          : '',
                                    )
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Text(
                                      values[tableColumn[i]] != null
                                          ? values[tableColumn[i]].toString()
                                          : '',
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      //style: TextStyle(fontSize: 6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            );
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
        // By default, show a loading spinner.
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

  reportViewMonthlySalesReport(var branchId) {
    return FutureBuilder<List<dynamic>>(
      future: api.getMonthlySalesReport(branchId),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            _data = data;
            tableColumn = data![0].keys.toList();
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        const MaterialStatePropertyAll(kPrimaryColor),
                    border: TableBorder.all(width: 1.0, color: grey),
                    columnSpacing: 12,
                    headingTextStyle: const TextStyle(
                        fontFamily: 'poppins',
                        color: white,
                        fontWeight: FontWeight.w500),
                    dataRowHeight: 20,
                    headingRowHeight: 30,
                    columns: [
                      for (int i = 0; i < tableColumn.length; i++)
                        DataColumn(
                          label: Align(
                            alignment: Alignment.center,
                            child: Text(
                              tableColumn[i],
                              style: const TextStyle(
                                  // color: Colors.black,
                                  // fontWeight: FontWeight.bold
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                    rows: data
                        .map(
                          (values) => DataRow(
                            cells: [
                              for (int i = 0; i < values.length; i++)
                                DataCell(
                                  Align(
                                    alignment: ComSettings.oKNumeric(
                                      values[tableColumn[i]] != null
                                          ? values[tableColumn[i]].toString()
                                          : '',
                                    )
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Text(
                                      values[tableColumn[i]] != null
                                          ? values[tableColumn[i]].toString()
                                          : '',
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      //style: TextStyle(fontSize: 6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            );
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
        // By default, show a loading spinner.
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

  reportViewMonthlyPurchase(var branchId) {
    return FutureBuilder<List<dynamic>>(
      future: api.getMonthlyPurchaseReport(branchId),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            _data = data;
            tableColumn = data![0].keys.toList();
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        const MaterialStatePropertyAll(kPrimaryColor),
                    border: TableBorder.all(width: 1.0, color: grey),
                    columnSpacing: 12,
                    headingTextStyle: const TextStyle(
                        fontFamily: 'poppins',
                        color: white,
                        fontWeight: FontWeight.w500),
                    dataRowHeight: 20,
                    headingRowHeight: 30,
                    columns: [
                      for (int i = 0; i < tableColumn.length; i++)
                        DataColumn(
                          label: Align(
                            alignment: Alignment.center,
                            child: Text(
                              tableColumn[i],
                              style: const TextStyle(
                                  // color: Colors.black,
                                  // fontWeight: FontWeight.bold
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                    rows: data
                        .map(
                          (values) => DataRow(
                            cells: [
                              for (int i = 0; i < values.length; i++)
                                DataCell(
                                  Align(
                                    alignment: ComSettings.oKNumeric(
                                      values[tableColumn[i]] != null
                                          ? values[tableColumn[i]].toString()
                                          : '',
                                    )
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Text(
                                      values[tableColumn[i]] != null
                                          ? values[tableColumn[i]].toString()
                                          : '',
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      //style: TextStyle(fontSize: 6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            );
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
        // By default, show a loading spinner.
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

  reportViewSalesBillByBill() {
    var dataJson = '[' +
        json.encode({
          'statementType': widget.statement.isEmpty ? '' : widget.statement,
          'sDate': widget.sDate.isEmpty ? '' : widget.sDate,
          'eDate': widget.eDate.isEmpty ? '' : widget.eDate,
          'id': widget.id ?? '',
          'Check_openingbalance': widget.ob ?? 0,
          'location': jsonEncode(location),
          'project': jsonEncode(project),
          'salesMan': 0
        }) +
        ']';
    return FutureBuilder<List<dynamic>>(
      future: api.fetchLedgerReport(dataJson),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            _data = data;
            tableColumn = data![0].keys.toList();
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                        child: Text(widget.name +
                            ' Date : From ' +
                            DateUtil.dateDMY(widget.sDate) +
                            ' To ' +
                            DateUtil.dateDMY(widget.eDate))),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => kPrimaryColor),
                        border:
                            TableBorder.all(width: 1.0, color: grey),
                        columnSpacing: 12,
                        dataRowHeight: 20,
                        headingRowHeight: 30,
                        columns: [
                          for (int i = 0; i < tableColumn.length; i++)
                            DataColumn(
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  tableColumn[i],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                        rows: data
                            .map(
                              (values) => DataRow(
                                cells: [
                                  for (int i = 0; i < values.length; i++)
                                    DataCell(
                                      Align(
                                        alignment: ComSettings.oKNumeric(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                        )
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          //style: TextStyle(fontSize: 6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    // SizedBox(height: 500),
                  ],
                ),
              ),
            );
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
        // By default, show a loading spinner.
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

  reportViewGroupList() {
    var dataJson = '[' +
        json.encode({
          'statementType': widget.statement.isEmpty ? '' : widget.statement,
          'sDate': widget.sDate.isEmpty ? '' : widget.sDate,
          'eDate': widget.eDate.isEmpty ? '' : widget.eDate,
          'id': widget.id ?? '',
          'Check_openingBalance': widget.ob ?? 0,
          'location': jsonEncode(location),
          'city': jsonEncode(project),
          'salesMan': widget.salesMan.isNotEmpty ? widget.salesMan : '0',
          'hName': ''
        }) +
        ']';
    return FutureBuilder<List<dynamic>>(
      future: api.fetchGroupReport(dataJson),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            tableColumn = data![0].keys.toList();
            Map<String, dynamic> totalData = {};
            for (int i = 0; i < tableColumn.length; i++) {
              var cell = '';
              if (tableColumn[i].toLowerCase() == ('debit') ||
                  tableColumn[i].toLowerCase() == ('opbalance') ||
                  tableColumn[i].toLowerCase() == ('credit') ||
                  tableColumn[i].toLowerCase() == ('balance') ||
                  tableColumn[i].toLowerCase() == ('total')) {
                cell = data
                    .fold(
                        0.0,
                        (a, b) =>
                            a +
                            (double.tryParse(b[tableColumn[i]].toString()) ??
                                0))
                    .toStringAsFixed(2);
              }
              if (i == 0) {
                cell = 'Total';
              }
              totalData[tableColumn[i]] = cell;
            }
            if (totalData.isNotEmpty) {
              data.add(totalData);
            }
            _data = data;
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                        child: Text(widget.name +
                            ' Date : From ' +
                            DateUtil.dateDMY(widget.sDate) +
                            ' To ' +
                            DateUtil.dateDMY(widget.eDate))),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.grey.shade200),
                        border: TableBorder.all(width: 1.0, color: grey),
                        columnSpacing: 12,
                        dataRowHeight: 20,
                        // dividerThickness: 1,
                        headingRowHeight: 30,
                        columns: [
                          for (int i = 0; i < tableColumn.length; i++)
                            DataColumn(
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  tableColumn[i],
                                  style: const TextStyle(
                                      // color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                        rows: data
                            .map(
                              (values) => DataRow(
                                cells: [
                                  for (int i = 0; i < values.length; i++)
                                    DataCell(
                                      Align(
                                        alignment: ComSettings.oKNumeric(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                        )
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          //style: TextStyle(fontSize: 6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    // SizedBox(height: 500),
                  ],
                ),
              ),
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
        // By default, show a loading spinner.
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

  reportViewEmployeeList() {
    return FutureBuilder<List<dynamic>>(
      future: api.getEmployeeList(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            _data = data;
            tableColumn = data![0].keys.toList();
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            const MaterialStatePropertyAll(kPrimaryColor),
                        border: TableBorder.all(width: 1.0, color: grey),
                        columnSpacing: 12,
                        headingTextStyle: const TextStyle(
                            fontFamily: 'poppins',
                            color: white,
                            fontWeight: FontWeight.w500),
                        dataRowHeight: 20,
                        headingRowHeight: 30,
                        columns: [
                          for (int i = 0; i < tableColumn.length; i++)
                            DataColumn(
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  tableColumn[i],
                                  style: const TextStyle(
                                      // color: Colors.black,
                                      // fontWeight: FontWeight.bold
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                        rows: data
                            .map(
                              (values) => DataRow(
                                cells: [
                                  for (int i = 0; i < values.length; i++)
                                    DataCell(
                                      Align(
                                        alignment: ComSettings.oKNumeric(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                        )
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          //style: TextStyle(fontSize: 6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    // SizedBox(height: 500),
                  ],
                ),
              ),
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
        // By default, show a loading spinner.
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

  reportVoucherList() {
    String ledCode = widget.id;
    String location =
        widget.branchId.isNotEmpty ? widget.branchId[0].toString() : '1';
    String groupCode = '0';
    String project = '0';
    String fromDate = widget.sDate.isNotEmpty ? widget.sDate : '2000-01-01';
    String toDate = widget.eDate.isNotEmpty ? widget.eDate : '2000-01-01';
    String sDate = widget.sDate.isNotEmpty ? widget.sDate : '2000-01-01';
    String eDate = widget.eDate.isNotEmpty ? widget.eDate : '2000-01-01';
    String where = '';
    String cashId = widget.partyId.isNotEmpty
        ? widget.partyId
        : '0';
    String salesman = widget.salesMan.isNotEmpty ? widget.salesMan : '0';
    String statement = widget.type == 'PaymentList'
        ? 'PvListSummery'
        : widget.type == 'ReceiptList'
            ? 'RvListSummery'
            : widget.type == 'JournalList'
                ? 'JvList'
                : '';
    String areaId = widget.area.isNotEmpty ? widget.area : '0';
    String routeId = widget.route.isNotEmpty ? widget.route : '0';
    List<dynamic> dataFirmList = [
      {'FormId': widget.type == 'PaymentList' ? 1 : 2}
    ];
    return FutureBuilder<List<dynamic>>(
      future: api.getVoucherList(
          ledCode,
          location,
          groupCode,
          project,
          fromDate,
          toDate,
          sDate,
          eDate,
          where,
          cashId,
          salesman,
          statement,
          areaId,
          routeId,
          dataFirmList
          ),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            tableColumn = data![0].keys.toList();
            Map<String, dynamic> totalData = {};
            for (int i = 0; i < tableColumn.length; i++) {
              var cell = '';
              if (tableColumn[i].toLowerCase() == ('discount') ||
                  tableColumn[i].toLowerCase() == ('amount') ||
                  tableColumn[i].toLowerCase() == ('total')) {
                cell = data
                    .fold(
                        0.0,
                        (a, b) =>
                             a +
                            (double.tryParse(b[tableColumn[i]].toString()) ??
                                0))
                    .toStringAsFixed(2);
              }
              if (i == 0) {
                cell = 'Total';
              }
              totalData[tableColumn[i]] = cell;
            }
            if (totalData.isNotEmpty) {
              data.add(totalData);
            }
            _data = data;
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            const MaterialStatePropertyAll(kPrimaryColor),
                        border: TableBorder.all(width: 1.0, color: grey),
                        headingTextStyle: const TextStyle(
                            fontFamily: 'poppins', color: white),
                        columnSpacing: 12,
                        dataRowHeight: 20,
                        headingRowHeight: 30,
                        columns: [
                          for (int i = 0; i < tableColumn.length; i++)
                            DataColumn(
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  tableColumn[i],
                                  // style: const TextStyle(
                                  //     // color: Colors.black,
                                  //     fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                        rows: data
                            .map(
                              (values) => DataRow(
                                cells: [
                                  for (int i = 0; i < values.length; i++)
                                    DataCell(
                                      Align(
                                        alignment: ComSettings.oKNumeric(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                        )
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          //style: TextStyle(fontSize: 6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    // SizedBox(height: 500),
                  ],
                ),
              ),
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
        // By default, show a loading spinner.
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
  
  reportBankVoucherList() {
    String ledCode = widget.partyId;
    String location =
        widget.branchId.isNotEmpty ? widget.branchId[0].toString() : '1';
    int locationId = int.parse(location);
    String groupCode = '0';
    String project = '0';
    String fromDate = widget.sDate.isNotEmpty ? widget.sDate : '2000-01-01';
    String toDate = widget.eDate.isNotEmpty ? widget.eDate : '2000-01-01';
    String sDate = widget.sDate.isNotEmpty ? widget.sDate : '2000-01-01';
    String eDate = widget.eDate.isNotEmpty ? widget.eDate : '2000-01-01';
    String where = '';
    String cashId = '0';
    String salesman = widget.salesMan.isNotEmpty ? widget.salesMan : '0';
    String statement = widget.statement;
   String areaIdStr = widget.area.isNotEmpty ? widget.area : '0';
   int areaId = int.tryParse(areaIdStr.split('-')[0]) ?? 0;
    String routeId = widget.route.isNotEmpty ? widget.route : '0';
    List<dynamic> dataFirmList = [
      {'FormId': widget.type == 'PaymentList' ? 1 : 2}
    ];
    
    return FutureBuilder<List<dynamic>>(
      future: api.getBankVoucherList(
       sDate,
       eDate,
       '',
       areaId,
       int.parse(ledCode),
       0,
       widget.name,
       locationId,
       0,
       statement),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            tableColumn = data![0].keys.toList();
            Map<String, dynamic> totalData = {};
            for (int i = 0; i < tableColumn.length; i++) {
              var cell = '';
              if (tableColumn[i].toLowerCase() == ('discount') ||
                  tableColumn[i].toLowerCase() == ('amount') ||
                  tableColumn[i].toLowerCase() == ('total')) {
                cell = data
                    .fold(
                        0.0,
                        (a, b) =>
                             a +
                            (double.tryParse(b[tableColumn[i]].toString()) ??
                                0))
                    .toStringAsFixed(2);
              }
              if (i == 0) {
                cell = 'Total';
              }
              totalData[tableColumn[i]] = cell;
            }
            if (totalData.isNotEmpty) {
              data.add(totalData);
            }
            _data = data;
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            const MaterialStatePropertyAll(kPrimaryColor),
                        border: TableBorder.all(width: 1.0, color: grey),
                        headingTextStyle: const TextStyle(
                            fontFamily: 'poppins', color: white),
                        columnSpacing: 12,
                        dataRowHeight: 20,
                        headingRowHeight: 30,
                        columns: [
                          for (int i = 0; i < tableColumn.length; i++)
                            DataColumn(
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  tableColumn[i],
                                  // style: const TextStyle(
                                  //     // color: Colors.black,
                                  //     fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                        rows: data
                            .map(
                              (values) => DataRow(
                                cells: [
                                  for (int i = 0; i < values.length; i++)
                                    DataCell(
                                      Align(
                                        alignment: ComSettings.oKNumeric(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                        )
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          //style: TextStyle(fontSize: 6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    // SizedBox(height: 500),
                  ],
                ),
              ),
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
        // By default, show a loading spinner.
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


  reportViewCustomerCardList() {
    return FutureBuilder<List<dynamic>>(
      future: api.getCustomerCardList(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            _data = data;
            tableColumn = data![0].keys.toList();
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => kPrimaryColor),
                        border:
                            TableBorder.all(width: 1.0, color: grey),
                        columnSpacing: 12,
                        dataRowHeight: 20,
                        headingRowHeight: 30,
                        columns: [
                          for (int i = 0; i < tableColumn.length; i++)
                            DataColumn(
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  tableColumn[i],
                                  style: const TextStyle(
                                      // color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                        rows: data
                            .map(
                              (values) => DataRow(
                                cells: [
                                  for (int i = 0; i < values.length; i++)
                                    DataCell(
                                      Align(
                                        alignment: ComSettings.oKNumeric(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                        )
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          //style: TextStyle(fontSize: 6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    // SizedBox(height: 500),
                  ],
                ),
              ),
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
        // By default, show a loading spinner.
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

  reportViewLedgerList() {
    return FutureBuilder<List<dynamic>>(
      future: api.getLedgerListByType('Ledger_List'),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            _data = data;
            tableColumn = data![0].keys.toList();
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            const MaterialStatePropertyAll(kPrimaryColor),
                        border: TableBorder.all(width: 1.0, color: grey),
                        columnSpacing: 12,
                        headingTextStyle: const TextStyle(
                            fontFamily: 'poppins',
                            color: white,
                            fontWeight: FontWeight.w500),
                        dataRowHeight: 20,
                        headingRowHeight: 30,
                        columns: [
                          for (int i = 0; i < tableColumn.length; i++)
                            DataColumn(
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  tableColumn[i],
                                  style: const TextStyle(
                                      // color: Colors.black,
                                      // fontWeight: FontWeight.bold
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                        rows: data
                            .map(
                              (values) => DataRow(
                                cells: [
                                  for (int i = 0; i < values.length; i++)
                                    DataCell(
                                      Align(
                                        alignment: ComSettings.oKNumeric(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                        )
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          //style: TextStyle(fontSize: 6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    // SizedBox(height: 500),
                  ],
                ),
              ),
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
        // By default, show a loading spinner.
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

  reportViewClosingReport() {
    var dataJson = {
      'statementType': widget.statement.isEmpty ? '' : widget.statement,
      'sDate': widget.sDate.isEmpty ? '' : widget.sDate,
      'eDate': widget.eDate.isEmpty ? '' : widget.eDate,
      'location': location[0]['id'].toString(),
      'showSalesProfit' : int.tryParse(widget.route),
      'showProfit' : int.tryParse(widget.area)
    };
    return FutureBuilder<List<dynamic>>(
      future: widget.statement == 'AsperMart'
          ? api.fetchClosingReportAll(dataJson)
          : api.fetchClosingReport(dataJson),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            _data = data;
            List<dynamic> incomeData = [];
            List<dynamic> expenseData = [];
            List<dynamic> totalData = [];
            List<double> incomeListTotal = [];
            List<dynamic> incomeCollection = [];
            List<double> expenseListTotal = [];
            if (widget.statement == 'AsperMart') {
              List<dynamic> _incomeData = data![7];
              if (_incomeData.isNotEmpty) {
                List<double> listTotal = [];
                Map<String, dynamic> m = {"Particular": "Opening Balance"};
                m.addAll(_incomeData[0]);
                incomeData.add(m);
                Map<String, dynamic> m1 = {"Particular": "Collection"};
                m1.addAll(_incomeData[1]);
                incomeData.add(m1);
                List<String> _tempColumnTotal = _incomeData[0].keys.toList();
                for (int dataIndex = 0;
                    dataIndex < _incomeData.length;
                    dataIndex++) {
                  for (int i = 0; i < _tempColumnTotal.length; i++) {
                    Map _map = _incomeData[dataIndex];
                    var aa = _map[_tempColumnTotal[i].toString()] ?? 0;
                    double a2 = double.tryParse(aa.toString())!;
                    if (dataIndex == 0) {
                      listTotal.add(a2);
                    } else {
                      double oldItem = listTotal.elementAt(i);
                      listTotal.removeAt(i);
                      listTotal.insert(i, oldItem + a2);
                    }
                  }
                }
                Map<String, dynamic> mTotal = {"Particular": "Total"};
                int index = 0;
                for (var _n in _tempColumnTotal) {
                  mTotal[_n] = listTotal[index];
                  index++;
                }
                incomeData.add(mTotal);

                incomeCollection.add(incomeData.elementAt(1));
                incomeListTotal = listTotal;
              }
              List<dynamic> _expenseData = data[8];
              if (_expenseData.isNotEmpty) {
                List<double> listTotal = [];
                List<String> _tempColumnTotal = _expenseData[0].keys.toList();
                for (int dataIndex = 0;
                    dataIndex < _expenseData.length;
                    dataIndex++) {
                  for (int i = 1; i < _tempColumnTotal.length; i++) {
                    Map _map = _expenseData[dataIndex];
                    var aa = _map[_tempColumnTotal[i].toString()] ?? 0;
                    double a2 = double.tryParse(aa.toString())!;
                    if (dataIndex == 0) {
                      listTotal.add(a2);
                    } else {
                      double oldItem = listTotal.elementAt(i - 1);
                      listTotal.removeAt(i - 1);
                      listTotal.insert(i - 1, oldItem + a2);
                    }
                  }
                }
                Map<String, dynamic> mTotal = {"LedName": "Total"};

                for (int index = 1; index < _tempColumnTotal.length; index++) {
                  var _n = _tempColumnTotal[index];
                  mTotal[_n] = listTotal[index - 1];
                }
                expenseData = _expenseData;
                expenseData.add(mTotal);

                expenseListTotal = listTotal;
              }
              List<dynamic> _totalData = data[9];
              if (_totalData.isNotEmpty) {
                //todaycoll = incomecolletion row amount - exptotal
                //total = income total - expense total
                List<String> _tempColumnTotal = _totalData[0].keys.toList();
                for (int dataIndex = 0;
                    dataIndex < _totalData.length;
                    dataIndex++) {
                  Map _map = _totalData[dataIndex];

                  if (dataIndex == 0) {
                    Map<String, dynamic> mTotal = {
                      "Particulars": "Today Collection"
                    };
                    for (int index = 1;
                        index < _tempColumnTotal.length;
                        index++) {
                      var _n = _tempColumnTotal[index];
                      Map b0 = incomeCollection[0];
                      double b1 = b0[_n] != null
                          ? double.tryParse(b0[_n].toString())!
                          : 0;
                      double b2 = expenseListTotal.isNotEmpty
                          ? expenseListTotal[index - 1]
                          : 0;
                      mTotal[_n] = b1 - b2;
                    }
                    totalData.add(mTotal);
                  } else {
                    Map<String, dynamic> mTotal = {
                      "Particulars": "Total Balance"
                    };
                    for (int index = 1;
                        index < _tempColumnTotal.length;
                        index++) {
                      var _n = _tempColumnTotal[index];
                      mTotal[_n] = incomeListTotal[index - 1] -
                          (expenseListTotal.isNotEmpty
                              ? expenseListTotal[index - 1]
                              : 0);
                    }
                    totalData.add(mTotal);
                  }
                }
                // totalData = _totalData;
              }
              tableColumnIncome =
                  incomeData.isEmpty ? [] : incomeData[0].keys.toList();
              tableColumnExpense =
                  expenseData.isEmpty ? [] : expenseData[0].keys.toList();
              tableColumnTotal =
                  totalData.isEmpty ? [] : totalData[0].keys.toList();
            } else {
              tableColumn = data![0].keys.toList();
            }
            return widget.statement == 'AsperMart'
                ? Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: controller,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                                widget.statement +
                                    ' Closing' +
                                    ' Date : From ' +
                                    DateUtil.dateDMY(widget.sDate) +
                                    ' To ' +
                                    DateUtil.dateDMY(widget.eDate),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                children: [
                                  DataTable(
                                    headingRowColor: MaterialStatePropertyAll(kPrimaryColor),
                                    border: TableBorder.all(
                                        width: 1.0,
                                        color: grey,
                                        style: BorderStyle.solid),
                                    columnSpacing: 12,
                                    dataRowHeight: 20,
                                    dividerThickness: 1,
                                    headingRowHeight: 1,
                                    columns: const [
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                    ],
                                    rows: [
                                      DataRow(cells: [
                                        const DataCell(Text('Opening Balance',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text(
                                          data[0][0]['Amount'] == null
                                              ? ''
                                              : data[0][0]['Amount'].toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        const DataCell(Text(' ')),
                                        const DataCell(Text('Cash Bank',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text(
                                            data[1][0]['Amount'] == null
                                                ? ''
                                                : data[1][0]['Amount']
                                                    .toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                      ]),
                                      const DataRow(cells: [
                                        DataCell(Text('Sales',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text('Purchase',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text('Stock',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text('Receivable',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text('Payable',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                      ]),
                                      DataRow(cells: [
                                        DataCell(Text(
                                            data[2][0][''] == null
                                                ? ''
                                                : data[2][0][''].toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text(
                                            data[3][0]['Amount'] == null
                                                ? ''
                                                : data[3][0]['Amount']
                                                    .toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text(
                                            data[4][0][''] == null
                                                ? ''
                                                : data[4][0][''].toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text(
                                            data[5][0]['Amount'] == null
                                                ? ''
                                                : data[5][0]['Amount']
                                                    .toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text(
                                            data[6][0]['Amount'] == null
                                                ? ''
                                                : data[6][0]['Amount']
                                                    .toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                      ]),
                                    ],
                                  ),
                                  const SizedBox(
                                      child: Center(
                                          child: Text('INCOME',
                                              style: TextStyle(
                                                  backgroundColor: blue,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      height: 30,
                                      width: 350),
                                  tableColumnIncome.isEmpty
                                      ? const Center()
                                      : DataTable(
                                        headingRowColor: MaterialStatePropertyAll(kPrimaryColor),
                                          border: TableBorder.all(
                                              width: 1.0,
                                              color: grey,
                                              style: BorderStyle.solid),
                                          columnSpacing: 12,
                                          dataRowHeight: 20,
                                          dividerThickness: 1,
                                          headingRowHeight: 30,
                                          columns: [
                                            for (int i = 0;
                                                i < tableColumnIncome.length;
                                                i++)
                                              DataColumn(
                                                label: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    tableColumnIncome[i],
                                                    style: const TextStyle(
                                                        // color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                          ],
                                          rows: incomeData
                                              .map(
                                                (values) => DataRow(
                                                  cells: [
                                                    for (int i = 0;
                                                        i < values.length;
                                                        i++)
                                                      DataCell(
                                                        Text(
                                                          values[tableColumnIncome[
                                                                      i]] !=
                                                                  null
                                                              ? values[
                                                                      tableColumnIncome[
                                                                          i]]
                                                                  .toString()
                                                              : '',
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          //style: TextStyle(fontSize: 6),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                  const SizedBox(
                                      child: Center(
                                          child: Text('EXPENSE',
                                              style: TextStyle(
                                                  backgroundColor: blue,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      height: 30,
                                      width: 350),
                                  tableColumnExpense.isEmpty
                                      ? const Center()
                                      : DataTable(
                                        headingRowColor: MaterialStatePropertyAll(kPrimaryColor),
                                          border: TableBorder.all(
                                              width: 1.0,
                                              color: grey,
                                              style: BorderStyle.solid),
                                          columnSpacing: 12,
                                          dataRowHeight: 20,
                                          dividerThickness: 1,
                                          headingRowHeight: 30,
                                          columns: [
                                            for (int i = 0;
                                                i < tableColumnExpense.length;
                                                i++)
                                              DataColumn(
                                                label: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    tableColumnExpense[i],
                                                    style: const TextStyle(
                                                        // color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                          ],
                                          rows: expenseData
                                              .map(
                                                (values) => DataRow(
                                                  cells: [
                                                    for (int i = 0;
                                                        i < values.length;
                                                        i++)
                                                      DataCell(
                                                        Text(
                                                          values[tableColumnExpense[
                                                                      i]] !=
                                                                  null
                                                              ? values[
                                                                      tableColumnExpense[
                                                                          i]]
                                                                  .toString()
                                                              : '',
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          //style: TextStyle(fontSize: 6),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                  const SizedBox(
                                      child: Center(
                                          child: Text('TOTAL',
                                              style: TextStyle(
                                                  backgroundColor: blue,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      height: 30,
                                      width: 350),
                                  tableColumnTotal.isEmpty
                                      ? const Center()
                                      : DataTable(
                                        headingRowColor: MaterialStatePropertyAll(kPrimaryColor),
                                          border: TableBorder.all(
                                              width: 1.0,
                                              color: grey,
                                              style: BorderStyle.solid),
                                          columnSpacing: 12,
                                          dataRowHeight: 20,
                                          dividerThickness: 1,
                                          headingRowHeight: 30,
                                          columns: [
                                            for (int i = 0;
                                                i < tableColumnTotal.length;
                                                i++)
                                              DataColumn(
                                                label: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    tableColumnTotal[i],
                                                    style: const TextStyle(
                                                        // color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                          ],
                                          rows: totalData
                                              .map(
                                                (values) => DataRow(
                                                  cells: [
                                                    for (int i = 0;
                                                        i < values.length;
                                                        i++)
                                                      DataCell(
                                                        Text(
                                                          values[tableColumnTotal[
                                                                      i]] !=
                                                                  null
                                                              ? values[
                                                                      tableColumnTotal[
                                                                          i]]
                                                                  .toString()
                                                              : '',
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          //style: TextStyle(fontSize: 6),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                  const SizedBox(
                                      child: Center(
                                          child: Text('',
                                              style: TextStyle(
                                                  backgroundColor: blue,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      height: 30,
                                      width: 350),
                                  DataTable(
                                    headingRowColor: MaterialStatePropertyAll(kPrimaryColor),
                                    border: TableBorder.all(
                                        width: 0.5,
                                        color: grey,
                                        style: BorderStyle.solid),
                                    columnSpacing: 12,
                                    dataRowHeight: 20,
                                    dividerThickness: 1,
                                    headingRowHeight: 1,
                                    columns: const [
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                    ],
                                    rows: [
                                      const DataRow(cells: [
                                        DataCell(Text('Cash in Hand',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                        DataCell(Text('Bank In Hand',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                      ]),
                                      DataRow(cells: [
                                        DataCell(Text(
                                          data[10][0]['Amount'] == null
                                              ? ''
                                              : data[10][0]['Amount']
                                                  .toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                        DataCell(Text(
                                            data[11][0]['Amount'] == null
                                                ? ''
                                                : data[11][0]['Amount']
                                                    .toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                      ]),
                                    ],
                                  ),
                                ],
                              )),
                          // SizedBox(height: 500),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: controller,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                              child: Text(widget.name +
                                  ' Date : From ' +
                                  DateUtil.dateDMY(widget.sDate) +
                                  ' To ' +
                                  DateUtil.dateDMY(widget.eDate))),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateColor.resolveWith(
                                  (states) => kPrimaryColor),
                              border: TableBorder.all(
                                  width: 1.0, color: grey),
                              columnSpacing: 12,
                              dataRowHeight: 20,
                              headingRowHeight: 30,
                              columns: [
                                for (int i = 0; i < tableColumn.length; i++)
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        tableColumn[i],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'poppins'
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                              rows: data
                                  .map(
                                    (values) => DataRow(
                                      cells: [
                                        for (int i = 0; i < values.length; i++)
                                          DataCell(
                                            Align(
                                              alignment: ComSettings.oKNumeric(
                                                values[tableColumn[i]] != null
                                                    ? values[tableColumn[i]]
                                                        .toString()
                                                    : '',
                                              )
                                                  ? Alignment.centerRight
                                                  : Alignment.centerLeft,
                                              child: Text(
                                                values[tableColumn[i]] != null
                                                    ? values[tableColumn[i]]
                                                        .toString()
                                                    : '',
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                //style: TextStyle(fontSize: 6),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          // SizedBox(height: 500),
                        ],
                      ),
                    ),
                  );
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
        // By default, show a loading spinner.
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

  reportViewProfitAndLossAccount() {
    var dataJson = {
      'statementType': widget.statement.isEmpty ? '' : widget.statement,
      'sDate': widget.sDate.isEmpty ? '' : widget.sDate,
      'eDate': widget.eDate.isEmpty ? '' : widget.eDate,
      'stockValuation': widget.name.isEmpty ? '' : widget.name,
      'code': '',
      'location': widget.branchId[0].toString().isNotEmpty
          ? widget.branchId[0].toString()
          : '1',
      'fyId': currentFinancialYear!.id
    };
    return FutureBuilder<List<dynamic>>(
      future: api.fetchProfitAndLossAccount(dataJson),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            _data = data;
            tableColumn = data![0].keys.toList();
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                        child: Text(widget.name +
                            ' Date : From ' +
                            DateUtil.dateDMY(widget.sDate) +
                            ' To ' +
                            DateUtil.dateDMY(widget.eDate))),
                    const SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            const MaterialStatePropertyAll(kPrimaryColor),
                        border: TableBorder.all(width: 1.0, color: grey),
                        headingTextStyle: const TextStyle(
                            fontFamily: 'poppins', color: white),
                        columnSpacing: 12,
                        dataRowHeight: 20,
                        headingRowHeight: 30,
                        columns: [
                          for (int i = 0; i < tableColumn.length; i++)
                            DataColumn(
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  tableColumn[i],
                                  // style: const TextStyle(
                                  //     // color: Colors.black,
                                  //     fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                        rows: data
                            .map(
                              (values) => DataRow(
                                cells: [
                                  for (int i = 0; i < values.length; i++)
                                    DataCell(
                                      Align(
                                        alignment: ComSettings.oKNumeric(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                        )
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          //style: TextStyle(fontSize: 6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    // SizedBox(height: 500),
                  ],
                ),
              ),
            );
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
        // By default, show a loading spinner.
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

   reportViewBalanceSheet() {
    var dataJson = '[' +
        json.encode({
          'statementType': widget.statement.isEmpty ? '' : widget.statement,
          'sDate': widget.sDate.isEmpty ? '' : widget.sDate,
          'eDate': widget.eDate.isEmpty ? '' : widget.eDate,
          'stockValuation': widget.name.isEmpty ? '' : widget.name,
          'code': ''
        }) +
        ']';
    return FutureBuilder<List<dynamic>>(
      future: api.fetchBalanceSheet(dataJson),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            var data = snapshot.data;
            _data = data;
            tableColumn = data![0].keys.toList();
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                        child: Text(widget.name +
                            ' Date : From ' +
                            DateUtil.dateDMY(widget.sDate) +
                            ' To ' +
                            DateUtil.dateDMY(widget.eDate))),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.grey.shade200),
                        border:
                            TableBorder.all(width: 1.0, color: Colors.black),
                        columnSpacing: 12,
                        dataRowHeight: 20,
                        headingRowHeight: 30,
                        columns: [
                          for (int i = 0; i < tableColumn.length; i++)
                            DataColumn(
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  tableColumn[i],
                                  style: const TextStyle(
                                      // color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                        rows: data!
                            .map(
                              (values) => DataRow(
                                cells: [
                                  for (int i = 0; i < values.length; i++)
                                    DataCell(
                                      Align(
                                        alignment: ComSettings.oKNumeric(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                        )
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Text(
                                          values[tableColumn[i]] != null
                                              ? values[tableColumn[i]]
                                                  .toString()
                                              : '',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          //style: TextStyle(fontSize: 6),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    // SizedBox(height: 500),
                  ],
                ),
              ),
            );
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
        // By default, show a loading spinner.
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

   Future<String> _createPDF(String title) async {
    return await makePDF(title).then((value) => savePreviewPDF(value, title));
  }

  Future<pw.Document> makePDF(String title) async {
    // var tableHeaders = [
    //   "Date",
    //   "Particulars",
    //   "Voucher",
    //   "EntryNo",
    //   "Debit",
    //   "Credit",
    //   "Balance",
    //   "Narration"
    // ];
    // tableHeaders=tableColumn;

    var data = _data;
    final pw.Document pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
        // pageFormat: PdfPageFormat.a4,
        maxPages: 100,
        header: (context) => pw.Column(children: [
              pw.Center(
                  child: pw.Column(children: [
                pw.Text(companySettings!.name),
                pw.Text(companySettings!.add1!),
                pw.Text(companySettings!.add2!),
                pw.Text(companySettings!.add3!),
                pw.Text(companySettings!.mobile!),
                pw.Text(companyTaxNo.isNotEmpty
                    ? (companyTaxMode == 'INDIA'
                        ? 'GST NO : $companyTaxNo'
                        : companyTaxMode == 'AFRICA'
                            ? 'NUIT : $companyTaxNo'
                            : companyTaxMode == 'GULF'
                                ? 'TRN : $companyTaxNo'
                                : '')
                    : ''),
              ])),
              pw.Text(title,
                  style: const pw.TextStyle(color: PdfColor.fromInt(0))),

              tempLedgerData != null
                  ? pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.RichText(
                          textAlign: pw.TextAlign.left,
                          text: pw.TextSpan(
                              text: 'Ledger   : ${tempLedgerData!.name}\n',
                              children: [
                                pw.TextSpan(
                                    text:
                                        'Address : ${tempLedgerData!.address1}\n'),
                                pw.TextSpan(
                                    text:
                                        '                ${tempLedgerData!.address2}\n'),
                                pw.TextSpan(
                                    text:
                                        '                ${tempLedgerData!.address3}\n'),
                                pw.TextSpan(
                                    text:
                                        'Mobile    : ${tempLedgerData!.phone}\n'),
                              ])))
                  : pw.Text(''),
              // if (context.pageNumber > 1) pw.SizedBox(height: 20)
            ]),
        build: (context) => [
              // pw.Container(
              //     child: pw.Padding(
              //         padding: const pw.EdgeInsets.all(1.0),
              //         child: pw.Column(
              //           children: [
              // pw.Header(
              //   text: title,
              //   child: pw.Text('data'),
              // ),
              pw.Table(
                border: pw.TableBorder.all(width: 0.2),
                children: [
                  pw.TableRow(children: [
                    for (int k = 0; k < tableColumn.length; k++)
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(tableColumn[k],
                                style: const pw.TextStyle(fontSize: 6)),
                            // pw.Divider(thickness: 1)
                          ]),
                    // pw.Column(
                    //     crossAxisAlignment: pw.CrossAxisAlignment.center,
                    //     mainAxisAlignment: pw.MainAxisAlignment.center,
                    //     children: [
                    //       pw.Text(tableHeaders[0],
                    //           style: const pw.TextStyle(fontSize: 6)),
                    //       // pw.Divider(thickness: 1)
                    //     ]),
                    // pw.Column(
                    //     crossAxisAlignment: pw.CrossAxisAlignment.center,
                    //     mainAxisAlignment: pw.MainAxisAlignment.center,
                    //     children: [
                    //       pw.Text(tableHeaders[1],
                    //           style: const pw.TextStyle(fontSize: 6)),
                    //       // pw.Divider(thickness: 1)
                    //     ]),
                    // pw.Column(
                    //     crossAxisAlignment: pw.CrossAxisAlignment.center,
                    //     mainAxisAlignment: pw.MainAxisAlignment.center,
                    //     children: [
                    //       pw.Text(tableHeaders[2],
                    //           style: const pw.TextStyle(fontSize: 6)),
                    //       // pw.Divider(thickness: 1)
                    //     ]),
                    // pw.Column(
                    //     crossAxisAlignment: pw.CrossAxisAlignment.center,
                    //     mainAxisAlignment: pw.MainAxisAlignment.center,
                    //     children: [
                    //       pw.Text(tableHeaders[3],
                    //           style: const pw.TextStyle(fontSize: 6)),
                    //       // pw.Divider(thickness: 1)
                    //     ]),
                    // pw.Column(
                    //     crossAxisAlignment: pw.CrossAxisAlignment.center,
                    //     mainAxisAlignment: pw.MainAxisAlignment.center,
                    //     children: [
                    //       pw.Text(tableHeaders[4],
                    //           style: const pw.TextStyle(fontSize: 6)),
                    //       // pw.Divider(thickness: 1)
                    //     ]),
                    // pw.Column(
                    //     crossAxisAlignment: pw.CrossAxisAlignment.center,
                    //     mainAxisAlignment: pw.MainAxisAlignment.center,
                    //     children: [
                    //       pw.Text(tableHeaders[5],
                    //           style: const pw.TextStyle(fontSize: 6)),
                    //       // pw.Divider(thickness: 1)
                    //     ]),
                    // pw.Column(
                    //     crossAxisAlignment: pw.CrossAxisAlignment.center,
                    //     mainAxisAlignment: pw.MainAxisAlignment.center,
                    //     children: [
                    //       pw.Text(tableHeaders[6],
                    //           style: const pw.TextStyle(fontSize: 6)),
                    //       // pw.Divider(thickness: 1)
                    //     ]),
                    // pw.Column(
                    //     crossAxisAlignment: pw.CrossAxisAlignment.center,
                    //     mainAxisAlignment: pw.MainAxisAlignment.center,
                    //     children: [
                    //       pw.Text(tableHeaders[7],
                    //           style: const pw.TextStyle(fontSize: 6)),
                    //       // pw.Divider(thickness: 1)
                    //     ]),
                  ]),
                  for (var i = 0; i < data.length; i++)
                    pw.TableRow(children: [
                      for (int l = 0; l < tableColumn.length; l++)
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(2.0),
                                child: pw.Text(
                                    data[i][tableColumn[l]].toString() ?? '',
                                    style: const pw.TextStyle(fontSize: 6)),
                                // pw.Divider(thickness: 1)
                              ),
                            ]),
                      // pw.Column(
                      //     crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //     mainAxisAlignment: pw.MainAxisAlignment.center,
                      //     children: [
                      //       pw.Padding(
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text(data[i]['Particulars'],
                      //             style: const pw.TextStyle(fontSize: 6)),
                      //         // pw.Divider(thickness: 1)
                      //       ),
                      //     ]),
                      // pw.Column(
                      //     crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //     mainAxisAlignment: pw.MainAxisAlignment.center,
                      //     children: [
                      //       pw.Padding(
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text('${data[i]['Voucher']}',
                      //             style: const pw.TextStyle(fontSize: 6)),
                      //         // pw.Divider(thickness: 1)
                      //       )
                      //     ]),
                      // pw.Column(
                      //     crossAxisAlignment: pw.CrossAxisAlignment.end,
                      //     mainAxisAlignment: pw.MainAxisAlignment.center,
                      //     children: [
                      //       pw.Padding(
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text('${data[i]['EntryNo']}',
                      //             style: const pw.TextStyle(fontSize: 6)),
                      //         // pw.Divider(thickness: 1)
                      //       )
                      //     ]),
                      // pw.Column(
                      //     crossAxisAlignment: pw.CrossAxisAlignment.end,
                      //     mainAxisAlignment: pw.MainAxisAlignment.center,
                      //     children: [
                      //       pw.Padding(
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text('${data[i]['Debit']}',
                      //             style: const pw.TextStyle(fontSize: 6)),
                      //         // pw.Divider(thickness: 1)
                      //       )
                      //     ]),
                      // pw.Column(
                      //     crossAxisAlignment: pw.CrossAxisAlignment.end,
                      //     mainAxisAlignment: pw.MainAxisAlignment.center,
                      //     children: [
                      //       pw.Padding(
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text('${data[i]['Credit']}',
                      //             style: const pw.TextStyle(fontSize: 6)),
                      //         // pw.Divider(thickness: 1)
                      //       )
                      //     ]),
                      // pw.Column(
                      //     crossAxisAlignment: pw.CrossAxisAlignment.end,
                      //     mainAxisAlignment: pw.MainAxisAlignment.center,
                      //     children: [
                      //       pw.Padding(
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text('${data[i]['Balance']}',
                      //             style: const pw.TextStyle(fontSize: 6)),
                      //         // pw.Divider(thickness: 1)
                      //       )
                      //     ]),
                      // pw.Column(
                      //     crossAxisAlignment: pw.CrossAxisAlignment.start,
                      //     mainAxisAlignment: pw.MainAxisAlignment.center,
                      //     children: [
                      //       pw.Padding(
                      //         padding: const pw.EdgeInsets.all(2.0),
                      //         child: pw.Text('${data[i]['Narration']}',
                      //             style: const pw.TextStyle(fontSize: 6)),
                      //         // pw.Divider(thickness: 1)
                      //       )
                      //     ]),
                    ])
                ],
              ),
              // pw.Header(text: ''),
              // pw.Footer(title: pw.Text('add footer message'))
              //   ],
              // )))
            ],
        footer: _buildFooter));

    return pdf;
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Container(),
        pw.Text(
          'Page ${context.pageNumber}/${context.pagesCount}',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.red,
          ),
        ),
      ],
    );
  }

  Future<String> savePreviewPDF(pw.Document pdf, String title) async {
  title = title.replaceAll(RegExp(r'[^\w\s]+'), '');
  if (kIsWeb) {
    try {
      final bytes = await pdf.save();
      
      // Use FileSaver to properly download the file
      final path = await FileSaver.instance.saveFile(
        name:'$title.pdf',
        bytes: bytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
        // '$title.pdf',
        // bytes,
        // 'pdf',
        // mimeType: MimeType.PDF
      );
      
      return path ?? '';
    } catch (ex) {
      print('Error saving PDF: $ex');
      return '';
    }
  }  else {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$title.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path; // real path on mobile
  }
}

  Future<String> _createCSV(String title) async {
    return _generateCsvFile(title)
        .then((value) => savePreviewCSV(value, title));
  }

  Future<String> _generateCsvFile(String title) async {
    var dataList = _data;
    List<List<dynamic>> rows = [];
    tableColumn = dataList[0].keys.toList();
    List<dynamic> row = [];
    for (var columnName in tableColumn) {
      row.add(columnName.toString());
    }
    rows.add(row);

    for (var i = 0; i < dataList.length; i++) {
      List<dynamic> row1 = [];
      for (var columnName in tableColumn) {
        row1.add(dataList[i][columnName].toString());
      }
      rows.add(row1);
    }
    return const ListToCsvConverter().convert(rows);
  }

  Future<String> savePreviewCSV(var csv, var title) async {
    title = title.replaceAll(RegExp(r'[^\w\s]+'), '');
    if (kIsWeb) {
      try {
        final bytes = utf8.encode(csv);
        final blob = html.Blob([bytes], 'application/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement()
          ..href = url
          ..style.display = 'none'
          ..download = '$title.csv';
        html.document.body!.children.add(anchor);
        anchor.click();
        html.document.body!.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
        return '';
      } catch (ex) {
        ex.toString();
      }
      return '';
    } else {
      var output = await getTemporaryDirectory();
      final file = File('${output.path}/' + title + '.csv');
      await file.writeAsString(csv);
      return file.path.toString();
    }
  }

  Future<void> urlFileShare(BuildContext context, String text, String subject,
      List<String> paths) async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    if (paths.isNotEmpty) {
      List<XFile> files = [];
      for (String value in paths) {
        files.add(XFile(value));
      }
      await Share.shareXFiles(files,
          text: text,
          subject: subject,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  showDateBottomSheet(BuildContext context) {
    Set<String> selectedItems = <String>{};
    Set<String> uniqueDate = <String>{};

    applyFilter() {
      List<dynamic> filteredList = recdset
          .where((item) => selectedItems.contains(item['Date']))
          .toList();

      setState(() {
        displayedData = filteredList;
      });
    }

    // Pre-process the data to remove duplicates
    List<dynamic> uniqueDateRecords = recdset.where((item) {
      bool isUnique = uniqueDate.add(item['Date'] ?? '');
      return isUnique;
    }).toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text('Select items to filter:'),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: ScrollController(),
                      shrinkWrap: true,
                      itemCount: uniqueDateRecords.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CheckboxListTile(
                          title: Text(uniqueDateRecords[index]['Date'] ?? ''),
                          value: selectedItems
                              .contains(uniqueDateRecords[index]['Date']),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                selectedItems.add(
                                    uniqueDateRecords[index]['Date'] ?? '');
                              } else {
                                selectedItems.remove(
                                    uniqueDateRecords[index]['Date'] ?? '');
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      applyFilter(); // Apply the selected filter
                    },
                    child: const Text('Apply Filter'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  showParticularsBottomSheet(BuildContext context) {
    Set<String> selectedItems = <String>{};
    Set<String> uniqueParticulars = <String>{};

    applyFilter() {
      List<dynamic> filteredList = recdset
          .where((item) => selectedItems.contains(item['Particulars']))
          .toList();

      setState(() {
        displayedData = filteredList;
      });
    }

    // Pre-process the data to remove duplicates
    List<dynamic> uniqueParticularRecords = recdset.where((item) {
      bool isUnique = uniqueParticulars.add(item['Particulars'] ?? '');
      return isUnique;
    }).toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text('Select items to filter:'),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: ScrollController(),
                      shrinkWrap: true,
                      itemCount: uniqueParticularRecords.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CheckboxListTile(
                          title: Text(uniqueParticularRecords[index]
                                  ['Particulars'] ??
                              ''),
                          value: selectedItems.contains(
                              uniqueParticularRecords[index]['Particulars']),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                selectedItems.add(uniqueParticularRecords[index]
                                        ['Particulars'] ??
                                    '');
                              } else {
                                selectedItems.remove(
                                    uniqueParticularRecords[index]
                                            ['Particulars'] ??
                                        '');
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      applyFilter(); // Apply the selected filter
                    },
                    child: const Text('Apply Filter'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  showDebitBottomSheet(BuildContext context) {
    Set<String> selectedItems = <String>{};
    Set<String> uniqueDebit = <String>{};

    applyFilter() {
      List<dynamic> filteredList = recdset
          .where((item) => selectedItems.contains(item['Debit']))
          .toList();

      setState(() {
        displayedData = filteredList;
      });
    }

    // Pre-process the data to remove duplicates
    List<dynamic> uniqueDebitRecords = recdset.where((item) {
      bool isUnique = uniqueDebit.add(item['Debit'] ?? '');
      return isUnique;
    }).toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text('Select items to filter:'),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: ScrollController(),
                      shrinkWrap: true,
                      itemCount: uniqueDebitRecords.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CheckboxListTile(
                          title: Text(uniqueDebitRecords[index]['Debit'] ?? ''),
                          value: selectedItems
                              .contains(uniqueDebitRecords[index]['Debit']),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                selectedItems.add(
                                    uniqueDebitRecords[index]['Debit'] ?? '');
                              } else {
                                selectedItems.remove(
                                    uniqueDebitRecords[index]['Debit'] ?? '');
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      applyFilter(); // Apply the selected filter
                    },
                    child: const Text('Apply Filter'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  showCreditBottomSheet(BuildContext context) {
    Set<String> selectedItems = <String>{};
    Set<String> uniqueCredit = <String>{};

    applyFilter() {
      List<dynamic> filteredList = recdset
          .where((item) => selectedItems.contains(item['Credit']))
          .toList();

      setState(() {
        displayedData = filteredList;
      });
    }

    // Pre-process the data to remove duplicates
    List<dynamic> uniqueCreditRecords = recdset.where((item) {
      bool isUnique = uniqueCredit.add(item['Credit'] ?? '');
      return isUnique;
    }).toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text('Select items to filter:'),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: ScrollController(),
                      shrinkWrap: true,
                      itemCount: uniqueCreditRecords.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CheckboxListTile(
                          title:
                              Text(uniqueCreditRecords[index]['Credit'] ?? ''),
                          value: selectedItems
                              .contains(uniqueCreditRecords[index]['Credit']),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                selectedItems.add(
                                    uniqueCreditRecords[index]['Credit'] ?? '');
                              } else {
                                selectedItems.remove(
                                    uniqueCreditRecords[index]['Credit'] ?? '');
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      applyFilter(); // Apply the selected filter
                    },
                    child: const Text('Apply Filter'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  showBalanceBottomSheet(BuildContext context) {
    Set<String> selectedItems = <String>{};
    Set<String> uniqueBalance = <String>{};

    applyFilter() {
      List<dynamic> filteredList = recdset
          .where((item) => selectedItems.contains(item['Balance']))
          .toList();

      setState(() {
        displayedData = filteredList;
      });
    }

    // Pre-process the data to remove duplicates
    List<dynamic> uniqueBalanceRecords = recdset.where((item) {
      bool isUnique = uniqueBalance.add(item['Balance'] ?? '');
      return isUnique;
    }).toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text('Select items to filter:'),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: ScrollController(),
                      shrinkWrap: true,
                      itemCount: uniqueBalanceRecords.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CheckboxListTile(
                          title: Text(
                              uniqueBalanceRecords[index]['Balance'] ?? ''),
                          value: selectedItems
                              .contains(uniqueBalanceRecords[index]['Balance']),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                selectedItems.add(uniqueBalanceRecords[index]
                                        ['Balance'] ??
                                    '');
                              } else {
                                selectedItems.remove(uniqueBalanceRecords[index]
                                        ['Balance'] ??
                                    '');
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      applyFilter(); // Apply the selected filter
                    },
                    child: const Text('Apply Filter'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

_buildHeader(sDate, eDate,name) {
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              "ACCOUNT SUMMARY",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(
              height: 12,
            ),
            pw.Text(
              "$name ",
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.Row(
              children: [
                pw.Text(
                  "From  ${DateUtil.dateDMY(sDate)}",
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(
                  width: 10,
                ),
                pw.Text(
                  "To  ${DateUtil.dateDMY(eDate)}",
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        )
      ],
    ),
    pw.SizedBox(
      height: 1,
    ),
    pw.Divider(
      color: const PdfColor.fromInt(0xFF336699), // Blue color
    ),
    pw.Container(
      width: double.infinity,
      height: 50,
      color: const PdfColor.fromInt(0xFF0000FF),
      child: pw.Table(
        columnWidths: {
          0: const pw.FixedColumnWidth(45),
          1: const pw.FlexColumnWidth(15),
          2: const pw.FlexColumnWidth(8),
          3: const pw.FlexColumnWidth(9),
          4: const pw.FlexColumnWidth(8),
        },
        children: [
          pw.TableRow(children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '  Date',
                  style: pw.TextStyle(
                      fontSize: 7,
                      color: const PdfColor.fromInt(0xFFFFFFFF),
                      fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '  Description',
                  style: pw.TextStyle(
                      fontSize: 7,
                      color: const PdfColor.fromInt(0xFFFFFFFF),
                      fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Center(
                  child: pw.Text(
                    '                             Debit',
                    style: pw.TextStyle(
                        fontSize: 7,
                        color: const PdfColor.fromInt(0xFFFFFFFF),
                        fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  '               Credit',
                  style: pw.TextStyle(
                      fontSize: 7,
                      color: const PdfColor.fromInt(0xFFFFFFFF),
                      fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "        Balanace",
                  style: pw.TextStyle(
                      fontSize: 7,
                      color: const PdfColor.fromInt(0xFFFFFFFF),
                      fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ]),
        ],
        border: pw.TableBorder.all(
            width: 1, color: const PdfColor.fromInt(0xFF0000FF)),
      ),
    ),
  ]);
}

// class EmployeeDataSource extends DataGridSource {
//   List<DataGridRow> dataGridRows = [];
//   List<dynamic>? _employees;

//   EmployeeDataSource(List<dynamic> employees) {
//     _employees = employees;
//     buildDataGridRows();
//   }

//   @override
//   List<DataGridRow> get rows => dataGridRows;

//   void buildDataGridRows() {
//     dataGridRows = _employees!.map<DataGridRow>((e) {
//       var showDetails = e['Particulars'] == 'Opening Balance' ||
//               e['Particulars'] == 'Closing Balance'
//           ? ' ${e['Particulars']}'
//           : e['Particulars'].isNotEmpty
//               ? ' Voucher:${e['Voucher']}\n No:${e['EntryNo']}\n ${e['Particulars']}'
//               : '';

//       return DataGridRow(cells: [
//         DataGridCell<String>(
//           columnName: 'Date',
//           value: ' ${e['Date']}',
//         ),
//         DataGridCell<String>(columnName: 'Description', value: showDetails),
//          DataGridCell<String>(columnName: 'Debit', value: '${e['Debit']} '),
//         DataGridCell<String>(columnName: 'Credit', value: '${e['Credit']} '),
//         DataGridCell<String>(columnName: 'Balance', value: '${e['Balance']} '),
//       ]);
//     }).toList();
//   }

//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//       cells: row.getCells().map<Widget>((cell) {
//         return Container(
//           // decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
//           alignment:
//               (cell.columnName == 'Date' || cell.columnName == 'Description')
//                   ? Alignment.centerLeft
//                   : Alignment.centerRight,
//           child: Text(
//             cell.value.toString(),
//             style: const TextStyle(fontSize: 8),
//             overflow: TextOverflow.clip,
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
