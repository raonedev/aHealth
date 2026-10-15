import 'package:ahealth/app_routes.dart';
import 'package:ahealth/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  static const String pathName = "/onBoarding";
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  final List<Map<String, String>> onBoardingData = const [
    {
      "title": "Simplify Your Health Goals with Our Minimal Health Tracker",
      "subTitle":
          "Set goals, add meals, track progress and so much more in the most seamless way possible.",
      "imagePath": "assets/svgs/onboarding1.svg",
    },
    {
      "title": "Track Your Weight and Body Fat with Ease",
      "subTitle":
          "Monitor changes over time and stay on top of your fitness and health journey effortlessly.",
      "imagePath": "assets/svgs/onboarding2.svg",
    },
    {
      "title": "Optimize Your Workouts with Real-Time Insights",
      "subTitle":
          "Track exercises, measure performance, and achieve fitness goals with data-driven results.",
      "imagePath": "assets/svgs/onboarding3.svg",
    },
    {
      "title": "Keep Your Body Hydrated with Smart Tracking",
      "subTitle":
          "Set daily hydration goals and stay refreshed by tracking your water intake seamlessly.",
      "imagePath": "assets/svgs/onboarding4.svg",
    },
    {
      "title": "Build Stronger Muscles with Detailed Analytics",
      "subTitle":
          "Track your muscle growth and progress with accurate insights to reach your fitness peak.",
      "imagePath": "assets/svgs/onboarding5.svg",
    },
  ];

  @override
  void initState() {
    super.initState();
    _precacheSvgs();
  }

  // Load every SVG into flutter_svg's cache once (flutter_svg 2.x)
  void _precacheSvgs() {
    for (final item in onBoardingData) {
      final loader = SvgAssetLoader(item['imagePath']!);
      svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastIndex = onBoardingData.length - 1;

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: onBoardingData.length,
              onPageChanged: (index) => _currentIndex.value = index,
              itemBuilder: (context, index) {
                return KeepAlivePage(
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: RepaintBoundary(
                          child: SvgPicture.asset(
                            onBoardingData[index]['imagePath']!,
                            width: MediaQuery.sizeOf(context).width,
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.bottomLeft,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // const SizedBox(height: kToolbarHeight),
                            Text(
                              onBoardingData[index]['title']!,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              onBoardingData[index]['subTitle']!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentIndex,
                  builder: (context, currentIndex, _) {
                    return Row(
                      children: [
                        ...List.generate(
                          onBoardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: currentIndex == index ? 30 : 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF090E1D),
                            minimumSize: const Size(110, 56),
                          ),
                          onPressed: () {
                            if (currentIndex == lastIndex) {
                              context.push(AppRoutes.heathDetail);
                            } else {
                              _pageController.animateToPage(
                                lastIndex,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Text(
                            currentIndex == lastIndex ? "Done" : "Skip",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;
  const KeepAlivePage({super.key, required this.child});
  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}