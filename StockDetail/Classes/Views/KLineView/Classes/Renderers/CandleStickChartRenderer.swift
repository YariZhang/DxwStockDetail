//
//  CandleStickChartRenderer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics
import UIKit

@objc
public protocol CandleStickChartRendererDelegate
{
    func candleStickChartRendererCandleData(_ renderer: CandleStickChartRenderer) -> CandleChartData!
    func candleStickChartRenderer(_ renderer: CandleStickChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    func candleStickChartDefaultRendererValueFormatter(_ renderer: CandleStickChartRenderer) -> NumberFormatter!
    func candleStickChartRendererChartYMax(_ renderer: CandleStickChartRenderer) -> Double
    func candleStickChartRendererChartYMin(_ renderer: CandleStickChartRenderer) -> Double
    func candleStickChartRendererChartXMax(_ renderer: CandleStickChartRenderer) -> Double
    func candleStickChartRendererChartXMin(_ renderer: CandleStickChartRenderer) -> Double
    func candleStickChartRendererMaxVisibleValueCount(_ renderer: CandleStickChartRenderer) -> Int
}

open class CandleStickChartRenderer: LineScatterCandleRadarChartRenderer
{
    open weak var delegate: CandleStickChartRendererDelegate?
    
    public init(delegate: CandleStickChartRendererDelegate?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.delegate = delegate
    }
    
    open override func drawData(context: CGContext)
    {
        guard let candleData = delegate!.candleStickChartRendererCandleData(self) else {
            return
        }
        
        for i in 0 ..< candleData.dataSets.count
        {
            let set = (candleData.dataSets as! [CandleChartDataSet])[i]
            if set.isVisible && set.entryCount > 0
            {
                drawDataSet(context: context, dataSet: set , dataSetIndex : i)
            }
        }
    }
    
    fileprivate var _shadowPoints = [CGPoint](repeating: CGPoint(), count: 2)
    fileprivate var _bodyRect = CGRect()
    fileprivate var _bodyRectVolume = CGRect()
    fileprivate var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    fileprivate var _fiveAvg = [CGPoint]()
    fileprivate var _tenAvg = [CGPoint]()
    fileprivate var _twentyAvg = [CGPoint]()
    
