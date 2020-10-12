//
//  FailedViewController.swift
//  Eshiritori
//
//  Created by Yuki Ito on 2020/10/10.
//  Copyright © 2020 quwtoy. All rights reserved.
//

import Foundation
import UIKit

class FailedViewController: UIViewController {
    
    var argImage: UIImage! = nil
    var argMessage = ""
    var argGameOverMessage = ""
    @IBOutlet var message:UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ngButton: UIButton!
    @IBOutlet var gameOverMessage:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // NGボタンタイトルを格納
        ngButton.setTitle("close", for: .normal)
        message.text = argMessage
        gameOverMessage.text = argGameOverMessage
        
        self.view.backgroundColor = UIColor.init(red: 255/255, green: 100/255, blue: 110/255, alpha: 100/100)
        
        imageView.image = argImage
        if(argImage != nil){
            // スクリーンサイズの取得
            let screenW:CGFloat = view.frame.size.width
            let screenH:CGFloat = view.frame.size.height
            // 画像のフレームを設定
            imageView.frame = CGRect(x:0, y:0, width:128, height:128)
            // 画像を中央に設定
            imageView.center = CGPoint(x:screenW/2, y:screenH/2)
            // 設定した画像をスクリーンに表示する
            self.view.addSubview(imageView)
        }

    }
    @IBAction func ngButtonAction(_ sender: Any) {
        if(gameOverMessage.text == ""){
            dismiss(animated: true, completion: nil)
        }else{
            self.performSegue(withIdentifier: "GameOverSegue", sender: nil)
        }
        
        argImage = nil
        imageView = nil
    }
}

