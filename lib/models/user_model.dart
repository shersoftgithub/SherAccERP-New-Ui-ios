class UserModel {
  int id, userId;
  String userName, password, groupName;
  // Map password;

  UserModel(
      {required this.id, required this.userId, required this.userName, required this.password, required this.groupName});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['Auto'],
        userId: json['UserID'] ?? 0,
        userName: json['Name'] ?? '',
        password: json['Password'] ?? '',
        groupName: json['GroupName'] ?? '');
  }

  static emptyData() {
    return UserModel(
        groupName: '', id: 0, password: '', userId: 0, userName: '');
  }
}

class UserGroupModel {
  int id, save, edit, find, delete;
  String name;
  UserGroupModel(
      {required this.id, required this.name, required this.save, required this.edit, required this.delete, required this.find});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'save': save,
      'edit': edit,
      'find': find,
      'delete': delete,
      'name': name,
    };
  }

  factory UserGroupModel.fromMap(Map<String, dynamic> map) {
    return UserGroupModel(
      id: map['Auto'] ?? 0,
      save: map['S'] ?? 0,
      edit: map['E'] ?? 0,
      find: map['F'] ?? 0,
      delete: map['D'] ?? 0,
      name: map['Name'] ?? '',
    );
  }
}
