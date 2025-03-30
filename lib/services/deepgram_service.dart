import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:lingowise/services/translation_service.dart';

class DeepgramService {
  final String deepgramApiKey = "8496509144871c7ea74eae3ec336989b8582900a";
  final TranslationService _translationService = TranslationService();
  WebSocketChannel? _socket;
  Function(String, String)? onTranscriptionReceived;
  Function(String)? onError;

  Future<void> init() async {
    await _translationService.init();
  }

  void connectToDeepgram({
    Function(String, String)? onData,
    Function(String)? onError,
  }) {
    onTranscriptionReceived = onData;
    this.onError = onError;

    try {
      final uri = Uri.parse(
        "wss://api.deepgram.com/v1/listen?access_token=$deepgramApiKey&encoding=linear16&sample_rate=16000",
      );

      _socket = WebSocketChannel.connect(uri);

      _socket!.stream.listen(
        (data) async {
          try {
            final response = jsonDecode(data);
            if (response["channel"]["alternatives"].isNotEmpty) {
              String transcript =
                  response["channel"]["alternatives"][0]["transcript"];

              // Use TranslationService to translate with user-selected language
              String translatedText = await _translationService.translate(transcript);

              if (onTranscriptionReceived != null) {
                onTranscriptionReceived!(transcript, translatedText);
              }
            }
          } catch (e) {
            print("Error processing transcription: $e");
            if (this.onError != null) {
              this.onError!("Error processing transcription: $e");
            }
          }
        },
        onError: (error) {
          print("WebSocket Error: $error");
          if (this.onError != null) {
            this.onError!("WebSocket Error: $error");
          }
        },
        onDone: () {
          print("WebSocket Closed");
          if (this.onError != null) {
            this.onError!("WebSocket connection closed");
          }
        },
      );
    } catch (e) {
      print("Error connecting to Deepgram: $e");
      if (this.onError != null) {
        this.onError!("Error connecting to Deepgram: $e");
      }
    }
  }

  void sendAudioData(List<int> audioData) {
    try {
      _socket?.sink.add(audioData);
    } catch (e) {
      print("Error sending audio data: $e");
      if (onError != null) {
        onError!("Error sending audio data: $e");
      }
    }
  }

  void closeConnection() {
    try {
      _socket?.sink.close();
    } catch (e) {
      print("Error closing connection: $e");
      if (onError != null) {
        onError!("Error closing connection: $e");
      }
    }
  }
}
