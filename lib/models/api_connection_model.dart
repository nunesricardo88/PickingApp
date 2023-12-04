import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/services/networking.dart';

const String tableApiConnection = 'apiconnection';

mixin ApiConnectionFields {
  static final List<String> allValues = [
    id,
    url,
    port,
    connectionString,
    lastConnection,
  ];

  static const String id = '_id';
  static const String url = 'url';
  static const String port = 'port';
  static const String connectionString = 'connectionString';
  static const String lastConnection = 'lastConnection';
}

class ApiConnection {
  int? id;
  String url;
  String port;
  String connectionString;
  DateTime? lastConnection;

  ApiConnection({
    this.id,
    required this.url,
    required this.port,
    required this.connectionString,
    this.lastConnection,
  });

  // ignore: prefer_constructors_over_static_methods
  static ApiConnection fromJson(Map<String, dynamic> json) => ApiConnection(
        id: json[ApiConnectionFields.id] as int?,
        url: json[ApiConnectionFields.url] as String,
        port: json[ApiConnectionFields.port] as String,
        connectionString: json[ApiConnectionFields.connectionString] as String,
        lastConnection: json[ApiConnectionFields.lastConnection] == null
            ? null
            : DateTime.parse(
                json[ApiConnectionFields.lastConnection] as String,
              ),
      );

  Map<String, Object?> toJson() => {
        ApiConnectionFields.id: id,
        ApiConnectionFields.url: url,
        ApiConnectionFields.port: port,
        ApiConnectionFields.connectionString: connectionString,
        ApiConnectionFields.lastConnection: lastConnection?.toIso8601String(),
      };

  ApiConnection copy({
    int? id,
    String? url,
    String? port,
    String? connectionString,
    DateTime? lastConnection,
  }) =>
      ApiConnection(
        id: id ?? this.id,
        url: url ?? this.url,
        port: port ?? this.port,
        connectionString: connectionString ?? this.connectionString,
        lastConnection: lastConnection ?? this.lastConnection,
      );

  Future<bool> isValid() async {
    if (connectionString.isEmpty) {
      return false;
    }

    try {
      final String getUrl = '$connectionString/Api/ping';
      final NetworkHelper networkHelper = NetworkHelper(getUrl);
      final http.Response response =
          await networkHelper.getDataNoAuth(seconds: 10) as http.Response;

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
