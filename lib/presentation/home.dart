import 'dart:ui';
import 'package:ahealth/app_routes.dart';
import 'package:ahealth/presentation/chat/chat.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home/home_widget.dart';
import 'nutririon/nutrition.dart';
import 'water/water.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String pathName = "/home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;
  final List<Widget> _screens = [
    const HomeWidget(),
    const WaterWidget(),
    const Nutrition(),
    const ChatWidget()
  ];

  final PageController _pageController = PageController(initialPage: 1);
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => context.push(AppRoutes.searchScreen),
              icon: const Icon(CupertinoIcons.search))
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _screens.length,
            onPageChanged: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
            itemBuilder: (context, index) {
              return _screens[index];
            },
          ),

          /// bottom navigationbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: BottomNavigationBar(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        type: BottomNavigationBarType.fixed,
                        selectedItemColor: Colors.black,
                        unselectedItemColor: Colors.black38,
                        showSelectedLabels: true,
                        selectedFontSize: 14,
                        unselectedFontSize: 14,
                        currentIndex: _currentIndex,
                        onTap: (value) {
                          setState(() {
                            _currentIndex = value;
                            _pageController.animateToPage(_currentIndex,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          });
                        },
                        showUnselectedLabels: true,
                        items: const [
                          BottomNavigationBarItem(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedHome01,
                            ),
                            label: 'Home',
                          ),
                          BottomNavigationBarItem(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedSoftDrink01,
                            ),
                            label: 'Water',
                          ),
                          BottomNavigationBarItem(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedRiceBowl01,
                            ),
                            label: 'Nutrition',
                          ),
                          BottomNavigationBarItem(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedChat01,
                            ),
                            label: 'Chat',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
