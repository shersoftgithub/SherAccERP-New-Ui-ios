import 'package:flutter/material.dart';
import 'package:sheraccerp/widget/appbar_custom_widget.dart';

class SettingsScreenWidget extends StatelessWidget {
  final List<Widget> children;
  final String title;
  const SettingsScreenWidget({super.key, required this.children, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(100), child: AppbarWidgget(headTxt: title,onPressed: () {
        Navigator.pop(context);
      },)),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: children.length,
        itemBuilder: (BuildContext context, int index) {
          return children[index];
        },
      ),
    );
    ;
  }
}
