import 'package:flutter/material.dart';
import 'package:sheraccerp/util/res_color.dart';

class ContainerFieldWidget extends StatelessWidget {
  final Widget widget;
  final String headTxt;
  const ContainerFieldWidget(
      {super.key, required this.widget, required this.headTxt});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 7,
            ),
            Text(
              headTxt,
              style: const TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w500,
                  color: black,
                  fontSize: 15),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(height: 55, child: widget),
      ],
    );
  }
}
