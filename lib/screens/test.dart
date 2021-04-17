import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
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
    return Scaffold(
      backgroundColor: Color(0xFF0C6DC6),
      body: SafeArea(
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
                    _createButton("SOPIR", "assets/icons/driver.png",
                        '/driver/login'),
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
      ),
    );
  }
}
