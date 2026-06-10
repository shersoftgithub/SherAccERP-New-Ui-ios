import 'package:image_picker/image_picker.dart';

class DeliveryItemWiseModel{
  int? gId;
  int? entryNo;
  int? itemId;
  XFile image;

  DeliveryItemWiseModel({
    this.gId,
    this.entryNo,
    this.itemId,
    required this.image,
  });

   factory DeliveryItemWiseModel.fromMap(Map<String, dynamic> data) {
    return DeliveryItemWiseModel(
      gId: data['Gridid'],
      entryNo: data['Entryno'],
      itemId: data['itemid'],
      image: XFile(''), 
    );
  }

   Map<String, dynamic> toMap() => {
        "Entryno": entryNo,
        "itemid": itemId,
        "Gridid": gId,
        "Photo": image,
      };

   static List encodedToJson(List<DeliveryItemWiseModel> list) {
    List jsonList = [];
    list.map((item) => jsonList.add(item.toMap())).toList();
    return jsonList;
  }

}