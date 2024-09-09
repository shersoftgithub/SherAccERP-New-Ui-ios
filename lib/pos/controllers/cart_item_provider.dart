

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

  double taxPercentage = updatedCartModel.tax ?? 0;
  double priceBeforeTax = updatedCartModel.realPrice / (1 + (taxPercentage / 100));
  double taxValue = updatedCartModel.realPrice - priceBeforeTax;

  double sGST = companyTaxMode == 'INDIA' ? taxValue / 2 : 0;
  double cGST = companyTaxMode == 'INDIA' ? taxValue / 2 : 0;
  double iGST = companyTaxMode == 'GULF' ? taxValue : 0;

  double totalTax = sGST + cGST + iGST;

  if (existingItemIndex != -1) {
    final existingItem = state[existingItemIndex];
    double newQuantity = existingItem.quantity! + 1;

    double totalAmount = newQuantity * (priceBeforeTax + totalTax);
    double totalTaxAmount = newQuantity * totalTax;

    final updatedItem = existingItem.copyWith(
      quantity: newQuantity,
      total: double.tryParse(totalAmount.toStringAsFixed(4)),
      tax: double.tryParse(totalTaxAmount.toStringAsFixed(4)),  
      net: newQuantity * updatedCartModel.rate,
      gross: newQuantity * priceBeforeTax,
      sGST: sGST * newQuantity,  
      cGST: cGST * newQuantity,  
      iGST: iGST * newQuantity,  
    );

    state = [
      ...state.sublist(0, existingItemIndex),
      updatedItem,
      ...state.sublist(existingItemIndex + 1),
    ];
  } else {
    double quantity = updatedCartModel.quantity ?? 1;

    double totalGross = quantity * priceBeforeTax;
    double totalNet = quantity * updatedCartModel.rate;
    double totalAmount = totalNet + (quantity * totalTax);  
    double totalTaxAmount = quantity * totalTax;  

    state = [
      updatedCartModel.copyWith(
        cGST: double.tryParse(cGST.toStringAsFixed(4))! * quantity,
        iGST: double.tryParse(iGST.toStringAsFixed(4))! * quantity,
        sGST: double.tryParse(sGST.toStringAsFixed(4))! * quantity,
        realPrice: priceBeforeTax,
        net: double.tryParse(totalNet.toStringAsFixed(4))!,
        gross: double.tryParse(totalGross.toStringAsFixed(4))!,
        tax: double.tryParse(totalTaxAmount.toStringAsFixed(4))!,  
        total: double.tryParse(totalAmount.toStringAsFixed(4))!,  
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

