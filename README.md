# miskai-flutter

Open sourced G2P engine for Flutter, a replica of hexgrad/misaki

A Flutter plugin for multilingual Grapheme-to-Phoneme (G2P) conversion, based on the Misaki engine architecture.

## Features

- Support for multiple languages: English (US/GB), Japanese, Korean, Chinese, Vietnamese, Hebrew
- Native performance with Dart/C++ implementation
- Dictionary-based approach with morphological rules
- eSpeak fallback for unsupported languages
- Lightweight and mobile-optimized

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  miskai_flutter:
    path: ../miskai_flutter  # or use git/pub.dev URL
```

## Usage

```dart
import 'package:miskai_flutter/miskai_flutter.dart';

// Initialize the engine
await MiskaiFlutter.initialize();

// Convert text to phonemes
final (phonemes, tokens) = await MiskaiFlutter.textToPhonemes(
  "Hello world",
  language: "en-us",
);

print(phonemes); // "hɛˈloʊ wɝld"

// Process Japanese text
final (jaPhonemes, jaTokens) = await MiskaiFlutter.textToPhonemes(
  "こんにちは",
  language: "ja",
);

print(jaPhonemes); // "ko ɴ ni chi wa"
```

## Converting Misaki Data

To use existing Misaki dictionaries and rules:

1. **English Dictionaries**: Copy JSON files from `misaki/data/en/` to `assets/dictionaries/en/`
2. **Japanese**: Extract mora mappings from `misaki/ja.py`
3. **Korean**: Copy rule files from `misaki/g2pkc/` to `assets/rules/ko/`
4. **Other languages**: Convert data files to JSON format

### Data Conversion Script

Run this Python script in the misaki directory to convert data:

```python
import json
import os
import shutil

# Convert English dictionaries
for dialect in ['us', 'gb']:
    for quality in ['gold', 'silver']:
        src = f"data/en/{dialect}_{quality}.json"
        dst = f"../miskai-flutter/assets/dictionaries/en/{dialect}_{quality}.json"
        if os.path.exists(src):
            shutil.copy(src, dst)

# Extract Japanese mora mappings
from ja import M2P
with open("../miskai-flutter/assets/dictionaries/ja/mora_mappings.json", "w") as f:
    json.dump(M2P, f, ensure_ascii=False, indent=2)

# Copy Korean rules
for file in ['idioms.txt', 'rules.txt', 'table.csv']:
    src = f"g2pkc/{file}"
    dst = f"../miskai-flutter/assets/rules/ko/{file}"
    if os.path.exists(src):
        shutil.copy(src, dst)
```

## Architecture

The plugin follows a modular architecture:

- **Dart Layer**: High-level API and language detection
- **Language Modules**: Implement specific G2P logic for each language
- **Native Layer (C++)**: Dictionary management and eSpeak integration
- **Assets**: Embedded dictionaries and rule files

## Language Support Status

- ✅ English (US/GB) - Basic implementation
- ✅ Japanese - Mora-to-phoneme mapping
- 🚧 Korean - Rule engine needed
- 🚧 Chinese - Pinyin tables needed
- 🚧 Vietnamese - Mapping tables needed
- 🚧 Hebrew - Implementation needed
- ✅ eSpeak fallback - Via native binding

## Development

To add a new language:

1. Create a new class extending `G2PBase` in `lib/src/languages/`
2. Implement the `process()` method with language-specific logic
3. Register the handler in `MiskaiG2PEngine`
4. Add dictionary/rule files to `assets/`

## Building Native Code

### Windows
```bash
cd windows
cmake -B build -S ../src
cmake --build build --config Release
```

### Linux/macOS
```bash
cd linux  # or macos
cmake -B build -S ../src
cmake --build build
```

## License

This project follows the same license as the original Misaki project.