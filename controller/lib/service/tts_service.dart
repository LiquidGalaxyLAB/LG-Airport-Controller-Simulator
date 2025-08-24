import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService extends ChangeNotifier {
  static final TtsService instance = TtsService.internal();
  factory TtsService() => instance;
  TtsService.internal();

  final FlutterTts tts = FlutterTts();
  bool isInitializedFlag = false;

  // Voice settings with defaults
  double speechRateValue = 0.5;
  double volumeValue = 1.0;
  double pitchValue = 1.0;
  String? selectedVoice;
  String? selectedLanguage = 'en-US';
  List<dynamic> availableVoices = [];
  List<dynamic> availableLanguages = [];

  // Getters
  double get speechRate => speechRateValue;
  double get volume => volumeValue;
  double get pitch => pitchValue;
  String? get getselectedVoice => selectedVoice;
  String? get getselectedLanguage => selectedLanguage;
  List<dynamic> get getavailableVoices => availableVoices;
  List<dynamic> get getavailableLanguages => availableLanguages;
  bool get isInitialized => isInitializedFlag;

  // Initialize TTS service
  Future<void> initialize() async {
    if (isInitializedFlag) return;

    try {
      // Get available languages and voices
      availableLanguages = await tts.getLanguages;
      availableVoices = await tts.getVoices;

      // Load saved settings
      await loadSettings();

      // Apply settings to TTS
      await applySettings();

      isInitializedFlag = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      speechRateValue = prefs.getDouble('tts_speech_rate') ?? 0.5;
      volumeValue = prefs.getDouble('tts_volume') ?? 1.0;
      pitchValue = prefs.getDouble('tts_pitch') ?? 1.0;
      selectedVoice = prefs.getString('tts_selected_voice');
      selectedLanguage = prefs.getString('tts_selected_language') ?? 'en-US';
    } catch (e) {
      print('Error loading TTS settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('tts_speech_rate', speechRateValue);
      await prefs.setDouble('tts_volume', volumeValue);
      await prefs.setDouble('tts_pitch', pitchValue);
      if (selectedVoice != null) {
        await prefs.setString('tts_selected_voice', selectedVoice!);
      }
      if (selectedLanguage != null) {
        await prefs.setString('tts_selected_language', selectedLanguage!);
      }
    } catch (e) {
      print('Error saving TTS settings: $e');
    }
  }

  // Apply current settings to TTS engine
  Future<void> applySettings() async {
    try {
      await tts.setSpeechRate(speechRateValue);
      await tts.setVolume(volumeValue);
      await tts.setPitch(pitchValue);
      
      if (selectedLanguage != null) {
        await tts.setLanguage(selectedLanguage!);
      }
      
      if (selectedVoice != null) {
        await tts.setVoice({
          "name": selectedVoice!,
          "locale": selectedLanguage ?? 'en-US'
        });
      }
    } catch (e) {
      print('Error applying TTS settings: $e');
    }
  }

  // Update speech rate
  Future<void> updateSpeechRate(double rate) async {
    speechRateValue = rate.clamp(0.1, 2.0);
    await tts.setSpeechRate(speechRateValue);
    await saveSettings();
    notifyListeners();
  }

  // Update volume
  Future<void> updateVolume(double volume) async {
    volumeValue = volume.clamp(0.0, 1.0);
    await tts.setVolume(volumeValue);
    await saveSettings();
    notifyListeners();
  }

  // Update pitch
  Future<void> updatePitch(double pitch) async {
    pitchValue = pitch.clamp(0.5, 2.0);
    await tts.setPitch(pitchValue);
    await saveSettings();
    notifyListeners();
  }

  // Update selected voice
  Future<void> updateVoice(String? voiceName) async {
    selectedVoice = voiceName;
    if (voiceName != null) {
      await tts.setVoice({
        "name": voiceName,
        "locale": selectedLanguage ?? 'en-US'
      });
    }
    await saveSettings();
    notifyListeners();
  }

  // Update selected language
  Future<void> updateLanguage(String? language) async {
    selectedLanguage = language;
    if (language != null) {
      await tts.setLanguage(language);
    }
    await saveSettings();
    notifyListeners();
  }

  // Main speak function with custom settings
  Future<void> speak(String text, {
    double? customRate,
    double? customVolume,
    double? customPitch,
    String? customVoice,
    bool addRoger = true,
  }) async {
    if (!isInitializedFlag) {
      await initialize();
    }

    try {
      // Apply custom settings if provided
      if (customRate != null) {
        await tts.setSpeechRate(customRate);
      }
      if (customVolume != null) {
        await tts.setVolume(customVolume);
      }
      if (customPitch != null) {
        await tts.setPitch(customPitch);
      }
      if (customVoice != null) {
        await tts.setVoice({
          "name": customVoice,
          "locale": selectedLanguage ?? 'en-US'
        });
      }

      // Speak the text
      await tts.speak(text);
      await tts.awaitSpeakCompletion(true);

      // Add "Roger" if requested
      if (addRoger) {
        await tts.speak("Roger");
        await tts.awaitSpeakCompletion(true);
      }

      // Restore original settings if custom ones were used
      if (customRate != null || customVolume != null || customPitch != null || customVoice != null) {
        await applySettings();
      }
    } catch (e) {
      print('Error speaking: $e');
    }
  }

  // Stop speaking
  Future<void> stop() async {
    await tts.stop();
  }

  // Pause speaking
  Future<void> pause() async {
    await tts.pause();
  }

  // Get voice info by name
  Map<String, dynamic>? getVoiceInfo(String voiceName) {
    try {
      return availableVoices.firstWhere(
        (voice) => voice['name'] == voiceName,
        orElse: () => null,
      );
    } catch (e) {
      return null;
    }
  }

  // Get voices for specific language
  List<dynamic> getVoicesForLanguage(String language) {
    return availableVoices.where((voice) {
      return voice['locale']?.toString().startsWith(language.split('-')[0]) ?? false;
    }).toList();
  }

  // Reset to default settings
  Future<void> resetToDefaults() async {
    speechRateValue = 0.5;
    volumeValue = 1.0;
    pitchValue = 1.0;
    selectedVoice = null;
    selectedLanguage = 'en-US';
    
    await applySettings();
    await saveSettings();
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }
}