#include <string>
#include <map>
#include <vector>
#include <memory>
#include <cstring>

#ifdef _WIN32
#define EXPORT extern "C" __declspec(dllexport)
#else
#define EXPORT extern "C" __attribute__((visibility("default")))
#endif

// Forward declarations
class DictionaryManager;
class PhonemeMapper;

// Global instances
std::unique_ptr<DictionaryManager> g_dictManager;
std::unique_ptr<PhonemeMapper> g_phonemeMapper;

// Dictionary entry structure
struct DictionaryEntry {
    std::string phonemes;
    std::string pos;  // Part of speech
};

// Dictionary manager class
class DictionaryManager {
private:
    std::map<std::string, std::map<std::string, DictionaryEntry>> dictionaries;
    
public:
    bool loadDictionary(const std::string& language, const std::string& path) {
        // TODO: Implement JSON parsing and loading
        // For now, return true to indicate success
        return true;
    }
    
    std::string lookup(const std::string& language, const std::string& word) {
        auto langIt = dictionaries.find(language);
        if (langIt != dictionaries.end()) {
            auto wordIt = langIt->second.find(word);
            if (wordIt != langIt->second.end()) {
                return wordIt->second.phonemes;
            }
        }
        return "";
    }
};

// Phoneme mapper for standardization
class PhonemeMapper {
private:
    std::map<std::string, std::map<char, char>> mappings;
    
public:
    PhonemeMapper() {
        // Initialize common mappings
        // US English flapping: t -> ɾ between vowels
        mappings["en-us"]['t'] = 'ɾ';  // Context-dependent
    }
    
    std::string mapPhonemes(const std::string& phonemes, const std::string& language) {
        // Apply language-specific mappings
        return phonemes;  // Simplified for now
    }
};

// String allocation for FFI
char* allocateString(const std::string& str) {
    char* result = new char[str.length() + 1];
    std::strcpy(result, str.c_str());
    return result;
}

// Export functions for Dart FFI
EXPORT void miskai_initialize() {
    g_dictManager = std::make_unique<DictionaryManager>();
    g_phonemeMapper = std::make_unique<PhonemeMapper>();
}

EXPORT char* miskai_process_text(const char* text, const char* language) {
    if (!g_dictManager || !text || !language) {
        return allocateString("");
    }
    
    std::string input(text);
    std::string lang(language);
    
    // Simple tokenization
    std::vector<std::string> words;
    std::string currentWord;
    
    for (char c : input) {
        if (std::isspace(c)) {
            if (!currentWord.empty()) {
                words.push_back(currentWord);
                currentWord.clear();
            }
        } else {
            currentWord += c;
        }
    }
    if (!currentWord.empty()) {
        words.push_back(currentWord);
    }
    
    // Process each word
    std::string result;
    for (const auto& word : words) {
        std::string phonemes = g_dictManager->lookup(lang, word);
        
        if (phonemes.empty()) {
            // Fallback: Return the word itself (would use eSpeak here)
            phonemes = word;
        }
        
        phonemes = g_phonemeMapper->mapPhonemes(phonemes, lang);
        
        if (!result.empty()) {
            result += " ";
        }
        result += phonemes;
    }
    
    return allocateString(result);
}

EXPORT int miskai_load_dictionary(const char* language, const char* path) {
    if (!g_dictManager || !language || !path) {
        return 0;
    }
    
    return g_dictManager->loadDictionary(language, path) ? 1 : 0;
}

EXPORT void miskai_free_string(char* str) {
    delete[] str;
}