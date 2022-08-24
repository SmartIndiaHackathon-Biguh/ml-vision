import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:url_launcher/url_launcher.dart';

class PlacesService {
  final key = 'AIzaSyDbP3dyEbPR3u6mtK33WdtdhynmSYG29FI';

  static String place = 'police';

  Future<List<Place>> getPlaces(double lat, double lng) async {
    Uri uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&type=$place&rankby=distance&key=$key');
    var response = await http.get(uri);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;
    return jsonResults.map((place) => Place.fromJson(place)).toList();
  }
}

class GeoLocatorService {
  final geolocator = Geolocator();
  //*older code
  // Future<Position> getLocation() async {
  //   return await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //       locationPermissionLevel: GeolocationPermission.location);
  // }

  // Future<double> getDistance(double startLatitude, double startLongitude,
  //     double endLatitude, double endLongitude) async {
  //   return await geolocator.distanceBetween(
  //       startLatitude, startLongitude, endLatitude, endLongitude);
  // }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<double> getDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) async {
    return await Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }
}

class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  Location.fromJson(Map<dynamic, dynamic> parsedJson)
      : lat = parsedJson['lat'],
        lng = parsedJson['lng'];
}

class Geometry {
  final Location location;

  Geometry({required this.location});

  Geometry.fromJson(Map<dynamic, dynamic> parsedJson)
      : location = Location.fromJson(parsedJson['location']);
}

class Place {
  final String name;
  final double rating;
  final int userRatingCount;
  final String vicinity;
  final Geometry geometry;

  Place(
      {required this.geometry,
      required this.name,
      required this.rating,
      required this.userRatingCount,
      required this.vicinity});

  Place.fromJson(Map<dynamic, dynamic> parsedJson)
      : name = parsedJson['name'],
        rating = (parsedJson['rating'] != null)
            ? parsedJson['rating'].toDouble()
            : null,
        userRatingCount = (parsedJson['user_ratings_total'] != null)
            ? parsedJson['user_ratings_total']
            : null,
        vicinity = parsedJson['vicinity'],
        geometry = Geometry.fromJson(parsedJson['geometry']);
}

class MarkerService {
  List<Marker> getMarkers(List<Place> places) {
    //var markers = List<Marker>();
    List<Marker> markers = [];

    places.forEach((place) {
      Marker marker = Marker(
          markerId: MarkerId(place.name),
          draggable: false,
          // icon: place.icon,
          infoWindow: InfoWindow(title: place.name, snippet: place.vicinity),
          position:
              LatLng(place.geometry.location.lat, place.geometry.location.lng));

      markers.add(marker);
    });

    return markers;
  }
}

class Search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentPosition = Provider.of<Position>(context);
    final placesProvider = Provider.of<Future<List<Place>>>(context);
    final geoService = GeoLocatorService();
    final markerService = MarkerService();

    return FutureProvider(
      create: (context) => placesProvider,
      initialData: [],
      child: Scaffold(
        body: (currentPosition != null)
            ? Consumer<List<Place>>(
                builder: (_, places, __) {
                  List<Marker> markers1 = [];
                  if ((places != null)) {
                    markers1 = markerService.getMarkers(places);
                  } else {
                    List<Marker> markers1 = [];
                  }
                  if ((places != null)) {
                    return Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: LatLng(currentPosition.latitude,
                                    currentPosition.longitude),
                                zoom: 16.0),
                            zoomGesturesEnabled: true,
                            markers: Set<Marker>.of(markers1),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: places.length,
                              itemBuilder: (context, index) {
                                return FutureProvider(
                                  create: (context) => geoService.getDistance(
                                      currentPosition.latitude,
                                      currentPosition.longitude,
                                      places[index].geometry.location.lat,
                                      places[index].geometry.location.lng),
                                  initialData: null,
                                  child: Card(
                                    child: ListTile(
                                      title: Text(places[index].name),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 3.0,
                                          ),
                                          (places[index].rating != null)
                                              ? Row(
                                                  children: <Widget>[
                                                    RatingBarIndicator(
                                                      rating:
                                                          places[index].rating,
                                                      itemBuilder: (context,
                                                              index) =>
                                                          Icon(Icons.star,
                                                              color:
                                                                  Colors.amber),
                                                      itemCount: 5,
                                                      itemSize: 10.0,
                                                      direction:
                                                          Axis.horizontal,
                                                    )
                                                  ],
                                                )
                                              : Row(),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Consumer<double>(
                                            builder: (context, meters, wiget) {
                                              return (meters != null)
                                                  ? Text(
                                                      '${places[index].vicinity} \u00b7 ${(meters / 1000).toStringAsFixed(1)} km')
                                                  : Container();
                                            },
                                          )
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.directions),
                                        color: Theme.of(context).primaryColor,
                                        onPressed: () {
                                          _launchMapsUrl(
                                              places[index]
                                                  .geometry
                                                  .location
                                                  .lat,
                                              places[index]
                                                  .geometry
                                                  .location
                                                  .lng);
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  void _launchMapsUrl(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class GoogleMapsScreen extends StatelessWidget {
  const GoogleMapsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final currentPosition = Provider.of<Position>(context);
    //final placesProvider = Provider.of<Future<List<Place>>>(context);
    //final geoService = GeoLocatorService();
    //final markerService = MarkerService();
    final locatorService = GeoLocatorService();
    final placesService = PlacesService();
    return MultiProvider(
      providers: [
        FutureProvider(
          create: (context) => locatorService.getLocation(),
          initialData: null,
        ),
        ProxyProvider<Position, Future<List<Place>>>(
          update: (context, position, places) async {
            Future<List<Place>> null1 = Future.value([]);
            // ignore: unnecessary_null_comparison
            if ((position != null)) {
              return placesService.getPlaces(
                  position.latitude, position.longitude);
            } else {
              return null1;            }
          },
        )
      ],
      child: MaterialApp(
        title: 'Nearby Police Stations',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Nearby Police Station"),
            backgroundColor: Colors.blue,
          ),
          body: Search(),
        ),
      ),
    );
  }
}
