import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sheraccerp/models/stock_item.dart';
import 'package:sheraccerp/models/stock_product.dart';
import 'package:sheraccerp/service/api_dio.dart';

part 'products_provider.g.dart';

@riverpod
Future<List<StockItem>> productsProviderss(ProductsProviderssRef ref, String date) async {
  final dioService = ref.watch(dioServiceProvider);
  return dioService.fetchStockProduct(date);
}

@riverpod
Future<List<StockProduct>> stockVariantsProvider(StockVariantsProviderRef ref, int productId) async {
  final dioService = ref.watch(dioServiceProvider);
  return dioService.fetchStockVariant(productId,false,0);
}

@riverpod
DioService dioService(DioServiceRef ref) {
  return DioService();
}
