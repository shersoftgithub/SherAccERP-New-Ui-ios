import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sheraccerp/models/api_error.dart';
import 'package:sheraccerp/models/company.dart';
import 'package:sheraccerp/models/company_user.dart';
import 'package:sheraccerp/models/form_model.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';

Future<ApiResponse> authenticate(String customerId) async {
  ApiResponse apiResponse =
      ApiResponse(data: {}, apiError: ApiError(error: ''));
  var dio = Dio(BaseOptions(maxRedirects: 5));

  SharedPreferences pref = await SharedPreferences.getInstance();
  try {
    final response = await dio.get(
        '${pref.getString('api')!}${apiV}company/Authenticate/$customerId');

    switch (response.statusCode) {
      case 200:
        List<dynamic> output = response.data;
        if (output.isNotEmpty) {
          Map<String, dynamic> responseBody = output[0];
          apiResponse.data = Company.fromJson(responseBody);
        } else {
          apiResponse.apiError = ApiError(error: "Invalid Customer ID");
        }
        break;
      case 401:
        apiResponse.apiError = ApiError.fromJson(json.decode(response.data));
        break;
      default:
        apiResponse.apiError = ApiError.fromJson(json.decode(response.data));
        break;
    }
  } on Response catch (r, e) {
    debugPrint('io error..${r.statusMessage}');
    final errorMessage =
        DioExceptions.fromDioError('$e' as DioError).toString();
    apiResponse.apiError = ApiError(error: "$errorMessage. Please retry");
  }
  return apiResponse;
}

Future<ApiResponse> getFirmList(String customerCode) async {
  ApiResponse apiResponse =
      ApiResponse(data: {}, apiError: ApiError(error: ''));
  var dio = Dio(BaseOptions(maxRedirects: 5));

  SharedPreferences pref = await SharedPreferences.getInstance();
  try {
    final response = await dio.get(
        '${pref.getString('api')!}${apiV}companyGetFirmList',
        queryParameters: {'customerCode': customerCode});

    switch (response.statusCode) {
      case 200:
        List<dynamic> output = response.data;
        if (output.isNotEmpty) {
          List<FirmModel> data = [];
          for (var json in output) {
            //Map<dynamic, dynamic> responseBody = output[0];
            data.add(FirmModel.fromJson(json));
          }
          apiResponse.data = data;
        } else {
          apiResponse.apiError = ApiError(error: "Invalid Customer Code");
        }
        break;
      case 401:
        apiResponse.apiError = ApiError.fromJson(json.decode(response.data));
        break;
      default:
        apiResponse.apiError = ApiError.fromJson(json.decode(response.data));
        break;
    }
  } on Response catch (r, e) {
    debugPrint('io error..${r.statusMessage}$e');
    apiResponse.apiError = ApiError(error: "Server error. Please retry");
  }
  return apiResponse;
}

Future<ApiResponse> authenticateCompany(
    String username, String password) async {
  ApiResponse apiResponse =
      ApiResponse(data: {}, apiError: ApiError(error: ''));
  var dio = Dio(BaseOptions(maxRedirects: 5));

  SharedPreferences pref = await SharedPreferences.getInstance();
  try {
    final response = await dio.get(
        '${pref.getString('api')}${apiV}companyLogin',
        queryParameters: {'username': username, 'password': password});

    switch (response.statusCode) {
      case 200:
        List<dynamic> output = response.data;
        if (output.isNotEmpty) {
          Map<String, dynamic> responseBody = output[0];
          apiResponse.data = Company.fromJson(responseBody);
          apiResponse.apiError = ApiError(error: '');
        } else {
          apiResponse.apiError =
              ApiError(error: "Invalid UserName or Password");
        }
        break;
      case 401:
        apiResponse.apiError = ApiError.fromJson(json.decode(response.data));
        break;
      default:
        apiResponse.apiError = ApiError.fromJson(json.decode(response.data));
        break;
    }
  } on Response catch (r) {
    debugPrint('io error..${r.statusMessage}');
    apiResponse.apiError = ApiError(error: "Server error. Please retry");
  }
  return apiResponse;
}

Future<ApiResponse> authenticateUser(
    String username, String password, String regId) async {
  ApiResponse apiResponse =
      ApiResponse(data: {}, apiError: ApiError(error: ''));
  String deviceId = '0'; //await _commonService.getDeviceId();
  SharedPreferences pref = await SharedPreferences.getInstance();
  var dio = Dio(BaseOptions(maxRedirects: 5));
  try {
    final response = await dio.get(
        '${pref.getString('api')!}${apiV}companyUserLogin',
        queryParameters: {
          'username': username,
          'password': password,
          'regId': regId,
          'deviceId': deviceId
        });

    switch (response.statusCode) {
      case 200:
        List<dynamic> output = response.data;
        if (output.isNotEmpty) {
          Map<String, dynamic> responseBody = output[0];
          apiResponse.data = CompanyUser.fromJson(responseBody);
        } else {
          apiResponse.apiError =
              ApiError(error: "Invalid UserName or Password");
        }
        break;
      case 401:
        apiResponse.apiError = ApiError.fromJson(json.decode(response.data));
        break;
      default:
        apiResponse.apiError =
            ApiError(error: json.decode(response.data)['error']);
        break;
    }
  } on Response catch (r) {
    debugPrint('io error..${r.statusMessage}');
    apiResponse.apiError = ApiError(error: "Server error. Please retry");
  }
  return apiResponse;
}

