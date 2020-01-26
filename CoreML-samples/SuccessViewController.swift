//
//  SuccessViewController.swift
//  CoreML-samples
//
//  Created by 伊藤優樹 on 2020/01/22.
//  Copyright © 2020 ytakzk. All rights reserved.
//

import Foundation
import UIKit

class SuccessViewController: UIViewController {
    var argImage: UIImage! = nil
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        
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
        dismiss(animated: true, completion: nil)
    }
}
