import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheraccerp/models/stock_item.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';

class StockItemProvider extends StateNotifier<List<StockItem>> {
  StockItemProvider() : super([]);
  
  bool isLoading = false;
  int page = 1;
  int limit = 20; // Items per page
  bool hasMoreData = true;
  final Dio  dio = Dio();

  Future<void> fetchStockProductLike(String date, String like) async {
    if (isLoading || !hasMoreData) return;
    isLoading = true;
    
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

    try {
      final response = await dio.get(
          '${pref.getString('api')}${apiV}stock/getStockSaleListLike/$dataBase',
          queryParameters: {
            'id': id,
            'location': location,
            'date': date,
            'like': like,
            'page': page,      // Pagination
            'limit': limit     // Items per page
          });
      
      if (response.statusCode == 200) {
        var jsonResponse = response.data;

        List<StockItem> fetchedItems = jsonResponse.map((product) => StockItem.fromJson(product)).toList();

        if (fetchedItems.isEmpty) {
          hasMoreData = false; // No more data to load
        } else {
          state = [...state, ...fetchedItems]; // Append new items
          page++; // Move to the next page
        }
      } else {
        debugPrint('Unexpected error Occurred!');
      }
    } catch (e) {
      final errorMessage = DioExceptions.fromDioError('$e' as DioError).toString();
      debugPrint(errorMessage.toString());
    } finally {
      isLoading = false;
    }
  }
}
