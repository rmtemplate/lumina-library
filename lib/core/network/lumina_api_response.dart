/// Representasi generik response dari backend Lumina.
///
/// Backend selalu mengembalikan:
/// { "status": bool, "code": str, "message": str, "data": any, "errors": any }
class LuminaApiResponse<T> {
  const LuminaApiResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
    this.errors,
  });

  final bool status;
  final String code;
  final String message;
  final T? data;
  final dynamic errors;

  factory LuminaApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromData,
  }) {
    return LuminaApiResponse(
      status: json['status'] as bool? ?? false,
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: (fromData != null && json['data'] != null)
          ? fromData(json['data'])
          : json['data'] as T?,
      errors: json['errors'],
    );
  }
}
