import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:teman_asik/constans.dart';
import '../../../../constans.dart';
import '../models/car.dart';
import '../../bus-list-detail/bus_list_detail_screen.dart';
import 'package:http/http.dart' as http;

class BusListBody extends StatefulWidget {
  @override
  _BusListBodyState createState() => _BusListBodyState();
}

class _BusListBodyState extends State<BusListBody> {
  bool isLoading = true;
  List<CarModel> _busCars = [];

  @override
  void initState() {
    super.initState();
    _getBusCars();
  }

  void _getBusCars () async {
    try {
      var url = Uri.parse('$apiUrl/transportations');
      var httpResult = await http.get(url);
      print(httpResult.statusCode);
      var data = json.decode(httpResult.body);
      List<CarModel> cars = [];
      List listColors = [Colors.blue, Colors.red, Colors.yellow, Colors.green, Colors.grey[700]];
      int i = 0;
      for (var item in data['data']) {
        // print
        cars.add(CarModel(
            id: 'a',
            title: item['name'],
            description: item['description'],
            icon: Icons.directions_bus,
            iconColor: listColors[i % (listColors.length)].withOpacity(0.3)
        ));
        i++;
      }
      setState(() {
        _busCars = cars;
      });

      Timer(Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final List<Widget> loadingShimmer = [];
    int shimmerCount = ((MediaQuery.of(context).size.height - ((kDefaultPadding * 2) + 25.0 + (kDefaultPadding*3))) / 70).floor() - 2;
    for(int i = 0; i < shimmerCount;i++) {
      loadingShimmer.add(Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[200],
        child: Container(
          margin: EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 60,
          width: MediaQuery.of(context).size.width,
        ),
      ));
    }
    if (isLoading) {
      return SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            top: kDefaultPadding,
            left: kDefaultPadding,
            right: kDefaultPadding
          ),
          color: kBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daftar Angkotan', style: kTitleStyle, textAlign: TextAlign.left),
              SizedBox(height: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: loadingShimmer,
              )
            ],
          ),
        )
      );
    }
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          top: kDefaultPadding,
          left: kDefaultPadding,
          right: kDefaultPadding
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

  CarItem({
    @required this.car
  });

  @override
  Widget build(BuildContext context) {
    final carTitleStlye = TextStyle(
      fontFamily: kFontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: kDarkColor.withOpacity(0.8)
    );
    final carSubTitleStlye = TextStyle(
      fontFamily: kFontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: kDarkColor.withOpacity(0.8)
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/passenger/bus-list-detail', arguments: BusListDetailScreenArguments(car.id));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
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
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(car.title, style: carTitleStlye),
                      // Text((MediaQuery.of(context).size.width).toString(), style: carTitleStlye),
                      SizedBox(height: 5),
                      Text((car.description.length > 25) ? car.description.substring(0, 25) : car.description, style: carSubTitleStlye)
                    ],
                  ),
                )
              ],
            ),
            Container(
              child: Icon(Icons.chevron_right),
            )
          ],
        ),
      ),
    );
  }
}
