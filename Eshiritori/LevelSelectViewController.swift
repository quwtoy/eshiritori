//
//  LevelSelectViewController.swift
//  Eshiritori
//
//  Created by Yuki Ito on 2020/10/10.
//  Copyright © 2020 quwtoy. All rights reserved.
//

import Foundation
import UIKit

class LevelSelectViewController: UIViewController {
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var normalButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    
    var level: String = ""
    var lifePoint: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 163/255, green: 209/255, blue: 255/255, alpha: 100/100)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title:  "",
            style:  .plain,
            target: nil,
            action: nil
        )
    }
    
    @IBAction func easyButtonAction(_ sender: Any) {
        self.level = "easy"
        self.lifePoint = 10
        self.performSegue(withIdentifier: "InitialCharSelectSegue", sender: nil)
    }
    
    @IBAction func normalButtonAction(_ sender: Any) {
        self.level = "normal"
        self.lifePoint = 5
        self.performSegue(withIdentifier: "InitialCharSelectSegue", sender: nil)
    }
    
    @IBAction func hardButtonAction(_ sender: Any) {
        self.level = "hard"
        self.lifePoint = 3
        self.performSegue(withIdentifier: "InitialCharSelectSegue", sender: nil)
    }
    
     // Segueを利用し画面遷移および値渡し
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // レベル選択をViewControllerへ通知
        if(segue.identifier == "InitialCharSelectSegue"){
            let nextView = segue.destination as! InitialCharSelectViewController
            nextView.argLevel = self.level
            nextView.argLifePoint = self.lifePoint
        }
        
    }

}
