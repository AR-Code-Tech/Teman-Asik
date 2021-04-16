import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gmapsws;
import 'package:google_place/google_place.dart';
import 'package:teman_asik/constans.dart';
import 'package:http/http.dart' as http;
import 'package:teman_asik/screens/passenger/bus-route/components/preview.dart';

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

// ignore: must_be_immutable
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

    return GestureDetector(
      onTap: () {
        if (onPress != null) {
          return onPress();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 0),
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
                  padding: EdgeInsets.all(10),
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

class BusRouteBody extends StatefulWidget {
  @override
  _BusRouteBodyState createState() => _BusRouteBodyState();
}

class _BusRouteBodyState extends State<BusRouteBody> {
  GoogleMapController _googleMapController;
  Set<Marker> _markers = {};
  LatLng myPos = LatLng(0, 0);
  LatLng destinationPos;
  final googlePlace = GooglePlace(kGoogleApiKey);
  bool helpShowed = false;
  bool busPredictBoxShow = false;
  bool selectButtonShow = false;
  bool busPredictBoxIsLoading = false;
  List<CarModel> _busList = [];
  int bestScoreTransportation;

  void _onMapCreated(GoogleMapController controller) async {
    _googleMapController = controller;
    _locatePosition();
  }

  void _locatePosition() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        LatLng pos = LatLng(position.latitude, position.longitude);
        _focusCameraMap(pos, 17);
        myPos = pos;
      });
    });
  }

  void _focusCameraMap(LatLng position, double zoom) {
    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: zoom
        )
      )
    );
  }

  void _onMapTap(LatLng pos) {
    setState(() {
      if (destinationPos != null) {
        destinationPos = null;
        _markers.removeWhere((marker) => marker.markerId.value == 'destination');
      }
      _addDestination(pos);
      busPredictBoxShow = false;
      selectButtonShow = true;
    });
  }

  void _addDestination (LatLng pos) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: pos,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: 'Tujuan Kamu'
          )
        )
      );
      destinationPos = pos;
    });
  }

  void _openSearchPlace() async {
    gmapsws.Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: Mode.overlay, // Mode.fullscreen
      language: "id",
      types: [],
      components: [gmapsws.Component(gmapsws.Component.country, "id")],
      strictbounds: false,
    );
    if (p != null) {
      var details = await googlePlace.details.get(p.placeId);
      _onMapTap(LatLng(details.result.geometry.location.lat, details.result.geometry.location.lng));
      _focusBound();
    }
  }

  void _focusBound() {
    Timer(Duration(milliseconds: 1200), () {
      // _focusCameraMap(result, 14);
      LatLng sourceLocation = myPos;
      LatLng destLocation = destinationPos;
      LatLng temp;
      if (sourceLocation.latitude > destLocation.latitude) {
        temp = sourceLocation;
        sourceLocation = destLocation;
        destLocation = temp;
      }
      LatLngBounds bound = LatLngBounds(southwest: sourceLocation, northeast: destLocation);
      CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 100);
      _googleMapController.animateCamera(u2).then((void v) {
        check(u2, _googleMapController);
      });
    });
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    _googleMapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();

    if (l1.southwest.latitude == -1000 || l2.southwest.latitude == -1000) {
      check(u, c);
    }
  }

  void _applyLocation () async {
    setState(() {
      busPredictBoxShow = true;
      selectButtonShow = false;
    });
    await _getBusPrediction();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        title: Text('Cari Angkot', style: kSubTitleStyle),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: _openSearchPlace,
              child: Icon(
                Icons.search,
                size: 26.0,
                color: Colors.grey[700],
              ),
            )
          ),
        ],
      ),
      body: Container(
        color: kBackgroundColor,
        child: Stack(
          children: [
            SizedBox(
              height: (busPredictBoxShow) ? maxHeight * 0.60 : maxHeight,
              child: Align(
                alignment: Alignment.center,
                child: GoogleMap(
                  onTap: _onMapTap,
                  onMapCreated: _onMapCreated,
                  markers: _markers,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(0, 0),
                  ),
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  compassEnabled: true,
                ),
              ),
            ),
            (busPredictBoxShow) ? SizedBox.expand(
              child: DraggableScrollableSheet(
                initialChildSize: .4,
                minChildSize: .4,
                maxChildSize: .4,
                builder: (BuildContext c, s) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10.0,
                          )
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            "Saran Angkot",
                            style: kSubTitleStyle,
                          ),
                        ),
                        SizedBox(height: 10),
                        (!busPredictBoxIsLoading) ? Expanded(
                          child: ListView(
                            children: _busList.map((CarModel car) {
                              return CarItem(
                                car: car,
                                bestWay: (car.id == bestScoreTransportation),
                                onPress: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PreviewScreen(
                                        origin: myPos,
                                        destination: destinationPos,
                                        closestPointFromDestination: car.closestPointFromDestination,
                                        closestPointFromOrigin: car.closestPointFromOrigin,
                                        routes: car.routes,
                                        car: car
                                      )
                                    )
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ) : Container(
                          child: Center(child: Text('Loading...')),
                        )
                      ],
                    ),
                  );
                },
              )
            ) : Container()
          ],
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: Duration(seconds: 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 10),
            (selectButtonShow) ? FloatingActionButton.extended(
              heroTag: '1',
              onPressed: _applyLocation,
              label: Text('Pilih'),
              icon: Icon(Icons.check),
              backgroundColor: Colors.green,
            ) : Container(),
            // SizedBox(height: 10),
          ],
        ),
      ),
    );
  }


  Future<void> _getBusPrediction() async {
    setState(() => busPredictBoxIsLoading = true);
    try {
      // get bus
      var originUrl = '${myPos.latitude},${myPos.longitude}';
      var destinationUrl = '${destinationPos.latitude},${destinationPos.longitude}';
      var url = Uri.parse('$apiUrl/navigation?origin=$originUrl&destination=$destinationUrl');
      var httpResult = await http.get(url);
      var data = json.decode(httpResult.body);
      List<CarModel> cars = [];

      List listColors = [Colors.blue, Colors.red, Colors.yellow, Colors.green, Colors.grey[700]];
      int i = 0;
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
          iconColor: listColors[i % (listColors.length)].withOpacity(0.3),
          routes: routes,
          closestPointFromOrigin: LatLng(item['closestPointFromOrigin']['latitude'], item['closestPointFromOrigin']['longitude']),
          closestPointFromDestination: LatLng(item['closestPointFromDestination']['latitude'], item['closestPointFromDestination']['longitude']),
        ));
        i++;
      }        
      
      setState(() {
        bestScoreTransportation = data['best']['id'];
        _busList = cars;
      });
    } catch (e) {
      print(e);
    }
    setState(() => busPredictBoxIsLoading = false);
  }
}