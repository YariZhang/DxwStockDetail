//
//  TimeLineView.swift
//  TimeChart
//
//  Created by zhangyr on 15/5/12.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//
//  分时线视图

import UIKit
import BasicService

protocol TimeLineViewDelegate : NSObjectProtocol {
    func timeLineViewMoreInfo(with data : PointInfo)
}

class TimeLineView: UIView ,StockDetailSegmentedDelegate , SoldViewDelegate{
    
    let lineColor : UIColor = Color("#ddd")
    let lineWidth : CGFloat = 0.5
    fileprivate var pLength : [CGFloat] = [2,2]
    weak var delegate : TimeLineViewDelegate?
    var datas : NSArray!
    var volDatas : NSArray!
    var agvDatas : NSArray!
    var sb_five : NSArray!
    var stock_code : String!
    fileprivate var bv : VolLineView!
    fileprivate var maxPrice : UILabel!
    fileprivate var minPrice : UILabel!
    fileprivate var maxRate : UILabel!
    fileprivate var minRate : UILabel!
    fileprivate var openPrice : UILabel!
    fileprivate var pointsArr : NSMutableArray!
    fileprivate var agvPointArr : NSMutableArray!
    fileprivate var timeShowView : UIView!
    fileprivate var currentTimeLabel : UILabel!
    fileprivate var currentPriceLabel : UILabel!
    fileprivate var currentRateLabel : UILabel!
    fileprivate var currentVolLabel : UILabel!
    fileprivate var currentAgvLabel : UILabel!
    fileprivate var moveLabel : UILabel!
    fileprivate var avg_pr : UILabel!
    var open : Float = 0.0
    var toOpen : Float = 0.0
    fileprivate var max : Float = 0.0
    var isDraw : Bool! = true
    //--------------------------------------
    fileprivate var isFiveDay : Bool
    var dateArr : NSArray!
    //--------------------------------------
    fileprivate var isLineMove : Bool = false
    fileprivate var canMove : Bool
    fileprivate var isMarket : Bool
    fileprivate var longPressGR : UILongPressGestureRecognizer!
    fileprivate var sellInfoView : SoldView!
    fileprivate var seg : StockDetailSegmentedControl!
    fileprivate var infoView : UIView!
    fileprivate var infoType : Int! = 1
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !canMove && !self.frame.contains(point) {
            return nil
        }else{
            for subview in self.subviews {
                let rect = (subview ).frame
                if rect.contains(point) {
                    //println(subview)
                    return subview
                }
            }
        }
        return self
    }
    
    override func draw(_ rect: CGRect) {
        
        var context = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        //println("执行drawRect")
        if !isDraw {
            if !canMove && longPressGR != nil {
                self.removeGestureRecognizer(longPressGR)
                longPressGR = nil
            }else if canMove && longPressGR == nil {
                addGR()
            }
            /*if canMove && !isFiveDay && infoType == 1 && !isMarket {
                self.sellInfoView.datas = self.sb_five
                self.sellInfoView.open = self.open
                self.sellInfoView.reloadData()
            }*/
            pointsArr.removeAllObjects()
            agvPointArr.removeAllObjects()
            changeDataToPoint()
            var lw : CGFloat = self.bounds.width / 242 + 0.5
            if isFiveDay {
                lw = self.bounds.width / 61 / 5 + 0.5
                
                for i in 0 ..< dateArr.count{
                    let day_label = timeShowView.viewWithTag(i + 100) as! UILabel
                    day_label.text = UtilDate.convertFormatByDate("yyyyMMdd", date_time: dateArr[i] as! String, toFormat: "MM-dd")
                }
            }
            //println(pointsArr.count)
            for item in pointsArr {
                let info = item as! PointInfo
                context?.saveGState()
                context?.beginPath()
                context?.setLineWidth(lw)
                context?.setStrokeColor(UIColor.clear.cgColor)
                context?.move(to: CGPoint(x: info.endPoint.x, y: self.bounds.height))
                context?.addLine(to: CGPoint(x: info.endPoint.x, y: info.endPoint.y))
                context?.strokePath()
                context?.restoreGState()
                context?.saveGState()
                context = UIGraphicsGetCurrentContext()
                
                context?.saveGState()
                context?.beginPath()
                context?.setLineWidth(1)
                context?.setStrokeColor(Color("#07d0f2").cgColor)
                context?.move(to: CGPoint(x: info.startPoint.x, y: info.startPoint.y))
                context?.addLine(to: CGPoint(x: info.endPoint.x, y: info.endPoint.y))
                context?.strokePath()
                context?.restoreGState()
                context?.saveGState()
                context = UIGraphicsGetCurrentContext()
            }
            self.maxPrice.text = String(format: "%.2f",max)
            self.minPrice.text = String(format: "%.2f",open - (max - open))
            self.maxRate.text = String(format: "%.2f%%",(max - open) / open * 100)
            self.minRate.text = String(format: "%.2f%%",(open - max) / open * 100)
            self.openPrice.text = String(format: "%.2f",open)
            
            context?.saveGState()
            context?.beginPath()
            context?.setLineWidth(1)
            context?.setStrokeColor(Color("#fec12d").cgColor)
            for item in agvPointArr {
                let info = item as! PointInfo
                context?.move(to: CGPoint(x: info.startPoint.x, y: info.startPoint.y))
                context?.addLine(to: CGPoint(x: info.endPoint.x, y: info.endPoint.y))
            }
            context?.strokePath()
            context?.restoreGState()
            context?.saveGState()
            context = UIGraphicsGetCurrentContext()
            
            bv.datas = self.volDatas
            bv.isDraw = self.isDraw
            bv.isLineMove = self.isLineMove
            bv.setNeedsDisplay()
            if !isLineMove {
                showInfo(self.pointsArr.count - 1)
            }
        }
        
        var startPoint : CGPoint!
        var endPoint : CGPoint!
        
        if isFiveDay {
            
            let w = self.bounds.width / 5
            context?.saveGState()
            context?.beginPath()
            context?.setLineWidth(lineWidth)
            context?.setStrokeColor(lineColor.cgColor)
            for i in 1 ... 4 {
                startPoint = CGPoint(x: CGFloat(i) * w, y: 0)
                endPoint = CGPoint(x: CGFloat(i) * w, y: self.bounds.height)
                context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
                context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
            }
            context?.strokePath()
            context?.restoreGState()
            context?.saveGState()
            
            context = UIGraphicsGetCurrentContext()
        }else{
            startPoint = CGPoint(x: self.bounds.width / 2, y: 0)
            endPoint = CGPoint(x: startPoint.x, y: self.bounds.height)
            
            context = UIGraphicsGetCurrentContext()
            context?.saveGState()
            context?.beginPath()
            context?.setLineWidth(lineWidth)
            context?.setLineWidth(0.5)
            context?.setStrokeColor(UtilColor.getTextBlackColor().cgColor)
            context?.setLineDash(phase: 0 , lengths : pLength)
            context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
            context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
            context?.strokePath()
            context?.restoreGState()
            context?.saveGState()
            
            startPoint = CGPoint(x: self.bounds.width / 4, y: 0)
            endPoint = CGPoint(x: startPoint.x, y: self.bounds.height)
            
            context = UIGraphicsGetCurrentContext()
            context?.saveGState()
            context?.beginPath()
            context?.setLineWidth(lineWidth)
            context?.setStrokeColor(lineColor.cgColor)
            context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
            context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
            startPoint = CGPoint(x: self.bounds.width / 4 * 3, y: 0)
            endPoint = CGPoint(x: startPoint.x, y: self.bounds.height)
            
            context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
            context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
            
            context?.strokePath()
            context?.restoreGState()
            context?.saveGState()
        }
        startPoint = CGPoint(x: 0, y: self.bounds.height / 2)
        endPoint = CGPoint(x: self.bounds.width, y: startPoint.y)
        context?.saveGState()
        context?.beginPath()
        context?.setLineWidth(0.5)
        context?.setStrokeColor(UtilColor.getTextBlackColor().cgColor)
        context?.setLineDash(phase: 0 , lengths : pLength)
        context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        context?.strokePath()
        context?.restoreGState()
        context?.saveGState()
        
        startPoint = CGPoint(x: 0, y: self.bounds.height / 4)
        endPoint = CGPoint(x: self.bounds.width, y: startPoint.y)
        
        context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.beginPath()
        context?.setLineWidth(lineWidth)
        context?.setStrokeColor(lineColor.cgColor)
        context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        
        startPoint = CGPoint(x: 0, y: self.bounds.height / 4 * 3)
        endPoint = CGPoint(x: self.bounds.width, y: startPoint.y)
        context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        context?.strokePath()
        context?.restoreGState()
        context?.saveGState()
        if self.sellInfoView != nil {
            //println("刷新横屏")
            reloadSoldData()
        }
    }
    
    func reloadSoldData() {
        self.sellInfoView.dataType = self.infoType
        switch self.infoType {
        case 1 :
            self.sellInfoView.datas = self.sb_five
            self.sellInfoView.open  = self.open
            self.sellInfoView.reloadData()
        case 2:
            StockService.getStockTimeDetailWithCode(stock_code, completion: { (bsd) -> Void in
                
                if bsd!.resultCode == 10000 {
                    if let arr = bsd!.resultData as? NSArray {
                        self.sellInfoView.datas = arr
                        self.sellInfoView.reloadData()
                    }
                }else{
                    UtilTools.noticError(view: self.sellInfoView, msg: bsd!.errorMsg + "", offset: self.sellInfoView.contentOffset.y)
                }
                
                }, failure: { (error) -> Void in
                    UtilTools.noticError(view: self.sellInfoView, msg: error!.msg!, offset: self.sellInfoView.contentOffset.y)
            })
        default :
            logPrint("")
        }
    }
    
    func showInfo(_ index : Int) {
        if self.pointsArr.count > 0 {
            let inf = self.pointsArr[index] as! PointInfo
            let agvinf = self.agvPointArr[index] as! PointInfo
            self.currentTimeLabel.text = inf.min
            self.currentTimeLabel.font = UIFont.normalFontOfSize(14)
            changeColorForVal(self.currentPriceLabel, val: inf.currentPrice, cpVal: open)
            changeColorForVal(self.currentRateLabel, val: (inf.currentPrice - open) / open, cpVal: 0)
            if agvinf.currentPrice > 0 {
                self.currentAgvLabel.isHidden = false
                self.avg_pr.isHidden = false
            }else{
                self.currentAgvLabel.isHidden = true
                self.avg_pr.isHidden = true
            }
            delegate?.timeLineViewMoreInfo(with: inf)
            changeColorForVal(self.currentAgvLabel, val: agvinf.currentPrice, cpVal: open)
        }else{
            self.currentTimeLabel.text = "--:--"
            self.currentTimeLabel.font = UIFont.normalFontOfSize(14)
            changeColorForVal(self.currentPriceLabel, val: 0, cpVal: 0)
            changeColorForVal(self.currentRateLabel, val: 0, cpVal: 0)
            changeColorForVal(self.currentAgvLabel, val: 0, cpVal: 0)
            self.currentAgvLabel.isHidden = true
            self.avg_pr.isHidden = true
        }
    }
    
    func changeColorForVal(_ label : UILabel , val : Float , cpVal : Float) {
        if val > cpVal {
            label.textColor = UtilColor.getRedTextColor()
        }else if val == cpVal {
            label.textColor = UtilColor.getTextBlackColor()
        }else{
            label.textColor = UtilColor.getGreenColor()
        }
        if cpVal == 0 {
            label.text = String(format: "%.2f%%", val * 100)
        }else{
            label.text = String(format: "%.2f", val)
        }
        //label.font = UtilTools.changeFontSize(label, text: label.text!)
    }
    
    func getTime(_ min : Int) -> String {
        if min <= 120 {
            let hour = 9 + (min + 30) / 60
            var mini = 30 + (min % 60)
            if mini >= 60 {
                mini = mini % 60
            }
            return String(format: "%02d:%02d", hour,mini)
        }else{
            let hour = 13 + (min - 120) / 60
            let mini = 0 + ((min - 120) % 60)
            return String(format: "%02d:%02d", hour,mini)
        }
    }
    
    func getValue(_ val : Float) -> String {
        return String(format: "%.2f", val)
    }
    
    func changeVolValue(_ volinf : PointInfo , index : Int) {
        if volinf.dealVol >= 0 {
            self.currentVolLabel.textColor = UtilColor.getRedTextColor()
        }else if volinf.dealVol == 0 {
            self.currentVolLabel.textColor = UtilColor.getTextBlackColor()
        }else{
            self.currentVolLabel.textColor = UtilColor.getGreenColor()
        }
        self.currentVolLabel.text = "\(UtilTools.formatTotalAmount(CGFloat(abs(volinf.dealVol / 100))))手"
        if delegate != nil && index < self.pointsArr.count {
            let inf         = self.pointsArr[index] as! PointInfo
            inf.p_change    = (inf.currentPrice - open) / open * 100
            inf.dealVol     = volinf.dealVol
            inf.volColor    = self.currentVolLabel.textColor
            inf.volStr      = self.currentVolLabel.text
            delegate?.timeLineViewMoreInfo(with: inf)
        }
    }
    
    init(frame: CGRect , move : Bool ,isFive : Bool = false , isMarket : Bool = false , isPortrait : Bool = false) {
        self.isFiveDay = isFive
        self.canMove = move
        self.isMarket = isMarket
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        infoView = UIView()
        if !isPortrait && !isFiveDay && !isMarket {
            self.frame.size.width -= frame.size.width / 4 + 10
            self.sellInfoView = SoldView(frame: CGRect(x: self.frame.size.width + 10, y: 0, width: frame.size.width / 4, height: frame.size.height / 2 * 3 - 10) ,tapDelegate : self)
            self.sellInfoView.isLand = true
            self.clipsToBounds = false
            self.addSubview(self.sellInfoView)
            seg = StockDetailSegmentedControl(frame: CGRect(x: self.sellInfoView.frame.minX, y: self.sellInfoView.frame.maxY + 5, width: self.sellInfoView.frame.width, height: 25), items: ["五档" as AnyObject,"明细" as AnyObject], delegate: self)
            self.addSubview(seg)
            self.infoView.isHidden = false
        }else if (isFiveDay || isMarket) && !isPortrait {
            self.infoView.isHidden = false
        }else{
            self.infoView.isHidden = true
        }
        self.layer.borderColor = Color("#ddd").cgColor
        self.layer.borderWidth = lineWidth
        bv = VolLineView(frame: CGRect(x: 0, y: self.frame.height + 20, width: self.frame.width, height: self.frame.height / 2) , isFive : isFive)
        bv.delegate = self
        self.addSubview(bv)
        
        maxPrice = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
        maxPrice.font = UIFont.normalFontOfSize(10)
        maxPrice.textColor = UtilColor.getRedTextColor()
        self.addSubview(maxPrice)
        minPrice = UILabel(frame: CGRect(x: 0, y: self.frame.size.height - 20, width: maxPrice.bounds.width, height: maxPrice.bounds.height))
        minPrice.font = UIFont.normalFontOfSize(10)
        minPrice.textColor = UtilColor.getGreenColor()
        self.addSubview(minPrice)
        
        maxRate = UILabel(frame: CGRect(x: self.frame.size.width - maxPrice.bounds.width, y: 0, width: maxPrice.bounds.width, height: maxPrice.bounds.height))
        maxRate.font = UIFont.normalFontOfSize(10)
        maxRate.textColor = UtilColor.getRedTextColor()
        maxRate.textAlignment = NSTextAlignment.right
        self.addSubview(maxRate)
        minRate = UILabel(frame: CGRect(x: maxRate.frame.minX, y: minPrice.frame.minY, width: maxPrice.bounds.width, height: maxPrice.bounds.height))
        minRate.font = UIFont.normalFontOfSize(10)
        minRate.textColor = UtilColor.getGreenColor()
        minRate.textAlignment = NSTextAlignment.right
        self.addSubview(minRate)
        openPrice = UILabel(frame: CGRect(x: 0, y: (self.frame.size.height - 20) / 2, width: maxPrice.bounds.width, height: maxPrice.bounds.height))
        openPrice.font = UIFont.normalFontOfSize(10)
        openPrice.textColor = UtilColor.getTextBlackColor()
        openPrice.textAlignment = NSTextAlignment.left
        self.addSubview(openPrice)
        
        timeShowView = UIView(frame: CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 20))
        timeShowView.backgroundColor = UIColor.clear
        self.addSubview(timeShowView)
        if !isFive {
            let mot = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
            mot.textColor = UtilColor.getHintLabelColor()
            mot.font = UIFont.normalFontOfSize(12)
            mot.text = "9:30"
            timeShowView.addSubview(mot)
            let mit = UILabel(frame: CGRect(x: (self.frame.size.width - 120) / 2, y: 0, width: 120, height: 20))
            mit.textColor = UtilColor.getHintLabelColor()
            mit.font = UIFont.normalFontOfSize(12)
            mit.textAlignment = NSTextAlignment.center
            mit.text = "11:30/13:00"
            timeShowView.addSubview(mit)
            let lat = UILabel(frame: CGRect(x: self.frame.size.width - 80, y: 0, width: 80, height: 20))
            lat.textColor = UtilColor.getHintLabelColor()
            lat.font = UIFont.normalFontOfSize(12)
            lat.textAlignment = NSTextAlignment.right
            lat.text = "15:00"
            timeShowView.addSubview(lat)
        }else{
            let dateW = timeShowView.bounds.size.width / 5
            for i in 0 ..< 5 {
                let label = UILabel(frame: CGRect(x: CGFloat(i) * dateW, y: 0, width: dateW, height: timeShowView.bounds.height))
                label.textColor = UtilColor.getHintLabelColor()
                label.tag = i + 100
                label.font = UIFont.normalFontOfSize(12)
                label.textAlignment = NSTextAlignment.center
                timeShowView.addSubview(label)
            }
        }
        
        
        
        self.infoView.frame = CGRect(x: 0, y: -20, width: self.frame.size.width, height: 20)
        self.addSubview(self.infoView)
        let labW = (infoView.bounds.width - 120) / 5
        self.currentTimeLabel = TextLabel(frame: CGRect(x: 0, y: 0, width: labW, height: 20), alignment: NSTextAlignment.left, toView: infoView)
        self.currentTimeLabel.text = "--:--"
        let o = HintLabel(frame: CGRect(x: self.currentTimeLabel.frame.maxX, y: 0, width: 30, height: 20), alignment: NSTextAlignment.left, title: "价格", toView: infoView)
        self.currentPriceLabel = TextLabel(frame: CGRect(x: o.frame.maxX, y: 0, width: labW, height: 20), alignment: NSTextAlignment.center, toView: infoView)
        self.currentPriceLabel.text = "--"
        let l = HintLabel(frame: CGRect(x: self.currentPriceLabel.frame.maxX, y: 0, width: 30, height: 20), alignment: NSTextAlignment.left, title: "涨跌", toView: infoView)
        self.currentRateLabel = TextLabel(frame: CGRect(x: l.frame.maxX, y: 0, width: labW, height: 20), alignment: NSTextAlignment.center, toView: infoView)
        self.currentRateLabel.text = "--"
        let c = HintLabel(frame: CGRect(x: self.currentRateLabel.frame.maxX, y: 0, width: 30, height: 20), alignment: NSTextAlignment.left, title: "成交", toView: infoView)
        self.currentVolLabel = TextLabel(frame: CGRect(x: c.frame.maxX, y: 0, width: labW, height: 20), alignment: NSTextAlignment.center, toView: infoView)
        self.currentVolLabel.text = "--"
        avg_pr = HintLabel(frame: CGRect(x: self.currentVolLabel.frame.maxX, y: 0, width: 30, height: 20), alignment: NSTextAlignment.left, title: "均价", toView: infoView)
        self.currentAgvLabel = TextLabel(frame: CGRect(x: avg_pr.frame.maxX, y: 0, width: labW, height: 20), alignment: NSTextAlignment.center, toView: infoView)
        self.currentAgvLabel.text = "--"
        
        pointsArr = NSMutableArray()
        agvPointArr = NSMutableArray()
        addGR()
    }
    
    func addGR() {
        longPressGR = UILongPressGestureRecognizer()
        longPressGR.addTarget(self, action: #selector(TimeLineView.moveToViewDetail(_:)))
        self.addGestureRecognizer(longPressGR)
    }
    
    @objc func moveToViewDetail(_ gr : UILongPressGestureRecognizer) {
        if self.pointsArr.count == 0 {
            return
        }
        let loc = gr.location(in: self)
        var space = self.bounds.width / 242
        if isFiveDay {
            space = self.bounds.width / 61 / 5
        }
        var moveX = loc.x
        if moveX > CGFloat(self.pointsArr.count) * space {
            moveX = CGFloat(self.pointsArr.count) * space
        }else if moveX <= 0 {
            moveX = 1
        }
        var index : Int = Int(String(format: "%.0f",moveX / space))!
        moveX = CGFloat(index) * space
        //println(index)
        if index >= self.pointsArr.count {
            index = self.pointsArr.count - 1
        }
        switch gr.state {
        case .began:
            NotificationCenter.default.post(name: Notification.Name(rawValue: "moveLine"), object: nil, userInfo: ["isMove" : true])
            self.moveLabel = UILabel(frame: CGRect(x: moveX - 0.5, y: 0, width: 0.5, height: self.bounds.height * 3 / 2 + 20))
            self.moveLabel.backgroundColor = Color("#90a4ae")
            self.isLineMove = true
            self.addSubview(moveLabel)
            self.bringSubviewToFront(self.timeShowView)
            showInfo(index)
            self.bv.turnBackPonit(index)
        case .changed:
            if moveLabel != nil {
                self.moveLabel.frame = CGRect(x: moveX - 0.5, y: 0, width: 0.5, height: self.bounds.height * 3 / 2 + 20)
            }
            self.bringSubviewToFront(self.timeShowView)
            showInfo(index)
            self.bv.turnBackPonit(index)
        default:
            if self.moveLabel != nil {
                self.moveLabel.removeFromSuperview()
                self.moveLabel = nil
                self.isLineMove = false
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "moveLine"), object: nil, userInfo: ["isMove" : false])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //println("执行")
    }
    
    
    func changeDataToPoint() {
        
        var space = self.bounds.width / 242
        if isFiveDay {
            space = self.bounds.width / 61 / 5
        }
        let startLine = self.bounds.height / 2
        let max = getMaxAbsPrice(self.datas)
        var startPoint = CGPoint.zero
        var agv_startPoint = CGPoint.zero
        
        for i in 0 ..< self.datas.count {
            let price = ((datas[i] as! NSArray).firstObject as! NSString).floatValue
            let agvPrice = (agvDatas[i] as! NSString).floatValue
            let min = (datas[i] as! NSArray).lastObject + ""
            let info = PointInfo()
            info.openPrice = open
            info.min = min
            info.currentPrice = price
            if i % 61 == 0 && isFiveDay {
                startPoint = CGPoint(x: CGFloat(i) * space + 1 ,y: startLine - CGFloat((price - open) / max) * (startLine - 1))
                agv_startPoint = CGPoint(x: CGFloat(i) * space + 1 ,y: startLine - CGFloat((agvPrice - open) / max) * (startLine - 1))
            }else if i == 0 {
                startPoint = CGPoint(x: 1 ,y: startLine - CGFloat((price - open) / max) * (startLine - 1))
                agv_startPoint = CGPoint(x: CGFloat(i) * space + 1 ,y: startLine - CGFloat((agvPrice - open) / max) * (startLine - 1))
            }
            info.startPoint = startPoint
            info.endPoint = CGPoint(x: CGFloat(i) * space + 1 ,y: startLine - CGFloat((price - open) / max) * (startLine - 1))
            startPoint = info.endPoint
            pointsArr.add(info)
            
            let info_agv = PointInfo()
            info_agv.openPrice = open
            info_agv.currentPrice = agvPrice
            info_agv.startPoint = agv_startPoint
            info_agv.endPoint = CGPoint(x: CGFloat(i) * space + 1 ,y: startLine - CGFloat((agvPrice - open) / max) * (startLine - 1))
            agv_startPoint = info_agv.endPoint
            agvPointArr.add(info_agv)
        }
        
    }
    
    
    
    func getMaxAbsPrice(_ arr : NSArray) -> Float {
        var xmax : Float = 0
        for p in arr {
            let pri : Float = abs(((p as! NSArray).firstObject as! NSString).floatValue - open)
            if pri > xmax {
                xmax = pri
            }
        }
        self.max = xmax + open
        return xmax
    }
    
    func soldViewTapAction() {
        if infoType == 2 {
            infoType = infoType - 1
        }else{
            infoType = infoType + 1
        }
        seg.selectedSegmentIndex = infoType - 1
        reloadSoldData()
    }
    
    func stockSegmentedSelectedItem(_ seg: StockDetailSegmentedControl, selectedItemIndex: Int, selectedItemTitle: String?) {
        self.infoType = selectedItemIndex + 1
        reloadSoldData()
    }
}
