//
//  TurnSelectViewController.swift
//  CoreML-samples
//
//  Created by 伊藤優樹 on 2020/02/24.
//  Copyright © 2020 ytakzk. All rights reserved.
//

import Foundation
import UIKit

class TurnSelectViewController: UIViewController {
    
    @IBOutlet weak var myTurnButton: UIButton!
    @IBOutlet weak var enemyTurnButton: UIButton!
    @IBOutlet weak var randomTurnButton: UIButton!
    @IBOutlet weak var initialTurnLabel: UILabel!
    
    var argLevel: String = ""
    var argLifePoint: Int = 0
    var argSelectedChar: String = ""
    var myTurnFlg: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 163/255, green: 209/255, blue: 255/255, alpha: 100/100)
        //角丸の程度を指定
        self.myTurnButton.layer.cornerRadius = 20.0
        self.enemyTurnButton.layer.cornerRadius = 20.0
        self.randomTurnButton.layer.cornerRadius = 20.0
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title:  "",
            style:  .plain,
            target: nil,
            action: nil
        )
    }
    
    @IBAction func myTurnButtonAction(_ sender: Any) {
        self.myTurnFlg = true
        initialTurnLabel.text = "「あなたからスタート」"
        // 非同期のためsleep
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.performSegue(withIdentifier: "ViewControllerSegue", sender: nil)
        }
    }
    
    @IBAction func enemyTurnButtonAction(_ sender: Any) {
        self.myTurnFlg = false
        initialTurnLabel.text = "「CPUからスタート」"
        // 非同期のためsleep
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.performSegue(withIdentifier: "ViewControllerSegue", sender: nil)
        }
    }
    
    @IBAction func randomTurnButtonAction(_ sender: Any) {
        let value = Int.random(in: 1 ... 2)
        if(value == 1){
            self.myTurnFlg = true
            initialTurnLabel.text = "「あなたからスタート」"
        }else{
            self.myTurnFlg = false
            initialTurnLabel.text = "「CPUからスタート」"
        }
        // 非同期のためsleep
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.performSegue(withIdentifier: "ViewControllerSegue", sender: nil)
        }
    }
    
    // Segueを利用し画面遷移および値渡し
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ViewControllerSegue"){
            let nextView = segue.destination as! ViewController
            nextView.argLevel = self.argLevel
            nextView.argLifePoint = self.argLifePoint
            nextView.argHint = self.argSelectedChar
            nextView.argMyTurnFlg = self.myTurnFlg
        }
    }

}
