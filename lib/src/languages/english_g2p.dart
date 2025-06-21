import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/g2p_base.dart';
import '../models/token.dart';

class EnglishG2P extends G2PBase {
  final String dialect; // 'us' or 'gb'
  late Map<String, dynamic> goldLexicon;
  late Map<String, dynamic> silverLexicon;
  bool _isInitialized = false;
  
  // Phoneme sets matching Misaki
  static const String usPhonemes = 'AIOWYbdfhijklmnpstuvwzæðŋɑɔəɛɜɡɪɹɾʃʊʌʒʤʧˈˌθᵊᵻʔ';
  static const String gbPhonemes = 'AIQWYabdfhijklmnpstuvwzðŋɑɒɔəɛɜɡɪɹʃʊʌʒʤʧˈˌːθᵊ';
  
  // Special words with context-dependent pronunciation
  static const Map<String, Map<String, String>> specialWords = {
    'the': {'before_vowel': 'ðɪ', 'default': 'ðə'},
    'a': {'before_vowel': 'ən', 'default': 'ə'},
    'to': {'stressed': 'tu', 'default': 'tə'},
  };
  
  EnglishG2P({this.dialect = 'us'});
  
  @override
  String get languageCode => 'en-$dialect';
  
  @override
  bool get isAvailable => _isInitialized;
  
  @override
  Future<void> initialize() async {
    try {
      // Load the real Misaki dictionaries
      await _loadGoldLexicon();
      await _loadSilverLexicon();
      
      _isInitialized = true;
      debugPrint('English G2P initialized with ${goldLexicon.length + silverLexicon.length} entries (${dialect.toUpperCase()})');
    } catch (e) {
      debugPrint('Failed to load Misaki dictionaries, using fallback: $e');
      goldLexicon = _createMinimalDictionary();
      silverLexicon = {};
      _isInitialized = true;
    }
  }
  
  Future<void> _loadGoldLexicon() async {
    final path = 'packages/miskai_flutter/assets/dictionaries/${dialect}_gold.json';
    final jsonString = await rootBundle.loadString(path);
    goldLexicon = json.decode(jsonString) as Map<String, dynamic>;
  }
  
  Future<void> _loadSilverLexicon() async {
    final path = 'packages/miskai_flutter/assets/dictionaries/${dialect}_silver.json';
    final jsonString = await rootBundle.loadString(path);
    silverLexicon = json.decode(jsonString) as Map<String, dynamic>;
  }
  
  Map<String, dynamic> _createMinimalDictionary() {
    // Basic dictionary for common words - following Misaki's format
    return {
      'hello': 'hɛˈloʊ',
      'world': 'wɝld',
      'the': 'ðə',
      'a': 'ə',
      'and': 'ænd',
      'to': 'tu',
      'of': 'ʌv',
      'in': 'ɪn',
      'it': 'ɪt',
      'you': 'ju',
      'that': 'ðæt',
      'he': 'hi',
      'was': 'wʌz',
      'for': 'fɔr',
      'on': 'ɑn',
      'are': 'ɑr',
      'as': 'æz',
      'with': 'wɪθ',
      'his': 'hɪz',
      'they': 'ðeɪ',
      'i': 'aɪ',
      'at': 'æt',
      'be': 'bi',
      'this': 'ðɪs',
      'have': 'hæv',
      'from': 'frʌm',
      'or': 'ɔr',
      'one': 'wʌn',
      'had': 'hæd',
      'by': 'baɪ',
      'word': 'wɝd',
      'but': 'bʌt',
      'not': 'nɑt',
      'what': 'wʌt',
      'all': 'ɔl',
      'were': 'wɝ',
      'we': 'wi',
      'when': 'wɛn',
      'your': 'jʊr',
      'can': 'kæn',
      'said': 'sɛd',
      'there': 'ðɛr',
      'each': 'iʧ',
      'which': 'wɪʧ',
      'she': 'ʃi',
      'do': 'du',
      'how': 'haʊ',
      'their': 'ðɛr',
      'if': 'ɪf',
      'will': 'wɪl',
      'up': 'ʌp',
      'other': 'ʌðɚ',
      'about': 'əˈbaʊt',
      'out': 'aʊt',
      'many': 'ˈmɛni',
      'then': 'ðɛn',
      'them': 'ðɛm',
      'these': 'ðiz',
      'so': 'soʊ',
      'some': 'sʌm',
      'her': 'hɚ',
      'would': 'wʊd',
      'make': 'meɪk',
      'like': 'laɪk',
      'into': 'ˈɪntu',
      'him': 'hɪm',
      'has': 'hæz',
      'two': 'tu',
      'more': 'mɔr',
      'very': 'ˈvɛri',
      'after': 'ˈæftɚ',
      'use': 'juz',
      'our': 'aʊr',
      'way': 'weɪ',
      'work': 'wɝk',
      'life': 'laɪf',
      'only': 'ˈoʊnli',
      'new': 'nu',
      'years': 'jɪrz',
      'time': 'taɪm',
      'good': 'gʊd',
      'get': 'gɛt',
      'may': 'meɪ',
      'know': 'noʊ',
      'over': 'ˈoʊvɚ',
      'think': 'θɪŋk',
      'also': 'ˈɔlsoʊ',
      'back': 'bæk',
      'first': 'fɝst',
      'well': 'wɛl',
      'even': 'ˈivɪn',
      'want': 'wɑnt',
      'because': 'bɪˈkɔz',
      'any': 'ˈɛni',
      'give': 'gɪv',
      'day': 'deɪ',
      'most': 'moʊst',
      'us': 'ʌs',
    };
  }
  