    internal func drawDataSet(context: CGContext, dataSet: CandleChartDataSet , dataSetIndex : Int)
    {
        let chartView = self.delegate as! CandleStickChartView
        let trans = delegate!.candleStickChartRenderer(self, transformerForAxis: dataSet.axisDependency)
        
        let phaseX = _animator.phaseX
        let phaseY = _animator.phaseY
        let bodySpace = dataSet.bodySpace
        
        var entries = dataSet.yVals as! [CandleChartDataEntry]
        let entryFrom = dataSet.entryForXIndex(_minX)
        let entryTo = dataSet.entryForXIndex(_maxX)
        
        let minx = max(dataSet.entryIndex(entry: entryFrom!, isEqual: true), 0)
        let maxx = min(dataSet.entryIndex(entry: entryTo!, isEqual: true) + 1, entries.count)
        
        
        context.saveGState()
        
        context.setLineWidth(dataSet.shadowWidth)
        
        var maxMainVol  : Double        = 0
        var minMainVol  : Double        = 0
        var maxMainPerc : String        = "0.00%"
        var maxVol : Double = 0 //最大成交量
        var j = minx
        var count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
        while j < count {
            let e = entries[j]
            let kline = e.data as! KLineData
            if kline.volume.doubleValue > maxVol {
                maxVol = kline.volume.doubleValue //计算最大成交量
            }
            if kline.main_amount.doubleValue > maxMainVol
            {
                maxMainVol      = kline.main_amount.doubleValue
                maxMainPerc     = kline.main_percent
            }
            if kline.main_amount.doubleValue < minMainVol
            {
                minMainVol  = kline.main_amount.doubleValue
            }
            
            j += 1
        }
        
        maxVolume           = maxVol
        maxMainVolume       = maxMainVol
        minMainVolume       = minMainVol
        maxMainPercent      = maxMainPerc
        
        //chartView.volumeLabel.frame = CGRectMake(viewPortHandler.contentLeftVolume + 3, viewPortHandler.contentTopVolume, viewPortHandler.contentWidthVolume, 12)
        /*if chartView.currentVol != nil {
            if maxVolume >= 100_000_000 {
                chartView.currentVol.text = String(format: "%.2f亿手", maxVolume / 100_000_000)
            }else if maxVolume >= 10_000_000 {
                chartView.currentVol.text = String(format: "%.2f千万手", maxVolume / 10_000_000)
            }else if maxVolume >= 10000 {
                chartView.currentVol.text = String(format: "%.2f万手", maxVolume / 10000)
            }else{
                chartView.currentVol.text = String(format: "%.0f手", maxVolume)
            }
        }*/
        //检查点
        j = minx
        count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
        while j < count {
            // get the entry
            let e = entries[j]
            let kline = e.data as! KLineData
            
            if (e.xIndex < _minX || e.xIndex > _maxX)
            {
                j += 1
                continue
            }
            
            // calculate the shadow
            
            _shadowPoints[0].x = CGFloat(e.xIndex)
            _shadowPoints[0].y = CGFloat(e.high) * phaseY
            _shadowPoints[1].x = CGFloat(e.xIndex)
            _shadowPoints[1].y = CGFloat(e.low) * phaseY
            
            trans?.pointValuesToPixel(&_shadowPoints)
            
            // calculate the avgerage
            
            var avgPoint = CGPoint(x: CGFloat(e.xIndex), y: CGFloat(kline.ma5) * phaseY)
    
            trans?.pointValueToPixel(&avgPoint)
            if avgPoint.y > viewPortHandler.contentTopVolume {
                avgPoint.y = viewPortHandler.contentTopVolume
            }else if kline.ma5.doubleValue <= 0.1 {
                avgPoint.y = viewPortHandler.contentBottom
            }
            _fiveAvg.append(avgPoint) //计算5日均线点位
            
            avgPoint = CGPoint(x: CGFloat(e.xIndex), y: CGFloat(kline.ma10) * phaseY)
            
            trans?.pointValueToPixel(&avgPoint)
            if avgPoint.y > viewPortHandler.contentTopVolume {
                avgPoint.y = viewPortHandler.contentTopVolume
            }else if kline.ma10.doubleValue <= 0.1 {
                avgPoint.y = viewPortHandler.contentBottom
            }
            _tenAvg.append(avgPoint) //计算10日均线点位
            
            avgPoint = CGPoint(x: CGFloat(e.xIndex), y: CGFloat(kline.ma20) * phaseY)
            
            trans?.pointValueToPixel(&avgPoint)
            if avgPoint.y > viewPortHandler.contentTopVolume {
                avgPoint.y = viewPortHandler.contentTopVolume
            }else if kline.ma20.doubleValue <= 0.1 {
                avgPoint.y = viewPortHandler.contentBottom
            }
            _twentyAvg.append(avgPoint) //计算20日均线点位
            
            // draw the shadow
            
            var shadowColor: UIColor! = nil
            if (dataSet.shadowColorSameAsCandle)
            {
                if (e.open > e.close)
                {
                    shadowColor = dataSet.decreasingColor ?? dataSet.colorAt(j)
                }
                else if (e.open < e.close)
                {
                    shadowColor = dataSet.increasingColor ?? dataSet.colorAt(j)
                }
                else
                {
                    shadowColor = kline.p_change.doubleValue >= 0 ? dataSet.increasingColor : dataSet.decreasingColor
                }
            }
            
            if (shadowColor === nil)
                
            {
                shadowColor = dataSet.shadowColor ?? dataSet.colorAt(j);
            }
            
            context.setStrokeColor(shadowColor.cgColor)
            context.strokeLineSegments(between: _shadowPoints)
            
            // calculate the body
            
            _bodyRect.origin.x = CGFloat(e.xIndex) - 0.5 + bodySpace
            _bodyRect.origin.y = CGFloat(e.close) * phaseY
            _bodyRect.size.width = (CGFloat(e.xIndex) + 0.5 - bodySpace) - _bodyRect.origin.x
            _bodyRect.size.height = (CGFloat(e.open) * phaseY) - _bodyRect.origin.y
            
            trans?.rectValueToPixel(&_bodyRect)
            
            if _bodyRect.size.height == 0 && !(e.data as! KLineData).isFilled.boolValue {
                _bodyRect.size.height = 1
            }
            
            if stockVolumeType == .mainMoney
            {
                let deno                    = self.getDenominator(max: maxMainVolume, min: minMainVolume)
                let maxHeight               = CGFloat(abs(maxMainVolume) / deno) * viewPortHandler.contentHeightVolume
                let zeroY                   = viewPortHandler.contentTopVolume + (CGFloat(maxMainVolume) > 0 ? maxHeight : 0)
                let moneyHeight             = deno == 0 ? 0.1 : (CGFloat(abs(kline.main_amount.doubleValue) / deno) * viewPortHandler.contentHeightVolume)
                
                _bodyRectVolume.origin.x    = _bodyRect.origin.x
                
                if CGFloat(kline.main_amount.doubleValue) > 0
                {
                    _bodyRectVolume.origin.y    = zeroY - moneyHeight
                }else
                {
                    _bodyRectVolume.origin.y    = zeroY
                }
                _bodyRectVolume.size.width  = _bodyRect.size.width
                _bodyRectVolume.size.height = moneyHeight
                
            }else
            {
                //成交量柱体尺寸
                let height = CGFloat(kline.volume.doubleValue / maxVolume) * viewPortHandler.contentHeightVolume
                let heightSpace = viewPortHandler.contentHeightVolume - height
                
                _bodyRectVolume.origin.x = _bodyRect.origin.x
                _bodyRectVolume.origin.y = viewPortHandler.contentTopVolume + heightSpace
                _bodyRectVolume.size.width = _bodyRect.size.width
                _bodyRectVolume.size.height = height
                //--------------
            }
            
            
            
            
            // draw body differently for increasing and decreasing entry
            
            if (e.open > e.close)
            {
                let color = dataSet.decreasingColor ?? dataSet.colorAt(j)
                
                if (dataSet.isDecreasingFilled)
                {
                    context.setFillColor(color.cgColor)
                    context.fill(_bodyRect)
                    context.fillPath()
                    if stockVolumeType == .mainMoney
                    {
                        context.setFillColor(self.getMainMoneyColor(mainAmount: kline.main_amount.doubleValue))
                    }
                    context.fill(_bodyRectVolume)
                    context.fillPath()
                }
                else
                {
                    context.setStrokeColor(color.cgColor)
                    context.stroke(_bodyRect)
                    context.strokePath()
                    if stockVolumeType == .mainMoney
                    {
                        context.setStrokeColor(self.getMainMoneyColor(mainAmount: kline.main_amount.doubleValue))
                    }
                    context.stroke(_bodyRectVolume)
                    context.strokePath()
                }
            }
            else if (e.open < e.close)
            {
                
                let color = dataSet.increasingColor ?? dataSet.colorAt(j)
                
                if (dataSet.isIncreasingFilled)
                {
                    context.setFillColor(color.cgColor)
                    context.fill(_bodyRect)
                    context.fillPath()
                    if stockVolumeType == .mainMoney
                    {
                        context.setFillColor(self.getMainMoneyColor(mainAmount: kline.main_amount.doubleValue))
                    }
                    context.fill(_bodyRectVolume)
                    context.fillPath()
                }
                else
                {
                    context.setStrokeColor(color.cgColor)
                    context.stroke(_bodyRect)
                    context.strokePath()
                    if stockVolumeType == .mainMoney
                    {
                        context.setStrokeColor(self.getMainMoneyColor(mainAmount: kline.main_amount.doubleValue))
                    }
                    context.stroke(_bodyRectVolume)
                    context.strokePath()
                }
            }
            else
            {
                let color = kline.p_change.doubleValue >= 0 ? dataSet.increasingColor : dataSet.decreasingColor
                if (dataSet.isIncreasingFilled)
                {
                    context.setFillColor(color!.cgColor)
                    context.fill(_bodyRect)
                    context.fillPath()
                    if stockVolumeType == .mainMoney
                    {
                        context.setFillColor(self.getMainMoneyColor(mainAmount: kline.main_amount.doubleValue))
                    }
                    context.fill(_bodyRectVolume)
                    context.fillPath()
                }
                else
                {
                    context.setStrokeColor(color!.cgColor)
                    context.stroke(_bodyRect)
                    context.strokePath()
                    if stockVolumeType == .mainMoney
                    {
                        context.setStrokeColor(self.getMainMoneyColor(mainAmount: kline.main_amount.doubleValue))
                    }
                    context.stroke(_bodyRectVolume)
                    context.strokePath()
                }
            }
            if j == count - 1 {
                if chartView.panCallBack {
                    chartView.delegate?.chartValueSelected?(chartView, entry: e, dataSetIndex: dataSetIndex, highlight: ChartHighlight())
                }
            }
            j += 1
        }
        drawAverageLineForFive(context: context, dataSet: dataSet) //绘制5日均线
        drawAverageLineForTen(context: context, dataSet: dataSet) //绘制10日均线
        drawAverageLineForTwenty(context: context, dataSet: dataSet) //绘制20日均线
        context.restoreGState()
    }
    
