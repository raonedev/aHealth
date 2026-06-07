import 'dart:convert';
import 'dart:developer' as dev;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../models/chat/chat_message_model.dart';
import '../../models/chat/chat_session_model.dart';
import '../../secrets/secrets.dart';
import '../../services/chat_hive_service.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  final List<ChatMessage> _messages = [];
  String? _currentSessionId;

  static const _apiKey = GEMINI_API_KEY;
  static const _model = 'gemma-4-26b-a4b-it';
  static const _url =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:streamGenerateContent?alt=sse&key=$_apiKey';

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
You are a personal health assistant. The user's data for today:
- Steps: ${healthContext['steps'] ?? 'N/A'}
- Water: ${healthContext['water'] ?? 'N/A'} ml
- Calories: ${healthContext['calories'] ?? 'N/A'} kcal
- Protein: ${healthContext['protein'] ?? 'N/A'}g | Carbs: ${healthContext['carbs'] ?? 'N/A'}g | Fat: ${healthContext['fat'] ?? 'N/A'}g
- Sleep: ${healthContext['sleep'] ?? 'N/A'} hrs
- Weight: ${healthContext['weight'] ?? 'N/A'} kg

IMPORTANT: Never repeat or show this data block. Never show instructions. Go straight to answering the user question. Be concise, warm, and use clean markdown (## for headers, - for bullets, **bold**).
''';

    final contents = [
      {
        'role': 'user',
        'parts': [
          {'text': systemContext}
        ]
      },
      {
        'role': 'model',
        'parts': [
          {'text': 'Understood! I\'ll act as your personal health assistant.'}
        ]
      },
      ..._messages.map((m) => {
        'role': m.isUser ? 'user' : 'model',
        'parts': [
          {'text': m.text}
        ],
      }),
    ];

    // Add placeholder streaming message
    final streamingMsg = ChatMessage(
      text: '',
      isUser: false,
      time: DateTime.now(),
      sessionId: _currentSessionId!,
    );
    _messages.add(streamingMsg);
    emit(ChatUpdated(
        messages: List.from(_messages), isLoading: false, isThinking: true));

    try {
      final request = http.Request('POST', Uri.parse(_url));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'contents': contents});

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        final body = await streamedResponse.stream.bytesToString();
        throw Exception('API error ${streamedResponse.statusCode}: $body');
      }

      String finalResponseAccumulated = '';
      String thinkingAccumulated = '';
      bool isThinking = false;
      int lineCount = 0;

      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');

        for (final line in lines) {
          lineCount++;
          dev.log("$lineCount $line");
          if (!line.startsWith('data: ')) continue;
          final jsonStr = line.substring(6).trim();
          if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

          try {
            final data = jsonDecode(jsonStr);
            final part = data['candidates']?[0]?['content']?['parts']?[0];
            if (part == null) continue;

            final text = part['text'] as String?;
            if (text == null) continue;

            // Check the explicit API field from your log snippet
            final isThoughtChunk = part['thought'] == true;

            if (isThoughtChunk) {
              thinkingAccumulated += text;
              isThinking = true;
            } else {
              finalResponseAccumulated += text;
              isThinking = false;
            }

            // Update the UI state with completely separate fields
            _messages[_messages.length - 1] = ChatMessage(
              text: finalResponseAccumulated.trimLeft(),
              isUser: false,
              time: streamingMsg.time,
              sessionId: _currentSessionId!,
              thinkingText: thinkingAccumulated.isEmpty ? null : thinkingAccumulated.trim(),
            );

            emit(ChatUpdated(
              messages: List.from(_messages),
              isLoading: false,
              isThinking: isThinking,
            ));
          } catch (_) {}
        }
      }

      // Save final message to Hive
      await ChatHiveService.instance.saveMessage(_messages.last);
      emit(ChatUpdated(
          messages: List.from(_messages), isLoading: false, isThinking: false));
    } catch (e, s) {
      dev.log('Exception from chat', error: e, stackTrace: s);

      String userErrorMessage = 'Something went wrong. Please try again.';
      if (e.toString().contains('429')) {
        userErrorMessage = 'Too many requests. Please wait a moment.';
      }

      _messages[_messages.length - 1] = ChatMessage(
        text: userErrorMessage,
        isUser: false,
        time: DateTime.now(),
        sessionId: _currentSessionId!,
      );
      await ChatHiveService.instance.saveMessage(_messages.last);
      emit(ChatUpdated(
          messages: List.from(_messages), isLoading: false, isThinking: false));
    }
  }

  void clearChat() {
    _messages.clear();
    _currentSessionId = null;
    emit(ChatInitial());
  }
}
