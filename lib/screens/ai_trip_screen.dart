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
  final peopleController = TextEditingController();
  final daysController = TextEditingController();

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
          'people': peopleController.text,
          'days': daysController.text,
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
              controller: peopleController,
              decoration: const InputDecoration(labelText: '인원수'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: daysController,
              decoration: const InputDecoration(labelText: '여행 일수'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
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