Future<ApiResponse> createUser(
    String username, String password, String regId) async {
  ApiResponse apiResponse =
      ApiResponse(data: {}, apiError: ApiError(error: ''));
  String deviceId = '0';
  var dio = Dio(BaseOptions(maxRedirects: 5));
  SharedPreferences pref = await SharedPreferences.getInstance();

  try {
    final response =
        await dio.post('${pref.getString('api')}${apiV}companyUser/add',
            data: json.encode({
              'registrationId': regId,
              'username': username,
              'password': password,
              'active': '0',
              'deviceId': deviceId,
              'userType': 'SalesMan'
            }),
            options: Options(headers: {'Content-Type': 'application/json'}));

    switch (response.statusCode) {
      case 200:
        apiResponse.data = {};
        break;
      case 201:
        var output = response.data;
        if (output['error'].toString() == 'Saved') {
          apiResponse.data = {};
        } else {
          var output = response.data;
          Map<String, dynamic> responseBody = output;
          apiResponse.apiError = ApiError(error: responseBody['error']);
          apiResponse.apiError = ApiError(error: '');
        }
        break;
      case 401:
        var output = response.data;
        Map<String, dynamic> responseBody = output;
        apiResponse.apiError = ApiError(error: responseBody['error']);
        break;
      default:
        var output = response.data;
        Map<String, dynamic> responseBody = output;
        apiResponse.apiError = ApiError(error: responseBody['error']);
        break;
    }
  } on Response catch (r) {
    debugPrint('io error..${r.statusMessage}');
    apiResponse.apiError = ApiError(error: "Server error. Please retry");
  }
  return apiResponse;
}

Future<ApiResponse> getCompanyDetails(String regId) async {
  ApiResponse apiResponse =
      ApiResponse(data: {}, apiError: ApiError(error: ''));
  var dio = Dio(BaseOptions(maxRedirects: 5));
  SharedPreferences pref = await SharedPreferences.getInstance();
  try {
    final response =
        await dio.get('${pref.getString('api')}${apiV}company/$regId');

    switch (response.statusCode) {
      case 200:
        List<dynamic> output = response.data;
        if (output.isNotEmpty) {
          Map<String, dynamic> responseBody = output[0];
          apiResponse.data = CompanyUser.fromJson(responseBody);
          apiResponse.apiError = ApiError(error: '');
        } else {
          apiResponse.apiError = ApiError(error: "Invalid UserName");
        }
        break;
      case 401:
        apiResponse.apiError =
            ApiError(error: json.decode(response.data)['error']);
        break;
      default:
        apiResponse.apiError =
            ApiError(error: json.decode(response.data)['error']);
        break;
    }
  } on Response catch (r) {
    debugPrint('io error..${r.statusMessage}');
    apiResponse.apiError = ApiError(error: "Server error. Please retry");
  }
  return apiResponse;
}

Future<ApiResponse> getUserDetails(String userId) async {
  ApiResponse apiResponse =
      ApiResponse(data: {}, apiError: ApiError(error: ''));
  var dio = Dio(BaseOptions(maxRedirects: 5));
  SharedPreferences pref = await SharedPreferences.getInstance();
  try {
    final response =
        await dio.get('${pref.getString('api')}${apiV}companyUser/$userId');

    switch (response.statusCode) {
      case 200:
        List<dynamic> output = response.data;
        if (output.isNotEmpty) {
          Map<String, dynamic> responseBody = output[0];
          apiResponse.data = CompanyUser.fromJson(responseBody);
          apiResponse.apiError = ApiError(error: '');
        } else {
          apiResponse.apiError = ApiError(error: "Invalid UserName");
        }
        break;
      case 401:
        apiResponse.apiError =
            ApiError(error: json.decode(response.data)['error']);
        break;
      default:
        apiResponse.apiError =
            ApiError(error: json.decode(response.data)['error']);
        break;
    }
  } on Response catch (r) {
    debugPrint('io error..${r.statusMessage}');
    apiResponse.apiError = ApiError(error: "Server error. Please retry");
  }
  return apiResponse;
}

