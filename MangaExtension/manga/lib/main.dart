import 'package:flutter/material.dart';
import 'package:manga/qr.dart';
import 'package:manga/remote.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MangaApp());

class MangaApp extends StatefulWidget {
  static late SharedPreferences data;
  const MangaApp({super.key});
  static final PageController pageController = PageController(initialPage: 0);
  @override
  State<MangaApp> createState() => _MangaAppState();
}

class _MangaAppState extends State<MangaApp> {
  static int _selectedIndex = 0;
  void _updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void init() {
    if (MangaApp.data.getInt('scroll') != null) {
      Remote.scroll = MangaApp.data.getInt('scroll') as int;
    } else {
      Remote.scroll = 500;
    }
    if (MangaApp.data.getInt('speed') != null) {
      Remote.speed = MangaApp.data.getInt('speed') as int;
    } else {
      Remote.speed = 500;
    }
  }

  void loadSaveData() async {
    MangaApp.data = await SharedPreferences.getInstance();
    init();
  }

  // Callback to handle tab selection
  void _onTabTapped(int index) {
    MangaApp.pageController.animateToPage(
      index,
      duration: const Duration(
          milliseconds: 500), // Điều chỉnh thời gian chuyển trang (tùy chọn)
      curve: Curves.ease, // Điều chỉnh hiệu ứng chuyển trang (tùy chọn)
    );
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSaveData();
  }

  //BUILD APP
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: MangaApp.pageController,
          children: <Widget>[
            QRScanner(_updateIndex),
            Remote(_updateIndex),
          ],
        ), // Display the selected screen

        bottomNavigationBar: BottomNavigationBar(
          fixedColor: const Color.fromARGB(255, 209, 174, 255),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: 'Quét mã QR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_remote),
              label: 'Điều khiển',
            ),
          ],
          currentIndex: _selectedIndex, // Current tab index
          onTap: _onTabTapped, // Callback for tab selection
        ),
      ),
    );
  }
}
