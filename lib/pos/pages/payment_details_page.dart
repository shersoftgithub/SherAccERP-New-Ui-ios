import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/app_settings_page.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/ledger_name_model.dart';
import 'package:sheraccerp/pos/models/pos_cart_model.dart';
import 'package:sheraccerp/scoped-models/main.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/res_color.dart';

class PaymentPage extends StatefulWidget {
  final List<PosCartModel> cartItems;
  final double? grandTotal;
  const PaymentPage({super.key, required this.grandTotal, required this.cartItems});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedCashAccount;
  String? selectedBankAccount;
  List<DropdownMenuItem<String>> cashAccountDropdownItems = [];
  List<DropdownMenuItem<String>> bankAccountDropdownItems = [];
  List<LedgerModel> cashBankACList = [];
  DioService api = DioService();
  String cashAc = '';
  String bankAc = '';
  CompanyInformation? companySettings;
  List<CompanySettings>? settings;

  // State variables for amounts and balances
  double cashReceived = 0.0;
  double cashBalance = 0.0;

  @override
  void initState() {
    super.initState();
    ComSettings().fetchOtherData();
    loadSettings();
  }

  loadSettings() async {
    companySettings = ScopedModel.of<MainModel>(context).getCompanySettings();
    settings = ScopedModel.of<MainModel>(context).getSettings();

    cashAc = ComSettings.getValue('CASH A/C', settings!).toString().trim() ?? 'CASH';
    selectedCashAccount = cashAc;

    await fetchCashAccounts();
    await fetchBankAccounts();
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

    if (cashAccountDropdownItems.any((item) => item.value == cashAc)) {
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
      cashBalance = (widget.grandTotal?? 0) - cashReceived;
    });
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
                            debugPrint(widget.cartItems.toString());
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
}
