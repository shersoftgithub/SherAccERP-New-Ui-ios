import 'package:flutter/material.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/res_color.dart';

class AccountsReportMenu extends StatelessWidget {
  const AccountsReportMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bagroundColor,
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        crossAxisCount: MediaQuery.of(context).size.width > 500
            ? (MediaQuery.of(context).size.width ~/ 250).toInt()
            : (MediaQuery.of(context).size.width ~/ 150).toInt(),
        children: <Widget>[
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_lrdger_report.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Ledger Report',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'ledger'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_group_list.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Group List',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'GroupList'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_cashbook.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Cash Book',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'CashBook'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_daybook.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Day Book',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'DayBook'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_trail_balance.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Trial Balance',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'TrialBalance'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_balance-sheet.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Balance Sheet',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'BalanceSheet'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_p&l_account.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'P&L Account',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'P&LAccount'};
              Navigator.pushNamed(context, '/select_ledger');
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_balance_report.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Balance Report',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'BalanceReport'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_payment_list.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Payment List',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (BuildContext context) => const ReportView(
              //             '0',
              //             '1',
              //             '2000-01-01',
              //             '2000-01-01',
              //             'PaymentList',
              //             '',
              //             'Payment List',
              //             '0',
              //             1)));
              argumentsPass = {'mode': 'PaymentList'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_receipt_list.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Receipt List',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (BuildContext context) => const ReportView(
              //             '0',
              //             '1',
              //             '2000-01-01',
              //             '2000-01-01',
              //             'ReceiptList',
              //             '',
              //             'Receipt List',
              //             '0',
              //             1)));
              argumentsPass = {'mode': 'ReceiptList'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_cashflow.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Cash Flow',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'CashFlow'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_fund_flow.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Fund Flow',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              // _showDialog(context);
              argumentsPass = {'mode': 'FundFlow'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_payable.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Payable',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'Payable'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_recivable.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Receivable',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'Receivable'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_journal_list.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Journal List',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'JournalList'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (BuildContext context) => const ReportView(
              //             '0',
              //             '1',
              //             '2000-01-01',
              //             '2000-01-01',
              //             'JournalList',
              //             '',
              //             'Journal List',
              //             '0',
              //             1)));
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_tax_reports.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Tax Report',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/TaxReport',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_invoice_bal_customer.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Invoice Balance Customers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'InvoiceWiseBalanceCustomers'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_invoice_bal_supplier.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Invoice Balance Suppliers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = {'mode': 'InvoiceWiseBalanceSuppliers'};
              Navigator.pushNamed(
                context,
                '/select_ledger',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_salesman_report.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Salesman Report',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              argumentsPass = '';
              Navigator.pushNamed(
                context,
                '/salesManReport',
              );
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                         image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_verify_cashbook.png'),
                            scale: 1.7
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Project Profit Loss',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
             Navigator.pushNamed(
              context,
              '/project_profit_loss',
            );
            },
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 50.0,
                width: 50.0,
              ),
              const Text("SherAcc Alert"),
            ],
          ),
          content: const Text("Not Available. \nwe will update next time"),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
