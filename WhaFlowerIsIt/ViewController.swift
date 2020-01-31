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
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var flowerDescription: UILabel!
    
    private var imagePicker = UIImagePickerController()
    
    private let urlBase : String  = "https://en.wikipedia.org/w/api.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
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
                
                let flowerName = firstResult.identifier.capitalized
                
                self.navigationItem.title = "It is a \(flowerName)"
                
                self.requestInfo(about : flowerName)
                
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        
        do{
            try handler.perform([request])
        }catch{
            print("Error while performing the request.\(error)")
        }
    }
    
    private func requestInfo(about flowerName : String){
        
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
        ]
        
        Alamofire.request(self.urlBase, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                
                print(response.result)
                
                let flowerJSON : JSON = JSON(response.result.value!)
                
                let pageId = flowerJSON["query"]["pageids"][0].stringValue
                
                let flowerInfo = flowerJSON["query"]["pages"][pageId]["extract"].stringValue
                
                let flowerImageUrl = flowerJSON["query"]["pages"][pageId]["thumbnail"]["source"].stringValue
                
                self.imageView.sd_setImage(with: URL(string: flowerImageUrl))
                
                self.flowerDescription.text = flowerInfo
            }
        }
    }
    
}

extension ViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imagePicked = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            // Na atual implementacao estamos colocando no imageView a imagem baixada da API
            //imageView.image = imagePicked
            
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

