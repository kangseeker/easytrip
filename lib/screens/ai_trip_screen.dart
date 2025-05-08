import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../widgets/trip_map.dart';
import '../models/trip_location.dart';
import '../models/post.dart';

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
  List<TripLocation> locations = [];
  bool loading = false;
  int step = 1;

  /* ----------------------------- 서버 호출 ---------------------------- */

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("여행 일정을 생성 중입니다..."),
            ],
          ),
        );
      },
    );
  }

  Future<void> generateTrip() async {
    final uri = Uri.parse(dotenv.env['API_URL']!);
    setState(() => loading = true);
    _showLoadingDialog();
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
          tripPlan = data['plan'] ?? '';
          locations = (data['locations'] as List)
              .map((e) => TripLocation.fromJson(e))
              .toList();
          step = 4;
        });
      } else {
        _errorDialog('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      _errorDialog(e.toString());
    } finally {
      setState(() => loading = false);
      Navigator.of(context, rootNavigator: true).pop(); // 다이얼로그 닫기

    }
  }

  void _errorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('에러'),
        content: Text(msg),
      ),
    );
  }

  void _createPost() {
  final randomNumber = Random().nextInt(10000);
  final newPost = Post(
    username: 'UNI$randomNumber',
    content: 'AI 추천 여행지 게시글입니다.',
    image: '지도 이미지 대체 예정',
  );

  Post.postStorage.add(newPost);
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('게시물이 등록되었습니다!'),
      duration: Duration(seconds: 2),
    ),
  );
}

  /* ----------------------------- UI ----------------------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 여행 추천')),
      body: step == 4
          ? _buildResultScreen()
          : _buildStepScreen(),
    );
  }

  /* ---------------------- 결과 화면 (지도 + 바텀시트) ---------------------- */
  Widget _buildResultScreen() {
    return Stack(
      children: [
        Positioned.fill(
          child: TripMap(locations: locations),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 280,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            padding: const EdgeInsets.all(16),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tripPlan,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => setState(() {
                        tripPlan = '';
                        locations = [];
                        selectedWalking =
                            selectedTravelStyle = selectedActivity = null;
                        step = 1;
                      }),
                      child: const Text('새 여행 만들기'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _createPost(); // 게시글 생성 함수
                      },
                      child: const Text('게시물 작성하기'),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /* ---------------------- 1~3단계 입력 화면 ---------------------- */
  Widget _buildStepScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('Step $step of 4',
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
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
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
    );
  }
}
