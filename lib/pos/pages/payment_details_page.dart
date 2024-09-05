import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/app_settings_page.dart';
import 'package:sheraccerp/models/cart_item.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/customer_model.dart';
import 'package:sheraccerp/models/ledger_name_model.dart';
import 'package:sheraccerp/models/sales_model.dart';
import 'package:sheraccerp/models/sales_type.dart';
import 'package:sheraccerp/pos/models/pos_cart_model.dart';
import 'package:sheraccerp/pos/pages/pos_settings_page.dart';
import 'package:sheraccerp/scoped-models/main.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/service/com_service.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final List<PosCartModel> cartItems;
  final double? totalGrossValue;
  final double? grandTotal;
  const PaymentPage({super.key, required this.grandTotal, required this.cartItems,required this.totalGrossValue});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String? selectedCashAccount;
  int? selectedCashId;
  String? selectedBankAccount;
  List<DropdownMenuItem<String>> cashAccountDropdownItems = [];
  List<DropdownMenuItem<String>> bankAccountDropdownItems = [];
  List<LedgerModel> cashBankACList = [];
  List<SerialNOModel> serialNoData = [];
   List<dynamic> otherAmountList = [];
  DateTime now = DateTime.now();
  String? formattedDate;
  DioService api = DioService();
  String cashAc = '';
  String bankAc = '';
  int acId = 0,lId = 0;
  int cashId = 0 ,commissionAccount = 0; 
  int decimal = 2,saleAccount = 0;
  CompanyInformation? companySettings;
  List<CompanySettings>? settings;
  CustomerModel? ledgerModel;
  String vehicleName = '', invoiceNo = '';
  var salesManId = 0;
  double _balance = 0;
  double totalCartValue = 0;
  bool manualInvoiceNumberInSales = false,
         sType = false,
         _isLoading = false,
         buttonEvent = false;
  final TextEditingController bankAmountController =TextEditingController();    
  final TextEditingController controllerCashReceived =TextEditingController();    
  final vehicleNameControl = TextEditingController();
  final invoiceNoController = TextEditingController(); 

  // State variables for amounts and balances
  double cashReceived = 0.0;
  double cashBalance = 0.0;

  @override
  void initState() {
    super.initState();
        formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);
    ComSettings().fetchOtherData();
    loadSettings();
        saleAccount = mainAccount.firstWhere(
        (element) => element['LedName'] == 'GENERAL SALES A/C')['LedCode'];

      final csDetails = api.getCustomerDetail(acId!);
  csDetails.then((value) {
      ledgerModel = value;
    
  },);    
  }


  loadSettings() async {
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();

    cashAc = ComSettings.getValue('CASH A/C', settings!).toString().trim() ?? 'CASH';
    selectedCashAccount = cashAc;
    decimal = (ComSettings.getValue('DECIMAL', settings!).toString().isNotEmpty
        ? int.tryParse(ComSettings.getValue('DECIMAL', settings!).toString())
        : 2)!;
    salesManId = ComSettings.appSettings(
            'int', 'key-dropdown-default-salesman-view', 1) -
        1;
        lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;    
        acId = 
         mainAccount.firstWhere((element) => element['LedName'] == cashAc,
            orElse: () => {'LedName': cashAc, 'LedCode': acId})['LedCode']
        ;    
     var settingss  = ScopedModel.of<MainModel>(context).getSettings();
         sType = ComSettings.getValue('TOOLBAR SALES', settingss)
                    .toString()
                    .isNotEmpty
                ? ComSettings.selectSalesType(
                    ComSettings.getValue('TOOLBAR SALES', settingss))
                : false;

   manualInvoiceNumberInSales =
        ComSettings.getStatus('MANNUAL INVOICE NUMBER IN SALES', settings!);
   companyTaxMode = ComSettings.getValue('PACKAGE', settings!);     

    await fetchCashAccounts();
    await fetchBankAccounts();

        api.fetchDetailAmount().then((value) {
      otherAmountList = value;
      // setState(() {
      //   otherAmountLoaded = true;
      // });
      });
  }
        getEntryNo(saleFormId) {
    api.getSalesInvoiceNo(saleFormId,'SEntryNo').then((value) {
      setState(() {
        invoiceNo = (int.parse(value.toString()) + 1).toString();
        invoiceNoController.text = invoiceNo;
      });
    });
  }

  
  // get rateType => ref.watch(rateTypeProvider);

  savesale() async{

       List<CustomerModel> ledger = [];
    ledger.add(CustomerModel(
        address1: '',
        address2: '',
        address3: '',
        address4: '',
        balance: '',
        city: '',
        email: '',
        id: acId,
        name: cashAc,
        phone: '',
        remarks: '',
        route: '',
        state: ledgerModel!.state,
        stateCode: ledgerModel!.stateCode,
        taxNumber: ''));
         
         var jsonLedger = CustomerModel.encodeCustomerToJson(ledger);
         var customer = json.encode(jsonLedger);
         var jsonItem = posCartModelToJsonList(widget.cartItems);
         var items = json.encode(jsonItem);
         var checkKFC = isKFC ? '1' : '0';
         var saleAccountId = saleAccount > 0 ? saleAccount.toString() : '0';
         var otherAmount = json.encode(otherAmountList);
         var locationId =
            lId.toString().trim().isNotEmpty ? lId : salesTypeData!.location;

  getEntryNo(salesTypeData!.id);

      var data = '[${json.encode({
            'statement': 'SalesInsert',
            'entryNo': 0,
            'invoiceNo': manualInvoiceNumberInSales ? invoiceNo : '0',
            'saleFormId': salesTypeData!.id,
            'saleFormType': salesTypeData!.type,
            'taxType': salesTypeData!.tax ? 'T' : 'NT',
            'date':DateUtil.dateYMD(formattedDate),
            'time':
                '1900-01-01 ${DateFormat("H:m:s:S").format(DateTime.now())}', //1900-01-01 19:27:23.930
            'sType': ref.read(rateTypeProvider),
            'saleAccountId': saleAccountId,
            'grossValue': widget.totalGrossValue,
            'discPercent': 0,
            'discount': 0,
            'rDiscount': 0,
            'net': widget.totalGrossValue!.toStringAsFixed(decimal),
            'cess': 0,
            'total': widget.grandTotal!.toStringAsFixed(decimal),
            'profit': 0,
            'cGST': 0,
            'sGST': 0,
            'iGST': 0,
            'addCess': 0,
            'fCess': 0,
            'otherDiscount': 0,
            'otherCharges': 0,
            'loadingCharge': 0,
            'balanceAmount': ComSettings.appSettings(
                    'bool', 'key-round-off-amount', false)
                ? double.parse(cashBalance.toString()).toStringAsFixed(decimal)
                : double.parse(cashBalance.toString()).roundToDouble().toString(),
            'labourCharge': 0,
            'grandTotal':
                ComSettings.appSettings('bool', 'key-round-off-amount', false)
                    ? widget.grandTotal!.toStringAsFixed(decimal)
                    : widget.grandTotal!.roundToDouble().toString(),
            'creditPeriod': 0,
            'takeUser': 0,
            'narration': '',
            'cashReceived': cashReceived,
            'cashAC': selectedCashId,
            'check_kFC':  checkKFC ,
            'salesMan': salesManId,
            'location': locationId,
            'roundOff': 0,
            'billType': companyTaxMode == 'GULF' ? '2' : '0',
            'returnNo': 0,
            'returnAmount': 0,
            'otherAmount': 0,
            'fyId': currentFinancialYear!.id,
            'commissionAccount': commissionAccount ?? 0,
            'commissionAmount': 0,
            'bankName': selectedBankAccount ?? '',
            'bankAmount': bankAmountController.text.isEmpty
               ? 0
               : bankAmountController.text,
            'eVehicleNo':  vehicleNameControl.text
          })}]';

      final body = {
        'information': customer,
        'data': data,
        'particular': items,
        'serialNoData': json.encode(SerialNOModel.encodedToJson(serialNoData)),
      };
      debugPrint('body====${body.toString()}');
      if (saleAccountId != '0') {
        if (checkFinancialYear(DateUtil.dateYMD(formattedDate))) {
          if (manualInvoiceNumberInSales) {
            api.checkManualInvoiceNoStatus(invoiceNo).then((value) {
              if (!value) {
                api.addSale(body).then((result) {
                  debugPrint('result====${result.toString()}');
                  if (CommonService().isNumeric(result) && int.tryParse(result)! > 0) {
                         final bodyJsonAmount = {
          'statement': 'SalesInsert',
          'entryNo': int.tryParse(result.toString()),
          'data': otherAmount,
          'date': DateUtil.dateYMD(formattedDate),
          'saleFormType': salesTypeData!.type,
          'narration': '',
          'location':locationId,
          'id': acId,
          'fyId': currentFinancialYear!.id
        };
        debugPrint('bodyjson====${bodyJsonAmount.toString()}');
                  }
                },);
              } else{
                                showErrorDialog(context, 'Duplicate Invoice No');
                setState(() {
                  _isLoading = false;
                  buttonEvent = false;
                });
              }
            },); 
          } else {
             api.addSale(body).then((result) {
                  debugPrint('result====${result.toString()}');
                  if (CommonService().isNumeric(result) && int.tryParse(result)! > 0) {
                         final bodyJsonAmount = {
          'statement': 'SalesInsert',
          'entryNo': int.tryParse(result.toString()),
          'data': otherAmount,
          'date': DateUtil.dateYMD(formattedDate),
          'saleFormType': salesTypeData!.type,
          'narration': '',
          'location':locationId,
          'id': acId,
          'fyId': currentFinancialYear!.id
        };
        if (salesTypeData!.accounts) {
          api.addOtherAmount(bodyJsonAmount);
        }
        debugPrint('bodyjson====${bodyJsonAmount.toString()}');
                  }
                   else {
                     showErrorDialog(context, result.toString());
                  }
                },).catchError((e) {
                  showErrorDialog(context, e.toString());
               });
          }
        } else {
          showErrorDialog(
              context, "Date Is Incompatible With This Financial Year");

          setState(() {
            _isLoading = false;
            buttonEvent = false;
          });
        }
      }
  }


  Future<void> fetchCashAccounts() async {
    List<AppSettingsMap> cashAccounts = [];
    var mainAccount = await api.getMainAccount();

    if (mainAccount.isNotEmpty) {
      cashAccounts.add(AppSettingsMap(key: 1, value: ''));
    }

    for (var element in mainAccount) {
      if (element['lh_name'] == 'CASH IN HAND') {
        cashAccounts.add(AppSettingsMap(
            key: element['LedCode'], value: element['LedName']));
      }
    }

    cashAccountDropdownItems = cashAccounts.map((account) {
      return DropdownMenuItem<String>(
        value: account.value,
        child: Text(account.value!),
      );
    }).toList();

    if (cashAccountDropdownItems.any((item) {
      item.key == cashId;
      return item.value == cashAc;
    })) {
      selectedCashId = cashId;
      selectedCashAccount = cashAc;
    }
    setState(() {});
  }
  

  Future<void> fetchBankAccounts() async {
    api.getLedgerListByType('SelectbankOnly').then((value) {
      List<LedgerModel> _dataTemp = [];
      for (var ledger in value) {
        _dataTemp.add(LedgerModel(
          id: ledger['ledcode'], 
          name: ledger['LedName']
        ));
      }
      setState(() {
        cashBankACList.addAll(_dataTemp);
        bankAccountDropdownItems = cashBankACList.map((account) {
          return DropdownMenuItem<String>(
            value: account.name,
            child: Text(account.name),
          );
        }).toList();
      });
    });
  }
  // Future<void> fetchBankAccounts() async {
  //   List<AppSettingsMap> bankAccounts = [];
  //   var mainAccount = await api.getMainAccount();

  //   if (mainAccount.isNotEmpty) {
  //     bankAccounts.add(AppSettingsMap(key: 1, value: ''));
  //   }

  //   for (var element in mainAccount) {
  //     if (element['lh_name'] == 'BANK A/C') {
  //       bankAccounts.add(AppSettingsMap(
  //           key: element['LedCode'], value: element['LedName']));
  //     }
  //   }

  //   bankAccountDropdownItems = bankAccounts.map((account) {
  //     return DropdownMenuItem<String>(
  //       value: account.value,
  //       child: Text(account.value!),
  //     );
  //   }).toList();

  //   if (bankAccountDropdownItems.any((item) => item.value == bankAc)) {
  //     selectedBankAccount = bankAc;
  //   }
  //   setState(() {});
  // }

   void _updateCashReceived(String value) {
    setState(() {
      cashReceived = double.tryParse(value) ?? 0.0;
      // Update cashBalance based on cashReceived
      cashBalance =  (widget.grandTotal?? 0) - cashReceived;
    });
  }
    void balanceCalculate() {
    double? cashReceived = controllerCashReceived.text.trim().isNotEmpty
        ? double.tryParse(controllerCashReceived.text)
        : 0;
    double bankAmount = bankAmountController.text.trim().isNotEmpty
        ? double.parse(bankAmountController.text.trim())
        : 0;
    _balance = (cashReceived! > 0 || bankAmount > 0)
        ? widget.grandTotal! > 0
            ? widget.grandTotal! - cashReceived - bankAmount
            : ((totalCartValue) - cashReceived - bankAmount)
        : widget.grandTotal! > 0
            ? widget.grandTotal!
            : totalCartValue;
  }

 

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bagroundColor,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: white
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(5)
                          )
                        ),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(' Cash',
                          style: TextStyle(
                            color: white,
                            fontFamily: 'poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500
                          ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 4,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Account',
                                          style: TextStyle(
                                            fontFamily: 'poppins',
                                            color: grey
                                          ),
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color.fromARGB(255, 202, 202, 202)
                                              ),
                                              borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: DropdownButton<String>(
                                             style: const TextStyle(
                                                   fontFamily: 'poppins', 
                                                   color: black,
                                                   fontSize: 13,
                                                   fontWeight: FontWeight.w500
                                                ),
                                            value: selectedCashAccount,
                                            isExpanded: true,
                                            items: cashAccountDropdownItems,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedCashAccount = value;
                                              });
                                            },
                                            underline: Container(),
                                          ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                   child: SizedBox(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Amount',
                                          style: TextStyle(
                                            fontFamily: 'poppins',
                                            color: grey
                                          ),
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color.fromARGB(255, 202, 202, 202)
                                              ),
                                              borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: TextField(
                                              keyboardType: TextInputType.number,
                                              onChanged: _updateCashReceived,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 5
                                                ),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide.none
                                                )
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                         ),
                         const SizedBox(
                          height: 20,
                         )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: white
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(5)
                          )
                        ),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(' Bank',
                          style: TextStyle(
                            color: white,
                            fontFamily: 'poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500
                          ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 4
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 4,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Account',
                                          style: TextStyle(
                                            fontFamily: 'poppins',
                                            color: grey
                                          ),
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color.fromARGB(255, 202, 202, 202)
                                              ),
                                              borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: DropdownButton<String>(
                                             style: const TextStyle(
                                                   fontFamily: 'poppins', 
                                                   color: black,
                                                   fontSize: 13,
                                                   fontWeight: FontWeight.w500
                                                ),
                                            value: selectedBankAccount,
                                            isExpanded: true,
                                            items: bankAccountDropdownItems,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedBankAccount = value;
                                                debugPrint(selectedBankAccount);
                                              });
                                            },
                                            underline: Container(),
                                          ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                   child: SizedBox(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Amount',
                                          style: TextStyle(
                                            fontFamily: 'poppins',
                                            color: grey
                                          ),
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color.fromARGB(255, 202, 202, 202)
                                              ),
                                              borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: TextField(
                                              keyboardType: TextInputType.number,
                                              controller: bankAmountController,
                                              onChanged: _updateCashReceived,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 5
                                                ),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide.none
                                                )
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                         ),
                         const SizedBox(
                          height: 20,
                         )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: white
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Details',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500
                        ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                            ),
                            Text("\u{20B9} ${widget.grandTotal!.toStringAsFixed(2)}",
                             style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Cash Received',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w500,
                            ),
                            ),
                            Text("\u{20B9} ${cashReceived.toStringAsFixed(2)}",
                             style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Cash Balance',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w500,
                            ),
                            ),
                            Text("\u{20B9} ${cashBalance.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        InkWell(
                          onTap: () {
                            savesale();
                            // debugPrint(widget.cartItems.toString());
                            // debugPrint(acId.toString());
                            // debugPrint(cashAc);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: kPrimaryColor
                            ),
                            child: const Center(
                              child: Text('Print',
                               style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'poppins',
                                fontSize: 17,
                                color: white
                              ),
                              )),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
    showErrorDialog(context, String msg) {
    debugPrint('error save sales :$msg');
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
}
