import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/utilities/system.dart';

class NetworkHelper {
  NetworkHelper(this.url);

  final String url;

  Future getDataNoAuth({required int seconds}) async {
    final Duration duration = Duration(seconds: seconds);
    final urlParsed = Uri.parse(url);

    final http.Response response = await http.get(urlParsed).timeout(duration);
    return response;
  }

  Future getData({required int seconds}) async {
    final Duration duration = Duration(seconds: seconds);
    final urlParsed = Uri.parse(url);
    final token = System.instance.activeUser!.tokenId;

    final http.Response response = await http.get(
      urlParsed,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(duration);
    return response;
  }

  Future postDataNoAuth({required String json, required int seconds}) async {
    final Duration duration = Duration(seconds: seconds);
    final urlParsed = Uri.parse(url);

    final http.Response response = await http.post(
      urlParsed,
      body: json,
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(duration);
    return response;
  }

  Future postData({required String json, required int seconds}) async {
    final Duration duration = Duration(seconds: seconds);
    final urlParsed = Uri.parse(url);
    final token = System.instance.activeUser!.tokenId;

    final http.Response response = await http.post(
      urlParsed,
      body: json,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(duration);
    return response;
  }
}
