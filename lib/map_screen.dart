import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map_project/user_marker_model.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  BitmapDescriptor iconPic = BitmapDescriptor.defaultMarker;

  final TextEditingController searchController = TextEditingController();

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(59.966694, 30.305694),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  final Marker googleMarker1 = const Marker(
      markerId: MarkerId('_kGooglePlex1'),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(60.003750, 30.287770),
      infoWindow: InfoWindow(title: 'dormitory') //37.431542, -122.095130
      );
  /*final Marker googleMarkerOrigin = Marker(
      markerId: MarkerId('_kghg'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: LatLng(37.382890, -122.045861),
      infoWindow: InfoWindow(title: 'blue mark') //37.431542, -122.095130
      );*/

  final Marker googleMarker2 = const Marker(
      markerId: MarkerId('_kGooglePlex2'),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(60.028248, 30.335376),
      infoWindow: InfoWindow(title: 'work'));
  Marker tobyMarker = Marker(
    markerId: MarkerId('tm123'),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(37.324684, -121.969696),
    infoWindow: InfoWindow(title: 'toby her'),
    onTap: () {},
  );
  Marker googleMarker = const Marker(
      markerId: MarkerId('kk'),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(59.971366, 30.321330),
      infoWindow: InfoWindow(title: 'leti'));

  Map<PolylineId, Polyline> _mapPolylines = {};
  int _polylineIdCounter = 1;

  late bool servicesEnabled;
  late PermissionStatus permission;
  double? lat;
  double? longt;
  late List<UsersMarkers> usersLocationMarkers;
  List<Marker>? googleMarkerList;
  Color? routColor;
  Marker? liveMarker;
  TravelMode? travelMode;
  List<Marker> markers = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    getCurrentLucation();
    lat;
    longt;
    iconPic;
    loadjson();

    travelMode;

    super.initState();
  }

  // Marker? googleMarker;

  Future loadjson() async {
    var jsondata = await DefaultAssetBundle.of(context)
        .loadString('assets/users_location.json');
    List<dynamic> userLocation = jsonDecode(jsondata);
    usersLocationMarkers =
        userLocation.map((e) => UsersMarkers.fromJson(e)).toList();

    googleMarkerList = usersLocationMarkers
        .map(
          (e) => Marker(
              markerId: MarkerId(e.username),
              icon: BitmapDescriptor.defaultMarker,
              position: LatLng(e.latitude, e.longitude),
              infoWindow: InfoWindow(title: e.username) //37.431542, -122.095130
              ),
        )
        .toList();
    /* BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(12, 12)), 'lib/images/chik.jpeg')
        .then((value) => iconPic = value);*/
  }

  Future<LocationData> getCurrentLucation() async {
    Location location = Location();
    LocationData locationData;

    servicesEnabled = await location.serviceEnabled();
    if (!servicesEnabled) {
      servicesEnabled = await location.requestService();
      if (!servicesEnabled) {}
    }
    permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {}
    }
    locationData = await location.getLocation();

    setState(() {
      lat = locationData.latitude!;
      longt = locationData.longitude!;
    });
    return locationData;
  }

  /*void _add() {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.red,
      width: 5,
      points: _createPoints(),
    );

    setState(() {
      _mapPolylines[polylineId] = polyline;
    });
  }*/

  /* List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];
    points.add(LatLng(37.382890, -122.045861));
    points.add(LatLng(37.374969, -121.908777));

    return points;
  }*/

