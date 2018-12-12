//
//  LineChartRenderer.swift
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
public protocol LineChartRendererDelegate
{
    func lineChartRendererData(_ renderer: LineChartRenderer) -> LineChartData!
    func lineChartRenderer(_ renderer: LineChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    func lineChartRendererFillFormatter(_ renderer: LineChartRenderer) -> ChartFillFormatter
    func lineChartDefaultRendererValueFormatter(_ renderer: LineChartRenderer) -> NumberFormatter!
    func lineChartRendererChartYMax(_ renderer: LineChartRenderer) -> Double
    func lineChartRendererChartYMin(_ renderer: LineChartRenderer) -> Double
    func lineChartRendererChartXMax(_ renderer: LineChartRenderer) -> Double
    func lineChartRendererChartXMin(_ renderer: LineChartRenderer) -> Double
    func lineChartRendererMaxVisibleValueCount(_ renderer: LineChartRenderer) -> Int
}

open class LineChartRenderer: LineScatterCandleRadarChartRenderer
{
    open weak var delegate: LineChartRendererDelegate?
    
    public init(delegate: LineChartRendererDelegate?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.delegate = delegate
    }
    
    //检查点
    open override func drawData(context: CGContext)
    {
        guard let lineData = delegate!.lineChartRendererData(self) else {
            return
        }
        
        for i in 0 ..< lineData.dataSetCount
        {
            let set = lineData.getDataSetByIndex(i)
            
            if (set !== nil && set!.isVisible)
            {
                drawDataSet(context: context, dataSet: set as! LineChartDataSet)
            }
        }
    }
    
    internal struct CGCPoint
    {
        internal var x: CGFloat = 0.0
        internal var y: CGFloat = 0.0
        
        ///  x-axis distance
        internal var dx: CGFloat = 0.0
        ///  y-axis distance
        internal var dy: CGFloat = 0.0
        
        internal init(x: CGFloat, y: CGFloat)
        {
            self.x = x
            self.y = y
        }
    }
    
    internal func drawDataSet(context: CGContext, dataSet: LineChartDataSet)
    {
        let entries = dataSet.yVals
        
        if (entries.count < 1)
        {
            return
        }
        
        context.saveGState()
        
        context.setLineWidth(dataSet.lineWidth)
        if (dataSet.lineDashLengths != nil)
        {
            context.setLineDash(phase: dataSet.lineDashPhase, lengths: dataSet.lineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0, lengths: [])
        }
        
        // if drawing cubic lines is enabled
        if (dataSet.isDrawCubicEnabled)
        {
            drawCubic(context: context, dataSet: dataSet, entries: entries)
        }
        else
        { // draw normal (straight) lines
            drawLinear(context: context, dataSet: dataSet, entries: entries)
        }
        
        context.restoreGState()
    }
    
