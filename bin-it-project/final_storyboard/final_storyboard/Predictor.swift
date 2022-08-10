//
//  Predictor.swift
//  final
//
//  Created by Rebecca Row on 3/29/22.
//

import Foundation
import Vision
import UIKit
import CoreML

// Identifies object in frame based on CoreML model


class Predictor {
    static func createImageClassifier() -> VNCoreMLModel {
        let defaultConfig = MLModelConfiguration()
        
        let classifierWrapper = try? MobileNetV2(configuration: defaultConfig)
        
        guard let imageClassifier = classifierWrapper else {
            fatalError("Failed to create an image classifier model")
        }
        
        let classifierModel = imageClassifier.model
        
        guard let visionModel = try? VNCoreMLModel(for: classifierModel) else {
            fatalError("Failed to create a `VNCoreMLModel`")
        }
        
        return visionModel
    }
    
    private static let imageClassifier = createImageClassifier()
    
    struct Prediction {
        
        let classification: String
        
        let confidencePercentage: String
    }
    
    typealias ImagePredictionHandler = (_ predictions: [Prediction]?) -> Void
    
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()
    
    private func createImageClassifierRequest() -> VNImageBasedRequest {
        let classificationRequest = VNCoreMLRequest(model: Predictor.imageClassifier, completionHandler: visionRequestHandler)
        
        return classificationRequest
        
    }
    
    func makePredictions(for photo: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(UIDevice.current.orientation.rawValue)) else { return }
        //CGImagePropertyOrientation(rawValue: photo.imageOrientation)
        
        guard let photoImage = photo.cgImage else {
            fatalError("Photo doesn't have underlying CGImage")
            
        }
        
        let classificationRequest = createImageClassifierRequest()
        predictionHandlers[classificationRequest] = completionHandler
        
        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)
        let requests: [VNRequest] = [classificationRequest]
        
        try handler.perform(requests)
    }
    
    private func visionRequestHandler(_ request: VNRequest, error:Error?) {
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("Request must include a prediction handler")
        }
        
        var predictions: [Prediction]? = nil
        
        defer {
            predictionHandler(predictions)
        }
        
        if let error = error {
            print("Vision image classifier error...\n\n\(error.localizedDescription)")
        }
        
        if request.results == nil {
            print("Vision request had no results")
        }
        
        guard let observations = request.results as? [VNClassificationObservation] else {
            print("VNRequest produced wrong result type: \(type(of: request.results))")
            return
        }
        
        predictions = observations.map { observation in
            Prediction(classification: observation.identifier,
                       confidencePercentage: observation.confidencePercentageString)
        }
    }
}


/*in view controller:

DispatchQueue.main.async { [unowned self] in
  if let first = results.first {
     if Int(first.confidence * 100) > 1 && first.identifier == "plastic bag" {
      self.LABEL.text = "I am \String(Int(first.confidence * 100))% sure that this is a \(first.identifier)"
      self.settingImage = false
    }
  } */
