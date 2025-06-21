import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/g2p_base.dart';
import '../models/token.dart';

class JapaneseG2P extends G2PBase {
  bool _isInitialized = false;
  Set<String> _japaneseWords = {};
  
  // Mora-to-phoneme mapping (from Misaki's M2P dictionary)
  static const Map<String, String> moraToPhoneme = {
    // Basic kana
    'ア': 'a', 'イ': 'i', 'ウ': 'u', 'エ': 'e', 'オ': 'o',
    'カ': 'ka', 'キ': 'ki', 'ク': 'ku', 'ケ': 'ke', 'コ': 'ko',
    'ガ': 'ga', 'ギ': 'gi', 'グ': 'gu', 'ゲ': 'ge', 'ゴ': 'go',
    'サ': 'sa', 'シ': 'ɕi', 'ス': 'su', 'セ': 'se', 'ソ': 'so',
    'ザ': 'za', 'ジ': 'ʥi', 'ズ': 'zu', 'ゼ': 'ze', 'ゾ': 'zo',
    'タ': 'ta', 'チ': 'ʨi', 'ツ': 'ʦu', 'テ': 'te', 'ト': 'to',
    'ダ': 'da', 'ヂ': 'ʥi', 'ヅ': 'zu', 'デ': 'de', 'ド': 'do',
    'ナ': 'na', 'ニ': 'ɲi', 'ヌ': 'nu', 'ネ': 'ne', 'ノ': 'no',
    'ハ': 'ha', 'ヒ': 'çi', 'フ': 'ƫu', 'ヘ': 'he', 'ホ': 'ho',
    'バ': 'ba', 'ビ': 'bi', 'ブ': 'bu', 'ベ': 'be', 'ボ': 'bo',
    'パ': 'pa', 'ピ': 'pi', 'プ': 'pu', 'ペ': 'pe', 'ポ': 'po',
    'マ': 'ma', 'ミ': 'mi', 'ム': 'mu', 'メ': 'me', 'モ': 'mo',
    'ヤ': 'ja', 'ユ': 'ju', 'ヨ': 'jo',
    'ラ': 'ra', 'リ': 'ri', 'ル': 'ru', 'レ': 're', 'ロ': 'ro',
    'ワ': 'wa', 'ヰ': 'wi', 'ヱ': 'we', 'ヲ': 'wo', 'ン': 'ɴ',
    
    // Small kana
    'ァ': 'a', 'ィ': 'i', 'ゥ': 'u', 'ェ': 'e', 'ォ': 'o',
    'ャ': 'ja', 'ュ': 'ju', 'ョ': 'jo',
    'ヮ': 'wa',
    
    // Digraphs (palatalized)
    'キャ': 'ᶄa', 'キュ': 'ᶄu', 'キョ': 'ᶄo',
    'ギャ': 'ᶃa', 'ギュ': 'ᶃu', 'ギョ': 'ᶃo',
    'シャ': 'ɕa', 'シュ': 'ɕu', 'ショ': 'ɕo',
    'ジャ': 'ʥa', 'ジュ': 'ʥu', 'ジョ': 'ʥo',
    'チャ': 'ʨa', 'チュ': 'ʨu', 'チョ': 'ʨo',
    'ニャ': 'ɲa', 'ニュ': 'ɲu', 'ニョ': 'ɲo',
    'ヒャ': 'ça', 'ヒュ': 'çu', 'ヒョ': 'ço',
    'ビャ': 'ᶀa', 'ビュ': 'ᶀu', 'ビョ': 'ᶀo',
    'ピャ': 'ᶈa', 'ピュ': 'ᶈu', 'ピョ': 'ᶈo',
    'ミャ': 'ᶆa', 'ミュ': 'ᶆu', 'ミョ': 'ᶆo',
    'リャ': 'ᶉa', 'リュ': 'ᶉu', 'リョ': 'ᶉo',
    
    // Special characters
    'ッ': 'ʔ',  // Gemination marker
    'ー': 'ː',  // Long vowel
  };
  
  // Hiragana to Katakana conversion
  static String hiraganaToKatakana(String text) {
    final buffer = StringBuffer();
    for (final char in text.runes) {
      if (char >= 0x3041 && char <= 0x3096) {
        // Convert hiragana to katakana
        buffer.writeCharCode(char + 0x60);
      } else {
        buffer.writeCharCode(char);
      }
    }
    return buffer.toString();
  }
  
  @override
  String get languageCode => 'ja';
  
  @override
  bool get isAvailable => _isInitialized;
  
  @override
  Future<void> initialize() async {
    try {
      // Load Japanese word list from Misaki
      final japaneseText = await rootBundle.loadString('packages/miskai_flutter/assets/dictionaries/ja_words.txt');
      _japaneseWords = japaneseText.split('\n')
          .where((word) => word.trim().isNotEmpty)
          .toSet();
      
      _isInitialized = true;
      debugPrint('Japanese G2P initialized with ${_japaneseWords.length} words');
    } catch (e) {
      debugPrint('Failed to load Japanese dictionary: $e');
      _isInitialized = true; // Continue without dictionary
    }
  }
  
  @override
  Future<G2PResult> process(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Convert to katakana for processing
    final katakanaText = hiraganaToKatakana(text);
    
    // Tokenize into moras
    final tokens = _tokenizeIntoMoras(katakanaText);
    final processedTokens = <MToken>[];
    final phonemesList = <String>[];
    
    for (final token in tokens) {
      final phonemes = _convertMoraToPhoneme(token.text);
      if (phonemes.isNotEmpty) {
        processedTokens.add(token.copyWith(phonemes: phonemes));
        phonemesList.add(phonemes);
      } else {
        processedTokens.add(token);
      }
    }
    
    return (phonemesList.join(' '), processedTokens);
  }
  
  List<MToken> _tokenizeIntoMoras(String text) {
    final tokens = <MToken>[];
    int i = 0;
    
    while (i < text.length) {
      // Check for digraphs (2-character combinations)
      if (i + 1 < text.length) {
        final digraph = text.substring(i, i + 2);
        if (moraToPhoneme.containsKey(digraph)) {
          tokens.add(MToken(text: digraph));
          i += 2;
          continue;
        }
      }
      
      // Single character
      final char = text[i];
      tokens.add(MToken(text: char));
      i++;
    }
    
    return tokens;
  }
  
  String _convertMoraToPhoneme(String mora) {
    // Direct lookup
    if (moraToPhoneme.containsKey(mora)) {
      return moraToPhoneme[mora]!;
    }
    
    // Handle long vowel marker
    if (mora == 'ー' && moraToPhoneme.isNotEmpty) {
      return 'ː';
    }
    
    // Handle gemination
    if (mora == 'ッ') {
      return 'ʔ';
    }
    
    // Check if it's a punctuation or space
    if (RegExp(r'[\s\p{P}]', unicode: true).hasMatch(mora)) {
      return '';
    }
    
    // If not found, return empty (could use fallback here)
    return '';
  }
  
  // Pitch accent support (simplified version)
  List<MToken> applyPitchAccent(List<MToken> tokens, List<int> accentPattern) {
    // This would apply pitch accent markers based on the pattern
    // For now, returning tokens as-is
    return tokens;
  }
  
  // Helper method to detect Japanese text
  static bool isJapaneseText(String text) {
    // Check for Japanese characters (Hiragana, Katakana, Kanji)
    return RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]').hasMatch(text);
  }
}