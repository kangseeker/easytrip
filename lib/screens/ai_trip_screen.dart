import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_trip/screens/trip_result_screen.dart';

class AITripScreen extends StatefulWidget {
  const AITripScreen({super.key});

  @override
  State<AITripScreen> createState() => _AITripScreenState();
}

class _AITripScreenState extends State<AITripScreen> {
  final destinationController = TextEditingController();
  final daysController = TextEditingController();

  String? selectedPeopleType;
  String? selectedWalking;
  String? selectedTravelStyle;
  String? selectedActivity;

  String tripPlan = '';
  bool loading = false;
  int step = 1;

  Future<void> generateTrip() async {
    final uri = Uri.parse(dotenv.env['API_URL']!);
    setState(() => loading = true);

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'destination': destinationController.text,
          'days': daysController.text,
          'peopleType': selectedPeopleType,
          'walkingPreference': selectedWalking,
          'travelStyle': selectedTravelStyle,
          'activityStyle': selectedActivity,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['plan'];

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripResultScreen(tripPlan: result),
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('서버 오류'),
            content: Text('상태 코드: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('에러 발생'),
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 여행 추천')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Step $step of 3',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),

            // 1단계
            if (step == 1) ...[
              TextField(
                controller: destinationController,
                decoration: InputDecoration(
                  hintText: '어디로 여행을 떠나시나요?',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (destinationController.text.isNotEmpty) {
                    setState(() => step = 2);
                  }
                },
                child: const Text('다음'),
              ),
            ]

            // 2단계
            else if (step == 2) ...[
              TextField(
                controller: daysController,
                decoration: const InputDecoration(labelText: '여행 일수'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedPeopleType,
                items: ['연인', '가족', '친구', '혼자']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedPeopleType = val),
                decoration: const InputDecoration(labelText: '동행 유형'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => setState(() => step = 1),
                    child: const Text('이전'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (daysController.text.isNotEmpty &&
                          selectedPeopleType != null) {
                        setState(() => step = 3);
                      }
                    },
                    child: const Text('다음'),
                  ),
                ],
              ),
            ]

            // 3단계
            else if (step == 3) ...[
                DropdownButtonFormField<String>(
                  value: selectedWalking,
                  items: ['많이 걷기', '적게 걷기']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedWalking = val),
                  decoration: const InputDecoration(labelText: '이동 스타일'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedTravelStyle,
                  items: ['여유롭게', '알차게', '중간 정도']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedTravelStyle = val),
                  decoration: const InputDecoration(labelText: '여행 스타일'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedActivity,
                  items: ['체험 위주', '관람 위주', '문화 중심']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedActivity = val),
                  decoration: const InputDecoration(labelText: '활동 성향'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => step = 2),
                      child: const Text('이전'),
                    ),
                    ElevatedButton(
                      onPressed: loading ? null : generateTrip,
                      child: const Text('여행 일정 생성'),
                    ),
                  ],
                ),
              ],

            const SizedBox(height: 20),

            if (tripPlan.isNotEmpty)
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : Text(tripPlan, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
