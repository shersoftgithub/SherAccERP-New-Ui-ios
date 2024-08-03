import 'package:flutter/material.dart';
import 'package:sheraccerp/screens/about_shersoft.dart';
import 'package:sheraccerp/screens/inventory/sales/sale.dart';
import 'package:sheraccerp/util/res_color.dart';

import '../shared/constants.dart';

class InventoryMenu extends StatelessWidget {
  const InventoryMenu({Key? key}) : super(key: key);

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
        children: [
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
                          image: AssetImage('assets/icons/ic_product.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                    ),
                    const Text(
                      'Product',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/product');
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
                          image: AssetImage('assets/icons/ic_opening_stock.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                    ),
                    const Text(
                      'Opening Stock',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/openingStock');
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
                          image: AssetImage('assets/icons/ic_new_purchase.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset('assets/icons/ic_purchase.png',
                      // color: white,
                      // height: 30,
                      // width: 30,
                      // fit: BoxFit.contain,
                      // ),
                    ),
                    const Text(
                      'Purchase',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/purchase');
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
                          image: AssetImage('assets/icons/ic_sales_new.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Sales',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              ComSettings.appSettings('bool', 'key-simple-sales', false)
                  ? Navigator.pushNamed(context, '/SimpleSale')
                  : Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Sale(
                            oldSale: false,
                            thisSale: false,
                          )));
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
                          image: AssetImage('assets/icons/ic_purchase_return.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Purchase Return',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/purchaseReturn');
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
                          image: AssetImage('assets/icons/ic_sales_returns.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Sale Return',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/salesReturn');
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
                          image: AssetImage('assets/icons/ic_jobcard.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Job Card',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/jobcardmenu');
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
                          image: AssetImage('assets/icons/ic_damage.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Damage',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/damageEntry');
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
                          image: AssetImage('assets/icons/ic_purchase_order.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Purchase Order',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/purchaseOrder');
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
                          image: AssetImage('assets/icons/ic_stock_transfer.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Stock Trasfer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/stockTransfer');
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
                          image: AssetImage('assets/icons/ic_product_management.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Product Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/ProductManagement');
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
                          image: AssetImage('assets/icons/ic_algnment_entry.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Alignment Entry',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/AlignmentEntry');
            },
          ),
          GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 2,
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
                          image: AssetImage('assets/icons/ic_service_entry.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Service Entry',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/ServiceEntry');
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
                          image: AssetImage('assets/icons/ic_stock_management.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'Stock Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/StockManagement');
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
                          image: AssetImage('assets/icons/ic_delivery-note.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          color: kPrimaryColor),
                      // child: Image.asset(iconsUrl),
                    ),
                    const Text(
                      'DeliveryNote',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/DeliveryNote');
            },
          ),
        ],
      ),
    );
  }
}
