import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:teman_asik/screens/passenger/bus-stop/components/maps.dart';

class BusStopBody extends StatefulWidget {
  @override
  _BusStopBodyState createState() => _BusStopBodyState();
}

class _BusStopBodyState extends State<BusStopBody> {
  final List<String> busStop = <String>[
    'Halte GKB Bundaran',
    'Halte SMPN 1 Manyar',
    // 'Halte SMPN 2 Manyar',
    // 'Halte SMPN 3 Manyar',
    // 'Halte SMPN 4 Manyar',
    // 'Halte SMPN 5 Manyar',
    // 'Halte SMPN 6 Manyar',
    // 'Halte SMPN 7 Manyar',
    // 'Halte SMPN 8 Manyar',
    // 'Halte SMPN 9 Manyar',
    // 'Halte SMPN 10 Manyar',
    // 'Halte SMPN 11 Manyar',
    // 'Halte SMPN 12 Manyar',
  ];
  final List<double> lat = <double>[
    -7.522284,
    -7.463156,
  ];
  final List<double> lng = <double>[
    112.413506,
    112.431951,
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
          itemCount: busStop.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusStopMaps(
                      busStopName: busStop[index],
                      latLng: LatLng(lat[index], lng[index]),
                    ),
                  ),
                );
              },
              child: Container(
                height: 80,
                margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.place,
                      size: 30,
                      color: Colors.red,
                    ),
                    Text('${busStop[index]}'),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
