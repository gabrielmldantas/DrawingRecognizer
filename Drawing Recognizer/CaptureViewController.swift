//
//  CaptureViewController.swift
//  ReconhecimentoDesenhos
//
//  Created by Gabriel on 2020-04-23.
//  Copyright © 2020 Gabriel. All rights reserved.
//

import UIKit

class CaptureViewController: UIViewController {
        
    var openCVCamera: OpenCVCameraWrapper!;
    @IBOutlet weak var cameraFeed: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        openCVCamera = OpenCVCameraWrapper()
        openCVCamera.setupCameraFeed(cameraFeed)
        openCVCamera.startCamera();
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let recognitionViewController = segue.destination as! RecognitionViewController
        recognitionViewController.capturedImage = openCVCamera.getCurrentImage()
        recognitionViewController.roi = openCVCamera.getCurrentROI()
        openCVCamera.stopCamera()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (openCVCamera.getCurrentBoundingBox().width == 0) {
            showNoBoundingBoxAlert()
            return false;
        }
        return true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        openCVCamera.stopCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        openCVCamera.startCamera()
        super.viewWillAppear(animated)
    }
    
    func showNoBoundingBoxAlert() {
        let alert = UIAlertController(
            title: "Aviso",
            message: "Não é possível iniciar o reconhecimento do desenho pois nenhum desenho foi localizado. Por favor aguarde o aparecimento da caixa de localização.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Fechar"), style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))

        present(alert, animated: true, completion: nil)
    }
}
