import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

import 'camera_capture_plugin_platform_interface.dart';

class CameraCapturePlugin {
  Future<String?> getPlatformVersion() {
    return CameraCapturePluginPlatform.instance.getPlatformVersion();
  }

  Future<Uint8List?> handleCameraImage(CameraImage cameraImage) async {
    try {
      final jpegData = await CameraCapturePluginPlatform.instance.handleCameraImage(
        cameraImage.width,
        cameraImage.height,
        cameraImage.planes,
      );
      return jpegData;
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }
}
