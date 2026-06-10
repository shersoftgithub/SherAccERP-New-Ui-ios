class UserSettingsModel {
  int userId;
  int salesmanId;
  int branchId;
  int cashId;
  int areaId;
  int groupId;
  int routeId;
  int? salesmanSelection;
  int? employeeId;
  UserSettingsModel({
    required this.userId,
    required this.salesmanId,
    required this.branchId,
    required this.cashId,
    required this.areaId,
    required this.groupId,
    required this.routeId,
    this.salesmanSelection,
    this.employeeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'salesmanId': salesmanId,
      'branchId': branchId,
      'cashId': cashId,
      'areaId': areaId,
      'groupId': groupId,
      'routeId': routeId,
      'salesmanSelection':salesmanSelection,
      'employeeId' : employeeId
    };
  }

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      userId: map['userId']?.toInt() ?? 0,
      salesmanId: map['salesmanId']?.toInt() ?? 0,
      branchId: map['branchId']?.toInt() ?? 0,
      cashId: map['cashId']?.toInt() ?? 0,
      areaId: map['areaId']?.toInt() ?? 0,
      groupId: map['groupId']?.toInt() ?? 0,
      routeId: map['routeId']?.toInt() ?? 0,
      salesmanSelection: map['salesmanSelection'] ?? 0,
      employeeId: map['employeeId'] ?? 0
    );
  }
}