    open override func drawValues(context: CGContext)
    {
        let candleData = delegate!.candleStickChartRendererCandleData(self)
        if (candleData === nil)
        {
            return
        }
        
        let defaultValueFormatter = delegate!.candleStickChartDefaultRendererValueFormatter(self)
        
        let dataSets = candleData?.dataSets
        
        for dataSet in dataSets!
        {
            
            if !dataSet.isDrawValuesEnabled || dataSet.entryCount == 0
            {
                continue
            }
            
            let valueFont = dataSet.valueFont
            let valueTextColor = dataSet.valueTextColor
            
            var formatter = dataSet.valueFormatter
            if (formatter === nil)
            {
                formatter = defaultValueFormatter
            }
            
            let trans = delegate!.candleStickChartRenderer(self, transformerForAxis: dataSet.axisDependency)
            
            var entries = dataSet.yVals as! [CandleChartDataEntry]
            
            let entryFrom = dataSet.entryForXIndex(_minX)
            let entryTo = dataSet.entryForXIndex(_maxX)
            
            let minx = max(dataSet.entryIndex(entry: entryFrom!, isEqual: true), 0)
            let maxx = min(dataSet.entryIndex(entry: entryTo!, isEqual: true) + 1, entries.count)
            
            var positions = trans!.generateTransformedValuesCandle(entries, phaseY: _animator.phaseY)
            
            let lineHeight = valueFont.lineHeight
            let yOffset: CGFloat = lineHeight + 5.0
            
            var j = minx
            let count = Int(ceil(CGFloat(maxx - minx) * _animator.phaseX + CGFloat(minx)))
            while j < count {
                let x = positions[j].x
                let y = positions[j].y
                
                if (!viewPortHandler.isInBoundsRight(x))
                {
                    break
                }
                
                if (!viewPortHandler.isInBoundsLeft(x) || !viewPortHandler.isInBoundsY(y))
                {
                    j += 1
                    continue
                }
                
                let val = entries[j].high
                
                if val == dataSet.yMax && !(entries[j].data as! KLineData).isFilled.boolValue {
                    var valStr = formatter!.string(from: NSNumber(value: val))!
                    var align  = NSTextAlignment.left
                    if x < (self.delegate as! CandleStickChartView).bounds.width / 2 {
                        valStr = "← " + valStr
                    }else{
                        valStr += " →"
                        align   = .right
                    }
                    
                    
                    ChartUtils.drawText(context: context, text: valStr, point: CGPoint(x: x, y: y - yOffset + 10), align: align, attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): valueFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): valueTextColor])
                }
                j += 1
            }
            
        }
    }
    
    // draw average lines
    
    internal func drawAverageLineForFive(context: CGContext , dataSet: CandleChartDataSet) {
        context.setLineWidth(dataSet.avgLineWidth)
        context.setStrokeColor(dataSet.averageFive.cgColor)
        var index = 0
        for i in 0 ..< _fiveAvg.count {
            let point = _fiveAvg[i]
            if point.y >= viewPortHandler.contentBottom {
                index = i + 1
                continue
            }
            if i == index {
                context.move(to: CGPoint(x: point.x, y: point.y))
            }else{
                let e = (self.delegate as! CandleStickChartView).getEntryByTouchPoint(point)
                if e != nil && !(e!.data as! KLineData).isFilled.boolValue {
                    context.addLine(to: CGPoint(x: point.x, y: point.y))
                }
            }
        }
        _fiveAvg.removeAll(keepingCapacity: false)
        context.strokePath()
    }
    
    internal func drawAverageLineForTen(context: CGContext , dataSet: CandleChartDataSet) {
        context.setLineWidth(dataSet.avgLineWidth)
        context.setStrokeColor(dataSet.averageTen.cgColor)
        var index = 0
        for i in 0 ..< _tenAvg.count {
            let point = _tenAvg[i]
            if point.y >= viewPortHandler.contentBottom {
                index = i + 1
                continue
            }
            if i == index {
                context.move(to: CGPoint(x: point.x, y: point.y))
            }else{
                let e = (self.delegate as! CandleStickChartView).getEntryByTouchPoint(point)
                if e != nil && !(e!.data as! KLineData).isFilled.boolValue {
                    context.addLine(to: CGPoint(x: point.x, y: point.y))
                }
            }
        }
        _tenAvg.removeAll(keepingCapacity: false)
        context.strokePath()
    }
    
    internal func drawAverageLineForTwenty(context: CGContext , dataSet: CandleChartDataSet) {
        context.setLineWidth(dataSet.avgLineWidth)
        context.setStrokeColor(dataSet.averageTwenty.cgColor)
        var index = 0
        for i in 0 ..< _twentyAvg.count {
            let point = _twentyAvg[i]
            if point.y >= viewPortHandler.contentBottom {
                index = i + 1
                continue
            }
            if i == index {
                context.move(to: CGPoint(x: point.x, y: point.y))
            }else{
                let e = (self.delegate as! CandleStickChartView).getEntryByTouchPoint(point)
                if e != nil && !(e!.data as! KLineData).isFilled.boolValue {
                    context.addLine(to: CGPoint(x: point.x, y: point.y))
                }
            }
        }
        _twentyAvg.removeAll(keepingCapacity: false)
        context.strokePath()
    }
    
    open override func drawExtras(context: CGContext)
    {
    }
    
    fileprivate var _highlightPtsBuffer = [CGPoint](repeating: CGPoint(), count: 6)
    open override func drawHighlighted(context: CGContext, indices: [ChartHighlight])
    {
        let candleData = delegate!.candleStickChartRendererCandleData(self)
        if (candleData === nil)
        {
            return
        }
        
        for i in 0 ..< indices.count
        {
            let xIndex = indices[i].xIndex; // get the x-position
            
            let set = candleData?.getDataSetByIndex(indices[i].dataSetIndex) as! CandleChartDataSet!
            
            if (set === nil || !set!.isHighlightEnabled)
            {
                continue
            }
            
            let e = set!.entryForXIndex(xIndex) as! CandleChartDataEntry!
            
            if (e === nil || e!.xIndex != xIndex)
            {
                continue
            }
            
            let trans = delegate!.candleStickChartRenderer(self, transformerForAxis: set!.axisDependency)
            
            context.setStrokeColor(set!.highlightColor.cgColor)
            context.setLineWidth(set!.highlightLineWidth)
            if (set!.highlightLineDashLengths != nil)
            {
                context.setLineDash(phase: set!.highlightLineDashPhase, lengths: set!.highlightLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0, lengths: [])
            }
            
            let y = CGFloat(e!.close)
            
            _highlightPtsBuffer[0] = CGPoint(x: CGFloat(xIndex), y: CGFloat(delegate!.candleStickChartRendererChartYMax(self)))
            _highlightPtsBuffer[1] = CGPoint(x: CGFloat(xIndex), y: CGFloat(delegate!.candleStickChartRendererChartYMin(self)))
            _highlightPtsBuffer[2] = CGPoint(x: CGFloat(xIndex), y: CGFloat(delegate!.candleStickChartRendererChartYMax(self)))
            _highlightPtsBuffer[3] = CGPoint(x: CGFloat(xIndex), y: CGFloat(delegate!.candleStickChartRendererChartYMin(self)))
            _highlightPtsBuffer[4] = CGPoint(x: CGFloat(delegate!.candleStickChartRendererChartXMin(self)), y: y)
            _highlightPtsBuffer[5] = CGPoint(x: CGFloat(delegate!.candleStickChartRendererChartXMax(self)), y: y)
            
            trans?.pointValuesToPixel(&_highlightPtsBuffer)
            
            _highlightPtsBuffer[0].y = viewPortHandler.contentBottom
            _highlightPtsBuffer[1].y = 0
            _highlightPtsBuffer[2].y = viewPortHandler.contentTopVolume + viewPortHandler.contentHeightVolume
            _highlightPtsBuffer[3].y = viewPortHandler.contentTopVolume
            
            // draw the lines
            drawHighlightLines(context: context, points: _highlightPtsBuffer,
                horizontal: set!.isHorizontalHighlightIndicatorEnabled, vertical: set!.isVerticalHighlightIndicatorEnabled)
        }
    }
    
    fileprivate func getDenominator(max : Double, min : Double) -> Double
    {
        var denominator         = 0.0
        if min > max
        {
            return 0
        }
        
        if max >= 0 && min >= 0
        {
            denominator         = max
        }else if max >= 0 && min < 0
        {
            denominator         = max + abs(min)
        }else if max < 0 && min < 0
        {
            denominator         = abs(min)
        }else
        {
            return 0
        }
        
        return denominator
    }
    
    fileprivate func getMainMoneyColor(mainAmount : Double) -> CGColor
    {
        if mainAmount == 0
        {
            return Color("#999").cgColor
        }else if mainAmount > 0
        {
            return Color(COLOR_COMMON_RED).cgColor
        }else
        {
            return Color(COLOR_COMMON_GREEN).cgColor
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
