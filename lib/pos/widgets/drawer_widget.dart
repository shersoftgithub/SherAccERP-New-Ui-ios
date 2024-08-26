import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheraccerp/pos/pages/items_page.dart';
import 'package:sheraccerp/util/res_color.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
     void _handleLogout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              pref.remove('userId');
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', ModalRoute.withName('/login'));
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
    return Drawer(
        width: MediaQuery.of(context).size.width/2.2,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 110,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: kPrimaryColor
                ),
                child: Row(
                children: [
                  CircleAvatar()
                ],
              )),
            ),
            const SizedBox(
              height: 20,
            ),
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
                leading: Image.asset('assets/icons/ic_items.png',scale: 3.3,color: black,),
                       title: const Text('Items'),
                       onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ItemsPage(),));
                       },
                     ),
             ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  ),
          leading: Image.asset('assets/icons/ic_discount.png',scale: 3.3,color: black,),
          title: const Text('Discount'),
          onTap: () {
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  ),
          leading: Image.asset('assets/icons/ic_hold.png',scale: 3.3,color: black,),
          title: const Text('Hold'),
          onTap: () {
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  ),
          leading: Image.asset('assets/icons/ic_logout.png',scale: 3.3,color: black,),
          title: const Text('Logout'),
          onTap: () {
            _handleLogout();
          },
        ),
      ),
          ],
        ),
      );
  }
}