import 'dart:math' show cos, sqrt, pow;
import 'dart:math' show cos, sqrt, pow, sin, atan2;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Location location = Location();
  LatLng? currentLocation;
  GoogleMapController? mapController;

  Set<Marker> markers = Set<Marker>();
  BitmapDescriptor? customIcon1;
  BitmapDescriptor? customIcon2;

  @override
  void initState() {
    super.initState();
    _createCustomMarkerIcons();
    _getLocation();
    _locationChangeListener();
  }

  void _createCustomMarkerIcons() async {
    customIcon1 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        'assets/images/Big_dog64.png' // 여기에 원하는 이미지파일 추가
    );

    customIcon2 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(),
        'assets/images/Small_dog64.png' // 여기에 원하는 이미지파일 추가
    );

    _initializeMarkers();
  }
  void _initializeMarkers() {
    markers.add(
      Marker(
        markerId: MarkerId('marker1'),
        position: LatLng(36.106681, 128.425068),
        icon: customIcon1 ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: '대형견'),
      ),
    );

    markers.add(
      Marker(
        markerId: MarkerId('marker2'),
        position: LatLng(36.106889,  128.425063),
        icon: customIcon2 ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: '소형견'),
      ),
    );
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

          // 추가: 일정 범위를 체크하여 경고 메시지 표시
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
          _addMarkers();
        });
      }
    } catch (e) {
      print("오류 발생: $e");
    }
  }

  void _updateCameraPosition(LatLng newPosition) {
    mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
  }

  void _addMarkers() {
    markers.add(
      Marker(
        markerId: MarkerId('test'),
        position: LatLng(36.107173, 128.424560),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: 'Pet'),
      ),
    );

    markers.add(
      Marker(
        markerId: MarkerId('test1'),
        position: LatLng(36.106658,  128.424149),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'Other Pet'),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentLocation != null) {
      _updateCameraPosition(currentLocation!);
    }
  }

  // 추가: 일정 범위를 체크하여 경고 메시지 표시
  void _checkDistance() {
    for (Marker marker in markers) {
      double distanceInMeters = _calculateDistance(
        currentLocation!.latitude,
        currentLocation!.longitude,
        marker.position.latitude,
        marker.position.longitude,
      );

      // 일정 거리 이상 벗어날 때 경고 메시지 표시
      if (distanceInMeters > 100) {//여기서 거리 조정 가능
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

  // 추가: 두 지점 간의 거리 계산
  double _calculateDistance(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
      ) {
    const double pi = 3.1415926535897932;
    const double earthRadius = 6371000.0; // 지구 반지름 (미터)

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
        markers: markers,
      ),
    );
  }
}
void main() {
  runApp(MaterialApp(
    home: MapScreen(),
  ));
}
