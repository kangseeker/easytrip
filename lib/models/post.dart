class Post {
  final String username;
  final String content;
  final String? attachedTripPlan;
  int likes;

  Post({
    required this.username,
    required this.content,
    this.attachedTripPlan,
    this.likes = 0,
  });

  static final List<Post> postStorage = [];
}
