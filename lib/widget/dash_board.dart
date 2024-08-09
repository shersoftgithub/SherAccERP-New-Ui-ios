import 'package:flutter/material.dart';
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
    'assets/icons/statement_icon.png',
    'assets/icons/expence_icon.png',
    'assets/icons/cash_bank_icon.png',
    'assets/icons/recivable_payable_icon.png',
  ];
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
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: 4,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 2,
                            mainAxisExtent: 150),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => pages[index],
                              ));
                        },
                        child: Container(
                          width: 170,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: 77,
                                height: 77,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: const Color(0xff0008B3)),
                                child: Image.asset(imageUrl[index]),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                dashTxt[index],
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'poppins',
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ));
  }
}
