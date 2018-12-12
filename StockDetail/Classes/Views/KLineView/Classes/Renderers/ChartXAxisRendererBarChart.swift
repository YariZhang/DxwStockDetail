//
//  ChartXAxisRendererBarChart.swift
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

open class ChartXAxisRendererBarChart: ChartXAxisRenderer
{
    internal weak var _chart: BarChartView!
    
    public init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!, chart: BarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer)
        
        self._chart = chart
    }
    
    /// draws the x-labels on the specified y-position
    internal override func drawLabels(context: CGContext, pos: CGFloat)
    {
        if (_chart.data === nil)
        {
            return
        }
        
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paraStyle.alignment = .center
        
        let labelAttrs : [String : AnyObject]? = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): _xAxis.labelFont,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): _xAxis.labelTextColor,
            convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): paraStyle]
        
        let barData = _chart.data as! BarChartData
        let step = barData.dataSetCount
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        var labelMaxSize = CGSize()
        
        if (_xAxis.isWordWrapEnabled)
        {
            labelMaxSize.width = _xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        //检查点
        var i = _minX
        let maxX = min(_maxX + 1, _xAxis.values.count)
        while i < maxX {
            let label = i >= 0 && i < _xAxis.values.count ? _xAxis.values[i] : nil
            if (label == nil)
            {
                i += _xAxis.axisLabelModulus
                continue
            }
            
            position.x = CGFloat(i * step) + CGFloat(i) * barData.groupSpace + barData.groupSpace / 2.0
            position.y = 0.0
            
            // consider groups (center label for each group)
            if (step > 1)
            {
                position.x += (CGFloat(step) - 1.0) / 2.0
            }
            
            position = position.applying(valueToPixelMatrix)
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                if (_xAxis.isAvoidFirstLastClippingEnabled)
                {
                    // avoid clipping of the last
                    if (i == _xAxis.values.count - 1)
                    {
                        let width = label!.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(labelAttrs)).width
                        
                        if (width > viewPortHandler.offsetRight * 2.0
                            && position.x + width > viewPortHandler.chartWidth)
                        {
                            position.x -= width / 2.0
                        }
                    }
                    else if (i == 0)
                    { // avoid clipping of the first
                        let width = label!.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(labelAttrs)).width
                        position.x += width / 2.0
                    }
                }
                
                ChartUtils.drawMultilineText(context: context, text: label!, point: CGPoint(x: position.x, y: pos), align: .center, attributes: labelAttrs, constrainedToSize: labelMaxSize)
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
        
        let barData = _chart.data as! BarChartData
        let step = barData.dataSetCount
        
        context.saveGState()
        
        context.setStrokeColor(_xAxis.gridColor.cgColor)
        context.setLineWidth(_xAxis.gridLineWidth)
        if (_xAxis.gridLineDashLengths != nil)
        {
            context.setLineDash(phase: _xAxis.gridLineDashPhase , lengths: _xAxis.gridLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0 , lengths: [])
        }
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        var i = _minX
        while i < _maxX {
            position.x = CGFloat(i * step) + CGFloat(i) * barData.groupSpace - 0.5
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                _gridLineSegmentsBuffer[0].x = position.x
                _gridLineSegmentsBuffer[0].y = viewPortHandler.contentTop
                _gridLineSegmentsBuffer[1].x = position.x
                _gridLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
                context.strokeLineSegments(between : _gridLineSegmentsBuffer)
            }
            i += _xAxis.axisLabelModulus
        }
        
        context.restoreGState()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
