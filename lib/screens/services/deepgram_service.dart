import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class DeepgramService {
  final String deepgramApiKey = "8496509144871c7ea74eae3ec336989b8582900a";
  final String googleTranslateApiKey =
      "AIzaSyAHGIdW9Zz4tGMcDjS_AnQcmwKB-bdH25w";
  final String targetLanguage = "es"; // 🔹 Change this to your target language

  WebSocketChannel? _socket;
  Function(String, String)? onTranscriptionReceived;

  void connectToDeepgram({Function(String, String)? onData}) {
    onTranscriptionReceived = onData;

    final uri = Uri.parse(
      "wss://api.deepgram.com/v1/listen?access_token=$deepgramApiKey&encoding=linear16&sample_rate=16000",
    );

    _socket = WebSocketChannel.connect(uri);

    _socket!.stream.listen(
      (data) async {
        final response = jsonDecode(data);
        if (response["channel"]["alternatives"].isNotEmpty) {
          String transcript =
              response["channel"]["alternatives"][0]["transcript"];

          // 🔹 Translate the text
          String translatedText = await translateText(transcript);

          if (onTranscriptionReceived != null) {
            onTranscriptionReceived!(transcript, translatedText);
          }
        }
      },
      onError: (error) => print("WebSocket Error: $error"),
      onDone: () => print("WebSocket Closed"),
    );
  }

  void sendAudioData(List<int> audioData) {
    _socket?.sink.add(audioData);
  }

  void closeConnection() {
    _socket?.sink.close();
  }

  Future<String> translateText(String text) async {
    final url = Uri.parse(
      "https://translation.googleapis.com/language/translate/v2?key=$googleTranslateApiKey",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"q": text, "target": targetLanguage, "format": "text"}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse["data"]["translations"][0]["translatedText"];
    } else {
      print("Translation Error: ${response.body}");
      return text; // Return original text if translation fails
    }
  }
}
