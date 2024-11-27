import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../viewmodels/home_viewmodel.dart';
import 'camera_screen.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);

    viewModel.handleAppLifecycleState(state, () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..startAutoScroll(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
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
                _buildCarousel(viewModel),
                _buildPageIndicator(viewModel),
                _buildGridButtons(context),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: viewModel.currentIndex,
              onTap: (index) => _navigateToPage(context, viewModel, index),
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
        },
      ),
    );
  }

  Widget _buildCarousel(HomeViewModel viewModel) {
    return Container(
      height: 180.0,
      child: PageView(
        controller: viewModel.pageController,
        children: viewModel.imagePaths.map((imagePath) {
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
    );
  }

  Widget _buildPageIndicator(HomeViewModel viewModel) {
    return SmoothPageIndicator(
      controller: viewModel.pageController,
      count: viewModel.imagePaths.length,
      effect: WormEffect(
        dotHeight: 8,
        dotWidth: 8,
        spacing: 8,
        activeDotColor: Colors.blue,
      ),
    );
  }

  Widget _buildGridButtons(BuildContext context) {
    return Expanded(
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

  void _navigateToPage(BuildContext context, HomeViewModel viewModel, int index) {
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CameraScreen()),
        ).then((_) {
          viewModel.onPageChanged(0);
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        ).then((_) {
          viewModel.onPageChanged(0);
        });
        break;
      default:
        viewModel.onPageChanged(index);
        break;
    }
  }
}
