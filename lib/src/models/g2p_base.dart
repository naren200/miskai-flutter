import 'token.dart';

typedef G2PResult = (String phonemes, List<MToken> tokens);

abstract class G2PBase {
  Future<G2PResult> process(String text);
  
  String get languageCode;
  bool get isAvailable;
  
  Future<void> initialize() async {
    // Default implementation - can be overridden
  }
}