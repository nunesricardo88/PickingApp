import 'package:n6picking_flutterapp/utilities/constants.dart';

class TaskOperation {
  bool success;
  ErrorCode errorCode;
  String message;

  TaskOperation({
    required this.success,
    required this.errorCode,
    required this.message,
  });
}
