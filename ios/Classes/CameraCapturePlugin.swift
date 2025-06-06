import Flutter
import UIKit

public class CameraCapturePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "camera_capture_plugin", binaryMessenger: registrar.messenger())
    let instance = CameraCapturePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "handleCameraImage":
    if let args = call.arguments as? [String: Any] {
                        self.handleCameraImage(args: args, result: result)
                    } else {
                        result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments missing", details: nil))
                    }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

 private func handleCameraImage(args: [String: Any], result: FlutterResult) {
         guard let width = args["width"] as? Int,
               let height = args["height"] as? Int,
               let planesData = args["planes"] as? [[String:Any]] else {
             result(FlutterError(code: "INVALID_DATA", message: "Missing image data", details: nil))
             return
         }

         guard let jpegData = jpegDataFromFlutterImage(width: width, height: height, planes: planesData) else {
             result(FlutterError(code: "PROCESSING_FAILED", message: "Failed to create JPEG data", details: nil))
             return
         }

         result(FlutterStandardTypedData(bytes: jpegData))
     }

     func jpegDataFromFlutterImage(width: Int, height: Int, planes: [[String: Any]]) -> Data? {
         var pixelBuffer: CVPixelBuffer?
         let attrs = [
             kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
         ] as CFDictionary

         CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)

         guard let buffer = pixelBuffer else { return nil }

         //lock memory ก่อน memcpy
         CVPixelBufferLockBaseAddress(buffer, [])


         guard let plane = planes.first,
               let bytesData = plane["bytes"] as? FlutterStandardTypedData,
               let planeAddress = CVPixelBufferGetBaseAddressOfPlane(buffer, 0),
               let _ = plane["width"] as? Int,
               let _ = plane["height"] as? Int,
               let _ = plane["bytesPerRow"] as? Int else {
             return nil
         }

         let bytes = bytesData.data
         memcpy(planeAddress, (bytes as NSData).bytes, bytes.count)

         //unlock memory หลัง memcpy
         CVPixelBufferUnlockBaseAddress(buffer, [])

         // แปลงเป็น CIImage → UIImage → JPEG
         let ciImage = CIImage(cvPixelBuffer: buffer)
         let context = CIContext()
         guard let cgImage = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: width, height: height)) else {
             return nil
         }

         let uiImage = UIImage(cgImage: cgImage)
         return uiImage.jpegData(compressionQuality: 0.85)
     }

}
