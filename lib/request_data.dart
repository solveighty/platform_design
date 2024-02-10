import 'dart:ffi';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' as io;




class SendToRest {
  static readBytes(String path){
    List<int> imageBytes = io.File(path).readAsBytesSync();
    return imageBytes;
  }
  static Future sendToRest(List<int> imageBytes) async {
    var url = Uri.parse('https://armario-rest.loophole.site/endpoint');
    final headers = {'Content-Type': 'application/json'};
    String base64img = base64Encode(imageBytes);
    Map params = {'base64_data': '${base64img}'};
    var body = json.encode(params);
    var response = await http.post(url, headers: headers, body: body);
    if (response.statusCode ==  200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      Fluttertoast.showToast(msg: jsonResponse['message']);
      print(jsonResponse['data']);
      return jsonResponse['data'];
    } else {
      print(response.body);
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      Fluttertoast.showToast(msg: jsonResponse['message']);
      throw Exception('Failed to load data. Status code: ${response.statusCode}.');
    }
  }
}