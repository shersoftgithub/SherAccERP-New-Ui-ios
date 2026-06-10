class WarrantyComplaintModel{
  String? complaint;
  int? gid;
  WarrantyComplaintModel({
    this.complaint,
    this.gid
  });
  Map<String, dynamic> toMap() {
    return {
      'complaint':complaint,
      'gid':gid,
    };
  }
}