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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
    }
        @IBAction func close(_ sender: Any) {
            dismiss(animated: true, completion: nil)
        }
}
