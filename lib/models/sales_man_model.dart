class SalesManModel {
  int id;
  String name, empCode, employeeSection;
  double salary;
  bool active;

  SalesManModel(
      {required this.id,
      required this.name,
      required this.empCode,
      required this.employeeSection,
      required this.salary,
      required this.active});

  factory SalesManModel.fromJson(Map<String, dynamic> json) {
    return SalesManModel(
      id: json['Auto'],
      name: json['name'],
      empCode: json['emp_code'],
      employeeSection: json['EmployeeSection'],
      salary: json['Salary'].toDouble(),
      active: json['Active'] == 1 ? true : false,
    );
  }

  static emptyData() {
    return SalesManModel(
        active: true,
        empCode: '0',
        employeeSection: '',
        id: 0,
        name: '',
        salary: 0);
  }
}

class EmployeeModel {
  String name;
  String address1;
  String address2;
  String address3;
  String telephone;
  String mobile;
  String date;
  bool activate;
  double salary;
  int auto;
  double ot;
  double dailyAllowance;
  double liveDeduction;
  double total;
  String employeeSection;
  double casualLeave;
  double tickEligibility;
  String commissionStatus;
  String type;
  double commissionPercentage;
  String min;
  String empCode;
  String empId;
  String gender;
  String workingHour;
  double vehicleCommission;
  double loadingCharge;
  String mode;
  int lunchMin;
  int otHour;
  String sms;
  double esi;
  double pf;
  int active;
  int att;
  String expiryDate;
  String expiryDateArabic;
  String baladiyaExpiryDate;
  String passportExpiryDate;
  int location;
  int ledCode;

  EmployeeModel({
    required this.name,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.telephone,
    required this.mobile,
    required this.date,
    required this.activate,
    required this.salary,
    required this.auto,
    required this.ot,
    required this.dailyAllowance,
    required this.liveDeduction,
    required this.total,
    required this.employeeSection,
    required this.casualLeave,
    required this.tickEligibility,
    required this.commissionStatus,
    required this.type,
    required this.commissionPercentage,
    required this.min,
    required this.empCode,
    required this.empId,
    required this.gender,
    required this.workingHour,
    required this.vehicleCommission,
    required this.loadingCharge,
    required this.mode,
    required this.lunchMin,
    required this.otHour,
    required this.sms,
    required this.esi,
    required this.pf,
    required this.active,
    required this.att,
    required this.expiryDate,
    required this.expiryDateArabic,
    required this.baladiyaExpiryDate,
    required this.passportExpiryDate,
    required this.location,
    required this.ledCode,
  });

  factory EmployeeModel.fromMap(Map<String, dynamic> json) => EmployeeModel(
        name: json["Name"],
        address1: json["Address1"],
        address2: json["address2"],
        address3: json["address3"],
        telephone: json["Telephone"],
        mobile: json["Mobile"],
        date: json["DDate"],
        activate: json["Activate"],
        salary: json["Salary"].toDouble(),
        auto: json["Auto"],
        ot: json["OT"].toDouble(),
        dailyAllowance: json["DAllowance"].toDouble(),
        liveDeduction: json["LiveDeduction"].toDouble(),
        total: json["Total"].toDouble(),
        employeeSection: json["EmployeeSection"],
        casualLeave: json["CashualLeave"].toDouble(),
        tickEligibility: json["TickeEligibility"].toDouble(),
        commissionStatus: json["salescomStatus"],
        type: json["Type"],
        commissionPercentage: json["commisionper"].toDouble(),
        min: json["min"],
        empCode: json["emp_code"],
        empId: json["emp_id"],
        gender: json["Gender"],
        workingHour: json["WorkingHour"],
        vehicleCommission: json["VehicleCommision"].toDouble(),
        loadingCharge: json["LoadingCharge"].toDouble(),
        mode: json["mode"],
        lunchMin: json["lunchmin"],
        otHour: json["othour"],
        sms: json["SMS"],
        esi: json["esi"].toDouble(),
        pf: json["pf"].toDouble(),
        active: json["Active"],
        att: json["att"],
        expiryDate: json["expdate"],
        expiryDateArabic: json["ExpdateArabic"],
        baladiyaExpiryDate: json["Baladiyaexpdate"],
        passportExpiryDate: json["Passportexpdate"],
        location: json["Location"],
        ledCode: json["LedCode"],
      );

  Map<String, dynamic> toMap() => {
        "Name": name,
        "Address1": address1,
        "address2": address2,
        "address3": address3,
        "Telephone": telephone,
        "Mobile": mobile,
        "DDate": date,
        "Activate": activate,
        "Salary": salary,
        "Auto": auto,
        "OT": ot,
        "DAllowance": dailyAllowance,
        "LiveDeduction": liveDeduction,
        "Total": total,
        "EmployeeSection": employeeSection,
        "CashualLeave": casualLeave,
        "TickeEligibility": tickEligibility,
        "salescomStatus": commissionStatus,
        "Type": type,
        "commisionper": commissionPercentage,
        "min": min,
        "emp_code": empCode,
        "emp_id": empId,
        "Gender": gender,
        "WorkingHour": workingHour,
        "VehicleCommision": vehicleCommission,
        "LoadingCharge": loadingCharge,
        "mode": mode,
        "lunchmin": lunchMin,
        "othour": otHour,
        "SMS": sms,
        "esi": esi,
        "pf": pf,
        "Active": active,
        "att": att,
        "expdate": expiryDate,
        "ExpdateArabic": expiryDateArabic,
        "Baladiyaexpdate": baladiyaExpiryDate,
        "Passportexpdate": passportExpiryDate,
        "Location": location,
        "LedCode": ledCode,
      };
}
