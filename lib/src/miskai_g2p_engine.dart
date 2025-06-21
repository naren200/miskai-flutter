import 'dart:io';
import 'package:flutter/foundation.dart';
import 'models/g2p_base.dart';
import 'models/token.dart';
import 'languages/english_g2p.dart';
import 'languages/japanese_g2p.dart';
import 'languages/vietnamese_g2p.dart';
import 'languages/korean_g2p.dart';
import 'languages/chinese_g2p.dart';
import 'languages/hebrew_g2p.dart';
import 'ffi/native_bindings.dart';

class MiskaiG2PEngine {
  final Map<String, G2PBase> _languageHandlers = {};
  bool _isInitialized = false;
  
  // Supported languages
  static const supportedLanguages = {
    'en-us': 'English (US)',
    'en-gb': 'English (GB)',
    'ja': 'Japanese',
    'ko': 'Korean',
    'zh': 'Chinese',
    'vi': 'Vietnamese',
    'he': 'Hebrew',
  };
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize native bindings for eSpeak fallback
      // Initialize on all platforms that support native libraries
      try {
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS || 
            Platform.isAndroid || Platform.isIOS) {
          NativeBindings.init();
        }
      } catch (e) {
        debugPrint('Native bindings initialization failed (fallback will not be available): $e');
      }
      
      // Register language handlers
      _languageHandlers['en-us'] = EnglishG2P(dialect: 'us');
      _languageHandlers['en-gb'] = EnglishG2P(dialect: 'gb');
      _languageHandlers['ja'] = JapaneseG2P();
      _languageHandlers['vi'] = VietnameseG2P();
      _languageHandlers['ko'] = KoreanG2P();
      _languageHandlers['zh'] = ChineseG2P();
      _languageHandlers['he'] = HebrewG2P();
      
      // Initialize all handlers
      await Future.wait(
        _languageHandlers.values.map((handler) => handler.initialize())
      );
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize G2P engine: $e');
      _isInitialized = false;
    }
  }
  
  bool get isInitialized => _isInitialized;
  
  List<String> get availableLanguages {
    return _languageHandlers.entries
        .where((e) => e.value.isAvailable)
        .map((e) => e.key)
        .toList();
  }
  
  Future<G2PResult> processText(String text, {String? language}) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Auto-detect language if not specified
    language ??= _detectLanguage(text);
    
    // Get appropriate handler
    final handler = _languageHandlers[language];
    
    if (handler != null && handler.isAvailable) {
      return await handler.process(text);
    } else {
      // Fallback to eSpeak
      return await _processWithEspeak(text, language);
    }
  }
  
  String _detectLanguage(String text) {
    // Use language-specific detection methods
    if (VietnameseG2P.isVietnameseText(text)) {
      return 'vi';
    }
    
    if (KoreanG2P.isKoreanText(text)) {
      return 'ko';
    }
    
    if (ChineseG2P.isChineseText(text)) {
      return 'zh';
    }
    
    if (JapaneseG2P.isJapaneseText(text)) {
      return 'ja';
    }
    
    // Check for Hebrew
    if (HebrewG2P.isHebrewText(text)) {
      return 'he';
    }
    
    // Default to English (US)
    return 'en-us';
  }
  
  Future<G2PResult> _processWithEspeak(String text, String language) async {
    // Use native eSpeak binding
    try {
      final phonemes = NativeBindings.processText(text, language);
      final tokens = text.split(' ').map((word) => MToken(
        text: word,
        phonemes: phonemes,
      )).toList();
      
      return (phonemes, tokens);
    } catch (e) {
      debugPrint('eSpeak fallback failed: $e');
      // Return empty result
      return ('', [MToken(text: text)]);
    }
  }
  
  // Batch processing for efficiency
  Future<List<G2PResult>> processBatch(List<String> texts, {String? language}) async {
    return Future.wait(
      texts.map((text) => processText(text, language: language))
    );
  }
  
  // Language-specific configuration
  void configureLanguage(String language, Map<String, dynamic> config) {
    final handler = _languageHandlers[language];
    if (handler != null) {
      // Apply configuration (e.g., dialect, phoneme set, etc.)
      // This would be implemented in each language handler
    }
  }
}