    internal func drawCubic(context: CGContext, dataSet: LineChartDataSet, entries: [ChartDataEntry])
    {
        let trans = delegate?.lineChartRenderer(self, transformerForAxis: dataSet.axisDependency)
        
        let entryFrom = dataSet.entryForXIndex(_minX)
        let entryTo = dataSet.entryForXIndex(_maxX)
        
        let minx = max(dataSet.entryIndex(entry: entryFrom!, isEqual: true), 0)
        let maxx = min(dataSet.entryIndex(entry: entryTo!, isEqual: true) + 1, entries.count)
        
        let phaseX = _animator.phaseX
        let phaseY = _animator.phaseY
        
        // get the color that is specified for this position from the DataSet
        let drawingColor = dataSet.colors.first!
        
        let intensity = dataSet.cubicIntensity
        
        // the path for the cubic-spline
        let cubicPath = CGMutablePath()
        
        let valueToPixelMatrix = trans!.valueToPixelMatrix
        
        let size = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
        
        if (size - minx >= 2)
        {
            var prevDx: CGFloat = 0.0
            var prevDy: CGFloat = 0.0
            var curDx: CGFloat = 0.0
            var curDy: CGFloat = 0.0
            
            var prevPrev = entries[minx]
            var prev = entries[minx]
            var cur = entries[minx]
            var next = entries[minx + 1]
            
            // let the spline start
            cubicPath.move(to: CGPoint(x: CGFloat(cur.xIndex), y: CGFloat(cur.value) * phaseY), transform: valueToPixelMatrix)
            
            prevDx = CGFloat(cur.xIndex - prev.xIndex) * intensity
            prevDy = CGFloat(cur.value - prev.value) * intensity
            
            curDx = CGFloat(next.xIndex - cur.xIndex) * intensity
            curDy = CGFloat(next.value - cur.value) * intensity
            
            // the first cubic
            cubicPath.addCurve(to:CGPoint(x: CGFloat(cur.xIndex), y: CGFloat(cur.value) * phaseY),
                               control1: CGPoint(x: CGFloat(prev.xIndex) + prevDx, y: (CGFloat(prev.value) + prevDy) * phaseY),
                               control2: CGPoint(x: CGFloat(cur.xIndex) - curDx, y: (CGFloat(cur.value) - curDy) * phaseY),
                               transform: valueToPixelMatrix)
            //检查点
            var j = minx + 1
            let count = min(size, entries.count - 1)
            while j < count {
                prevPrev = entries[j == 1 ? 0 : j - 2]
                prev = entries[j - 1]
                cur = entries[j]
                next = entries[j + 1]
                
                prevDx = CGFloat(cur.xIndex - prevPrev.xIndex) * intensity
                prevDy = CGFloat(cur.value - prevPrev.value) * intensity
                curDx = CGFloat(next.xIndex - prev.xIndex) * intensity
                curDy = CGFloat(next.value - prev.value) * intensity
                
                cubicPath.addCurve(to:CGPoint(x: CGFloat(cur.xIndex), y: CGFloat(cur.value) * phaseY),
                                   control1: CGPoint(x: CGFloat(prev.xIndex) + prevDx, y: (CGFloat(prev.value) + prevDy) * phaseY),
                                   control2: CGPoint(x: CGFloat(cur.xIndex) - curDx, y: (CGFloat(cur.value) - curDy) * phaseY),
                                   transform: valueToPixelMatrix)
                j += 1
            }
            
            if (size > entries.count - 1)
            {
                prevPrev = entries[entries.count - (entries.count >= 3 ? 3 : 2)]
                prev = entries[entries.count - 2]
                cur = entries[entries.count - 1]
                next = cur
                
                prevDx = CGFloat(cur.xIndex - prevPrev.xIndex) * intensity
                prevDy = CGFloat(cur.value - prevPrev.value) * intensity
                curDx = CGFloat(next.xIndex - prev.xIndex) * intensity
                curDy = CGFloat(next.value - prev.value) * intensity
                
                // the last cubic
                cubicPath.addCurve(to:CGPoint(x: CGFloat(cur.xIndex), y: CGFloat(cur.value) * phaseY),
                                   control1: CGPoint(x: CGFloat(prev.xIndex) + prevDx, y: (CGFloat(prev.value) + prevDy) * phaseY),
                                   control2: CGPoint(x: CGFloat(cur.xIndex) - curDx, y: (CGFloat(cur.value) - curDy) * phaseY),
                                   transform: valueToPixelMatrix)
            }
        }
        
        context.saveGState()
        
        if (dataSet.isDrawFilledEnabled)
        {
            drawCubicFill(context: context, dataSet: dataSet, spline: cubicPath, matrix: valueToPixelMatrix, from: minx, to: size)
        }
        
        context.beginPath()
        context.addPath(cubicPath)
        context.setStrokeColor(drawingColor.cgColor)
        context.strokePath()
        
        context.restoreGState()
    }
    
    internal func drawCubicFill(context: CGContext, dataSet: LineChartDataSet, spline: CGMutablePath, matrix: CGAffineTransform, from: Int, to: Int)
    {
        context.saveGState()
        
        let fillMin = delegate!.lineChartRendererFillFormatter(self).getFillLinePosition(
            dataSet: dataSet,
            data: delegate!.lineChartRendererData(self),
            chartMaxY: delegate!.lineChartRendererChartYMax(self),
            chartMinY: delegate!.lineChartRendererChartYMin(self))
        
        var pt1 = CGPoint(x: CGFloat(to - 1), y: fillMin)
        var pt2 = CGPoint(x: CGFloat(from), y: fillMin)
        pt1 = pt1.applying(matrix)
        pt2 = pt2.applying(matrix)
        
        context.beginPath()
        context.addPath(spline)
        context.addLine(to: CGPoint(x: pt1.x, y: pt1.y))
        context.addLine(to: CGPoint(x: pt2.x, y: pt2.y))
        context.closePath()
        
        context.setFillColor(dataSet.fillColor.cgColor)
        context.setAlpha(dataSet.fillAlpha)
        context.fillPath()
        
        context.restoreGState()
    }
    
