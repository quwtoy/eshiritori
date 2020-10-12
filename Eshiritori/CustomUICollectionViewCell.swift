//
//  CustomUICollectionViewCell.swift
//  Eshiritori
//
//  Created by Yuki Ito on 2020/10/10.
//  Copyright © 2020 quwtoy. All rights reserved.
//

import UIKit

class CustomUICollectionViewCell: UICollectionViewCell {

    var textLabel : UILabel?
    var imageView: UIImageView!
    

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // UILabelを生成.
        textLabel = UILabel(frame: CGRect(x:0, y:0, width:frame.width, height:frame.height))
        textLabel?.text = "nil"
        textLabel?.backgroundColor = UIColor.white
        textLabel?.textAlignment = NSTextAlignment.center

        // Cellに追加.
        self.contentView.addSubview(textLabel!)
    }

}
