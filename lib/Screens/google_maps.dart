import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sih_login/Services/place_services.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    home: PoliceScreen(),
  ));
}

class PoliceScreen extends StatefulWidget {
  const PoliceScreen({Key? key}) : super(key: key);

  @override
  State<PoliceScreen> createState() => _PoliceScreenState();
}

class _PoliceScreenState extends State<PoliceScreen> {
  late GoogleMapController googleMapController;
  List<Marker> _marker = [];

  var place = PlaceServices();

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   //_marker.addAll(_list);
  // }

  _setNearMarker(LatLng point, String name, String vicinity) {
    final Marker marker = Marker(
      markerId: MarkerId(name),
      draggable: false,
      infoWindow: InfoWindow(title: name, snippet: vicinity),
      position: LatLng(point.latitude, point.longitude),
    );
    setState(() {
      _marker.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Nearest Police Stations"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        height: screenHeight - 150.0,
        width: screenWidth,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition:
              const CameraPosition(target: LatLng(27, 28), zoom: 16),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: Set.of(_marker),
          onMapCreated: (GoogleMapController controller) async {
            googleMapController = controller;
            Position position = await place.getLocatin();
            var lat = position.latitude;
            var lng = position.longitude;
            googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: LatLng(lat, lng), zoom: 15.5)));
            var placesResults = await place.getPlaceDetails();
            List<dynamic> placesWithin = placesResults['results'] as List;
            print(placesWithin);
            placesWithin.forEach((element) {
              _setNearMarker(
                LatLng(element['geometry']['location']['lat'],
                    element['geometry']['location']['lng']),
                element['name'],
                element['vicinity'],
              );
            });
          },
        ),
      ),
    );
  }
}
