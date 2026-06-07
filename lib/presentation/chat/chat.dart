import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../blocs/chat/chat_cubit.dart';
import '../../blocs/nutrition/nutrition_cubit.dart';
import '../../blocs/sleep/sleep_cubit.dart';
import '../../blocs/step/step_cubit.dart';
import '../../blocs/water/water_cubit.dart';
import '../../blocs/weight/weight_cubit.dart';
import '../../models/chat/chat_message_model.dart';
import '../../services/chat_hive_service.dart';


const Color _bg = Color(0xFFF6F6F9);
const Color _card = Color(0xFFFFFFFF);
const Color _textPrimary = Color(0xFF1A1A1A);
const Color _textSecondary = Color(0xFF757575);

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic> get _healthContext {
    // Steps
    final stepsState = context
        .read<StepsCubit>()
        .state;
    final steps = stepsState is StepSuccessState
        ? stepsState.stepModel.fold<double>(
        0, (s, e) => s + (e.value?.numericValue ?? 0)).toInt()
        : 0;

    // Water (liters → ml)
    final waterState = context
        .read<WaterCubit>()
        .state;
    final water = waterState is WaterSuccessState
        ? (waterState.waterModel.fold<double>(
        0, (s, e) => s + (e.value?.numericValue ?? 0)) * 1000).toInt()
        : 0;

    // Nutrition
    final nutritionState = context
        .read<NutritionCubit>()
        .state;
    final nutritionItems = nutritionState is NutritionSuccess ? nutritionState
        .nutritionModel : [];
    final calories = nutritionItems.fold<double>(
        0, (s, e) => s + (e.value?.calories ?? 0));
    final protein = nutritionItems.fold<double>(
        0, (s, e) => s + (e.value?.protein ?? 0));
    final carbs = nutritionItems.fold<double>(
        0, (s, e) => s + (e.value?.carbs ?? 0));
    final fat = nutritionItems.fold<double>(
        0, (s, e) => s + (e.value?.fat ?? 0));

    // Sleep (minutes → hours)
    final sleepState = context
        .read<SleepCubit>()
        .state;
    final sleep = sleepState is SleepSuccessState
        ? double.parse(((sleepState.sleepModel.fold<double>(
        0, (s, e) => s + (e.value?.numericValue ?? 0))) / 60).toStringAsFixed(
        1))
        : 0.0;

    // Weight
    final weightState = context
        .read<WeightCubit>()
        .state;
    final weight = weightState is WeightSuccess
        ? weightState.weightModel.first.value?.numericValue?.toStringAsFixed(1)
        : 'N/A';

    return {
      'steps': steps,
      'water': water,
      'calories': calories.toInt(),
      'protein': protein.toStringAsFixed(1),
      'carbs': carbs.toStringAsFixed(1),
      'fat': fat.toStringAsFixed(1),
      'sleep': sleep,
      'weight': weight,
      'currentTime': DateTime.now()
    };
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<ChatCubit>().sendMessage(
      userText: text,
      healthContext: _healthContext,
    );
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          'AI Health Chat',
          style: TextStyle(
              color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(
                CupertinoIcons.clock, color: _textSecondary, size: 20),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          IconButton(
            icon: const Icon(
                CupertinoIcons.square_pencil, color: _textSecondary, size: 20),
            onPressed: () => context.read<ChatCubit>().startNewSession(),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state is ChatUpdated) {
                  Future.delayed(
                      const Duration(milliseconds: 100), _scrollToBottom);
                }
              },
              builder: (context, state) {
                if (state is ChatInitial) return _buildEmptyState();
                if (state is ChatUpdated) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: state.messages.length + (state.isLoading &&
                        state.messages.lastOrNull?.text.isEmpty == true
                        ? 1
                        : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length)
                        return _buildTypingIndicator();
                      return _buildBubble(state.messages[index]);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          _buildInputBar(),
          const SizedBox(height: kToolbarHeight + 20,)
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.chat_bubble_2, size: 64,
              color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Ask me about your health today',
              style: TextStyle(color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('e.g. "How are my macros today?"',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    final hasThinking = msg.thinkingText != null &&
        msg.thinkingText!.isNotEmpty;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment
            .start,
        children: [
          // Thinking expander (only for AI messages)
          if (!isUser && hasThinking)
            _ThinkingBlock(thinkingText: msg.thinkingText!),

          Container(
            margin: const EdgeInsets.only(bottom: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery
                .of(context)
                .size
                .width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? Colors.black : _card,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: msg.text.isEmpty
                ? const _TypingDots() // still streaming answer
                : MarkdownBody(
              data: msg.text,
              softLineBreak: true,
              styleSheet: MarkdownStyleSheet
                  .fromTheme(Theme.of(context))
                  .copyWith(
                p: TextStyle(color: isUser ? Colors.white : _textPrimary,
                    fontSize: 14,
                    height: 1.5),
                strong: TextStyle(color: isUser ? Colors.white : _textPrimary,
                    fontWeight: FontWeight.bold),
                listBullet: TextStyle(
                    color: isUser ? Colors.white : _textPrimary, fontSize: 14),
                h2: TextStyle(color: isUser ? Colors.white : _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                h3: TextStyle(color: isUser ? Colors.white : _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
                blockSpacing: 8,
                listIndent: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: const _TypingDots(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery
          .of(context)
          .padding
          .bottom + 10),
      decoration: BoxDecoration(
        color: _card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: _controller,
              placeholder: 'Ask about your health...',
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(20),
              ),
              onSubmitted: (_) => _send(),
              textInputAction: TextInputAction.send,
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                  CupertinoIcons.arrow_up, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final sessions = ChatHiveService.instance.getSessions();
    return Drawer(
      backgroundColor: _bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text('History',
                      style: TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                        CupertinoIcons.xmark, size: 18, color: _textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: sessions.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.clock, size: 40,
                        color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    const Text('No history yet',
                        style: TextStyle(color: _textSecondary, fontSize: 13)),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: sessions.length,
                itemBuilder: (context, i) {
                  final s = sessions[i];
                  return Dismissible(
                    key: ValueKey(s.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      padding: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                          CupertinoIcons.delete, color: Colors.white, size: 18),
                    ),
                    onDismissed: (_) async {
                      await ChatHiveService.instance.deleteSession(s.id);
                      setState(() {});
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(CupertinoIcons.chat_bubble_text,
                            size: 16, color: Colors.black54),
                      ),
                      title: Text(s.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        '${s.createdAt.day}/${s.createdAt.month}/${s.createdAt
                            .year}',
                        style: const TextStyle(color: _textSecondary,
                            fontSize: 11),
                      ),
                      onTap: () {
                        context.read<ChatCubit>().loadSession(s.id);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final opacity = ((_ctrl.value * 3 - i) % 1).clamp(0.2, 1.0);
            return Container(
              width: 6,
              height: 6,
              margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
              decoration: BoxDecoration(
                color: _textSecondary.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

class _ThinkingBlock extends StatefulWidget {
  final String thinkingText;

  const _ThinkingBlock({required this.thinkingText});

  @override
  State<_ThinkingBlock> createState() => _ThinkingBlockState();
}

class _ThinkingBlockState extends State<_ThinkingBlock> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1), // Subtle background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Theme(
        // Hides the default borders ExpansionTile adds
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false, // DEFAULT IS COLLAPSED
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          minTileHeight: 40,
          title: Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Thought Process',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.thinkingText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic, // Differentiates from normal text
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}