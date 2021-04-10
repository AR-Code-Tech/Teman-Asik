import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teman_asik/screens/passenger/bus-route/components/preview.dart';
import 'package:teman_asik/screens/passenger/bus-route/components/select_location.dart';
import '../../../../constans.dart';
import 'package:http/http.dart' as http;

class CarItem extends StatelessWidget {
  final CarModel car;
  final Function onPress;
  bool bestWay = false;

  CarItem({
    @required this.car,
    @required this.bestWay,
    this.onPress,
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
        if (onPress != null) {
          return onPress();
        }
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
                      (bestWay) ? Column(
                        children: [
                          SizedBox(height: 5),
                          Text(
                            'Paling disarankan.',
                            style: TextStyle(
                              color: Colors.red[300],
                              fontFamily: kFontFamily
                            ),
                          )
                        ],
                      ) : Container()
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

class CarModel {
  int id;
  String title;
  String description;
  Color iconColor;
  IconData icon;
  List<LatLng> routes = [];
  LatLng closestPointFromOrigin;
  LatLng closestPointFromDestination;

  CarModel({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.icon,
    @required this.iconColor,
    @required this.routes,
    @required this.closestPointFromOrigin,
    @required this.closestPointFromDestination,
  });
}

class BusRouteBody extends StatefulWidget {
  @override
  _BusRouteBodyState createState() => _BusRouteBodyState();
}

class LocationSelectData {
  LatLng origin;
  LatLng destination;

  LocationSelectData({
    @required this.origin,
    @required this.destination
  });
}

class _BusRouteBodyState extends State<BusRouteBody> {
  LatLng myPos;
  LatLng destinationPos;
  List<CarModel> _busList = [];
  List<LatLng> _routes = [];
  TextEditingController _controllerOrigin = new TextEditingController();
  TextEditingController _controllerDestination = new TextEditingController();
  bool isLoading = true;
  int bestScoreTransportation;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = false;
    });
  }

  void _selectPositionScreen(BuildContext context) async {
    final LocationSelectData result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocationScreen()
      )
    );
    if (result != null) {
      if (result.destination == null) {
        setState(() {
          myPos = null;
          destinationPos = null;
          _controllerOrigin.text = '';
          _controllerDestination.text = '';
        });
        return ;
      }

      try {
        setState(() {
          isLoading = true;
          myPos = result.origin;
          destinationPos = result.destination;
        });
        // print(result.destination);

        // get origin
        var httpResultOrigin = await _getPlaceInfo(result.origin);
        var bodyOrigin = json.decode(httpResultOrigin.body);
        
        // get origin
        var httpResultDestination = await _getPlaceInfo(result.destination);
        var bodyDestination = json.decode(httpResultDestination.body);

        // get bus
        var originUrl = '${result.origin.latitude},${result.origin.longitude}';
        var destinationUrl = '${result.destination.latitude},${result.destination.longitude}';
        var url = Uri.parse('$apiUrl/navigation?origin=$originUrl&destination=$destinationUrl');
        var httpResult = await http.get(url);
        var data = json.decode(httpResult.body);
        List<CarModel> cars = [];

        for(var item in data['transportations']) {
          List<LatLng> routes = [];
          for (var route in item["routes"]) {
            try {
              var rute = LatLng(route["latitude"], route["longitude"]);
              routes.add(rute);
            } catch (e) {
            }
          }
          cars.add(CarModel(
            id: item['id'],
            title: item['name'],
            description: item['description'],
            icon: Icons.directions_bus,
            iconColor: Colors.blue.withOpacity(0.3),
            routes: routes,
            closestPointFromOrigin: LatLng(item['closestPointFromOrigin']['latitude'], item['closestPointFromOrigin']['longitude']),
            closestPointFromDestination: LatLng(item['closestPointFromDestination']['latitude'], item['closestPointFromDestination']['longitude']),
          ));
        }        
        
        setState(() {
          bestScoreTransportation = data['best']['id'];
          _busList = cars;
          _controllerOrigin.text = bodyOrigin["results"][0]["formatted_address"];
          _controllerDestination.text = bodyDestination["results"][0]["formatted_address"];
        });
      } catch (e) {
        print(e);
      }
      setState(() => isLoading = false);
    }
  }

  _getPlaceInfo(LatLng pos) async {
    var url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=$kGoogleApiKey');
    var httpResult = await http.get(url);
    return httpResult;
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
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
        padding: EdgeInsets.only(
          top: kDefaultPadding,
          left: kDefaultPadding,
          right: kDefaultPadding
        ),
        width: maxWidth,
        height: maxHeight,
        color: kBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cari Angkot', style: kTitleStyle, textAlign: TextAlign.left),
            SizedBox(height: 20,),
            CupertinoFormSection(
              header: Text('Masukan Lokasi'),
              children: <Widget>[
                CupertinoFormRow(
                  child: CupertinoTextFormFieldRow(
                    controller: _controllerOrigin,
                    placeholder: 'Posisi Anda Terkini',
                    readOnly: true,
                  ),
                  prefix: Text('Dari'),
                ),
                CupertinoFormRow(
                  child: CupertinoTextFormFieldRow(
                    controller: _controllerDestination,
                    placeholder: 'Pilih Tujuan',
                    readOnly: true,
                  ),
                  prefix: Text('Tujuan'),
                ),
                CupertinoFormRow(
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      child: Text(
                        'Pilih Lokasi',
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 12
                        ),
                      ),
                      onPressed: () {
                        _selectPositionScreen(context);
                      },
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
            (myPos != null && destinationPos != null) ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30,),
                Text('Saran Angkot', style: kSubTitleStyle, textAlign: TextAlign.left),
                SizedBox(height: 20,),
                Stack(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: maxHeight / 3,
                        child: ListView(
                          children: _busList.map((CarModel car) {
                            return CarItem(
                              car: car,
                              bestWay: (car.id == bestScoreTransportation),
                              onPress: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PreviewScreen(
                                      origin: myPos,
                                      destination: destinationPos,
                                      closestPointFromDestination: car.closestPointFromDestination,
                                      closestPointFromOrigin: car.closestPointFromOrigin,
                                      routes: car.routes,
                                    )
                                  )
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ) : Container(),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text('Saran Angkot', style: kSubTitleStyle, textAlign: TextAlign.left),
            //     SizedBox(height: 20,),
            //     Expanded(
            //       child: ListView(
            //         children: _busList.map((CarModel car) {
            //           return CarItem(car: car);
            //         }).toList(),
            //       ),
            //     )
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}