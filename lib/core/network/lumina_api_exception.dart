class LuminaApiException implements Exception {
  const LuminaApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.fieldErrors,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  bool get isUnauthorized => statusCode == 401;
  bool get isValidationError => statusCode == 422;
  bool get isNetworkError => statusCode == null;
  bool get isServerError => (statusCode ?? 0) >= 500;

  /// Returns the first error message for a specific field, or null.
  String? fieldError(String field) {
    final errors = fieldErrors?[field];
    if (errors == null || errors.isEmpty) return null;
    return errors.first;
  }

  /// Returns a single human-readable message.
  /// Prioritises field errors over generic message.
  String get displayMessage {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      return fieldErrors!.values.first.first;
    }
    return message;
  }

  @override
  String toString() => 'LuminaApiException($statusCode): $message';
}
