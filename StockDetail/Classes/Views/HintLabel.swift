//
//  HintLabel.swift
//  Portfilio
//
//  Created by zhangyr on 15/5/7.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//
//  股票详情页标签性label
//

import UIKit
import BasicService

class HintLabel: UILabel {
   
    init(frame : CGRect , alignment : NSTextAlignment , title : String , toView : UIView , fontSize : CGFloat = 12) {
        super.init(frame: frame)
        self.textColor = UtilColor.getHintLabelColor()
        self.font = UIFont.normalFontOfSize(fontSize)
        self.textAlignment = alignment
        self.text = title
        toView.addSubview(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ProtfolioTableViewCell : UITableViewCell {
    
    var stockInfo : NSDictionary!
    var checkoutType : Int!
    fileprivate var stockName : UILabel!
    fileprivate var stockCode : UILabel!
    //private var stockComment : UIButton!
    fileprivate var stockPrice : UILabel!
    fileprivate var stockDetail : BaseButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor            = Color("#fff")
        let selectedView                = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 50))
        selectedView.alpha              = 0.8
        selectedView.backgroundColor    = Color("#f9f9f9")
        self.selectedBackgroundView     = selectedView
        
        stockName                   = UILabel()
        stockName.textColor         = Color("#333333")
        stockName.font              = UIFont.normalFontOfSize(16)
        self.addSubview(stockName)
        stockName.snp.makeConstraints { (maker) in
            maker.left.equalTo(self).offset(12)
            maker.top.equalTo(self).offset(9)
            maker.left.equalTo(200)
        }
        stockCode                   = UILabel()
        stockCode.textColor         = Color("#999999")
        stockCode.font              = UIFont.normalFontOfSize(12)
        self.addSubview(stockCode)
        stockCode.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.stockName)
            maker.bottom.equalTo(self).offset(-9)
        }
        stockPrice                  = UILabel()
        stockPrice.textAlignment    = NSTextAlignment.center
        stockPrice.text             = "--"
        stockPrice.textColor        = Color("#333333")
        stockPrice.font             = UIFont.boldFontOfSize(18)
        self.addSubview(stockPrice)
        stockPrice.snp.makeConstraints { (maker) in
            maker.center.equalTo(self)
            maker.width.equalTo(200)
        }
        stockDetail                     = BaseButton()
        stockDetail.layer.cornerRadius  = 3
        stockDetail.layer.masksToBounds = true
        stockDetail.backgroundColor     = Color("#999999")
        stockDetail.titleLabel?.font    = UIFont.boldFontOfSize(18)
        stockDetail.setTitleColor(Color("#fff"), for: UIControl.State())
        stockDetail.setTitle("--", for: UIControl.State())
        stockDetail.addTarget(self, action: #selector(ProtfolioTableViewCell.showOtherInfo(_:)), for: UIControl.Event.touchUpInside)
        self.addSubview(stockDetail)
        stockDetail.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(self)
            maker.right.equalTo(self).offset(-12)
            maker.width.equalTo(80)
            maker.height.equalTo(28)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if stockInfo == nil {
            return
        }
        
        let name        = stockInfo.object(forKey: "name") + ""
        let code        = stockInfo.object(forKey: "code") + ""
        let price       = stockInfo.object(forKey: "price") + ""
        let rate        = stockInfo.parseNumber("p_change", numberType: ParseNumberType.float) as! Float
        let floatPrice  = stockInfo.parseNumber("price_change", numberType: ParseNumberType.float) as! Float
        var totalAmount : Float = 0
        let t_p = stockInfo.parseNumber("is_tp", numberType: ParseNumberType.int) as! Int
        let is_tp = t_p == 1
        totalAmount = stockInfo.parseNumber("totalShare", numberType: ParseNumberType.float) as! Float
        
        stockName.text = name
        stockCode.text = code
        stockPrice.text = price
        
        var rateStr = ""
        var bcolor  = UIColor()
        var tcolor  = UIColor.white
        var scolor  = Color("#999999")
        switch checkoutType {
        case 1:
            if rate == 0 || is_tp {
                if is_tp {
                    rateStr = "停牌"
                }else{
                    rateStr = String(format: "%.2f%%", rate)
                }
                bcolor = Color("#333")
                tcolor = Color("#fff")
            }else if rate < 0 {
                rateStr = String(format: "%.2f%%", rate)
                bcolor  = UtilColor.getGreenColor()
                scolor  = UtilColor.getGreenColor()
            }else{
                rateStr = String(format: "+%.2f%%", rate)
                bcolor  = UtilColor.getRedStockColor()
                scolor  = UtilColor.getRedStockColor()
            }
        case 2:
            if floatPrice == 0 || is_tp {
                if is_tp {
                    rateStr = "停牌"
                }else{
                    rateStr = String(format: "%.2f", floatPrice)
                }
                bcolor = Color("#333")
                tcolor = Color("#fff")
            }else if floatPrice < 0 {
                rateStr = String(format: "%.2f", floatPrice)
                bcolor  = UtilColor.getGreenColor()
                scolor  = UtilColor.getGreenColor()
            }else{
                rateStr = String(format: "+%.2f", floatPrice)
                bcolor  = UtilColor.getRedStockColor()
                scolor  = UtilColor.getRedStockColor()
            }
        default :
            if rate == 0 || is_tp {
                bcolor = Color("#333")
                tcolor = Color("#fff")
            }else if rate < 0 {
                bcolor  = UtilColor.getGreenColor()
                scolor  = UtilColor.getGreenColor()
            }else{
                bcolor  = UtilColor.getRedStockColor()
                scolor  = UtilColor.getRedStockColor()
            }
            rateStr = UtilTools.formatTotalAmount(CGFloat(totalAmount))
            if totalAmount == 0 {
                rateStr = "--"
            }
        }
        
        stockPrice.textColor            = bcolor
        stockDetail.setTitle(rateStr, for: UIControl.State())
        stockDetail.setTitleColor(tcolor, for: UIControl.State())
        stockDetail.backgroundColor     = scolor
    }
    
    @objc func showOtherInfo(_ btn : UIButton) {
        //println("showInfo")
        self.checkoutType = self.checkoutType + 1
        if self.checkoutType > 3 {
            self.checkoutType = 1
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "checkoutType"), object: nil, userInfo: ["type" : self.checkoutType])
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
