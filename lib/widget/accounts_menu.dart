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
                          borderRadius: BorderRadius.circular(50),
                          image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_payment_new.png'),
                            scale: 1.9
                            ),
                          color: const Color(0xff0008B3)),
                      // child: Image.asset('assets/icons/ic_payment_new.png',
                      // height: 20,
                      // width: 20,
                      // ),
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
                            image: AssetImage('assets/icons/ic_receipt.png'),
                            scale: 1.9
                            ),
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
                            image: AssetImage('assets/icons/ic_customer.png'),
                            scale: 1.9
                            ),
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
                            image: AssetImage('assets/icons/ic_supplier.png'),
                            scale: 1.9
                            ),
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
              surfaceTintColor: grey,
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
                        image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_ledger.png'),
                            scale: 1.9
                            ),
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
              surfaceTintColor: grey,
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
                        image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_group.png'),
                            scale: 1.9
                            ),
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
              surfaceTintColor: grey,
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
                        image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_journal.png'),
                            scale: 1.9
                            ),
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
              surfaceTintColor: grey,
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
                        image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_contra.png'),
                            scale: 1.9
                            ),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            title: const Text('Receipt Option'),
            titleTextStyle: const TextStyle(
              fontFamily: 'poppins',
              color: black,
              fontSize: 16,
              fontWeight: FontWeight.w500
              ),
            children: [
              SimpleDialogOption(
                child: Container(
                    height: 40,
                    decoration: BoxDecoration(color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(5)
                    ),
                    child: const Center(child: Text('Cash Receipt',
                    style: TextStyle(fontFamily: 'poppins',color: white),
                    ))),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/RPVoucher',
                      arguments: {'voucher': 'Receipt'});
                },
              ),
              SimpleDialogOption(
                child: Container(
                    height: 40,
                    decoration: BoxDecoration(color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(5)
                    ),
                    child: const Center(child: Text('Bank Receipt',
                    style: TextStyle(fontFamily: 'poppins',color: white),
                    ))),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/BankVoucher',
                      arguments: {'voucher': 'Receipt'});
                },
              ),
              SimpleDialogOption(
                child: Container(
                    height: 40,
                    decoration: BoxDecoration(color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(5)
                    ),
                    child: const Center(
                      child: Text('Receipt Invoice',
                      style: TextStyle(fontFamily: 'poppins',color: white),),
                    )),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            title: const Text('Payment Option'),
            titleTextStyle: const TextStyle(
              fontFamily: 'poppins',
              color: black,
              fontSize: 16,
              fontWeight: FontWeight.w500
              ),
            children: [
              SimpleDialogOption(
                child: 
                Container(
                    height: 40,
                    decoration: BoxDecoration(color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(5)
                    ),
                    child: const  Center(
                      child: Text('Cash Payment',
                      style: TextStyle(fontFamily: 'poppins',color: white),),
                    )),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/RPVoucher',
                      arguments: {'voucher': 'Payment'});
                },
              ),
              SimpleDialogOption(
                child:
                 Container(
                    height: 40,
                    decoration: BoxDecoration(color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(5)
                    ),
                    child: const Center(
                      child: Text('Bank Payment',
                      style: TextStyle(fontFamily: 'poppins',color: white)),
                    )),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/BankVoucher',
                      arguments: {'voucher': 'Payment'});
                },
              ),
              SimpleDialogOption(
                child: Container(
                    height: 40,
                    decoration: BoxDecoration(color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(5)
                    ),
                    child: const  Center(child: Text('Payment Invoice'
                    ,style: TextStyle(fontFamily: 'poppins',color: white)))),
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
