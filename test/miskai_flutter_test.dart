import 'package:flutter_test/flutter_test.dart';
import 'package:miskai_flutter/miskai_flutter.dart';
import 'package:miskai_flutter/miskai_flutter_platform_interface.dart';
import 'package:miskai_flutter/miskai_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMiskaiFlutterPlatform
    with MockPlatformInterfaceMixin
    implements MiskaiFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('Miskai Flutter G2P Plugin v0.0.1');
}

void main() {
  final MiskaiFlutterPlatform initialPlatform = MiskaiFlutterPlatform.instance;

  test('$MethodChannelMiskaiFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMiskaiFlutter>());
  });

  test('getPlatformVersion', () async {
    MiskaiFlutter miskaiFlutterPlugin = MiskaiFlutter();
    MockMiskaiFlutterPlatform fakePlatform = MockMiskaiFlutterPlatform();
    MiskaiFlutterPlatform.instance = fakePlatform;

    expect(await miskaiFlutterPlugin.getPlatformVersion(), 'Miskai Flutter G2P Plugin v0.0.1');
  });
}
