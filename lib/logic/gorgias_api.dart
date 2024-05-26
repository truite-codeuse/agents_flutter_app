import 'dart:convert';
import 'dart:io';
import 'logic.dart';
import 'package:http/http.dart' as http;

/// API transcription for the Gorgias Cloud API
class GorgiasAPI {

  // Credentials
  final String authn = "Basic dGhlb3BoaWxlcm9taWV1OkglWWxqdCReNnMwNHB2Y1BpazE1";
  
  /// Returns the headers for the HTTP request (auth)
  Map<String, String> getHeaders() {
    return {
      'accept': '*/*',
      'Authorization': authn,
    };
  }

  /// Returns the basic URI for the API request with the route added at the end
  Uri getUri(String route) {
    return Uri.parse('http://aiasvm1.amcl.tuc.gr:8085$route');
  }

  /// Adds a file to the Gorgias Cloud API
  /// BE CAREFUL IT DOES NOT WORK YET
  Future<bool> addFile(File file) {
    //return file.readAsBytes().then((value) {
      var fileBytes = {"file":file.readAsStringSync()};
      final headers = getHeaders();
      final url = getUri("/addFile?project=intellagent&type=gorgias");
      return http.post(url, headers:headers, body:fileBytes).then((value) {
        final status = value.statusCode;
        if (status != 200) throw Exception('http.post error: statusCode= $status');
          print(value.body);
          return true;
        }).catchError((e) {
          print(e.toString());
          return false;
        });
      //}
    //);
  }

  /// Adds a file to the Gorgias Cloud API (another attempt)
  /// BE CAREFUL IT DOES NOT WORK YET
  Future<bool> addFile2(String filePath) async {
    var headers = {
      'Authorization': 'Basic dGhlb3BoaWxlcm9taWV1OkglWWxqdCReNnMwNHB2Y1BpazE1',
      'Cookie': 'JSESSIONID=F809087772521359CDA470F058BD4CF5'
    };
    var request = http.MultipartRequest('POST', Uri.parse('http://aiasvm1.amcl.tuc.gr:8085/addFile?project=intellagent&type=gorgias'));
    request.files.add(await http.MultipartFile.fromPath('file', '/home/truitedev/Documents/rules.pl'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
    return true;
  }

  Future<String> getFile(String name) {
    final String fileName = name == "" ? "rules.pl" : name;
    var headers = getHeaders();
    headers['accept'] = 'application/json';
    final url = getUri("/getFileContent?filename=$fileName&project=intellagent");
    return http.post(url, headers:headers).then(
      (value) {
        return value.body;
      }
    );
  }

  /// Queries the Gorgias Cloud API and returns if the call should be denied or not
  Future<bool> queryGorgias(List<Fact> facts, String name) {
    final String fileName = name == "" ? "intellagent/rules.pl" : name;
    const String query = "deny";
    List<String> trueFacts = facts.where((f) => f.state).map<String>((f) => f.name).toList();
    final data = {
      "facts":trueFacts,
      "gorgiasFiles": [
        fileName
      ],
      "query": query,
      "resultSize": 1
    };
    var headers = getHeaders();
    headers['Content-type'] = 'application/json';
    final url = getUri("/GorgiasQuery");
    return http.post(url, headers:headers, body:jsonEncode(data)).then(
      (value) {
        return json.decode(value.body)["hasResult"];
      }
    );
  }
}