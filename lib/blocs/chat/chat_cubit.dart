import 'dart:convert';
import 'dart:developer' as dev;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../models/chat/chat_message_model.dart';
import '../../models/chat/chat_session_model.dart';
import '../../services/chat_hive_service.dart';

part 'chat_state.dart';


class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  final List<ChatMessage> _messages = [];
  String? _currentSessionId;

  static const _apiKey = 'AIzaSyD8yw635mL0Bsd0WIOblJPbkaS5maznoIY';
  static const _model = 'gemini-2.5-flash';
  static const _url =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

  Future<void> startNewSession() async {
    _messages.clear();
    _currentSessionId = const Uuid().v4();
    final session = ChatSession(
      id: _currentSessionId!,
      title:
      'Chat ${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      createdAt: DateTime.now(),
    );
    await ChatHiveService.instance.saveSession(session);
    emit(ChatUpdated(messages: []));
  }

  Future<void> loadSession(String sessionId) async {
    _currentSessionId = sessionId;
    final msgs = ChatHiveService.instance.getMessages(sessionId);
    _messages
      ..clear()
      ..addAll(msgs);
    emit(ChatUpdated(messages: List.from(_messages)));
  }

  Future<void> sendMessage({
    required String userText,
    required Map<String, dynamic> healthContext,
  }) async {
    if (_currentSessionId == null) await startNewSession();

    final userMsg = ChatMessage(
      text: userText,
      isUser: true,
      time: DateTime.now(),
      sessionId: _currentSessionId!,
    );
    await ChatHiveService.instance.saveMessage(userMsg);
    _messages.add(userMsg);
    emit(ChatUpdated(messages: List.from(_messages), isLoading: true));

    final systemContext = '''
You are a personal health assistant. Today's user data:
- Steps: ${healthContext['steps'] ?? 'N/A'}
- Water: ${healthContext['water'] ?? 'N/A'} ml
- Calories consumed: ${healthContext['calories'] ?? 'N/A'} kcal
- Protein: ${healthContext['protein'] ?? 'N/A'}g | Carbs: ${healthContext['carbs'] ?? 'N/A'}g | Fat: ${healthContext['fat'] ?? 'N/A'}g
- Sleep: ${healthContext['sleep'] ?? 'N/A'} hrs
- Weight: ${healthContext['weight'] ?? 'N/A'} kg
Answer health questions based on this data. Be concise and friendly. Use markdown for formatting.
''';

    final contents = _messages
        .map((m) => {
      'role': m.isUser ? 'user' : 'model',
      'parts': [
        {'text': m.text}
      ],
    })
        .toList();

    try {
      final res = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {'text': systemContext}
            ]
          },
          'contents': contents,
        }),
      );

      if (res.statusCode != 200) {
        throw Exception('API error ${res.statusCode}: ${res.body}');
      }

      final data = jsonDecode(res.body);
      dev.log(data.toString());

      if (data['candidates'] != null &&
          (data['candidates'] as List).isNotEmpty &&
          data['candidates'][0]['content'] != null) {
        final reply =
        data['candidates'][0]['content']['parts'][0]['text'] as String;

        final aiMsg = ChatMessage(
          text: reply,
          isUser: false,
          time: DateTime.now(),
          sessionId: _currentSessionId!,
        );
        await ChatHiveService.instance.saveMessage(aiMsg);
        _messages.add(aiMsg);
        emit(ChatUpdated(messages: List.from(_messages), isLoading: false));
      } else {
        throw Exception('Unexpected response structure');
      }
    } catch (e, s) {
      dev.log('Exception from chat', error: e, stackTrace: s);

      String userErrorMessage = 'Something went wrong. Please try again.';
      if (e.toString().contains('429')) {
        userErrorMessage = 'Too many requests. Please wait a moment.';
      }

      final errMsg = ChatMessage(
        text: userErrorMessage,
        isUser: false,
        time: DateTime.now(),
        sessionId: _currentSessionId!,
      );
      await ChatHiveService.instance.saveMessage(errMsg);
      _messages.add(errMsg);
      emit(ChatUpdated(messages: List.from(_messages), isLoading: false));
    }
  }

  void clearChat() {
    _messages.clear();
    _currentSessionId = null;
    emit(ChatInitial());
  }
}
