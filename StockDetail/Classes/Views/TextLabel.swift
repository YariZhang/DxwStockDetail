//
//  TextLabel.swift
//  Portfilio
//
//  Created by zhangyr on 15/5/7.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//
//  股票数据显示label
//
import UIKit

class TextLabel: UILabel {
   
    init(frame: CGRect , alignment : NSTextAlignment , toView : UIView ,fontSize : CGFloat = 12) {
        super.init(frame: frame)
        self.textColor = UtilColor.getTextBlackColor()
        self.font = UIFont.normalFontOfSize(fontSize)
        self.textAlignment = alignment
        toView.addSubview(self)
    }
    
    /*override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 0, 0, 8 * SCREEN_WIDTH / 320)))
    }*/

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
