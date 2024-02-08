import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final TextEditingController searchController = TextEditingController();

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(59.966694, 30.305694),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  final Marker googleMarker = Marker(
      markerId: MarkerId('kk'),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(59.971366, 30.321330),
      infoWindow: InfoWindow(title: 'leti') //37.431542, -122.095130
      );
  final Marker googleMarker1 = Marker(
      markerId: MarkerId('_kGooglePlex'),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(60.003750, 30.287770),
      infoWindow: InfoWindow(title: 'dormitory') //37.431542, -122.095130
      );
  final Marker googleMarker2 = Marker(
      markerId: MarkerId('_kGooglePlex'),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(60.028248, 30.335376),
      infoWindow: InfoWindow(title: 'work') //37.431542, -122.095130
      );
  late bool servicesEnabled;
  late PermissionStatus permission;
  double? lat;
  double? longt;

  @override
  void initState() {
    getCurrentLucation();
    lat;
    longt;

    super.initState();
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
        },
        child: FutureBuilder(
            future: getCurrentLucation().timeout(Duration.zero),
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

                          liveMarker = Marker(
                              markerId: MarkerId('_kGooglePlex'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueYellow),
                              position: LatLng(lat!, longt!),
                              infoWindow: InfoWindow(
                                  title: 'work') //37.431542, -122.095130
                              );
                        },
                        icon: Icon(Icons.search),
                      )
                    ],
                  ),
                  Expanded(
                    child: GoogleMap(
                      mapType: MapType.hybrid,
                      markers: {
                        googleMarker,
                        googleMarker1,
                        googleMarker2,
                        liveMarker ?? googleMarker,
                      },
                      initialCameraPosition: CameraPosition(
                          target: LatLng(lat ?? 55.78619841559829,
                              longt ?? 37.550435740210204),
                          zoom: 12.0),
                      polylines: {
                        Polyline(polylineId: PolylineId("rout"))
                      }, // 55.78619841559829, 37.550435740210204
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
          onPressed: () async {
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
                markerId: MarkerId('_kGooglePlex'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueYellow),
                position: LatLng(lat!, longt!),
                infoWindow: InfoWindow(title: 'work') //37.431542, -122.095130
                );
          },
          child: const Icon(Icons.navigation),
        ),
      ),
    );
  }
}
