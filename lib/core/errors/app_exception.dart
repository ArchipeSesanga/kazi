sealed class AppException implements Exception {
  const AppException(this.code, [this.message]);

  final String code;
  final String? message;

  @override
  String toString() =>
      'AppException($code${message != null ? ': $message' : ''})';
}

final class NetworkException extends AppException {
  const NetworkException([String? message]) : super('network', message);
}

final class PermissionDeniedException extends AppException {
  const PermissionDeniedException([String? message])
      : super('permissionDenied', message);
}

final class NotFoundException extends AppException {
  const NotFoundException([String? message]) : super('notFound', message);
}

final class InvalidInputException extends AppException {
  const InvalidInputException([String? message])
      : super('invalidInput', message);
}

final class RateLimitedException extends AppException {
  const RateLimitedException([String? message])
      : super('rateLimited', message);
}

final class OtpInvalidException extends AppException {
  const OtpInvalidException([String? message]) : super('otpInvalid', message);
}

final class OtpExpiredException extends AppException {
  const OtpExpiredException([String? message]) : super('otpExpired', message);
}

final class TooManyRequestsException extends AppException {
  const TooManyRequestsException([String? message])
      : super('tooManyRequests', message);
}

final class QuotaExceededException extends AppException {
  const QuotaExceededException([String? message])
      : super('quotaExceeded', message);
}

final class UnauthenticatedException extends AppException {
  const UnauthenticatedException([String? message])
      : super('unauthenticated', message);
}

final class UnknownException extends AppException {
  const UnknownException([String? message]) : super('unknown', message);
}
