import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'miskai_flutter_method_channel.dart';

abstract class MiskaiFlutterPlatform extends PlatformInterface {
  /// Constructs a MiskaiFlutterPlatform.
  MiskaiFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static MiskaiFlutterPlatform _instance = MethodChannelMiskaiFlutter();

  /// The default instance of [MiskaiFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelMiskaiFlutter].
  static MiskaiFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MiskaiFlutterPlatform] when
  /// they register themselves.
  static set instance(MiskaiFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
