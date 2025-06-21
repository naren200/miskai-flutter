import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/g2p_base.dart';
import '../models/token.dart';

class KoreanG2P extends G2PBase {
  bool _isInitialized = false;
  final Map<String, String> _g2pRules = {};
  List<String> _idioms = [];
  
  @override
  String get languageCode => 'ko';
  
  @override
  bool get isAvailable => _isInitialized;
  
  @override
  Future<void> initialize() async {
    try {
      // Load Korean G2P data from Misaki g2pkc module
      await _loadG2PKCData();
      
      _isInitialized = true;
      debugPrint('Korean G2P initialized with ${_g2pRules.length} rules and ${_idioms.length} idioms');
    } catch (e) {
      debugPrint('Failed to load Korean G2P data: $e');
      _isInitialized = true; // Continue without data
    }
  }
  
  Future<void> _loadG2PKCData() async {
    try {
      // Load idioms
      final idiomsText = await rootBundle.loadString('packages/miskai_flutter/assets/dictionaries/ko/idioms.txt');
      _idioms = idiomsText.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      // Load rules (this would need to be processed from the Python files)
      final rulesText = await rootBundle.loadString('packages/miskai_flutter/assets/dictionaries/ko/rules.txt');
      final rules = rulesText.split('\n').where((line) => line.trim().isNotEmpty);
      
      for (final rule in rules) {
        final parts = rule.split('\t');
        if (parts.length >= 2) {
          _g2pRules[parts[0]] = parts[1];
        }
      }
      
    } catch (e) {
      debugPrint('Error loading Korean G2PKC data: $e');
    }
  }
  
  @override
  Future<G2PResult> process(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Basic Korean text processing
    final tokens = _tokenize(text);
    final processedTokens = <MToken>[];
    final phonemesList = <String>[];
    
    for (final token in tokens) {
      final phonemes = _convertToPhonemes(token.text);
      if (phonemes.isNotEmpty) {
        processedTokens.add(token.copyWith(phonemes: phonemes));
        phonemesList.add(phonemes);
      } else {
        processedTokens.add(token);
      }
    }
    
    return (phonemesList.join(' '), processedTokens);
  }
  
  List<MToken> _tokenize(String text) {
    final tokens = <MToken>[];
    final syllables = _segmentIntoSyllables(text);
    
    for (final syllable in syllables) {
      if (syllable.trim().isNotEmpty) {
        tokens.add(MToken(text: syllable));
      }
    }
    
    return tokens;
  }
  
  List<String> _segmentIntoSyllables(String text) {
    final syllables = <String>[];
    int i = 0;
    
    while (i < text.length) {
      final char = text.codeUnitAt(i);
      
      // Check if it's a Hangul syllable (0xAC00-0xD7AF)
      if (char >= 0xAC00 && char <= 0xD7AF) {
        syllables.add(text[i]);
      } else if (char >= 0x1100 && char <= 0x11FF) {
        // Hangul Jamo (initial consonants)
        syllables.add(text[i]);
      } else if (char >= 0x1160 && char <= 0x11FF) {
        // Hangul Jamo (vowels)
        syllables.add(text[i]);
      } else if (char >= 0x11A8 && char <= 0x11FF) {
        // Hangul Jamo (final consonants)
        syllables.add(text[i]);
      } else {
        // Non-Korean character
        syllables.add(text[i]);
      }
      
      i++;
    }
    
    return syllables;
  }
  
  String _convertToPhonemes(String syllable) {
    // Check if it's in our rules
    if (_g2pRules.containsKey(syllable)) {
      return _g2pRules[syllable]!;
    }
    
    // Basic Hangul syllable decomposition and phoneme conversion
    final codePoint = syllable.codeUnits.first;
    
    if (codePoint >= 0xAC00 && codePoint <= 0xD7AF) {
      // Decompose Hangul syllable
      final syllableIndex = codePoint - 0xAC00;
      final initialIndex = syllableIndex ~/ (21 * 28);
      final medialIndex = (syllableIndex % (21 * 28)) ~/ 28;
      final finalIndex = syllableIndex % 28;
      
      // Convert to basic phonemes (simplified)
      String phonemes = _getInitialConsonant(initialIndex);
      phonemes += _getMedialVowel(medialIndex);
      if (finalIndex > 0) {
        phonemes += _getFinalConsonant(finalIndex);
      }
      
      return phonemes;
    }
    
    return syllable; // Return as-is if can't convert
  }
  
  String _getInitialConsonant(int index) {
    const consonants = ['g', 'kk', 'n', 'd', 'tt', 'r', 'm', 'b', 'pp', 's', 'ss', '', 'j', 'jj', 'ch', 'k', 't', 'p', 'h'];
    return index < consonants.length ? consonants[index] : '';
  }
  
  String _getMedialVowel(int index) {
    const vowels = ['a', 'ae', 'ya', 'yae', 'eo', 'e', 'yeo', 'ye', 'o', 'wa', 'wae', 'oe', 'yo', 'u', 'wo', 'we', 'wi', 'yu', 'eu', 'yi', 'i'];
    return index < vowels.length ? vowels[index] : '';
  }
  
  String _getFinalConsonant(int index) {
    const consonants = ['', 'g', 'kk', 'gs', 'n', 'nj', 'nh', 'd', 'l', 'lg', 'lm', 'lb', 'ls', 'lt', 'lp', 'lh', 'm', 'b', 'bs', 's', 'ss', 'ng', 'j', 'ch', 'k', 't', 'p', 'h'];
    return index < consonants.length ? consonants[index] : '';
  }
  
  // Helper method to detect Korean text
  static bool isKoreanText(String text) {
    // Check for Hangul characters
    return RegExp(r'[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AF]').hasMatch(text);
  }
}