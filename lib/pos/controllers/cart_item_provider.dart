

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sheraccerp/pos/models/pos_cart_model.dart';
import 'package:sheraccerp/shared/constants.dart';

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

  final updatedCartModel = cartModel.copyWith(
    unitValue: cartModel.unitValue ?? 1.0, 
    unitId: cartModel.unitId ?? 0,         
  );

  if (existingItemIndex != -1) {
    final existingItem = state[existingItemIndex];

    final updatedItem = existingItem.copyWith(
      quantity: existingItem.quantity! + 1,
      total: (existingItem.quantity! + 1) * double.tryParse(existingItem.rate.toStringAsFixed(2))!, 
      // tax: (existingItem.quantity! ) + double.tryParse(existingItem.tax!.toStringAsFixed(3))!,  
    );

    state = [
      ...state.sublist(0, existingItemIndex),
      updatedItem,
      ...state.sublist(existingItemIndex + 1),
    ];
  } else {
    double taxPercentage = updatedCartModel.tax ?? 0;
    double priceBeforeTax = updatedCartModel.rate / (1 + (taxPercentage / 100));
    double taxValue = updatedCartModel.rate - priceBeforeTax;
    double gross =  priceBeforeTax * updatedCartModel.quantity! ;
    double sGST = companyTaxMode == 'INDIA' ? taxValue  : 0;
    double cGST = companyTaxMode == 'INDIA' ? taxValue  : 0;
    double iGST = companyTaxMode == 'GULF' ? taxValue  : 0;
    double net =  updatedCartModel.quantity! * updatedCartModel.rate;
    double totalAmount = updatedCartModel.quantity! * updatedCartModel.rate; 

    state = [
      updatedCartModel.copyWith(
        cGST: double.tryParse(cGST.toStringAsFixed(2)),
        iGST: double.tryParse(iGST.toStringAsFixed(2)),
        sGST: double.tryParse(sGST.toStringAsFixed(2)),
        realPrice: double.tryParse(updatedCartModel.rate.toStringAsFixed(2))!,
        net: double.tryParse(net.toStringAsFixed(2)),
        gross: double.tryParse(gross.toStringAsFixed(2)),
        rate: double.tryParse(priceBeforeTax.toStringAsFixed(2))!,
        tax: double.tryParse(taxValue.toStringAsFixed(2)),
        total: double.tryParse(totalAmount.toStringAsFixed(2)), 
      ),
      ...state,
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

