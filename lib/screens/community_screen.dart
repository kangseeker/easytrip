import 'package:flutter/material.dart';
import 'ai_trip_screen.dart';


class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const AITripScreen(), // AI 여행 화면
    const Center(child: Text('친구 목록 기능 준비 중...')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EazyTrip Community')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.travel_explore), label: 'AI여행'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: '게시물'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '친구'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.withOpacity(0.6),
        onTap: _onItemTapped,
      ),
    );
  }
}
