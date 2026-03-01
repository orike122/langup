// Build with: flutter run --dart-define=OPENAI_KEY=sk-xxx
// Never commit a real key. Production: proxy through a backend.
const String openAiKey = String.fromEnvironment('OPENAI_KEY');

const String openAiBaseUrl = 'https://api.openai.com/v1';
const String gptModel = 'gpt-4-turbo';
const String whisperModel = 'whisper-1';
