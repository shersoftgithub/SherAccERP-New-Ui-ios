class LeavesModel {
  final DateTime ddate;
  final String type; // 'P' for present, other values for leave/absent
  final DateTime enter;

  LeavesModel({
    required this.ddate,
    required this.type,
    required this.enter,
  });

  factory LeavesModel.fromJson(Map<String, dynamic> json) {
    return LeavesModel(
      ddate: DateTime.parse(json['ddate']),
      type: json['type'] ?? '',
      enter: DateTime.parse(json['enter']),
    );
  }
}