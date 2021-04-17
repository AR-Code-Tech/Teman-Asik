import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:teman_asik/Api/auth_driver.dart';
import 'package:teman_asik/constans.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeBody extends StatefulWidget {
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

//  'assets/images/illustrations/walking-with-handbag.png'
class _HomeBodyState extends State<HomeBody> {
  BuildContext context;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  void _checkState() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = (prefs.getString('auth_token') ?? '');
    bool isNavigation = (prefs.getBool('navigation') ?? false);
    try {
      if (token != '') {
        var url = Uri.parse('$apiUrl/auth/profile');
        var httpResult = await http.post(url, headers: <String, String>{
          'Accept': 'application/json;',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        });
        if (httpResult.statusCode == 200) {
          var data = jsonDecode(httpResult.body);
          AuthDriver.id = data["id"];
          AuthDriver.identityNumber = data["role"]["identity_number"];
          AuthDriver.plateNumber = data["role"]["plate_number"];
          AuthDriver.name = data["name"];
          AuthDriver.transportationId = data["role"]["transportation_id"];
          AuthDriver.transportationName =
              data["role"]["transportation"]["name"];
          Navigator.pushReplacementNamed(context, '/driver/Home');
        }
      }
    } catch (e) {}
    if (isNavigation)
      Navigator.pushReplacementNamed(context, '/passenger/live-navigation');
    while (context == null) {
      if (isNavigation)
        Navigator.pushReplacementNamed(context, '/passenger/live-navigation');
    }
    setState(() => isLoading = false);
  }

  Widget _createButton(String user, String imageUrl, String page) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, page);
      },
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFFEAEE16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(imageUrl),
            ),
            Text(
              user,
              style: TextStyle(color: Color(0xFF0C6DC6)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() => this.context = context);
    if (isLoading) {
      return Scaffold(
          backgroundColor: kBackgroundColor,
          body: Container(
            color: kBackgroundColor,
            child: Center(
              child: Text('Loading...'),
            ),
          ));
    }
    return SafeArea(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 1, child: Container()),
            Expanded(
              flex: 3,
              child: Image.asset(
                "assets/images/logo/menu.png",
                fit: BoxFit.fill,
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    "Pengguna",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Sebagai",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _createButton("PENUMPANG", "assets/icons/passenger.png",
                      '/passenger/home'),
                  _createButton(
                      "SOPIR", "assets/icons/driver.png", '/driver/login'),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/logo/dishub.png',
                  height: 42,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardSelection extends StatelessWidget {
  final String illustration;
  final String title;
  final Color color;
  final Function onTap;

  CardSelection(
      {@required this.illustration,
      @required this.title,
      @required this.color,
      @required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        this.onTap();
      },
      child: Container(
          margin: EdgeInsets.only(
              top: kDefaultPadding / 2, bottom: kDefaultPadding / 2),
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
              color: this.color, borderRadius: BorderRadius.circular(15)),
          child: Stack(children: [
            Positioned(
                left: 10,
                top: 25,
                child: Image.asset(this.illustration, height: 220)),
            Container(
              decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.3),
                  borderRadius: BorderRadius.circular(15)),
            ),
            Center(
                child: Text(this.title,
                    style: TextStyle(
                        fontFamily: kFontFamily,
                        color: kLightColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600)))
          ])),
    );
  }
}
