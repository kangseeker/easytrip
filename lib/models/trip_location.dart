// lib/models/trip_location.dart

class TripLocation {
  final String name;
  final double lat;
  final double lng;

  TripLocation({
    required this.name,
    required this.lat,
    required this.lng,
  });

  // JSON → 객체
  factory TripLocation.fromJson(Map<String, dynamic> j) => TripLocation(
    name: j['name'] as String,
    lat: j['lat'] as double,
    lng: j['lng'] as double,
  );

  // 객체 → JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'lat': lat,
    'lng': lng,
  };
}