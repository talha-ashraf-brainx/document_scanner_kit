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
//        TODO: Re-Factor right after the complete
        var savedPaths: [String] = []
        for i in 0 ..< scan.pageCount
        {
            if let path = saveImage(image: scan.imageOfPage(at: i)) {
                savedPaths.append(path)
            } else {
                print("Image couldn't saved")
            }
                
        }
        result(savedPaths)
        controller.dismiss(animated: true)
        dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
        result(FlutterError(code: "SCAN_FAIL_WITH_ERROR", message: error.localizedDescription, details: error.localizedDescription))
        controller.dismiss(animated: true)
        dismiss(animated: true)
    }
    
    func saveImage(image: UIImage) -> String? {
//        TODO: Implement ability to define prefix for fileName
//        TODO: Better Error handling
//        TODO: Implement ability to save images to the pictures
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return nil
        }
        
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }
        
        let fileName = UUID().uuidString
        
        guard let filePath = directory.appendingPathComponent(fileName + ".jpg") else {
            return nil
        }
        
        do {
            try data.write(to: filePath)
            return filePath.path
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
        
    }
    
}
