import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sheraccerp/pos/models/pos_cart_model.dart';
import 'package:sheraccerp/pos/models/hold_items_model.dart';

part 'hold_item_provider.g.dart';

@Riverpod(keepAlive: true)
class HoldItem extends _$HoldItem {
  @override
  List<HoldItemsModel> build() {
    return <HoldItemsModel>[];
  }

  void addHoldList(List<PosCartModel> items) {
    final copiedItems = items.map((item) => item.copyWith()).toList();
    final holdList = HoldItemsModel(id: state.length + 1, items: copiedItems);
    state = [...state, holdList];
    debugPrint('Hold list updated: ${state.toString()}');
  }
  
  void removeHoldList(int holdListId) {
  state = state.where((list) => list.id != holdListId).toList();
}


  void clearAllHoldLists() {
    state = [];
  }

  List<PosCartModel> restoreHoldList(int holdListId) {
    final holdList = state.firstWhere((list) => list.id == holdListId);
    return holdList.items;
  }
}
