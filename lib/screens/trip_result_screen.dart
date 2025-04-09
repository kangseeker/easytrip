import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripResultScreen extends StatelessWidget {
  final String tripPlan;

  const TripResultScreen({super.key, required this.tripPlan});

  @override
  Widget build(BuildContext context) {
    const CameraPosition initialPosition = CameraPosition(
      target: LatLng(37.5665, 126.9780), // 서울시청 위치
      zoom: 12,
    );

    final Marker marker = Marker(
      markerId: MarkerId('start'),
      position: LatLng(37.5665, 126.9780),
      infoWindow: InfoWindow(title: '출발지'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('AI 여행 일정 결과')),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: GoogleMap(
              initialCameraPosition: initialPosition,
              markers: {marker},
              onMapCreated: (GoogleMapController controller) {},
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                tripPlan,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
