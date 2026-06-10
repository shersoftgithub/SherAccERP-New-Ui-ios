import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/scoped-models/mains.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'cash_and_bank.dart';
import 'expense.dart';
import 'receivables_payables.dart';
import 'statement.dart';

class DashList extends StatefulWidget {
  const DashList({Key? key}) : super(key: key);

  @override
  State<DashList> createState() => _DashListState();
}

class _DashListState extends State<DashList> {
  List pages = [
    Statement(isAppbar:  true,),
    Expense(isAppbar: true,),
    CashAndBank(isAppbar: true,),
    ReceivablesAndPayables(isAppbar: true,),
  ];
  List dashTxt = [
    'Statement',
    'Expenses',
    'Cash&\n  Bank',
    'Recievable&\n     Payble'
  ];
  List imageUrl = [
    'assets/icons/ic_statement_nn.png',
    'assets/icons/ic_expenses_nn.png',
    'assets/icons/ic_cash_and_bank_nn.png',
    'assets/icons/ic_recievable_and_bank_nn.png',
  ];
  bool salesManWiseAttendanceEdit=false;
  List<CompanySettings>? settings;
  CompanyInformation? companySettings;
  @override
  void initState() {
    settings = ScopedModel.of<MainModel>(context).getSettings();
       salesManWiseAttendanceEdit = 
        ComSettings.getStatus('KEY ENABLE ATTENDANCE WISE SALESMAN EDIT', settings!);
    super.initState();
  }
  // int index = 0;
  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return
        // ? SizedBox(
        //     height: size.height,
        //     width: size.height,
        //     child: Column(
        //       children: [
        //         const Expanded(child: Statement()),
        //         BackButton(
        //           onPressed: () {
        //             setState(() {
        //               index = 0;
        //             });
        //           },
        //         ),
        //       ],
        //     ),
        //   )
        // : index == 2
        //     ? SizedBox(
        //         height: size.height,
        //         width: size.height,
        //         child: Column(
        //           children: [
        //             const Expanded(child: Expense()),
        //             BackButton(
        //               onPressed: () {
        //                 setState(() {
        //                   index = 0;
        //                 });
        //               },
        //             ),
        //           ],
        //         ),
        //       )
        //     : index == 3
        //         ? SizedBox(
        //             height: size.height,
        //             width: size.height,
        //             child: Column(
        //               children: [
        //                 Expanded(child: CashAndBank()),
        //                 BackButton(
        //                   onPressed: () {
        //                     setState(() {
        //                       index = 0;
        //                     });
        //                   },
        //                 ),
        //               ],
        //             ),
        //           )
        //         : index == 4
        //             ? SizedBox(
        //                 height: size.height,
        //                 width: size.height,
        //                 child: Column(
        //                   children: [
        //                     BackButton(
        //                       onPressed: () {
        //                         setState(() {
        //                           index = 0;
        //                         });
        //                       },
        //                     ),
        //                     Expanded(child: ReceivablesAndPayables()),
        //                   ],
        //                 ),
        //               )
        //             :
        Scaffold(
            backgroundColor: bagroundColor,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GridView.count(
                    shrinkWrap: true,
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
                        image:  DecorationImage(
                          image: AssetImage('assets/icons/ic_statement_nn.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          color: kPrimaryColor),
                    ),
                    const Text(
                      'Statement',
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => Statement(isAppbar:  true,),));
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
                        image:  DecorationImage(
                          image: AssetImage('assets/icons/ic_expenses_nn.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          color: kPrimaryColor),
                    ),
                    const Text(
                      'Expenses',
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => Expense(isAppbar: true,),));
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
                        image:  DecorationImage(
                          image: AssetImage('assets/icons/ic_cash_and_bank_nn.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          color: kPrimaryColor),
                    ),
                    const Text(
                      'Cash & Bank',
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => CashAndBank(isAppbar: true,)));
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
                        image:  DecorationImage(
                          image: AssetImage('assets/icons/ic_recievable_and_bank_nn.png',),
                          scale: 1.8,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          color: kPrimaryColor),
                    ),
                    const Text(
                      'Recievable & Payble',
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => ReceivablesAndPayables(isAppbar: true,)));
            },
          ),
        //   if(salesManWiseAttendanceEdit)
        //  GestureDetector(
        //     child: Card(
        //       surfaceTintColor: grey,
        //       color: white,
        //       elevation: 4,
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //         children: [
        //           Container(
        //             width: 77,
        //             height: 77,
        //             decoration: BoxDecoration(
        //               image: const DecorationImage(
        //                 image: AssetImage('assets/icons/ic_employee_list.png'),
        //                 scale: 1.8,
        //               ),
        //               borderRadius: BorderRadius.circular(100),
        //               color: kPrimaryColor,
        //             ),
        //           ),
        //           const Text(
        //             'Attendance',
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //               fontFamily: 'poppins',
        //               fontSize: 15,
        //               fontWeight: FontWeight.w500,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //     onTap: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => const AttendanceLoaderPage(),
        //         ),
        //       );
        //     },
        //   ),
         GestureDetector(
            child: Card(
              surfaceTintColor: grey,
              color: white,
              elevation: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 77,
                    height: 77,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/icons/ic_sales_calendar.png'),
                        scale: 1.8,
                      ),
                      borderRadius: BorderRadius.circular(100),
                      color: kPrimaryColor,
                    ),
                  ),
                  const Text(
                    'Sales Calendar',
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
            onTap: () {
               Navigator.pushNamed(context, '/SalesListcalendarView');
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const SalesCalendarPage(),
              //   ),
              // );
            },
          ),
            ],
                    // itemBuilder: (context, index) {
                    //   return InkWell(
                    //     onTap: () {
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => pages[index],
                    //           ));
                    //     },
                    //     child: Container(
                    //       width: 170,
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(5),
                    //         color: Colors.white,
                    //       ),
                    //       child: Column(
                    //         children: [
                    //           const SizedBox(
                    //             height: 10,
                    //           ),
                    //           Container(
                    //             width: 77,
                    //             height: 77,
                    //             decoration: BoxDecoration(
                    //                 borderRadius: BorderRadius.circular(100),
                    //                 color: const Color(0xff0008B3)),
                    //             child: Image.asset(imageUrl[index],
                    //             scale: 1.5,),
                    //           ),
                    //           const SizedBox(
                    //             height: 10,
                    //           ),
                    //           Text(
                    //             dashTxt[index],
                    //             style: const TextStyle(
                    //                 fontSize: 15,
                    //                 fontFamily: 'poppins',
                    //                 fontWeight: FontWeight.w500),
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //   );
                    // },
                  ),
                ],
              ),
            ));
  }
}
