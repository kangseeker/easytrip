import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostWriteScreen extends StatefulWidget {
  final String? attachedPlan; // 저장된 여행 일정 연결용

  const PostWriteScreen({super.key, this.attachedPlan});

  @override
  State<PostWriteScreen> createState() => _PostWriteScreenState();
}

class _PostWriteScreenState extends State<PostWriteScreen> {
  final TextEditingController contentController = TextEditingController();

  Future<void> _submitPost() async {
    await FirebaseAuth.instance.currentUser?.reload(); // 최신 정보 반영
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final displayName = user.displayName?.trim();
    final content = contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요.')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/api/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_uid': user.uid,
        'display_name': displayName ?? user.email?.split('@').first ?? '익명',
        'content': content,
        'itinerary': widget.attachedPlan ?? '',
        'image_url': null,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시물이 등록되었습니다!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: ${response.statusCode}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시물 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.attachedPlan != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✅ AI 여행 일정이 첨부되었습니다.',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            TextField(
              controller: contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '게시글 내용을 자유롭게 입력하세요.',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitPost,
                child: const Text('게시물 등록'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
