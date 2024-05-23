import 'package:flutter/material.dart';

class Students extends StatefulWidget {
  const Students({Key? key}) : super(key: key);

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('NAME : SAFVAN P'),
        Text('CLASS : 10th'),
        Text('NAME : SAFVAN P'),
        Text('NAME : SAFVAN P'),
        Text('NAME : SAFVAN P'),
        Text('NAME : SAFVAN P'),
        Text('NAME : SAFVAN P'),
        Text('NAME : SAFVAN P'),
        Text('NAME : SAFVAN P'),
      ],
    );
  }
}
