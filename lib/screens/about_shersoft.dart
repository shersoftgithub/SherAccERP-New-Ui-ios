import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/appbar_custom_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSherSoft extends StatelessWidget {
  AboutSherSoft({Key? key}) : super(key: key);

  launchURL() async {
    const url = 'https://shersoftware.com/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'Shersoftware@gmail.com',
      queryParameters: {'subject': 'about as'});

  launchPhone() async {
    const url = 'tel:+91 9847997755';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  callNumber() async {
    const number = '9847997755'; //set the number here
    // bool? res =
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  smsToNumber() async {
    String url = "";
    if (Platform.isAndroid) {
      //FOR Android
      url = 'sms:9847997755?body=message';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else if (Platform.isIOS) {
      //FOR IOS
      url = 'sms:9847997755&body=message';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  sentMail() async {
    const url = "mailto:Shersoftware@gmail.com?subject=New&body=New%20plugin";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List gridListTxts = [
    'SherAcc',
    'SherPharma',
    'SherGold',
    'SherDoc',
    'SherTex',
    'More'
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: bagroundColor,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: AppbarWidgget(
              headTxt: 'About Developer',
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 63,
                height: 63,
              ),
              RichText(
                text: const TextSpan(
                  text: 'SherSoft \n',
                  style: TextStyle(
                    fontFamily: 'roman',
                    color: Color(0xff0008B3),
                    fontWeight: FontWeight.bold,
                    fontSize: 42,
                  ),
                  children: [
                    TextSpan(
                      text: '   Software Company',
                      style: TextStyle(
                          fontFamily: 'roman',
                          fontWeight: FontWeight.normal,
                          fontSize: 17),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: const Color(0xff0008B3),
                    ),
                    // child: Image.asset(constants.locationUrl),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Text(
                    'J.N Road, Perinthalmanna',
                    style: TextStyle(
                        fontFamily: 'roman',
                        color: Color(0xff0008B3),
                        fontSize: 17),
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white),
                child: const Center(
                  child: Text(
                    'SherAcc ERP',
                    style: TextStyle(
                        fontFamily: 'times roman',
                        fontWeight: FontWeight.w700,
                        color: Color(0xff0008B3),
                        fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => callNumber(),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 37,
                        height: 37,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3),
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: white,
                        ),
                      ),
                    ),
                    const Text(
                      '+91 9847997755',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => launchURL(),
                      child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 37,
                          height: 37,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: const Color(0xff0008B3),
                          ),
                          child: const Icon(
                            Icons.web,
                            color: white,
                          )),
                    ),
                    const Text(
                      'www.shersoftware.com',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => sentMail(),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 37,
                        height: 37,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff0008B3),
                        ),
                        child: const Icon(
                          Icons.mail,
                          color: white,
                        ),
                      ),
                    ),
                    const Text(
                      'shersoftware@gmail.com',
                      style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 3; i++)
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: const Color(0xff0008B3),
                          ),
                          child: const Icon(
                            Icons.web,
                            color: white,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        )
                      ],
                    ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              GridView.builder(
                itemCount: 6,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    crossAxisCount: 3,
                    mainAxisExtent: 40),
                itemBuilder: (context, index) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white),
                    child: Text(
                      gridListTxts[index],
                      style: const TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0008B3)),
                    ),
                  );
                },
              ),
              const Column(
                children: [
                  // const Padding(
                  //   padding: EdgeInsets.all(4.0),
                  //   child: Text(
                  //     "SherSoft",
                  //     style: TextStyle(color: Colors.white, fontSize: 20),
                  //   ),
                  // ),
                  // const Padding(
                  //   padding: EdgeInsets.all(2.0),
                  //   child: Text(
                  //     "Software Company",
                  //     style: TextStyle(color: Colors.white, fontSize: 15),
                  //   ),
                  // ),
                  // const Padding(
                  //   padding: EdgeInsets.all(2.0),
                  //   child: Text(
                  //     "📌Perinthalmanna, Malappuram, Kerala",
                  //     style: TextStyle(color: Colors.white, fontSize: 14),
                  //   ),
                  // )
                ],
              ),
              // ListView(
              //   shrinkWrap: true,
              //   children: [
              //     const SizedBox(
              //       height: 300,
              //     ),
              //     // Padding(
              //     //   padding: const EdgeInsets.all(2.0),
              //     //   child: Row(
              //     //     mainAxisAlignment: MainAxisAlignment.center,
              //     //     children: const [
              //     //       SizedBox(
              //     //         width: 20,
              //     //       ),
              //     //       Text(
              //     //         "SherAcc ERP",
              //     //         style: TextStyle(
              //     //             color: kPrimaryDarkColor,
              //     //             fontSize: 22,
              //     //             fontWeight: FontWeight.bold),
              //     //       )
              //     //     ],
              //     //   ),
              //     // ),
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           GestureDetector(
              //             onTap: () => callNumber(),
              //             child: const Icon(
              //               Icons.phone,
              //               color: Colors.blue,
              //             ),
              //           ),
              //           const SizedBox(
              //             width: 20,
              //           ),
              //           const Text(
              //             "+91 9847997755",
              //             style: TextStyle(color: Colors.blue, fontSize: 18),
              //           )
              //         ],
              //       ),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           GestureDetector(
              //             onTap: () => launchURL(),
              //             child: const Icon(
              //               Icons.web,
              //               color: Colors.blue,
              //             ),
              //           ),
              //           const SizedBox(
              //             width: 20,
              //           ),
              //           const Text(
              //             "shersoftware.com",
              //             style: TextStyle(color: Colors.blue, fontSize: 18),
              //           )
              //         ],
              //       ),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           GestureDetector(
              //             onTap: () => sentMail(),
              //             child: const Icon(
              //               Icons.mail,
              //               color: Colors.blue,
              //             ),
              //           ),
              //           const SizedBox(
              //             width: 20,
              //           ),
              //           const Text(
              //             "shersoftware@gmail.com",
              //             style: TextStyle(color: Colors.blue, fontSize: 18),
              //           )
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
