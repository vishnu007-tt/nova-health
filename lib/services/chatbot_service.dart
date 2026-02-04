import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message_model.dart';
import '../models/user_model.dart';

class ChatbotService {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal();

  // Gemini API Key - Replace with your own key from https://aistudio.google.com/
  // Get your free API key at: https://aistudio.google.com/app/apikey
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  late final GenerativeModel _model;
  ChatSession? _chatSession;

  void initialize() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',  // Stable production model (verified working)
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
  }

  String _buildSystemPrompt(UserModel? user) {
    final userInfo = user != null
        ? '''
User Profile:
- Name: ${user.fullName ?? user.username}
- Age: ${user.age ?? 'Not specified'}
- Gender: ${user.gender ?? 'Not specified'}
- Weight: ${user.weight != null ? '${user.weight} kg' : 'Not specified'}
- Height: ${user.height != null ? '${user.height} cm' : 'Not specified'}
- BMI: ${user.bmi?.toStringAsFixed(1) ?? 'Not calculated'}
'''
        : '';

    return '''You are NovaHealth AI, a compassionate and knowledgeable health assistant integrated into the NovaHealth mobile app. Your role is to provide personalized health guidance, wellness advice, and support.

$userInfo

Guidelines:
1. **Multilingual Support**: Detect the user's language and respond in the SAME language they use
2. **Personalization**: Use the user's profile information to give personalized advice
3. **Health Focus**: Provide advice on:
   - Nutrition and diet planning
   - Exercise and workout recommendations
   - Mental health and stress management
   - Sleep and recovery
   - Period/menstrual health (if applicable)
   - Hydration tracking
   - Symptom management
4. **Safety First**: Always remind users to consult healthcare professionals for serious concerns
5. **Encouraging Tone**: Be supportive, positive, and motivating
6. **Privacy**: Never store or share personal health data
7. **Evidence-Based**: Provide advice based on scientific evidence when possible

Important Notes:
- You are NOT a replacement for medical professionals
- For emergencies, always direct users to call emergency services
- If unsure about medical advice, recommend consulting a doctor
- Keep responses concise and actionable (2-4 sentences usually)

Start each conversation warmly and ask how you can help with their health journey today.''';
  }

  Future<String> sendMessage(String message, {UserModel? user, List<ChatMessage>? chatHistory}) async {
    try {
      // Start new chat session if needed
      if (_chatSession == null) {
        final systemPrompt = _buildSystemPrompt(user);
        _chatSession = _model.startChat(
          history: [
            Content.text(systemPrompt),
          ],
        );
      }

      // Send message and get response
      final response = await _chatSession!.sendMessage(
        Content.text(message),
      );

      return response.text ?? 'I apologize, but I couldn\'t generate a response. Please try again.';
    } catch (e) {
      print('Chatbot error: $e');
      return 'I apologize, but I encountered an error. Please check your internet connection and try again.';
    }
  }

  void resetChat() {
    _chatSession = null;
  }

  void dispose() {
    _chatSession = null;
  }
}
