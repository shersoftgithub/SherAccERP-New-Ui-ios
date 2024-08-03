import 'package:flutter/material.dart';
import 'package:sheraccerp/screens/about_shersoft.dart';
import 'package:sheraccerp/screens/printer_settings.dart';
import 'package:sheraccerp/screens/profile.dart';
import 'package:sheraccerp/screens/salesman_registration.dart';
import 'package:sheraccerp/screens/settings/software_settings.dart';
import 'package:sheraccerp/screens/tax_registration.dart';
import 'package:sheraccerp/screens/ui/add_screen.dart';
import 'package:sheraccerp/screens/user_list.dart';
import 'package:sheraccerp/screens/user_registration.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/appbar_custom_widget.dart';

class MoreWidget extends StatelessWidget {
  const MoreWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List pages = [
      Profile(),
      UserScreen(),
      SettingsMenu(),
      AboutSherSoft(),
    ];
    List settingsListTxt = [
      'Company Profile',
      'User List',
      'Software Settings',
      'About Developer'
    ];
    return Scaffold(
      backgroundColor: bagroundColor,
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ListView.separated(
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.only(left: 15),
                  height: 40,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        settingsListTxt[index],
                        style: const TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => pages[index],
                              ));
                        },
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 10,
                );
              },
              itemCount: 4)
          //  ListView(
          //   shrinkWrap: true,
          //   children: [
          //     Card(
          //       elevation: 2,
          //       child: TextButton(
          //         child: const Text('Company Profile'),
          //         onPressed: () {
          //           Navigator.of(context).push(
          //             MaterialPageRoute(
          //               builder: (context) => const Profile(),
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //     Card(
          //       elevation: 2,
          //       child: TextButton(
          //         child: const Text('User List'),
          //         onPressed: () {
          //           Navigator.of(context).push(
          //             MaterialPageRoute(
          //               builder: (context) => const UserScreen(),
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //     // Card(
          //     //   elevation: 2,
          //     //   child: TextButton(
          //     //     child: const Text('Create New User'),
          //     //     onPressed: () {
          //     //       Navigator.of(context).push(
          //     //         MaterialPageRoute(
          //     //           builder: (context) => AddScreen(),
          //     //         ),
          //     //       );
          //     //     },
          //     //   ),
          //     // ),
          //     Card(
          //       elevation: 2,
          //       child: TextButton(
          //         child: const Text('Software Settings'),
          //         onPressed: () {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => const SettingsMenu()),
          //           );
          //         },
          //       ),
          //     ),
          //     Card(
          //       elevation: 2,
          //       child: TextButton(
          //           onPressed: () {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(builder: (context) => AboutSherSoft()),
          //             );
          //           },
          //           child: const Text('About Developer')),
          //     ),
          //   ],
          // ),
          ),
    );
  }
}

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppbarWidgget(
            headTxt: 'Software Settings',
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Scaffold(
        backgroundColor: bagroundColor,
        body: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
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
                          image: const DecorationImage(
                            image: AssetImage('assets/icons/ic_general.png'),
                            scale: 1.9
                            ),
                            borderRadius: BorderRadius.circular(50),
                            color: kPrimaryColor),
                        // child: Image.asset(iconsUrl),
                      ),
                      const Text(
                        'General',
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
                Navigator.of(context).pushNamed('/settings');
              },
            ),
            // GestureDetector(
            //   child: Card(
            //     elevation: 5.0,
            //     child: Container(
            //       padding: const EdgeInsets.all(0),
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.spaceAround,
            //         children: const <Widget>[
            //           Icon(
            //             Icons.business_rounded,
            //             color: blue,
            //             size: 90.0,
            //           ),
            //           Text('Default',
            //               style: TextStyle(
            //                   color: Colors.black, fontWeight: FontWeight.bold)),
            //         ],
            //       ),
            //     ),
            //   ),
            //   onTap: () {
            //     _showAlert(context);
            //   },
            // ),
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
                            image: AssetImage('assets/icons/ic_printer.png'),
                            scale: 1.9
                            ),
                            borderRadius: BorderRadius.circular(50),
                            color: kPrimaryColor),
                        // child: Image.asset(iconsUrl),
                      ),
                      const Text(
                        'Printer',
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => const PrintSettings()));
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
                            image: AssetImage('assets/icons/ic_other.png'),
                            scale: 1.9
                            ),
                            borderRadius: BorderRadius.circular(50),
                            color: kPrimaryColor),
                        // child: Image.asset(iconsUrl),
                      ),
                      const Text(
                        'Other',
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
                Navigator.of(context).pushNamed('/OtherRegistration');
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
                            image: AssetImage('assets/icons/ic_salesman.png'),
                            scale: 1.9
                            ),
                            borderRadius: BorderRadius.circular(50),
                            color: kPrimaryColor),
                        // child: Image.asset(iconsUrl),
                      ),
                      const Text(
                        'Salesman',
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const SalesmanRegistration()));
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
                            image: AssetImage('assets/icons/ic_user_new.png'),
                            scale: 1.9
                            ),
                            borderRadius: BorderRadius.circular(50),
                            color: kPrimaryColor),
                        // child: Image.asset(iconsUrl),
                      ),
                      const Text(
                        'User',
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const UserRegistration()));
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
                            image: AssetImage('assets/icons/ic_tax_group.png'),
                            scale: 1.9
                            ),
                            borderRadius: BorderRadius.circular(50),
                            color: kPrimaryColor),
                        // child: Image.asset(iconsUrl),
                      ),
                      const Text(
                        'Tax Group',
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const TaxRegistration()));
              },
            ),
          ],
        ),
      ),
    );
  }

  void showAlert(BuildContext context) {
    // flutter defined function
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
          actions: <Widget>[
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

class MoreWidget2 extends StatelessWidget {
  const MoreWidget2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Card(
          elevation: 2,
          child: TextButton(
            child: const Text('Change Password'),
            onPressed: () {
              //
            },
          ),
        ),
        Card(
          elevation: 2,
          child: TextButton(
            child: const Text('Other'),
            onPressed: () {
              //
            },
          ),
        ),
        Card(
          elevation: 2,
          child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutSherSoft()),
                );
              },
              child: const Text('About Developer')),
        ),
      ],
    );
  }
}
