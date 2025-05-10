import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isAuthor = currentUser?.uid == post.userUid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
        actions: [
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('게시글 삭제'),
                    content: const Text('정말 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final res = await http.delete(
                    Uri.parse('${dotenv.env['API_URL']}/api/posts/${post.id}'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'user_uid': currentUser?.uid}),
                  );

                  if (res.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('삭제되었습니다.')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('삭제 실패: ${res.statusCode}')),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 16),
            if (post.itinerary != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('AI 여행 추천 일정 보기'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('AI 여행 추천 일정'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildTripSections(post.itinerary!),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('닫기'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTripSections(String plan) {
    final lines = plan.split('\n');
    final widgets = <Widget>[];

    for (final rawLine in lines) {
      final line = rawLine.trimLeft();
      if (line.isEmpty) continue;

      if (line.startsWith('## Day')) {
        widgets.addAll([
          const Divider(color: Colors.grey, thickness: 0.6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              line.replaceFirst('## ', ''),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ]);
      } else if (line.startsWith('###')) {
        widgets.addAll([
          const Divider(color: Colors.grey, thickness: 0.3),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              line.replaceFirst('### ', ''),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ]);
      } else if (line.startsWith('점심:') || line.startsWith('저녁:') || line.startsWith('숙소추천:')) {
        final parts = line.split(':');
        widgets.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(6),
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14.5, color: Colors.black87, height: 1.6),
              children: [
                TextSpan(
                  text: '${parts.first.trim()}: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: parts.skip(1).join(':').trim()),
              ],
            ),
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 8),
          child: Text(
            line,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ));
      }
    }

    return widgets;
  }
}
