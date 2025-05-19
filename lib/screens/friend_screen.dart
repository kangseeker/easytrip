import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Friend {
  final String id;
  final String name;
  final String email;

  Friend({required this.id, required this.name, required this.email});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['uid'],
      name: json['display_name'],
      email: json['email'] ?? '',
    );
  }
}

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  List<Friend> friends = [];
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final res = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/api/friends?user_uid=${user.uid}'),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body)['friends'];
      setState(() {
        friends = data.map((e) => Friend.fromJson(e)).toList();
      });
    } else {
      print('친구 목록 불러오기 실패: ${res.statusCode}');
    }
  }

  Future<void> addFriend() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final email = emailController.text.trim();

    if (email.isEmpty) return;

    final res = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/api/friends'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_uid': user.uid, 'target_email': email}),
    );

    if (res.statusCode == 200) {
      Navigator.pop(context);
      nameController.clear();
      emailController.clear();
      fetchFriends();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친구가 추가되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친구 추가 실패')),
      );
    }
  }

  Future<void> removeFriend(String friendUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final res = await http.delete(
      Uri.parse('${dotenv.env['API_URL']}/api/friends'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_uid': user.uid, 'friend_uid': friendUid}),
    );

    if (res.statusCode == 200) {
      fetchFriends();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제 실패')),
      );
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('친구 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '상대 이메일'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              emailController.clear();
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: addFriend,
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(String friendUid, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('$name님을 친구 목록에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              removeFriend(friendUid);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('친구 목록')),
      body: friends.isEmpty
          ? const Center(child: Text('친구가 없습니다.'))
          : ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(friend.name),
            subtitle: Text(friend.email),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmRemove(friend.id, friend.name),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
        foregroundColor: Colors.white,
      ),
    );
  }
}
