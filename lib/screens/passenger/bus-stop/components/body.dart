import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong/latlong.dart';

class BusStopBody extends StatefulWidget {
  @override
  _BusStopBodyState createState() => _BusStopBodyState();
}

class _BusStopBodyState extends State<BusStopBody> {
  final LatLng myLocation = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(-7.522284, 112.413506),
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
                  point: LatLng(-7.522284, 112.413506),
                  builder: (ctx) =>
                  Container(
                    child: SvgPicture.asset('assets/icons/map-marker.svg', color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}

// AIzaSyA7U7ucdsrr7AZdAzvz50fbsPrkzEaMOnQ