import 'package:flutter/material.dart';
import 'package:sheraccerp/util/res_color.dart';

class Jobcardmenu extends StatefulWidget {
  const Jobcardmenu({super.key});

  @override
  State<Jobcardmenu> createState() => _JobcardmenuState();
}

class _JobcardmenuState extends State<Jobcardmenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: AppBar(
        centerTitle: true,
        titleTextStyle: const TextStyle(fontFamily: 'poppins', fontSize: 17,
        color: white,),
        title: const Text('Job Card'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/jobcardhome');
                },
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  decoration: BoxDecoration(
                      border: Border.all(color: grey),
                      borderRadius: BorderRadius.circular(5),
                      color: white),
                  child: const Text(
                    'Job Card Home',
                    style: TextStyle(fontFamily: 'poppins', fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/jobcardentry');
                },
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  decoration: BoxDecoration(
                      border: Border.all(color: grey),
                      borderRadius: BorderRadius.circular(5),
                      color: white),
                  child: const Text(
                    'Job Card Entry',
                    style: TextStyle(fontFamily: 'poppins', fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/jobcardreplacement');
                },
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  decoration: BoxDecoration(
                      border: Border.all(color: grey),
                      borderRadius: BorderRadius.circular(5),
                      color: white),
                  child: const Text(
                    'Replacement',
                    style: TextStyle(fontFamily: 'poppins', fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                decoration: BoxDecoration(
                    border: Border.all(color: grey),
                    borderRadius: BorderRadius.circular(5),
                    color: white),
                child: const Text(
                  'Proforma invoice',
                  style: TextStyle(fontFamily: 'poppins', fontSize: 15),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                decoration: BoxDecoration(
                    border: Border.all(color: grey),
                    borderRadius: BorderRadius.circular(5),
                    color: white),
                child: const Text(
                  'Send To Service',
                  style: TextStyle(fontFamily: 'poppins', fontSize: 15),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                decoration: BoxDecoration(
                    border: Border.all(color: grey),
                    borderRadius: BorderRadius.circular(5),
                    color: white),
                child: const Text(
                  'Service Return',
                  style: TextStyle(fontFamily: 'poppins', fontSize: 15),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                decoration: BoxDecoration(
                    border: Border.all(color: grey),
                    borderRadius: BorderRadius.circular(5),
                    color: white),
                child: const Text(
                  'Job Card Bill',
                  style: TextStyle(fontFamily: 'poppins', fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
