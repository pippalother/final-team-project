//
//  predictorViewController.swift
//  final_storyboard
//
//  Created by Rebecca Row on 4/13/22.
//

import Foundation
import UIKit


class predictorViewController: UIViewController {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var recycleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var yesOrNoImage:UIImage!
    
    var percentage: String = "";
    var classification: String = "";
    var recyclable: String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image=yesOrNoImage
        
        itemLabel.text = classification
        classificationLabel.text = percentage
        recycleLabel.text = recyclable
        // Do any additional setup after loading the view.
    }
    
}
