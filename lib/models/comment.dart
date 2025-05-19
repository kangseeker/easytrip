class Comment {
  final int id;
  final String userUid;
  final String username;
  final String content;
  final DateTime createdAt;
  final int? parentId;

  Comment({
    required this.id,
    required this.userUid,
    required this.username,
    required this.content,
    required this.createdAt,
    this.parentId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userUid: json['user_uid'],
      username: json['username'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      parentId: json['parent_id'],
    );
  }
}
