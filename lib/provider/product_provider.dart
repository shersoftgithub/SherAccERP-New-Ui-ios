import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sheraccerp/models/stock_item.dart';
import 'package:sheraccerp/models/stock_product.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/util/dateUtil.dart';

part 'product_provider.g.dart';

@riverpod
class Products extends _$Products {
  @override
  Future<List<StockItem>> build() async {
    return await fetchStockProducts('', ''); 
  }

  Future<List<StockItem>> fetchStockProducts(String itemLike, String date) async {
    state = const AsyncValue.loading();
    try {
      var items = await DioService().fetchStockProductLike(DateUtil.dateDMY2YMDA(date), itemLike);
      state = AsyncValue.data(items);
      return items;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return [];
    }
  }

  Future<List<StockItem>> fetchNoStockProducts(String itemLike, String date) async {
    state = const AsyncValue.loading();
    try {
      var variants = await DioService().fetchNoStockProductLike(DateUtil.dateDMY2YMDA(date), itemLike);
      state = AsyncValue.data(variants);
      return variants;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return [];
    }
  }
}







// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sheraccerp/models/stock_item.dart';
// import 'package:sheraccerp/service/api_dio.dart';
// import 'package:sheraccerp/util/dateUtil.dart';

// final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<StockItem>>>((ref) {
//   return ProductsNotifier();
// });

// class ProductsNotifier extends StateNotifier<AsyncValue<List<StockItem>>> {
//   ProductsNotifier() : super(const AsyncValue.loading()) {
   
//     fetchStockProducts("", "");
//   }

//   Future<void> fetchStockProducts(String itemLike, String date) async {
//     try {
//       state = const AsyncValue.loading();
//       var items = await DioService().fetchStockProductLike(
//         DateUtil.dateDMY2YMDA(date), itemLike
//       );
//       state = AsyncValue.data(items);
//     } catch (error, stackTrace) {
//       print('API Call Failed: $error');
//       state = AsyncValue.error(error, stackTrace);
//     }
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:sheraccerp/models/stock_item.dart';
// import 'package:sheraccerp/service/api_dio.dart';

// import '../models/product.dart';

// class ProductProvider with ChangeNotifier {
//   List<Product> productList = [];
//   DioService api = DioService();

//   ProductProvider() {
//     loadProduct();
//   }

//   loadProduct() async {
//     var productList1 = await api.getProductData();
//     notifyListeners();
//   }

//
// }

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sheraccerp/models/stock_item.dart';
// import 'package:sheraccerp/service/api_dio.dart';

// final productProvider = FutureProvider.family<List<StockItem>, String>((ref, itemLike) async {
//   return DioService().fetchStockProduct(itemLike);
// });




