import 'package:flutter/material.dart';

class Friend {
  final String id;
  final String name;
  final String email;

  Friend({required this.id, required this.name, required this.email});
}

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  List<Friend> friends = [
    Friend(id: '1', name: 'Alice', email: 'alice@example.com'),
    Friend(id: '2', name: 'Bob', email: 'bob@example.com'),
  ];

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  void _addFriend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('친구 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              nameController.clear();
              emailController.clear();
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                setState(() {
                  friends.add(Friend(
                    id: DateTime.now().toString(),
                    name: nameController.text,
                    email: emailController.text,
                  ));
                });
              }
              Navigator.pop(context);
              nameController.clear();
              emailController.clear();
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveFriend(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('$name님을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              _removeFriend(id);
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _removeFriend(String id) {
    setState(() {
      friends.removeWhere((friend) => friend.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 목록'),
      ),
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
                    onPressed: () => _confirmRemoveFriend(friend.id, friend.name),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFriend,
        child: const Icon(Icons.add),
      ),
    );
  }
}
