class PunchTypeModel {
  final String punchType;
  final String punchTime;
  final String workDuration;

  PunchTypeModel({
    required this.punchType,
    required this.punchTime,
    required this.workDuration,
  });

  factory PunchTypeModel.fromJson(Map<String, dynamic> json) {
    return PunchTypeModel(
      punchType: json['pncType'] ?? '',
      punchTime: json['pncTime'] ?? '',
      workDuration: json['pncWorkDur'] ?? '',
    );
  }
}