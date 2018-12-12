//
//  ChartYAxisRendererHorizontalBarChart.swift
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

open class ChartYAxisRendererHorizontalBarChart: ChartYAxisRenderer
{
    public override init(viewPortHandler: ChartViewPortHandler, yAxis: ChartYAxis, transformer: ChartTransformer!)
    {
        super.init(viewPortHandler: viewPortHandler, yAxis: yAxis, transformer: transformer)
    }

    /// Computes the axis values.
    open override func computeAxis(yMin: Double, yMax : Double)
    {
        // calculate the starting and entry point of the y-labels (depending on zoom / contentrect bounds)
        var tmpMin  = yMin
        var tmpMax  = yMax
        if (viewPortHandler.contentHeight > 10.0 && !viewPortHandler.isFullyZoomedOutX)
        {
            let p1 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            let p2 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            
            if (!_yAxis.isInverted)
            {
                tmpMin = Double(p1.x)
                tmpMax = Double(p2.x)
            }
            else
            {
                tmpMin = Double(p2.x)
                tmpMax = Double(p1.x)
            }
        }
        
        computeAxisValues(min: tmpMin, max: tmpMax)
    }

    /// draws the y-axis labels to the screen
    open override func renderAxisLabels(context: CGContext)
    {
        if (!_yAxis.isEnabled || !_yAxis.isDrawLabelsEnabled)
        {
            return
        }
        
        var positions = [CGPoint]()
        positions.reserveCapacity(_yAxis.entries.count)
        
        for i in 0 ..< _yAxis.entries.count
        {
            positions.append(CGPoint(x: CGFloat(_yAxis.entries[i]), y: 0.0))
        }
        
        transformer.pointValuesToPixel(&positions)
        
        let lineHeight = _yAxis.labelFont.lineHeight
        let baseYOffset: CGFloat = 2.5
        
        let dependency = _yAxis.axisDependency
        let labelPosition = _yAxis.labelPosition
        
        var yPos: CGFloat = 0.0
        
        if (dependency == .left)
        {
            if (labelPosition == .outsideChart)
            {
                yPos = viewPortHandler.contentTop - baseYOffset
            }
            else
            {
                yPos = viewPortHandler.contentTop - baseYOffset
            }
        }
        else
        {
            if (labelPosition == .outsideChart)
            {
                yPos = viewPortHandler.contentBottom + lineHeight + baseYOffset
            }
            else
            {
                yPos = viewPortHandler.contentBottom + lineHeight + baseYOffset
            }
        }
        
        // For compatibility with Android code, we keep above calculation the same,
        // And here we pull the line back up
        yPos -= lineHeight
        
        drawYLabels(context: context, fixedPosition: yPos, positions: positions, offset: _yAxis.yOffset)
    }
    
    fileprivate var _axisLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderAxisLine(context: CGContext)
    {
        if (!_yAxis.isEnabled || !_yAxis.drawAxisLineEnabled)
        {
            return
        }
        
        context.saveGState()
        
        context.setStrokeColor(_yAxis.axisLineColor.cgColor)
        context.setLineWidth(_yAxis.axisLineWidth)
        if (_yAxis.axisLineDashLengths != nil)
        {
            context.setLineDash(phase: _yAxis.axisLineDashPhase, lengths: _yAxis.axisLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0, lengths: [])
        }

        if (_yAxis.axisDependency == .left)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentTop
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        else
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentBottom
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        
        context.restoreGState()
    }

    /// draws the y-labels on the specified x-position
    internal func drawYLabels(context: CGContext, fixedPosition: CGFloat, positions: [CGPoint], offset: CGFloat)
    {
        let labelFont = _yAxis.labelFont
        let labelTextColor = _yAxis.labelTextColor
        
        for i in 0 ..< _yAxis.entryCount
        {
            let text = _yAxis.getFormattedLabel(i)
            
            if (!_yAxis.isDrawTopYLabelEntryEnabled && i >= _yAxis.entryCount - 1)
            {
                return
            }
            
            ChartUtils.drawText(context: context, text: text, point: CGPoint(x: positions[i].x, y: fixedPosition - offset), align: .center, attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): labelFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): labelTextColor])
        }
    }

    open override func renderGridLines(context: CGContext)
    {
        if (!_yAxis.isEnabled || !_yAxis.isDrawGridLinesEnabled)
        {
            return
        }
        
        context.saveGState()
        
        // pre alloc
        var position = CGPoint()
        
        context.setStrokeColor(_yAxis.gridColor.cgColor)
        context.setLineWidth(_yAxis.gridLineWidth)
        if (_yAxis.gridLineDashLengths != nil)
        {
            context.setLineDash(phase: _yAxis.gridLineDashPhase, lengths: _yAxis.gridLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0, lengths: [])
        }
        
        // draw the horizontal grid
        for i in 0 ..< _yAxis.entryCount
        {
            position.x = CGFloat(_yAxis.entries[i])
            position.y = 0.0
            transformer.pointValueToPixel(&position)
            
            context.beginPath()
            context.move(to: CGPoint(x: position.x, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: position.x, y: viewPortHandler.contentBottom))
            context.strokePath()
        }
        
        context.restoreGState()
    }
    
    fileprivate var _limitLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderLimitLines(context: CGContext)
    {
        let limitLines = _yAxis.limitLines

        if (limitLines.count <= 0)
        {
            return
        }
        
        context.saveGState()
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for l in limitLines
        {
            position.x = CGFloat(l.limit)
            position.y = 0.0
            position = position.applying(trans)
            
            _limitLineSegmentsBuffer[0].x = position.x
            _limitLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _limitLineSegmentsBuffer[1].x = position.x
            _limitLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            
            context.setStrokeColor(l.lineColor.cgColor)
            context.setLineWidth(l.lineWidth)
            if (l.lineDashLengths != nil)
            {
                context.setLineDash(phase: l.lineDashPhase, lengths: l.lineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0, lengths: [])
            }
            
            context.strokeLineSegments(between: _limitLineSegmentsBuffer)

            let label = l.label

            // if drawing the limit-value label is enabled
            if (label.characters.count > 0)
            {
                let labelLineHeight = l.valueFont.lineHeight
                
                let add = CGFloat(4.0)
                let xOffset: CGFloat = l.lineWidth
                let yOffset: CGFloat = add / 2.0
                
                if (l.labelPosition == .rightTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: position.x + xOffset,
                            y: viewPortHandler.contentTop + yOffset),
                        align: .left,
                        attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): l.valueFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): l.valueTextColor])
                }
                else if (l.labelPosition == .rightBottom)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: position.x + xOffset,
                            y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                        align: .left,
                        attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): l.valueFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): l.valueTextColor])
                }
                else if (l.labelPosition == .leftTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: position.x - xOffset,
                            y: viewPortHandler.contentTop + yOffset),
                        align: .right,
                        attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): l.valueFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): l.valueTextColor])
                }
                else
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: position.x - xOffset,
                            y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                        align: .right,
                        attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): l.valueFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): l.valueTextColor])
                }
            }
        }
        
        context.restoreGState()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
