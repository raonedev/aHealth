part of 'chat_cubit.dart';

sealed class ChatState extends Equatable {
  const ChatState();
}

final class ChatInitial extends ChatState {
  @override
  List<Object> get props => [];
}


final class ChatUpdated extends ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isThinking;
  const ChatUpdated({required this.messages, this.isLoading = false,this.isThinking = false,});

  @override
  List<Object?> get props => [
    isLoading,
    messages,
    isThinking,
  ];
}


