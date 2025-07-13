import 'dart:convert';
import 'package:http/http.dart' as http;

class WordData {
  final String word;
  final String phonetic;
  final String definition;
  final String example;
  final List<String> synonyms;
  final String audioUrl;

  WordData({
    required this.word,
    required this.phonetic,
    required this.definition,
    required this.example,
    required this.synonyms,
    required this.audioUrl,
  });

  factory WordData.fromJson(Map<String, dynamic> json) {
    final meanings = json['meanings'] as List;
    final definitions = meanings[0]['definitions'] as List;
    final definition = definitions[0]['definition'] as String;
    final example = definitions[0]['example'] as String? ?? '';
    final synonyms = definitions[0]['synonyms'] as List?;

    final phonetics = json['phonetics'] as List;
    String audioUrl = '';
    for (var phonetic in phonetics) {
      if (phonetic['audio'] != null && phonetic['audio'].isNotEmpty) {
        audioUrl = phonetic['audio'];
        break;
      }
    }

    return WordData(
      word: json['word'] as String,
      phonetic: json['phonetic'] as String? ?? '',
      definition: definition,
      example: example,
      synonyms: synonyms?.map((s) => s as String).toList() ?? [],
      audioUrl: audioUrl,
    );
  }
}

Future<WordData?> fetchWordData(String word) async {
  final response = await http.get(Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    if (data.isNotEmpty) {
      return WordData.fromJson(data[0]);
    }
  } else {
    print('Failed to load word data for $word: ${response.statusCode}');
  }
  return null;
}


