import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    if (Platform.isIOS) {
      await _tts.awaitSpeakCompletion(true);
    }

    if (Platform.isAndroid) {
      await _checkAndroidVoice();
    }

    _initialized = true;
  }

  Future<void> _checkAndroidVoice() async {
    final voices = await _tts.getVoices as List?;
    if (voices == null) return;

    final hasGerman = voices.any((v) {
      final locale = (v['locale'] as String? ?? '').toLowerCase();
      return locale.startsWith('de');
    });

    if (!hasGerman) {
      // Caller should check this flag and show a snackbar.
      _germanVoiceMissing = true;
    }
  }

  bool _germanVoiceMissing = false;
  bool get germanVoiceMissing => _germanVoiceMissing;

  Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
