import '../models/g2p_base.dart';
import '../models/token.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class HebrewG2P implements G2PBase {
  bool _isInitialized = false;
  Map<String, String> _phoneticRules = {};
  
  // Hebrew phoneme set based on mishkal package
  static const Set<String> _phonemeSet = {
    'ʔ', 'b', 'v', 'g', 'ɣ', 'd', 'ð', 'h', 'w', 'z', 'ħ', 'tˤ', 'j', 'k', 'x',
    'l', 'm', 'n', 's', 'ʕ', 'p', 'f', 'tsˤ', 'q', 'ʁ', 'ʃ', 't', 'θ',
    'a', 'e', 'i', 'o', 'u', 'ə', 'ɛ', 'ɔ'
  };
  
  // Hebrew Unicode range detector
  static bool isHebrewText(String text) {
    return RegExp(r'[\u0590-\u05FF]').hasMatch(text);
  }

  @override
  String get languageCode => 'he';

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load Hebrew phonetic rules from assets
      final rulesJson = await rootBundle.loadString('packages/miskai_flutter/assets/he/phonetic_rules.json');
      final rules = json.decode(rulesJson) as Map<String, dynamic>;
      _phoneticRules = rules.cast<String, String>();
      
      _isInitialized = true;
    } catch (e) {
      // If assets fail to load, still mark as initialized but with basic rules
      _initializeBasicRules();
      _isInitialized = true;
    }
  }
  
  void _initializeBasicRules() {
    // Basic Hebrew to IPA mappings based on mishkal package
    _phoneticRules = {
      // Consonants
      'א': 'ʔ',  // Aleph
      'ב': 'b',  // Bet
      'בּ': 'b', // Bet with dagesh
      'ג': 'g',  // Gimel
      'ד': 'd',  // Dalet
      'ה': 'h',  // He
      'ו': 'v',  // Vav
      'ז': 'z',  // Zayin
      'ח': 'χ',  // Het
      'ט': 't',  // Tet
      'י': 'j',  // Yod
      'כ': 'x',  // Kaf
      'כּ': 'k', // Kaf with dagesh
      'ל': 'l',  // Lamed
      'מ': 'm',  // Mem
      'ם': 'm',  // Mem final
      'ן': 'n',  // Nun final
      'נ': 'n',  // Nun
      'ס': 's',  // Samekh
      'ע': 'ʕ',  // Ayin
      'פ': 'f',  // Pe
      'פּ': 'p', // Pe with dagesh
      'ף': 'f',  // Pe final
      'צ': 'ts', // Tsadi
      'ץ': 'ts', // Tsadi final
      'ק': 'k',  // Qof
      'ר': 'ʁ',  // Resh
      'ש': 'ʃ',  // Shin
      'שׂ': 's', // Sin
      'ת': 't',  // Tav
      'תּ': 't', // Tav with dagesh
      
      // Vowels (niqqud)
      'ַ': 'a',   // Patah
      'ָ': 'a',   // Qamats
      'ֶ': 'e',   // Segol
      'ֵ': 'e',   // Tsere
      'ִ': 'i',   // Hiriq
      'ֹ': 'o',   // Holam
      'ֻ': 'u',   // Qubuts
      'ְ': 'ə',   // Shva
      'ֲ': 'a',   // Hataf patah
      'ֱ': 'e',   // Hataf segol
      'ֳ': 'o',   // Hataf qamats
    };
  }

  @override
  bool get isAvailable => _isInitialized;

  @override
  Future<G2PResult> process(String text, {bool preservePunctuation = true, bool preserveStress = true}) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final tokens = <MToken>[];
    final phonemes = StringBuffer();
    
    // Split text into words
    final words = text.split(RegExp(r'\s+'));
    
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      
      if (word.isEmpty) continue;
      
      // Process Hebrew word
      final wordPhonemes = _convertWordToPhonemes(word, preservePunctuation, preserveStress);
      
      tokens.add(MToken(
        text: word,
        phonemes: wordPhonemes,
      ));
      
      phonemes.write(wordPhonemes);
      
      // Add space between words (except for last word)
      if (i < words.length - 1) {
        phonemes.write(' ');
      }
    }
    
    return (phonemes.toString(), tokens);
  }
  
  String _convertWordToPhonemes(String word, bool preservePunctuation, bool preserveStress) {
    final result = StringBuffer();
    
    for (int i = 0; i < word.length; i++) {
      final char = word[i];
      final charCode = char.codeUnitAt(0);
      
      // Handle Hebrew characters
      if (charCode >= 0x0590 && charCode <= 0x05FF) {
        // Hebrew character range
        final phoneme = _phoneticRules[char];
        if (phoneme != null) {
          result.write(phoneme);
        } else {
          // Fallback for unmapped Hebrew characters
          result.write(char);
        }
      } else if (preservePunctuation && RegExp(r'[^\w\s]').hasMatch(char)) {
        // Preserve punctuation if requested
        result.write(char);
      } else if (char.trim().isNotEmpty) {
        // Non-Hebrew, non-punctuation character
        result.write(char);
      }
    }
    
    return result.toString();
  }
  
  /// Get the phoneme set used by this Hebrew G2P implementation
  Set<String> getPhonemeSet() {
    return _phonemeSet;
  }
  
  @override
  String toString() => 'HebrewG2P(initialized: $_isInitialized, rules: ${_phoneticRules.length})';
}