    fileprivate var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    internal func drawLinear(context: CGContext, dataSet: LineChartDataSet, entries: [ChartDataEntry])
    {
        let trans = delegate!.lineChartRenderer(self, transformerForAxis: dataSet.axisDependency)
        let valueToPixelMatrix = trans?.valueToPixelMatrix
        
        let phaseX = _animator.phaseX
        let phaseY = _animator.phaseY
        
        context.saveGState()
        
        let entryFrom = dataSet.entryForXIndex(_minX)
        let entryTo = dataSet.entryForXIndex(_maxX)
        
        let minx = max(dataSet.entryIndex(entry: entryFrom!, isEqual: true), 0)
        let maxx = min(dataSet.entryIndex(entry: entryTo!, isEqual: true) + 1, entries.count)
        
        // more than 1 color
        //检查点
        if (dataSet.colors.count > 1)
        {
            if (_lineSegments.count != 2)
            {
                _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
            }
            
            var j = minx
            let count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
            while j < count {
                if (count > 1 && j == count - 1)
                { // Last point, we have already drawn a line to this point
                    break
                }
                
                var e = entries[j]
                
                _lineSegments[0].x = CGFloat(e.xIndex)
                _lineSegments[0].y = CGFloat(e.value) * phaseY
                _lineSegments[0] = _lineSegments[0].applying(valueToPixelMatrix!)
                if (j + 1 < count)
                {
                    e = entries[j + 1]
                    
                    _lineSegments[1].x = CGFloat(e.xIndex)
                    _lineSegments[1].y = CGFloat(e.value) * phaseY
                    _lineSegments[1] = _lineSegments[1].applying(valueToPixelMatrix!)
                }
                else
                {
                    _lineSegments[1] = _lineSegments[0]
                }
                
                if (!viewPortHandler.isInBoundsRight(_lineSegments[0].x))
                {
                    break
                }
                
                // make sure the lines don't do shitty things outside bounds
                if (!viewPortHandler.isInBoundsLeft(_lineSegments[1].x)
                    || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y))
                    || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y)))
                {
                    j += 1
                    continue
                }
                
