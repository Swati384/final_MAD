import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  print("📡 Pinging Google Gemini API...");
  try {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: 'AIzaSyDQs0C2qHIuoohZI_ikXn0yfe7DEQdzyN8', // Your live key
    );

    final response = await model.generateContent([Content.text('Hello')]);
    print("✅ SUCCESS! Response from Gemini: ${response.text?.trim()}");
    print("👉 The error is GONE. You can safely run 'flutter run' now.");
  } catch (e) {
    print("❌ ERROR STILL PRESENT: $e");
  }
}