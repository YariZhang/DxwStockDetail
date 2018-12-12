//
//  StockHeaderInfoView.swift
//  Subject
//
//  Created by zhangyr on 2016/11/28.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

enum StockHeaderType: Int {
    case stock
    case plate
}

class StockHeaderInfoView: BaseView {
    
    var infoData : Dictionary<String,Any>! {
        didSet {
            if infoData != nil {
                showData()
            }
        }
    }

    required init(type : StockHeaderType) {
        self.type = type
        super.init(frame: CGRect.zero)
    }
    
    override func initUI() {
        super.initUI()
        self.backgroundColor = UIColor.white
        
        backColorView = UIView()
        self.addSubview(backColorView)
        
        currentPrice = UILabel()
        currentPrice.font = UIFont.boldFontOfSize(28)
        currentPrice.textColor = HexColor("#333")
        currentPrice.textAlignment = .center
        currentPrice.text = "--"
        self.addSubview(currentPrice)
        
        backColorView.snp.makeConstraints({ (maker) in
            maker.left.equalTo(currentPrice).offset(8)
            maker.right.equalTo(currentPrice)
            maker.top.equalTo(self).offset(8)
            maker.bottom.equalTo(self).offset(-8)
        })
        
        switch type {
        case .stock:
            currentPrice.snp.makeConstraints({ (maker) in
                maker.left.equalTo(self)
                maker.centerY.equalTo(self).offset(-8)
                maker.width.equalTo(125 * SCALE_WIDTH_6)
                maker.height.equalTo(29)
            })
            
            changeInfoLabel = UILabel()
            changeInfoLabel?.font = UIFont.normalFontOfSize(14)
            changeInfoLabel?.textColor = HexColor("#333")
            changeInfoLabel?.textAlignment = .center
            changeInfoLabel?.text = "--"
            self.addSubview(changeInfoLabel!)
            changeInfoLabel?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(currentPrice)
                maker.top.equalTo(currentPrice.snp.bottom)
                maker.width.equalTo(currentPrice)
                maker.height.equalTo(15)
            })
            
