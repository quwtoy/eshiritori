//
//  GameOverViewController.swift
//  CoreML-samples
//
//  Created by 伊藤優樹 on 2020/01/31.
//  Copyright © 2020 ytakzk. All rights reserved.
//

import Foundation
import UIKit

class GameOverViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uruuruImage = UIImage.gif(name: "uruuru")
        imageView.image = uruuruImage
        
    }
}
