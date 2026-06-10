class LeaveDay {
  final DateTime date;
  final String status; 
  final String? leaveType; 

  LeaveDay({
    required this.date,
    required this.status,
    this.leaveType,
  });
}