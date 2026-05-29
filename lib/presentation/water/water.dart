import 'package:ahealth/appcolors.dart';
import 'package:ahealth/common/spring_button_widget.dart';
import 'package:flutter/material.dart';

class WaterWidget extends StatefulWidget {
  const WaterWidget({super.key});

  @override
  State<WaterWidget> createState() => _WaterWidgetState();
}

class _WaterWidgetState extends State<WaterWidget> {
  double value = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.6),
                    Colors.blueAccent,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(0),
                  bottomLeft: Radius.circular(0),
                ),
              ),
            ),
            Container(
              width: 100,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.4),
              ),
            ),
            Container(
              width: 120,
              height: 10,
              decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(50)),
            ),
            Container(
              width: 100,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.4),
              ),
            ),
            Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 900),
                width: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentGeometry.topCenter,
                    end: AlignmentGeometry.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.blue.withValues(alpha: 0.2),
                      Colors.blueAccent,
                    ],
                    stops: [1 - value, 0, 1],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    topRight: Radius.circular(100),
                    bottomRight: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Text(
                      "2,436 ml",
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Remaining 546 ml",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textDarkGrey,
                          ),
                    ),
                    Spacer(),
                    SpringButton(
                      SpringButtonType.withOpacity,
                      onTap: () {
                        setState(() {
                          value = (value + 0.1) % 1;
                        });
                      },
                      uiChild: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: kToolbarHeight * 2,
            ),
          ],
        ),
      ),
    );
  }
}
