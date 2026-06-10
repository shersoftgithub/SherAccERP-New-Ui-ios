import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sheraccerp/models/stock_item.dart';
import 'package:sheraccerp/models/stock_product.dart';
import 'package:sheraccerp/service/api_dio.dart';

part 'stockvariant_provider.g.dart';

@riverpod
class StockVariants extends _$StockVariants {
  @override
  Future<List<StockProduct>> build(int selectedItemId) async {
    // Initial loading state
    state = const AsyncValue.loading();

    try {
      // Fetch data in parallel
      var stockItemsFuture = DioService().fetchStockVariant(selectedItemId,false,0);
      var variantsFuture = DioService().fetchStockVariant(selectedItemId,false,0);

      // Wait for all requests to complete
      final results = await Future.wait([stockItemsFuture, variantsFuture]);

      // Combine results
      final combinedResults = [...results[0] as List<StockProduct>, ...results[1] as List<StockProduct>];

      // Update state with data
      state = AsyncValue.data(combinedResults);
      return combinedResults;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return [];
    }
  }
}
