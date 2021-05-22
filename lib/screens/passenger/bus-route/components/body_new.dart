import 'dart:async';
import 'dart:convert';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teman_asik/screens/passenger/bus-route/components/preview.dart';
import 'package:google_maps_webservice/places.dart' as gmapsws;
import 'package:google_place/google_place.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

import '../../../../constans.dart';

class CarModel {
  int id;
  double distance;
  double cost;
  String title;
  String description;
  Color iconColor;
  IconData icon;
  List<LatLng> routes = [];
  LatLng closestPointFromOrigin;
  LatLng closestPointFromDestination;

  CarModel({
    @required this.id,
    @required this.distance,
    @required this.title,
    @required this.cost,
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
        color: kDarkColor.withOpacity(0.8));

    return GestureDetector(
      onTap: () {
        if (onPress != null) {
          return onPress();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0),
              blurRadius: 5.0,
            ),
          ],
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
                  child: Icon(
                    car.icon,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 20),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(car.title, style: carTitleStlye),
                      Column(
                        children: [
                          SizedBox(height: 5),
                          Text(
                            '${car.distance}km - Rp ${car.cost.toInt()}',
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontFamily: kFontFamily),
                          )
                        ],
                      )
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
  final googlePlace = GooglePlace(kGoogleApiKey);
  Set<Marker> _markers = {};
  List<CarModel> _busList = [];
  LatLng myPos;
  LatLng destinationPos;
  bool busPredictBoxShow = false;
  bool busPredictBoxIsLoading = false;
  int bestScoreTransportation;
  String placeNameText = '';
  bool isReady = false;
  bool locationPermissionStatus = false;
  Timer timerCheckPermission;


