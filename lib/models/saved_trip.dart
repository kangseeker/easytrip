import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter/material.dart';
import '../screens/post_write_screen.dart';


class SavedTrip {
  final String plan;
  final DateTime savedAt;

  SavedTrip({required this.plan, required this.savedAt});

  factory SavedTrip.fromJson(Map<String, dynamic> json) => SavedTrip(
    plan: json['plan'],
    savedAt: DateTime.parse(json['createdAt']),
  );
}


class SavedTripListScreen extends StatefulWidget {
  const SavedTripListScreen({super.key});

  @override
  State<SavedTripListScreen> createState() => _SavedTripListScreenState();
}

class _SavedTripListScreenState extends State<SavedTripListScreen> {
  late Future<List<SavedTrip>> futureTrips;

  @override
  void initState() {
    super.initState();
    futureTrips = fetchSavedTrips();
  }

  Future<List<SavedTrip>> fetchSavedTrips() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final uri = Uri.parse('${dotenv.env['API_URL']}/api/trips?userId=${user.uid}');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => SavedTrip.fromJson(e)).toList();
    } else {
      throw Exception('일정 불러오기 실패: ${res.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 저장된 일정')),
      body: FutureBuilder<List<SavedTrip>>(
        future: futureTrips,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('저장된 일정이 없습니다.'));
          }

          final trips = snapshot.data!;
          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return ListTile(
                title: Text(
                  '저장 날짜: ${trip.savedAt.year}.${trip.savedAt.month}.${trip.savedAt.day}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  trip.plan.length > 50 ? '${trip.plan.substring(0, 50)}...' : trip.plan,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SavedTripDetailScreen(tripPlan: trip.plan),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// ✅ TripResult 스타일 상세 화면 + 버튼 2개
class SavedTripDetailScreen extends StatelessWidget {
  final String tripPlan;

  const SavedTripDetailScreen({super.key, required this.tripPlan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('저장된 일정 보기')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _buildTripSections(tripPlan),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('뒤로가기'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('게시물 작성하기'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostWriteScreen(attachedPlan: tripPlan),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
                TextSpan(text: parts.skip(1).join(':').trim()),
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
