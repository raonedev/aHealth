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
  const ChatUpdated({required this.messages, this.isLoading = false});

  @override
  // TODO: implement props
  List<Object?> get props => [
    isLoading,
    messages,
  ];
}


