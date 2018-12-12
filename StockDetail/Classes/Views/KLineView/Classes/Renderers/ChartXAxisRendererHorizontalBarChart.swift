//
//  ChartXAxisRendererHorizontalBarChart.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
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

open class ChartXAxisRendererHorizontalBarChart: ChartXAxisRendererBarChart
{
    public override init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!, chart: BarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer, chart: chart)
    }
    
    open override func computeAxis(xValAverageLength: Double, xValues: [String?])
    {
        _xAxis.values = xValues
       
        let longest = _xAxis.getLongestLabel() as NSString
        let longestSize = longest.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): _xAxis.labelFont]))
        _xAxis.labelWidth = floor(longestSize.width + _xAxis.xOffset * 3.5)
        _xAxis.labelHeight = longestSize.height
    }

    open override func renderAxisLabels(context: CGContext)
    {
        if (!_xAxis.isEnabled || !_xAxis.isDrawLabelsEnabled || _chart.data === nil)
        {
            return
        }
        
        let xoffset = _xAxis.xOffset
        
        if (_xAxis.labelPosition == .top)
        {
            drawLabels(context: context, pos: viewPortHandler.contentRight + xoffset, align: .left)
        }
        else if (_xAxis.labelPosition == .bottom)
        {
            drawLabels(context: context, pos: viewPortHandler.contentLeft - xoffset, align: .right)
        }
        else if (_xAxis.labelPosition == .bottomInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentLeft + xoffset, align: .left)
        }
        else if (_xAxis.labelPosition == .topInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentRight - xoffset, align: .right)
        }
        else
        { // BOTH SIDED
            drawLabels(context: context, pos: viewPortHandler.contentLeft - xoffset, align: .right)
            drawLabels(context: context, pos: viewPortHandler.contentRight + xoffset, align: .left)
        }
    }

    /// draws the x-labels on the specified y-position
    internal func drawLabels(context: CGContext, pos: CGFloat, align: NSTextAlignment)
    {
        let labelFont = _xAxis.labelFont
        let labelTextColor = _xAxis.labelTextColor
        
        // pre allocate to save performance (dont allocate in loop)
        var position = CGPoint(x: 0.0, y: 0.0)
        
        let bd = _chart.data as! BarChartData
        let step = bd.dataSetCount
        
        //检查点
        var i = _minX
        let maxX = min(_maxX + 1, _xAxis.values.count)
        while i < maxX {
            let label = _xAxis.values[i]
            
            if (label == nil)
            {
                i += _xAxis.axisLabelModulus
                continue
            }
            
            position.x = 0.0
            position.y = CGFloat(i * step) + CGFloat(i) * bd.groupSpace + bd.groupSpace / 2.0
            
            // consider groups (center label for each group)
            if (step > 1)
            {
                position.y += (CGFloat(step) - 1.0) / 2.0
            }
            
            transformer.pointValueToPixel(&position)
            
            if (viewPortHandler.isInBoundsY(position.y))
            {
                ChartUtils.drawText(context: context, text: label!, point: CGPoint(x: pos, y: position.y - _xAxis.labelHeight / 2.0), align: align, attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): labelFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): labelTextColor])
            }
            i += _xAxis.axisLabelModulus
        }
    
    }
    
    fileprivate var _gridLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderGridLines(context: CGContext)
    {
        if (!_xAxis.isEnabled || !_xAxis.isDrawGridLinesEnabled || _chart.data === nil)
        {
            return
        }
        
        context.saveGState()
        
        context.setStrokeColor(_xAxis.gridColor.cgColor)
        context.setLineWidth(_xAxis.gridLineWidth)
        if (_xAxis.gridLineDashLengths != nil)
        {
            context.setLineDash(phase: _xAxis.gridLineDashPhase, lengths: _xAxis.gridLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        let bd = _chart.data as! BarChartData
        
        // take into consideration that multiple DataSets increase _deltaX
        let step = bd.dataSetCount
        //检查点
        var i = _minX
        let maxX = min(_maxX + 1, _xAxis.values.count)
        while i < maxX {
            position.x = 0.0
            position.y = CGFloat(i * step) + CGFloat(i) * bd.groupSpace - 0.5
            
            transformer.pointValueToPixel(&position)
            
            if (viewPortHandler.isInBoundsY(position.y))
            {
                _gridLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
                _gridLineSegmentsBuffer[0].y = position.y
                _gridLineSegmentsBuffer[1].x = viewPortHandler.contentRight
                _gridLineSegmentsBuffer[1].y = position.y
                context.strokeLineSegments(between: _gridLineSegmentsBuffer)
            }
            i += _xAxis.axisLabelModulus
        }
        
        context.restoreGState()
    }
    
    fileprivate var _axisLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderAxisLine(context: CGContext)
    {
        if (!_xAxis.isEnabled || !_xAxis.isDrawAxisLineEnabled)
        {
            return
        }
        
        context.saveGState()
        
        context.setStrokeColor(_xAxis.axisLineColor.cgColor)
        context.setLineWidth(_xAxis.axisLineWidth)
        if (_xAxis.axisLineDashLengths != nil)
        {
            context.setLineDash(phase: _xAxis.axisLineDashPhase, lengths: _xAxis.axisLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        if (_xAxis.labelPosition == .top
            || _xAxis.labelPosition == .topInside
            || _xAxis.labelPosition == .bothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        
        if (_xAxis.labelPosition == .bottom
            || _xAxis.labelPosition == .bottomInside
            || _xAxis.labelPosition == .bothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        
        context.restoreGState()
    }
    
    fileprivate var _limitLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderLimitLines(context: CGContext)
    {
        let limitLines = _xAxis.limitLines
        
        if (limitLines.count == 0)
        {
            return
        }
        
        context.saveGState()
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for l in limitLines
        {
            
            position.x = 0.0
            position.y = CGFloat(l.limit)
            position = position.applying(trans)
            
            _limitLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _limitLineSegmentsBuffer[0].y = position.y
            _limitLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _limitLineSegmentsBuffer[1].y = position.y
            
            context.setStrokeColor(l.lineColor.cgColor)
            context.setLineWidth(l.lineWidth)
            if (l.lineDashLengths != nil)
            {
                context.setLineDash(phase: l.lineDashPhase, lengths: l.lineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            context.strokeLineSegments(between: _limitLineSegmentsBuffer)
            
            let label = l.label
            
            // if drawing the limit-value label is enabled
            if (label.characters.count > 0)
            {
                let labelLineHeight = l.valueFont.lineHeight
                
                let add = CGFloat(4.0)
                let xOffset: CGFloat = add
                let yOffset: CGFloat = l.lineWidth + labelLineHeight
                
                if (l.labelPosition == .rightTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentRight - xOffset,
                            y: position.y - yOffset),
                        align: .right,
                        attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): l.valueFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): l.valueTextColor])
                }
                else if (l.labelPosition == .rightBottom)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentRight - xOffset,
                            y: position.y + yOffset - labelLineHeight),
                        align: .right,
                        attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): l.valueFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): l.valueTextColor])
                }
                else if (l.labelPosition == .leftTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentLeft + xOffset,
                            y: position.y - yOffset),
                        align: .left,
                        attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): l.valueFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): l.valueTextColor])
                }
                else
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentLeft + xOffset,
                            y: position.y + yOffset - labelLineHeight),
                        align: .left,
                        attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): l.valueFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): l.valueTextColor])
                }
            }
        }
        
        context.restoreGState()
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
