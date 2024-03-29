//
//  GameOverViewController.swift
//  Eshiritori
//
//  Created by Yuki Ito on 2020/10/10.
//  Copyright © 2020 quwtoy. All rights reserved.
//

import Foundation
import UIKit

class GameOverViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var score: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel.text = "あなたのスコアは " + String(self.score) + " 点です"
        
        let uruuruImage = UIImage.gif(name: "uruuru")
        imageView.image = uruuruImage
        //角丸の程度を指定
        self.replayButton.layer.cornerRadius = 20.0
        
    }
    
    @IBAction func replayButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "replaySegue", sender: nil)
    }
}