            open = StockInfoItem()
            open?.text = "开"
            self.addSubview(open!)
            open?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(currentPrice.snp.right).offset(10 * SCALE_WIDTH_6)
                maker.top.equalTo(self).offset(12)
                maker.height.equalTo(15)
                maker.width.equalTo(71 * SCALE_WIDTH_6)
            })
            
            high = StockInfoItem()
            high?.text = "高"
            self.addSubview(high!)
            high?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(open!.snp.right)
                maker.top.equalTo(open!)
                maker.height.equalTo(open!)
                maker.width.equalTo(open!)
            })
            
            volume = StockInfoItem()
            volume?.text = "额"
            volume?.space = 15
            self.addSubview(volume!)
            volume?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(high!.snp.right)
                maker.top.equalTo(high!)
                maker.height.equalTo(high!)
                maker.width.equalTo(91 * SCALE_WIDTH_6)
            })
            
            turnover = StockInfoItem()
            turnover?.text = "换"
            self.addSubview(turnover!)
            turnover?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(open!)
                maker.bottom.equalTo(self).offset(-12)
                maker.width.equalTo(open!)
                maker.height.equalTo(open!)
            })
            
            low = StockInfoItem()
            low?.text = "低"
            self.addSubview(low!)
            low?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(high!)
                maker.bottom.equalTo(turnover!)
                maker.height.equalTo(turnover!)
                maker.width.equalTo(high!)
            })
            
            totalShare = StockInfoItem()
            totalShare?.text = "市值"
            self.addSubview(totalShare!)
            totalShare?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(volume!)
                maker.bottom.equalTo(low!)
                maker.height.equalTo(turnover!)
                maker.width.equalTo(volume!)
            })
            
            verLine = UIView()
            verLine?.backgroundColor = HexColor("#ddd")
            self.addSubview(verLine!)
            verLine?.snp.makeConstraints({ (maker) in
                maker.right.equalTo(self).offset(-12 * SCALE_WIDTH_6)
                maker.top.equalTo(self)
                maker.bottom.equalTo(self)
                maker.width.equalTo(0.5)
            })
            
            triangle = UIImageView()
            triangle?.image = UIImage(named: "stock_detail_triangle")
            self.addSubview(triangle!)
            triangle?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(verLine!.snp.right).offset(3 * SCALE_WIDTH_6)
                maker.centerY.equalTo(self)
            })
            
            button = BaseButton()
            button?.addTarget(self, action: #selector(StockHeaderInfoView.viewMore), for: UIControl.Event.touchUpInside)
            self.addSubview(button!)
            button?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(open!)
                maker.right.equalTo(self)
                maker.top.equalTo(self)
                maker.bottom.equalTo(self)
            })
            
            break
        default:
            currentPrice.snp.makeConstraints({ (maker) in
                maker.left.equalTo(self)
                maker.centerY.equalTo(self)
                maker.width.equalTo(140 * SCALE_WIDTH_6)
                maker.height.equalTo(29)
            })
            
            raise = StockInfoItem()
            raise?.text = "涨"
            raise?.textFont = UIFont.normalFontOfSize(16)
            raise?.valFont = UIFont.normalFontOfSize(16)
            raise?.valColor = HexColor(COLOR_COMMON_RED)
            self.addSubview(raise!)
            raise?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(currentPrice.snp.right).offset(10 * SCALE_WIDTH_6)
                maker.centerY.equalTo(currentPrice)
                maker.height.equalTo(17)
                maker.width.equalTo(80 * SCALE_WIDTH_6)
            })
            
            fall = StockInfoItem()
            fall?.text = "跌"
            fall?.textFont = UIFont.normalFontOfSize(16)
            fall?.valFont = UIFont.normalFontOfSize(16)
            fall?.valColor = HexColor(COLOR_COMMON_GREEN)
            self.addSubview(fall!)
            fall?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(raise!.snp.right)
                maker.centerY.equalTo(raise!)
                maker.width.equalTo(73 * SCALE_WIDTH_6)
                maker.height.equalTo(raise!)
            })
            
            flat = StockInfoItem()
            flat?.text = "平"
            flat?.textFont = UIFont.normalFontOfSize(16)
            flat?.valFont = UIFont.normalFontOfSize(16)
            flat?.valColor = HexColor(COLOR_COMMON_BLACK_3)
            self.addSubview(flat!)
            flat?.snp.makeConstraints({ (maker) in
                maker.left.equalTo(fall!.snp.right)
                maker.centerY.equalTo(fall!)
                maker.width.equalTo(72 * SCALE_WIDTH_6)
                maker.height.equalTo(fall!)
            })
            
            break
        }
    }
    
    private func showData() {
        switch type {
        case .stock:
            let isTp = infoData.getNumberForKey("is_tp").intValue == 1
            if isTp {
                currentPrice.textColor = HexColor("#ddd")
                changeInfoLabel?.textColor = HexColor("#ddd")
                currentPrice.text = infoData["price"] + ""
                changeInfoLabel?.text = "停牌"
            }else{
                
                //current
                
                let preClose = infoData.getNumberForKey("pre_close").floatValue
                let price = infoData.getNumberForKey("price").floatValue
                let pChange = infoData["p_change"] + ""
                let priceChange = infoData["price_change"] + ""
                if price > preClose {
                    currentPrice.textColor = HexColor(COLOR_COMMON_RED)
                    changeInfoLabel?.textColor = HexColor(COLOR_COMMON_RED)
                }else if price == preClose {
                    currentPrice.textColor = HexColor(COLOR_COMMON_BLACK_3)
                    changeInfoLabel?.textColor = HexColor(COLOR_COMMON_BLACK_3)
                }else{
                    currentPrice.textColor = HexColor(COLOR_COMMON_GREEN)
                    changeInfoLabel?.textColor = HexColor(COLOR_COMMON_GREEN)
                }
                
                var symbol = ""
                if let p = Double(priceChange) , p > 0.001 {
                    symbol = "+"
                }
                
                if let pre = Float(currentPrice.text!) {
                    if pre > price {
                        backColorView.backgroundColor = HexColor(COLOR_COMMON_GREEN).withAlphaComponent(0.3)
                    }else if pre == price {
                        backColorView.backgroundColor = UIColor.clear
                    }else{
                        backColorView.backgroundColor = HexColor(COLOR_COMMON_RED).withAlphaComponent(0.3)
                    }
                    
                    backColorView.alpha = 0
                    
                    UIView.animateKeyframes(withDuration: 0.3, delay: 0.2, options: UIView.KeyframeAnimationOptions.overrideInheritedDuration, animations: { () -> Void in
                        self.backColorView.alpha = 1
                    }) { (Bool) -> Void in
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.backColorView.alpha = 0
                        }, completion: { (Bool) -> Void in
                            self.currentPrice.text = self.infoData["price"] + ""
                            self.changeInfoLabel?.text = "\(symbol + priceChange)  \(symbol + pChange)%"
                        })
                    }
                    
                }else{
                    currentPrice.text = self.infoData["price"] + ""
                    changeInfoLabel?.text = "\(symbol + priceChange)  \(symbol + pChange)%"
                }
                
            }
            
            open?.value = infoData["open"] + ""
            high?.value = infoData["high"] + ""
            volume?.value = UtilTools.formatTotalAmount(CGFloat(infoData.getNumberForKey("amount").floatValue))
            turnover?.value = String(format: "%.2f%%", infoData.getNumberForKey("turnover").floatValue)
            low?.value = infoData["low"] + ""
            totalShare?.value = UtilTools.formatTotalAmount(CGFloat(infoData.getNumberForKey("totalShare").floatValue))
            
            break
        default:
            
            let preClose = infoData.getNumberForKey("pre_close").floatValue
            let price = infoData.getNumberForKey("price").floatValue
            let pChange = infoData["p_change"] + ""
            let tmpP = infoData.getNumberForKey("p_change").floatValue
            let priceChange = infoData["price_change"] + ""
            if price > preClose {
                currentPrice.textColor = HexColor(COLOR_COMMON_RED)
            }else if price == preClose {
                currentPrice.textColor = HexColor(COLOR_COMMON_BLACK_3)
            }else{
                currentPrice.textColor = HexColor(COLOR_COMMON_GREEN)
            }
            
            var symbol = ""
            if let p = Double(priceChange) , p > 0.001 {
                symbol = "+"
            }
            
            if let pre = Float(currentPrice.text! - "%") {
                if pre > tmpP {
                    backColorView.backgroundColor = HexColor(COLOR_COMMON_GREEN).withAlphaComponent(0.3)
                }else if pre == tmpP {
                    backColorView.backgroundColor = UIColor.clear
                }else{
                    backColorView.backgroundColor = HexColor(COLOR_COMMON_RED).withAlphaComponent(0.3)
                }
                
                backColorView.alpha = 0
                
                UIView.animateKeyframes(withDuration: 0.3, delay: 0.2, options: UIView.KeyframeAnimationOptions.overrideInheritedDuration, animations: { () -> Void in
                    self.backColorView.alpha = 1
                }) { (Bool) -> Void in
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        self.backColorView.alpha = 0
                    }, completion: { (Bool) -> Void in
                        self.currentPrice.text = symbol + pChange + "%"
                    })
                }
                
            }else{
                self.currentPrice.text = symbol + pChange + "%"
            }
            
            raise?.value = infoData["rise_count"] + ""
            fall?.value = infoData["fall_count"] + ""
            flat?.value = infoData["flat_count"] + ""
            break
        }
    }
    
    @objc private func viewMore() {
        if infoData != nil {
            Behavior.eventReport("pankou")
            let infoAlert = StockMoreInfoAlert()
            infoAlert.show(withData: infoData)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var type : StockHeaderType
    
    private var backColorView : UIView!
    private var currentPrice : UILabel!
    
    private var changeInfoLabel : UILabel?
    private var open : StockInfoItem?
    private var high : StockInfoItem?
    private var volume : StockInfoItem?
    private var turnover : StockInfoItem?
    private var low : StockInfoItem?
    private var totalShare : StockInfoItem?
    private var verLine : UIView?
    private var triangle : UIImageView?
    private var button : BaseButton?
    
    private var raise : StockInfoItem?
    private var fall : StockInfoItem?
    private var flat : StockInfoItem?

}

class StockMoreInfoAlert: BaseView {
    
    override func initUI() {
        super.initUI()
        self.backgroundColor = HexColor(COLOR_COMMON_BLACK_30)
        
        ///contentView 的圆角
        let radius : CGFloat = 4
        ///contentView 的宽
        let contentWidth : CGFloat = 300
        ///contentView 的高
        let contentHeight : CGFloat = 235
        ///contentView 头部高
        let topHeight : CGFloat = 50
        ///取消按钮的大小
        let btnSize : CGFloat = 30
        ///取消按钮的右边距
        let btnRight : CGFloat = -10
        ///左边item的边距
        let itemLeft : CGFloat = 15
        ///最上item离头部边距
        let itemTop : CGFloat = 16
        ///前排item的宽
        let foreItemWidth : CGFloat = 148
        ///item的高
        let itemHeight : CGFloat = 15
        ///item之间的间距
        let itemOffset : CGFloat = 12
        ///三个字符的item value项偏移
        let threeCharsSpace : CGFloat = 8
        ///两个字符的item value项偏移
        let twoCharsSpace : CGFloat = 22
        ///字体大小
        let fontSize : CGFloat = 14
        
        
        contentView = UIView()
        contentView.backgroundColor = HexColor(COLOR_COMMON_WHITE)
        contentView.layer.cornerRadius = radius
        contentView.layer.masksToBounds = true
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (maker) in
            maker.center.equalTo(self)
            maker.width.equalTo(contentWidth * SCALE_WIDTH_6)
            maker.height.equalTo(contentHeight)
        }
        
        topView = UIView()
        topView.backgroundColor = HexColor(COLOR_COMMON_RED)
        contentView.addSubview(topView)
        topView.snp.makeConstraints { (maker) in
            maker.left.equalTo(contentView)
            maker.right.equalTo(contentView)
            maker.top.equalTo(contentView)
            maker.height.equalTo(topHeight)
        }
        
        topTitle = UILabel()
        topTitle.font = UIFont.normalFontOfSize(18)
        topTitle.textColor = HexColor(COLOR_COMMON_WHITE)
        topTitle.textAlignment = .center
        topTitle.text = "行情数据"
        topView.addSubview(topTitle)
        topTitle.snp.makeConstraints { (maker) in
            maker.center.equalTo(topView)
        }
        
        cancelBtn = BaseButton()
        cancelBtn.addTarget(self, action: #selector(StockMoreInfoAlert.cancelAction), for: UIControl.Event.touchUpInside)
        cancelBtn.setImage(UIImage(named: "ic_stock_close"), for: UIControl.State.normal)
        topView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (maker) in
            maker.right.equalTo(topView).offset(btnRight * SCALE_WIDTH_6)
            maker.centerY.equalTo(topView)
            maker.width.equalTo(btnSize)
            maker.height.equalTo(btnSize)
        }
        
        
        bottomView = UIView()
        bottomView.backgroundColor = HexColor(COLOR_COMMON_WHITE)
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (maker) in
            maker.left.equalTo(contentView)
            maker.right.equalTo(contentView)
            maker.top.equalTo(topView.snp.bottom)
            maker.bottom.equalTo(contentView)
        }
        
        open = StockInfoItem()
        open.text = "今开"
        open.space = twoCharsSpace
        open.valFont = UIFont.boldFontOfSize(fontSize)
        bottomView.addSubview(open)
        open.snp.makeConstraints { (maker) in
            maker.left.equalTo(bottomView).offset(itemLeft * SCALE_WIDTH_6)
            maker.top.equalTo(bottomView).offset(itemTop)
            maker.width.equalTo(foreItemWidth * SCALE_WIDTH_6)
            maker.height.equalTo(itemHeight)
        }
        
        preClose = StockInfoItem()
        preClose.text = "昨收"
        preClose.space = twoCharsSpace
        preClose.valFont = UIFont.boldFontOfSize(fontSize)
        bottomView.addSubview(preClose)
        preClose.snp.makeConstraints { (maker) in
            maker.left.equalTo(open.snp.right)
            maker.top.equalTo(open)
            maker.right.equalTo(bottomView)
            maker.height.equalTo(open)
        }
        
        high = StockInfoItem()
        high.text = "最高"
        high.space = twoCharsSpace
        high.valFont = UIFont.boldFontOfSize(fontSize)
        bottomView.addSubview(high)
        high.snp.makeConstraints { (maker) in
            maker.left.equalTo(open)
            maker.top.equalTo(open.snp.bottom).offset(itemOffset)
            maker.width.equalTo(open)
            maker.height.equalTo(open)
        }
        
        low = StockInfoItem()
        low.text = "最低"
        low.space = twoCharsSpace
        low.valFont = UIFont.boldFontOfSize(fontSize)
        bottomView.addSubview(low)
        low.snp.makeConstraints { (maker) in
            maker.left.equalTo(preClose)
            maker.top.equalTo(high)
            maker.width.equalTo(preClose)
            maker.height.equalTo(preClose)
        }
        
        turnover = StockInfoItem()
        turnover.text = "换手率"
        turnover.space = threeCharsSpace
        turnover.valFont = UIFont.boldFontOfSize(fontSize)
        bottomView.addSubview(turnover)
        turnover.snp.makeConstraints { (maker) in
            maker.left.equalTo(high)
            maker.top.equalTo(high.snp.bottom).offset(itemOffset)
            maker.width.equalTo(high)
            maker.height.equalTo(high)
        }
        
        pChange = StockInfoItem()
        pChange.text = "振幅"
        pChange.space = twoCharsSpace
        pChange.valFont = UIFont.boldFontOfSize(fontSize)
        bottomView.addSubview(pChange)
        pChange.snp.makeConstraints { (maker) in
            maker.left.equalTo(low)
            maker.top.equalTo(turnover)
            maker.width.equalTo(low)
            maker.height.equalTo(low)
        }
        
        volume = StockInfoItem()
        volume.text = "成交量"
        volume.space = threeCharsSpace
        volume.valFont = UIFont.boldFontOfSize(fontSize)
        bottomView.addSubview(volume)
        volume.snp.makeConstraints { (maker) in
            maker.left.equalTo(turnover)
            maker.top.equalTo(turnover.snp.bottom).offset(itemOffset)
            maker.width.equalTo(turnover)
            maker.height.equalTo(turnover)
        }
        
        amount = StockInfoItem()
        amount.text = "成交额"
        amount.space = threeCharsSpace
        amount.valFont = UIFont.boldFontOfSize(fontSize)
        bottomView.addSubview(amount)
        amount.snp.makeConstraints { (maker) in
            maker.left.equalTo(pChange)
            maker.top.equalTo(volume)
            maker.width.equalTo(pChange)
            maker.height.equalTo(pChange)
        }
        
        inVol = StockInfoItem()
        inVol.text = "内盘"
        inVol.space = twoCharsSpace
        inVol.valColor = HexColor(COLOR_COMMON_GREEN)
        inVol.valFont = UIFont.boldFontOfSize(fontSize)
        bottomView.addSubview(inVol)
        inVol.snp.makeConstraints { (maker) in
            maker.left.equalTo(volume)
            maker.top.equalTo(volume.snp.bottom).offset(itemOffset)
            maker.width.equalTo(volume)
            maker.height.equalTo(volume)
        }
        
        outVol = StockInfoItem()
        outVol.text = "外盘"
        outVol.space = twoCharsSpace
        outVol.valColor = HexColor(COLOR_COMMON_RED)
        outVol.valFont = UIFont.boldFontOfSize(fontSize)
        bottomView.addSubview(outVol)
        outVol.snp.makeConstraints { (maker) in
            maker.left.equalTo(amount)
            maker.top.equalTo(inVol)
            maker.width.equalTo(amount)
            maker.height.equalTo(amount)
        }
        
        totalShare = StockInfoItem()
        totalShare.text = "总市值"
        totalShare.space = threeCharsSpace
        totalShare.valFont = UIFont.boldFontOfSize(fontSize)
        bottomView.addSubview(totalShare)
        totalShare.snp.makeConstraints { (maker) in
            maker.left.equalTo(inVol)
            maker.top.equalTo(inVol.snp.bottom).offset(itemOffset)
            maker.width.equalTo(inVol)
            maker.height.equalTo(inVol)
        }
        
        flowShare = StockInfoItem()
        flowShare.text = "流通值"
        flowShare.space = threeCharsSpace
        flowShare.valFont = UIFont.boldFontOfSize(fontSize)
        bottomView.addSubview(flowShare)
        flowShare.snp.makeConstraints { (maker) in
            maker.left.equalTo(outVol)
            maker.top.equalTo(totalShare)
            maker.width.equalTo(outVol)
            maker.height.equalTo(outVol)
        }
        
    }
    
    func show(withData data : Dictionary<String,Any>) {
        let isShow = self.superview != nil
        
        let preClosePrice = data.getNumberForKey("pre_close").floatValue
        preClose.value = data["pre_close"] + ""
        
        let openPrice = data.getNumberForKey("open").floatValue
        if preClosePrice > openPrice {
            open.valColor = HexColor(COLOR_COMMON_GREEN)
        }else if preClosePrice < openPrice {
            open.valColor = HexColor(COLOR_COMMON_RED)
        }else{
            open.valColor = HexColor(COLOR_COMMON_BLACK_3)
        }
        open.value = data["open"] + ""
        
        let highPrice = data.getNumberForKey("high").floatValue
        if preClosePrice > highPrice {
            high.valColor = HexColor(COLOR_COMMON_GREEN)
        }else if preClosePrice < highPrice {
            high.valColor = HexColor(COLOR_COMMON_RED)
        }else{
            high.valColor = HexColor(COLOR_COMMON_BLACK_3)
        }
        high.value = data["high"] + ""
        
        let lowPrice = data.getNumberForKey("low").floatValue
        if preClosePrice > lowPrice {
            low.valColor = HexColor(COLOR_COMMON_GREEN)
        }else if preClosePrice < lowPrice {
            low.valColor = HexColor(COLOR_COMMON_RED)
        }else{
            low.valColor = HexColor(COLOR_COMMON_BLACK_3)
        }
        low.value = data["low"] + ""
        
        turnover.value = String(format: "%.2f%%", data.getNumberForKey("turnover").floatValue)
        
        pChange.value = String(format: "%.2f%%", data.getNumberForKey("zf").floatValue)
        
        volume.value = UtilTools.formatTotalAmount(CGFloat(data.getNumberForKey("volume").floatValue / 100)) + "手"
        
        amount.value = UtilTools.formatTotalAmount(CGFloat(data.getNumberForKey("amount").floatValue))
        
        inVol.value = UtilTools.formatTotalAmount(CGFloat(data.getNumberForKey("invol").floatValue))
        
        outVol.value = UtilTools.formatTotalAmount(CGFloat(data.getNumberForKey("outvol").floatValue))
        
        totalShare.value = UtilTools.formatTotalAmount(CGFloat(data.getNumberForKey("totalShare").floatValue))
        
        flowShare.value = UtilTools.formatTotalAmount(CGFloat(data.getNumberForKey("csv").floatValue))
        
        
        if !isShow {
            UtilTools.getAppDelegate()?.window??.addSubview(self)
            self.snp.makeConstraints { (maker) in
                maker.left.equalTo(self.superview!)
                maker.right.equalTo(self.superview!)
                maker.top.equalTo(self.superview!)
                maker.bottom.equalTo(self.superview!)
            }
            
            self.alpha = 0
            contentView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.alpha = 1
                self.contentView.transform = CGAffineTransform.identity
            }, completion: nil)
        }
        
        
    }
    
    @objc private func cancelAction() {
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }, completion: {(bool) in
            self.removeFromSuperview()
        })
        
    }
    
    private var contentView : UIView!
    private var topView : UIView!
    private var bottomView : UIView!
    private var topTitle : UILabel!
    private var cancelBtn : BaseButton!
    
    private var open : StockInfoItem!
    private var preClose : StockInfoItem!
    private var high : StockInfoItem!
    private var low : StockInfoItem!
    private var turnover : StockInfoItem!
    private var pChange : StockInfoItem!
    private var volume : StockInfoItem!
    private var amount : StockInfoItem!
    private var inVol : StockInfoItem!
    private var outVol : StockInfoItem!
    private var totalShare : StockInfoItem!
    private var flowShare : StockInfoItem!
    
}

