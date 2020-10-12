//
//  CustomCell.swift
//  UITableViewTimelineSample
//
//  Created by Yuki Ito on 2020/10/10.
//  Copyright © 2020 quwtoy. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var meTalkView: UIView!
    
    @IBOutlet weak var meTalkLabel: UILabel!
    
    @IBOutlet weak var partnerTalkView: UIView!
    
    @IBOutlet weak var partnerTalkLabel: UILabel!
    
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    
    func talk(isMe: Bool, text: String) {
        meTalkView.isHidden = !isMe
        partnerTalkView.isHidden = isMe
        
        meTalkLabel.text = isMe ? text : ""
        partnerTalkLabel.text = isMe ? "" : text
        
        guard let font = isMe ? meTalkLabel.font : partnerTalkLabel.font else { return }
        cellHeight.constant = labelHeight(text: text, width: UIScreen.main.bounds.width - 60, font: font) + 24
    }
    
    private func labelHeight(text: String, width: CGFloat, font: UIFont, maxLine: Int = 0) -> CGFloat {
        let label = UILabel()
        label.font = font
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = maxLine
        label.text = text
        let rect: CGSize = label.sizeThatFits(CGSize(width: width-label.layoutMargins.left-label.layoutMargins.right,
                                                     height: CGFloat.greatestFiniteMagnitude))
        return rect.height
    }
}
