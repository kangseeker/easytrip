// lib/widgets/trip_map.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/trip_location.dart';  // 모델을 쓰지 않을 거면 List<Map> 그대로 받아도 OK
import 'dart:math' as math;


class LatLngBoundsBuilder {
  double? _north, _south, _east, _west;

  void include(LatLng p) {
    _north = (_north == null) ? p.latitude  : math.max(_north!, p.latitude);
    _south = (_south == null) ? p.latitude  : math.min(_south!, p.latitude);
    _east  = (_east  == null) ? p.longitude : math.max(_east!,  p.longitude);
    _west  = (_west  == null) ? p.longitude : math.min(_west!,  p.longitude);
  }

  LatLngBounds build() => LatLngBounds(
    southwest: LatLng(_south!, _west!),
    northeast: LatLng(_north!, _east!),
  );
}

class TripMap extends StatefulWidget {
  final List<TripLocation> locations;

  const TripMap({super.key, required this.locations});

  @override
  State<TripMap> createState() => _TripMapState();
}

class _TripMapState extends State<TripMap> {
  final _dayColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLngBounds? _bounds;

  @override
  void initState() {
    super.initState();
    _buildMapData();
  }

  @override
  void didUpdateWidget(covariant TripMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locations != widget.locations) _buildMapData();
  }

  void _buildMapData() {
    final markers = <Marker>{};
    final polylines = <Polyline>{};
    final boundsBuilder = LatLngBoundsBuilder();

    var day = 0;
    var path = <LatLng>[];

    for (var i = 0; i < widget.locations.length; i++) {
      final loc = widget.locations[i];
      final latLng = LatLng(loc.lat, loc.lng);

      // ---------- 마커 ----------
      markers.add(
        Marker(
          markerId: MarkerId('m$i'),
          position: latLng,
          infoWindow: InfoWindow(title: '${i + 1}. ${loc.name}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            HSVColor.fromColor(_dayColors[day % _dayColors.length]).hue,
          ),
        ),
      );

      // ---------- 경로 ----------
      boundsBuilder.include(latLng);
      path.add(latLng);

      final boundary = (i + 1) % 3 == 0 || i == widget.locations.length - 1;
      if (boundary) {
        polylines.add(
          Polyline(
            polylineId: PolylineId('p$day'),
            color: _dayColors[day % _dayColors.length],
            width: 4,
            points: List.unmodifiable(path),
          ),
        );
        path = [];
        day++;
      }
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
      _bounds = boundsBuilder.build();
    });
  }

  GoogleMapController? _ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.5665, 126.9779),
          zoom: 5,
        ),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (c) {
          _ctrl = c;
          if (_bounds != null) {
            c.animateCamera(CameraUpdate.newLatLngBounds(_bounds!, 50));
          }
        },
      ),
    );
  }
}
