import 'package:flutter/material.dart';
import 'package:teman_asik/constans.dart';

class HomeBody extends StatefulWidget {
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

//  'assets/images/illustrations/walking-with-handbag.png'
class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text("Anda adalah...", style: kTitleStyle),
                SizedBox(height: 30),
                CardSelection(
                  title: "Penumpang",
                  illustration: 'assets/images/illustrations/walking-with-handbag.png',
                  color: Colors.purple[300]
                ),
                CardSelection(
                  title: "Supir",
                  illustration: 'assets/images/illustrations/man-trolley.png',
                  color: Colors.orange[300]
                ),
              ]
            ),
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

  CardSelection({ this.illustration, this.title, this.color });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: kDefaultPadding/2, bottom: kDefaultPadding/2),
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: this.color,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 25,
            child: Image.asset(this.illustration, height: 220)
          ),
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.3),
              borderRadius: BorderRadius.circular(15)
            ),
          ),
          Center(
            child: Text(
              this.title,
              style: TextStyle(fontFamily: kFontFamily,
              color: kLightColor,
              fontSize: 20,
              fontWeight: FontWeight.w600)
            )
          )
        ]
      )
    );
  }
}