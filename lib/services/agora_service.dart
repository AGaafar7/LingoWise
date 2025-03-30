import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:lingowise/services/agora_token_generaor.dart';

class AgoraService {
  static final _engine = createAgoraRtcEngine();

  static Future<void> initialize() async {
    await _engine.initialize(
      const RtcEngineContext(appId: "a33c42c93ff94b729a6ce74486333c7a"),
    );
    await _engine.enableAudio();
  }

  static Future<void> joinCall(String channelName) async {
    String appId = "a33c42c93ff94b729a6ce74486333c7a";
    String appCertificate =
        "7c08652be9f34ac6924f47a5a288abd2"; // ⚠️ Do not expose in production!
    int uid = 0;

    // Generate token dynamically
    String agoraToken = AgoraTokenGenerator.generateToken(
      appId: appId,
      appCertificate: appCertificate,
      channelName: channelName,
      uid: uid,
    );

    await _engine.joinChannel(
      token: agoraToken,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(),
    );
  }

  static RtcEngine get engine => _engine;
}
