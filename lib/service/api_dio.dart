import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheraccerp/attendance/model/first_in_model.dart';
import 'package:sheraccerp/attendance/model/leave_salesman_model.dart';
import 'package:sheraccerp/attendance/model/punch_in_model.dart';
import 'package:sheraccerp/attendance/model/punchtype_model.dart';
import 'package:sheraccerp/models/cash_customer_model.dart';
import 'package:sheraccerp/models/company.dart';

import 'package:sheraccerp/models/customer_model.dart';
import 'package:sheraccerp/models/gst_auth_model.dart';
import 'package:sheraccerp/models/ledger_name_model.dart';
import 'package:sheraccerp/models/ledger_parent.dart';
import 'package:sheraccerp/models/option_rate_type.dart';
import 'package:sheraccerp/models/print_settings_model.dart';
import 'package:sheraccerp/models/product_manage_model.dart';
import 'package:sheraccerp/models/product_register_model.dart';
import 'package:sheraccerp/models/sales_delivery_basic_response_model.dart';
import 'package:sheraccerp/models/sales_delivery_model.dart';
import 'package:sheraccerp/models/sales_man_model.dart';
import 'package:sheraccerp/models/sales_type.dart';
import 'package:sheraccerp/models/sms_data_model.dart';
import 'package:sheraccerp/models/stock_item.dart';
import 'package:sheraccerp/models/stock_product.dart';
import 'package:sheraccerp/models/tax_group_model.dart';
import 'package:sheraccerp/models/unit_model.dart';
import 'package:sheraccerp/models/user_model.dart';
import 'package:sheraccerp/models/voucher_type_model.dart';
import 'package:sheraccerp/pos/models/upi_model.dart';
import 'package:sheraccerp/screens/accounts/account_summary.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/widget/simple_piediagram_pay_rec.dart';

class DioService {
  // var a='';
  var dio = Dio();
  DioService();

  Future<Map<dynamic, dynamic>> fetchDashTotalData(
      formattedDate, branch) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp',
        sType = 'Total Summary',
        sDate = formattedDate,
        eDate = formattedDate;
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      var response = await dio.get(
          '${pref.getString('api')}${apiV}dashboard/Total/$dataBase',
          queryParameters: {
            'statementType': sType,
            'sDate': sDate,
            'eDate': eDate,
            'branch': branch
          });

      if (response.statusCode == 200) {
        Map<dynamic, dynamic> responseBodyOfTotal;
        List<dynamic> outList = response.data;
        responseBodyOfTotal = outList[0];
        return responseBodyOfTotal;
      } else {
        debugPrint('Failed to load internet');
        return {
"Total Sales" : 0,
"Total No Sales" : 0,
"Total Cash Sales" : 0,
"Total No Cash Sales" :0,
"Total Credit Sales" : 0,
"Total No Credit Sales": 0,
"No Customers" : 0,
"No of Repeat Customers" : 0,
"Total Expenses" : 0

        };
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
      return {};
    }
  }

  Future<dynamic> fetchDashSalesSummary(formattedDate, fromDate, branch) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp',
        sType = 'Sales Summary',
        sDate = fromDate,
        eDate = formattedDate;
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      var response = await dio.get(
          '${pref.getString('api')}${apiV}dashboard/SummaryList/$dataBase',
          queryParameters: {
            'statementType': sType,
            'sDate': sDate,
            'eDate': eDate,
            'branch': branch
          });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        debugPrint('Failed to load internet');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
  }

  Future<dynamic> fetchDashPurchaseSummary(
      formattedDate, fromDate, branch) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp',
        sType = 'Purchase Summary',
        sDate = fromDate,
        eDate = formattedDate;
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      var response = await dio.get(
          '${pref.getString('api')}${apiV}dashboard/SummaryList/$dataBase',
          queryParameters: {
            'statementType': sType,
            'sDate': sDate,
            'eDate': eDate,
            'branch': branch
          });
      if (response.statusCode == 200) {
        return response.data;
      } else {
        debugPrint('Failed to load internet');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
  }

  Future<dynamic> fetchDashStatement(formattedDate, branch) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp',
        sType = 'Daily Statement',
        sDate = formattedDate,
        eDate = formattedDate;
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      var response = await dio.get(
          '${pref.getString('api')}${apiV}dashboard/dayStatement/$dataBase',
          queryParameters: {
            'statementType': sType,
            'sDate': sDate,
            'eDate': eDate,
            'branch': branch
          });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        debugPrint('Failed to load internet');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
  }

  Future<dynamic> fetchDashDailyStatement(formattedDate, head, branch) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', sDate = formattedDate, eDate = formattedDate;
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      var response = await dio.get(
          '${pref.getString('api')}${apiV}dashboard/dayStatement/$dataBase',
          queryParameters: {
            'statementType': head,
            'sDate': sDate,
            'eDate': eDate,
            'branch': branch
          });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        debugPrint('Failed to load internet');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
  }

  Future<bool> addEvent(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}company/event/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        if (response.statusMessage == "Created") {
          ret = true;
        } else {
          ret = false;
        }
      } else {
        ret = false;
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<List<dynamic>> findLedger(id) async {
    List<dynamic> ret = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/find/$dataBase',
          queryParameters: {'id': id});

      if (response.statusCode == 200) {
        ret = response.data;
      } else {
        ret = [];
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> renameLedger(var body) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/rename/$dataBase',
          queryParameters: body,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        if (response.data.toString() == "1") {
          ret = true;
        } else {
          ret = false; //
        }
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> spLedgerAdd(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}Ledger/add/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        if (response.data.toString() == "1") {
          ret = true;
        } else {
          ret = false;
        }
      } else {
        ret = false;
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> spLedgerEdit(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}Ledger/edit/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        // if (response.data.toString() == "1") {
        ret = true;
        // } else {
        //   ret = false;
        // }
      } else {
        ret = false;
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> spLedgerDelete(id) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio
          .delete('${pref.getString('api')}${apiV}Ledger/delete/$dataBase/$id');

      if (response.statusCode == 200) {
        if (response.data.toString() == "1") {
          ret = true;
        } else {
          ret = false;
        }
      } else {
        ret = false;
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<dynamic> spLedger(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    var _item = [];
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}Ledger/sp_ledger/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> _data = response.data;
        _item = _data;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _item;
  }

  Future<dynamic> addProduct(var body) async {
    dynamic ret = '0';
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");

    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}Product/add/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        var data = response.data;
        if (data['id'] > 0) {
          ret = data['id'].toString();
        } else {
          ret = data['message'];
        }
      } else {
        ret = 'Unexpected error occurred!';
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      ret = errorMessage;
    }
    return ret;
  }

  Future<dynamic> editProduct(var body) async {
    dynamic ret = '0';
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");

    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}Product/edit/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        if (jsonResponse['message'] == 'success') {
          ret = jsonResponse['message'];
        } else {
          ret = jsonResponse['message'];
        }
      } else {
        ret = 'unexpected error';
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      ret = errorMessage.toString();
    }
    return ret;
  }

  Future<bool> deleteProduct(var id) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");

    try {
      final response = await dio.delete(
          '${pref.getString('api')}${apiV}Product/delete/$dataBase',
          queryParameters: {'id': id},
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        ret = response.data > 0 ? true : false;
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> renameProduct(var body) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");

    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}Product/rename/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        if (jsonResponse['message'] == 'success') {
          ret = true;
        } else {
          ret = false;
        }
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> addOpeningStock(var body) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}purchase/OpeningStockAdd/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        //RealEntryNo,EntryNo,InvoiceNo,Type
        var jsonResponse = response.data; //json.decode(response.data);
        if (jsonResponse['returnValue'] > 0) {
          ret = true;
        } else {
          ret = false;
        }
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> stockTransfer(var body) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}stock/stockTransfer/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        //RealEntryNo,EntryNo,InvoiceNo,Type
        var jsonResponse = response.data; //json.decode(response.data);
        if (jsonResponse['returnValue'] > 0) {
          ret = true;
        } else {
          ret = false;
        }
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> addPurchase(var body) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
        debugPrint(body.toString());
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}purchase/purchaseAdd/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        //RealEntryNo,EntryNo,InvoiceNo,Type
        var jsonResponse = response.data; //json.decode(response.data);
        if (jsonResponse['returnValue'] > 0) {
           dataDynamic = [
            {
              'RealEntryNo': jsonResponse['returnValue'],
              'EntryNo': jsonResponse['returnValue'],
              'InvoiceNo': '0',
              'Type': '0'
            }
          ];
          ret = true;
        } else {
          ret = false;
        }
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> newSale(var body) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}sale/salesAdd/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] == 1 ? true : false;
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> addDamage(var body) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}damage/Add/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] == 1 ? true : false;
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> addSaleOld(var body) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}sale/add/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        //RealEntryNo,EntryNo,InvoiceNo,Type
        var jsonResponse = response.data; //json.decode(response.data);
        dataDynamic = jsonResponse;
        ret = true;
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<dynamic> addSale(var body) async {
    dynamic ret = '0';
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}sale/add/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        if (response.data['id'] > 0) {
          ret = response.data['id'].toString();
        } else {
          ret = response.data['message'];
        }
      } else {
        ret = 'Unexpected error occurred!';
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      ret = errorMessage.toString();
    }
    return ret;
  }

  Future<dynamic> editSale(var body) async {
    dynamic ret = 0;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}sale/edit/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        if (response.data['id'] > 0) {
          ret = response.data['id'].toString();
        } else {
          ret = response.data['message'];
        }
      } else {
        ret = '0';
        debugPrint('Unexpected error occurred!');
        ret = 'Unexpected error occurred!';
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      ret = errorMessage.toString();
    }
    return ret;
  }

  Future<int> spSale(var body) async {
    int ret = 0;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}sale/sale/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        ret = response.data['returnValue'];
      } else {
        ret = 0;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> addOtherAmount(body) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}sale/addOtherAmount/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        ret = response.data > 0 ? true : false;
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

   Future<bool> addOthersAmount(body) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api' ?? '127.0.0.1:80/api/')}${apiV}sale/addOthersAmount/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        ret = response.data > 0 ? true : false;
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> addDeliveryDetialsOnItems(List<Map<String, dynamic>> body) async {
  bool ret = false;
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = 'cSharp';
  dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");
  try {
    debugPrint('Sending data: ${json.encode(body)}');
    debugPrint('Data type: ${body.runtimeType}');
    debugPrint('Is List: ${body is List}');

    final response = await dio.post(
      '${pref.getString('api')}${apiV}sale/addDeliveryDetails/$dataBase',
      // 'http://192.168.0.110:8090/api/v26/sale/addDeliveryDetails/$dataBase',
      data: json.encode(body),
      options: Options(headers: {'Content-Type': 'application/json'})
    );

    if (response.statusCode == 200) {
      ret = response.data['success'] ?? false;
      debugPrint('API Response: ${response.data}');
    } else {
      ret = false;
      debugPrint('Unexpected error occurred! Status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');
    }
  } catch (e) {
    final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
    debugPrint(errorMessage.toString());
  }
  return ret;
}
 

  Future<bool> checkBill(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sale/checkPrint/$dataBase',
          queryParameters: {
            'statement': data['statement'].toString(),
            'entryNo': data['entryNo'].toString(),
            'sType': data['sType'].toString(),
            'grandTotal': data['grandTotal'].toString(),
            'fyId': currentFinancialYear!.id,
          });

      if (response.statusCode == 200) {
        ret = response.data['returnValue'] > 0 ? true : false;
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<dynamic> spSaleFind(var body) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}sale/sale/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        return jsonResponse['recordsets'];
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
  }

  Future<bool> deleteSale(entryNo, type, form) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
        '${pref.getString('api')}${apiV}sale/delete/$dataBase',
        queryParameters: {
          'entryNo': entryNo,
          'type': type,
          'form': form,
          'fyId': currentFinancialYear!.id,
        },
      );
      if (response.statusCode == 200) {
        ret = response.data > 0 ? true : false;
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> deleteDeliveryNote(entryNo, type, form) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
        '${pref.getString('api')}${apiV}sale/deleteDeliveryNote/$dataBase',
        queryParameters: {
          'entryNo': entryNo,
          'type': type,
          'form': form,
          'fyId': currentFinancialYear!.id,
        },
      );
      if (response.statusCode == 200) {
        ret = response.data > 0 ? true : false;
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<int> addVoucher(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}Voucher/add/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        if (response.data['returnValue'] > 0) {
          return response.data['returnValue'];
        } else {
          return 0;
        }
      } else {
        debugPrint('Unexpected error Occurred!');
        return 0;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return 0;
    }
  }

  Future<int> deleteVoucher(
      String id, int fyId, String statementType, int frmId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
        '${pref.getString('api')}${apiV}Voucher/delete/$dataBase',
        queryParameters: {
          'id': id,
          'statementType': statementType,
          'fyId': currentFinancialYear!.id,
          'frmId': frmId
        },
      );

      if (response.statusCode == 200) {
        if (response.data['returnValue'] > 0) {
          return response.data['returnValue'];
        } else {
          return 0;
        }
      } else {
        debugPrint('Unexpected error Occurred!');
        return 0;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return 0;
    }
  }

  Future<int> addJournalVoucher(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}Journal/add/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        if (response.data['returnValue'] > 0) {
          return response.data['returnValue'];
        } else {
          return 0;
        }
      } else {
        debugPrint('Unexpected error Occurred!');
        return 0;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return 0;
    }
  }

  Future<int> editJournalVoucher(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}Journal/edit/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        if (response.data['returnValue'] > 0) {
          return response.data['returnValue'];
        } else {
          return 0;
        }
      } else {
        debugPrint('Unexpected error Occurred!');
        return 0;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return 0;
    }
  }

  Future<int> deleteJournalVoucher(id, date, user, time) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
          '${pref.getString('api')}${apiV}Journal/delete/$dataBase',
          queryParameters: {
            'id': id,
            'date': date,
            'user': user,
            'time': time,
            'fyId': currentFinancialYear!.id
          },
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        if (response.data['returnValue'] > 0) {
          return response.data['returnValue'];
        } else {
          return 0;
        }
      } else {
        debugPrint('Unexpected error Occurred!');
        return 0;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return 0;
    }
  }

  Future<int> addInvoiceVoucher(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}InvoiceVoucher/add/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        if (response.data['returnValue'] > 0) {
          return response.data['returnValue'];
        } else {
          return 0;
        }
      } else {
        debugPrint('Unexpected error Occurred!');
        return 0;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return 0;
    }
  }

  Future<int> editInvoiceVoucher(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}InvoiceVoucher/edit/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        if (response.data['returnValue'] > 0) {
          return response.data['returnValue'];
        } else {
          return 0;
        }
      } else {
        debugPrint('Unexpected error Occurred!');
        return 0;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return 0;
    }
  }

  Future<int> deleteInvoiceVoucher(id, type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
          '${pref.getString('api')}${apiV}InvoiceVoucher/delete/$dataBase',
          queryParameters: {'id': id, 'type': type},
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        if (response.data['returnValue'] > 0) {
          return response.data['returnValue'];
        } else {
          return 0;
        }
      } else {
        debugPrint('Unexpected error Occurred!');
        return 0;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return 0;
    }
  }

  Future<List<dynamic>> fetchSalesTypeList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', statement = 'SelectSalesType';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sales_list/$dataBase',
          queryParameters: {'statementType': statement});
      List<dynamic> _items = [];
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var json in jsonResponse) {
          _items.add({'id': json['iD'], 'value': true, 'name': json['type']});
        }
        return _items;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<List<dynamic>> getSalesReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}sales_report/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<List<dynamic>> getSalesReportCalendarDeliveryWise(String sDate,String eDate) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}salesCalendarItemDeliveryWise/$dataBase',
          // 'http://192.168.29.207:8090/api/v29/salesCalendarItemDeliveryWise/$dataBase',
          queryParameters: {
           'sDate': sDate,
           'eDate': eDate,
           'fyId': currentFinancialYear!.id,
           },
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  } 
 

  Future<List<dynamic>> getSalesListReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}listPageReport/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<List<dynamic>> getListPageReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}listPageReportAll/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<List<dynamic>> getSalesReturnReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}SalesReturnReport/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<List<dynamic>> getProductReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}ProductList/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<List<dynamic>> getMonthlySalesReport(branchId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}salesReportMonthly/$dataBase',
          queryParameters: {
            'location': branchId,
            'fyId': currentFinancialYear!.id
          });

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<SalesDeliveryBasicResponse> getSalesDeliveryReportBasic({
  required String sDate,
  required String eDate,
  required List<int> salesTypes,
  int? location,
  int? fyId,
  int page = 1,
  int pageSize = 20,
}) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = pref.getString('DBName') ?? "cSharp";
    String salesTypesParam = salesTypes.join(',');
    
    Map<String, dynamic> queryParams = {
      'sDate': sDate,
      'eDate': eDate,
      'salesTypes': salesTypesParam,
      'page': page,
      'pageSize': pageSize,
    };
    
    if (location != null) queryParams['location'] = location;
    if (fyId != null) queryParams['fyId'] = fyId;
    
    final response = await dio.get(
      // 'http://192.168.0.110:8090/api/v26/salesDeliveryReportBasic/$dataBase',
      '${pref.getString('api')}${apiV}salesDeliveryReportBasic/$dataBase',
      queryParameters: queryParams,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    if (response.statusCode == 200) {
      return SalesDeliveryBasicResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to load sales delivery report: ${response.statusCode}');
    }
  } on DioError catch (e) {
    throw Exception('Dio error: ${e.message}');
  } catch (e) {
    throw Exception('Error: $e');
  }
}

