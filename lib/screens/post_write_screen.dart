import 'package:flutter/material.dart';
import '../models/post.dart';

class PostWriteScreen extends StatefulWidget {
  final String? attachedPlan; // 저장된 여행 일정 연결용

  const PostWriteScreen({super.key, this.attachedPlan});

  @override
  State<PostWriteScreen> createState() => _PostWriteScreenState();
}

class _PostWriteScreenState extends State<PostWriteScreen> {
  final TextEditingController contentController = TextEditingController();

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
                onPressed: () {
                  final post = Post(
                    username: 'UNI${DateTime.now().millisecondsSinceEpoch % 10000}',
                    content: contentController.text,
                    attachedTripPlan: widget.attachedPlan,
                  );
                  Post.postStorage.add(post);
                  Navigator.pop(context);
                },
                child: const Text('게시물 등록'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
