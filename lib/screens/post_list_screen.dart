import 'dart:math';
import 'package:flutter/material.dart';
import '../models/post.dart';


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
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person),
                  ),
                  title: Text(post.username),
                  subtitle: Text(post.content),
                ),
                Container(
                  height: 200,
                  color: Colors.orangeAccent,
                  alignment: Alignment.center,
                  child: Text(post.image),
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


