import 'dart:math';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../screens/post_detail.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시물')),
      body: ListView.builder(
        itemCount: Post.postStorage.length,
        itemBuilder: (context, index) {
          final post = Post.postStorage[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                  leading: const CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 188, 213, 255),
                    child: Icon(Icons.person),
                  ),
                  title: Text(post.username),
                  subtitle: Text(
                     post.content.length > 30
                    ? '${post.content.substring(0, 30)}...'
                    : post.content,
                  ),
                ),
                /*
                Container(
                  height: 200,
                  color: Colors.orangeAccent,
                  alignment: Alignment.center,
                  child: Text(post.image),
                ),*/
                ButtonBar(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          post.likes++; // 좋아요 1 증가
                        });
                      },
                      icon: const Icon(Icons.favorite_border),
                      label: Text('좋아요 (${post.likes})'),
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


