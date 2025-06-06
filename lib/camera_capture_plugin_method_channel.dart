import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'camera_capture_plugin_platform_interface.dart';

/// An implementation of [CameraCapturePluginPlatform] that uses method channels.
class MethodChannelCameraCapturePlugin extends CameraCapturePluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('camera_capture_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Uint8List?> handleCameraImage(int width, int height, List<Plane> planes) async {
    final jpegData = await methodChannel.invokeMethod<Uint8List>(
      'handleCameraImage',
      <String, dynamic>{
        'width': width,
        'height': height,
        'planes': planes.map((plane) {
          return {
            'bytes': plane.bytes,
            'bytesPerRow': plane.bytesPerRow,
            'bytesPerPixel': plane.bytesPerPixel,
            'height': plane.height,
            'width': plane.width,
          };
        }).toList(),
      },
    );
    return jpegData;
  }
}
