import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asik/constans.dart';
import 'package:http/http.dart' as http;

// Navigator.pushReplacementNamed(context, '/driver/Home');

class LoginDriverBody extends StatefulWidget {
  @override
  _LoginDriverBodyState createState() => _LoginDriverBodyState();
}

class _LoginDriverBodyState extends State<LoginDriverBody> {
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  void _showAlert(String text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  void _login() async {
    try {
      var url = Uri.parse('$apiUrl/auth/login');
      var httpResult = await http.post(
        url,
        headers: <String, String>{
          'Accept': 'application/json;',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _usernameController.text,
          'password': _passwordController.text
        })
      );
      var body = json.decode(httpResult.body);
      if (httpResult.statusCode == 422) {
        if (body['message'] != null) {
          if (body['errors'] != null) {
            Map<String, dynamic> errors = body['errors'];
            errors.forEach((key, value) {
              for (var e in value) {
                _showAlert(e);
                break;
              }
            });
          } else {
            _showAlert(body['message']);
          }
        } else {
          _showAlert('Data tidak lengkap.');
        }
      } else if (httpResult.statusCode == 401) {
        _showAlert('Username atau Password salah.');
      } else if (httpResult.statusCode == 200) {
        if (body['user']['role'] != 'Driver') {
          return _showAlert('Akun anda bukan seorang Driver.');
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', body['access_token']);
        Navigator.pushReplacementNamed(context, '/driver/Home');
      } else {
        print(httpResult.statusCode);
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _buildTextFormField(String text, IconData icon, TextEditingController controller) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: text,
      prefixIcon: Icon(
        icon,
        color: Colors.black45,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28.0),
        borderSide: BorderSide(
          color: Colors.green,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28.0),
        borderSide: BorderSide(
          color: Colors.green,
        ),
      ),
      hintText: text,
    ),
  );


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text("LOGO APPS", style: kTitleStyle),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Column(
                  children: [
                    Text("MASUK", style: kSubTitleStyle),
                    Text("SEBAGAI SOPIR", style: kSubTitleStyle),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildTextFormField(
                    "Username",
                    Icons.account_circle,
                    _usernameController
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildTextFormField(
                    "Password",
                    Icons.lock_open_rounded,
                    _passwordController
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    child: Text("MASUK"),
                    onPressed: _login,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Segera Lakukan Pendaftaran ke kantor dinas perhubungan gersik untuk mendapatkan username dan password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Image.asset(
                    'assets/images/logo/dishub.png',
                    height: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}