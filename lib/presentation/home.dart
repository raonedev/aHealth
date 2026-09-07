import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:flutter/material.dart';

import '../blocs/nutrition/nutrition_cubit.dart';
import '../features/progress_photos/presentation/screens/progress_photos_screen.dart';
import 'home/home_widget.dart';
import 'nutririon/nutrition.dart' show Nutrition;
import 'water/water.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.child});
  final Widget child;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _tabs = [
    '/shell/home',
    '/shell/water',
    '/shell/nutrition',
    '/shell/progress',
  ];

  int _locationToIndex(String loc) {
    if (loc.startsWith('/shell/water')) return 1;
    if (loc.startsWith('/shell/nutrition')) return 2;
    if (loc.startsWith('/shell/progress')) return 3;
    return 0;
  }

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onAndroidBack() async {
    final index =
        _pageController.hasClients ? (_pageController.page?.round() ?? 0) : 0;

    // Not on Home tab → swipe back to Home
    if (index != 0) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
      context.go(_tabs[0]);
      return;
    }

    // Already on Home → leave the app (no GoRouter pop)
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex =
        _locationToIndex(GoRouterState.of(context).uri.toString());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != currentIndex) {
        _pageController.jumpToPage(currentIndex);
      }
    });

    return PopScope(
      canPop: false, // we handle Android back ourselves
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onAndroidBack();
      },
      child: Theme(
        data: Theme.of(context).copyWith(
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.transparent,
            elevation: 0,
            modalBackgroundColor: Colors.transparent,
          ),
        ),
        child: Scaffold(
          extendBody: true,
          bottomSheet: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                      currentIndex: currentIndex,
                      onTap: (index) {
                        if (index == currentIndex) return;
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.ease,
                        );
                        context.go(_tabs[index]);
                      },
                      showUnselectedLabels: true,
                      items: const [
                        BottomNavigationBarItem(
                          icon: HugeIcon(icon: HugeIcons.strokeRoundedHome01),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedSoftDrink01),
                          label: 'Water',
                        ),
                        BottomNavigationBarItem(
                          icon:
                              HugeIcon(icon: HugeIcons.strokeRoundedRiceBowl01),
                          label: 'Nutrition',
                        ),
                        BottomNavigationBarItem(
                          icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedBodyPartSixPack),
                          label: 'Weight',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              // REQUIRED: keep GoRouter's shell navigator mounted
              Offstage(offstage: true, child: widget.child),

              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  final cubit = context.read<NutritionCubit>();
                  final today = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  );
                  if (cubit.selectedDate != today) {
                    cubit.getNutritionData(date: today);
                  }

                  final loc = GoRouterState.of(context).uri.toString();
                  if (_locationToIndex(loc) == index) return;

                  context.go(_tabs[index]);
                },
                children: const [
                  HomeWidget(),
                  WaterWidget(),
                  Nutrition(),
                  ProgressPhotosScreen(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
