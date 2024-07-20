import 'package:flutter/material.dart';
import 'package:sheraccerp/util/res_color.dart';

class InventoryReportMenu extends StatelessWidget {
  const InventoryReportMenu({Key? key}) : super(key: key);

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
                      'Purchase List',
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
              Navigator.pushNamed(context, '/PurchaseList');
              // Navigator.pushNamed(context, '/PurchaseList',
              // arguments: {'title': 'ItemWise'});
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
                      'Sales List',
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
              Navigator.pushNamed(context, '/SalesList');
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
                      'Product List',
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
              Navigator.pushNamed(context, '/ProductReport');
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
                      'Stock Report',
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
              Navigator.pushNamed(context, '/StockReport');
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
                      'Sales Return Report',
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
              Navigator.pushNamed(context, '/SalesReturnList');
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
                      'Damage Report',
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
              Navigator.pushNamed(context, '/damageReport');
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
                      'Price List',
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
              Navigator.pushNamed(context, '/priceList');
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
                      'SerialNo List',
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
              Navigator.pushNamed(context, '/serialNoList');
            },
          ),
        ],
      ),
    );
  }
}