//******************************************************

  addMarker(latLng, newSetState) {
    markers.add(liveMarker!);
    if (tobyMarker.markerId.value == 'tm123') {
      markers.add(Marker(
          consumeTapEvents: true,
          markerId: MarkerId(latLng.toString()),
          icon: BitmapDescriptor.defaultMarker,
          position: latLng,
// We adding onTap paramater for when click marker, remove from map
          onTap: () {
            getDirections(markers, newSetState);

            newSetState(() {});
          }));
    }

    markers.add(Marker(
        consumeTapEvents: true,
        markerId: MarkerId(latLng.toString()),
        icon: BitmapDescriptor.defaultMarker,
        position: latLng,
// We adding onTap paramater for when click marker, remove from map
        onTap: () {
          markers.removeWhere(
              (element) => element.markerId == MarkerId(latLng.toString()));
// markers length must be greater than 1 because polyline needs two // points
          if (markers.length > 1) {
            getDirections(markers, newSetState);
          }
// When we added markers then removed all, this time polylines seems //in map because of we should clear polylines
          else {
            polylines.clear();
          }

// newState parameter of function, we are openin map in alertDialog, // contexts are different in page and alert dialog because of we use // different setState
          newSetState(() {});
        }));
    // if (markers.length > 1)
    {
      getDirections(markers, newSetState);
    }
    setState(() {});
    newSetState(() {});
  }

  getDirections(googleMarker1, newSetState) async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyD_EXNQjjvmLVJE37nA8zVQdTPRDcQStYE',
      PointLatLng(markers.first.position.latitude,
          markers.first.position.longitude), //first added marker
      PointLatLng(
          markers.last.position.latitude, markers.last.position.longitude),
      travelMode: travelMode ?? TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {});
    } else {
      print(result.errorMessage);
    }

    setState(() {});
    //newSetState(() {});

    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: routColor ?? Colors.blue,
      points: polylineCoordinates,
      width: 4,
    );

    setState(() {
      polylines[id] = polyline;
    });
    //newSetState(() {});
  }

  drwPath(googleMarker1, newSetState) {
    getDirections(googleMarker1, newSetState);
    setState(() {});
    //newSetState(() {});
  }
  //********************************************************* */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getCurrentLucation();
          loadjson();
        },
        child: FutureBuilder(
            future: loadjson(),
            builder: (context, snap) {
              return StatefulBuilder(builder: (context, newSetState) {
                return Column(
                  children: [
                    Expanded(
                      child: GoogleMap(
                        mapType: MapType.hybrid,
                        mapToolbarEnabled: true,
                        markers: {
                          tobyMarker,
                          ...markers,
                          ...googleMarkerList ?? [googleMarker1],
                          googleMarker ?? googleMarker1,
                          googleMarker1,
                          googleMarker2,
                          liveMarker ?? googleMarker1,
                        },
                        initialCameraPosition: CameraPosition(
                            target:
                                LatLng(lat ?? 59.998702, longt ?? 30.333615),
                            zoom: 12.0),
                        polylines: Set<Polyline>.of(polylines.values),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onTap: (newLatLng) async {
                          await addMarker(newLatLng, newSetState);
                          setState(() {});

                          newSetState(() {});
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            newSetState(() {});
                            setState(() {});
                            travelMode = TravelMode.walking;
                            routColor = Colors.yellow;
                            drwPath(googleMarker1, newSetState);
                          },
                          icon: const Icon(Icons.directions_walk),
                        ),
                        IconButton(
                          onPressed: () async {
                            newSetState(() {});
                            setState(() {});
                            travelMode = TravelMode.transit;
                            routColor = Colors.green;
                            drwPath(googleMarker1, newSetState);
                          },
                          icon: const Icon(Icons.bus_alert_rounded),
                        ),
                        IconButton(
                          onPressed: () async {
                            newSetState(() {});
                            setState(() {});
                            travelMode = TravelMode.driving;
                            routColor = Colors.blue;
                            drwPath(googleMarker1, newSetState);
                          },
                          icon: const Icon(Icons.local_taxi),
                        )
                      ],
                    ),
                  ],
                );
              });
            }),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 170),
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () async {
            setState(() {});
            {
              GoogleMapController controller = await _controller.future;
              await controller.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      bearing: 192.8334901395799,
                      target: LatLng(lat!, longt!),
                      tilt: 59.440717697143555,
                      zoom: 10)));
            }

            liveMarker = Marker(
                markerId: const MarkerId('_liveid'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueYellow),
                position: LatLng(lat!, longt!),
                infoWindow: const InfoWindow(title: 'Live location'));
            //getPath(liveMarker, googleMarker1);
            // _add();
          },
          child: const Icon(
            Icons.navigation,
            size: 40,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
