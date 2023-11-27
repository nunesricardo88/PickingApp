class ApiResponse {
  int statusCode;
  bool success;
  dynamic result;

  ApiResponse({
    required this.statusCode,
    required this.success,
    required this.result,
  });
}
