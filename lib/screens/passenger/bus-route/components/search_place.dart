import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_place/google_place.dart';
import 'package:teman_asik/constans.dart';
import 'dart:async';

class SearchPlace extends StatefulWidget {
  @override
  _SearchPlaceState createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {
  List<AutocompletePrediction> _prediction = [];
  Timer _debounce;
  bool isLoading = false;
  final googlePlace = GooglePlace(kGoogleApiKey);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
      _debounce?.cancel();
      super.dispose();
  }

  void _selectPlace(BuildContext context, int index) async {
    var details = await googlePlace.details.get(_prediction[index].placeId);
    Navigator.pop(context, LatLng(details.result.geometry.location.lat, details.result.geometry.location.lng));
  }

  void _onSearchTextUpdate(String query) async {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: 100), () async {
      try {
        var places = await googlePlace.autocomplete.get(query);
        setState(() {
          _prediction.clear();
        });
        for (var item in places.predictions) {
          setState(() {
            _prediction.add(item);
          });
        }
        // var details = await googlePlace.details.get(places.predictions[0].placeId);
        // print(places.predictions[0].description);
        // print(details.result.geometry.location.lat);
        // print(details.result.geometry.location.lng);
        // LatLng pos = LatLng(
        //   details.result.geometry.location.lat,
        //   details.result.geometry.location.lng
        // );
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: TextField(
          // controller: _searchQueryController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Cari Lokasi...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white30),
            fillColor: Colors.red,
          ),
          style: TextStyle(color: Colors.white, fontSize: 16.0),
          onChanged: _onSearchTextUpdate,
        ),
      ),
      body: Container(
        color: kBackgroundColor,
        child: ListView.builder(
          itemCount: _prediction.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                _selectPlace(context, index);
              },
              child: Container(
                margin: EdgeInsets.only(top: kDefaultPadding, left: kDefaultPadding, right: kDefaultPadding),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(_prediction[index].description),
              ),
            );
          }
        ),
      ),
    );
  }
}