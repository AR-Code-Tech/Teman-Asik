import 'package:flutter/material.dart';
import 'package:teman_asik/constans.dart';

class LoginDriverBody extends StatelessWidget {
  Widget _buildTextFormField(String text, IconData icon) => TextFormField(
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildTextFormField(
                    "Password",Icons.lock_open_rounded,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    child: Text("MASUK"),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/driver/Home');
                    },
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