  @override
  Future<G2PResult> process(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final tokens = _tokenize(text);
    final processedTokens = <MToken>[];
    final phonemesList = <String>[];
    
    for (final token in tokens) {
      final phonemes = await _lookupPhonemes(token);
      processedTokens.add(token.copyWith(phonemes: phonemes));
      if (phonemes.isNotEmpty) {
        phonemesList.add(phonemes);
      }
    }
    
    return (phonemesList.join(' '), processedTokens);
  }
  
  List<MToken> _tokenize(String text) {
    final tokens = <MToken>[];
    final words = text.split(RegExp(r'(\s+)'));
    
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.trim().isEmpty) continue;
      
      // Extract whitespace
      String? whitespace;
      if (i < words.length - 1 && words[i + 1].trim().isEmpty) {
        whitespace = words[i + 1];
        i++; // Skip whitespace in next iteration
      }
      
      // Handle punctuation
      final match = RegExp(r'^(\W*)([\w\-]+)(\W*)$').firstMatch(word);
      if (match != null) {
        final prePunct = match.group(1)!;
        final mainWord = match.group(2)!;
        final postPunct = match.group(3)!;
        
        if (prePunct.isNotEmpty) {
          tokens.add(MToken(text: prePunct));
        }
        
        tokens.add(MToken(
          text: mainWord,
          whitespace: whitespace,
        ));
        
        if (postPunct.isNotEmpty) {
          tokens.add(MToken(text: postPunct));
        }
      } else {
        tokens.add(MToken(
          text: word,
          whitespace: whitespace,
        ));
      }
    }
    
    return tokens;
  }
  
  Future<String> _lookupPhonemes(MToken token) async {
    final text = token.text.toLowerCase();
    
    // Check for inline phoneme specification [word](/phonemes/)
    final inlineMatch = RegExp(r'\[([^\]]+)\]\(\/([^\/]+)\/\)').firstMatch(text);
    if (inlineMatch != null) {
      return inlineMatch.group(2)!;
    }
    
    // Handle contractions
    final contractionPhonemes = _handleContractions(text);
    if (contractionPhonemes != null) {
      return contractionPhonemes;
    }
    
    // Dictionary lookup
    String? phonemes = _lookupInLexicon(text, goldLexicon) ?? _lookupInLexicon(text, silverLexicon);
    
    // Apply morphological rules if not found
    phonemes ??= _applyMorphologicalRules(text);
    
    // Apply dialect-specific transformations
    if (phonemes != null && dialect == 'us') {
      phonemes = _applyFlapping(phonemes, token);
    }
    
    return phonemes ?? '';
  }
  
  String? _lookupInLexicon(String word, Map<String, dynamic> lexicon) {
    final entry = lexicon[word];
    if (entry == null) return null;
    
    if (entry is String) {
      return entry;
    } else if (entry is Map) {
      // Handle POS-tagged entries
      // For now, return the first pronunciation
      return entry.values.first;
    }
    
    return null;
  }
  
  String? _handleContractions(String text) {
    final contractions = {
      "'ll": 'ɫ',
      "'m": 'm',
      "'re": 'ɹ',
      "'ve": 'v',
      "'d": 'd',
      "'s": 's',
      "n't": 'nt',
    };
    
    for (final entry in contractions.entries) {
      if (text.endsWith(entry.key)) {
        final base = text.substring(0, text.length - entry.key.length);
        final basePhonemes = _lookupInLexicon(base, goldLexicon) ?? 
                            _lookupInLexicon(base, silverLexicon);
        if (basePhonemes != null) {
          return '$basePhonemes${entry.value}';
        }
      }
    }
    
    return null;
  }
  
  String? _applyMorphologicalRules(String word) {
    // Try removing common suffixes
    final suffixRules = [
      (RegExp(r'(.+)s$'), 's'),      // plurals
      (RegExp(r'(.+)ed$'), 'd'),     // past tense
      (RegExp(r'(.+)ing$'), 'ɪŋ'),   // gerund
      (RegExp(r'(.+)er$'), 'ɚ'),     // comparative
      (RegExp(r'(.+)est$'), 'ɪst'),  // superlative
    ];
    
    for (final rule in suffixRules) {
      final match = rule.$1.firstMatch(word);
      if (match != null) {
        final stem = match.group(1)!;
        final stemPhonemes = _lookupInLexicon(stem, goldLexicon) ?? 
                            _lookupInLexicon(stem, silverLexicon);
        if (stemPhonemes != null) {
          return '$stemPhonemes${rule.$2}';
        }
      }
    }
    
    return null;
  }
  
  String _applyFlapping(String phonemes, MToken token) {
    // US English flapping: /t/ → [ɾ] between vowels
    if (dialect == 'us') {
      final vowels = 'AIOWYæɑɔəɛɜɪʊʌ';
      return phonemes.replaceAllMapped(
        RegExp('([$vowels])t([$vowels])'),
        (match) => '${match.group(1)}ɾ${match.group(2)}'
      );
    }
    return phonemes;
  }
}