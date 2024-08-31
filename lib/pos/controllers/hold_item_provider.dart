import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sheraccerp/pos/models/pos_cart_model.dart';
import 'package:sheraccerp/pos/models/hold_items_model.dart';

part 'hold_item_provider.g.dart';

@riverpod
class HoldItem extends _$HoldItem {
  @override
  List<HoldItemsModel> build() {
    return <HoldItemsModel>[];
  }

  void addHoldList(List<PosCartModel> items) {
    final holdList = HoldItemsModel(id: state.length + 1, items: items);
    state = [...state, holdList];
  }

  void clearAllHoldLists() {
    state = [];
  }

  List<PosCartModel> restoreHoldList(int holdListId) {
    final holdList = state.firstWhere((list) => list.id == holdListId);
    return holdList.items;
  }
}
