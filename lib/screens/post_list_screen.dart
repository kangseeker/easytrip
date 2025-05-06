import 'dart:math';
import 'package:flutter/material.dart';


class PostListScreen extends StatelessWidget {
  final String username = 'UNI_SEOUL1234'; // 임시 닉네임(UNI+지역명+난수)

  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물'),
      ),
      body: ListView.builder(
        itemCount: 3, // 임시 게시글 3개
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person),
                  ),
                  title: Text(username),
                  subtitle: Text( '게시글입니다'),
                ),
                Container(
                  height: 200,
                  color: Colors.orangeAccent, // 나중에 이미지로 대체 가능
                  child: const Center(child: Text('사진 영역 (지도 이미지 대체 예정)')),
                ),
                ButtonBar(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border),
                      label: const Text('좋아요'),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}


