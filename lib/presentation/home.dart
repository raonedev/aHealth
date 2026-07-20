import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:flutter/material.dart';

import 'chat/chat.dart';
import 'home/home_widget.dart';
import 'nutririon/nutrition.dart' show Nutrition;
import 'water/water.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.child});

  final Widget child;

  static const String pathName = "/home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _tabs = [
    '/shell/home',
    '/shell/water',
    '/shell/nutrition',
    '/shell/chat'
  ];

  int _locationToIndex(String loc) {
    if (loc.startsWith('/shell/water')) return 1;
    if (loc.startsWith('/shell/nutrition')) return 2;
    if (loc.startsWith('/shell/chat')) return 3;
    return 0;
  }

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Makes it seamless with your SafeArea background
      statusBarIconBrightness: Brightness.dark, // Android icon contrast
      statusBarBrightness: Brightness.light,    // iOS icon contrast
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToIndex(GoRouterState.of(context).uri.toString());

    // Sync PageController with router location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients && _pageController.page?.round() != currentIndex) {
        _pageController.animateToPage(currentIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.ease);
      }
    });
    return Scaffold(
      extendBody: true,
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 40),
          child: SafeArea(
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
                    currentIndex: _locationToIndex(
                        GoRouterState.of(context).uri.toString()),
                    onTap: (index) {
                      _pageController.animateToPage(index,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.ease);
                      context.go(_tabs[index]);
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
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => context.go(_tabs[index]),
            children: const [
              HomeWidget(),
              WaterWidget(),
              Nutrition(),
              ChatWidget(),
            ],
          ),

          /// bottom navigationbar
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: SafeArea(
          //     child: Padding(
          //       padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
          //       child: ClipRRect(
          //         borderRadius: BorderRadius.circular(24.0),
          //         child: BackdropFilter(
          //           filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          //           child: Container(
          //             decoration: BoxDecoration(
          //               color: Colors.white.withValues(alpha: 0.15),
          //               borderRadius: BorderRadius.circular(24.0),
          //               border: Border.all(
          //                 color: Colors.white.withValues(alpha: 0.8),
          //                 width: 1.0,
          //               ),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: Colors.black.withValues(alpha: 0.08),
          //                   blurRadius: 20,
          //                   offset: const Offset(0, 8),
          //                 ),
          //               ],
          //             ),
          //             child: BottomNavigationBar(
          //               elevation: 0,
          //               backgroundColor: Colors.transparent,
          //               type: BottomNavigationBarType.fixed,
          //               selectedItemColor: Colors.black,
          //               unselectedItemColor: Colors.black38,
          //               showSelectedLabels: true,
          //               selectedFontSize: 14,
          //               unselectedFontSize: 14,
          //               currentIndex: _locationToIndex(
          //                   GoRouterState.of(context).uri.toString()),
          //               onTap: (index) {
          //                 _pageController.animateToPage(index,
          //                     duration: const Duration(milliseconds: 400),
          //                     curve: Curves.ease);
          //                 context.go(_tabs[index]);
          //               },
          //               showUnselectedLabels: true,
          //               items: const [
          //                 BottomNavigationBarItem(
          //                   icon: HugeIcon(
          //                     icon: HugeIcons.strokeRoundedHome01,
          //                   ),
          //                   label: 'Home',
          //                 ),
          //                 BottomNavigationBarItem(
          //                   icon: HugeIcon(
          //                     icon: HugeIcons.strokeRoundedSoftDrink01,
          //                   ),
          //                   label: 'Water',
          //                 ),
          //                 BottomNavigationBarItem(
          //                   icon: HugeIcon(
          //                     icon: HugeIcons.strokeRoundedRiceBowl01,
          //                   ),
          //                   label: 'Nutrition',
          //                 ),
          //                 BottomNavigationBarItem(
          //                   icon: HugeIcon(
          //                     icon: HugeIcons.strokeRoundedChat01,
          //                   ),
          //                   label: 'Chat',
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
