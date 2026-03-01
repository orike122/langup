import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;

  Stream<Amplitude> get amplitudeStream => _recorder.onAmplitudeChanged(
        const Duration(milliseconds: 100),
      );

  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> hasMicPermission() async {
    return Permission.microphone.isGranted;
  }

  Future<void> startRecording() async {
    final granted = await requestMicPermission();
    if (!granted) throw Exception('Microphone permission denied');

    final dir = await getTemporaryDirectory();
    _recordingPath =
        '${dir.path}/langup_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
        numChannels: 1,
      ),
      path: _recordingPath!,
    );
  }

  Future<File?> stopRecording() async {
    final path = await _recorder.stop();
    if (path == null) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    return file;
  }

  Future<bool> isRecording() => _recorder.isRecording();

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
