//
//  ScannerViewController.swift
//  document_scanner_kit_ios
//
//  Created by Ahmet Bülbül on 10.08.2024.
//

import Foundation
import VisionKit
import Flutter

@available(iOS 13.0, *)
class ScannerViewController: UIViewController, VNDocumentCameraViewControllerDelegate{
    let result: FlutterResult
    
    init(result: @escaping FlutterResult) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder){
        return nil
    }

    override func viewWillAppear(_ animated: Bool) {
        if self.isBeingPresented {
            let documentCameraVC = VNDocumentCameraViewController()
            documentCameraVC.delegate = self
            present(documentCameraVC, animated: true)
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        result(nil)
        controller.dismiss(animated: true)
        dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
//        TODO: Save Images
        let documentTitle = "\(scan.title)-\(scan.pageCount)"
        result([documentTitle])
        controller.dismiss(animated: true)
        dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
        result(FlutterError(code: "SCAN_FAIL_WITH_ERROR", message: error.localizedDescription, details: error.localizedDescription))
        controller.dismiss(animated: true)
        dismiss(animated: true)
    }
    
    
    
    
}
