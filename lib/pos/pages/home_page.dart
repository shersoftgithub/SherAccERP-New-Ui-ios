import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sheraccerp/pos/widgets/drawer_widget.dart';
import 'package:sheraccerp/util/res_color.dart';

class PosHomePage extends HookWidget {
  final Map<String, int> selectedItems;
  const PosHomePage({super.key,required this.selectedItems});

  @override
  Widget build(BuildContext context) {
      final _quantity = useState('');

    void _handleNumberPressed(String number) {
      _quantity.value += number;
      // widget.onQuantityChanged(_quantity.value);
    }

    void _handleClearPressed() {
      _quantity.value = '';
      // widget.onQuantityChanged('');
    }
    var scaffoldKey = GlobalKey<ScaffoldState>();
    final isExpanded = useState<bool>(true);
    final animationDuration = const Duration(milliseconds: 400);
    return  DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bagroundColor,
        key: scaffoldKey,
        drawer: DrawerWidget(),
        appBar: AppBar(
          toolbarHeight: 80,
         leading: Align(
          alignment: Alignment.bottomRight,
           child: IconButton(onPressed: (){
              scaffoldKey.currentState?.openDrawer();
           }, icon: Image.asset('assets/icons/ic_menu.png',scale: 2.6,)),
         ),
         backgroundColor: kPrimaryColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10
            ),
            child: Column(
              children: [
               Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 8
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: white,
                ),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width/6,
                            child: const Text('Barcode',
                            overflow: TextOverflow.ellipsis,
                            // textScaler: TextScaler.linear(.9),
                                                  style: TextStyle(
                                                    fontFamily: 'poppins',
                                                    // fontSize: 13,
                                                     fontWeight: FontWeight.w500,
                                                     color: grey
                                                  ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/5,
                            child: const Center(
                              child: Text('Item Name',
                              overflow: TextOverflow.ellipsis,
                              // textScaler: TextScaler.linear(.9),
                                                    style: TextStyle(
                                                      fontFamily: 'poppins',
                                                      // fontSize: 13,
                                                       fontWeight: FontWeight.w500,
                                                       color: grey
                                                    ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/6,
                            child: const Center(
                              child: Text('Qty',
                              overflow: TextOverflow.ellipsis,
                              // textScaler: TextScaler.linear(.9),
                                                    style: TextStyle(
                                                      fontFamily: 'poppins',
                                                      // fontSize: 13,
                                                       fontWeight: FontWeight.w500,
                                                       color: grey
                                                    ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/6,
                            child: const Center(
                              child: Text('Rate',
                              overflow: TextOverflow.ellipsis,
                              // textScaler: TextScaler.linear(.9),
                                                    style: TextStyle(
                                                      fontFamily: 'poppins',
                                                      // fontSize: 13,
                                                       fontWeight: FontWeight.w500,
                                                       color: grey
                                                    ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/6,
                            child: const Center(
                              child: Text('Total',
                              overflow: TextOverflow.ellipsis,
                              // textScaler: TextScaler.linear(.9),
                                                    style: TextStyle(
                                                      fontFamily: 'poppins',
                                                      // fontSize: 13,
                                                       fontWeight: FontWeight.w500,
                                                       color: grey
                                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    // items list
                    ListView.separated(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 5,
                      ),
                      itemCount: selectedItems.length,
                      itemBuilder: (context, index) {
                         String itemName = selectedItems.keys.elementAt(index);
          int quantity = selectedItems[itemName]!;
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          // height: 40,
                          child: Row(
                            children: [
                               SizedBox(
                            width: MediaQuery.of(context).size.width/6,
                            child: const Text('01233212',
                            maxLines: null,
                            // textScaler: TextScaler.linear(.9),
                            overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'poppins',
                                                    // fontSize: 13,
                                                     fontWeight: FontWeight.w500,
                                                  ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/5,
                            child:  Center(
                              child: Text(itemName,
                              // textScaler: TextScaler.linear(.9),
                              maxLines: null,
                              textAlign: TextAlign.justify,
                              overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontFamily: 'poppins',
                                                      // fontSize: 13,
                                                       fontWeight: FontWeight.w500,
                                                    ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/6,
                            child:  Center(
                              child: Text(quantity.toString(),
                              // textScaler: TextScaler.linear(.9),
                              overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontFamily: 'poppins',
                                                      // fontSize: 13,
                                                       fontWeight: FontWeight.w500,
                                                    ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/6,
                            child: const Center(
                              child: Text('200',
                              // textScaler: TextScaler.linear(.9),
                              overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily: 'poppins',
                                                      // fontSize: 13,
                                                       fontWeight: FontWeight.w500,
                                                    ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/6,
                            child: const Center(
                              child: Text('400',
                              overflow: TextOverflow.ellipsis,
                              // textScaler: TextScaler.linear(.9),
                                                    style: TextStyle(
                                                      fontFamily: 'poppins',
                                                      // fontSize: 13,
                                                       fontWeight: FontWeight.w500,
                                                    ),
                              ),
                            ),
                          ),
                          // InkWell(
                          //   onTap: () {
                              
                          //   },
                          //   child: Icon(
                          //     Icons.close,color: red,
                          //     size: 15,
                          //     ),
                          // )
                            ],
                          ),
                        );
                      },)
                  ],
                ),
               )
              ],
            ),
          ),
        ),
        extendBody: true,
        bottomNavigationBar: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 6,
                color: bagroundColor,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5
                ),
                 margin: const EdgeInsets.symmetric(
                  // vertical: 8,
                  horizontal: 8
                ), 
                width: MediaQuery.of(context).size.width,
                height: 28,
                decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(3)
                    ),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        
                      },
                      child: const Text('Clear all ',
                      // textScaler: TextScaler.linear(.9),
                      style: TextStyle(
                        fontFamily: 'poppins',
                        // fontSize: 13,
                         fontWeight: FontWeight.w500,
                         decoration: TextDecoration.underline,
                         decorationColor: red,
                         color: red
                      ),
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            isExpanded.value = !isExpanded.value;
                          },
                          child: Icon(!isExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,)),
                      ),
                    ),
                      const Spacer(),
                      const Text('Total Qty: 10',
                      // textScaler: TextScaler.linear(.9),
                      style: TextStyle(
                        fontFamily: 'poppins',
                        // fontSize: 13,
                        fontWeight: FontWeight.w500
                      ),)
                  ],
                ),
              ),
              Container(
                height: 6,
                color: bagroundColor,
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5
                ),
                width: MediaQuery.of(context).size.width,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: white,
                ),
                child: const Row(
                  children: [
                    Text('Customer Card No',
                    //  textScaler: TextScaler.linear(.9),
                      style: TextStyle(
                        fontFamily: 'poppins',
                        // fontSize: 13,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: TextField(
                        // autofocus: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5
                          ),
                          constraints: BoxConstraints(
                            maxHeight: 28
                          ),
                          border: OutlineInputBorder(
                          )
                        ),
                      )
                    )
                  ],
                ),
              ),
              Container(
                color: bagroundColor,
                height: 8,
              ),
              AnimatedContainer(
                color: bagroundColor,
                // margin: EdgeInsets.symmetric(
                //   vertical: 10,
                //   horizontal: 8
                // ), 
                duration: animationDuration,
                // color: white,
                // height: isExpanded.value
                //     ? MediaQuery.of(context).size.height / 2
                //     : 0,
                child: Container(
                   margin: const EdgeInsets.symmetric(
                  // vertical: 16,
                  horizontal: 8
                ), 
                  height: isExpanded.value
                    ? MediaQuery.of(context).size.height / 2
                    : 0,
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(3)
                    ),
                    child:  Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TabBar(
                            dividerHeight: 0,
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 1
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 1
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorPadding: EdgeInsets.symmetric(
                             vertical:isExpanded.value ?  10 : 0
                            ),
                            indicatorColor: isExpanded.value? kPrimaryColor : bagroundColor,
                            unselectedLabelColor: black,
                            labelStyle: const TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w500,
                              color: kPrimaryColor //Color(0xff0008B3),
                              // fontSize: 13
                            ),
                            tabs: const[
                            Tab(text: 'Barcode',),
                            Tab(text: 'Quantity',),
                            Tab(text: 'Speed Item',),
                          ]),
                          Expanded(
                            child: TabBarView(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4
                                ),
                                // height: MediaQuery.of(context).size.height,
                                // color: red,
                                child:  Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        top: 4
                                      ),
                                      child: Text('Barcode',
                                      style: TextStyle(
                                        fontFamily: 'poppins'
                                      ),
                                      ),
                                    ),
                                    const SizedBox(
                                                      width: 4,
                                                    ),
                                                    const Expanded(
                                                      child: TextField(
                                                        // autofocus: true,
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                            vertical: 5
                                                          ),
                                                          constraints: BoxConstraints(
                                                            maxHeight: 28
                                                          ),
                                                          border: OutlineInputBorder(
                                                          )
                                                        ),
                                                      )
                                                    ),
                                                    const SizedBox(
                                                      width: 4,
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        debugPrint('adsfdv');
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.all(2),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          border: Border.all(
                                                            color: grey
                                                          )
                                                        ),
                                                        child: const Icon(Icons.qr_code_scanner_rounded,
                                                        size: 20,
                                                        color: grey,
                                                        )),
                                                    )
                                  ],
                                ),
                              ),
                              Container(
                                // height: MediaQuery.of(context).size.height,
                                // color: green,
                                child: Column(
      children: [
        Text('', style: const TextStyle(fontSize: 24)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                //  padding: const EdgeInsets.symmetric(
                //   horizontal: 26,
                //   vertical: 7
                // ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                backgroundColor: const Color(0xffeeeff3)
              ),
              onPressed: () => _handleNumberPressed('+1'),
              child: const Text('+1',
              style: TextStyle(
                color: black,
                fontSize: 22
              ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // padding: const EdgeInsets.symmetric(
                //   horizontal: 26,
                //   vertical: 7
                // ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                backgroundColor: const Color(0xffeeeff3)
              ),
              onPressed: () => _handleNumberPressed('-1'),
              child: const Text('-1',
              style: TextStyle(
                color: black,
                fontSize: 22
              ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // padding: const EdgeInsets.symmetric(
                //   horizontal: 26,
                //   vertical: 7
                // ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                backgroundColor: const Color(0xffeeeff3)
              ),
              onPressed: () => _handleNumberPressed('+5'),
              child: const Text('+5',
              style: TextStyle(
                color: black,
                fontSize: 22
              ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // padding: const EdgeInsets.symmetric(
                //   horizontal: 26,
                //   vertical: 7
                // ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                backgroundColor: const Color(0xffeeeff3)
              ),
              onPressed: () => _handleNumberPressed('+10'),
              child: const Text('+10',
              style: TextStyle(
                color: black,
                fontSize: 22
              ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                // padding: const EdgeInsets.symmetric(
                //   horizontal: 26,
                //   vertical: 7
                // ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                backgroundColor: const Color(0xffeeeff3)
              ),
              onPressed: () => _handleNumberPressed('7'),
              child: const Text('7',
              style: TextStyle(
                color: black,
                fontSize: 22
              ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                //  padding: const EdgeInsets.symmetric(
                //   horizontal: 26,
                //   vertical: 7
                // ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                backgroundColor: const Color(0xffeeeff3)
              ),
              onPressed: () => _handleNumberPressed('8'),
              child: const Text('8',
              style: TextStyle(
                color: black,
                fontSize: 22
              ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                //  padding: const EdgeInsets.symmetric(
                //   horizontal: 26,
                //   vertical: 7
                // ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                backgroundColor: const Color(0xffeeeff3)
              ),
              onPressed: () => _handleNumberPressed('9'),
              child: const Text('9',
              style: TextStyle(
                color: black,
                fontSize: 22
              ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                //  padding: const EdgeInsets.symmetric(
                //   horizontal: 26,
                //   vertical: 7
                // ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                backgroundColor: const Color(0xffeeeff3)
              ),
              onPressed: _handleClearPressed,
              child: const Icon(Icons.close,
              color: black,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                //  padding: const EdgeInsets.symmetric(
                //   horizontal: 26,
                //   vertical: 7
                // ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                backgroundColor: const Color(0xffeeeff3)
              ),
              onPressed: () => _handleNumberPressed('4'),
              child: const Text('4',
              style: TextStyle(
                color: black,
                fontSize: 22
              ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                //  padding: const EdgeInsets.symmetric(
                //   horizontal: 26,
                //   vertical: 7
                // ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                backgroundColor: const Color(0xffeeeff3)
              ),
              onPressed: () => _handleNumberPressed('5'),
              child: const Text('5',
              style: TextStyle(
                color: black,
                fontSize: 22
              ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                //  padding: const EdgeInsets.symmetric(
                //   horizontal: 26,
                //   vertical: 7
                // ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                backgroundColor: const Color(0xffeeeff3)
              ),
              onPressed: () => _handleNumberPressed('6'),
              child: const Text('6',
              style: TextStyle(
                color: black,
                fontSize: 22
              ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                backgroundColor: const Color(0xffeeeff3)
              ),
              onPressed: () {
              },
              child: const Icon(Icons.more_outlined,
              color: black,
              ),
            ),
          ],
        ),
        SizedBox(
           width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    // width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                            ),
                            backgroundColor: const Color(0xffeeeff3)
                          ),
                          onPressed: () => _handleNumberPressed('1'),
                          child: const Text('1',
                          style: TextStyle(
                            color: black,
                            fontSize: 22
                          ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                            ),
                            backgroundColor: const Color(0xffeeeff3)
                          ),
                          onPressed: () => _handleNumberPressed('2'),
                          child: const Text('2',
                          style: TextStyle(
                            color: black,
                            fontSize: 22
                          ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                            ),
                            backgroundColor: const Color(0xffeeeff3)
                          ),
                          onPressed: () => _handleNumberPressed('3'),
                          child: const Text('3',
                          style: TextStyle(
                            color: black,
                            fontSize: 22
                          ),
                          ),
                        ),
                       
                      ],
                    ),
                  ),
                  Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                  ),
                  backgroundColor: const Color(0xffeeeff3)
                ),
                onPressed: () => _handleNumberPressed('0'),
                child: const Text('0',
                style: TextStyle(
                  color: black,
                  fontSize: 22
                ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                  ),
                  backgroundColor: const Color(0xffeeeff3)
                ),
                onPressed: () => _handleNumberPressed('00'),
                child: const Text('00',
                style: TextStyle(
                  color: black,
                  fontSize: 22
                ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                  ),
                  backgroundColor: const Color(0xffeeeff3)
                ),
                onPressed: () => _handleNumberPressed('.'),
                child: const Text('.',
                style: TextStyle(
                  color: black,
                  fontSize: 22
                ),
                ),
              ),
            ],
          ),
                ],
              ),
              
               ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        vertical: 35
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                      ),
                      backgroundColor: const Color(0xffeeeff3)
                    ),
                    onPressed: () {
                      // Implement your "Add" action here
                    },
                    child: const Text('Add',
                    style: TextStyle(
                      fontFamily: 'poppins',
                  color: kPrimaryColor,
                  fontSize: 20
                ),
                    ),
                  ),
            ],
          ),
        ),
        
      ],
    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4
                                ),
                                // height: MediaQuery.of(context).size.height,
                                // color: blue,
                                child: GridView.builder(
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisExtent: 80,
                                    mainAxisSpacing: 8,
                                  crossAxisCount: 3,crossAxisSpacing: 8),
                                   itemBuilder: (context, index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: const Color(0xffeeeff3)
                                      ),
                                     );
                                   },),
                              ),
                            ]),
                          )
                        ],
                      ),
                    ),
                ),
              ),
               Container(
                color: bagroundColor,
                height: 8,
              ),
              Container(
                color: kPrimaryColor,
                width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height/6.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width/1.5,
                            child: const Text('Total',
                            style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w300,
                            color: white,
                            fontSize: 14
                             ),
                            ),
                          ),
                          const Text(':',
                           style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w500,
                            color: white,
                            fontSize: 16
                             ),
                          ),
                          const Spacer(),
                          const Text('1234567890',
                           style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w300,
                            color: white,
                            fontSize: 15
                             ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width/1.5,
                            child: const Text('GST/VAT',
                            style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w300,
                            color: white,
                            fontSize: 14
                             ),
                            ),
                          ),
                          const Text(':',
                           style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w500,
                            color: white,
                            fontSize: 16
                             ),
                          ),
                          const Spacer(),
                          const Text('1234567890',
                           style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w300,
                            color: white,
                            fontSize: 15
                             ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: white
                        ),
                       child:  Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width/1.53,
                            child: const Text('Grand Total',
                            style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 16
                             ),
                            ),
                          ),
                          const Text(':',
                           style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 18
                             ),
                          ),
                          const Spacer(),
                          const Text('1234567890',
                           style: TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 15
                             ),
                          )
                        ],
                      ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}