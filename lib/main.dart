import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:flutter_google_places/flutter_google_places.dart';
//import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as LocationManager;
import "package:google_maps_webservice/places.dart";

final String kGoogleApiKey = "AIzaSyCIEINhIghKi-l9mg9NxUX4YANayVxs4LM";
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

  // GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  String query = 'India Gate';
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 0.0, target: LatLng(26.8439, 75.5652), tilt: 0.0, zoom: 12.0);

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
        await places.searchByText(search).then((value) async{
      print(value.results.length);
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      bearing: 0.0, 
      target: LatLng(value.results[0].geometry.location.lat,value.results[0].geometry.location.lng),
      tilt: 0.0, 
      zoom: 7.0)
      ));

      _add(value.results[0].name, value.results[0].geometry.location);
  
    });
  }

  TextEditingController _searchcontroller;
  bool entered = false;
  String title = 'Welcome';

void _add(String mid,Location m) {
    var markerIdVal = mid;
     final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        m.lat,m.lng
      ),
      infoWindow: InfoWindow(title: markerIdVal),
      onTap: () {
      },
    );
      setState(() {
        markers[markerId] = marker;
      });
}
  @override
  Widget build(BuildContext context) {
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
            entered = !entered;
            setState(() {});
          },
        ),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: Set<Marker>.of(markers.values)
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To MUJ!'),
        icon: Icon(Icons.school),
      ),
    );
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

  Future<void> _goToDesiredLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
