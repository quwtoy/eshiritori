//
//  TestCollectionViewController.swift
//  Eshiritori
//
//  Created by Yuki Ito on 2020/10/10.
//  Copyright © 2020 quwtoy. All rights reserved.
//

import UIKit

class TestCollectionViewController: UIViewController, UIScrollViewDelegate {
    
    // 画像インスタンス
    var drakeIsTheBestInTheWorld = UIImageView()
    var eminemIsFantastic = UIImageView()
    var lilwayneIsSuperMan = UIImageView()
    var jayzIsfamous = UIImageView()
    var kanyeIskanye = UIImageView()
    
    @IBOutlet weak var anotherScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        print(myBoundSize.width)
        print(myBoundSize.height)

        // 中身の大きさを設定
        anotherScrollView.contentSize = CGSize(width: myBoundSize.width, height: myBoundSize.height)
        // スクロールの跳ね返り
        anotherScrollView.bounces = false
        // Delegate を設定
        anotherScrollView.delegate = self

       drakeIsTheBestInTheWorld = UIImageView.init(frame: CGRect.init(x: 0, y:15, width: 100, height: 100))
       drakeIsTheBestInTheWorld.image = UIImage(named: "geta")
       let textLabel = UILabel(frame: CGRect(x: 0, y: 100, width: 100, height: 400))
        textLabel.text = "hogeegege"
       textLabel.numberOfLines = 0
       textLabel.sizeToFit()
       self.anotherScrollView.addSubview(drakeIsTheBestInTheWorld)
        self.anotherScrollView.addSubview(textLabel)

        eminemIsFantastic = UIImageView.init(frame: CGRect.init(x: 100, y:15, width: 100, height: 100))
        eminemIsFantastic.image = UIImage(named: "kyusu")
        self.anotherScrollView.addSubview(eminemIsFantastic)

        lilwayneIsSuperMan = UIImageView.init(frame: CGRect.init(x: 200, y:15, width: 100, height: 100))
        lilwayneIsSuperMan.image = UIImage(named: "ooboe")
        self.anotherScrollView.addSubview(lilwayneIsSuperMan)

        jayzIsfamous = UIImageView.init(frame: CGRect.init(x: 300, y:15, width: 100, height: 100))
        jayzIsfamous.image = UIImage(named: "redfox")
        self.anotherScrollView.addSubview(jayzIsfamous)

        kanyeIskanye = UIImageView.init(frame: CGRect.init(x: 400, y:15, width: 100, height: 100))
        kanyeIskanye.image = UIImage(named: "tanuki")
        self.anotherScrollView.addSubview(kanyeIskanye)

    }

       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /* 以下は UITextFieldDelegate のメソッド */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // スクロール中の処理
        print("didScroll")
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // ドラッグ開始時の処理
        print("beginDragging")
    }

}
