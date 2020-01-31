//
//  ViewController.swift
//  WhaFlowerIsIt
//
//  Created by user161182 on 1/30/20.
//  Copyright © 2020 user161182. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func detectFlower(flowerImage : CIImage){
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Could not load the model.")
        }
        
        let request = VNCoreMLRequest(model: model) { (req, error) in
            guard let results = req.results as? [VNClassificationObservation] else {
                fatalError("The model failed to process the image.")
            }
            
            if let firstResult = results.first {
                self.navigationItem.title = "It is a \(firstResult.identifier)"
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        
        do{
            try handler.perform([request])
        }catch{
            print("Error while performing the request.\(error)")
        }
    }
}

extension ViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imageView.image = imagePicked
            
            guard let ciImage = CIImage(image: imagePicked) else {
                fatalError("Can not convert image to a CIImage data type.")
            }
            
            detectFlower(flowerImage : ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}

