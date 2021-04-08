import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teman_asik/constans.dart';
import 'package:teman_asik/screens/passenger/bus-stop/components/maps.dart';
import 'package:teman_asik/screens/passenger/bus-stop/model/bus_stop_model.dart';

class BusStopBody extends StatefulWidget {
  @override
  _BusStopBodyState createState() => _BusStopBodyState();
}

class _BusStopBodyState extends State<BusStopBody> {
  List<BusStopModel> busStop = [
    BusStopModel('Halte GKB Bundaran', LatLng(-7.522284, 112.413506)),
    BusStopModel('Halte SMPN 1 Manyar', LatLng(-7.463156, 112.431951)),
  ];
  

  TextEditingController searchController = new TextEditingController();
  String filter;
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: kLightColor,
            child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(
                    controller: searchController,
                    decoration: new InputDecoration(
                        hintText: 'Search', border: InputBorder.none),
                  ),
                  trailing: new IconButton(
                    icon: new Icon(Icons.cancel),
                    onPressed: () {
                      searchController.clear();
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: busStop.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusStopMaps(
                          busStopName: busStop[index].busStopName,
                          latLng: busStop[index].latlng,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            child: Icon(
                              Icons.place,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(),
                          flex: 1,
                        ),
                        Expanded(flex: 4, child: Text('${busStop[index].busStopName}')),
                        Expanded(
                          child: Container(),
                          flex: 1,
                        ),
                        Expanded(
                          child: Icon(Icons.arrow_forward_ios),
                          flex: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
