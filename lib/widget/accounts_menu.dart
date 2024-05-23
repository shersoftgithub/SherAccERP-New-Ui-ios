import 'package:flutter/material.dart';
import 'package:sheraccerp/util/res_color.dart';

class AccountsMenu extends StatelessWidget {
  const AccountsMenu({Key? key}) : super(key: key);

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
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Payment',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              showPaymentOptionList(context);
            },
          ),
          GestureDetector(
            child: Card(
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
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Receipt',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              showReceiptOptionList(context);
            },
          ),
          GestureDetector(
            child: Card(
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
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Customer',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/ledger',
                  arguments: {'parent': 'CUSTOMERS'});
            },
          ),
          GestureDetector(
            child: Card(
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
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Supplier',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/ledger',
                  arguments: {'parent': 'SUPPLIERS'});
            },
          ),
          GestureDetector(
            child: Card(
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Ledger',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/ledger',
                  arguments: {'parent': ''});
            },
          ),
          GestureDetector(
            child: Card(
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Group',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              // _showDialog(context);
            },
          ),
          GestureDetector(
            child: Card(
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Journal',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/journal');
            },
          ),
          GestureDetector(
            child: Card(
              color: white,
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 77,
                      height: 77,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Contra',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              // _showDialog(context);
            },
          ),
        ],
      ),
    );
  }

  showReceiptOptionList(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Receipt Option'),
            children: [
              SimpleDialogOption(
                child: Card(
                    color: blue.shade50,
                    child: const ListTile(title: Text('Cash Receipt'))),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/RPVoucher',
                      arguments: {'voucher': 'Receipt'});
                },
              ),
              SimpleDialogOption(
                child: Card(
                    color: blue.shade50,
                    child: const ListTile(title: Text('Bank Receipt'))),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/BankVoucher',
                      arguments: {'voucher': 'Receipt'});
                },
              ),
              SimpleDialogOption(
                child: Card(
                    color: blue.shade50,
                    child: const ListTile(title: Text('Receipt Invoice'))),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/InvRPVoucher',
                      arguments: {'voucher': 'Receipt Invoice'});
                },
              ),
              // SimpleDialogOption(
              //   child: Card(
              //       color: blue.shade50,
              //       child: const ListTile(title: Text('Consignment Receipt'))),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
              // SimpleDialogOption(
              //   child: Card(
              //       color: blue.shade50,
              //       child: const ListTile(title: Text('Casual Receipt'))),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
            ],
          );
        });
  }

  showPaymentOptionList(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Payment Option'),
            children: [
              SimpleDialogOption(
                child: Card(
                    color: blue.shade50,
                    child: const ListTile(title: Text('Cash Payment'))),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/RPVoucher',
                      arguments: {'voucher': 'Payment'});
                },
              ),
              SimpleDialogOption(
                child: Card(
                    color: blue.shade50,
                    child: const ListTile(title: Text('Bank Payment'))),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/BankVoucher',
                      arguments: {'voucher': 'Payment'});
                },
              ),
              SimpleDialogOption(
                child: Card(
                    color: blue.shade50,
                    child: const ListTile(title: Text('Payment Invoice'))),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/InvRPVoucher',
                      arguments: {'voucher': 'Payment Invoice'});
                },
              ),
              // SimpleDialogOption(
              //   child: Card(
              //       color: blue.shade50,
              //       child: const ListTile(title: Text('Consignment Payment'))),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
              // SimpleDialogOption(
              //   child: Card(
              //       color: blue.shade50,
              //       child: const ListTile(title: Text('Casual Payment'))),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
            ],
          );
        });
  }
}
