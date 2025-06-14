package com.example.camera_capture_plugin

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.Rect
import android.graphics.YuvImage
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream

/** CameraCapturePlugin */
class CameraCapturePlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "camera_capture_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "handleCameraImage" -> handleCameraImage(call, result)
      else -> result.notImplemented()
    }
  }

  private fun handleCameraImage(call: MethodCall, result: MethodChannel.Result) {
    val arg = (call.arguments as? Map<String, *>)
    val planes = arg?.get("planes") as? List<Map<String, *>>
    val bytes: ByteArray? = planes?.firstOrNull()?.get("bytes") as? ByteArray
    val width: Int? = arg?.get("width") as? Int
    val height: Int? = arg?.get("height") as? Int
    val quality: Int = 85

    if(bytes == null || width == null || height == null) {
      result.error("Null argument", "bytes, width, height must not be null", null)
      return
    }

    Thread {
      val out = ByteArrayOutputStream()
      val yuv = YuvImage(bytes, ImageFormat.NV21, width, height, null)

      yuv.compressToJpeg(Rect(0, 0, width, height), quality, out)

      val converted = out.toByteArray()

      val bitmap = BitmapFactory.decodeByteArray(converted, 0, converted.size)
      val matrix = Matrix()
      matrix.postRotate(90f)

      val rotatedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true);
      bitmap.recycle()

      val baos = ByteArrayOutputStream()
      rotatedBitmap.compress(Bitmap.CompressFormat.JPEG, quality, baos)
      rotatedBitmap.recycle()
      val imageBytes = baos.toByteArray()

      Handler(Looper.getMainLooper()).post {
        result.success(imageBytes)
      }
    }.start()
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
