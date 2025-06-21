import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/g2p_base.dart';
import '../models/token.dart';

class VietnameseG2P extends G2PBase {
  bool _isInitialized = false;
  Map<String, String> _acronyms = {};
  Map<String, String> _symbols = {};
  Map<String, String> _teencode = {};
  
  @override
  String get languageCode => 'vi';
  
  @override
  bool get isAvailable => _isInitialized;
  
  @override
  Future<void> initialize() async {
    try {
      // Load Vietnamese dictionaries from Misaki
      await _loadAcronyms();
      await _loadSymbols();
      await _loadTeencode();
      
      _isInitialized = true;
      debugPrint('Vietnamese G2P initialized with ${_acronyms.length} acronyms, ${_symbols.length} symbols, ${_teencode.length} teencode entries');
    } catch (e) {
      debugPrint('Failed to load Vietnamese dictionaries: $e');
      _isInitialized = true; // Continue without dictionaries
    }
  }
  
  Future<void> _loadAcronyms() async {
    final jsonString = await rootBundle.loadString('packages/miskai_flutter/assets/dictionaries/vi_acronyms.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    _acronyms = data.cast<String, String>();
  }
  
  Future<void> _loadSymbols() async {
    final jsonString = await rootBundle.loadString('packages/miskai_flutter/assets/dictionaries/vi_symbols.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    _symbols = data.cast<String, String>();
  }
  
  Future<void> _loadTeencode() async {
    final jsonString = await rootBundle.loadString('packages/miskai_flutter/assets/dictionaries/vi_teencode.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    _teencode = data.cast<String, String>();
  }
  
  @override
  Future<G2PResult> process(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    String normalizedText = _normalizeText(text);
    final tokens = _tokenize(normalizedText);
    final processedTokens = <MToken>[];
    
    for (final token in tokens) {
      final normalizedToken = _processToken(token);
      processedTokens.add(normalizedToken);
    }
    
    final resultText = processedTokens.map((t) => t.text).join();
    return (resultText, processedTokens);
  }
  
  String _normalizeText(String text) {
    String result = text;
    
    // Apply acronym expansion (case insensitive)
    _acronyms.forEach((acronym, expansion) {
      result = result.replaceAll(RegExp(r'\b' + RegExp.escape(acronym) + r'\b', caseSensitive: false), expansion);
    });
    
    // Apply symbol conversion
    _symbols.forEach((symbol, replacement) {
      result = result.replaceAll(symbol, replacement);
    });
    
    // Apply teencode normalization (case insensitive)
    _teencode.forEach((teencode, normal) {
      result = result.replaceAll(RegExp(r'\b' + RegExp.escape(teencode) + r'\b', caseSensitive: false), normal);
    });
    
    return result;
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
      
      tokens.add(MToken(text: word, whitespace: whitespace));
    }
    
    return tokens;
  }
  
  MToken _processToken(MToken token) {
    // Vietnamese text processing can include:
    // - Tone normalization
    // - Syllable boundary detection
    // - Special character handling
    
    // For now, return the token as-is after text normalization
    return token;
  }
  
  // Helper method to detect Vietnamese text
  static bool isVietnameseText(String text) {
    // Check for Vietnamese-specific characters
    return RegExp(r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđĐ]').hasMatch(text);
  }
}