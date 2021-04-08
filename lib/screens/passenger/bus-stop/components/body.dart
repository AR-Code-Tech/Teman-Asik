import 'dart:async';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teman_asik/constans.dart';
import 'package:teman_asik/screens/passenger/bus-stop/components/maps.dart';
import 'package:teman_asik/screens/passenger/bus-stop/model/bus_stop_model.dart';
import 'package:http/http.dart' as http;
import '../../../../constans.dart';

class BusStopBody extends StatefulWidget {
  @override
  _BusStopBodyState createState() => _BusStopBodyState();
}

class _BusStopBodyState extends State<BusStopBody> {
  List<BusStopModel> busStop = [];
  

  TextEditingController searchController = new TextEditingController();
  String filter;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _getTerminals();
  }

  void _getTerminals () async {
    try {
      var url = Uri.parse('$apiUrl/terminals');
      var httpResult = await http.get(url);
      print(httpResult.statusCode);
      var data = json.decode(httpResult.body);
      List<BusStopModel> terminals = [];
      int i = 0;
      for (var item in data['data']) {
        // print
        terminals.add(BusStopModel(item['name'], LatLng(item['latitude'], item['longitude'])));
        i++;
      }
      setState(() {
        busStop = terminals;
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
    final List<Widget> loadingShimmer = [];
    int shimmerCount = ((MediaQuery.of(context).size.height - ((kDefaultPadding * 2) + 25.0 + (kDefaultPadding*3))) / 50).floor() - 3;
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
          height: 50,
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
              Text('Daftar Halte', style: kTitleStyle, textAlign: TextAlign.left),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(kDefaultPadding, kDefaultPadding, kDefaultPadding, kDefaultPadding),
            child: Text('Daftar Halte', style: kTitleStyle, textAlign: TextAlign.left),
          ),
          Container(
            color: kLightColor,
            child: new Padding(
              padding: EdgeInsets.only(
                left: kDefaultPadding-5,
                right: kDefaultPadding-5,
                bottom: kDefaultPadding / 2
              ),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(
                    controller: searchController,
                    decoration: new InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
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
                    margin: EdgeInsets.fromLTRB(kDefaultPadding, 5, kDefaultPadding, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
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
                              size: 18,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            '${busStop[index].busStopName}',
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              color: kDarkColor
                            ),
                          )
                        ),
                        Expanded(
                          child: Container(),
                          flex: 1,
                        ),
                        Expanded(
                          child: Icon(Icons.arrow_forward_ios, color: kDarkColor, size: 15,),
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
