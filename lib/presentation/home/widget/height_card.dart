import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/height/height_cubit.dart';
import '../../../common/spring_button_widget.dart';
import '../../../helper/helper_func.dart';

class HeightCard extends StatefulWidget {
  const HeightCard({super.key});

  @override
  State<HeightCard> createState() => _HeightCardState();
}

class _HeightCardState extends State<HeightCard> {
  bool _useFeet = false;

final _kPrimary = Color(0xFF0D631B);
final _kOnSurfaceVariant = Color(0xFF40493D);
final _kSurfaceContainerLowest = Color(0xFFFFFFFF);
final _kSurfaceContainerHighest = Color(0xFFE3E2E2);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showHeightDialog(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _kSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BlocBuilder<HeightCubit, HeightState>(
          builder: (context, state) {
            Widget trailing;
            if (state is HeightLoading) {
              trailing = const CupertinoActivityIndicator();
            } else if (state is HeightFailed) {
              trailing = Text(state.errorMessage,
                  style: const TextStyle(fontSize: 12, color: Colors.red));
            } else if (state is HeightSuccess && state.heightModel.isNotEmpty) {
              final meters = state.heightModel[0].value?.numericValue;
              trailing = meters != null
                  ? Text.rich(
                      TextSpan(
                        text: _useFeet
                            ? '${(meters * 3.28084).toStringAsFixed(2)} '
                            : '${(meters * 100).toStringAsFixed(1)} ',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(
                            text: _useFeet ? 'ft' : 'cm',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    )
                  : const Text('UNKNOWN', style: TextStyle(fontSize: 20));
            } else {
              trailing = const Text('No Height Data', style: TextStyle(fontSize: 12));
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.straighten, color: _kOnSurfaceVariant, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'HEIGHT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: _kOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _unitToggle('cm', !_useFeet, () => setState(() => _useFeet = false)),
                    const SizedBox(width: 8),
                    _unitToggle('ft', _useFeet, () => setState(() => _useFeet = true)),
                    const SizedBox(width: 12),
                    trailing,
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _unitToggle(String label, bool selected, VoidCallback onTap) {
    return SpringButton(
      SpringButtonType.withOpacity,
      onTap: onTap,
      uiChild: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? _kPrimary : _kSurfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _kOnSurfaceVariant,
          ),
        ),
      ),
    );
  }
}