  void _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _googleMapController = controller;
    });
    await _locatePosition();
    Timer(Duration(seconds: 1), () {
      setState(() {
        isReady = true;
      });
      _setDestinationPos(myPos);
    });
  }

  void _onMapCameraMove(CameraPosition cameraPosition) async {
    if (isReady) await _setDestinationPos(cameraPosition.target);
  }

  Future<void> _setDestinationPos(LatLng coordinate) async {
    try {
      if (coordinate.latitude == 0 && coordinate.longitude == 0) return ;
      setState(() {
        busPredictBoxShow = false;
        destinationPos = coordinate;
        _markers.clear();
      });
      var placemark = await Geocoder.google(kGoogleApiKey).findAddressesFromCoordinates(Coordinates(destinationPos.latitude, destinationPos.longitude));
      setState(() {
        placeNameText = placemark.first.addressLine;
      });
    } catch(e) {
      print(e);
    }
  }

  void checkPermission() async {
    try {
      bool geolocatorPermissionStatus  = await Geolocator.isLocationServiceEnabled();
      setState(() => locationPermissionStatus = geolocatorPermissionStatus);
      timerCheckPermission = Timer(Duration(milliseconds: 500), checkPermission);
    } catch (e) {
    }
  }

  void _applyLocation() async {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: destinationPos,
          infoWindow: InfoWindow(
            title: 'Tujuan Kamu'
          )
        )
      );
      busPredictBoxShow = true;
    });
    await _getBusPrediction();
  }
  
  Future<void> _locatePosition() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        LatLng pos = LatLng(position.latitude, position.longitude);
        _focusCameraMap(pos, 17);
        myPos = pos;
        _setDestinationPos(myPos);
      });
    });
  }

  void _focusCameraMap(LatLng position, double zoom) {
    _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: zoom)));
  }

  void _openSearchPlace() async {
    setState(() {
      busPredictBoxShow = false;
    });
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
      LatLng resPos = LatLng(details.result.geometry.location.lat,
          details.result.geometry.location.lng);
      _focusCameraMap(resPos, 17);
      await _setDestinationPos(resPos);
      _focusBound();
    }
  }

  void _focusBound() {
    return ;
    Timer(Duration(milliseconds: 1000), () {
      // _focusCameraMap(result, 14);
      LatLng sourceLocation = myPos;
      LatLng destLocation = destinationPos;
      LatLng temp;
      if (sourceLocation.latitude > destLocation.latitude) {
        temp = sourceLocation;
        sourceLocation = destLocation;
        destLocation = temp;
      }
      LatLngBounds bound =
          LatLngBounds(southwest: sourceLocation, northeast: destLocation);
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

    if (l1.southwest.latitude == -100 || l2.southwest.latitude == -100) {
      check(u, c);
    }
  }

  @override
  void initState() {
    super.initState();
    timerCheckPermission = Timer(Duration(milliseconds: 500), checkPermission);
  }

  @override
  void dispose() {
    timerCheckPermission.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height;
    final maxWidth = MediaQuery.of(context).size.width;
    if (!locationPermissionStatus) {
      return Scaffold(
        body: Container(
            color: kBackgroundColor,
            child: Center(
              child: Text(
                'Tolong Aktifkan Layanan Lokasi...'
              ),
            ),
          ),
      );
    }
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
              )),
        ],
      ),
      floatingActionButton: AnimatedContainer(
        duration: Duration(seconds: 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 10),
            // (!busPredictBoxShow) ? FloatingActionButton.extended(
            //   heroTag: '1',
            //   onPressed: _applyLocation,
            //   label: Text('Pilih'),
            //   icon: Icon(Icons.check),
            //   backgroundColor: Colors.green,
            // ) : Container()
            // SizedBox(height: 10),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              Container(
                height: maxHeight * .5,
                color: Colors.black,
                child: Stack(
                  children: [
                    SizedBox(
                      height: (busPredictBoxShow) ? maxHeight * 0.60 : maxHeight,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: GoogleMap(
                              onMapCreated: _onMapCreated,
                              onCameraMove: _onMapCameraMove,
                              markers: _markers,
                              initialCameraPosition: CameraPosition(
                                target: (myPos == null) ? LatLng(0, 0) : myPos,
                              ),
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    (!busPredictBoxShow) ? Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: Icon(Icons.location_on, size: 50, color: Colors.redAccent),
                        transform: Matrix4.translationValues(0, -20, 0)
                      )
                    ) : Container(),
                    Positioned(
                      bottom: kDefaultPadding,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          _locatePosition();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/icons/focus.png",
                            height: 32,
                            width: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                          (!busPredictBoxIsLoading)
                              ? Expanded(
                                  child: ListView(
                                    children: _busList.map((CarModel car) {
                                      return CarItem(
                                        car: car,
                                        bestWay: false,
                                        onPress: () async {
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => PreviewScreen(
                                                      origin: myPos,
                                                      destination:
                                                          destinationPos,
                                                      closestPointFromDestination: car
                                                          .closestPointFromDestination,
                                                      closestPointFromOrigin:
                                                          car.closestPointFromOrigin,
                                                      routes: car.routes,
                                                      car: car)));
                                        },
                                      );
                                    }).toList(),
                                  ),
                                )
                              : Container(
                                  child: Center(child: Text('Loading...')),
                                )
                        ],
                      ),
                    );
                  },
                ))
              : Container(),
              (!busPredictBoxShow) ? SizedBox.expand(
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
                      child: ListView(
                        children: [
                          SizedBox(height: 20),
                          Text('Pilih Lokasi', style: TextStyle(fontFamily: kFontFamily, fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(.2),
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Text(
                              // placeNameText,
                              (placeNameText.length > 100) ? '${placeNameText.substring(0, 100)}...' : placeNameText,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 3,
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _applyLocation,
                              child: Text('Lanjut'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ))
              : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getBusPrediction() async {
    setState(() => busPredictBoxIsLoading = true);
    try {
      // get bus
      var originUrl = '${myPos.latitude},${myPos.longitude}';
      var destinationUrl =
          '${destinationPos.latitude},${destinationPos.longitude}';
      var url = Uri.parse(
          '$apiUrl/navigation?origin=$originUrl&destination=$destinationUrl');
      var httpResult = await http.get(url);
      var data = json.decode(httpResult.body);
      List<CarModel> cars = [];

      List listColors = [
        Colors.blue,
        Colors.red,
        Colors.yellow,
        Colors.green,
        Colors.grey[700]
      ];
      int i = 0;
      for (var item in data['transportations']) {
        List<LatLng> routes = [];
        for (var route in item["routes"]) {
          try {
            var rute = LatLng(route["latitude"], route["longitude"]);
            routes.add(rute);
          } catch (e) {}
        }
        try {
          cars.add(CarModel(
            id: item['id'],
            title: item['name'],
            cost: double.parse(item['cost'].toString()),
            distance: double.parse(item['distance'].toString()),
            description: item['description'],
            icon: Icons.directions_bus,
            iconColor: listColors[i % (listColors.length)].withOpacity(0.3),
            routes: routes,
            closestPointFromOrigin: LatLng(
                item['closestPointFromOrigin']['latitude'],
                item['closestPointFromOrigin']['longitude']),
            closestPointFromDestination: LatLng(
                item['closestPointFromDestination']['latitude'],
                item['closestPointFromDestination']['longitude']),
          ));
        } catch (e) {
          print(e);
        }
        print(item['cost']);
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