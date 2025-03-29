import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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
  RtcEngine? _engine; // 🔹 Make nullable to avoid null issues
  bool _isJoined = false;
  bool _hasError = false;
  String _errorMessage = "";

  // 🔹 Secure your App ID & Token (Move these to a secure backend)
  final String agoraAppId = "a33c42c93ff94b729a6ce74486333c7a";
  final String agoraToken =
      "007eJxTYOj+rCK7de2szknVbc06v4pYBBk0LiU0mb78PW/h3gMT0uIVGBKNjZNNjJItjdPSLE2SzI0sE82SU81NTCzMjIEy5onewi/SGwIZGeTMmpkZGSAQxOdkyE0tLk5Mz8xLZ2AAAP"; // Get from Agora Console

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // 🔹 Request microphone permission & handle errors
    if (await Permission.microphone.request().isDenied) {
      setState(() {
        _hasError = true;
        _errorMessage = "Microphone permission is required!";
      });
      return;
    }

    try {
      _engine = createAgoraRtcEngine(); // 🔹 Create Agora engine
      await _engine!.initialize(RtcEngineContext(appId: agoraAppId));

      await _engine!.enableAudio();
      await _engine!.setChannelProfile(
        ChannelProfileType.channelProfileCommunication,
      );

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int uid) {
            setState(() => _isJoined = true);
          },
          onUserOffline: (
            RtcConnection connection,
            int uid,
            UserOfflineReasonType reason,
          ) {
            setState(() => _isJoined = false);
          },
          onError: (ErrorCodeType err, String msg) {
            setState(() {
              _hasError = true;
              _errorMessage = "Agora Error: $msg";
            });
          },
        ),
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
    _engine?.leaveChannel(); // 🔹 Ensure proper cleanup
    _engine?.release();
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
