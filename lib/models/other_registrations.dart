class OtherRegistrationModel {
  int id;
  String name;
  String description;
  String type;
  String add1;
  String add2;
  String add3;
  String email;
  OtherRegistrationModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.type,
      required this.add1,
      required this.add2,
      required this.add3,
      required this.email});

  factory OtherRegistrationModel.fromJson(Map<String, dynamic> json) {
    return OtherRegistrationModel(
        id: json['auto']??0,
        name: json['Name']??'',
        description: json['Description']??'',
        type: json['Type']??'',
        add1: json['add1']??'',
        add2: json['add2']??'',
        add3: json['add3']??'',
        email: json['Email']??'');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'add1': add1,
      'add2': add2,
      'add3': add3,
      'email': email,
    };
  }

  static emptyData() {
    return OtherRegistrationModel(
        id: 0,
        name: '',
        description: '',
        type: '',
        add1: '',
        add2: '',
        add3: '',
        email: '');
  }
}

OtherRegistrationModel? otherRegistrations;
