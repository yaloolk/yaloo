import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String getFriendlyMessage(dynamic error) {
    // 1. Handle Dio Network Errors
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "The connection timed out. Please check your internet and try again.";
        case DioExceptionType.connectionError:
          return "It looks like you're offline. Please check your internet connection.";
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;

          // Try to extract a clean message sent by your Django backend first
          final data = error.response?.data;
          if (data is Map) {
            final backendMessage = data['message'] ?? data['error'] ?? data['detail'];
            if (backendMessage != null && backendMessage is String) {
              return backendMessage; // e.g., "This username is already taken."
            }
          }

          // Fallback to generic friendly status code messages
          if (statusCode == 400) return "We couldn't process that request. Please check your details.";
          if (statusCode == 401) return "Your session has expired. Please log in again.";
          if (statusCode == 403) return "You don't have permission to do this.";
          if (statusCode == 404) return "We couldn't find what you were looking for.";
          if (statusCode != null && statusCode >= 500) {
            return "Our servers are currently experiencing issues. Please try again later.";
          }
          return "Something went wrong. Please try again.";
        case DioExceptionType.cancel:
          return "The request was cancelled.";
        default:
          return "An unexpected network error occurred. Please try again.";
      }
    }

    // 2. Handle generic Dart errors (e.g., parsing errors)
    return "Oops! Something went wrong on our end.";
  }
}