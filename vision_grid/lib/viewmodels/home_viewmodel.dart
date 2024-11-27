import 'dart:async';
import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  int currentIndex = 0;
  final PageController pageController = PageController();
  Timer? timer;
  DateTime? backgroundTime;

  final List<String> imagePaths = [
    'assets/images/promo1.webp',
    'assets/images/promo2.webp',
    'assets/images/promo3.webp',
    'assets/images/promo4.webp',
  ];

  void startAutoScroll() {
    timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (pageController.hasClients) {
        int nextPage = pageController.page!.round() + 1;
        if (nextPage >= imagePaths.length) {
          nextPage = 0;
        }
        pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void stopAutoScroll() {
    timer?.cancel();
  }

  void onPageChanged(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void handleAppLifecycleState(AppLifecycleState state, VoidCallback onTimeout) {
    if (state == AppLifecycleState.paused) {
      backgroundTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (backgroundTime != null) {
        final duration = DateTime.now().difference(backgroundTime!);
        if (duration.inMinutes >= 5) {
          onTimeout();
        }
      }
      backgroundTime = null;
    }
  }

  void dispose() {
    stopAutoScroll();
    pageController.dispose();
  }
}
