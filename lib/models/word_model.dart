class WordModel {
  final String word;
  final String phonetic;
  final String definition;
  final String example;
  final List<String> synonyms;
  final String audioUrl;
  bool isMemorized;

  WordModel({
    required this.word,
    required this.phonetic,
    required this.definition,
    required this.example,
    required this.synonyms,
    required this.audioUrl,
    this.isMemorized = false,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
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

    return WordModel(
      word: json['word'] as String,
      phonetic: json['phonetic'] as String? ?? '',
      definition: definition,
      example: example,
      synonyms: synonyms?.map((s) => s as String).toList() ?? [],
      audioUrl: audioUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'phonetic': phonetic,
      'definition': definition,
      'example': example,
      'synonyms': synonyms,
      'audioUrl': audioUrl,
      'isMemorized': isMemorized,
    };
  }
}

