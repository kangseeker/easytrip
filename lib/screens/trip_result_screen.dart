import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripResultScreen extends StatelessWidget {
  final String tripPlan;

  const TripResultScreen({super.key, required this.tripPlan});

  @override
  Widget build(BuildContext context) {
    const CameraPosition initialPosition = CameraPosition(
      target: LatLng(37.5665, 126.9780),
      zoom: 12,
    );

    final Marker marker = Marker(
      markerId: MarkerId('start'),
      position: LatLng(37.5665, 126.9780),
      infoWindow: InfoWindow(title: '출발지'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('AI 여행 일정 결과')),
      body: Stack(
        children: [
          // 1. 지도는 전체 배경
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: initialPosition,
              markers: {marker},
              onMapCreated: (GoogleMapController controller) {},
            ),
          ),

          // 2. 텍스트 바텀시트 (앞단에 올림)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 250,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  tripPlan,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
