import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:lingowise/screens/services/agora_token_generaor.dart';
import 'package:lingowise/screens/services/audio_capture_service.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraAudioCallScreen extends StatefulWidget {
  final String channelName;
  final String userId;

  const AgoraAudioCallScreen({
    super.key,
    required this.channelName,
    required this.userId,
  });

  @override
  _AgoraAudioCallScreenState createState() => _AgoraAudioCallScreenState();
}

class _AgoraAudioCallScreenState extends State<AgoraAudioCallScreen> {
  final AudioCaptureService _audioCaptureService = AudioCaptureService();
  RtcEngine? _engine;
  bool _isJoined = false;
  bool _hasError = false;
  String _errorMessage = "";

  final String agoraAppId = "YOUR_APP_ID";
  final String agoraAppCertificate =
      "YOUR_APP_CERTIFICATE"; // ⚠️ Store securely!

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // 🔹 Request microphone permission
    if (await Permission.microphone.request().isDenied) {
      setState(() {
        _hasError = true;
        _errorMessage = "Microphone permission is required!";
      });
      return;
    }

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: agoraAppId));
      await _engine!.enableAudio();
      await _engine!.setChannelProfile(
        ChannelProfileType.channelProfileCommunication,
      );

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int uid) {
            setState(() => _isJoined = true);
            _audioCaptureService.startRecording();
          },
          onUserOffline: (
            RtcConnection connection,
            int uid,
            UserOfflineReasonType reason,
          ) {
            setState(() => _isJoined = false);
            _audioCaptureService.stopRecording();
          },
          onError: (ErrorCodeType err, String msg) {
            setState(() {
              _hasError = true;
              _errorMessage = "Agora Error: $msg";
            });
            _audioCaptureService.stopRecording();
          },
        ),
      );

      // 🔹 Generate token dynamically before joining
      String agoraToken = AgoraTokenGenerator.generateToken(
        appId: agoraAppId,
        appCertificate: agoraAppCertificate,
        channelName: widget.channelName,
        uid: int.tryParse(widget.userId) ?? 0,
      );

      await _engine!.joinChannel(
        token: agoraToken,
        channelId: widget.channelName,
        uid: int.tryParse(widget.userId) ?? 0,
        options: const ChannelMediaOptions(),
      );
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = "Error initializing Agora: $e";
      });
    }
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    _audioCaptureService.stopRecording();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child:
            _hasError
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 100, color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Go Back"),
                    ),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic, size: 100, color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      _isJoined ? "Connected..." : "Waiting for user...",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 40),
                    FloatingActionButton(
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.call_end),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
      ),
    );
  }
}
