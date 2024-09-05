

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sheraccerp/pos/models/pos_cart_model.dart';

part 'cart_item_provider.g.dart';

@riverpod
class CartItem extends _$CartItem{
  @override
  List<PosCartModel> build(){
    return <PosCartModel> [];
  }

  // void addItem(PosCartModel cartModel){
  //   state = [...state,cartModel];
  // }
 void addItem(PosCartModel cartModel) {
    final existingItemIndex = state.indexWhere((item) => item.id == cartModel.id);

    if (existingItemIndex != -1) {
      final updatedItem = state[existingItemIndex].copyWith(
        quantity: state[existingItemIndex].quantity! + 1,
      );

      state = [
        ...state.sublist(0, existingItemIndex),
        updatedItem,
        ...state.sublist(existingItemIndex + 1),
      ];
    } else {
      double taxPercentage = cartModel.tax ?? 0;
      double priceBeforeTax = cartModel.rate / (1 + (taxPercentage / 100));
      double taxValue = cartModel.rate - priceBeforeTax;

      state = [
        ...state,
        cartModel.copyWith(
          realPrice: cartModel.rate,
          rate: priceBeforeTax,
          tax: taxValue,
        ),
      ];
    }
  }


   void removeItem(PosCartModel cartModel) {
    final existingItemIndex = state.indexWhere((item) => item.id == cartModel.id);

    if (existingItemIndex != -1) {
      final currentItem = state[existingItemIndex];
      if (currentItem.quantity! > 1) {
        final updatedItem = currentItem.copyWith(
          quantity: currentItem.quantity! - 1,
        );

        state = [
          ...state.sublist(0, existingItemIndex),
          updatedItem,
          ...state.sublist(existingItemIndex + 1),
        ];
      } else {
        state = [
          ...state.sublist(0, existingItemIndex),
          ...state.sublist(existingItemIndex + 1),
        ];
      }
    }
  }

    void updateItem(PosCartModel updatedItem) {
    final existingItemIndex = state.indexWhere((item) => item.id == updatedItem.id);

    if (existingItemIndex != -1) {
      state = [
        ...state.sublist(0, existingItemIndex),
        updatedItem,
        ...state.sublist(existingItemIndex + 1),
      ];
    }
  }
  
  void removeAllCartItem(int index){
    state.removeRange(0, index);
  }
   void clearAllCartItems() {
    state = [];
  }
}

