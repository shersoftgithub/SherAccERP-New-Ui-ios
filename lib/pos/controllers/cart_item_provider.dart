

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sheraccerp/pos/models/pos_cart_model.dart';

part 'cart_item_provider.g.dart';

@riverpod
class CartItem extends _$CartItem{
  @override
  List<PosCartModel> build(){
    return <PosCartModel> [];
  }

  void addItem(PosCartModel cartModel){
    state = [...state,cartModel];
  }
  void removeAllCartItem(int index){
    state.removeRange(0, index);
  }
}