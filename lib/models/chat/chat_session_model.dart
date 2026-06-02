import 'package:hive/hive.dart';

part 'chat_session_model.g.dart';

@HiveType(typeId: 11)
class ChatSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
  });
}