import 'package:flutter/material.dart';
import 'package:teman_asik/constans.dart';

class PassengerHomeScreen extends StatefulWidget {
  @override
  _PassengerHomeScreenState createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final int itemLength = 5;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      // appBar: AppBar(
      //   leading: GestureDetector(
      //     onTap: () {
      //       Navigator.pushReplacementNamed(context, '/');
      //     },
      //     child: Icon(Icons.chevron_left),
      //   )
      // ),
      body: Container(
        child: Column(
          children: [
            
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          border: Border(
            top: BorderSide(width: 1, color: kDarkColor.withOpacity(0.1))
          )
        ),
        child: Row(
          children: [
            NavItem(length: itemLength, index: 0, icon: Icons.bus_alert),
            NavItem(length: itemLength, index: 1, icon: Icons.alt_route),
            NavItem(length: itemLength, index: 2, icon: Icons.map),
            NavItem(length: itemLength, index: 3, icon: Icons.question_answer),
            NavItem(length: itemLength, index: 4, icon: Icons.close),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final icon;
  final length;
  final int index;

  NavItem({ this.icon, this.length, this.index });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final backgroundColor = kBackgroundColor;

    return Container(
      height: 60,
      width: screenWidth / this.length,
      decoration: ((index == 1)
        ? BoxDecoration(
            color: backgroundColor,
            border: Border(bottom: BorderSide(width: 4, color: kPrimaryColor))
          )
        : BoxDecoration(
          color: backgroundColor
        )),
        child: (index == 1)
          ? Container(
            child: Icon(
              this.icon,
              color: ((index == 1) ? kPrimaryColor : kDarkColor.withOpacity(0.3))
            ),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  kPrimaryColor.withOpacity(0.3),
                  kPrimaryColor.withOpacity(0.02),
                ]
              ),
            ))
          : Icon(
              this.icon,
              color: ((index == 1) ? kPrimaryColor : kDarkColor.withOpacity(0.3))
            )
    );
  }
}