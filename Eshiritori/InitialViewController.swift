//
//  InitialViewController.swift
//  Eshiritori
//
//  Created by Yuki Ito on 2020/10/10.
//  Copyright © 2020 quwtoy. All rights reserved.
//

import Foundation
import UIKit

class InitialViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 163/255, green: 209/255, blue: 255/255, alpha: 100/100)
        // ナビゲーションバーの透明化
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        // ナビゲーションバーの文字色を黒に変更
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title:  "",
            style:  .plain,
            target: nil,
            action: nil
        )
        //角丸の程度を指定
        self.startButton.layer.cornerRadius = 20.0
        
        let piyopiyoImage = UIImage.gif(name: "piyopiyo")
        imageView.image = piyopiyoImage
    }
    
    @IBAction func startButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "LevelSelectSegue", sender: nil)
    }
}

