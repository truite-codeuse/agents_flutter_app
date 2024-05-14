import 'dart:convert';

import 'package:http/http.dart' as http;

class GorgiasAPI {
  final String uname = "theophileromieu";
  final String pword = "H%Yljt\$^6s04pvcPik15";

  Future<bool> testGorgias() {
    final authn = 'Basic ${base64Encode(utf8.encode('$uname:$pword'))}';
    final headers = {
      'accept': '*/*',
      'Authorization': authn,
    };

    final url = Uri.parse('http://aiasvm1.amcl.tuc.gr:8085/getUserProjects');
    final res = http.get(url, headers: headers).then((res) {
      final status = res.statusCode;
      if (status != 200) throw Exception('http.get error: statusCode= $status');
      print(res.body);
      return true;
    }).catchError((e) {
      print(e.toString());
      return false;
    });
    return res;
  }
  

}