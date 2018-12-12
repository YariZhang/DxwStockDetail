//
//  VolLineView.swift
//  TimeChart
//
//  Created by zhangyr on 15/5/12.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class VolLineView: UIView {

    fileprivate let lineColor : UIColor = Color("#ddd")
    fileprivate let lineWidth : CGFloat = 0.5
    fileprivate var pLength : [CGFloat] = [2,2]
    fileprivate var pointsArr : NSMutableArray!
    fileprivate var max : Float! = 0
    fileprivate var maxVolLabel : UILabel!
    fileprivate var halfMaxLabel : UILabel!
    fileprivate var volUnit : UILabel!
    var isDraw : Bool! = true
    var datas : NSArray!
    var isLineMove : Bool = false
    fileprivate var isFiveDay : Bool
    weak var delegate : TimeLineView!
    
    
    override func draw(_ rect: CGRect) {
        
        UIGraphicsGetCurrentContext()?.clear(rect)
        
        if !isDraw {
            pointsArr.removeAllObjects()
            var width = self.bounds.width / 242
            if isFiveDay {
                width = self.bounds.width / 61 / 5
            }
            changeDataToPoint()
            for item in pointsArr {
                let info = item as! PointInfo
                let c : CGContext = UIGraphicsGetCurrentContext()!
                c.saveGState()
                c.beginPath()
                c.setLineWidth(width)
                if info.dealVol >= 0 {
                    c.setStrokeColor(UtilColor.getRedTextColor().cgColor)
                }else{
                    c.setStrokeColor(UtilColor.getGreenColor().cgColor)
                }
                c.move(to: CGPoint(x: info.startPoint.x, y: info.startPoint.y))
                c.addLine(to: CGPoint(x: info.endPoint.x, y: info.endPoint.y))
                c.strokePath()
                c.restoreGState()
                c.saveGState()
                self.maxVolLabel.text = String(format: "%.0f", self.max / 100)
                self.halfMaxLabel.text = String(format: "%.0f", self.max / 200)
            }
            
            if !isLineMove && self.pointsArr.count > 0 {
                let inf = self.pointsArr.lastObject as! PointInfo
                delegate.changeVolValue(inf , index : self.pointsArr.count - 1)
            }
        }
        
        var startPoint : CGPoint = CGPoint(x: 0, y: self.bounds.height / 2)
        var endPoint : CGPoint = CGPoint(x: self.bounds.width, y: startPoint.y)
        var context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.beginPath()
        context?.setLineWidth(0.5)
        context?.setStrokeColor(UtilColor.getTextBlackColor().cgColor)
        context?.setLineDash(phase: 0, lengths: pLength)
        context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        context?.strokePath()
        context?.restoreGState()
        context?.saveGState()
        
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
            context?.setLineDash(phase: 0, lengths: pLength)
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
        
    }
    
    
    init(frame: CGRect ,isFive : Bool) {
        self.isFiveDay = isFive
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = Color("#ddd").cgColor
        self.layer.borderWidth = lineWidth
        pointsArr = NSMutableArray()
        
        self.maxVolLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
        self.maxVolLabel.textColor = UtilColor.getTextBlackColor()
        self.maxVolLabel.font = UIFont.normalFontOfSize(10)
        self.maxVolLabel.text = String(format: "%.0f", self.max)
        self.addSubview(self.maxVolLabel)
        
        self.halfMaxLabel = UILabel(frame: CGRect(x: 0, y: (self.bounds.height - 20) / 2, width: 60, height: 20))
        self.halfMaxLabel.textColor = UtilColor.getTextBlackColor()
        self.halfMaxLabel.font = UIFont.normalFontOfSize(10)
        self.halfMaxLabel.text = String(format: "%.0f", self.max / 2)
        self.addSubview(self.halfMaxLabel)
        
        self.volUnit = UILabel(frame: CGRect(x: 0, y: self.bounds.height - 20, width: 60, height: 20))
        self.volUnit.textColor = UtilColor.getTextBlackColor()
        self.volUnit.font = UIFont.normalFontOfSize(10)
        self.volUnit.text = "手"
        self.addSubview(self.volUnit)
        
    }
    
    func changeDataToPoint() {
        
        var space = self.bounds.width / 242
        if isFiveDay {
            space = self.bounds.width / 61 / 5
        }
        _ = getMaxTotalVol(self.datas)
        
        for i in 0 ..< self.datas.count {
            let val = (self.datas[i] as! NSString).floatValue
            let info = PointInfo()
            info.dealVol = val
            info.startPoint = CGPoint(x: CGFloat(i) * space + 1, y: self.bounds.height)
            if self.max == 0 {
                info.endPoint = CGPoint(x: CGFloat(i) * space + 1, y: self.bounds.height)
            }else{
                info.endPoint = CGPoint(x: CGFloat(i) * space + 1, y: self.bounds.height - CGFloat(abs(val) / self.max) * self.bounds.height)
            }
            pointsArr.add(info)
        }
        
    }
    
    func getMaxTotalVol(_ arr : NSArray) -> Float {
        var xmax : Float = 0
        for p in arr {
            let val = (p as! NSString).floatValue
            if abs(val) > xmax {
                xmax = abs(val)
            }
        }
        self.max = xmax
        return xmax
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func turnBackPonit(_ index : Int) {
        let inf = self.pointsArr[index] as! PointInfo
        delegate.changeVolValue(inf , index : index)
    }
    
}
