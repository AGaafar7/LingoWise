import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_sound/flutter_sound.dart';
import 'deepgram_service.dart';

class AudioCaptureService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final DeepgramService _deepgramService = DeepgramService();
  StreamController<Uint8List>? _streamController;

  Future<void> startRecording() async {
    await _recorder.openRecorder();

    _streamController = StreamController<Uint8List>();
    _streamController!.stream.listen((buffer) {
      _deepgramService.sendAudioData(buffer);
    });

    await _recorder.startRecorder(
      toStream: _streamController!.sink, // ✅ Correctly passing the stream sink
      codec: Codec.pcm16,
      sampleRate: 16000,
      numChannels: 1,
    );

    _deepgramService.connectToDeepgram();
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    await _streamController?.close();
    _deepgramService.closeConnection();
  }
}
