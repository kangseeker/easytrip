import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // 로그인 취소

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase 로그인
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential);
      final user = userCredential.user;

      // ✅ 로그인 성공 후 사용자 정보 서버에 등록
      if (user != null) {
        await http.post(
          Uri.parse('${dotenv.env['API_URL']}/api/users/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'uid': user.uid,
            'display_name': user.displayName ?? user.email
                ?.split('@')
                .first ?? '익명',
          }),
        );
      }
    } catch (e) {
      print('로그인 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 중 오류가 발생했습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ 로고 이미지 추가
            Image.asset(
              'assets/logo_text.png',
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.8,
            ),
            const SizedBox(height: 48), // 로고와 버튼 간 여백

            // ✅ 로그인 버튼
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Google 계정으로 로그인'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42A5F5), // 버튼 색
                foregroundColor: Colors.white, // 글자 + 아이콘 흰색
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () => _signInWithGoogle(context),
            ),
          ],
        ),
      ),
    );
  }
}