Future<List<SalesDeliveryItem>> getSalesDeliveryFullDetails({
  required int entryNo,
  required int salesType,
  required int fyId,
}) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = pref.getString('DBName') ?? "cSharp";
    
    final response = await dio.get(
      // 'http://192.168.0.110:8090/api/v26/salesDeliveryFullDetails/$dataBase',
      '${pref.getString('api')}${apiV}salesDeliveryFullDetails/$dataBase',
      queryParameters: {
        'entryNo': entryNo,
        'salesType': salesType,
        'fyId': fyId,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['success'] == true) {
        return (data['data'] as List<dynamic>)
            .map((item) => SalesDeliveryItem.fromJson(item))
            .toList();
      } else {
        throw Exception('API returned error');
      }
    } else {
      throw Exception('Failed to load details: ${response.statusCode}');
    }
  } on DioError catch (e) {
    throw Exception('Dio error: ${e.message}');
  } catch (e) {
    throw Exception('Error: $e');
  }
}


  Future<List<dynamic>> getPurchaseReport(
     data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
   
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}purchase_report/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'})
          );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }
   
  // Future<List<dynamic>> getPurchaseReport(data) async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   String dataBase = 'cSharp';
  //   dataBase = isEstimateDataBase
  //       ? (pref.getString('DBName') ?? "cSharp")
  //       : (pref.getString('DBNameT') ?? "cSharp");
  //   try {
  //     final response = await dio.post(
  //         '${pref.getString('api' ?? '127.0.0.1:80/api/')}${apiV}purchase_report/$dataBase',
  //         data: data,
  //         options: Options(headers: {'Content-Type': 'application/json'}));
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = response.data;
  //       return data;
  //     } else {
  //       debugPrint('Failed to load data');
  //       return [];
  //     }
  //   } catch (e) {
  //     final errorMessage =  DioExceptions.fromDioError('$e' as DioError).toString();
  //     debugPrint(errorMessage.toString());
  //     return [];
  //   }
  // }

  Future<List<dynamic>> getMonthlyPurchaseReport(branchId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}purchaseReportMonthly/$dataBase');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<List<dynamic>> getAttendanceReportMonthly(var fromDate , var toDate) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}essl/attendance_month/$dataBase',queryParameters: {
            'fromDate': fromDate,
            'toDate': toDate
          });

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }
  Future<List<dynamic>> getAttendanceReport(var fromDate , var toDate) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}essl/attendance_report/$dataBase',
          queryParameters: {
            'fromDate': fromDate,
            'toDate': toDate
          }
          );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<List<dynamic>> getStockReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock_report_new/$dataBase',
          queryParameters: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } on Response catch (r, e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      Response response = r;
      return response.statusCode == 400
          ? [
              {
                'error': errorMessage,
                'respond': response.statusCode.toString(),
              }
            ]
          : [
              {
                'error': errorMessage,
                'respond': response.statusCode.toString(),
              }
            ];
    }
  }

  Future<List<dynamic>> getStockLedgerReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock_report_new/$dataBase',
          queryParameters: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } on Response catch (r, e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return r.statusCode == 400
          ? [
              {
                'error': errorMessage,
                'respond': r.statusCode.toString(),
              }
            ]
          : [
              {
                'error': errorMessage,
                'respond': r.statusCode.toString(),
              }
            ];
    }
  }

  Future<List<dynamic>> fetchBankVouchers() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}inventory_report/BankVouchers/$dataBase');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<List<dynamic>> fetchEventDetails(date) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}inventory_report/EventDetails/$dataBase',
          queryParameters: {'date': date});

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<int> getProductId() async {
    int ret = 0;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}Product/getProductId/$dataBase');

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] + 1;
      } else {
        ret = 0;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<ProductRegisterModel> getProductByName(String _name) async {
    ProductRegisterModel? model;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Product/getByName/$dataBase',
          queryParameters: {'name': _name});

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null) {
          model = ProductRegisterModel.fromMap(data[0]);
        } else {
          // model = ;
          debugPrint('Unexpected error occurred!');
        }
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return model!;
  }

  Future<ProductRegisterModel> getProductByCode(String _code) async {
    ProductRegisterModel? model;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Product/getByCode/$dataBase',
          queryParameters: {'code': _code});

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null) {
          model = ProductRegisterModel.fromMap(data[0]);
        } else {
          // model = ;
          debugPrint('Unexpected error occurred!');
        }
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return model!;
  }

  Future<ProductRegisterModel> getProductById(String id) async {
    ProductRegisterModel? model;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Product/getById/$dataBase',
          queryParameters: {'id': id});

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null) {
          model = ProductRegisterModel.fromMap(data[0]);
        } else {
          // model = ;
          debugPrint('Unexpected error occurred!');
        }
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return model!;
  }

  Future<bool> getUserLogin(name, password) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}users/find/$dataBase',
          queryParameters: {'name': name});

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data;
        if (jsonResponse.isNotEmpty) {
          userNameC = jsonResponse[0]['Name'];
          userIdC = jsonResponse[0]['Auto'];
          if (jsonResponse[0]['Name'].toUpperCase() == name &&
              jsonResponse[0]['Password'].toUpperCase() == password) {
            ret = true;
          }
        } else {
          ret = false;
        }
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<Map<String, dynamic>> getProductData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Product/getProductData/$dataBase');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        debugPrint('Failed to load data');
        return {};
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return {};
    }
  }

  Future<List<dynamic>> getSalesListDataS(statement) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    var filter = ' ';
    try {
      final response = await dio.get(
        '${pref.getString('api')}$apiV${Uri.encodeComponent(statement)}/$dataBase/$filter',
      );
      final data = response.data;
      if (data != null) {
        List<dynamic> list;
        list = data.map((item) => (item['name'])).toList();
        return list; //.map((s) => s as String).toList();
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return [];
  }

  Future<List<DataJson>> getSupplierListData(filter) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    filter = filter.toString().isEmpty ? ' ' : filter;
    List<DataJson> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getSupplierList/$dataBase',
          queryParameters: {'name': filter});
      final data = response.data;
      if (data != null && data.isNotEmpty) {
        _items = DataJson.fromJsonList(data);
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
  
  Future<List<DataJson>> getSalesListData(filter, statement) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    filter = filter.toString().isEmpty ? ' ' : filter;
    List<DataJson> _items = [];
    try {
      final response = await dio.get(
        '${pref.getString('api')! + apiV + statement}/$dataBase',
        queryParameters: {"value": filter},
      );
      final data = response.data;
      if (data != null) {
        _items = DataJson.fromJsonList(data);
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

    Future<List<DataJson>> getSalesListDataLike(filter, statement) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    filter = filter.toString().isEmpty ? ' ' : filter;
    List<DataJson> _items = [];
    try {
      final response = await dio.get(
        '${pref.getString('api')! + apiV + statement}/$dataBase',
        queryParameters: {"value": filter},
      );
      final data = response.data;
      if (data != null) {
        _items = DataJson.fromJsonList(data);
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }


  Future<List<TaxGroupModel>> getTaxGroupData(filter, statement) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    filter = filter.toString().isEmpty ? ' ' : filter;
    List<TaxGroupModel> _items = [];
    try {
      final response = await dio.get(
        '${pref.getString('api')! + apiV + statement}/$dataBase',
        queryParameters: {"filter": filter},
      );
      final data = response.data;
      if (data != null) {
        _items = TaxGroupModel.fromJsonList(data);
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<DataJson>> getHSNListData(filter, statement) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    filter = filter.toString().isEmpty ? ' ' : filter;
    List<DataJson> _items = [];
    try {
      final response = await dio.get(
        '${pref.getString('api')! + apiV + statement}/$dataBase',
        queryParameters: {"filter": filter},
      );
      final data = response.data;
      if (data != null) {
        _items = DataJson.fromJsonList(data);
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<LedgerModel>> getLedgerAll() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}Ledger/getAll/$dataBase');
      if (response.statusCode == 200) {
        for (var data in response.data) {
          _items.add(LedgerModel.fromJson(data));
        }
        return _items;
      } else {
        debugPrint('Failed to load data');
        return _items;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return _items;
    }
  }
  Future<List<Map<String, dynamic>>> getLedgersAll() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<Map<String, dynamic>> _items = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}Ledger/getAll/$dataBase');
      if (response.statusCode == 200) {
         List<dynamic> data = response.data;
        _items = List.from(data);
        // for (var data in response.data) {
        //   _items.add(LedgerModel.fromJson(data));
        // }
        return _items;
      } else {
        debugPrint('Failed to load data');
        return _items;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return _items;
    }
  }

  Future<List<LedgerParent>> getLedgerGroupAll() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerParent> items = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}Ledger/getParentList/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var group in jsonResponse) {
          items.add(LedgerParent.fromJson(group));
        }
        return items;
      } else {
        debugPrint('Failed to load data');
        return items;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return items;
    }
  }

   Future<List<LedgerModel>> getLedgerByGroup(groupId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      var _groupId = groupId > 1 ? groupId : 0,
          _areaId = 0,
          _routeId = 0,
          _salesman = 0,
          _emp = 21359,//empCode > 1 ? empCode : 0,
          like = '';
      final response = await dio.get(
        '${pref.getString('api')}${apiV}Ledger/getLedgerByParent/$dataBase',
        // 'http://192.168.0.110:8090/api/v26/Ledger/getLedgerByParent/$dataBase',
        queryParameters: {
          'groupId': _groupId,
          'areaId': _areaId,
          'routeId': _routeId,
          'salesman': _salesman,
          'like': like,
          'empId': _emp
        },
      );
      if (response.statusCode == 200) {
        for (var data in response.data) {
          _items.add(LedgerModel.fromJson(data));
        }
        return _items;
      } else {
        debugPrint('Failed to load data');
        return _items;
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
      return _items;
    }
   }

  Future<List<dynamic>> getLedger(String name) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getLedger/$dataBase',
          queryParameters: {'name': name});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        _items = jsonResponse;
        return _items;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
   Future<List<LedgerModel>> getLedgerBySalesMan(salesManId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      var _salesman = salesManId > 1 ? salesManId : 0,
          _areaId = 0,
          _routeId = 0,
          _groupId = 0,
          like = '';
      final response = await dio.get(
        '${pref.getString('api')}${apiV}Ledger/getLedgerByParent/$dataBase',
        queryParameters: {
          'groupId': _groupId,
          'areaId': _areaId,
          'routeId': _routeId,
          'salesman': _salesman,
          'like': like
        },
      );
      if (response.statusCode == 200) {
        for (var data in response.data) {
          _items.add(LedgerModel.fromJson(data));
        }
        return _items;
      } else {
        debugPrint('Failed to load data');
        return _items;
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
      return _items;
    }
  }
  Future<List<dynamic>> getPaginationList(String statement, int page,
      String location, String type, String date, String salesMan) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
        '${pref.getString('api')}${apiV}listPage/$dataBase',
        queryParameters: {
          'statementType': statement,
          'page': page,
          'location': location,
          'type': type,
          'date': date,
          'salesMan': salesMan,
          'fyId': currentFinancialYear!.id
        },
      )
          // ).onError((error, stackTrace) {
          //   debugPrint('Erorr:$error');
          //   return null;
          // })
          //     // .timeout(const Duration(seconds: 10));
          ;
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        _items = jsonResponse;
        return _items;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> getDamageReport(String statementType, String sDate,
      String eDate, String condition) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}damage_report/$dataBase',
          queryParameters: {
            'statementType': statementType,
            'sDate': sDate,
            'eDate': eDate,
            'condition': condition
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        _items = jsonResponse;
        return _items;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> getPurchaseAC() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}purchase/getPurchaseAC/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        _items = jsonResponse;
        return _items;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> getStockAC() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}Ledger/getStockAC/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        _items = jsonResponse;
        return _items;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<LedgerParent>> getLedgerParent() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerParent> _items = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}Ledger/getParentList/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data as List;
        for (var ledger in jsonResponse) {
          _items.add(LedgerParent.fromJson(ledger));
        }

        return _items;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<LedgerModel>> getCashBankAc() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getCashAndBank/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var ledger in jsonResponse) {
          _items.add(LedgerModel.fromJsonL(ledger));
        }
      } else {
        debugPrint('Failed to load data');
      }
      return _items;
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<LedgerModel>> getLedgerData(filter) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      final response = await dio.get(
        '${pref.getString('api')}${apiV}Ledger/getAll/$dataBase',
        queryParameters: {"filter": filter},
      );
      final data = response.data;
      if (data != null) {
        _items = LedgerModel.fromJsonList(data);
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<LedgerModel>> getLedgerDataByParent(
      filter, int groupId, int areaId, int routeId, int salesman) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      Response response;
      if (groupId > 1 || areaId > 1 || routeId > 1) {
        var _groupId = groupId > 1 ? groupId : 0,
            _areaId = areaId > 1 ? areaId : 0,
            _routeId = routeId > 1 ? routeId : 0,
            _salesman = 0;
        response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getLedgerByParent/$dataBase',
          queryParameters: {
            'groupId': _groupId,
            'areaId': _areaId,
            'routeId': _routeId,
            'salesman': _salesman,
            'filter': filter
          },
        );
      } else {
        response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getAll/$dataBase',
          queryParameters: {"filter": filter},
        );
      }
      final data = response.data;
      if (data != null) {
        _items = LedgerModel.fromJsonList(data);
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<SalesType>> getSalesTypeList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<SalesType> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sale/getSalesTypeList/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var ledger in jsonResponse) {
          _items.add(SalesType.fromJson(ledger));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

   Future<List<SalesType>> getSalesReturnTypeList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<SalesType> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api' ?? '127.0.0.1:80/api/')}${apiV}sale/getSalesReturnTypeList/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var ledger in jsonResponse) {
          _items.add(SalesType.fromJson(ledger));
        }
      } else {
        debugPrint('Failed to load data');
      }
    }  catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }


  Future<List<OptionRateType>> getRateTypeList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<OptionRateType> _items = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}sale/getRateTypeList/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var ledger in jsonResponse) {
          _items.add(OptionRateType.fromJson(ledger));
        }
        optionRateTypeList = _items;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<LedgerModel>> getCustomerNameList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getCustomerCashList/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var ledger in jsonResponse) {
          _items.add(LedgerModel.fromJson(ledger));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<LedgerModel>> getCustomerNameListByParent(
      int groupId, int areaId, int routeId, int salesman) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      Response response;
      if (groupId > 1 || areaId > 1 || routeId > 1) {
        var _groupId = groupId > 1 ? groupId : 0,
            _areaId = areaId > 1 ? areaId : 0,
            _routeId = routeId > 1 ? routeId : 0,
            _salesman = 0;
        response = await dio.get(
            '${pref.getString('api')}${apiV}Ledger/getLedgerByParent/$dataBase',
            queryParameters: {
              'groupId': _groupId,
              'areaId': _areaId,
              'routeId': _routeId,
              'salesman': _salesman,
              'filter': ''
            });
      } else {
        response = await dio.get(
            '${pref.getString('api')}${apiV}Ledger/getCustomerCashList/$dataBase');
      }
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var ledger in jsonResponse) {
          _items.add(LedgerModel.fromJson(ledger));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
  
  Future<List<LedgerModel>> getLedgerById(int ledCode) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      Response response;
        response = await dio.get(
            '${pref.getString('api')}${apiV}Ledger/getLedgerById/$dataBase',
            // 'http://192.168.0.110:8090/api/v26/Ledger/getLedgerById/$dataBase',
            queryParameters: {
              'ledCode': ledCode,
            });
      
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var ledger in jsonResponse) {
          _items.add(LedgerModel.fromJson(ledger));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<LedgerModel>> getCustomerNameListLike(
      int groupId, int areaId, int routeId, int salesman, String like,) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      Response response;
      if (groupId > 1 || areaId > 1 || routeId > 1) {
        var _groupId = groupId > 1 ? groupId : 0,
            _areaId = areaId > 1 ? areaId : 0,
            _routeId = routeId > 1 ? routeId : 0,
            _salesman = 0,
            _emp = empCode > 1 ? empCode : 0;
        response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getLedgerByParentLike/$dataBase',
          // 'http://192.168.0.110:8090/api/v26/Ledger/getLedgerByParentLike/$dataBase',
          queryParameters: {
            'groupId': _groupId,
            'areaId': _areaId,
            'routeId': _routeId,
            'salesman': _salesman,
            'like': like,
            'empId': _emp
          },
        );
      } else {
        response = await dio.get(
            '${pref.getString('api')}${apiV}Ledger/getLedgerListLike/$dataBase',
            queryParameters: {'name': like});
      }
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var ledger in jsonResponse) {
          _items.add(LedgerModel.fromJson(ledger));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<LedgerModel>> getLedgerBySalesManLike(
      int salesman, String like) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      Response response;
      if (salesman > 1) {
        var _salesman = salesman > 1 ? salesman : 0;
        response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getLedgerBySalesManLike/$dataBase',
          queryParameters: {'salesman': _salesman, 'like': like},
        );
      } else {
        response = await dio.get(
            '${pref.getString('api')}${apiV}Ledger/getLedgerListLike/$dataBase',
            queryParameters: {'name': like});
      }
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var ledger in jsonResponse) {
          _items.add(LedgerModel.fromJson(ledger));
        }
        // "http://202.21.37.226:90/api/v26/Ledger/getLedgerBySalesManLike/ASPER23?salesman=2&like=a"
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
  Future<List<LedgerModel>> getLedgerBySalesMans(
      int salesman, ) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      Response response;
      if (salesman > 1) {
        var _salesman = salesman > 1 ? salesman : 0;
        response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getLedgerBySales/$dataBase',
          queryParameters: {'salesman': _salesman, },
        );
      } else {
        response = await dio.get(
            '${pref.getString('api')}${apiV}Ledger/getLedgerListLike/$dataBase',);
      }
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var ledger in jsonResponse) {
          _items.add(LedgerModel.fromJson(ledger));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<LedgerModel>> getSupplierNameList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerModel> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getCustomerCashList/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var ledger in jsonResponse) {
          _items.add(LedgerModel.fromJson(ledger));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> getSalesAccountList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getSalesAccountList/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        // for (var ledger in jsonResponse) {
        //   _items.add(LedgerModel.fromJson(ledger));
        // }
        _items = jsonResponse;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

 Future<CustomerModel> getCustomerDetail(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    CustomerModel _item = CustomerModel();
    try { 
      final response = await dio
          .get('${pref.getString('api')}${apiV}Ledger/getDetail/$dataBase/$id');
      if (response.statusCode == 200) {
        List<dynamic> _data = response.data;

        // _item = CustomerModel.fromJson(_data[0]);
          if (_data.isNotEmpty) {
          _item = CustomerModel.fromJson(_data[0]);
        } else {
          _item = CustomerModel.emptyData();
          _item.id = id;
          _item.name = '';  
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _item;
  }
 Future<CashCustomerModel> getCashCustomerDetail(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    CashCustomerModel _item = CashCustomerModel();
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}Ledger/getDetail/$dataBase/$id');
      if (response.statusCode == 200) {
        List<dynamic> _data = response.data;
        // _item = CustomerModel.fromJson(_data[0]);
          if (_data.isNotEmpty) {
          _item = CashCustomerModel.fromJson(_data[0]);
        } else {
          _item = CashCustomerModel.emptyData();
          _item.id = id;
          _item.name = '';
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _item;
  }

  // search customers 

  Future<List<CustomerModel>> searchCustomers(String query) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = 'cSharp';
  dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");

  try {
    final response = await dio.get(
        '${pref.getString('api')}${apiV}Ledger/search/$dataBase',
        queryParameters: {'query': query});

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((item) => CustomerModel.fromJson(item)).toList();
    } else {
      debugPrint('Failed to load data');
      return [];
    }
  } on DioError catch (e) {
    final errorMessage = DioExceptions.fromDioError(e).toString();
    debugPrint(errorMessage);
    return [];
  }
}   


//   Stream<CustomerModel> getCustomerDetailStream(int id) async* {
//   SharedPreferences pref = await SharedPreferences.getInstance();
//   String dataBase = 'cSharp';
//   dataBase = isEstimateDataBase
//       ? (pref.getString('DBName') ?? "cSharp")
//       : (pref.getString('DBNameT') ?? "cSharp");
//   CustomerModel _item = CustomerModel();
//   try {
//     final response = await dio
//         .get('${pref.getString('api')}${apiV}Ledger/getDetail/$dataBase/$id');
//     if (response.statusCode == 200) {
//       List<dynamic> _data = response.data;
//       _item = CustomerModel.fromJson(_data[0]);
//       yield _item;
//     } else {
//       debugPrint('Failed to load data');
//     }
//   } catch (e) {
//     final errorMessage =
//         DioExceptions.fromDioError('$e' as DioError).toString();
//     debugPrint(errorMessage.toString());
//   }
// }

//   Stream<CustomerModel> getCustomerDetailStockStream(int id) async* {
//   SharedPreferences pref = await SharedPreferences.getInstance();
//   String dataBase = 'cSharp';
//   dataBase = isEstimateDataBase
//       ? (pref.getString('DBName') ?? "cSharp")
//       : (pref.getString('DBNameT') ?? "cSharp");
//   CustomerModel _item = CustomerModel();
//   try {
//     final response = await dio.get(
//         '${pref.getString('api')}${apiV}Ledger/getDetailWithStock/$dataBase/$id');
//     if (response.statusCode == 200) {
//       List<dynamic> _data = response.data;
//       _item = CustomerModel.fromJson(_data[0]);
//       yield _item;
//     } else {
//       debugPrint('Failed to load data');
//     }
//   } catch (e) {
//     final errorMessage =
//         DioExceptions.fromDioError('$e' as DioError).toString();
//     debugPrint(errorMessage.toString());
//   }
// }

  Future<CustomerModel> getCustomerDetailStock(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    CustomerModel _item = CustomerModel();
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getDetailWithStock/$dataBase/$id');
      if (response.statusCode == 200) {
        List<dynamic> _data = response.data;
        // _item = CustomerModel.fromJson(_data[0]);
          if (_data.isNotEmpty) {
          _item = CustomerModel.fromJson(_data[0]);
        } else {
          _item = CustomerModel.emptyData();
          _item.id = id;
          _item.name = '';
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _item;
  }

  Future<List<Map<String, dynamic>>> getLedgerListByType(sType) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<Map<String, dynamic>> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getLedgerByType/$dataBase',
          queryParameters: {'type': sType});
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _items = List.from(data);
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<Map<String, dynamic>>> fetchProfitAndLossAccount(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<Map<String, dynamic>> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}accounts_report/ProfitAndLoss/$dataBase',
          queryParameters: data);
      if (response.statusCode == 200) {
        if (response.data.toString().isNotEmpty) {
          List<dynamic> data = response.data;
          _items = List.from(data);
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<Map<String, dynamic>>> fetchClosingReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<Map<String, dynamic>> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}inventory_report/ClosingReport/$dataBase',
          queryParameters: data);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _items = List.from(data);
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> fetchClosingReportAll(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}inventory_report/ClosingReportAll/$dataBase',
          queryParameters: data);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _items = List.from(data);
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<Map<String, dynamic>>> getEmployeeList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<Map<String, dynamic>> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}EmployeeReport/getEmployeeList/$dataBase',
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        if (response.data.toString().isNotEmpty) {
          List<dynamic> data = response.data;
          _items = List.from(data);
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<Map<String, dynamic>>> spEmployee(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<Map<String, dynamic>> _items = [];
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}EmployeeReport/getEmployeeReport/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        if (response.data.toString().isNotEmpty) {
          List<dynamic> data = response.data;
          _items = List.from(data);
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<Map<String, dynamic>>> getCustomerCardList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<Map<String, dynamic>> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}CustomerCard/CustomerCardList/$dataBase',
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        if (response.data.toString().isNotEmpty) {
          List<dynamic> data = response.data;
          _items = List.from(data);
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
  
   Future<List<LedgerReports>> accountSummery(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<LedgerReports> _items = [];
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}accounts_report/getLedgerReport/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        if (response.data.toString().isNotEmpty) {
          List<dynamic> data = response.data['recordset'];
          _items = List.from(data);
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
  
  Future<List<Map<String, dynamic>>> fetchLedgerReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<Map<String, dynamic>> _items = [];
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}accounts_report/getLedgerReport/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        if (response.data.toString().isNotEmpty) {
          List<dynamic> data = response.data['recordset'];
          _items = List.from(data);
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<Map<String, dynamic>>> fetchBalanceSheet(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<Map<String, dynamic>> _items = [];
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}BalanceSheet/getBalanceSheet/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        if (response.data.toString().isNotEmpty) {
          List<dynamic> data = response.data;
          _items = List.from(data);
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<Map<String, dynamic>>> fetchGroupReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<Map<String, dynamic>> _items = [];
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}accounts_report/groupListNew/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _items = List.from(data);
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

//invoice wise customer //
  Future<List<StockProduct>> fetchStockProductByBarcode(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location =
        lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<StockProduct> _items = [];

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockSaleListByBarcode/$dataBase',
          queryParameters: {'Id': id, 'location': location});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

   Future<String> fetchBarcodePos(String itemCode, int customer,String allowNegativeStock, String statement ) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location =
        lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    // String _items = '';
    String _items =  '';

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}BarcodePos/$dataBase',
          queryParameters: {
            'itemCode': itemCode, 
            'location': location,
            'customer': 0,
            'allowNegativeStock': allowNegativeStock,
            'statement': statement
            });
      if (response.statusCode == 200) {
        // var jsonResponse = response.data;
        // for (var product in jsonResponse[0]) {
        //   _items = product['ProductName'];
        // }
         var jsonResponse = response.data;
       _items =   jsonResponse[0][0]['ProductName'];
        // for (var product in jsonResponse) {
        //   _items.add(StockProduct.fromJsonB(product));
        // }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) { 
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<StockProduct>> fetchBarcodePosId(String itemCode, int customer,String allowNegativeStock, String statement ) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location =
        lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    // String _items = '';
    List<StockProduct> _items = [];

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}BarcodePosMob/$dataBase',
          // 'http://192.168.29.207:8090/api/v26/BarcodePosMob/$dataBase',
          queryParameters: {
            'itemCode': itemCode,    
            'location': location,
            'customer': 0,
            'allowNegativeStock': allowNegativeStock,
            'statement': statement,
            'app' : 1
            });
      if (response.statusCode == 200) {
        var jsonResponse = response.data[0];
        for (var product in jsonResponse) {
          _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) { 
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }




     Future<List<StockProduct>> fetchStockVariantList(int id,bool taxUpdate,int locationId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location = locationId > 0 ? locationId.toString().trim()
        : lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<StockProduct> _items = [];
    try {
      final response = await dio.get(
          !taxUpdate
          ? '${pref.getString('api')}${apiV}stock/getStockVariantList/$dataBase'
          : '${pref.getString('api')}${apiV}stock/getStockVariantListGst/$dataBase',
          // !taxUpdate
          //  ? 'http://192.168.29.207:8090/api/v26/stock/getStockVariantList/$dataBase'
          //  : 'http://192.168.29.207:8090/api/v26/stock/getStockVariantListGst/$dataBase',
          queryParameters: {'Id': id, 'location': location});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
 final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
  
    Stream<List<StockProduct>> fetchStockVariantListStream(int id) async* {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location =
        lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<StockProduct> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockVariantList/$dataBase',
          queryParameters: {'Id': id, 'location': location});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) { 
          _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
 final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    yield _items;
  }


  Future<List<StockItem>> fetchStockProduct(String date) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0', id = '1';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 0) -
        1;
    location = lId.toString().trim().isNotEmpty
        ? lId < 1
            ? location
            : lId.toString().trim()
        : location;
    List<StockItem> _items = [];

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockSaleList/$dataBase',
          queryParameters: {'id': id, 'location': location, 'date': date});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          //.map((data) => new StockProduct.fromJson(data))
          _items.add(StockItem.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
  
  Stream<List<StockItem>> fetchStockProducts(String date) async* {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0', id = '1';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 0) -
        1;
    location = lId.toString().trim().isNotEmpty
        ? lId < 1
            ? location
            : lId.toString().trim()
        : location;
    List<StockItem> _items = [];

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockSaleList/$dataBase',
          queryParameters: {'id': id, 'location': location, 'date': date});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          //.map((data) => new StockProduct.fromJson(data))
          _items.add(StockItem.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    yield _items;
  }
  Future<List<StockItem>> fetchStockProductByCategory(String date,String categoryId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0', id = '1';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 0) -
        1;
    location = lId.toString().trim().isNotEmpty
        ? lId < 1
            ? location
            : lId.toString().trim()
        : location;
    List<StockItem> _items = [];

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockSaleListByCategory/$dataBase',
          queryParameters: {'id': id, 'location': location, 'date': date,'categoryId':categoryId});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          //.map((data) => new StockProduct.fromJson(data))
          _items.add(StockItem.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

   Future<List<StockItem>> fetchStockProductLike(
      String date, String like) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0', id = '1';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 0) -
        1;
    location = lId.toString().trim().isNotEmpty
        ? lId < 1
            ? location
            : lId.toString().trim()
        : location;
    List<StockItem> _items = [];

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockSaleListLike/$dataBase',
          queryParameters: {
            'id': id,
            'location': location,
            'date': date,
            'like': like
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          //.map((data) => new StockProduct.fromJson(data))
          _items.add(StockItem.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
  
  Future<List<StockItem>> fetchStockProductLazyLoading(
      String date, int limit, String lastDoc) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0', id = '1';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 0) -
        1;
    location = lId.toString().trim().isNotEmpty
        ? lId < 1
            ? location
            : lId.toString().trim()
        : location;
    List<StockItem> _items = [];

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockSaleListLike/$dataBase',
          queryParameters: {
            'id': id,
            'location': location,
            'date': date,
            'like': limit
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          //.map((data) => new StockProduct.fromJson(data))
          _items.add(StockItem.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<StockItem>> fetchNoStockProduct(String date) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0', id = '1';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 0) -
        1;
    location = lId.toString().trim().isNotEmpty
        ? lId < 1
            ? location
            : lId.toString().trim()
        : location;
    List<StockItem> _items = [];

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Product/getProductList/$dataBase',
          queryParameters: {'date': date});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          //.map((data) => new StockProduct.fromJson(data))
          _items.add(StockItem.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
  Stream<List<StockItem>> fetchNoStockProducts(String date) async* {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0', id = '1';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 0) -
        1;
    location = lId.toString().trim().isNotEmpty
        ? lId < 1
            ? location
            : lId.toString().trim()
        : location;
    List<StockItem> _items = [];

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Product/getProductList/$dataBase',
          queryParameters: {'date': date});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          //.map((data) => new StockProduct.fromJson(data))
          _items.add(StockItem.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    yield _items;
  }

 Future<List<StockItem>> fetchNoStockProductLike(
      String date, String like) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0', id = '1';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 0) -
        1;
    location = lId.toString().trim().isNotEmpty
        ? lId < 1
            ? location
            : lId.toString().trim()
        : location;
    List<StockItem> _items = [];

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Product/getProductListLike/$dataBase',
          queryParameters: {'date': date, 'like': like});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          //.map((data) => new StockProduct.fromJson(data))
          _items.add(StockItem.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
  
  Future<List<StockItem>> fetchStockProductByLocation(
      String location, String date) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', id = '1';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    location = location.toString().trim().isNotEmpty ? location : '0';
    List<StockItem> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockSaleList/$dataBase',
          queryParameters: {'id': id, 'location': location, 'date': date});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          if (product['qty'] > 0) {
            _items.add(StockItem.fromJson(product));
          }
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

 Future<List<StockProduct>> fetchStockVariant(int id,bool taxUpdate,int locationId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location = locationId > 0 ? locationId.toString().trim()
        : lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<StockProduct> _items = [];
    try {
      final response = await dio.get(
          !taxUpdate
          ? '${pref.getString('api')}${apiV}stock/getStockVariant/$dataBase'
          : '${pref.getString('api')}${apiV}stock/getStockVariantGst/$dataBase',
          // !taxUpdate
          // ? 'http://192.168.29.207:8090/api/v26/stock/getStockVariant/$dataBase'
          // : 'http://192.168.29.207:8090/api/v26/stock/getStockVariantGst/$dataBase',
          queryParameters: {'Id': id, 'location': location});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }


  Future<List<StockProduct>> fetchStockTransferItemVariant(
      int id, String location,bool taxUpdate) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<StockProduct> _items = [];
    try {
      final response = await dio.get(
          !taxUpdate
          ? '${pref.getString('api' ?? '127.0.0.1:80/api/')}${apiV}stock/getStockVariant/$dataBase'
          : '${pref.getString('api' ?? '127.0.0.1:80/api/')}${apiV}stock/getStockVariantGst/$dataBase',
          // 'http://192.168.29.207:8090/api/v26/stock/getStockVariant/$dataBase',
          queryParameters: {'Id': id, 'location': location});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
       final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }


  Stream<List<StockProduct>> fetchStockVariants(int id) async* {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location =
        lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<StockProduct> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockVariant/$dataBase',
          queryParameters: {'Id': id, 'location': location});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    yield _items;
  }

 Future<List<dynamic>> fetchNoStockVariant(String id,bool taxUpdate,int locationId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location = locationId > 0 ? locationId.toString().trim()
       : lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<StockProduct> _items = [];
    try {
      final response = await dio.get(
          !taxUpdate
         ? '${pref.getString('api')}${apiV}stock/getNonStockVariant/$dataBase'
         : '${pref.getString('api')}${apiV}stock/getNonStockVariantGst/$dataBase',
          // !taxUpdate
          // ? 'http://192.168.29.207:8090/api/v26/stock/getNonStockVariant/$dataBase'
          // : 'http://192.168.29.207:8090/api/v26/stock/getNonStockVariantGst/$dataBase',
          queryParameters: {'Id': id});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
           _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<StockProduct>> fetchNoStockVariants(String id,bool taxUpdate,int locationId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location = locationId > 0 ? locationId.toString().trim()
       : lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<StockProduct> _items = [];
    try {
      final response = await dio.get(
           !taxUpdate
          ? '${pref.getString('api')}${apiV}stock/getNonStockVariant/$dataBase'
          : '${pref.getString('api')}${apiV}stock/getNonStockVariantGst/$dataBase',
          //  !taxUpdate
          // ?'${pref.getString('api')}${apiV}stock/getNonStockVariant/$dataBase'
          // :'${pref.getString('api')}${apiV}stock/getNonStockVariantGst/$dataBase',
          queryParameters: {'Id': id});
      if (response.statusCode == 200) {
         var jsonResponse = response.data;
        for (var product in jsonResponse) {
           _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
 

   Future<List<StockProduct>> fetchNoStockVariantList(String id,bool taxUpdate,int locationId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location = locationId > 0 ? locationId.toString().trim()
       : lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<StockProduct> _items = [];
    try {
      final response = await dio.get(
          !taxUpdate
         ? '${pref.getString('api')}${apiV}stock/getNonStockVariantList/$dataBase'
         : '${pref.getString('api')}${apiV}stock/getNonStockVariantListGst/$dataBase',
          // !taxUpdate
          // ? 'http://192.168.29.207:8090/api/v26/stock/getNonStockVariantList/$dataBase'
          // : 'http://192.168.29.207:8090/api/v26/stock/getNonStockVariantListGst/$dataBase',
          queryParameters: {'Id': id});
   if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
       final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }


  Future<List<StockProduct>> fetchStockVariantProduct(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location =
        lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<StockProduct> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockVariant/$dataBase',
          queryParameters: {'Id': id, 'location': location});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<StockProduct>> fetchStockItem(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location =
        lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<StockProduct> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockItem/$dataBase',
          queryParameters: {'Id': id, 'location': location});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

   Future<List<StockProduct>> fetchStockByItemCode(String itemCode,bool taxUpdate) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location =
        lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<StockProduct> _items = [];
    try {
      final response = await dio.get(
        !taxUpdate
          ? '${pref.getString('api')}${apiV}stock/getStockByItemCode/$dataBase'
          : '${pref.getString('api')}${apiV}stock/getStockByItemCodeGst/$dataBase',
          // 'http://192.168.29.207:8090/api/v26/stock/getStockByItemCode/$dataBase',
          queryParameters: {'itemCode': itemCode, 'location': location});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
     final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<StockProduct>> fetchProductByItemCode(String itemCode,bool taxUpdate) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location =
        lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<StockProduct> _items = [];
    try {
      final response = await dio.get(
        !taxUpdate
          ? '${pref.getString('api')}${apiV}stock/getProductByItemCode/$dataBase'
          : '${pref.getString('api')}${apiV}stock/getProductByItemCodeGst/$dataBase',
          // 'http://192.168.0.111:8090/api/v26/stock/getProductByItemCodeGst/$dataBase',
          queryParameters: {'itemCode': itemCode, 'location': location});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          _items.add(StockProduct.fromJson(product));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
     final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }



  Future<double> getStockOf(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location =
        lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<double> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/stock/selectStockById/$dataBase',
          queryParameters: {'id': id, 'location': location});
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data;
        if (jsonResponse.isNotEmpty) {
          for (var product in jsonResponse) {
            _items.add(double.tryParse(product['Qty'].toString())!);
          }
        } else {
          _items.add(0);
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items[0];
  }

  Future<double> getMinimumRateOf(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<double> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/product/getProductPurchase/$dataBase',
          queryParameters: {'id': id});
      //v20 '/product/getProductPurchase/$dataBase/$id');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var product in jsonResponse) {
          _items.add(double.tryParse(product['Qty'].toString())!);
        }
        return _items[0];
      } else {
        debugPrint('Unexpected error Occurred!');
        return 0;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return 0;
    }
  }

  Future<List<UnitModel>> fetchUnitOf(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<UnitModel> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Product/getMultiUnit/$dataBase',
          queryParameters: {'id': id});
      //v20 'Product/getMultiUnit/$dataBase/$id');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var data in jsonResponse) {
          _items.add(UnitModel.fromJson(data));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<UnitModel>> fetchUnitList(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<UnitModel> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Product/getMultiUnitAll/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var data in jsonResponse) {
          _items.add(UnitModel.fromJson(data));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> getMainAccount() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getMainAccount/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        _items = jsonResponse as List;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> getMainHead() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}Ledger/getMainHead/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        return jsonResponse as List;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> fetchOtherRegList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}OtherRegistration/$dataBase')
          // .get('http:192.168.29.123:8090/api/${apiV}OtherRegistration/$dataBase')
          ;
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        _items = jsonResponse as List;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<bool> addOtherRegistration(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}OtherRegistration/Add/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 201) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> editOtherRegistration(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}OtherRegistration/Edit/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 201) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> deleteOtherRegistration(id) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
          '${pref.getString('api')}${apiV}OtherRegistration/Delete/$dataBase',
          queryParameters: {'auto': id},
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        ret = true;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<List<dynamic>> fetchDetailAmount() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}sale/getDetailAmount/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        _items = jsonResponse as List;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> fetchWarrentyItemFromSalesList(int ledgerId, int itemId) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = 'cSharp';
  dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");

  dynamic _items = [];
  
  try {
    final response = await dio.get(
      '${pref.getString('api')}${apiV}WarrantyEntry/FindSales/$dataBase',
      queryParameters: {'ledgerId': ledgerId, 'itemId': itemId},
    );

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      // Assuming response.data is a list of lists
      // if (jsonResponse is List) {
        // Flattening the list if the response is a list of lists
        for (var sublist in jsonResponse) {
          // if (sublist is List) {
            for (var item in sublist) {
              if (item is Map<String, dynamic>) {
                _items.add(item);
              }
            }
          // }
        }
      // }
    } else {
      debugPrint('Unexpected error occurred!');
    }
  } catch (e) {
    final errorMessage =
        DioExceptions.fromDioError('$e' as DioError).toString();
    debugPrint(errorMessage.toString());
  }

  return _items;    
}

  Future<dynamic> fetchPreviousBills(ledger) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sale/previous_bills/$dataBase',
          queryParameters: {'id': ledger, 'fyId': currentFinancialYear!.id});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<dynamic> fetchPreviousPurchaseBills(ledger) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}purchase/previous_bills/$dataBase',
          queryParameters: {'id': ledger, 'fyId': currentFinancialYear!.id});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<dynamic> fetchItemBills(sDate, eDate) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sale/Item_bills/$dataBase',
          queryParameters: {
            'sDate': sDate,
            'eDate': eDate,
            'fyId': currentFinancialYear!.id
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<dynamic> fetchSalesInvoice(int id, int type,bool taxUpdate) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          !taxUpdate
          ? '${pref.getString('api')}${apiV}sale/find/$dataBase'
          : '${pref.getString('api')}${apiV}sale/findGst/$dataBase',
          queryParameters: {
            'id': id,
            'type': type,
            'fyId': currentFinancialYear!.id,
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<dynamic> fetchDeliveryNoteInvoice(int id, int type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sale/findDeliveryNote/$dataBase',
          queryParameters: {
            'id': id,
            'type': type,
            'fyId': currentFinancialYear!.id,
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<dynamic> fetchSalesReturnInvoice(String id, int type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sale/findReturn/$dataBase',
          queryParameters: {
            'id': id,
            'type': type,
            'fyId': currentFinancialYear!.id,
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

   Future<List<ProductPurchaseModel>> fetchAllProductPurchase(bool taxUpdate) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<ProductPurchaseModel> _items = [];
    try {
      final response = await dio.get(
           !taxUpdate
         ? '${pref.getString('api')}${apiV}Product/getProductListPurchase/$dataBase'
         : '${pref.getString('api')}${apiV}Product/getProductListPurchaseGst/$dataBase'
      //  'http://192.168.29.207:8090/api/v26/Product/getProductListPurchaseGst/$dataBase'
        // 'http://192.168.29.207:8090/api/v26/Product/getProductListPurchase/$dataBase'
          );
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = List<ProductPurchaseModel>.from(
            jsonResponse.map((x) => ProductPurchaseModel.fromMap(x)));
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
  Future<List<dynamic>> fetchProductPurchaseListLike(String name) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Product/getProductListPurchaseLike/$dataBase',
          queryParameters: {'name': name});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

   Future<List<dynamic>> fetchProductPrize(int id,int supplierId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Product/getProductPurchaseById/$dataBase',
          // 'http://192.168.29.207:8090/api/v26/Product/getProductPurchaseById/$dataBase',
          queryParameters: {'id': id, 'sId': supplierId});

      if (response.statusCode == 200) {
        dynamic jsonResponse = response.data;
        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> fetchProductPrizeStock(int id, int location) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Product/getProductPurchaseByStock/$dataBase',
          queryParameters: {'id': id, 'location': location});
      if (response.statusCode == 200) {
        dynamic jsonResponse = response.data;
        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future fetchExpenseData(
      String sDate, String eDate, String sType, var branch) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}dashboard/Expense/$dataBase',
          queryParameters: {
            'statementType': sType,
            'sDate': sDate,
            'eDate': eDate,
            'branch': branch
          });

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        return jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
  }

  Future fetchExpenseLedger(String sDate, String eDate, name, branch) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}dashboard/getExpenseLedger/$dataBase',
          queryParameters: {
            'sDate': sDate,
            'eDate': eDate,
            'name': name,
            'branch': branch
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        return jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
  }

  Future fetchCashBankLedger(String sDate, String eDate) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    var branch = 0;
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}dashboard/getCashBankLedger/$dataBase',
          queryParameters: {'sDate': sDate, 'eDate': eDate, 'branch': branch});

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        return jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
  }

  Future<List<ChartPayRec>> fetchReceivableAndPayable(
      String sDate, String eDate, var branch) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<ChartPayRec> data = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}dashboard/getReceivableAndPayable/$dataBase',
          queryParameters: {'sDate': sDate, 'eDate': eDate, 'branch': branch});

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var _data in jsonResponse) {
          data.add(ChartPayRec.fromJson(_data));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return data;
  }

  Future<dynamic> fetchPurchaseInvoiceSp(int id, String type,int frmId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/purchaseSP/find/$dataBase',
          queryParameters: {
            'id': id,
            'statement': type,
            'fyId': currentFinancialYear!.id,
            'frmId': frmId
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        // print(jsonResponse);

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<dynamic> fetchPurchaseInvoice(int id, String type,int frmId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/purchaseFind/$dataBase',
          queryParameters: {
            'id': id,
            'type': type,
            'fyId': currentFinancialYear!.id,
            'frmId': frmId
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<dynamic> fetchPurchaseInvoiceOld(int id, String type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/purchase/find/$dataBase',
          queryParameters: {
            'id': id,
            'type': type,
            'fyId': currentFinancialYear!.id
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<dynamic> fetchPurchaseReturnInvoice(int id, String type, var frmId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/purchaseReturn/find/$dataBase',
          queryParameters: {
            'id': id,
            'type': type,
            'fyId': currentFinancialYear!.id,
            'frmId': frmId
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<bool> deletePurchase(entryNo, type,frmId) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
        '${pref.getString('api')}${apiV}purchase/delete/$dataBase',
        queryParameters: {
          'entryNo': entryNo,
          'type': type,
          'fyId': currentFinancialYear!.id,
          'frmId': frmId,
        },
      );
      if (response.statusCode == 200) {
        
        ret = response.data['returnValue'] > 0 ? true : false;
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (ex) {
      ex.toString();
      ret = false;
    }
    return ret;
  }

  Future<dynamic> fetchVoucher(int id, String type, frmId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/Voucher/find/$dataBase',
          queryParameters: {
            'id': id,
            'type': type,
            'fyId': currentFinancialYear!.id,
            'frmId': frmId
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<dynamic> fetchJournalVoucher(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/Journal/find/$dataBase',
          queryParameters: {'id': id, 'fyId': currentFinancialYear!.id});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<dynamic> fetchInvoiceVoucher(int id, String type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/InvoiceVoucher/find/$dataBase',
          queryParameters: {
            'id': id,
            'type': type,
            'fyId': currentFinancialYear!.id
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<dynamic> fetchStockTransfer(int id, String type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/stock/stockTransferFind/$dataBase',
          queryParameters: {'entryNo': id, 'fyId': currentFinancialYear!.id});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<bool> deleteStockTransfer(entryNo, type) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
        '${pref.getString('api')}${apiV}stock/delete/$dataBase',
        queryParameters: {
          'entryNo': entryNo,
          'type': type,
          'fyId': currentFinancialYear!.id
        },
      );
      if (response.statusCode == 200) {
        ret = response.data['returnValue'] > 0 ? true : false;
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<List<Map<String, dynamic>>> fetchQuickSearch(value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<Map<String, dynamic>> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}inventory_report/QuickSearch/$dataBase',
          queryParameters: {'name': value});

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _items = List.from(data);
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> getProductTracking(id, ledger) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sale/getProductTracking/$dataBase',
          queryParameters: {'id': id, 'ledger': ledger});

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _items = data;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> getSoldProductTracking(id, ledger) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sale/getSoldProductTracking/$dataBase',
          queryParameters: {'id': id, 'ledger': ledger});

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _items = data;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<ProductManageModel>> fetchProductDetails(id, String date) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp', location = '0';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    if (locationList.isNotEmpty) {
      location = locationList
          .where((element) => element.value == defaultLocation)
          .map((e) => e.key)
          .first
          .toString();
    }
    int lId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    location =
        lId.toString().trim().isNotEmpty ? lId.toString().trim() : location;
    List<ProductManageModel> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getProductManagement/$dataBase',
          queryParameters: {'id': id, 'location': location, 'date': date});

      if (response.statusCode == 200) {
        var data = response.data;
        for (var row in data) {
          _items.add(ProductManageModel.fromMap(row));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<bool> updateProductDetails(List<ProductManageModel> data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}stock/UpdateProductManagement/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        if (response.data['returnValue'] > 0) {
          return response.data['returnValue'] > 0 ? true : false;
        } else {
          return false;
        }
      } else {
        debugPrint('Unexpected error Occurred!');
        return false;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return false;
    }
  }

  Future<List<dynamic>> getVoucherList(
      String ledCode,
      String location,
      String groupCode,
      String project,
      String fromDate,
      String toDate,
      String sDate,
      String eDate,
      String where,
      String cashId,
      String salesman,
      String statement,
      String area,
      String route,
      dataFirmList) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}voucher_report/getListReport/$dataBase',
          queryParameters: {
            'ledCode': ledCode,
            'location': location,
            'groupCode': groupCode,
            'project': project,
            'fromDate': fromDate,
            'toDate': toDate,
            'sDate': sDate,
            'eDate': eDate,
            'where': where,
            'cashId': cashId,
            'salesman': salesman,
            'statement': statement,
            'areaId': area,   
            'routeId': route,
            'formsType': dataFirmList
          });

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _items = data;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<dynamic>> getBankVoucherList(
      String sDate,
      String eDate,
      String cDate,
      int bankId,
      int id,
      int groupId,
      String status,
      int location,
      int clr,
      String statementType) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}BankVoucherReport/$dataBase',
          // 'http://192.168.29.207:8090/api/v26/BankVoucherReport/$dataBase',
          queryParameters: {
            'sDate': sDate,
            'eDate': eDate,
            'cDate': cDate,
            'bankId': bankId,
            'id': id,
            'groupId': groupId,
            'status': status,
            'location': location,
            'clr': clr,
            'statementType': statementType,
          });

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _items = data;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }


  Future<int> getStockManageMentId() async {
    int ret = 0;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockManagementId/$dataBase',
          queryParameters: {'fyId': currentFinancialYear!.id});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] + 1;
      } else {
        ret = 0;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> stockManagementUpdate(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}stock/stockManagement/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to load data');
        return false;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return false;
    }
  }

  Future<bool> stockManagementDelete(entryNo) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
          '${pref.getString('api')}${apiV}stock/deleteStockManagement/$dataBase',
          queryParameters: {
            'fyId': currentFinancialYear!.id,
            'entryNo': entryNo
          },
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to load data');
        return false;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return false;
    }
  }

  Future<List<dynamic>?> stockManagementFind(String entryNo) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/findStockManagement/$dataBase',
          queryParameters: {
            'fyId': currentFinancialYear!.id,
            'entryNo': entryNo
          },
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        return response.data;
      } else {
        debugPrint('Failed to load data');
        return null;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return null;
    }
  }

  Future<List<CompanySettings>> getSoftwareSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<CompanySettings> _data = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}SoftwareSettings/$dataBase');
      if (response.statusCode == 200) {
        for (var data in response.data) {
          _data.add(CompanySettings.fromJson1(data));
        }
      } else {
        //
      }
    } on DioError {
      // print(e.message);
    }
    return _data;
  }

  Future<List<PrintSettingsModel>> getPrintSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<PrintSettingsModel> _data = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}PrintSettings/$dataBase',
          queryParameters: {
            'fyId': currentFinancialYear != null ? currentFinancialYear!.id : 0
          }
          );
      if (response.statusCode == 200) {
        for (var data in response.data) {
          _data.add(PrintSettingsModel.fromMap(data));
        }
      } else {
        //
      }
    } on DioError {
      // print(e.message);
    }
    return _data;
  }

  Future<bool> companyUpdate(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}company/company/update',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        return response.data > 0 ? true : false;
      } else {
        debugPrint('Failed to load data');
        return false;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return false;
    }
  }

  Future<bool> updateGeneralSetting(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}updateGeneralSetting/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        return response.data > 0 ? true : false;
      } else {
        debugPrint('Failed to load data');
        return false;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return false;
    }
  }

  Future<dynamic> eInvoiceDetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}EInvoice/Details/$dataBase');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        debugPrint('Unexpected error Occurred!');
        return {};
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return {};
    }
  }

  Future<bool> eInvoiceUpdate(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}EInvoice/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to load data');
        return false;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return false; 
    }
  }

  Future<dynamic> getPublicIp() async {
    try {
      final response = await dio.get("https://ipinfo.io/ip");
      if (response.statusCode == 200) {
        return response.data;
      } else {
        debugPrint('Unexpected error Occurred!');
        return {};
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return {};
    }
  }

  Future<AuthClass> authenticateGSTPortal(
      username, password, ipAddress, clientId, clientSecret, gstIn) async {
    AuthClass? data;
    try {
      final response = await dio.get(gstBaseApi + gstAuthApi,
          options: Options(headers: {
            'accept': '*/*',
            'username': username,
            'password': password,
            'ip_address': ipAddress,
            'client_id': clientId,
            'client_secret': clientSecret,
            'gstin': gstIn,
          }),
          queryParameters: {'email': 'shersoftware@gmail.com'});

      if (response.statusCode == 200) {
        var _data = response.data;
        data = AuthClass.fromMap(_data);
        return data;
      } else {
        debugPrint('Failed to load data');
        return data!;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return data!;
    }
  }

  Future<GstNoResult> getGstResult(
      String bClient,
      String taxNumber,
      String username,
      String ipAddress,
      clientId,
      String clientSecret,
      String authToken,
      String companyGstNo) async {
    GstNoResult? data;
    try {
      final response = await dio.get(gstBaseApi + gstDetailsApi,
          queryParameters: {
            "param1": taxNumber,
            "email": bClient != "SHERSOFT"
                ? "ac.japansquare@gmail.com"
                : "shersoftware@gmail.com"
          },
          options: Options(headers: {
            "param1": taxNumber,
            "email": bClient != "SHERSOFT"
                ? "abc@gmail.com"
                : "shersoftware@gmail.com",
            'ip_address': ipAddress,
            'client_id': clientId,
            'client_secret': clientSecret,
            'username': username,
            'auth-token': authToken,
            'gstin': companyGstNo,
          }));

      if (response.statusCode == 200) {
        if (response.data != null) {
          var _data = response.data;
          if (_data['status_cd'] == '0') {
            data = GstNoResult(
              data: GSTNoData(
                  AddrBnm: '',
                  AddrBno: '',
                  AddrFlno: '',
                  AddrLoc: '',
                  AddrPncd: 0,
                  AddrSt: '',
                  BlkStatus: '',
                  DtDReg: '',
                  DtReg: '',
                  Gstin: '',
                  LegalName: '',
                  StateCode: 0,
                  Status: '',
                  TradeName: '',
                  TxpType: ''),
              status_cd: _data['status_cd'] ?? '',
              status_desc: _data['status_desc'] ?? '',
            );
          } else {
            data = GstNoResult.fromMap(_data);
          }
        }
        return data!;
      } else {
        debugPrint('Failed to load data');
        return data!;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return data!;
    }
  }

  Future<IRnResult> generateEInvoice(
      String bClient,
      String username,
      String ipAddress,
      clientId,
      String clientSecret,
      String authToken,
      String companyGstNo,
      data) async {
    IRnResult? data;
    try {
      final response = await dio.post(gstBaseApi + gstIrnApi,
          queryParameters: {
            "email": bClient != "SHERSOFT"
                ? "ac.japansquare@gmail.com"
                : "shersoftware@gmail.com"
          },
          options: Options(headers: {
            'accept': '*/*',
            'ip_address': ipAddress,
            'client_id': clientId,
            'client_secret': clientSecret,
            'username': username,
            'auth-token': authToken,
            'gstin': companyGstNo,
            'Content-Type': 'application/json'
          }),
          data: data);

      if (response.statusCode == 200) {
        var _data = response.data;
        data = IRnResult.fromMap(_data);
        return data;
      } else {
        debugPrint('Failed to load data');
        return data!;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return data!;
    }
  }

  Future<IRnResult> cancelIRN(
      String bClient,
      String username,
      String ipAddress,
      clientId,
      String clientSecret,
      String authToken,
      String companyGstNo,
      data) async {
    IRnResult? data;
    try {
      final response = await dio.post(gstBaseApi + gstCancelIrnApi,
          queryParameters: {
            "email": bClient != "SHERSOFT"
                ? "ac.japansquare@gmail.com"
                : "shersoftware@gmail.com"
          },
          options: Options(headers: {
            'accept': '*/*',
            'ip_address': ipAddress,
            'client_id': clientId,
            'client_secret': clientSecret,
            'username': username,
            'auth-token': authToken,
            'gstin': companyGstNo,
            'Content-Type': 'application/json'
          }),
          data: data);

      if (response.statusCode == 200) {
        var _data = response.data;
        data = IRnResult.fromMap(_data);
        return data;
      } else {
        debugPrint('Failed to load data');
        return data!;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return data!;
    }
  }

  Future<File> getInvoiceDesignerPdfFile(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    data.update('code', (value) => pref.getString('Code') ?? 'COM');

    // try {
    final response = await dio.post(invoiceUrl,
        data: json.encode(data),
        options: Options(
            headers: {'Content-Type': 'application/json'},
            responseType: ResponseType.bytes));
    final Directory appDir = await getTemporaryDirectory();
    String tempPath = appDir.path;
    final String fileName = '${DateTime.now().microsecondsSinceEpoch}-s.pdf';
    File file = File('$tempPath/$fileName');
    if (!await file.exists()) {
      await file.create();
    }
    await file.writeAsBytes(response.data);
    return file;
    // } catch (value) {
    //   if (value is DioException) {
    //     debugPrint(value.response.toString());
    //   }
    //   debugPrint(value.toString());
    // }
  }

  Future<List<int>?> getInvoiceDesignerPdfData(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    data.update('code', (value) => pref.getString('Code') ?? 'COM');
    try {
      final response = await dio.post(
        invoiceUrl,
      // 'http://148.72.210.101:888/Home/DownloadPdf',
          data: json.encode(data),
          options: Options(
              headers: {'Content-Type': 'application/json'},
              responseType: ResponseType.bytes,
              validateStatus: (status) => status! < 600,));
      if (response != null) {
        return response.data;
      }
      debugPrint('The download failed.');
    } catch (value) {
      if (value is DioError) {
        debugPrint(value.response.toString());
      }
      // debugPrint(value.toString());
    }
    return null;
  }
  
  Future<bool> updateBillInfo(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}sale/editIrn/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to load data');
        return false;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return false;
    }
  }

  Future<bool> updateReturnBillInfo(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}sale/editSalesReturnIrn/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to load data');
        return false;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return false;
    }
  }

  Future<bool> updateCanceledBillInfo(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}sale/editCanceledSaleIrn/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to load data');
        return false;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return false;
    }
  }

  Future<bool> updateCanceledReturnBillInfo(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}sale/editCanceledSalesReturnIrn/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to load data');
        return false;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>> getGeoCode(String pin) async {
    final response = await dio.get(geoApiFy.replaceAll('pin', pin),
        options: Options(headers: {'Content-Type': 'application/json'}));
    if (response.statusCode == 200) {
      var data = response.data['results'][0];
      return {'place': data['county'], 'lon': data['lon'], 'lat': data['lat']};
    } else {
      return {};
    }
  }

  Future<EWayResultModel> authEWay(
      String bClient,
      String username,
      String password,
      String ipAddress,
      clientId,
      String clientSecret,
      gstNo) async {
    EWayResultModel data;
    try {
      final response = await dio.get(gstBaseApi + eWayAuthApi,
          queryParameters: {
            "email":
            //  bClient != "SHERSOFT"
            //     ? "ac.japansquare@gmail.com"
            //     :
                 "shersoftware@gmail.com",
            'username': username,
            'password': password
          },
          options: Options(headers: {
            'Accept': 'application/json',
            'ip_address': ipAddress,
            'client_id': clientId,
            'client_secret': clientSecret,
            'gstin': gstNo
          }));
      if (response.statusCode == 200) {
        var _data = response.data;
        return data = EWayResultModel.fromMap(_data);
      } else {
        debugPrint('Failed to load data');
        return EWayResultModel.emptyData();
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return EWayResultModel.emptyData();
    }
  }

  Future<EWayResultModel> generateEWayBill(
      String bClient,
      String gstNo,
      String password,
      String ipAddress,
      clientId,
      String clientSecret,
      data) async {
    EWayResultModel? data;
    try {
      final response = await dio.post(gstBaseApi + eWayBillApi,
          queryParameters: {
            "email": 
            // bClient != "SHERSOFT"
            //     ? "ac.japansquare@gmail.com"
            //     :
                 "shersoftware@gmail.com"
          },
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'ip_address': ipAddress,
            'client_id': clientId,
            'client_secret': clientSecret,
            'gstin': gstNo
          }),
          data: data);
      if (response.statusCode == 200) {
        var _data = response.data;
        return data = EWayResultModel.fromMap(_data);
      } else {
        debugPrint('Failed to load data');
        return EWayResultModel.emptyData();
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return EWayResultModel.emptyData();
    }
  }

  Future<EWayResultModel> cancelEWayBill(
      String bClient,
      String gstNo,
      String password,
      String ipAddress,
      clientId,
      String clientSecret,
      data) async {
    try {
      final response = await dio.post(gstBaseApi + eWayBillCancelApi,
          queryParameters: {
            "email": 
            // bClient != "SHERSOFT"
            //     ? "ac.japansquare@gmail.com"
            //     :
                 "shersoftware@gmail.com"
          },
          options: Options(headers: { 
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'ip_address': ipAddress,
            'client_id': clientId,
            'client_secret': clientSecret,
            'gstin': gstNo
          }),
          data: data);
      if (response.statusCode == 200) {
        var _data = response.data;
        return EWayResultModel.fromMap(_data);
      } else {
        debugPrint('Failed to load data');
        return EWayResultModel.emptyData();
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return EWayResultModel.emptyData();
    }
  }

  Future<List<dynamic>> getTaxReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}TaxReport/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<List<SmsDataModel>> getSMSApiData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<SmsDataModel> data = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}getSMSSettings/$dataBase');
      if (response.statusCode == 200) {
        data = response.data;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return data;
  }

  Future<List<SmsDataModel>> getSMSApiDataList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<SmsDataModel> data = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}getSMSSettingsList/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var _data in jsonResponse) {
          data.add(SmsDataModel.fromMap(_data));
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return data;
  }

  Future<List<UpiModel>> getUpiDataList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<UpiModel> data = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}getUpiList/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var _data in jsonResponse) {
          data.add(UpiModel.fromMap(_data));
        }                                                  
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return data;
  }


  Future<bool> sentSmsOverApi(String urlData) async {
    try {
      final response = await dio.get(urlData);
      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to load data');
        return false;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return false;
    }
  }

  Future<bool> saveSmsApi(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    bool result = false;
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}addSMSSettings/$dataBase',
          data: json.encode(data));
      if (response.statusCode == 200) {
        result = true;
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return result;
  }

  Future<dynamic> fetchBankVoucher(int id, String type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/BankVoucher/find/$dataBase',
          queryParameters: {
            'id': id,
            'type': type,
            'fyId': currentFinancialYear!.id
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<int> addBankVoucher(List<Map<String, Object?>> data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}BankVoucher/add/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        if (response.data['returnValue'] > 0) {
          return response.data['returnValue'];
        } else {
          return 0;
        }
      } else {
        debugPrint('Unexpected error Occurred!');
        return 0;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return 0;
    }
  }

  Future<int> deleteBankVoucher(
      String id, int fyId, String statementType) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
        '${pref.getString('api')}${apiV}BankVoucher/delete/$dataBase',
        queryParameters: {
          'id': id,
          'statementType': statementType,
          'fyId': currentFinancialYear!.id
        },
      );

      if (response.statusCode == 200) {
        if (response.data['returnValue'] > 0) {
          return response.data['returnValue'];
        } else {
          return 0;
        }
      } else {
        debugPrint('Unexpected error Occurred!');
        return 0;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return 0;
    }
  }

  Future<List<dynamic>> getSerialNoReport(type, String serialNo, String itemId,
      String mfr, String category, String subCategory, String branch) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    String statement = type == 'Select All'
        ? 'all'
        : type == 'Details'
            ? 'details'
            : 'transaction';
    dynamic _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/serialNoReport/$statement/$dataBase',
          queryParameters: {
            'itemId': itemId,
            'serialNo': serialNo,
            'mfrId': mfr,
            'categoryId': category,
            'subCategoryId': subCategory,
            'branch': branch
          });
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<SalesManModel>> getSalesManList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<SalesManModel> resultData = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}$apiV/salesman/salesmanList/$dataBase');
      if (response.statusCode == 200) {
        for (var json in response.data) {
          resultData.add(SalesManModel.fromJson(json));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return resultData;
  }

  Future<List<SalesManModel>> getSalesManListAll() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<SalesManModel> resultData = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}$apiV/salesman/listAll/$dataBase');
      if (response.statusCode == 200) {
        for (var json in response.data) {
          resultData.add(SalesManModel.fromJson(json));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return resultData;
  }

  Future<List<SalesManModel>> getSalesManAll() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<SalesManModel> resultData = [];
    try {
      final response =
          await dio.get('${pref.getString('api')}$apiV/salesman/All/$dataBase');
      if (response.statusCode == 200) {
        for (var json in response.data) {
          resultData.add(SalesManModel.fromJson(json));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return resultData;
  }

  Future<EmployeeModel> findSalesman(String name) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    EmployeeModel? resultData;
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/salesman/find/$dataBase',
          queryParameters: {'name': name});
      if (response.statusCode == 200) {
        for (var employeeModel in response.data) {
          resultData = EmployeeModel.fromMap(employeeModel);
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return resultData!;
  }

  Future<bool> addSalesman(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}salesman/add/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 201) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> editSalesman(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}salesman/edit/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 201) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> deleteSalesman(String id, String name) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
          '${pref.getString('api')}${apiV}salesman/delete/$dataBase',
          queryParameters: {'auto': id, 'name': name},
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        ret = true;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> renameSalesMan(Map<String, String> body) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}salesman/rename/$dataBase',
          queryParameters: body,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        if (response.data.toString() == "1") {
          ret = true;
        } else {
          ret = false; //
        }
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

   Future<List<dynamic>> getCityListBySalesMan(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic resultData;
    try {
      final response = await dio.get(
          '${pref.getString('api')}$apiV/salesman/getCityListBySalesMan/$dataBase',
          queryParameters: {'id': id});
      if (response.statusCode == 200) {
        resultData = response.data;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return resultData;
  }

  Future<List<UserModel>> getUserListAll() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    List<UserModel> userList = [];
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response =
          await dio.get('${pref.getString('api')}${apiV}users/All/$dataBase');

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data['recordset'];
        if (jsonResponse.isNotEmpty) {
          for (var map in jsonResponse) {
            userList.add(UserModel(
                id: map['auto'],
                groupName: '',
                password: '',
                userId: 0,
                userName: map['name']));
          }
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return userList;
  }

  Future<bool> checkPasswordUser(String name, String password) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    bool check = false;
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}users/checkPassword/$dataBase',
          queryParameters: {'password': password, 'name': name});

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        check = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return check;
  }

  Future<bool> changePasswordUser(String name, String password) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    bool check = false;
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}users/changePassword/$dataBase',
          data: {'name': name, 'password': password});

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        check = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return check;
  }

  Future<UserModel> findUser(String name) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    UserModel userModel = UserModel.emptyData();
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}users/find/$dataBase',
          queryParameters: {'name': name});

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data;
        if (jsonResponse.isNotEmpty) {
          for (var map in jsonResponse) {
            userModel = UserModel.fromJson(map);
          }
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return userModel;
  }

  Future<bool> addUser(Map<String, Object> data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}users/add/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> editUser(Map<String, Object> data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}users/edit/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> deleteUser(String id, String name) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
          '${pref.getString('api')}${apiV}users/delete/$dataBase',
          queryParameters: {'auto': id, 'name': name},
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        ret = true;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<List<UserGroupModel>> getUserGroupListAll() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    List<UserGroupModel> userList = [];
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}userGroup/All/$dataBase');

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data;
        if (jsonResponse.isNotEmpty) {
          for (var map in jsonResponse) {
            userList.add(UserGroupModel.fromMap(map));
          }
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return userList;
  }

  Future<UserGroupModel> findUserGroup(String name) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    UserGroupModel? groupModel;
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}userGroup/find/$dataBase',
          queryParameters: {'name': name});

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data;
        if (jsonResponse.isNotEmpty) {
          groupModel = UserGroupModel.fromMap(jsonResponse[0]);
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return groupModel!;
  }

  Future<bool> addUserGroup(Map<String, Object> data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}userGroup/Add/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> editUserGroup(Map<String, Object> data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}userGroup/edit/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> deleteUserGroup(String name) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
          '${pref.getString('api')}${apiV}userGroup/delete/$dataBase',
          queryParameters: {'groupName': name},
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        ret = true;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<List<SalesType>> salesFormList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    List<SalesType>? resultData;
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
        '${pref.getString('api')}${apiV}salesForm/ListAll/$dataBase',
      );

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var data in jsonResponse) {
          resultData!.add(SalesType.fromJson(data));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return resultData!;
  }

  Future<bool> salesFormAdd(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}salesForm/add/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 201) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> salesOtherDetailsAdd(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}salesForm/addOtherDetails/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 201) {
        // var jsonResponse = response.data;
        ret = true;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> checkDomain() async {
    try {
      String domain = kIsWeb ? 'www.google.com' : 'https://www.google.com/';
      final response = await dio.get(domain);
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      return false;
      // debugPrint(e.toString());
    }
    return false;
  }

  Future<bool> updateGeneralSettingMobile(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}updateGeneralSettingMobile/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        return  true ;
      } else {
        debugPrint('Failed to load data');
        return false;
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      return false;
    }
  }

  Future<List<TaxGroupModel>> taxGroupAll() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<TaxGroupModel> _items = [];
    try {
      final response = await dio.get(
        '${pref.getString('api')}${apiV}taxGroup/All/$dataBase',
      );
      final data = response.data;
      if (data != null) {
        _items = TaxGroupModel.fromMapList(data);
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<bool> taxGroupAdd(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}taxGroup/add/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 201) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> taxGroupEdit(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}taxGroup/edit/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 201) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> taxGroupDelete(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
          '${pref.getString('api')}${apiV}taxGroup/delete/$dataBase',
          queryParameters: data,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        // var data = response.data;
        ret = true;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<List<ReportDesign>> getReportDesignByName(String form) async {
    List<ReportDesign> _reportDesign = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}reportDesignerByName/$dataBase',
          queryParameters: {'name': form});
      if (response.statusCode == 200) {
        
        List<dynamic> _data = response.data;
        for (var data in _data) {
            _reportDesign.add(ReportDesign.fromMap(data));
           print(data);
        }
       
      } else {
        // throw Exception('Failed to load data');
      }
    } on DioError {
      // print(e.message);
    }
    return _reportDesign;
  }

  Future<List<VoucherType>> voucherFormList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    List<VoucherType> result = [];
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
        '${pref.getString('api')}${apiV}voucherForm/All/$dataBase',
      );

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var data in jsonResponse) {
          result.add(VoucherType.fromMap(data));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return result;
  }

  Future<VoucherType> getVoucherForm() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    VoucherType result = VoucherType.emptyData();
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
        '${pref.getString('api')}${apiV}voucherForm/find/$dataBase',
      );

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var data in jsonResponse) {
          result = (VoucherType.fromMap(data));
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return result;
  }

  Future<bool> voucherFormAdd(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}voucherForm/add/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 201) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> voucherFormEdit(data) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}voucherForm/edit/$dataBase',
          data: json.encode(data),
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 201) {
        var jsonResponse = response.data;
        ret = jsonResponse['returnValue'] > 0 ? true : false;
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> voucherFormDelete(int id) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.delete(
          '${pref.getString('api')}${apiV}voucherForm/delete/$dataBase',
          queryParameters: {'id': id},
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 201) {
        // var jsonResponse = response.data;
        // ret = jsonResponse['returnValue'] > 0 ? true : false;
        if (response.data.toString() == "1") {
          ret = true;
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<List<VoucherType>> getVoucherTypeList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<VoucherType> _items = [];
    try {
      final response = await dio
          .get('${pref.getString('api')}${apiV}voucherForm/All/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var ledger in jsonResponse) {
          _items.add(VoucherType.fromMap(ledger));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<bool> checkDayStatus(String date) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sale/CheckDayStatus/$dataBase',
          queryParameters: {'date': date},
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        if (response.data['status']) {
          ret = true;
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<bool> checkManualInvoiceNoStatus(String id) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sale/CheckManualInvoiceNo/$dataBase',
          queryParameters: {'id': id},
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        if (response.data['status']) {
          ret = true;
        }
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<String> getSalesInvoiceNo(int saleFormId , String statement) async {
    String ret = '0';
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sale/getEntryNo/$dataBase',
          queryParameters: {
            'type': saleFormId,
            'fyId': currentFinancialYear!.id,
            'statement': statement
          },
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        ret = response.data.toString();
      } else {
        debugPrint('Unexpected error occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<List<DataJson>> getUnregisteredSalesLedgerDataListLike(
      String like) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<DataJson> _items = [];
    try {
      Response response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getUnregisteredSalesLedgerListLike/$dataBase',
          queryParameters: {'name': like});

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null) {
          tempCustomerData = data;
          for (var map in data) {
            _items.add(DataJson(id: map['Ledcode'], name: map['LedName']));
          }
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<String>> getVehicleNameList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<String> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}sale/getVehicleNoList/$dataBase');
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        for (var map in jsonResponse) {
          _items.add((map['evehicleno'] ?? ''));
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<Map<String, dynamic>>> getPredictNextSalesOrder(int id, int locationId) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = 'cSharp';
  dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");

  try {
    final response = await dio.get(
      '${pref.getString('api')}${apiV}sale/getPredictNextSalesOrder/$dataBase',
      queryParameters: {
        'id': id,
        'location': locationId,
      }
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data); 
    } else {
      debugPrint('Failed to load data');
      return [];
    }
  } catch (e) {
    final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
    debugPrint(errorMessage);
    return [];
  }
}


  Future<List<dynamic>> getOtherDataDiscountByName(String percentage) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<dynamic> _items = [];
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}OtherRegistration/DiscountByName/$dataBase',
          queryParameters: {'name': percentage});
      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        _items = jsonResponse as List;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }

  Future<List<String>> getUnregisteredNameList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    List<String> _items = [];
    try {
      Response response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getUnregisteredSalesLedgerList/$dataBase');

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null) {
          tempCustomerData = data;
          for (var map in data) {
            _items.add(map['LedName']);
          }
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
   Future<List<DataJson>> getProject() async {
    List<DataJson> ret = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api' ?? '127.0.0.1:80/api/')}${apiV}project/All/$dataBase');
      if (response.statusCode == 200) {
        if (response.data != null && response.data.isNotEmpty) {
          ret = DataJson.fromJsonList(response.data);
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
    final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }
  Future<List<dynamic>> fetchProjectReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api' ?? '127.0.0.1:80/api/')}${apiV}project_report/$dataBase',
          queryParameters: data,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
     final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }

  Future<CustomerModel> getNonCustomerDetail(String name) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    CustomerModel _item = CustomerModel();
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getNonCustomerDetail/$dataBase',
          queryParameters: {'name': name});
      if (response.statusCode == 200) {
        List<dynamic> _data = response.data;
        _item = CustomerModel.fromJson(_data[0]);
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _item;
  }

  Future<String> translateText(String sourceText) async {
    String translation = "";
    String from = 'en'; //'auto' for default
    String to = secondLanguage;
    try {
      final parameters = {
        'client': 'gtx',
        'sl': from,
        'tl': to,
        'dt': 't',
        'q': sourceText
      };
      String url = "https://translate.googleapis.com/translate_a/single";
      final response = await dio.get(url, queryParameters: parameters);
      if (response.statusCode == 200) {
        List<dynamic> jsonData = response.data;
        if (jsonData == null) {
          debugPrint('Error: Can\'t parse json data');
        }

        final sb = StringBuffer();
        for (var c = 0; c < jsonData[0].length; c++) {
          sb.write(jsonData[0][c][0]);
        }
        if (from == 'auto' && from != to) {
          from = jsonData[2] ?? from;
          if (from == to) {
            from = 'auto';
          }
        }
        translation = sb.toString();
      }
    } catch (ex) {
      ex.toString();
    }
    if (translation.length > 1) {
      translation = translation.substring(1);
    }
    return translation;
  }

  Future<dynamic> getBalance(
      int id, String statement, String type, String date, entryNo) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = '0';
    try {
      Response response = await dio.get(
          '${pref.getString('api')}${apiV}Ledger/getBalance/$dataBase',
          queryParameters: {
            'Id': id,
            'statement': statement,
            'type': type,
            'date': date,
            'entryNo': entryNo,
            'fyId': currentFinancialYear!.id
          });

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null) {
          _items = data;
        }
      } else {
        debugPrint('Failed to load data');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;
  }
  Future<List<dynamic>> getSalesManReport(data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}accounts_report/salesManReport/$dataBase',
          data: data,
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data;
      } else {
        debugPrint('Failed to load data');
        return [];
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
      return [];
    }
  }
  Future<bool> validateGstNo(String taxNumber) async {
    var _ip = await getPublicIp();
    var result = false;
    var authResponse = await authenticateGSTPortal(
        gstCommonUserName,
        gstCommonPassword,
        _ip,
        gstCommonClientId,
        gstCommonClientSecret,
        gstCommonGstNo);
    if (authResponse != null) {
      AuthClass authData = authResponse;
      if (authData.status_cd.toString() != "Sucess") {
        result = false;
      } else {
        await getGstResult(
                'SHERSOFT',
                taxNumber,
                gstCommonUserName,
                _ip,
                gstCommonClientId,
                gstCommonClientSecret,
                authData.data.AuthToken,
                gstCommonGstNo)
            .then((resultResponse) {
          if (resultResponse.status_cd == '1') {
            result = true;
          } else {
            result = false;
          }
        });
      }
    } else {
      result = false;
    }
    return result;
  }
    Future<bool> checkSerialNo(String serialNo, String type) async {
    bool ret = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
        '${pref.getString('api' ?? '127.0.0.1:80/api/')}${apiV}purchase/checkSerialNo/$dataBase',
        queryParameters: {'serialno': serialNo, 'type': type},
      );
      if (response.statusCode == 200) {
        ret = response.data['returnValue'] > 0 ? true : false;
      } else {
        ret = false;
        debugPrint('Unexpected error occurred!');
      }
    } catch (ex) {
      ex.toString();
      ret = false;
    }
    return ret;
  }
  Future<List<String>> getSelectedItemSerialNoList(
      uniqueCode, itemId, statementType) async {
    List<String> ret = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api' ?? '127.0.0.1:80/api/')}${apiV}sale/serialNoList/$dataBase',
          queryParameters: {
            'uniqueCode': uniqueCode,
            'itemId': itemId,
            'statementType': statementType
          });
      if (response.statusCode == 200) {
        if (response.data != null && response.data.isNotEmpty) {
          ret = List<String>.from(response.data
              .map((item) => item['SerialNO'].toString())
              .toList());
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
     final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<List<dynamic>> findPoint(id, entryNo, type) async {
    List<dynamic> ret = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api' ?? '127.0.0.1:80/api/')}${apiV}collectionPoint/find/$dataBase',
          queryParameters: {
            'entryNo': entryNo,
            'id': id,
            'fyId': currentFinancialYear!.id,
            'type': type
          });

      if (response.statusCode == 200) {
        if (response.data != null && response.data.isNotEmpty) {
          ret = List<dynamic>.from(response.data.map((item) {
            return {'point': item['Point'], 'total': item['Total']};
          }).toList());
        } else {
          ret = [];
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

   Future<List<dynamic>> getPointByEntryAndLedger(id, entryNo) async {
    List<dynamic> ret = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api' ?? '127.0.0.1:80/api/')}${apiV}collectionPoint/point/$dataBase',
          queryParameters: {
            'entryNo': entryNo,
            'id': id,
            'fyId': currentFinancialYear!.id
          });

      if (response.statusCode == 200) {
        if (response.data != null && response.data.isNotEmpty) {
          ret = List<String>.from(response.data
              .map((item) => item['SerialNO'].toString())
              .toList());
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }

  Future<List<dynamic>> getPointByLedger(id) async {
    List<dynamic> ret = [];
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}collectionPoint/point/$dataBase',
          queryParameters: {
            'id': id,
          });

      if (response.statusCode == 200) {
        if (response.data != null && response.data.isNotEmpty) {
          ret = List<String>.from(response.data
              .map((item) => item['SerialNO'].toString())
              .toList());
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return ret;
  }



  Future<String> getWarrantyEntryNo(String statement)async{
    String ret = '0';
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
      try {
          final response = await dio.get(
          '${pref.getString('api')}${apiV}WarrantyEntry/getEntryNo/$dataBase',
          queryParameters: {
            'statementType':statement
          });
           if (response.statusCode == 200) {
        ret = response.data.toString();
      } else {
        debugPrint('Unexpected error occurred!');
      }
      } catch (e) {
        final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
      }
      return ret;
  }

  Future<dynamic>fetchWarranty(entryNo)async{
   
    SharedPreferences pref = await SharedPreferences.getInstance();
    String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
    dynamic _items = [];    
    try {
      final response =await dio.get(
        '${pref.getString('api' ?? '127.0.0.1:80/api/')}${apiV}WarrantyEntry/find/$dataBase',
        queryParameters: {
          'entryNo':entryNo
        }
      );
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        _items = jsonResponse;
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    }  catch (e) {
     final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
      debugPrint(errorMessage.toString());
    }
    return _items;   
  }
  
  Future<dynamic> addWarranty(var body)async{
    dynamic ret = 0;
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
        try {
      final response = await dio.post(
          '${pref.getString('api')}${apiV}WarrantyEntry/add/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        if (response.data['returnValue'] > 0) {
          ret = response.data['returnValue'].toString();
        } else {
          ret = response.data['message'];
        }
      } else {
        ret = '0';
        debugPrint('Unexpected error occurred!');
        ret = 'Unexpected error occurred!';
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      ret = errorMessage.toString();
    }
    return ret;
  }

  Future<dynamic> editWarranty(var body)async{
    dynamic ret = 0;
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = 'cSharp';
    dataBase = isEstimateDataBase
        ? (pref.getString('DBName') ?? "cSharp")
        : (pref.getString('DBNameT') ?? "cSharp");
        try {
      final response = await dio.put(
          '${pref.getString('api')}${apiV}WarrantyEntry/edit/$dataBase',
          data: json.encode(body),
          options: Options(headers: {'Content-Type': 'application/json'}));

      if (response.statusCode == 201) {
        if (response.data['returnValue'] > 0) {
          ret = response.data['returnValue'].toString();
        } else {
          ret = response.data['message'];
        }
      } else {
        ret = '0';
        debugPrint('Unexpected error occurred!');
        ret = 'Unexpected error occurred!';
      }
    } catch (e) {
      final errorMessage =
          DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
      ret = errorMessage.toString();
    }
    return ret;
  }

 Future<List<Map<String, dynamic>>> getWarrantyReport(data) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");

  List<Map<String, dynamic>> _items = [];

  try {
    final response = await dio.get(
      '${pref.getString('api')}$apiV/WarrantyReport/$dataBase',
      queryParameters: data,
    );

    if (response.statusCode == 200) {
      var jsonResponse = response.data[0];

      // Parse the response properly
      if (jsonResponse is List) {
        _items = jsonResponse.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Unexpected data format: ${jsonResponse.runtimeType}');
      }
    } else {
      debugPrint('Unexpected error Occurred!');
    }
  } catch (e) {
    final errorMessage =
        DioExceptions.fromDioError(e as DioError).toString();
    debugPrint(errorMessage);
  }

  return _items;
}
Future<dynamic> sendWhatsappMsg(data) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");
  dynamic ret = [];

  try {
    final response = await dio.post(
      '${pref.getString('api')}${apiV}send-whatsappTxt',
      data: json.encode(data),
      options: Options(headers: {'Content-Type': 'application/json'})
    );

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugPrint('WhatsApp Response: $jsonResponse'); 
      ret = jsonResponse;
    } else {
      ret = {
        'success': false,
        'to': response.data['to']
      };
      debugPrint('HTTP Error: ${response.statusCode}');
    }
  } catch (e) {
    final errorMessage = e is DioError 
        ? DioExceptions.fromDioError(e).toString()
        : e.toString();
    debugPrint('Error sending WhatsApp message: $errorMessage');
    ret = false;
  }

  return ret;
}

 Future<dynamic> sendWhatsappMsgAndPdf(data) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");

  dynamic ret = [];

  try {
    final response = await dio.post(
      '${pref.getString('api')}${apiV}send-whatsappFile',
      data: json.encode(data),
      options: Options(headers: {'Content-Type': 'application/json'})
    );

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      debugPrint('WhatsApp Response: $jsonResponse'); 
      ret = jsonResponse;
    } else {
      ret = {
        'success': false,
        'to': response.data['to']
      };
      debugPrint('HTTP Error: ${response.statusCode}');
    }
  } catch (e) {
    final errorMessage =
        DioExceptions.fromDioError(e as DioError).toString();
    debugPrint(errorMessage);
  }

  return ret;
}

