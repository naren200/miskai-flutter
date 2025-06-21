import 'src/miskai_g2p_engine.dart';
import 'src/models/token.dart';

export 'src/miskai_g2p_engine.dart';
export 'src/models/token.dart';
export 'src/models/g2p_base.dart';

class MiskaiFlutter {
  static final MiskaiG2PEngine _engine = MiskaiG2PEngine();
  
  /// Initialize the G2P engine
  static Future<void> initialize() async {
    await _engine.initialize();
  }
  
  /// Check if the engine is initialized
  static bool get isInitialized => _engine.isInitialized;
  
  /// Get list of available languages
  static List<String> get availableLanguages => _engine.availableLanguages;
  
  /// Convert text to phonemes
  /// Returns a tuple of (phonemes string, list of tokens)
  static Future<(String, List<MToken>)> textToPhonemes(
    String text, {
    String? language,
  }) async {
    return await _engine.processText(text, language: language);
  }
  
  /// Process multiple texts in batch
  static Future<List<(String, List<MToken>)>> batchTextToPhonemes(
    List<String> texts, {
    String? language,
  }) async {
    return await _engine.processBatch(texts, language: language);
  }
  
  /// Configure language-specific settings
  static void configureLanguage(String language, Map<String, dynamic> config) {
    _engine.configureLanguage(language, config);
  }
  
  /// Get platform version (for compatibility with existing tests)
  Future<String?> getPlatformVersion() async {
    return 'Miskai Flutter G2P Plugin v0.0.1';
  }
}