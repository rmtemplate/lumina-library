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
    this.meta,
    this.errors,
  });

  final bool status;
  final String code;
  final String message;
  final T? data;

  /// Sibling of `data` in the backend envelope. Holds `pagination`
  /// ({ current_page, last_page, total, has_more_pages, per_page }) and
  /// other contextual metadata. Previously discarded — needed for infinite
  /// scroll to read `meta.pagination.has_more_pages`.
  final Map<String, dynamic>? meta;
  final dynamic errors;

  Map<String, dynamic>? get pagination =>
      meta?['pagination'] as Map<String, dynamic>?;

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
      meta: json['meta'] as Map<String, dynamic>?,
      errors: json['errors'],
    );
  }
}
