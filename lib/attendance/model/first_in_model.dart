class FirstInModel {
  final String punchType;
  final String punchTime;

  FirstInModel({
    required this.punchType,
    required this.punchTime,
  });

  factory FirstInModel.fromJson(Map<String, dynamic> json) {
    return FirstInModel(
      punchType: json['pncType'] ?? '',
      punchTime: json['pncTime'] ?? '',
    );
  }
}