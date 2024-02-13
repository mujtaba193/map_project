import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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

  final Marker googleMarker1 = Marker(
      markerId: MarkerId('_kGooglePlex1'),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(60.003750, 30.287770),
      infoWindow: InfoWindow(title: 'dormitory') //37.431542, -122.095130
      );
  final Marker googleMarkerOrigin = Marker(
      markerId: MarkerId('_path'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: LatLng(37.382890, -122.045861),
      infoWindow: InfoWindow(title: 'dormitory') //37.431542, -122.095130
      );

  final Marker googleMarkerDestination = Marker(
      markerId: MarkerId('_path'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      position: LatLng(37.374969, -121.908777),
      infoWindow: InfoWindow(title: 'dormitory') //37.431542, -122.095130
      );
  final Marker googleMarker2 = Marker(
      markerId: MarkerId('_kGooglePlex2'),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(60.028248, 30.335376),
      infoWindow: InfoWindow(title: 'work') //37.431542, -122.095130
      );
  late bool servicesEnabled;
  late PermissionStatus permission;
  double? lat;
  double? longt;
  late List<UsersMarkers> usersLocationMarkers;
  List<Marker>? googleMarkerList;

  @override
  void initState() {
    getCurrentLucation();
    lat;
    longt;
    iconPic;
    loadjson();

    super.initState();
  }

  Marker? googleMarker;

  Future loadjson() async {
    var jsondata = await DefaultAssetBundle.of(context)
        .loadString('assets/users_location.json');
    List<dynamic> userLocation = jsonDecode(jsondata);
    usersLocationMarkers =
        userLocation.map((e) => UsersMarkers.fromJson(e)).toList();

    googleMarkerList = usersLocationMarkers
        .map((e) => Marker(
            markerId: MarkerId(e.username),
            icon: BitmapDescriptor.defaultMarker,
            position: LatLng(e.latitude, e.longitude),
            infoWindow: InfoWindow(title: e.username) //37.431542, -122.095130
            ))
        .toList();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(12, 12)), 'lib/images/chik.jpeg')
        .then((value) => iconPic = value);
    googleMarker = Marker(
        markerId: MarkerId('kk'),
        icon: iconPic,
        position: LatLng(59.971366, 30.321330),
        infoWindow: InfoWindow(title: 'leti') //37.431542, -122.095130
        );
  }

  Marker? liveMarker;

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

  /*Future<Map<String, dynamic>> getPath(liveMarker, googleMarker1) async {
    final String url =
        'http://maps.googleapis.com/maps/api/directions/json?origin=$liveMarker&destination=$googleMarkerpath&key=AIzaSyD_EXNQjjvmLVJE37nA8zVQdTPRDcQStYE';
    var respo = await http.get(Uri.parse(url));
    var json = jsonDecode(respo.body);
    var result = {
      'bounds_ne': json['routes'][0]['bounds']['northeast'],
      'bounds_sw': json['routes'][0]['bounds']['northeast'],
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end_location': json['routes'][0]['legs'][0]['end_location'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
    };
    print('hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh$result');
    return result;
  }*/
  Map<PolylineId, Polyline> _mapPolylines = {};
  int _polylineIdCounter = 1;

  void _add() {
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
  }

  List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];
    points.add(LatLng(37.382890, -122.045861));
    points.add(LatLng(37.374969, -121.908777));

    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getCurrentLucation();
          loadjson();
        },
        child: FutureBuilder(
            future: loadjson(),
            builder: (context, snapshot) {
              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: 45,
                        child: TextFormField(
                          controller: searchController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          {
                            GoogleMapController controller =
                                await _controller.future;
                            await controller.animateCamera(
                                CameraUpdate.newCameraPosition(CameraPosition(
                                    bearing: 192.8334901395799,
                                    target: LatLng(lat!, longt!),
                                    tilt: 59.440717697143555,
                                    zoom: 10)));
                          }
                        },
                        icon: Icon(Icons.search),
                      )
                    ],
                  ),
                  Expanded(
                    child: GoogleMap(
                      mapType: MapType.hybrid,
                      markers: {
                        ...googleMarkerList ?? [googleMarker1],
                        googleMarker ?? googleMarker1,
                        googleMarker1,
                        googleMarkerOrigin,
                        googleMarkerDestination,
                        googleMarker2,
                        liveMarker ?? googleMarker1,
                      },
                      initialCameraPosition: CameraPosition(
                          target: LatLng(lat ?? 55.78619841559829,
                              longt ?? 37.550435740210204),
                          zoom: 12.0),
                      polylines: Set<Polyline>.of(_mapPolylines.values),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),
                ],
              );
            }),
      ),

      /*CameraPosition(
                        target: LatLng(currentLocation!.latitude!,
                            currentLocation!.longitude!),
                        zoom: 10.0),*/
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
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
                markerId: MarkerId('_Toby'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueYellow),
                position: LatLng(lat!, longt!),
                infoWindow: InfoWindow(title: 'work'));
            //getPath(liveMarker, googleMarker1);
            _add();
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
