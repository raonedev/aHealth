// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:ahealth/common/spring_button_widget.dart';
import 'package:ahealth/presentation/home/widget/height_card.dart';
import 'package:ahealth/presentation/home/widget/hydration_card.dart';
import 'package:ahealth/presentation/home/widget/sleep_card.dart';
import 'package:ahealth/presentation/home/widget/weight_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_routes.dart';
import '../../appcolors.dart';
import '../../features/step_tracking/presentation/views/tracking_view.dart';
import 'widget/nutrition_card.dart';
import 'widget/step_card.dart';

const _kOnSurfaceVariant = Color(0xFF40493D);
const _kSurfaceContainerLowest = Color(0xFFFFFFFF);

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  String _userName = '';
  File? _userImageFile;
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadUserImage();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userNameSharedPreferenceKey') ?? '';
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _loadUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('userProfileImagePathSharedPreferenceKey');
    if (path != null && await File(path).exists()) {
      if (mounted) {
        setState(() {
          _userImageFile = File(path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            _buildTopBar(context),
            const SizedBox(height: 8),
            NutritionCard(),
            const SizedBox(height: 16),
            StepsCard(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: HydrationCard()),
                const SizedBox(width: 16),
                Expanded(child: WeightCard()),
              ],
            ),
            const SizedBox(height: 16),
            HeightCard(),
            const SizedBox(height: 16),
            SleepCard(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: kToolbarHeight + 20),
        child: SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: () {
              context.push(StepsTrackingView.name);
            },
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedWorkoutRun,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ---- Top bar -------------------------------------------------------

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: grey,
              backgroundImage:
                  _userImageFile != null ? FileImage(_userImageFile!) : null,
              child: _userImageFile == null
                  ? Icon(Icons.person, color: _kOnSurfaceVariant)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME BACK,',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: _kOnSurfaceVariant,
                  ),
                ),
                Text(
                  _userName.isNotEmpty ? _userName : 'there',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
        SpringButton(
          SpringButtonType.withOpacity,
          onTap: () => context.push(AppRoutes.searchFoodScreen),
          uiChild: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kSurfaceContainerLowest,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.search, color: _kOnSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
