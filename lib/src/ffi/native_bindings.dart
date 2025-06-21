import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef InitializeNative = Void Function();
typedef InitializeDart = void Function();

typedef ProcessTextNative = Pointer<Utf8> Function(Pointer<Utf8> text, Pointer<Utf8> language);
typedef ProcessTextDart = Pointer<Utf8> Function(Pointer<Utf8> text, Pointer<Utf8> language);

typedef LoadDictionaryNative = Int32 Function(Pointer<Utf8> language, Pointer<Utf8> path);
typedef LoadDictionaryDart = int Function(Pointer<Utf8> language, Pointer<Utf8> path);

typedef FreeStringNative = Void Function(Pointer<Utf8> str);
typedef FreeStringDart = void Function(Pointer<Utf8> str);

class NativeBindings {
  static late DynamicLibrary _lib;
  static late InitializeDart _initialize;
  static late ProcessTextDart _processText;
  static late LoadDictionaryDart _loadDictionary;
  static late FreeStringDart _freeString;

  static void init() {
    _lib = _loadLibrary();
    
    _initialize = _lib
        .lookup<NativeFunction<InitializeNative>>('miskai_initialize')
        .asFunction();
    
    _processText = _lib
        .lookup<NativeFunction<ProcessTextNative>>('miskai_process_text')
        .asFunction();
    
    _loadDictionary = _lib
        .lookup<NativeFunction<LoadDictionaryNative>>('miskai_load_dictionary')
        .asFunction();
    
    _freeString = _lib
        .lookup<NativeFunction<FreeStringNative>>('miskai_free_string')
        .asFunction();
    
    _initialize();
  }

  static DynamicLibrary _loadLibrary() {
    if (Platform.isWindows) {
      return DynamicLibrary.open('miskai_flutter.dll');
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('libmiskai_flutter.so');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('libmiskai_flutter.dylib');
    } else if (Platform.isAndroid) {
      return DynamicLibrary.open('libmiskai_flutter.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  static String processText(String text, String language) {
    final textPtr = text.toNativeUtf8();
    final langPtr = language.toNativeUtf8();
    
    try {
      final resultPtr = _processText(textPtr, langPtr);
      final result = resultPtr.toDartString();
      _freeString(resultPtr);
      return result;
    } finally {
      malloc.free(textPtr);
      malloc.free(langPtr);
    }
  }

  static bool loadDictionary(String language, String path) {
    final langPtr = language.toNativeUtf8();
    final pathPtr = path.toNativeUtf8();
    
    try {
      final result = _loadDictionary(langPtr, pathPtr);
      return result == 1;
    } finally {
      malloc.free(langPtr);
      malloc.free(pathPtr);
    }
  }
}