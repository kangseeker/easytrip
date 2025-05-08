class Post {
  final String username;
  final String content;
  //final String image;
  int likes;

  Post({
    required this.username,
    required this.content,
    //required this.image,
    this.likes = 0,
  });
  static final List<Post> postStorage = []; // 전역 게시글 리스트
}