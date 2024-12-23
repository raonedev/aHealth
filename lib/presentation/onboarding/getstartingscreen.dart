import 'package:ahealth/app_routes.dart';
import 'package:ahealth/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class GetStartingScreen extends StatefulWidget {
  const GetStartingScreen({super.key});
  @override
  State<GetStartingScreen> createState() => _GetStartingScreenState();
}

class _GetStartingScreenState extends State<GetStartingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16,
          children: [
            const SizedBox(
              width: double.infinity,
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Text(
              "Welcome to \nA - Health",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              "Your  Health  Companion",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SvgPicture.asset('assets/svgs/getstarted.svg'),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (_) => const OnboardingScreen()));
                context.push(AppRoutes.onBoarding);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Get Started",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: white),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.arrow_forward,
                    color: white,
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                  text: 'Already have an account?',
                  style: Theme.of(context).textTheme.bodySmall,
                  children: const [
                    TextSpan(
                        text: ' Sign In.',
                        style: TextStyle(
                          color: red,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: red,
                        ))
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
