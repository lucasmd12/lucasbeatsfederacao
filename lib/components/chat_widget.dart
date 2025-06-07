import 'package:flutter/material.dart';
import 'package:lucasbeatsfederacao/models/message_model.dart';

class ChatWidget extends StatelessWidget {
  final List<MessageModel> messages;
  final bool isLoading;
  final Function(String) onSendMessage;
  final Function() onRefresh;

  const ChatWidget({
    Key? key,
    required this.messages,
    this.isLoading = false,
    required this.onSendMessage,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ListTile(
                        title: Text(message.senderId),
                        subtitle: Text(message.content),
                        trailing: Text(message.timestamp.toLocal().toString().split(
                            '.')[0]), // Format timestamp for display
                      );
                    },
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Digite uma mensagem...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onSubmitted: onSendMessage,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  // Implement message sending logic here
                  // For now, we'll just call onSendMessage with a dummy text
                  onSendMessage('Mensagem de teste');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}


