import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/word_model.dart';
import 'storage_service.dart';

class WordService {
  static final WordService _instance = WordService._internal();
  factory WordService() => _instance;
  WordService._internal();

  List<String> _allWords = [];
  List<WordModel> _learnNewWords = [];
  List<WordModel> _newVocabWords = [];
  List<WordModel> _memorizedWords = [];
  int _dailyProgress = 0;
  
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Load word list from assets
    final String wordData = await rootBundle.loadString('assets/words.txt');
    _allWords = wordData.split('\n').where((word) => word.trim().isNotEmpty).toList();
    
    // Load memorized words and daily progress from storage
    await _loadStoredData();
    
    // Initialize word categories
    await _initializeWordCategories();
    
    _isInitialized = true;
  }

  Future<void> _loadStoredData() async {
    _memorizedWords = await StorageService.getMemorizedWords();
    _dailyProgress = await StorageService.getDailyProgress();
  }

  Future<void> _initializeWordCategories() async {
    final random = Random();
    
    // Get first 5000 words for "Learn new words"
    final learnWords = _allWords.take(5000).toList();
    learnWords.shuffle(random);
    
    // Get next 5000 words for "New Vocab Words"
    final vocabWords = _allWords.skip(5000).take(5000).toList();
    vocabWords.shuffle(random);
    
    // Fetch definitions for a subset of words to start with
    await _loadWordsWithDefinitions(learnWords, _learnNewWords, 100);
    await _loadWordsWithDefinitions(vocabWords, _newVocabWords, 100);
  }

  Future<void> _loadWordsWithDefinitions(List<String> words, List<WordModel> targetList, int count) async {
    for (int i = 0; i < min(count, words.length); i++) {
      final wordData = await _fetchWordDefinition(words[i]);
      if (wordData != null) {
        targetList.add(wordData);
      }
      
      // Add a small delay to avoid overwhelming the API
      if (i % 10 == 0) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  Future<WordModel?> _fetchWordDefinition(String word) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return WordModel.fromJson(data[0]);
        }
      }
    } catch (e) {
      print('Error fetching definition for $word: $e');
    }
    
    // Return a basic word model if API fails
    return WordModel(
      word: word,
      phonetic: '',
      definition: 'A word in the English language',
      example: 'This word can be used in various contexts.',
      synonyms: [],
      audioUrl: '',
    );
  }

  // Getters
  List<WordModel> getLearnNewWords() => _learnNewWords;
  List<WordModel> getNewVocabWords() => _newVocabWords;
  List<WordModel> getAllWords() => [..._learnNewWords, ..._newVocabWords];
  List<WordModel> getMemorizedWords() => _memorizedWords;

  int getMemorizedCount() => _dailyProgress;
  int getDailyGoal() => 20;

  // Word memorization methods
  Future<void> memorizeWord(WordModel word) async {
    if (!_memorizedWords.any((w) => w.word == word.word)) {
      word.isMemorized = true;
      _memorizedWords.add(word);
      _dailyProgress++;
      
      await StorageService.saveMemorizedWords(_memorizedWords);
      await StorageService.updateDailyProgress(_dailyProgress);
    }
  }

  Future<void> unmemorizeWord(WordModel word) async {
    final wasMemorized = _memorizedWords.any((w) => w.word == word.word);
    _memorizedWords.removeWhere((w) => w.word == word.word);
    word.isMemorized = false;
    
    if (wasMemorized && _dailyProgress > 0) {
      _dailyProgress--;
    }
    
    await StorageService.saveMemorizedWords(_memorizedWords);
    await StorageService.updateDailyProgress(_dailyProgress);
  }

  bool isWordMemorized(String word) {
    return _memorizedWords.any((w) => w.word == word);
  }

  // Load more words dynamically
  Future<void> loadMoreWords(String category) async {
    if (category == 'learn_new' && _learnNewWords.length < 1000) {
      final startIndex = _learnNewWords.length;
      final endIndex = min(startIndex + 50, 5000);
      final moreWords = _allWords.skip(startIndex).take(endIndex - startIndex).toList();
      await _loadWordsWithDefinitions(moreWords, _learnNewWords, moreWords.length);
    } else if (category == 'new_vocab' && _newVocabWords.length < 1000) {
      final startIndex = 5000 + _newVocabWords.length;
      final endIndex = min(startIndex + 50, 10000);
      final moreWords = _allWords.skip(startIndex).take(endIndex - startIndex).toList();
      await _loadWordsWithDefinitions(moreWords, _newVocabWords, moreWords.length);
    }
  }
}

