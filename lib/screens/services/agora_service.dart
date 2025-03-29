import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraService {
  static final _engine = createAgoraRtcEngine();

  static Future<void> initialize() async {
    await _engine.initialize(
      const RtcEngineContext(appId: "a33c42c93ff94b729a6ce74486333c7a"),
    );
    await _engine.enableAudio();
  }

  static Future<void> joinCall(String channelName) async {
    String agoraToken =
        "007eJxTYOj+rCK7de2szknVbc06v4pYBBk0LiU0mb78PW/h3gMT0uIVGBKNjZNNjJItjdPSLE2SzI0sE82SU81NTCzMjIEy5onewi/SGwIZGeTMmpkZGSAQxOdkyE0tLk5Mz8xLZ2AAAP"; // Get from Agora Console

    await _engine.joinChannel(
      token: agoraToken,
      channelId: channelName,
      uid: 0, // Agora assigns a random UID
      options: const ChannelMediaOptions(),
    );
  }
}
