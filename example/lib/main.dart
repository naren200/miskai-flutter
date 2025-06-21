import 'package:flutter/material.dart';
import 'dart:async';

import 'package:miskai_flutter/miskai_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController(text: 'Hello world');
  String _phonemes = '';
  String _selectedLanguage = 'en-us';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeG2P();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> initializeG2P() async {
    try {
      await MiskaiFlutter.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Failed to initialize: $e');
    }
  }

  void _updateSampleText(String language) {
    switch (language) {
      case 'en-us':
      case 'en-gb':
        _controller.text = 'Hello world';
        break;
      case 'ja':
        _controller.text = 'こんにちは世界';
        break;
      case 'ko':
        _controller.text = '안녕하세요 세계';
        break;
      case 'vi':
        _controller.text = 'Xin chào thế giới';
        break;
      case 'zh':
        _controller.text = '你好世界';
        break;
      case 'he':
        _controller.text = 'שלום עולם';
        break;
    }
  }

  String _getLanguageInfo() {
    switch (_selectedLanguage) {
      case 'en-us':
        return 'English (United States) - CMU Pronouncing Dictionary with 183,562 entries';
      case 'en-gb':
        return 'English (Great Britain) - British English dictionary with 197,118 entries';
      case 'ja':
        return 'Japanese (日本語) - MeCab-based tokenization with 147,571 word pronunciations';
      case 'ko':
        return 'Korean (한국어) - G2P conversion with 5 phonological rules and 392 idioms';
      case 'vi':
        return 'Vietnamese (Tiếng Việt) - Text normalization with 3,098 acronyms, 62 symbols, and 482 teencode entries';
      case 'zh':
        return 'Chinese (中文) - Pinyin conversion with tone sandhi and text normalization';
      case 'he':
        return 'Hebrew (עברית) - Grapheme-to-phoneme conversion for Modern Hebrew';
      default:
        return 'Unknown language';
    }
  }

  Future<void> convertToPhonemes() async {
    if (!_isInitialized) return;

    try {
      final (phonemes, tokens) = await MiskaiFlutter.textToPhonemes(
        _controller.text,
        language: _selectedLanguage,
      );
      
      setState(() {
        _phonemes = phonemes;
      });
    } catch (e) {
      setState(() {
        _phonemes = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miskai G2P Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Miskai G2P Demo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: ValueKey(_selectedLanguage),
                decoration: const InputDecoration(
                  labelText: 'Enter text',
                  border: OutlineInputBorder(),
                ),
                controller: _controller,
                textDirection: _selectedLanguage == 'he' ? TextDirection.rtl : TextDirection.ltr,
                style: const TextStyle(fontSize: 16),
                maxLines: 2,
                onSubmitted: (_) => convertToPhonemes(),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: _selectedLanguage,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'en-us', child: Text('English (US)')),
                  DropdownMenuItem(value: 'en-gb', child: Text('English (GB)')),
                  DropdownMenuItem(value: 'ja', child: Text('Japanese (日本語)')),
                  DropdownMenuItem(value: 'ko', child: Text('Korean (한국어)')),
                  DropdownMenuItem(value: 'vi', child: Text('Vietnamese (Tiếng Việt)')),
                  DropdownMenuItem(value: 'zh', child: Text('Chinese (中文)')),
                  DropdownMenuItem(value: 'he', child: Text('Hebrew (עברית)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                    // Update sample text based on language
                    _updateSampleText(value);
                    // Auto-convert to show immediate results
                    convertToPhonemes();
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isInitialized ? convertToPhonemes : null,
                child: Text(_isInitialized ? 'Convert to Phonemes' : 'Initializing...'),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Phonemes:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _phonemes.isEmpty ? 'No phonemes yet - Click "Convert to Phonemes" or select a language' : _phonemes,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Language Info:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_getLanguageInfo()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}