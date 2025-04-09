import 'package:flutter/material.dart';

class PostListScreen extends StatelessWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물'),
      ),
      body: const Center(
        child: Text('게시물 기능 준비 중...'),
      ),
    );
  }
}