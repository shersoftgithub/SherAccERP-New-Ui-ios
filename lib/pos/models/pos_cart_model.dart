
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pos_cart_model.g.dart';
part 'pos_cart_model.freezed.dart';

@freezed
class PosCartModel  with _$PosCartModel{
  factory PosCartModel({
    required String id,
    required String name,
    required int quantity
  }) = _PosCartModel;

  factory PosCartModel.fromJson(Map<String, Object?> json) =>
      _$PosCartModelFromJson(json);
}