import 'package:flutter/material.dart';
import '../models/trip_location.dart';
import '../widgets/trip_map.dart';

class TripResultScreen extends StatelessWidget {
  final String tripPlan;
  final List<TripLocation> locations;

  const TripResultScreen({
    super.key,
    required this.tripPlan,
    required this.locations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AI 여행 추천'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: TripMap(locations: locations),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.25,
            maxChildSize: 0.85,
            expand: true,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    // 핸들바
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    // 일정 내용
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: _buildTripSections(tripPlan),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTripSections(String plan) {
    final lines = plan.split('\n');
    final widgets = <Widget>[];

    for (final rawLine in lines) {
      final line = rawLine.trimLeft(); // ⬅️ 공백 제거

      if (line.isEmpty) continue;

      // Day 구간
      if (line.startsWith('## Day')) {
        widgets.addAll([
          const Divider(color: Colors.grey, thickness: 0.6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              line.replaceFirst('## ', ''),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ]);
      }

      // 오전 / 오후
      else if (line.startsWith('###')) {
        widgets.addAll([
          const Divider(color: Colors.grey, thickness: 0.3),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              line.replaceFirst('### ', ''),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ]);
      }

      // 점심 / 저녁 / 숙소추천
      else if (line.startsWith('점심:') || line.startsWith('저녁:') || line.startsWith('숙소추천:')) {
        final parts = line.split(':');
        widgets.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(6),
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14.5, color: Colors.black87, height: 1.6),
              children: [
                TextSpan(
                  text: '${parts.first.trim()}: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: parts.skip(1).join(':').trim(),
                ),
              ],
            ),
          ),
        ));
      }

      // 일반 텍스트
      else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 8),
          child: Text(
            line,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ));
      }
    }

    return widgets;
  }
}
