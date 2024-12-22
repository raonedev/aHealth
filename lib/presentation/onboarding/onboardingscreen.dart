import 'package:ahealth/appcolors.dart';
import 'package:ahealth/presentation/profileinfo/weightinfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final List<Map<String, dynamic>> onBoardingData = [
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


  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onBoardingData.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              // Fade animation logic
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double opacity = 1.0;
                  if (_pageController.position.haveDimensions) {
                    final pageOffset = _pageController.page ?? currentIndex;
                    opacity = 1 - (pageOffset - index).abs().clamp(0.0, 1.0) as double;
                  }
                  return Opacity(
                    opacity: opacity,
                    child: child,
                  );
                },
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: SvgPicture.asset(
                        onBoardingData[index]['imagePath'],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: kToolbarHeight),
                          Text(
                            onBoardingData[index]['title'],
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            onBoardingData[index]['subTitle'],
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
              child: Row(
                children: [
                  ...List.generate(
                    onBoardingData.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: currentIndex == index ? 30 : 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
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
                      if (currentIndex == onBoardingData.length - 1) {
                        // Navigate to the next screen or perform any action
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>const HeathDetailScreen()));
                      } else {
                        _pageController.animateToPage(
                          onBoardingData.length - 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      currentIndex == onBoardingData.length - 1
                          ? "Done"
                          : "Skip",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
