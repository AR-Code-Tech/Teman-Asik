import 'package:flutter/material.dart';
import 'package:teman_asik/constans.dart';
import '../models/car.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/fontelico_icons.dart';

class BusListBody extends StatefulWidget {
  @override
  _BusListBodyState createState() => _BusListBodyState();
}

class _BusListBodyState extends State<BusListBody> {
  List<CarModel> _busCars = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _busCars.add(
        CarModel(
          title: 'Lyn A',
          icon: Icons.directions_bus,
          iconColor: Colors.blue.withOpacity(0.3)
        )
      );
      _busCars.add(
        CarModel(
          title: 'Lyn B',
          icon: Icons.directions_bus,
          iconColor: Colors.red.withOpacity(0.3)
        )
      );
      _busCars.add(
        CarModel(
          title: 'Lyn C',
          icon: Icons.directions_bus,
          iconColor: Colors.purple.withOpacity(0.3)
        )
      );
      _busCars.add(
        CarModel(
          title: 'Lyn D',
          icon: Icons.directions_bus,
          iconColor: Colors.green.withOpacity(0.3)
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          top: kDefaultPadding,
          left: kDefaultPadding * 2,
          right: kDefaultPadding * 2
        ),
        width: maxWidth,
        color: kBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daftar Angkotan', style: kTitleStyle, textAlign: TextAlign.left),
            SizedBox(height: 20,),
            Expanded(
              child: ListView(
                children: _busCars.map((CarModel car) {
                  return CarItem(car: car);
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CarItem extends StatelessWidget {
  final CarModel car;

  CarItem({@required this.car});

  @override
  Widget build(BuildContext context) {
    final carTitleStlye = TextStyle(
      fontFamily: kFontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: kDarkColor.withOpacity(0.8)
    );

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: car.iconColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(car.icon, color: Colors.grey[700],),
              ),
              SizedBox(width: 20),
              Text(car.title, style: carTitleStlye)
            ],
          ),
          Container(
            child: Icon(Icons.chevron_right),
          )
        ],
      ),
    );
  }
}
