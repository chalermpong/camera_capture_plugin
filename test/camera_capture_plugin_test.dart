import 'dart:typed_data';

import 'package:camera/src/camera_image.dart';
import 'package:camera_capture_plugin/camera_capture_plugin.dart';
import 'package:camera_capture_plugin/camera_capture_plugin_method_channel.dart';
import 'package:camera_capture_plugin/camera_capture_plugin_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCameraCapturePluginPlatform
    with MockPlatformInterfaceMixin
    implements CameraCapturePluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Uint8List?> handleCameraImage(int width, int height, List<Plane> planes) => Future.value();
}

void main() {
  final CameraCapturePluginPlatform initialPlatform = CameraCapturePluginPlatform.instance;

  test('$MethodChannelCameraCapturePlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCameraCapturePlugin>());
  });

  test('getPlatformVersion', () async {
    CameraCapturePlugin cameraCapturePlugin = CameraCapturePlugin();
    MockCameraCapturePluginPlatform fakePlatform = MockCameraCapturePluginPlatform();
    CameraCapturePluginPlatform.instance = fakePlatform;

    expect(await cameraCapturePlugin.getPlatformVersion(), '42');
  });
}