Future<ApiResponse> getDashDetails(String userId) async {
  ApiResponse apiResponse =
      ApiResponse(data: {}, apiError: ApiError(error: ''));
  var dio = Dio(BaseOptions(maxRedirects: 5));
  SharedPreferences pref = await SharedPreferences.getInstance();
  try {
    final response = await dio
        .get('${pref.getString('api')}${apiV}CompanyUser/get?id=$userId');

    switch (response.statusCode) {
      case 200:
        List<dynamic> output = response.data;
        if (output.isNotEmpty) {
          Map<String, dynamic> responseBody = output[0];
          apiResponse.data = CompanyUser.fromJson(responseBody);
          apiResponse.apiError = ApiError(error: '');
        } else {
          apiResponse.apiError =
              ApiError(error: "Invalid UserName or Password");
        }
        break;
      case 401:
        apiResponse.apiError =
            ApiError(error: json.decode(response.data)['error']);
        break;
      default:
        apiResponse.apiError =
            ApiError(error: json.decode(response.data)['error']);
        break;
    }
  } catch (e) {
    final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
    apiResponse.apiError = ApiError(error: "$errorMessage. Please retry");
  }
  return apiResponse;
}

Future<List<CompanyUser>> getCompanyUserList(String regId) async {
  var dio = Dio(BaseOptions(maxRedirects: 5));
  SharedPreferences pref = await SharedPreferences.getInstance();
  List<CompanyUser> list = [];
  regId = regId.isNotEmpty ? regId : '0';

  try {
    final response =
        await dio.get('${pref.getString('api')}${apiV}companyUserList/$regId');

    if (response.statusCode == 200) {
      final data = response.data;
      if (data != null) {
        for (var json in data) {
          list.add(CompanyUser.fromJson(json));
        }
        return list;
      }
      return list;
    } else {
      return list;
      // throw Exception('Failed to load internet');
    }
  } catch (ex) {
    debugPrint(ex.toString());
    return list;
  }
}

Future<List<FormModel>> getCompanyUserControlList(String userId) async {
  var dio = Dio(BaseOptions(maxRedirects: 5));
  SharedPreferences pref = await SharedPreferences.getInstance();
  List<FormModel> list = [];

  try {
    final response = await dio
        .get('${pref.getString('api')}${apiV}companyUserControlList/$userId');

    if (response.statusCode == 200) {
      final data = response.data;
      if (data != null) {
        for (var json in data) {
          list.add(FormModel.fromJson(json));
        }
        return list;
      }
      return list;
    } else {
      return list;
      // throw Exception('Failed to load internet');
    }
  } catch (ex) {
    debugPrint(ex.toString());
    return list;
  }
}

Future<List<FormModel>> getCompanyUserControlForms() async {
  var dio = Dio(BaseOptions(maxRedirects: 5));
  SharedPreferences pref = await SharedPreferences.getInstance();
  List<FormModel> list = [];

  try {
    final response =
        await dio.get('${pref.getString('api')}${apiV}companyUserControlForms');

    if (response.statusCode == 200) {
      final data = response.data;
      if (data != null) {
        for (var json in data) {
          list.add(FormModel.fromJson(json));
        }
        return list;
      }
      return list;
    } else {
      return list;
      // throw Exception('Failed to load internet');
    }
  } catch (ex) {
    debugPrint(ex.toString());
    return list;
  }
}

Future<bool> addUserControl(data) async {
  var dio = Dio(BaseOptions(maxRedirects: 5));
  bool ret = false;
  SharedPreferences pref = await SharedPreferences.getInstance();
  try {
    final response = await dio.post(
        '${pref.getString('api')}${apiV}companyUser/addUserControl',
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
    }
  } catch (r, e) {
    debugPrint(e.toString());
    final errorMessage = DioExceptions.fromDioError(e as DioError).toString();
  }
  return ret;
}

Future<bool> changeCompanyUserPassword(var body) async {
  bool ret = false;
  var dio = Dio(BaseOptions(maxRedirects: 5));
  SharedPreferences pref = await SharedPreferences.getInstance();
  try {
    final response = await dio.put(
        '${pref.getString('api')}$apiV/companyUser/changePassword',
        data: json.encode(body),
        options: Options(headers: {'Content-Type': 'application/json'}));

    if (response.statusCode == 200) {
      ret = true;
    } else {
      ret = false;
    }
  } catch (ex) {
    debugPrint(ex.toString());
    ret = false;
  }
  return ret;
}

class ApiResponse {
  dynamic data;
  ApiError apiError;
  ApiResponse({
    required this.data,
    required this.apiError,
  });
  // dynamic _data = [];
  // dynamic _apiError = [];

  // Object get Data => _data;
  // set Data(Object data) => _data = data;

  // Object get ApiError => _apiError as Object;
  // set ApiError(Object error) => _apiError = error;

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'apiError': apiError,
    };
  }

  factory ApiResponse.fromMap(Map<String, dynamic> map) {
    return ApiResponse(
      data: map['data'],
      apiError: ApiError.fromMap(map['apiError']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiResponse.fromJson(String source) =>
      ApiResponse.fromMap(json.decode(source));
}
