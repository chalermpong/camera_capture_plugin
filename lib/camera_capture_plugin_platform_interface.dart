import 'package:camera/camera.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'camera_capture_plugin_method_channel.dart';

abstract class CameraCapturePluginPlatform extends PlatformInterface {
  /// Constructs a CameraCapturePluginPlatform.
  CameraCapturePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static CameraCapturePluginPlatform _instance = MethodChannelCameraCapturePlugin();

  /// The default instance of [CameraCapturePluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelCameraCapturePlugin].
  static CameraCapturePluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CameraCapturePluginPlatform] when
  /// they register themselves.
  static set instance(CameraCapturePluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> handleCameraImage(int width, int height, List<Plane> planes) {
    throw UnimplementedError('handleCameraImage() has not been implemented.');
  }
}
