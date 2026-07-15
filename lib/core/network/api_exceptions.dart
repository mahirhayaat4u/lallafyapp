/// Custom API exception classes
///
/// 💡 React Native equivalent: This is like the error object you reject
/// in your Axios interceptor: { message, status, errors }
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<ValidationError>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 422 || (errors?.isNotEmpty ?? false);
  bool get isServerError => (statusCode ?? 0) >= 500;
}

/// Individual validation error (mirrors backend's errors array)
class ValidationError {
  final String? field;
  final String message;

  ValidationError({this.field, required this.message});

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] as String?,
      message: json['message'] as String? ?? 'Validation error',
    );
  }
}

/// Network-level exception (no internet, timeout, etc.)
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection. Please check your network.']);

  @override
  String toString() => message;
}
