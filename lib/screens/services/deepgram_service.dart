import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class DeepgramService {
  final String deepgramApiKey = "YOUR_DEEPGRAM_API_KEY";
  WebSocketChannel? _socket;

  void connectToDeepgram() {
    final uri = Uri.parse(
      "wss://api.deepgram.com/v1/listen?access_token=$deepgramApiKey&encoding=linear16&sample_rate=16000",
    );

    _socket = WebSocketChannel.connect(uri);

    _socket!.stream.listen((data) {
      final response = jsonDecode(data);
      if (response["channel"]["alternatives"].isNotEmpty) {
        print(
          "Transcription: ${response["channel"]["alternatives"][0]["transcript"]}",
        );
      }
    });
  }

  void sendAudioData(List<int> audioData) {
    _socket?.sink.add(audioData);
  }

  void closeConnection() {
    _socket?.sink.close();
  }
}
