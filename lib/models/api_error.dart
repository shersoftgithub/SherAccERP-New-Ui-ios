import 'dart:convert';

class ApiError {
  String error;
  ApiError({
    required this.error,
  });

  // ApiError({required error})

  // ApiError.fromJson(Map<String, dynamic> json) {
  //   _error = json['error'];
  // }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['error'] = _error;
  //   return data;
  // }

  Map<String, dynamic> toMap() {
    return {
      'error': error,
    };
  }

  factory ApiError.fromMap(Map<String, dynamic> map) {
    return ApiError(
      error: map['error'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiError.fromJson(String source) =>
      ApiError.fromMap(json.decode(source));
}
