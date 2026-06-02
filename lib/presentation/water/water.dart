import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health/health.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../blocs/water/water_cubit.dart';

const Color background = Color(0xFFF1F5F9);
const Color grey = Color(0xFFCBD5E1);
const Color textDarkGrey = Color(0xFF475569);

class WaterWidget extends StatefulWidget {
  const WaterWidget({super.key});

  @override
  State<WaterWidget> createState() => _WaterWidgetState();
}

class _WaterWidgetState extends State<WaterWidget> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fillController;

  double _currentAngle = 0.0;
  double _targetAngle = 0.0;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: 0.0,
    );

    _waveController.addListener(() {
      _currentAngle += (_targetAngle - _currentAngle) * 0.08;
    });

    accelerometerEventStream().listen((event) {
      if (mounted) {
        _targetAngle = atan2(event.x, event.y).clamp(-pi / 3, pi / 3);
      }
    });

    context.read<WaterCubit>().getWaterData();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  void _syncFillLevel(double totalLiters, double targetLiters) {
    final level = (totalLiters / targetLiters).clamp(0.0, 1.0);
    _fillController.animateTo(level, curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WaterCubit, WaterState>(
      listener: (context, state) {if (state is WaterSuccessState) {
        final total = state.waterModel.fold(0.0, (sum, e) => sum + (e.value?.numericValue ?? 0.0));
        _syncFillLevel(total, 4.0);
      }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text('Today\' water'),
            ),
            actions: [
              IconButton(onPressed: () {
                context.push('/chart/${HealthDataType.WATER.name}');
              }, icon: Icon(Icons.history))
            ],

          ),
          body: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: kToolbarHeight),
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
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                ),
                Container(width: 100, height: 10, color: Colors.blue.withValues(alpha: 0.4)),
                Container(
                  width: 120,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                Container(width: 100, height: 8, color: Colors.blueAccent.withValues(alpha: 0.4)),
                Expanded(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_waveController, _fillController]),
                    builder: (context, _) {
                      final value = _fillController.value;
                      final total = state is WaterSuccessState
                          ? state.waterModel.fold(0.0, (sum, e) => sum + (e.value?.numericValue ?? 0.0))
                          : 0.0;
                      final totalMl = (total * 1000).toStringAsFixed(0);
                      final remainingL = (4.0 - total).clamp(0.0, 4.0).toStringAsFixed(2);

                      return Container(
                        width: 280,
                        decoration: BoxDecoration(
                          border: Border.all(color: grey, width: 0.6),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(100),
                            topRight: Radius.circular(100),
                            bottomRight: Radius.circular(50),
                            bottomLeft: Radius.circular(50),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CustomPaint(
                          painter: _WaterPainter(
                            fillLevel: value,
                            animValue: _waveController.value,
                            angle: _currentAngle,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              if (state is WaterLoadingState)
                                const CircularProgressIndicator(color: Colors.white)
                              else
                                Text(
                                  "$totalMl ml",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              const SizedBox(height: 20),
                              Text(
                                "Remaining $remainingL L",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: textDarkGrey),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: state is WaterLoadingState
                                    ? null
                                    : () => context.read<WaterCubit>().addWater(waterInLiter: 0.25),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.blueAccent.withValues(alpha: 0.2),
                                    ),
                                    color: (value < 0.3) ? Colors.blue : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: (value > 0.3) ? Colors.blue : Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Log Water here",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: (value < 0.2) ? textDarkGrey : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: kToolbarHeight * 2),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WaterPainter extends CustomPainter {
  final double fillLevel;
  final double animValue;
  final double angle;

  _WaterPainter({
    required this.fillLevel,
    required this.animValue,
    required this.angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fillLevel <= 0) return;

    final waterTop = size.height * (1 - fillLevel);
    const waveHeight = 12.0;

    final path = Path();

    double getSurfaceY(double x) {
      return waterTop + tan(angle) * (x - size.width / 2);
    }

    path.moveTo(0, getSurfaceY(0));

    for (double x = 0; x <= size.width; x++) {
      final surfaceY = getSurfaceY(x);
      final y = surfaceY +
          waveHeight * sin((x / size.width * 2 * pi) + (animValue * 2 * pi)) +
          waveHeight * 0.5 * sin((x / size.width * 3 * pi) + (animValue * 2 * pi * 1.3));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.withValues(alpha: 0.5),
          Colors.blueAccent,
        ],
      ).createShader(Rect.fromLTWH(0, waterTop, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaterPainter old) =>
      old.fillLevel != fillLevel || old.animValue != animValue || old.angle != angle;
}