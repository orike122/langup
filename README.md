# Langup — German Language Learning App

A Flutter app for learning German through AI voice conversation with "Lena", a friendly tutor powered by GPT-4 Turbo and Whisper.

## Features

- **Voice conversation** — speak German, Whisper transcribes, GPT-4 replies
- **Grammar corrections** — shown visually below your message (not spoken)
- **Word definitions** — tap any word in Lena's reply for an inline definition
- **CEFR adaptive** — onboarding quiz determines A1–C2 level; Lena adapts
- **Text-to-speech** — Lena's replies spoken aloud in German (slower rate for comprehension)

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── constants/       api_constants, prompts, level_questions
├── models/          message, correction, level, gpt_response
├── services/        openai_service, tts_service, audio_service
├── providers/       conversation_provider, level_provider
├── screens/         splash, level_test, conversation
└── widgets/         chat_bubble, correction_chip, word_definition_modal
```

## Getting Started

### 1. Prerequisites

- Flutter SDK ≥ 3.0
- Dart ≥ 3.0
- An OpenAI API key with access to GPT-4 Turbo and Whisper

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run with your API key

```bash
flutter run --dart-define=OPENAI_KEY=sk-YOUR_KEY_HERE
```

> **Never commit a real API key.** The placeholder `String.fromEnvironment('OPENAI_KEY')` is inert at build time if no `--dart-define` is provided.

### 4. Platform setup

**Android** — permissions are declared in `android/app/src/main/AndroidManifest.xml`.
Ensure a German TTS voice is installed: *Settings → Language & Input → Text-to-speech output*.

**iOS** — mic usage description is in `ios/Runner/Info.plist`.
The `AVAudioSession` is configured in `ios/Runner/AppDelegate.swift` for simultaneous record + playback.

## Architecture

| Layer | Technology |
|---|---|
| UI | Flutter + Material 3 |
| State | Riverpod `StateNotifier` |
| Transcription | OpenAI Whisper (`whisper-1`) |
| AI replies | OpenAI GPT-4 Turbo (`gpt-4-turbo`) |
| TTS | `flutter_tts` (de-DE, 0.5× speed) |
| Recording | `record` package (.m4a / AAC) |
| Persistence | `shared_preferences` (CEFR level) |

## Production Considerations

- **Proxy your API key** — route OpenAI calls through your own backend to keep the key server-side
- Add auth so each user has a rate-limited token
- Consider streaming GPT responses for lower perceived latency
- Add offline fallback / retry logic for flaky connections

## Verification Checklist

- [ ] Fresh install → level test appears → level saved → no test on relaunch
- [ ] Full loop: mic tap → speak → transcription shows → bot replies → TTS plays
- [ ] Intentional mistake → correction chip appears, no audio for correction
- [ ] Tap word in bot reply → definition modal appears
- [ ] Set level to A1 → bot uses simple sentences
