import Flutter
import UIKit

@available(iOS 13.0, *)
public class DocumentScannerKitPlugin: NSObject, FlutterPlugin, UIApplicationDelegate {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "document_scanner_kit_ios", binaryMessenger: registrar.messenger())
    let instance = DocumentScannerKitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
     if (call.method == "scan") {
          guard Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") is String else { return result(FlutterError(code: "MISSING_CONFIG", message: "NSCameraUsageDescription should be added to Info.plist", details: "NSCameraUsageDescription should be added to Info.plist"))}
          if let viewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
              let scannerVC = ScannerViewController(result: result)
              scannerVC.isModalInPresentation = true
               if UIDevice.current.userInterfaceIdiom == .pad {
                  controller.popoverPresentationController?.sourceView = self.view
                  controller.modalPresentationStyle = .pageSheet
              } else {
                  scannerVC.modalPresentationStyle = .popover
              }
             
              viewController.present(scannerVC, animated: true)
          }
      }
  }
}
