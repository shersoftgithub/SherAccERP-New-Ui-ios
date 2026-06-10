class PunchInModel {
  final String punchType;
  final String punchTime;
  final String pncDate;
  final int pncEmployee;
  final String? latitude;
  final String? longitude;  
  final String? workDur;

  PunchInModel({
    required this.punchType,
    required this.punchTime,
    required this.pncDate,
    required this.pncEmployee,
    this.latitude,
    this.longitude,
    this.workDur,
  });

  factory PunchInModel.fromJson(Map<String, dynamic> json) {
    return PunchInModel(
      punchType: json['pncType'] ?? '',
      punchTime: json['pncTime'] ?? '',
      pncDate: json['pncDate'] ?? '',
      pncEmployee: json['pncEmployee'] ?? 0,
      latitude: json['pncLatitude']?.toString(),
      longitude: json['pncLongitude']?.toString(),
      workDur: json['pncWorkDur']?.toString() ?? '',
    );
  }
}