import 'package:flutter/material.dart';
import 'screens/ai_trip_screen.dart';
import 'screens/post_list_screen.dart';
import 'screens/friend_screen.dart';
import 'screens/profile_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // ✅ 반드시 dotenv 불러오기
  runApp(const easy_trip());
}

class easy_trip extends StatelessWidget { //
  const easy_trip({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyTrip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const AITripScreen(),
    const PostListScreen(),
    const FriendScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: 'AI여행',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: '게시물',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '친구',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}