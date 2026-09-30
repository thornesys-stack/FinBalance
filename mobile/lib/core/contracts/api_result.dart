class ApiResult<T> {
  final T? data;
  final String? message;
  final bool success;

  const ApiResult({
    this.data,
    this.message,
    required this.success,
  });

  factory ApiResult.success(T data) {
    return ApiResult(
      data: data,
      success: true,
    );
  }

  factory ApiResult.failure(String message) {
    return ApiResult(
      message: message,
      success: false,
    );
  }
}