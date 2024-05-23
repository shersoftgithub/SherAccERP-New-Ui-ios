import 'package:flutter/material.dart';
import 'package:sheraccerp/app_settings_page.dart';

class SalesManSettings extends StatefulWidget {
  const SalesManSettings({Key? key}) : super(key: key);

  @override
  State<SalesManSettings> createState() => _SalesManSettingsState();
}

class _SalesManSettingsState extends State<SalesManSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PopScope(
      canPop: false,
      onPopInvoked: (didPop) => onBackPress(),
      child: const AppSettings(),
    ));
  }

  onBackPress() {
    Navigator.pushNamedAndRemoveUntil(context, '/', ModalRoute.withName('/'));
  }
}
