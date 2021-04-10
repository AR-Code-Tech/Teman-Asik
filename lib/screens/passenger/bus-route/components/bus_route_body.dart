import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teman_asik/screens/passenger/bus-route/components/select_location.dart';
import '../../../../constans.dart';

class BusRouteBody extends StatefulWidget {
  @override
  _BusRouteBodyState createState() => _BusRouteBodyState();
}

class _BusRouteBodyState extends State<BusRouteBody> {
  LatLng myPos = LatLng(0, 0);
  TextEditingController _controllerOrigin = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _selectPositionScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocationScreen()
      )
    );
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          top: kDefaultPadding,
          left: kDefaultPadding,
          right: kDefaultPadding
        ),
        width: maxWidth,
        color: kBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cari Angkot', style: kTitleStyle, textAlign: TextAlign.left),
            SizedBox(height: 20,),
            CupertinoFormSection(
              header: Text('Mencari Angkot'),
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
          ],
        ),
      ),
    );
  }
}