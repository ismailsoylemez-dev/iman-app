class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

class LocationException extends AppException {
  const LocationException({required super.message, super.code, super.originalError});
}

class NotificationException extends AppException {
  const NotificationException({required super.message, super.code, super.originalError});
}

class DataException extends AppException {
  const DataException({required super.message, super.code, super.originalError});
}
