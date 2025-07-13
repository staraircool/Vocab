import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _isInitialized = true;
  }

  Future<void> speakWord(String word) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _flutterTts.speak(word);
    } catch (e) {
      print('Error speaking word: $e');
    }
  }

  Future<void> playAudioFromUrl(String audioUrl) async {
    if (audioUrl.isEmpty) return;
    
    try {
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      print('Error playing audio from URL: $e');
      // Fallback to TTS if URL audio fails
      await speakWord('word');
    }
  }

  Future<void> stopAudio() async {
    await _flutterTts.stop();
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

