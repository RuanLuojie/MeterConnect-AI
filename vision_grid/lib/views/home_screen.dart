import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'camera_screen.dart';
import '../viewmodels/camera_viewmodel.dart';
import 'settings_screen.dart';
import '../login_screen.dart';
import 'registration_screen.dart';
import 'issue_feedback_screen.dart';
import 'emergency_notification_screen.dart';
import 'usage_data_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;
  DateTime? _backgroundTime;

  final List<String> _imagePaths = [
    'assets/images/promo1.webp',
    'assets/images/promo2.webp',
    'assets/images/promo3.webp',
    'assets/images/promo4.webp',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAutoScroll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  /// **自動輪播**
  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.round() + 1;
        if (nextPage >= _imagePaths.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
  }

  /// **應用程序生命週期監聽**
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
      _stopAutoScroll(); // 應用進入背景，停止自動輪播
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null) {
        final duration = DateTime.now().difference(_backgroundTime!);
        if (duration.inMinutes >= 5) {
          // 如果超過5分鐘，返回登入畫面
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
          );
        } else {
          _startAutoScroll(); // 繼續自動輪播
        }
        _backgroundTime = null;
      }
    }
  }

  /// **導航**
  void _navigateToPage(int index) {
    if (index == _currentIndex) return; // 防止重複導航
    switch (index) {
      case 0:
      // 首頁邏輯（可選，如果需要刷新）
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (context) => CameraViewModel(),
              child: CameraScreen(),
            ),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
        break;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  /// **構建UI**
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision Grid'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // **自動輪播區域**
          Container(
            height: 180.0,
            child: PageView(
              controller: _pageController,
              children: _imagePaths.map((imagePath) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 8),
          SmoothPageIndicator(
            controller: _pageController,
            count: _imagePaths.length,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 8,
              activeDotColor: Colors.blue,
            ),
          ),
          SizedBox(height: 20),
          // **功能按鈕區域**
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              padding: EdgeInsets.all(16.0),
              children: [
                _buildGridButton(
                  icon: Icons.app_registration,
                  label: '註冊',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationScreen(),
                      ),
                    );
                  },
                ),
                _buildGridButton(
                  icon: Icons.feedback,
                  label: '問題反饋表',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IssueFeedbackScreen(),
                      ),
                    );
                  },
                ),
                _buildGridButton(
                  icon: Icons.bar_chart,
                  label: '使用數據',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UsageDataScreen(),
                      ),
                    );
                  },
                ),
                _buildGridButton(
                  icon: Icons.warning,
                  label: '緊急通報',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmergencyNotificationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: '相機',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設置',
          ),
        ],
      ),
    );
  }

  Widget _buildGridButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
