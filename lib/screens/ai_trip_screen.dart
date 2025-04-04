import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<void> generateTrip() async {
    final uri = Uri.parse('http://10.0.2.2:3000/generate-trip');
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
        setState(() {
          tripPlan = data['plan'];
        });
      } else {
        setState(() {
          tripPlan = '서버 에러: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        tripPlan = '에러 발생: $e';
      });
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
            TextField(
              controller: destinationController,
              decoration: const InputDecoration(labelText: '여행지'),
            ),
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
            ElevatedButton(
              onPressed: loading ? null : generateTrip,
              child: const Text('여행 일정 생성'),
            ),
            const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : Text(tripPlan, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
