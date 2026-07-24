import 'package:hive/hive.dart';

part 'chat_message_model.g.dart';

@HiveType(typeId: 10)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final bool isUser;

  @HiveField(2)
  final DateTime time;

  @HiveField(3)
  final String sessionId;

  @HiveField(4)
  final String? thinkingText;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    required this.sessionId,
    this.thinkingText,
  });
}