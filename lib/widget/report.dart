import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:sheraccerp/screens/report_view.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';

// ignore: must_be_immutable
class Report extends StatelessWidget {
  DioService api = DioService();
  DataJson? location;

  Report({Key? key}) : super(key: key);

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
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_closing_report.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Closing Report',
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
              argumentsPass = {'mode': 'closingReport'};
              Navigator.pushNamed(context, '/select_ledger');
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
                  children: [
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_sales_daily.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Sales Daily',
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
              Navigator.pushNamed(context, '/SalesList',
                  arguments: {'title': 'Daily'});
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
                            image: AssetImage('assets/icons/ic_sales_billwise.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Sales BillWise',
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
              Navigator.pushNamed(context, '/SalesList',
                  arguments: {'title': 'BillWise'});
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
                            image: AssetImage('assets/icons/ic_sales_itemwise.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Sales ItemWise',
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
              Navigator.pushNamed(context, '/SalesList',
                  arguments: {'title': 'ItemWise'});
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
                            image: AssetImage('assets/icons/ic_bill_by_bill.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Bill By Bill',
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
              // Navigator.push(
              //     context,
              //     new MaterialPageRoute(
              //         builder: (BuildContext context) =>
              //             new LedgerSelect(), 'billByBill'));
              argumentsPass = {'mode': 'billByBill'};
              Navigator.pushNamed(context, '/select_ledger');
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
                            image: AssetImage('assets/icons/ic_monthly_sales.png'),
                            scale: 1.9
                            ),
                            borderRadius: BorderRadius.circular(50),
                            color: const Color(0xff0008B3)),
                        // child: Image.asset(iconsUrl),
                      ),
                      const Text(
                        'Monthly Sales',
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
                monthlyReport(context, 'Monthly Sales');
              }),
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
                            image: AssetImage('assets/icons/ic_monthly_purchase.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Monthly Purchase',
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
              monthlyReport(context, 'Monthly Purchase');
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
                            image: AssetImage('assets/icons/ic_cheque._new.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Cheque', //'Cheque Returns',
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const ReportView('0',
                          '1', '', '', 'Cheque', '', '', '', [0], '0', '0','0')));
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
                            image: AssetImage('assets/icons/ic_user_activity.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'User Activity',
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
            onTap: () async {
              DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100));
              if (picked != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ReportView(
                            '0',
                            '1',
                            DateUtil.datePickerYMD(picked),
                            '',
                            'User Activity',
                            '',
                            '',
                            '',
                            [0],
                            '0',
                            '0',
                            '0')));
              }
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
                            image: AssetImage('assets/icons/ic_pending_fcs.png'),
                            scale: 1.9
                            ),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Pending FCS',
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
              // Navigator.pushNamed(context, '/ledger',
              //     arguments: {'parent': 'SUPPLIERS'});
              _showDialog(context);
            },
          ),
        ],
      ),
    );
  }

  monthlyReport(BuildContext context, var reportName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return (StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(reportName),
            content: DropdownSearch<dynamic>(
              popupProps: PopupProps.menu(
                constraints: BoxConstraints(maxHeight: 300),
                showSearchBox: true,
              ),
              asyncItems: (String filter) =>
                  api.getSalesListData(filter, 'sales_list/location'),
              dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Select Branch")),
              onChanged: (dynamic data) {
                location = data;
              },
            ),
            actions: [
              TextButton(
                child: const Text("CANCEL"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("SHOW"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ReportView(
                              '0',
                              '1',
                              '',
                              '',
                              reportName,
                              '',
                              '',
                              '',
                              location != null ? [location!.id!] : [0],
                              '0',
                              '0',
                              '0')));
                },
              ),
            ],
          );
        }));
      },
    );
  }

  void _showDialog(BuildContext context) {
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
          actions: [
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
