import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';
import 'post_detail.dart';
import 'post_write_screen.dart';


class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List<Post> postList = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final uri = Uri.parse('${dotenv.env['API_URL']}/api/posts');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final List posts = json['posts'];
      setState(() {
        postList = posts.map((e) => Post.fromJson(e)).toList();
      });
    } else {
      print('게시물 불러오기 실패: ${res.statusCode}');
    }
  }

  Future<void> toggleLike(Post post) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final uri = Uri.parse('${dotenv.env['API_URL']}/api/posts/${post.id}/like');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_uid': user.uid}),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final liked = json['liked'] as bool;

      setState(() {
        post.likes += liked ? 1 : -1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요 실패: ${res.statusCode}')),
      );
    }
  }

  Future<void> addFriend(String friendUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final res = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/api/friends'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_uid': user.uid,
        'friend_uid': friendUid,
      }),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친구 추가 완료')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('친구 추가 실패: ${res.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시물')),

      // ✅ 아래에 둥근 + 버튼 추가
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PostWriteScreen(),
            ),
          ).then((_) => fetchPosts()); // 작성 후 목록 갱신
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),

      body: ListView.builder(
        itemCount: postList.length,
        itemBuilder: (context, index) {
          final post = postList[index];
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
                  leading: GestureDetector(
                    onTap: () => addFriend(post.userUid),
                    child: const CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 188, 213, 255),
                      child: Icon(Icons.edit),
                    ),
                  ),
                  title: Text(post.username),
                  subtitle: Text(
                    post.content.length > 30
                        ? '${post.content.substring(0, 30)}...'
                        : post.content,
                  ),
                ),
                ButtonBar(
                  children: [
                    TextButton.icon(
                      onPressed: () => toggleLike(post),
                      icon: const Icon(Icons.favorite_border),
                      label: Text('좋아요 (${post.likes})'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

