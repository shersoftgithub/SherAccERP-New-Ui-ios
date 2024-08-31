import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sheraccerp/pos/models/pos_cart_model.dart';

part 'hold_items_model.g.dart';
part 'hold_items_model.freezed.dart';

@freezed
class HoldItemsModel with _$HoldItemsModel {
  factory HoldItemsModel({
    required int id,
    required List<PosCartModel> items,
  }) = _HoldItemsModel;

  factory HoldItemsModel.fromJson(Map<String, Object?> json) =>
      _$HoldItemsModelFromJson(json);
}
