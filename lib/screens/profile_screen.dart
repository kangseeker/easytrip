import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙
          crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙!!!
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purpleAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              '닉네임: 여행자123',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              '이메일: user@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃 기능 준비 중')),
                );
              },
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}