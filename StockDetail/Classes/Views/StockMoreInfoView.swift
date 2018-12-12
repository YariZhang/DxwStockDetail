//
//  StockMoreInfoView.swift
//  Subject
//
//  Created by zhangyr on 2016/11/17.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockMoreInfoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor    = Color("#fff")
        timeLabel               = UILabel()
        timeLabel.font          = UIFont.normalFontOfSize(14)
        timeLabel.textColor     = Color("#333")
        up1                     = TextValueLabel()
        up2                     = TextValueLabel()
        up3                     = TextValueLabel()
        down1                   = TextValueLabel()
        down2                   = TextValueLabel()
        down3                   = TextValueLabel()
        
        self.addSubview(timeLabel)
        self.addSubview(up1)
        self.addSubview(up2)
        self.addSubview(up3)
        self.addSubview(down1)
        self.addSubview(down2)
        self.addSubview(down3)
        
        timeLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self).offset(10)
            maker.top.equalTo(self).offset(8)
            maker.width.equalTo(110 * SCALE_WIDTH_6 - 10)
            maker.height.equalTo(14)
        }
        
        up1.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.timeLabel.snp.right)
            maker.centerY.equalTo(self.timeLabel)
            maker.width.equalTo(95 * SCALE_WIDTH_6)
            maker.height.equalTo(12)
        }
        
        up2.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.up1.snp.right)
            maker.top.equalTo(self.up1)
            maker.width.equalTo(85 * SCALE_WIDTH_6)
            maker.height.equalTo(self.up1)
        }
        
        up3.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.up2.snp.right)
            maker.top.equalTo(self.up2)
            maker.width.equalTo(self.up2)
            maker.height.equalTo(self.up2)
        }
        
        down1.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.up1)
            maker.bottom.equalTo(self).offset(-8)
            maker.width.equalTo(self.up1)
            maker.height.equalTo(self.up1)
        }
        
        down2.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.up2)
            maker.bottom.equalTo(self.down1)
            maker.width.equalTo(self.up2)
            maker.height.equalTo(self.up2)
        }
        
        down3.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.up3)
            maker.bottom.equalTo(self.down2)
            maker.width.equalTo(self.up3)
            maker.height.equalTo(self.up3)
        }
    }
    
    func show(with data : NSObject , isK : Bool) {
        down1.isHidden          = !isK
        down2.isHidden          = !isK
        down3.isHidden          = !isK
        self.isK                = isK
        
        if isK {
            guard let tmp = data as? KLineData else {
                return
            }
            
            timeLabel.text      = tmp.date
            
            let pre             = tmp.close.doubleValue - tmp.price_change.doubleValue
            up1.text            = "开"
            up1.value           = String(format: "%.2f", tmp.open.doubleValue)
            up1.color           = colorForLabel(from: tmp.open.doubleValue, to: pre)
            up2.text            = "高"
            up2.value           = String(format: "%.2f", tmp.high.doubleValue)
            up2.color           = colorForLabel(from: tmp.high.doubleValue, to: pre)
            up3.text            = "幅"
            if tmp.price_change.doubleValue > 0 {
                up3.value       = String(format: "+%.2f%%", tmp.p_change.doubleValue)
                up3.color       = Color(COLOR_COMMON_RED)
            }else{
                up3.value       = String(format: "%.2f%%", tmp.p_change.doubleValue)
                if tmp.price_change.doubleValue == 0 {
                    up3.color       = Color(COLOR_COMMON_BLACK_3)
                }else{
                    up3.color       = Color(COLOR_COMMON_GREEN)
                }
            }
            down1.text          = "收"
            down1.value         = String(format: "%.2f", tmp.close.doubleValue)
            down1.color         = colorForLabel(from: tmp.close.doubleValue, to: pre)
            down2.text          = "低"
            down2.value         = String(format: "%.2f", tmp.low.doubleValue)
            down2.color         = colorForLabel(from: tmp.low.doubleValue, to: pre)
            down3.text          = "量"
            let volume          = tmp.volume.doubleValue
            if volume >= 100_000_000 {
                down3.value     = String(format: "%.2f亿手", volume / 100_000_000)
            }else if volume >= 10_000_000 {
                down3.value     = String(format: "%.2f千万手", volume / 10_000_000)
            }else if volume >= 100000 {
                down3.value     = String(format: "%.2f万手", volume / 10000)
            }else{
                down3.value     = String(format: "%.0f手", volume)
            }
            down3.color         = Color("#333")
            
        }else{
            guard let tmp = data as? PointInfo else {
                return
            }
            timeLabel.text      = tmp.min
            
            up1.text            = "价"
            up1.value           = String(format: "%.2f", tmp.currentPrice)
            up2.text            = "幅"
            let rate            = tmp.p_change ?? 0
            if rate > 0 {
                up2.value       = String(format: "+%.2f%%", rate)
                up2.color       = Color(COLOR_COMMON_RED)
            }else{
                up2.value       = String(format: "%.2f%%", rate)
                if rate == 0 {
                    up2.color       = Color(COLOR_COMMON_BLACK_3)
                }else{
                    up2.color       = Color(COLOR_COMMON_GREEN)
                }
            }
            up1.color           = up2.color
            up3.text            = "量"
            up3.value           = tmp.volStr
            up3.color           = tmp.volColor
        }
    }
    
    fileprivate func colorForLabel(from num1 : Double , to num2 : Double) -> UIColor {
        return num1 > num2 ? Color(COLOR_COMMON_RED) : num1 == num2 ? Color(COLOR_COMMON_BLACK_3) : Color(COLOR_COMMON_GREEN)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var timeLabel   : UILabel!
    fileprivate var up1         : TextValueLabel!
    fileprivate var up2         : TextValueLabel!
    fileprivate var up3         : TextValueLabel!
    fileprivate var down1       : TextValueLabel!
    fileprivate var down2       : TextValueLabel!
    fileprivate var down3       : TextValueLabel!
    fileprivate var isK         : Bool = true {
        didSet {
            if isK != oldValue {
                if isK {
                    timeLabel.snp.remakeConstraints { (maker) in
                        maker.left.equalTo(self).offset(10)
                        maker.top.equalTo(self).offset(8)
                        maker.width.equalTo(110 * SCALE_WIDTH_6 - 10)
                        maker.height.equalTo(14)
                    }
                }else{
                    timeLabel.snp.remakeConstraints { (maker) in
                        maker.left.equalTo(self).offset(10)
                        maker.centerY.equalTo(self)
                        maker.width.equalTo(110 * SCALE_WIDTH_6 - 10)
                        maker.height.equalTo(14)
                    }
                }
            }
        }
    }

}

class TextValueLabel : UIView {
    
    var text : String? {
        didSet {
            hintLabel.text  = text
        }
    }
    
    var value : String? {
        didSet {
            valLabel.text   = value
        }
    }
    
    var color : UIColor! {
        didSet {
            valLabel.textColor  = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        hintLabel           = UILabel()
        hintLabel.font      = UIFont.normalFontOfSize(12)
        hintLabel.textColor = Color("#999")
        self.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.centerY.equalTo(self)
        }
        
        valLabel            = UILabel()
        valLabel.font       = UIFont.normalFontOfSize(12)
        valLabel.textColor  = Color("#333")
        self.addSubview(valLabel)
        valLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(hintLabel.snp.right).offset(4)
            maker.centerY.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var hintLabel   : UILabel!
    fileprivate var valLabel    : UILabel!
}
