import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'miskai_flutter_platform_interface.dart';

/// An implementation of [MiskaiFlutterPlatform] that uses method channels.
class MethodChannelMiskaiFlutter extends MiskaiFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('miskai_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
