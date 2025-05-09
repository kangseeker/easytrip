import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'trip_input_screen.dart';
import '../models/saved_trip.dart';

class AITripScreen extends StatefulWidget {
  const AITripScreen({super.key});

  @override
  State<AITripScreen> createState() => _AITripScreenState();
}

class _AITripScreenState extends State<AITripScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Easy trip')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Lottie.asset(
                  'assets/lottie/Trip.json',
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration * 1.5
                      ..value = 0;
                    _controller.forward();
                  },
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 버튼 1: AI에게 여행일정 받기
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.travel_explore),
                label: const Text('AI에게 여행일정 받기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TripInputScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // 버튼 2: 저장한 일정 보기 → SavedTripListScreen
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.bookmark), // 아이콘도 바꿈
                label: const Text('저장한 일정 보기'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedTripListScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
