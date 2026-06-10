import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sheraccerp/models/ledger_name_model.dart';
import 'package:sheraccerp/service/api_dio.dart';

part 'customer_provider.g.dart';

@riverpod
class Customers extends _$Customers {
  @override
  int? groupId;
  int? areaId;
  int? routeId;
  int? salesmanId;
  Future<List<LedgerModel>> build() async {
    return await fetchCustomerNames(groupId!, areaId!, routeId!, salesmanId!);
  }

  Future<List<LedgerModel>> fetchCustomerNames(int groupId, int areaId, int routeId, int salesmanId) async {
    state = const AsyncValue.loading();
    try {
      var value = await DioService().getCustomerNameListByParent(
        groupId,
        areaId,
        routeId,
        salesmanId,
      );
      state = AsyncValue.data(value);
      return value;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return [];
    }
  }
}
