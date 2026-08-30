import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../blocs/food_scan/food_scan_cubit.dart';
import '../food_scan_result_screen.dart';

class FoodVoiceInputSheet extends StatefulWidget {
  const FoodVoiceInputSheet({super.key});

  @override
  State<FoodVoiceInputSheet> createState() => _FoodVoiceInputSheetState();
}

class _FoodVoiceInputSheetState extends State<FoodVoiceInputSheet> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';
  bool _editing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _startListening();
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize(
      onError: (val) => _stopListening(),
    );
    if (!available) return;

    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
          _controller.text = _text;
        });
      },
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _editing = true;
    });
  }

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    context.read<FoodScanCubit>().scanFoodText(
          textInput: _controller.text.trim(),
          groupUuid: DateTime.now().millisecondsSinceEpoch.toString(),
        );
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
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
                      : 'No food items detected.',
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: BlocBuilder<FoodScanCubit, FoodScanState>(
              builder: (context, state) {
                
            if (state is FoodScanLoading) {
              return Padding(
                padding: const EdgeInsets.only(bottom: kToolbarHeight*2),
                child: SizedBox(
                  height: 160,
                  width: 160,
                  child: Lottie.asset(
                    'assets/lottieanimations/voice_input.json',
                    animate: true,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_editing) ...[
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Lottie.asset(
                      'assets/lottieanimations/voice_input.json',
                      animate: _isListening,
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Text(
                        _text.isEmpty ? 'Listening...' : _text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _stopListening,
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Done'),
                      ),
                    ],
                  )
                ] else ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Edit Description',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.mic_none),
                              onPressed: () {
                                setState(() => _editing = false);
                                _startListening();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _controller,
                          maxLines: 3,
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Edit your food description',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Log Food'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ],
            );
          }),
        ));
  }
}
