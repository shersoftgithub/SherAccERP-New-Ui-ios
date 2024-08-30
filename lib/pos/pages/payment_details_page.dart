import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:sheraccerp/util/res_color.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8
        ),
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
                          child:  Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  // width: MediaQuery.of(context).size.width/2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Account',
                                      style: TextStyle(
                                        fontFamily: 'poppins',
                                        color:  grey
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
                                  // width: MediaQuery.of(context).size.width/2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Amount',
                                      style: TextStyle(
                                        fontFamily: 'poppins',
                                        color:  grey
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
                          child:  Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  // width: MediaQuery.of(context).size.width/2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Account',
                                      style: TextStyle(
                                        fontFamily: 'poppins',
                                        color:  grey
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
                                  // width: MediaQuery.of(context).size.width/2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Amount',
                                      style: TextStyle(
                                        fontFamily: 'poppins',
                                        color:  grey
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
              child:  Padding(
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                        ),
                        Text("\u{20B9} ",
                         style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cash Recieved',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                        ),
                        ),
                        Text("\u{20B9} ",
                         style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                        ),
                        ),
                        Text("\u{20B9} ",
                         style: TextStyle(
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
    );
  }
}