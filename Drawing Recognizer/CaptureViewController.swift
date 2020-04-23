//
//  CaptureViewController.swift
//  ReconhecimentoDesenhos
//
//  Created by Gabriel on 2020-04-23.
//  Copyright © 2020 Gabriel. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import MobileCoreServices

class CaptureViewController: UIViewController {
        
    var openCVCamera: OpenCVCameraWrapper!;
    @IBOutlet weak var cameraFeed: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        openCVCamera = OpenCVCameraWrapper();
        openCVCamera.setupCameraFeed(cameraFeed)
        openCVCamera.startCamera();
    }
    
    @IBAction func recognizeDrawing(_ sender: Any) {
        let currentImage = openCVCamera.getCurrentImage()!
        openCVCamera.stopCamera()
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(currentImage.pngData()!, withName: "image", fileName: "image.png", mimeType: "image/png")
        }, to: "http://192.168.0.105:5000/predict").responseJSON(completionHandler: { response in
            debugPrint(response)
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        openCVCamera.stopCamera()
    }
}
