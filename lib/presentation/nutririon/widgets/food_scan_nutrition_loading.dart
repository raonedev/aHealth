// Your Palette Mapping
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/food_scan/food_scan_cubit.dart';
import '../food_scan_result_screen.dart';

const Color _sheetBg = Color(0xFFF6F6F9); // _bg
const Color _sheetCard = Color(0xFFFFFFFF); // _card
const Color _sheetTextPrimary = Color(0xFF1A1A1A); // _textPrimary
const Color _sheetTextSecondary = Color(0xFF757575); // _textSecondary

class FoodScanLoadingSheet extends StatelessWidget {
  const FoodScanLoadingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FoodScanCubit, FoodScanState>(
      listener: (context, state) {
        if (state is FoodScanSuccess) {
          Navigator.pop(context); // close sheet
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<FoodScanCubit>(),
                child: FoodScanResultScreen(
                  foods: state.foods,
                  imagePath: state.imagePath,
                  groupUuid: state.groupUuid,
                ),
              ),
            ),
          );
        } else if (state is FoodScanError || state is FoodScanNoItems) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state is FoodScanError
                    ? state.message
                    : 'No food items detected in the image.',
              ),
            ),
          );
        }
      },
      child: BlocBuilder<FoodScanCubit, FoodScanState>(
        builder: (context, state) {
          final thinking = state is FoodScanThinking ? state.thinkingText : '';

          return Container(
            decoration: const BoxDecoration(
              color: _sheetBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Notch Handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _sheetTextSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Main Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _sheetCard,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Styled Activity Wrapper
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _sheetBg,
                          shape: BoxShape.circle,
                        ),
                        child: const CupertinoActivityIndicator(radius: 14),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Analyzing Your Food',
                        style: TextStyle(
                          color: _sheetTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'AI is reading nutrition facts...',
                        style: TextStyle(
                          color: _sheetTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // AI Thoughts Dynamic Section
                if (thinking.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _sheetCard.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _sheetTextSecondary.withValues(alpha: 0.08),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                thinking,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _sheetTextSecondary,
                                  height: 1.4,
                                  fontFamily: 'Roboto', // cleaner read
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Added placeholder spacing matching constraints when not thinking
                  const SizedBox(height: 40),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
