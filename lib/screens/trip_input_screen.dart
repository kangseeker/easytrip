import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';

import '../models/trip_location.dart';
import 'trip_result_screen.dart';

class TripInputScreen extends StatefulWidget {
  const TripInputScreen({super.key});

  @override
  State<TripInputScreen> createState() => _TripInputScreenState();
}

class _TripInputScreenState extends State<TripInputScreen> {
  final destinationController = TextEditingController();
  final daysController = TextEditingController();

  String? selectedPeopleType;
  String? selectedWalking;
  String? selectedTravelStyle;
  String? selectedActivity;

  int step = 1;

  Future<void> generateTrip() async {
    final uri = Uri.parse('${dotenv.env['API_URL']}/generate-trip');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/loading.json',
                width: 120,
                height: 120,
                repeat: true,
              ),
              const SizedBox(height: 20),
              const Text('AI 여행일정 생성 중', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );

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
        final parsedPlan = data['plan'] ?? '';
        final parsedLocations = (data['locations'] as List)
            .map((e) => TripLocation.fromJson(e))
            .toList();

        if (!mounted) return;
        Navigator.pop(context); // 로딩창 닫기
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TripResultScreen(
              tripPlan: parsedPlan,
              locations: parsedLocations,
            ),
          ),
        );
      } else {
        Navigator.pop(context);
        _errorDialog('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context);
      _errorDialog('에러 발생: $e');
    }
  }

  void _errorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('에러'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 여행일정 입력')),
      body: _buildStepScreen(),
    );
  }

  Widget _buildStepScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('Step $step of 3',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          if (step == 1) _buildStep1(),
          if (step == 2) _buildStep2(),
          if (step == 3) _buildStep3(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        TextField(
          controller: destinationController,
          decoration: InputDecoration(
            hintText: '어디로 여행을 떠나시나요?',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
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
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        TextField(
          controller: daysController,
          decoration: const InputDecoration(labelText: '여행 일수'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: selectedPeopleType,
          items: [
            '연인과 함께',
            '어르신을 포함한 가족이 함께',
            '아이를 포함한 가족이 함께',
            '친구들과',
            '동호회 혹은 소모임으로',
            '혼자 떠나는',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
                if (daysController.text.isNotEmpty && selectedPeopleType != null) {
                  setState(() => step = 3);
                }
              },
              child: const Text('다음'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedWalking,
          items: [
            '자가용 혹은 렌터카 이용',
            '대중교통 선호',
            '택시 이용',
            '짧은거리만 도보 이동',
            '도보 이동 중심',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => selectedWalking = val),
          decoration: const InputDecoration(labelText: '이동 스타일'),
        ),
        DropdownButtonFormField<String>(
          value: selectedTravelStyle,
          items: [
            '여유롭게 즐기면서',
            '계획적으로 알차게',
            '계획적이지만 널널하게',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => selectedTravelStyle = val),
          decoration: const InputDecoration(labelText: '여행 스타일'),
        ),
        DropdownButtonFormField<String>(
          value: selectedActivity,
          items: [
            '액티비티/레저 중심',
            '유명 관광지 구경 위주',
            '맛집/카페 탐방',
            '역사/문화/자연 체험',
            '쇼핑 중심',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
              onPressed: generateTrip,
              child: const Text('여행 일정 생성'),
            ),
          ],
        ),
      ],
    );
  }
}
