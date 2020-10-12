//
//  SuccessViewController.swift
//  Eshiritori
//
//  Created by Yuki Ito on 2020/10/10.
//  Copyright © 2020 quwtoy. All rights reserved.
//

import Foundation
import UIKit

class SuccessViewController: UIViewController {
    var argImage: UIImage! = nil
    var argMessage = ""
    @IBOutlet var message:UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        message.text = argMessage
        
        self.view.backgroundColor = UIColor.init(red: 100/255, green: 110/255, blue: 255/255, alpha: 100/100)
        
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
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}