import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import '../../../../constans.dart';

class SelectLocationScreen extends StatefulWidget {
  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  GoogleMapController _googleMapController;
  Set<Marker> _markers = {};
  LatLng myPos = LatLng(0, 0);
  LatLng destinationPos;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _googleMapController = controller;
    });
    _locatePosition();
  }

  void _onMapTap(LatLng pos) {
    setState(() {
      if (destinationPos != null) {
        destinationPos = null;
        _markers.removeWhere((marker) => marker.markerId.value == 'destination');
      }

      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: pos,
          icon: BitmapDescriptor.defaultMarker
        )
      );
      destinationPos = pos;
    });
  }

  void _locatePosition() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17
          )
        )
      );
    });
  }

  void _searchLocation() async {
      Prediction prediction = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        language: "id",
        mode: Mode.overlay,
        components: [new Component(Component.country, "id")]
      );
      displayPrediction(prediction);
      print(prediction);
    try {
    } catch (e) {
      print(e);
    }
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      // var address = await Geocoder.local.findAddressesFromQuery(p.description);

      print(lat);
      print(lng);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Tujuan'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                onTap: _onMapTap,
                markers: _markers,
                initialCameraPosition: CameraPosition(
                  target: LatLng(0.0, 0.0),
                ),
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
              ),
            ),
          ],
        )
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: '1',
            onPressed: _locatePosition,
            label: Text('Lokasi Saya'),
            icon: Icon(Icons.gps_fixed)
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: '2',
            onPressed: _searchLocation,
            label: Text('Cari Lokasi'),
            icon: Icon(Icons.search),
            backgroundColor: Colors.amber,
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: '3',
            onPressed: _locatePosition,
            label: Text('Pilih'),
            icon: Icon(Icons.check),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }
}