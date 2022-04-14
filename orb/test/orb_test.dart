import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:orb/plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('orb');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await OrbPlugin.platformVersion, '42');
  });
}
