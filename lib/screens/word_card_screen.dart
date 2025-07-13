import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/word_service.dart';
import '../services/audio_service.dart';
import '../widgets/animated_card.dart';

class WordCardScreen extends StatefulWidget {
  final String category;

  const WordCardScreen({super.key, required this.category});

  @override
  State<WordCardScreen> createState() => _WordCardScreenState();
}

class _WordCardScreenState extends State<WordCardScreen>
    with TickerProviderStateMixin {
  final WordService _wordService = WordService();
  final AudioService _audioService = AudioService();
  
  List<WordModel> _words = [];
  int _currentIndex = 0;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
    _loadWords();
    _setupAnimations();
  }

  void _setupAnimations() {
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _heartAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  void _loadWords() {
    switch (widget.category) {
      case 'learn_new':
        _words = _wordService.getLearnNewWords();
        break;
      case 'new_vocab':
        _words = _wordService.getNewVocabWords();
        break;
      case 'repeat_all':
        _words = _wordService.getAllWords();
        break;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6B46C1),
                Color(0xFF9333EA),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    final currentWord = _words[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B46C1),
              Color(0xFF9333EA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Pronunciation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Progress indicator
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_currentIndex + 1) / _words.length,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Word card with animation
              Expanded(
                child: AnimatedCard(
                  onSwipeLeft: _nextWord,
                  onSwipeRight: _previousWord,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phonetic
                        if (currentWord.phonetic.isNotEmpty)
                          Text(
                            currentWord.phonetic,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        
                        const SizedBox(height: 10),
                        
                        // Word
                        Text(
                          currentWord.word.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Definition
                        Text(
                          currentWord.definition,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Example
                        if (currentWord.example.isNotEmpty)
                          Text(
                            currentWord.example,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        
                        const SizedBox(height: 30),
                        
                        // Synonyms
                        if (currentWord.synonyms.isNotEmpty) ...[
                          const Text(
                            'Synonyms:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: currentWord.synonyms.take(3).map((synonym) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  synonym,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Speaker button
                    _buildActionButton(
                      icon: Icons.volume_up,
                      onTap: () => _speakWord(currentWord),
                    ),
                    
                    // Next button
                    _buildActionButton(
                      icon: Icons.arrow_forward,
                      onTap: _nextWord,
                    ),
                    
                    // Heart button (memorize) with animation
                    AnimatedBuilder(
                      animation: _heartAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _heartAnimation.value,
                          child: _buildActionButton(
                            icon: _wordService.isWordMemorized(currentWord.word)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            onTap: () => _toggleMemorize(currentWord),
                            isActive: _wordService.isWordMemorized(currentWord.word),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isActive ? Colors.red : Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.black,
          size: 28,
        ),
      ),
    );
  }

  void _speakWord(WordModel word) async {
    if (word.audioUrl.isNotEmpty) {
      await _audioService.playAudioFromUrl(word.audioUrl);
    } else {
      await _audioService.speakWord(word.word);
    }
  }

  void _nextWord() {
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousWord() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _toggleMemorize(WordModel word) async {
    if (_wordService.isWordMemorized(word.word)) {
      await _wordService.unmemorizeWord(word);
    } else {
      await _wordService.memorizeWord(word);
      _heartAnimationController.forward().then((_) {
        _heartAnimationController.reverse();
      });
    }
    setState(() {});
  }
}