class StockInfoItem: BaseView {
    
    var textColor : UIColor = HexColor("#999") {
        didSet {
            textLabel.textColor = textColor
        }
    }
    var valColor : UIColor = HexColor("#333") {
        didSet {
            valLabel.textColor = valColor
        }
    }
    var textFont : UIFont = UIFont.normalFontOfSize(14, needScale: true) {
        didSet {
            textLabel.font = textFont
            textLabel.snp.updateConstraints { (maker) in
                maker.height.equalTo(textFont.pointSize + 1)
            }
        }
    }
    var valFont : UIFont = UIFont.normalFontOfSize(14, needScale: true) {
        didSet {
            valLabel.font = valFont
            valLabel.snp.updateConstraints { (maker) in
                maker.height.equalTo(valFont.pointSize + 1)
            }
        }
    }
    var text : String? {
        didSet {
            textLabel.text = text
        }
    }
    var value : String? {
        didSet {
            valLabel.text = value
        }
    }
    var space : CGFloat = 2 {
        didSet {
            valLabel.snp.updateConstraints { (maker) in
                maker.left.equalTo(textLabel.snp.right).offset(space)
            }
        }
    }
    
    override func initUI() {
        super.initUI()
        
        textLabel = UILabel()
        textLabel.font = textFont
        textLabel.textColor = textColor
        self.addSubview(textLabel)
        textLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.centerY.equalTo(self)
            maker.height.equalTo(textFont.pointSize + 1)
        }
        
        valLabel = UILabel()
        valLabel.font = valFont
        valLabel.textColor = valColor
        self.addSubview(valLabel)
        valLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(textLabel.snp.right).offset(space)
            maker.centerY.equalTo(textLabel)
            maker.height.equalTo(valFont.pointSize + 1)
        }
        
    }
    
    private var textLabel : UILabel!
    private var valLabel  : UILabel!
    
}

func -(left : String, right : String) -> String
{
    return left.replacingOccurrences(of: right, with: "")
}
