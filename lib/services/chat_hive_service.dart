import 'package:hive_flutter/hive_flutter.dart';

import '../models/chat/chat_message_model.dart';
import '../models/chat/chat_session_model.dart';

class ChatHiveService {
  static final instance = ChatHiveService._();
  ChatHiveService._();

  static const _sessionsBox = 'chat_sessions';
  static const _messagesBox = 'chat_messages';

  Future<void> openBoxes() async {
    await Hive.openBox<ChatSession>(_sessionsBox);
    await Hive.openBox<ChatMessage>(_messagesBox);
  }

  Box<ChatSession> get _sessions => Hive.box<ChatSession>(_sessionsBox);
  Box<ChatMessage> get _messages => Hive.box<ChatMessage>(_messagesBox);

  Future<void> saveSession(ChatSession session) async {
    await _sessions.put(session.id, session);
  }

  List<ChatSession> getSessions() {
    return _sessions.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> deleteSession(String sessionId) async {
    await _sessions.delete(sessionId);
    final keys = _messages.keys.where((k) => (k as String).startsWith(sessionId));
    await _messages.deleteAll(keys.toList());
  }

  Future<void> saveMessage(ChatMessage msg) async {
    final key = '${msg.sessionId}_${msg.time.millisecondsSinceEpoch}';
    await _messages.put(key, msg);
  }

  List<ChatMessage> getMessages(String sessionId) {
    return _messages.values
        .where((m) => m.sessionId == sessionId)
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }
}