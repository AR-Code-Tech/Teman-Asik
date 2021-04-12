import 'dart:ui';
import 'package:flutter/material.dart';
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
        var httpResult = await http.post(
          url,
          headers: <String, String>{
            'Accept': 'application/json;',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          }
        );
        if (httpResult.statusCode == 200) {
          Navigator.pushReplacementNamed(context, '/driver/Home');
        }
      }
    } catch (e) {
    }
    if (isNavigation) Navigator.pushReplacementNamed(context, '/passenger/live-navigation');
    while (context == null) {
      if (isNavigation) Navigator.pushReplacementNamed(context, '/passenger/live-navigation');
    }
    setState(() => isLoading = false);
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
            child: Text(
              'Loading...'
            ),
          ),
        )
      );
    }
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(top: 15),
              child: Column(
                children: [Text("LOGO APPS", style: kTitleStyle)],
              ),
            ),
            Column(children: [
              Text("Anda adalah...", style: kSubTitleStyle),
              SizedBox(height: 30),
              CardSelection(
                title: "Penumpang",
                illustration:
                    'assets/images/illustrations/walking-with-handbag.png',
                color: Colors.blue[300],
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/passenger/home');
                },
              ),
              CardSelection(
                title: "Supir",
                illustration: 'assets/images/illustrations/man-trolley.png',
                color: Colors.orange[300],
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/driver/login');
                },
              ),
            ]),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Image.asset('assets/images/logo/dishub.png', height: 42),
            )
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
