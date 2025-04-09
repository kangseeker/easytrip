import 'package:flutter/material.dart';

class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 목록'),
      ),
      body: const Center(
        child: Text('친구 기능 준비 중...'),
      ),
    );
  }
}