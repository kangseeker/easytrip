class Post {
  final int id;
  final String userUid;
  final String username;
  final String content;
  final String? itinerary;
  final String? imageUrl;
  final DateTime createdAt;
  int likes;

  Post({
    required this.id,
    required this.userUid,
    required this.username,
    required this.content,
    required this.createdAt,
    required this.likes,
    this.itinerary,
    this.imageUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userUid: json['user_uid'],
      username: json['username'],
      content: json['content'],
      itinerary: json['itinerary'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      likes: json['likes'] ?? 0,
    );
  }
}
