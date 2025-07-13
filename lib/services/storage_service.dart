import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';

class StorageService {
  static const String _memorizedWordsKey = 'memorized_words';
  static const String _dailyProgressKey = 'daily_progress';
  static const String _lastResetDateKey = 'last_reset_date';

  static Future<List<WordModel>> getMemorizedWords() async {
    final prefs = await SharedPreferences.getInstance();
    final wordsJson = prefs.getStringList(_memorizedWordsKey) ?? [];
    
    return wordsJson.map((json) {
      final Map<String, dynamic> wordMap = jsonDecode(json);
      return WordModel(
        word: wordMap['word'],
        phonetic: wordMap['phonetic'] ?? '',
        definition: wordMap['definition'],
        example: wordMap['example'] ?? '',
        synonyms: List<String>.from(wordMap['synonyms'] ?? []),
        audioUrl: wordMap['audioUrl'] ?? '',
        isMemorized: true,
      );
    }).toList();
  }

  static Future<void> saveMemorizedWords(List<WordModel> words) async {
    final prefs = await SharedPreferences.getInstance();
    final wordsJson = words.map((word) => jsonEncode({
      'word': word.word,
      'phonetic': word.phonetic,
      'definition': word.definition,
      'example': word.example,
      'synonyms': word.synonyms,
      'audioUrl': word.audioUrl,
    })).toList();
    
    await prefs.setStringList(_memorizedWordsKey, wordsJson);
  }

  static Future<int> getDailyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndResetDailyProgress();
    return prefs.getInt(_dailyProgressKey) ?? 0;
  }

  static Future<void> updateDailyProgress(int progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyProgressKey, progress);
  }

  static Future<void> _checkAndResetDailyProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastResetDate = prefs.getString(_lastResetDateKey);
    
    if (lastResetDate != today) {
      await prefs.setInt(_dailyProgressKey, 0);
      await prefs.setString(_lastResetDateKey, today);
    }
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

