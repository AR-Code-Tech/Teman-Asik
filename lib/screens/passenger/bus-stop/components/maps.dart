import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong/latlong.dart';

class BusStopMaps extends StatelessWidget {
  final LatLng latLng;
  final String busStopName;
  BusStopMaps({Key key, @required this.latLng, @required this.busStopName}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(busStopName),),
      body: Container(
          child: FlutterMap(
            options: MapOptions(
              center: latLng,
              zoom: 13.5,
            ),
            layers: [
              TileLayerOptions(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']
              ),
              MarkerLayerOptions(
                markers: [
                  Marker(
                    width: 20.0,
                    height: 20.0,
                    point: latLng,
                    builder: (ctx) =>
                    Container(
                      child: SvgPicture.asset('assets/icons/map-marker.svg', color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}