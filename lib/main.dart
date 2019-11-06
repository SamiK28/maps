import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

import 'package:location/location.dart' as LocationManager;
import "package:google_maps_webservice/places.dart";
import 'package:sliding_up_panel/sliding_up_panel.dart';

final String kGoogleApiKey = "AIzaSyBShd19wL1Lj9-MDRkyzh1jr4fiuWQ_UIA";
final places = new GoogleMapsPlaces(apiKey: kGoogleApiKey);

Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 0.0, target: LatLng(365.0, 0.00), tilt: 0.0, zoom: 12.0);

  Future<LatLng> getUserLocation() async {
    // var currentLocation = LocationData;
    // var location = new Location();
    var currentLocation;
    final location = LocationManager.Location();
    try {
      currentLocation = await location.getLocation();
      Map<String, double> curr = jsonDecode(currentLocation.toString());

      double lat = curr["latitude"];
      double lng = curr["longitude"];
      final center = LatLng(lat, lng);
      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  Future<void> getl(search) async {
    PlacesSearchResponse reponse =
        await places.searchByText(search).then((value) async {
      print(value.results.length);
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          bearing: 0.0,
          target: LatLng(value.results[0].geometry.location.lat,
              value.results[0].geometry.location.lng),
          tilt: 0.0,
          zoom: 7.0)));

      _add(value.results[0].name, value.results[0].geometry.location);
    });
  }

  TextEditingController _searchcontroller;
  bool entered = false;
  String title = 'Welcome';

  void _add(String mid, Location m) {
    var markerIdVal = mid;
    String info = "";
    info = "Name : XYZ Phone\n" +
        m.lat.toString() +
        "," +
        m.lng.toString() +
        "\n" +
        "Battery : 60 %\n";
    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(m.lat, m.lng),
      infoWindow: InfoWindow(
        title: info,
        snippet:
            "12345vt786bv66i8bbi,yctvgto8tv23t84o264tv468o2t4b2t44o8btc,v48o6tvrtv6r5v65v74ev5",
      ),
      onTap: () {
        bottomSheet();
      },
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  Color color = Colors.white;
  bool surprise = true;
  double mapHeight = 806.8571428571429;

  @override
  Widget build(BuildContext context) {
    print(mapHeight);
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(20.0),
      topRight: Radius.circular(20.0),
    );
    //getl('Paris');
    return Scaffold(
      appBar: AppBar(
        title: entered
            ? TextField(
                textCapitalization: TextCapitalization.words,
                controller: _searchcontroller,
                decoration: InputDecoration(hintText: 'Search Here'),
                onSubmitted: (v) {
                  title = v;
                  getl(v);
                  entered = !entered;
                  setState(() {});
                },
              )
            : Text(
                title,
                style: TextStyle(color: Colors.black),
              ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              entered = !entered;
            });
          },
        ),
      ),
      body: Stack(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: mapHeight,
                child: GoogleMap(
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    onTap: (omg) {
                      setState(() {
                        surprise = false;
                      });
                    },
                    myLocationButtonEnabled: true,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    markers: [
                      Marker(
                        markerId: MarkerId("value"),
                        position: LatLng(28.6139, 77.2090),
                        infoWindow: InfoWindow(
                          title: "info",
                          snippet:
                              "12345vt786bv66i8bbi,yctvgto8tv23t84o264tv468o2t4b2t44o8btc,v48o6tvrtv6r5v65v74ev5",
                        ),
                        onTap: () {
                          setState(() {
                            color = Colors.red;
                            surprise = true;
                          });
                        },
                      )
                    ].toSet()
                    //Set<Marker>.of(markers.values)
                    ),
              ),
            ],
          ),
          surprise
              ? SlidingUpPanel(
                  onPanelOpened: () {
                    setState(() {
                      mapHeight = mapHeight / 3;
                    });
                  },
                  onPanelClosed: () {
                    setState(() {
                      mapHeight = mapHeight * 3;
                    });
                  },
                  panel: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(24.0)),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20.0,
                            color: Colors.grey,
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Hero(
                                  tag: "iconHero",
                                  child: Icon(
                                    Icons.phonelink_lock,
                                    size: 50,
                                  ),
                                ),
                              ),
                              Hero(
                                tag: "colHero",
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Text(
                                        "Redmi Note 5 Pro",
                                        style: TextStyle(
                                            fontSize: 22, color: Colors.black),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        "Disarmed • Static • Wifi",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black38),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          Container(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 14.0),
                            child: Container(
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(flex: 1,child: Icon(Icons.signal_wifi_4_bar,color: Colors.green,)),
                                    Expanded(flex: 3,child: Text(
                                      "Device is connected to wifi",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black54),
                                    ))

                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Divider(color: Colors.black38,),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 14.0),
                            child: Container(
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(flex: 1,child: Icon(Icons.lock,color: Colors.green,)),
                                    Expanded(flex: 3,child: Text(
                                      "Device is locked",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black54),
                                    ))

                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Divider(color: Colors.black38,),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 14.0),
                            child: Container(
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(flex: 1,child: Icon(Icons.location_on,color: Colors.green,)),
                                    Expanded(flex: 3,child: Text(
                                      "Last Location: 20.5937° N, 78.9629° E",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black54),
                                    ))

                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Divider(color: Colors.black38,),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 14.0),
                            child: Container(
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(flex: 1,child: Icon(Icons.battery_charging_full,color: Colors.green,)),
                                    Expanded(flex: 3,child: Text(
                                      "Battery is charging • 100%",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black54),
                                    ))

                                  ],
                                ),
                              ),
                            ),
                          )


                        ],
                      ),
                    ),
                  ),
                  renderPanelSheet: false,
                  collapsed: Container(
                    decoration:
                        BoxDecoration(color: color, borderRadius: radius),

                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Hero(
                                  tag: "iconHero",
                                  child: Icon(
                                    Icons.phonelink_lock,
                                    size: 50,
                                  ),
                                ),
                              ),
                            )),
                        Expanded(
                            flex: 4,
                            child: Container(
                              child: Hero(
                                tag: "colHero",
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Text(
                                        "Redmi Note 5 Pro",
                                        style: TextStyle(
                                            fontSize: 22, color: Colors.black),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        "Disarmed • Static • Wifi",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black38),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  borderRadius: radius,
                )
              : Container(),
        ],
      ),
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await places.getDetailsByPlaceId(p.placeId).then((result) {
        print(result.hasNoResults);
        print(result.errorMessage);
        print(result.result);
        print(result.isNotFound);
      });

      var placeId = p.placeId;
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;

      var address = await Geocoder.local.findAddressesFromQuery(p.description);
      goToDesiredLocation(LatLng(lat, lng));
      print(lat);
      print(lng);
    }
  }

  Future<void> _themall() async {
    final GoogleMapController controller = await _controller.future;
    final center = await getUserLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(center.latitude, center.longitude))));
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<void> goToDesiredLocation(LatLng latlng) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latlng, zoom: 14)));
  }

  void bottomSheet() {
    Builder(
      builder: (context) {
        return SlidingUpPanel(
          panel: Center(
            child: Text('Panel'),
          ),
        );
      },
    );
  }
}
