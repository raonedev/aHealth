import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../appcolors.dart';
import '../../common/spring_button_widget.dart';
import '../../constants.dart';
import '../common/widgets/edit_goal_dialog.dart';
import '../profileinfo/health_detail.dart' show Gender;

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetStepsController = TextEditingController();
  final TextEditingController _targetWaterController = TextEditingController();

  File? _imageFile;
  Gender _gender = Gender.male;
  int _waterLogAmountMl = kDefaultWaterLogAmountMl;
  double _selectedWaterTarget = kDefaultTargetWaterLiters;
  final List<double> _waterTargetOptions = [
    1.5,
    2.0,
    2.5,
    3.0,
    3.5,
    4.0,
    4.5,
    5.0,
    6.0,
  ];
  bool _isLoading = true;
  bool _isSaving = false;

  String _goal = 'maintainWeight';
  String _activity = 'lightlyActive';
  static const _goalLabels = {
    'lossWeight': 'Weight Loss',
    'gainWeight': 'Weight Gain',
    'maintainWeight': 'Maintain Weight',
    'gainMuscle': 'Muscle Gain',
    'lifeStyleImprove': 'Lifestyle Improvement',
  };
  static const _activityLabels = {
    'sedentary': 'Sedentary',
    'lightlyActive': 'Lightly Active',
    'moderatelyActive': 'Moderately Active',
    'veryActive': 'Very Active',
    'extraActive': 'Extra Active',
  };

  final List<int> _waterPresetOptions = [150, 200, 250, 300, 350, 500];

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _goal = prefs.getString(PrefKeys.healthGoal) ?? 'maintainWeight';
      _activity = prefs.getString(PrefKeys.activityLevel) ?? 'lightlyActive';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadGoal();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetStepsController.dispose();
    _targetWaterController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString(PrefKeys.userName) ?? '';
    final imagePath = prefs.getString(PrefKeys.profileImagePath);
    final genderStr = prefs.getString(PrefKeys.gender) ?? Gender.male.name;
    final logAmount =
        prefs.getInt(PrefKeys.waterLogAmountMl) ?? kDefaultWaterLogAmountMl;
    final steps = prefs.getInt(PrefKeys.targetSteps) ?? kDefaultTargetSteps;
    final waterTarget =
        prefs.getDouble(PrefKeys.targetWaterLiters) ??
        kDefaultTargetWaterLiters;

    Gender loadedGender = Gender.male;
    for (final g in Gender.values) {
      if (g.name.toLowerCase() == genderStr.toLowerCase()) {
        loadedGender = g;
        break;
      }
    }

    File? file;
    if (imagePath != null && await File(imagePath).exists()) {
      file = File(imagePath);
    }

    final normalizedWaterTarget = double.parse(waterTarget.toStringAsFixed(1));
    if (!_waterTargetOptions.any(
      (opt) => (opt - normalizedWaterTarget).abs() < 0.05,
    )) {
      _waterTargetOptions.add(normalizedWaterTarget);
      _waterTargetOptions.sort();
    }

    if (mounted) {
      setState(() {
        _nameController.text = name;
        _imageFile = file;
        _gender = loadedGender;
        _waterLogAmountMl = logAmount;
        _targetStepsController.text = steps.toString();
        _selectedWaterTarget = normalizedWaterTarget;
        _targetWaterController.text = _selectedWaterTarget.toStringAsFixed(1);
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final ext = picked.path.split('.').last;
    final savedPath = '${appDir.path}/profile_image.$ext';

    final prefs = await SharedPreferences.getInstance();
    final oldPath = prefs.getString(PrefKeys.profileImagePath);

    final savedFile = await File(picked.path).copy(savedPath);
    await FileImage(savedFile).evict();
    await prefs.setString(PrefKeys.profileImagePath, savedFile.path);

    if (oldPath != null && oldPath != savedFile.path) {
      final oldFile = File(oldPath);
      await FileImage(oldFile).evict();
      if (await oldFile.exists()) await oldFile.delete();
    }

    if (!mounted) return;
    setState(() {
      _imageFile = savedFile;
    });
  }

  Future<void> _saveProfile() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSaving = true;
    });

    final prefs = await SharedPreferences.getInstance();

    // 1. Name
    await prefs.setString(PrefKeys.userName, _nameController.text.trim());

    // 2. Image
    if (_imageFile != null) {
      await prefs.setString(PrefKeys.profileImagePath, _imageFile!.path);
    }

    // 3. Gender
    await prefs.setString(PrefKeys.gender, _gender.name);

    // 4. Water Log Amount (ml)
    await prefs.setInt(PrefKeys.waterLogAmountMl, _waterLogAmountMl);

    // 5. Target Steps
    final steps =
        int.tryParse(_targetStepsController.text.trim()) ?? kDefaultTargetSteps;
    await prefs.setInt(PrefKeys.targetSteps, steps.clamp(1000, 100000));

    // 6. Target Water (Liters)
    await prefs.setDouble(
      PrefKeys.targetWaterLiters,
      _selectedWaterTarget.clamp(0.5, 15.0),
    );

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Profile & targets updated successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop(true);
    }
  }

  String _genderLabel(Gender g) {
    switch (g) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.preferNotToSay:
        return 'Prefer Not to Say';
    }
  }

  IconData _genderIcon(Gender g) {
    switch (g) {
      case Gender.male:
        return Icons.male_rounded;
      case Gender.female:
        return Icons.female_rounded;
      case Gender.other:
        return Icons.transgender_rounded;
      case Gender.preferNotToSay:
        return Icons.person_outline_rounded;
    }
  }

  void _showEditStepGoalBottomSheet() {
    HapticFeedback.lightImpact();
    final currentSteps =
        int.tryParse(_targetStepsController.text.trim()) ?? kDefaultTargetSteps;
    final TextEditingController tempController = TextEditingController(
      text: currentSteps.toString(),
    );
    final presets = [6000, 8000, 10000, 12000, 15000];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2E7D32,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.directions_walk_rounded,
                            color: Color(0xFF2E7D32),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Step Goal',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Recommended: 8,000 - 10,000 steps',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tempController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Target Steps',
                        hintText: 'e.g. 10000',
                        suffixText: 'steps',
                        suffixStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (_) {
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Quick Presets',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presets.map((p) {
                        final isSelected =
                            tempController.text.trim() == p.toString();
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            tempController.text = p.toString();
                            setSheetState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2E7D32)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              '$p steps',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final parsed = int.tryParse(
                            tempController.text.trim(),
                          );
                          if (parsed != null &&
                              parsed >= 1000 &&
                              parsed <= 100000) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _targetStepsController.text = parsed.toString();
                            });
                            Navigator.pop(sheetContext);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid step goal (1,000 - 100,000)',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Update Goal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Picker
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primary.withValues(alpha: 0.2),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: const Color(0xFFE2E8F0),
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : null,
                              child: _imageFile == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 54,
                                      color: Color(0xFF94A3B8),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: _pickImage,
                        child: const Text(
                          'Change Profile Picture',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Personal Information Section
                    _buildSectionHeader('PERSONAL INFORMATION'),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: 'Enter your name',
                              prefixIcon: const Icon(
                                Icons.badge_outlined,
                                size: 20,
                                color: Color(0xFF94A3B8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: Gender.values.map((g) {
                              final isSelected = _gender == g;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _gender = g;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primary
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? primary
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _genderIcon(g),
                                        size: 18,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF475569),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _genderLabel(g),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Hydration Configuration Section
                    _buildSectionHeader('WATER INTAKE LOGGING'),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0284C7,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.water_drop_rounded,
                                  color: Color(0xFF0284C7),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantity Per Log',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Amount added per tap in-app and via notification action',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0284C7,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$_waterLogAmountMl ml',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _waterPresetOptions.map((ml) {
                              final isSelected = _waterLogAmountMl == ml;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _waterLogAmountMl = ml;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0284C7)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$ml ml',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Daily Goals / Targets Section
                    _buildSectionHeader('DAILY HEALTH TARGETS'),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        children: [
                          // Target Steps
                          InkWell(
                            onTap: _showEditStepGoalBottomSheet,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2E7D32,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.directions_walk_rounded,
                                      color: Color(0xFF2E7D32),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Daily Step Goal',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Recommended: 8,000 - 10,000 steps',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${_targetStepsController.text.isEmpty ? '8000' : _targetStepsController.text} steps',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.edit_outlined,
                                          size: 15,
                                          color: Color(0xFF64748B),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          // Target Water
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00569F,
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.local_drink_rounded,
                                  color: Color(0xFF00569F),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Water Goal',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Recommended: 2.5 - 4.0 Liters',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<double>(
                                    value: _selectedWaterTarget,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF64748B),
                                    ),
                                    isDense: true,
                                    borderRadius: BorderRadius.circular(12),
                                    items: _waterTargetOptions.map((
                                      double value,
                                    ) {
                                      return DropdownMenuItem<double>(
                                        value: value,
                                        child: Text(
                                          '${value.toStringAsFixed(1)} L',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (double? newValue) {
                                      if (newValue != null) {
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          _selectedWaterTarget = newValue;
                                          _targetWaterController.text = newValue
                                              .toStringAsFixed(1);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('RE-CALIBRATE GOAL'),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: InkWell(
                        onTap: () async {
                          await showEditGoalDialog(context);
                          _loadGoal();
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.flag_rounded, color: primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _goalLabels[_goal] ?? _goal,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    _activityLabels[_activity] ?? _activity,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              'Change',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SpringButton(
                      SpringButtonType.onlyScale,
                      onTap: _isSaving ? null : _saveProfile,
                      uiChild: Container(
                        width: double.infinity,
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: black,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isSaving
                            ? const CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