Future<String> uploadPdfAndGetLink(String pdfPath) async {
  try {
    File pdfFile = File(pdfPath);
    String fileName = pdfFile.path.split('/').last; // Extract filename

    FormData formData = FormData.fromMap({
      "id": "sheraccErp", // Folder name
      "file": await MultipartFile.fromFile(pdfPath, filename: fileName),
    });

    Dio dio = Dio();

    Response response = await dio.post(
      "http://imageupload.shersoft.tech/upload",
      data: formData,
      options: Options(
        headers: {
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    if (response.statusCode == 200) {
      // Construct the URL after successful upload
      String fileUrl = "http://imageupload.shersoft.tech/image/sheraccErp/$fileName";
      return fileUrl;
    } else {
      debugPrint("File upload failed: ${response.data}");
      return "";
    }
  } catch (e) {
    debugPrint("Error during file upload: $e");
    return "";
  }
}

// Future<String> uploadPdfAndGetLink(String pdfPathOrData) async {
//   try {
//     // final dio = Dio();
//     FormData formData;
//     String fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';

//     if (kIsWeb) {
//       // Handle web case - process base64 data URL
//       if (!pdfPathOrData.startsWith('data:application/pdf;base64,')) {
//         debugPrint('Invalid PDF data format on web');
//         return '';
//       }

//       final base64String = pdfPathOrData.split(',').last;
//       final bytes = base64Decode(base64String);

//       formData = FormData.fromMap({
//         "id": "sheraccErp",
//         "file": MultipartFile.fromBytes(
//           bytes,
//           filename: fileName,
//           contentType: MediaType('application', 'pdf'),
//         ),
//       });
//     } else {
//       // Handle mobile case - process file path
//       final file = File(pdfPathOrData);
//       if (!await file.exists()) {
//         debugPrint('PDF file not found at path: $pdfPathOrData');
//         return '';
//       }

//       formData = FormData.fromMap({
//         "id": "sheraccErp",
//         "file": await MultipartFile.fromFile(
//           pdfPathOrData,
//           filename: fileName,
//         ),
//       });
//     }

//     final response = await dio.post(
//       "http://imageupload.shersoft.tech/upload",
//       data: formData,
//       options: Options(
//         headers: {"Content-Type": "multipart/form-data"},
//       ),
//     );

//     if (response.statusCode == 200) {
//       return "http://imageupload.shersoft.tech/image/sheraccErp/$fileName";
//     } else {
//       debugPrint("Upload failed: ${response.statusCode} - ${response.data}");
//       return '';
//     }
//   } catch (e) {
//     debugPrint("Upload error: $e");
//     return '';
//   }
// }

Future<bool> saveCompanyLocation({
  required double latitude,
  required double longitude,
}) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  
  String dataBase = 'cSharp';
  dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");

  try {
    final response = await dio.post(
      '${pref.getString('api')}${apiV}SaveCompanyLocation/$dataBase',
      // 'http://192.168.29.207:8090/api/v26/SaveCompanyLocation/$dataBase',
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      return response.data['success'] ?? false;
    } else {
      debugPrint('Failed to save location: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
    debugPrint('Location save error: $errorMessage');
    return false;
  }
}
Future<bool> saveCompanyRadius({
  required String radius,
}) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  
  String dataBase = 'cSharp';
  dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");  

  try {
    final response = await dio.post(
      '${pref.getString('api')}${apiV}SaveCompanyDistance/$dataBase',
      // 'http://192.168.29.207:8090/api/v26/SaveCompanyDistance/$dataBase',
      queryParameters: {
        'radius': radius,
      },
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (response.statusCode == 200) {
      return response.data['success'] ?? false;
    } else {
      debugPrint('Failed to save location: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
    debugPrint('Location save error: $errorMessage');
    return false;
  }
}

Future<bool> savePunchingEntry(data) async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  
  String dataBase = 'cSharp';
  dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");

  final DateFormat customFormatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

   final encodedData = {
    'employeeId': data['employee'],
    'date': (data['date'] as DateTime).toIso8601String(),
    'time':  customFormatter.format(data['Time'] as DateTime),
    'punchType': data['ptype'],
    'narration': data['narration'],
    'otamount': data['otamount'],
    'Allowances': data['Allowances'],
    'EmpSection' : data['EmpSection'],
    'location': data['location'],
    'type' : data['type'],
    'Attendance' : data['Attendance'],
    'Wage' : data['Wage'],
    'oth': data['oth'],
    'fyId' : data['fyId'],
  };

  try {
    final response = await dio.post(
      '${pref.getString('api')}${apiV}addPunchingEntry/$dataBase',
      // 'http://192.168.29.207:8090/api/v26/addPunchingEntry/$dataBase',
      data: encodedData,
    );

    if (response.statusCode == 200) {
      return response.data['success'] ?? false;
    } else {
      debugPrint('Failed to save punching entry: ${response.statusCode}');
      return false;
    }
  } on DioError catch (e) {
    final errorMessage = DioExceptions.fromDioError(e).toString();
    debugPrint('Punching entry save error: $errorMessage');
    return false;
  } catch (e) {
    debugPrint('Unexpected error: $e');
    return false;
  }
}
 
 Future<List<PunchTypeModel>> getLastPuchType(
  int employeeId,
  DateTime date) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = 'cSharp';
  dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");
  // String? lastPunchType;
  List<PunchTypeModel> result = [];
  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
  try {
    final response = await dio.get(
      '${pref.getString('api')}${apiV}getLastPunchType/$dataBase',
      // 'http://192.168.29.207:8090/api/v26/getLastPunchType/$dataBase',
      queryParameters: {
        'employeeId': employeeId,
        'date': formattedDate
        },
    );

    if (response.statusCode == 200) {
      var jsonResponse= response.data;
      for(var data in jsonResponse) {
        result.add(PunchTypeModel.fromJson(data));
      }
    } else {
      debugPrint('Failed to fetch last punch type: ${response.statusCode}');
    }
  } catch (e) {
    final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
    debugPrint('Error fetching last punch type: $errorMessage');
  }
  return result;
 }

 Future<List<FirstInModel>>  getFirstPuchIn(
  int employeeId,
  DateTime date) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = 'cSharp';
  dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");
  // String? lastPunchType;
  List<FirstInModel> result = [];
  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
  try {
    final response = await dio.get(
      '${pref.getString('api')}${apiV}getFirstPunchIn/$dataBase',
      // 'http://192.168.29.207:8090/api/v26/getFirstPunchIn/$dataBase',
      queryParameters: {
        'employeeId': employeeId,
        'date': formattedDate
        },
    );

    if (response.statusCode == 200) {
      // result = response.data;
      var jsonResponse= response.data;
      for(var data in jsonResponse) {
        result.add(FirstInModel.fromJson(data));
      }
    } else {
      debugPrint('Failed to fetch last punch type: ${response.statusCode}');
    }
  } catch (e) {
    final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
    debugPrint('Error fetching last punch type: $errorMessage');
  }
  return result;
 }

 Future<List<PunchInModel>>  getAttendanceReportBySalesman(
  int employeeId,
  DateTime date) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = 'cSharp';
  dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");
  // String? lastPunchType;
  List<PunchInModel> result = [];
  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
  try {
    final response = await dio.get(
      '${pref.getString('api')}${apiV}getAttendanceReportBySalesman/$dataBase',
      // 'http://192.168.29.207:8090/api/v26/getAttendanceReportBySalesman/$dataBase',
      queryParameters: {
        'employeeId': employeeId,
        'date': formattedDate
        },
    );

    if (response.statusCode == 200) {
      // result = response.data;
      var jsonResponse= response.data;
      for(var data in jsonResponse) {
        result.add(PunchInModel.fromJson(data));
      }
    } else {
      debugPrint('Failed to fetch last punch type: ${response.statusCode}');
    }
  } catch (e) {
    final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
    debugPrint('Error fetching last punch type: $errorMessage');
  }
  return result;
 }

 Future<List<LeavesModel>>  getLeaveReportBySalesman(
  int employeeId,
  DateTime date) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String dataBase = 'cSharp';
  dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");
  // String? lastPunchType;
  List<LeavesModel> result = [];
  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
  try {
    final response = await dio.get(
      '${pref.getString('api')}${apiV}getLeaveReportBySalesman/$dataBase',
      // 'http://192.168.29.207:8090/api/v26/getLeaveReportBySalesman/$dataBase',
      queryParameters: {
        'employeeId': employeeId,
        'date': formattedDate
        },
    );

    if (response.statusCode == 200) {
      // result = response.data;
      var jsonResponse= response.data;
      for(var data in jsonResponse) {
        result.add(LeavesModel.fromJson(data));
      }
    } else {
      debugPrint('Failed to fetch last punch type: ${response.statusCode}');
    }
  } catch (e) {
    final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
    debugPrint('Error fetching last punch type: $errorMessage');
  }
  return result;
 }

 Future<bool> punchOutEntry(data) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  
  String dataBase = 'cSharp';
  dataBase = isEstimateDataBase
      ? (pref.getString('DBName') ?? "cSharp")
      : (pref.getString('DBNameT') ?? "cSharp");
   final encodedData = {
    'employeeId': data['employee'],
    'date': (data['date'] as DateTime).toIso8601String(),
    'time': (data['Time'] as DateTime).toIso8601String(),
    'punchType': data['ptype'],
    'latitude': data['latitude'],
    'longitude': data['longitude'],
    'workDur': data['workDur'],
  };

  try {
    final response = await dio.post(
      // '${pref.getString('api')}${apiV}PunchOutEntry/$dataBase',
      'http://192.168.29.207:8090/api/v26/PunchOutEntry/$dataBase',
      data: encodedData,
    );

    if (response.statusCode == 200) {
      return response.data['success'] ?? false;
    } else {
      debugPrint('Failed to save punching entry: ${response.statusCode}');
      return false;
    }
  } on DioError catch (e) { 
    final errorMessage = DioExceptions.fromDioError(e).toString();
    debugPrint('Punching entry save error: $errorMessage');
    return false;
  } catch (e) {
    debugPrint('Unexpected error: $e');
    return false;
    
  }
}


}


