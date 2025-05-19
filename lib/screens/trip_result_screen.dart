import 'package:http/http.dart' as http;             // 서버 통신용
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경변수용
import 'package:firebase_auth/firebase_auth.dart';   // 사용자 uid 추출용
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/trip_location.dart';
import '../widgets/trip_map.dart';
import '../models/saved_trip.dart';
import 'post_write_screen.dart';

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
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: _buildTripSections(tripPlan),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("일정 다시 생성"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('로그인이 필요합니다.')),
                                  );
                                  return;
                                }

                                final response = await http.post(
                                  Uri.parse('${dotenv.env['API_URL']}/api/trips'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    "userId": user.uid,
                                    "plan": tripPlan,
                                    "locations": locations.map((e) => e.toJson()).toList(),
                                  }),
                                );

                                if (response.statusCode == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('여행 일정이 저장되었습니다!')),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SavedTripListScreen(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('저장 실패: ${response.statusCode}')),
                                  );
                                }
                              },
                              child: const Text("일정 저장하기"),
                            ),
                          ),

                        ],
                      ),
                    )
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
      final line = rawLine.trimLeft();

      if (line.isEmpty) continue;

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
      } else if (line.startsWith('###')) {
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
      } else if (line.startsWith('점심:') || line.startsWith('저녁:') || line.startsWith('숙소추천:')) {
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
      } else {
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
