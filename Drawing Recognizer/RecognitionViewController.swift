//
//  RecognitionViewController.swift
//  Drawing Recognizer
//
//  Created by Gabriel on 2020-04-23.
//  Copyright © 2020 Gabriel. All rights reserved.
//

import UIKit
import Alamofire

class RecognitionViewController: UIViewController {

    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var resultView: UITextView!
    
    let PREDICT_WS_URL = "http://192.168.0.105:5000/predict";
    
    var capturedImage: UIImage!;
    var roi: UIImage!;
    var recognitionResult: NSDictionary!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        capturedImageView.image = capturedImage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (recognitionResult == nil) {
            processCapture()
        }
    }
    
    func processCapture() {
        showLoading()
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(self.roi.pngData()!, withName: "image", fileName: "image.png", mimeType: "image/png")
            },
            to: PREDICT_WS_URL,
            headers: headers,
            requestModifier: { $0.timeoutInterval = 5 }
        ).validate().responseJSON(completionHandler: { response in
            self.hideLoading()
            switch response.result {
            case let .success(result):
                self.recognitionResult = result as? NSDictionary
                self.resultView.text =
                """
                Classificação: \(self.recognitionResult["class"]!)
                Precisão: \(self.recognitionResult["probability"]!)%
                """;
            case .failure:
                let alert = UIAlertController(
                    title: "Erro",
                    message: "Houve um erro ao reconhecer a imagem. Por favor tente novamente.",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Fechar"), style: .default, handler: { _ in
                    let navigationController = self.view.window!.rootViewController as? UINavigationController
                    navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func showLoading() {
        let alert = UIAlertController(title: "Processando", message: "Por favor aguarde...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func hideLoading() {
        dismiss(animated: false, completion: nil)
    }
}