class DataJson {
  int? id;
  String? name;

  DataJson({this.id, this.name});

  factory DataJson.fromJson(Map<String, dynamic> json) {
    return DataJson(id: json['id'], name: json['name']);
  }

  factory DataJson.fromJsonX(Map<String, dynamic> json) {
    return DataJson(id: json['auto'], name: json['Name']);
  }

  static List<DataJson> fromJsonList(List list) {
    return list.map((item) => DataJson.fromJson(item)).toList();
  }

  static List<DataJson> fromJsonListX(List list) {
    return list.map((item) => DataJson.fromJsonX(item)).toList();
  }

  String userAsString() {
    return '#$id $name';
  }

  @override
  String toString() => name!;
}

class DioExceptions implements Exception {
  DioExceptions.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioErrorType.connectTimeout:
        message = "Connection timeout with API server";
        break;
      case DioErrorType.other:
        message = "Connection to API server failed due to internet connection";
        break;
      case DioErrorType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      case DioErrorType.response:
        message = _handleError(
            dioError.response!.statusCode!, dioError.response!.data);
        break;
      case DioErrorType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  String? message;

  String _handleError(int statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 404:
        return error["message"];
      case 500:
        return 'Internal server error';
      default:
        return 'Oops something went wrong';
    }
  }

  @override
  String toString() => message!;
}
