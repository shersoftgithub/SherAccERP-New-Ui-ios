import 'package:flutter/material.dart';
import 'package:sheraccerp/util/res_color.dart';

class JobCardHome extends StatefulWidget {
  const JobCardHome({Key? key}) : super(key: key);

  @override
  State<JobCardHome> createState() => _JobCardHomeState();
}

class _JobCardHomeState extends State<JobCardHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JobCardHome',style: TextStyle(fontSize: 16,
        color: white,
        ),),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
              
              ),
              child:Column(
                children: [
                  CircleAvatar(radius: 50,),
                  SizedBox(height: 12,),
                  Text('label 2'),
                ],
              )
            ),
            ListTile(leading: const Icon(Icons.pie_chart_outline_rounded),
              title: const Text('Report'),
              onTap: () {
                
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_box_outlined),
              title: const Text('Job card'),
              onTap: () {
                
              },
            ),
            ListTile(
                leading: const Icon(Icons.check_box_outlined),
              title: const Text('Proforma Invoice'),
              onTap: () {
                
              },
            ),
            ListTile(leading: const Icon(Icons.find_replace_outlined),
              title: const Text('Replace Entry'),
              onTap: () {
              
              },
            ),
            ListTile(leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Job card Bill'),
              onTap: () {
                
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout,color: Colors.red,),
              title: const Text('Exit'),
              onTap: () {
                
              },
            ),
           
          ],
        ),
      ),
      body: const Center(
      
      ),
    );
  }
}
