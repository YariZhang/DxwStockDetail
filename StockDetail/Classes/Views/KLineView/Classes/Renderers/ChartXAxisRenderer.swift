//
//  ChartXAxisRenderer.swift
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

open class ChartXAxisRenderer: ChartAxisRendererBase
{
    internal var _xAxis: ChartXAxis!
  
    public init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!)
    {
        super.init(viewPortHandler: viewPortHandler, transformer: transformer)
        
        _xAxis = xAxis
    }
    
    open func computeAxis(xValAverageLength: Double, xValues: [String?])
    {
        var a = ""
        
        let max = Int(round(xValAverageLength + Double(_xAxis.spaceBetweenLabels)))
        
        for _ in 0 ..< max
        {
            a += "h"
        }
        
        let widthText = a as NSString
        
        _xAxis.labelWidth = widthText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): _xAxis.labelFont])).width
        _xAxis.labelHeight = _xAxis.labelFont.lineHeight
        _xAxis.values = xValues
    }
    
    // 画日期的label
    open override func renderAxisLabels(context: CGContext)
    {
        if (!_xAxis.isEnabled || !_xAxis.isDrawLabelsEnabled)
        {
            return
        }
        
        let yoffset = CGFloat(4.0)
        
        if (_xAxis.labelPosition == .top)
        {
            drawLabels(context: context, pos: viewPortHandler.offsetTop - _xAxis.labelHeight - yoffset)
        }
        else if (_xAxis.labelPosition == .bottom)
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yoffset * 1.5)
        }
        else if (_xAxis.labelPosition == .bottomInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom - _xAxis.labelHeight - yoffset)
        }
        else if (_xAxis.labelPosition == .topInside)
        {
            drawLabels(context: context, pos: viewPortHandler.offsetTop + yoffset)
        }
        else
        { // BOTH SIDED
            drawLabels(context: context, pos: viewPortHandler.offsetTop - _xAxis.labelHeight - yoffset)
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yoffset * 1.6)
        }
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
            context.setLineDash(phase: 0.0 , lengths : [])
        }

        if (_xAxis.labelPosition == .top
                || _xAxis.labelPosition == .topInside
                || _xAxis.labelPosition == .bothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentTop
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }

        if (_xAxis.labelPosition == .bottom
                || _xAxis.labelPosition == .bottomInside
                || _xAxis.labelPosition == .bothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentBottom
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        
        context.restoreGState()
    }
    
    /// draws the x-labels on the specified y-position
    // 画日期的label
    internal func drawLabels(context: CGContext, pos: CGFloat)
    {
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paraStyle.alignment = .center
        
        let labelAttrs = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): _xAxis.labelFont,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): _xAxis.labelTextColor,
            convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): paraStyle] as [String : Any]
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        var labelMaxSize = CGSize()
        
        if (_xAxis.isWordWrapEnabled)
        {
            labelMaxSize.width = _xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        var i = _minX , maxX = min(_maxX + 1, _xAxis.values.count)
        while i < maxX
        {
            let label = _xAxis.values[i]
            if (label == nil)
            {
                i += _xAxis.axisLabelModulus
                continue
            }
            
            position.x = CGFloat(i)
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                let labelns = label! as NSString
                
                if (_xAxis.isAvoidFirstLastClippingEnabled)
                {
                    // avoid clipping of the last
                    if (i == _xAxis.values.count - 1 && _xAxis.values.count > 1) || (i == _xAxis.values.count - 2 && _xAxis.values.count > 2)
                    {
                        let width = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary(labelAttrs), context: nil).size.width
                        
                        if (width > viewPortHandler.offsetRight * 2.0
                            && position.x + width > viewPortHandler.chartWidth)
                        {
                            position.x -= width / 2.0
                        }
                    }
                    else if (i == 0)
                    { // avoid clipping of the first
                        let width = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary(labelAttrs), context: nil).size.width
                        position.x += width / 2.0
                    }
                }
                
                ChartUtils.drawMultilineText(context: context, text: label!, point: CGPoint(x: position.x, y: pos), align: .center, attributes: labelAttrs as [String : AnyObject]?, constrainedToSize: labelMaxSize)
            }
            i += _xAxis.axisLabelModulus
        }
    }
    
    fileprivate var _gridLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderGridLines(context: CGContext)
    {
        if (!_xAxis.isDrawGridLinesEnabled || !_xAxis.isEnabled)
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
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        var i = _minX
        while i <= _maxX
        {
            position.x = CGFloat(i)
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if (position.x >= viewPortHandler.offsetLeft
                && position.x <= viewPortHandler.chartWidth)
            {
                _gridLineSegmentsBuffer[0].x = position.x
                _gridLineSegmentsBuffer[0].y = viewPortHandler.contentTop
                _gridLineSegmentsBuffer[1].x = position.x
                _gridLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
                context.strokeLineSegments(between: _gridLineSegmentsBuffer)
                _gridLineSegmentsBuffer[0].x = position.x
                _gridLineSegmentsBuffer[0].y = viewPortHandler.contentTopVolume
                _gridLineSegmentsBuffer[1].x = position.x
                _gridLineSegmentsBuffer[1].y = viewPortHandler.contentBottomVolume
                context.strokeLineSegments(between: _gridLineSegmentsBuffer)
            }
            i += _xAxis.axisLabelModulus
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
                context.setLineDash(phase: 0.0, lengths: [])
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
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
