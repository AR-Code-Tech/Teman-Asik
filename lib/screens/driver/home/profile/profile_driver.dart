import 'package:flutter/material.dart';
import 'package:teman_asik/Api/auth_driver.dart';
import 'package:teman_asik/constans.dart';
import 'dart:ui';
class ProfileDriver extends StatelessWidget {
  Widget _createText(String title, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: kTitleStyle,
        ),
        Text(
          data,
          style: kSubTitleStyle,
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 3,
                color: Colors.blue,
              ),
              Positioned(
                bottom: -50,
                child: Image.asset(
                  'assets/images/logo/driver.png',
                  height: MediaQuery.of(context).size.height / 4,
                ),
              ),
            ],
          ),
        ),
        Expanded(flex: 1, child: Container()),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _createText("Nama", AuthDriver.name),
              _createText("No KTP", AuthDriver.identityNumber),
              _createText("Plat Nomor", AuthDriver.plateNumber),
              _createText("Jenis Angkot", AuthDriver.transportationName),
            ],
          ),
        ),
      ],
    );
  }
}
