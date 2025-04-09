import 'package:flutter_test/flutter_test.dart';
import 'package:scanpro_dart/scanpro_dart.dart';
import 'package:scanpro_dart/scanpro_dart_platform_interface.dart';
import 'package:scanpro_dart/scanpro_dart_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockScanproDartPlatform
    with MockPlatformInterfaceMixin
    implements ScanproDartPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ScanproDartPlatform initialPlatform = ScanproDartPlatform.instance;

  test('$MethodChannelScanproDart is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelScanproDart>());
  });

  test('getPlatformVersion', () async {
    ScanproDart scanproDartPlugin = ScanproDart();
    MockScanproDartPlatform fakePlatform = MockScanproDartPlatform();
    ScanproDartPlatform.instance = fakePlatform;

    expect(await scanproDartPlugin.getPlatformVersion(), '42');
  });
}
