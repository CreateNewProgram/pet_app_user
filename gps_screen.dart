import 'dart:math' show cos, sqrt, pow, sin, atan2;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Location location = Location();
  LatLng? currentLocation;
  GoogleMapController? mapController;

  Set<Marker> markers1 = Set<Marker>();
  Set<Marker> markers2 = Set<Marker>();
  BitmapDescriptor? customIcon1;
  BitmapDescriptor? customIcon2;
  DateTime? lastAlertTime;

  @override
  void initState() {
    super.initState();
    _createCustomMarkerIcons();
    _getLocation();
    _locationChangeListener();
    _initializeMarkersFromFirestore();
    _initializeMarkersFromFirestore2();
  }

  void _createCustomMarkerIcons() async {
    customIcon1 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        'assets/images/대형견_남자.png'
    );

    customIcon2 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        'assets/images/소형견_여자.png'
    );
  }

  Future<void> _initializeMarkersFromFirestore() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('Pet Location').get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
    in querySnapshot.docs) {
      double latitude = documentSnapshot['latitude'] as double;
      double longitude = documentSnapshot['longitude'] as double;
      String markerId = documentSnapshot.id;

      markers1.add(
        Marker(
          markerId: MarkerId(markerId),
          position: LatLng(latitude, longitude),
          icon: customIcon1 ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: '나의 펫'),
        ),
      );
      setState(() {});
    }
  }

  Future<void> _initializeMarkersFromFirestore2() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('pet Location2').get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
    in querySnapshot.docs) {
      double latitude = documentSnapshot['latitude'] as double;
      double longitude = documentSnapshot['longitude'] as double;
      String markerId = documentSnapshot.id;

      markers2.add(
        Marker(
          markerId: MarkerId(markerId),
          position: LatLng(latitude, longitude),
          icon: customIcon2 ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: '대형견'),
        ),
      );
      setState(() {});
    }
  }

  void _locationChangeListener() {
    location.onLocationChanged.listen((LocationData currentLocationData) {
      if (currentLocationData.latitude != null &&
          currentLocationData.longitude != null) {
        setState(() {
          currentLocation = LatLng(
            currentLocationData.latitude!,
            currentLocationData.longitude!,
          );
          _updateCameraPosition(currentLocation!);
          _checkDistance();
        });
      }
    });
  }

  void _getLocation() async {
    try {
      var userLocation = await location.getLocation();
      if (userLocation.latitude != null && userLocation.longitude != null) {
        setState(() {
          currentLocation = LatLng(
            userLocation.latitude!,
            userLocation.longitude!,
          );
          _updateCameraPosition(currentLocation!);
        });
      }
    } catch (e) {
      print("오류 발생: $e");
    }
  }

  void _updateCameraPosition(LatLng newPosition) {
    mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentLocation != null) {
      _updateCameraPosition(currentLocation!);
    }
  }

  // 추가: 일정 범위를 체크하여 경고 메시지 표시
  void _checkDistance() {
    // 펫1의 위치와 사용자의 현재 위치 간의 거리 체크
    for (Marker marker in markers1) {
      double distanceFromUser = _calculateDistance(
        currentLocation!.latitude,
        currentLocation!.longitude,
        marker.position.latitude,
        marker.position.longitude,
      );

      // 사용자가 일정 거리(예: 200미터)를 벗어났을 때 경고
      if (distanceFromUser > 200) {
        if (lastAlertTime == null || DateTime.now().difference(lastAlertTime!).inMinutes >= 1) {
          lastAlertTime = DateTime.now();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('경고'),
                content: Text('일정 범위를 벗어났습니다!'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('확인'),
                  ),
                ],
              );
            },
          );
        }
      }
    }

    // 펫1과 대형견(펫2) 사이의 거리 체크
    for (Marker pet1Marker in markers1) {
      for (Marker bigDogMarker in markers2) {
        double distanceBetweenPets = _calculateDistance(
          pet1Marker.position.latitude,
          pet1Marker.position.longitude,
          bigDogMarker.position.latitude,
          bigDogMarker.position.longitude,
        );

        if (distanceBetweenPets <= 10) {
          if (lastAlertTime == null || DateTime.now().difference(lastAlertTime!).inMinutes >= 1) {
            lastAlertTime = DateTime.now();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('경고'),
                  content: Text('대형견이 근처에 있습니다!'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('확인'),
                    ),
                  ],
                );
              },
            );
            break; // 추가된 경고 메시지가 표시된 후 다른 마커에 대한 검사를 중단
          }
        }
      }
    }
  }

  // 추가: 두 지점 간의 거리 계산
  double _calculateDistance(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
      ) {
    const double pi = 3.1415926535897932;
    const double earthRadius = 6371000.0;

    double dLat = (endLatitude - startLatitude) * pi / 180.0;
    double dLon = (endLongitude - startLongitude) * pi / 180.0;

    double a = pow(sin(dLat / 2), 2) +
        cos(startLatitude * pi / 180.0) * cos(endLatitude * pi / 180.0) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('우리들의 애완동물 위치'),
      ),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: currentLocation!,
          zoom: 15.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: markers1.union(markers2),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MapScreen(),
  ));
}