                // get the color that is set for this line-segment
                context.setStrokeColor(dataSet.colorAt(j).cgColor)
                context.strokeLineSegments(between: _lineSegments)
                j += 1
            }
            
        }
        else
        { // only one color per dataset
            
            var e1: ChartDataEntry!
            var e2: ChartDataEntry!
            
            if (_lineSegments.count != max((entries.count - 1) * 2, 2))
            {
                _lineSegments = [CGPoint](repeating: CGPoint(), count: max((entries.count - 1) * 2, 2))
            }
            
            e1 = entries[minx]
            
            let count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
            var x = count > 1 ? minx + 1 : minx
            var j = 0
            while x < count {
                e1 = entries[x == 0 ? 0 : (x - 1)]
                e2 = entries[x]
                j += 1
                _lineSegments[j] = CGPoint(x: CGFloat(e1.xIndex), y: CGFloat(e1.value) * phaseY).applying(valueToPixelMatrix!)
                _lineSegments[j] = CGPoint(x: CGFloat(e2.xIndex), y: CGFloat(e2.value) * phaseY).applying(valueToPixelMatrix!)
                x += 1
            }
            
            //let size = max((count - minx - 1) * 2, 2)
            context.setStrokeColor(dataSet.colorAt(0).cgColor)
            context.strokeLineSegments(between: _lineSegments)
        }
        
        context.restoreGState()
        
        // if drawing filled is enabled
        if (dataSet.isDrawFilledEnabled && entries.count > 0)
        {
            drawLinearFill(context: context, dataSet: dataSet, entries: entries, minx: minx, maxx: maxx, trans: trans!)
        }
    }
    
    internal func drawLinearFill(context: CGContext, dataSet: LineChartDataSet, entries: [ChartDataEntry], minx: Int, maxx: Int, trans: ChartTransformer)
    {
        context.saveGState()
        
        context.setFillColor(dataSet.fillColor.cgColor)
        
        // filled is usually drawn with less alpha
        context.setAlpha(dataSet.fillAlpha)
        
        let filled = generateFilledPath(
            entries,
            fillMin: delegate!.lineChartRendererFillFormatter(self).getFillLinePosition(
                dataSet: dataSet,
                data: delegate!.lineChartRendererData(self),
                chartMaxY: delegate!.lineChartRendererChartYMax(self),
                chartMinY: delegate!.lineChartRendererChartYMin(self)),
            from: minx,
            to: maxx,
            matrix: trans.valueToPixelMatrix)
        
        context.beginPath()
        context.addPath(filled)
        context.fillPath()
        
        context.restoreGState()
    }
    
    /// Generates the path that is used for filled drawing.
    //检查点
    fileprivate func generateFilledPath(_ entries: [ChartDataEntry], fillMin: CGFloat, from: Int, to: Int,  matrix: CGAffineTransform) -> CGPath
    {
        let tmpMatrix = matrix
        let phaseX = _animator.phaseX
        let phaseY = _animator.phaseY
        let filled = CGMutablePath()
        filled.move(to: CGPoint(x: CGFloat(entries[from].xIndex), y: fillMin), transform: tmpMatrix)
        filled.addLine(to: CGPoint(x: CGFloat(entries[from].xIndex), y: CGFloat(entries[from].value) * phaseY), transform: tmpMatrix)
        
        // create a new path
        var x = from + 1
        let count = Int(ceil(CGFloat(to - from) * phaseX + CGFloat(from)))
        while x < count {
            let e = entries[x]
            filled.addLine(to: CGPoint(x: CGFloat(e.xIndex), y: CGFloat(e.value) * phaseY), transform: tmpMatrix)
            x += 1
        }
        
        // close up
        filled.addLine(to: CGPoint(x: CGFloat(entries[max(min(Int(ceil(CGFloat(to - from) * phaseX + CGFloat(from))) - 1, entries.count - 1), 0)].xIndex), y: fillMin), transform: tmpMatrix)
        filled.closeSubpath()
        
        return filled
    }
    
    open override func drawValues(context: CGContext)
    {
        let lineData = delegate!.lineChartRendererData(self)
        if (lineData === nil)
        {
            return
        }
        
        let defaultValueFormatter = delegate!.lineChartDefaultRendererValueFormatter(self)
        
        if (CGFloat((lineData?.yValCount)!) < CGFloat(delegate!.lineChartRendererMaxVisibleValueCount(self)) * viewPortHandler.scaleX)
        {
            let dataSets = lineData?.dataSets
            
            for d in dataSets!
            {
                let dataSet = d as! LineChartDataSet
                
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
                
                let trans = delegate!.lineChartRenderer(self, transformerForAxis: dataSet.axisDependency)
                
                // make sure the values do not interfear with the circles
                var valOffset = Int(dataSet.circleRadius * 1.75)
                
                if (!dataSet.isDrawCirclesEnabled)
                {
                    valOffset = valOffset / 2
                }
                
                var entries = dataSet.yVals
                
                let entryFrom = dataSet.entryForXIndex(_minX)
                let entryTo = dataSet.entryForXIndex(_maxX)
                
                let minx = max(dataSet.entryIndex(entry: entryFrom!, isEqual: true), 0)
                let maxx = min(dataSet.entryIndex(entry: entryTo!, isEqual: true) + 1, entries.count)
                
                var positions = trans!.generateTransformedValuesLine(
                    entries,
                    phaseX: _animator.phaseX,
                    phaseY: _animator.phaseY,
                    from: minx,
                    to: maxx)
                
                for j in 0 ..< positions.count
                {
                    if (!viewPortHandler.isInBoundsRight(positions[j].x))
                    {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(positions[j].x) || !viewPortHandler.isInBoundsY(positions[j].y))
                    {
                        continue
                    }
                    
                    let val = entries[j + minx].value
                    
                    ChartUtils.drawText(context: context, text: formatter!.string(from: NSNumber(value: val))!, point: CGPoint(x: positions[j].x, y: positions[j].y - CGFloat(valOffset) - valueFont.lineHeight), align: .center, attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): valueFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): valueTextColor])
                }
            }
        }
    }
    
    open override func drawExtras(context: CGContext)
    {
        drawCircles(context: context)
    }
    
    fileprivate func drawCircles(context: CGContext)
    {
        let phaseX = _animator.phaseX
        let phaseY = _animator.phaseY
        
        let lineData = delegate!.lineChartRendererData(self)
        
        let dataSets = lineData?.dataSets
        
        var pt = CGPoint()
        var rect = CGRect()
        
        context.saveGState()
        
        for i in 0 ..< dataSets!.count
        {
            let dataSet = lineData?.getDataSetByIndex(i) as! LineChartDataSet
            
            if (!dataSet.isVisible || !dataSet.isDrawCirclesEnabled)
            {
                continue
            }
            
            let trans = delegate!.lineChartRenderer(self, transformerForAxis: dataSet.axisDependency)
            let valueToPixelMatrix = trans!.valueToPixelMatrix
            
            var entries = dataSet.yVals
            
            let circleRadius = dataSet.circleRadius
            let circleDiameter = circleRadius * 2.0
            let circleHoleDiameter = circleRadius
            let circleHoleRadius = circleHoleDiameter / 2.0
            let isDrawCircleHoleEnabled = dataSet.isDrawCircleHoleEnabled
            
            let entryFrom = dataSet.entryForXIndex(_minX)!
            let entryTo = dataSet.entryForXIndex(_maxX)!
            
            let minx = max(dataSet.entryIndex(entry: entryFrom, isEqual: true), 0)
            let maxx = min(dataSet.entryIndex(entry: entryTo, isEqual: true) + 1, entries.count)
            var j = minx
            let count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
            while j < count {
                let e = entries[j]
                pt.x = CGFloat(e.xIndex)
                pt.y = CGFloat(e.value) * phaseY
                pt = pt.applying(valueToPixelMatrix)
                
                if (!viewPortHandler.isInBoundsRight(pt.x))
                {
                    break
                }
                
                // make sure the circles don't do shitty things outside bounds
                if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                {
                    j += 1
                    continue
                }
                
                context.setFillColor(dataSet.getCircleColor(j)!.cgColor)
                
                rect.origin.x = pt.x - circleRadius
                rect.origin.y = pt.y - circleRadius
                rect.size.width = circleDiameter
                rect.size.height = circleDiameter
                context.fillEllipse(in: rect)
                
                if (isDrawCircleHoleEnabled)
                {
                    context.setFillColor(dataSet.circleHoleColor.cgColor)
                    
                    rect.origin.x = pt.x - circleHoleRadius
                    rect.origin.y = pt.y - circleHoleRadius
                    rect.size.width = circleHoleDiameter
                    rect.size.height = circleHoleDiameter
                    context.fillEllipse(in: rect)
                }
                j += 1
            }
            
        }
        
        context.restoreGState()
    }
    
    var _highlightPtsBuffer = [CGPoint](repeating: CGPoint(), count: 4)
    
    open override func drawHighlighted(context: CGContext, indices: [ChartHighlight])
    {
        let lineData = delegate!.lineChartRendererData(self)
        let chartXMax = delegate!.lineChartRendererChartXMax(self)
        let chartYMax = delegate!.lineChartRendererChartYMax(self)
        let chartYMin = delegate!.lineChartRendererChartYMin(self)
        
        context.saveGState()
        
        for i in 0 ..< indices.count
        {
            let set = lineData?.getDataSetByIndex(indices[i].dataSetIndex) as! LineChartDataSet!
            
            if (set === nil || !set!.isHighlightEnabled)
            {
                continue
            }
            
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
            
            let xIndex = indices[i].xIndex; // get the x-position
            
            if (CGFloat(xIndex) > CGFloat(chartXMax) * _animator.phaseX)
            {
                continue
            }
            
            let yValue = set!.yValForXIndex(xIndex)
            if (yValue.isNaN)
            {
                continue
            }
            
            let y = CGFloat(yValue) * _animator.phaseY; // get the y-position
            
            _highlightPtsBuffer[0] = CGPoint(x: CGFloat(xIndex), y: CGFloat(chartYMax))
            _highlightPtsBuffer[1] = CGPoint(x: CGFloat(xIndex), y: CGFloat(chartYMin))
            _highlightPtsBuffer[2] = CGPoint(x: CGFloat(delegate!.lineChartRendererChartXMin(self)), y: y)
            _highlightPtsBuffer[3] = CGPoint(x: CGFloat(chartXMax), y: y)
            
            let trans = delegate!.lineChartRenderer(self, transformerForAxis: set!.axisDependency)
            
            trans?.pointValuesToPixel(&_highlightPtsBuffer)
            
            // draw the lines
            drawHighlightLines(context: context, points: _highlightPtsBuffer,
                horizontal: set!.isHorizontalHighlightIndicatorEnabled, vertical: set!.isVerticalHighlightIndicatorEnabled)
        }
        
        context.restoreGState()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
