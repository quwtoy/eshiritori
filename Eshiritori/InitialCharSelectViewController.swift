//
//  InitialCharSelectViewController.swift
//  Eshiritori
//
//  Created by Yuki Ito on 2020/10/10.
//  Copyright © 2020 quwtoy. All rights reserved.
//

import Foundation
import UIKit

class InitialCharSelectViewController: UIViewController {
    
    @IBOutlet weak var selectCharButton: UIButton!
    @IBOutlet weak var initialCharLabel: UILabel!
    var argLevel: String = ""
    var argLifePoint: Int = 0
    var selectedChar: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 163/255, green: 209/255, blue: 255/255, alpha: 100/100)
        //角丸の程度を指定
        self.selectCharButton.layer.cornerRadius = 20.0
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title:  "",
            style:  .plain,
            target: nil,
            action: nil
        )
    }
    
    @IBAction func selectCharButtonAction(_ sender: Any) {
        let chars = ["あ", "い", "う", "え", "お","か", "き", "く", "け", "こ","さ", "し", "す", "せ", "そ","た", "ち", "つ", "て", "と","な", "に", "ね", "の","は", "ひ", "ふ", "へ", "ほ","ま", "み", "む", "め", "も","や", "ゆ", "よ", "ら", "り","る", "れ", "ろ"]
        selectedChar = chars.randomElement()!
        print(argLevel)
        print(String(argLifePoint))
        print(selectedChar)
        initialCharLabel.text = "「" + selectedChar + "」からスタート"
        // 非同期のためsleep
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.performSegue(withIdentifier: "TurnSelectSegue", sender: nil)
        }
    }
    
     // Segueを利用し画面遷移および値渡し
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "TurnSelectSegue"){
            let nextView = segue.destination as! TurnSelectViewController
            nextView.argLevel = self.argLevel
            nextView.argLifePoint = self.argLifePoint
            nextView.argSelectedChar = self.selectedChar
            
        }
    }

}
