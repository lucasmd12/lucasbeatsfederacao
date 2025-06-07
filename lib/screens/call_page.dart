import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/call_provider.dart';

class CallPage extends ConsumerWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callProvider = ref.watch(callProviderNotifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(callProvider.currentChannel?.name ?? 'Chamada em Andamento'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exibir participantes
            if (callProvider.participants.isNotEmpty)
              ...callProvider.participants.map((user) => Text(user.name)),
            
            // Placeholder para vídeo local/remoto (se houver)
            if (callProvider.localStream != null)
              // TODO: Implementar widget para exibir o vídeo local
              const Text('Vídeo Local (implementar)'),
            if (callProvider.remoteStream != null)
              // TODO: Implementar widget para exibir o vídeo remoto
              const Text('Vídeo Remoto (implementar)'),

            const SizedBox(height: 20),
            Text(
              callProvider.isInCall
                  ? 'Conectado ao canal de voz'
                  : 'Não conectado',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(callProvider.isMuted ? Icons.mic_off : Icons.mic),
                  onPressed: () {
                    callProvider.toggleMute();
                  },
                ),
                IconButton(
                  icon: Icon(callProvider.isCameraOff ? Icons.videocam_off : Icons.videocam),
                  onPressed: () {
                    callProvider.toggleCamera();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.red),
                  onPressed: () {
                    callProvider.leaveVoiceChannel();
                    Navigator.of(context).pop(); // Voltar para a tela anterior
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


