// Create delivery_report_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sheraccerp/provider/sales_delivery_provider.dart';
import 'package:sheraccerp/screens/inventory/sales/sales_delivery_reportpage.dart';
import 'package:sheraccerp/service/api_dio.dart';

class DeliveryReportWrapper extends StatelessWidget {
  const DeliveryReportWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeliveryReportProvider(
        DioService(), // Create new instance
      ),
      child: const DeliveryReportPage(),
    );
  }
}