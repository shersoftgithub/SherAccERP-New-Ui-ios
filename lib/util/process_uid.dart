import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sheraccerp/util/res_color.dart';

class ProgressHUDS extends StatelessWidget {
  final Widget? child;
  final bool? inAsyncCall;
  final double? opacity;
  final Color? color;
  final Animation<Color>? valueColor;
  final double blurIntensity; 

  const ProgressHUDS({
    Key? key,
    @required this.child,
    @required this.inAsyncCall,
    this.opacity = 0.3,
    this.color = Colors.grey,
    this.valueColor,
    this.blurIntensity = 4, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = <Widget>[];
    widgetList.add(child!);
    
    if (inAsyncCall!) {
      final modal = Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurIntensity,
                sigmaY: blurIntensity,
              ),
              child: Container(
                color: color!.withOpacity(opacity!),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: kPrimaryColor,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                  // const SizedBox(height: 16),
                  // Text(
                  //   'Loading...',
                  //   style: TextStyle(
                  //     color: kPrimaryColor,
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      );
      
      widgetList.add(modal);
    }
    
    return Stack(
      children: widgetList,
    );
  }
}