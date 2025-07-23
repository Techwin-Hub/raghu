import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<bool> signupUser(String firstName, String lastName, String email,
      String phone, String password, File imageFile) async {
    var uri = Uri.parse('$baseUrl/signup');
    var request = http.MultipartRequest('POST', uri);

    request.fields['firstName'] = firstName;
    request.fields['lastName'] = lastName;
    request.fields['email'] = email;
    request.fields['phone'] = phone;
    request.fields['password'] = password;

    request.files.add(await http.MultipartFile.fromPath('profileImage', imageFile.path));

    var response = await request.send();
    return response.statusCode == 200;
  }

  static Future<bool> signinUser(String username, String password) async {
    var uri = Uri.parse('$baseUrl/signin');
    var response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}));

    return response.statusCode == 200;
  }
}
