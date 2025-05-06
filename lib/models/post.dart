class Post {
  final String username;
  final String content;
  final String image;

  Post({
    required this.username,
    required this.content,
    required this.image,
  });
  static final List<Post> postStorage = []; // 전역 게시글 리스트
}