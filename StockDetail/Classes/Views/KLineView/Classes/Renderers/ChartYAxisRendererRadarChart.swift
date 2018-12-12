//
//  ChartYAxisRendererRadarChart.swift
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

open class ChartYAxisRendererRadarChart: ChartYAxisRenderer
{
    fileprivate weak var _chart: RadarChartView!
    
    public init(viewPortHandler: ChartViewPortHandler, yAxis: ChartYAxis, chart: RadarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, yAxis: yAxis, transformer: nil)
        
        _chart = chart
    }
 
    open override func computeAxis(yMin: Double, yMax: Double)
    {
        computeAxisValues(min: yMin, max: yMax)
    }
    
    internal override func computeAxisValues(min yMin: Double, max yMax: Double)
    {
        let labelCount = _yAxis.labelCount
        let range = abs(yMax - yMin)
        
        if (labelCount == 0 || range <= 0)
        {
            _yAxis.entries = [Double]()
            return
        }
        
        let rawInterval = range / Double(labelCount)
        var interval = ChartUtils.roundToNextSignificant(number: Double(rawInterval))
        let intervalMagnitude = pow(10.0, round(log10(interval)))
        let intervalSigDigit = Int(interval / intervalMagnitude)
        
        if (intervalSigDigit > 5)
        {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or
            // 90
            interval = floor(10 * intervalMagnitude)
        }
        
        // force label count
        if _yAxis.isForceLabelsEnabled
        {
            let step = Double(range) / Double(labelCount - 1)
            
            if _yAxis.entries.count < labelCount
            {
                // Ensure stops contains at least numStops elements.
                _yAxis.entries.removeAll(keepingCapacity: true)
            }
            else
            {
                _yAxis.entries = [Double]()
                _yAxis.entries.reserveCapacity(labelCount)
            }
            
            var v = yMin
            
            for _ in 0 ..< labelCount
            {
                _yAxis.entries.append(v)
                v += step
            }
            
        }
        else
        {
            // no forced count
            
            // clean old values
            if (_yAxis.entries.count > 0)
            {
                _yAxis.entries.removeAll(keepingCapacity: false)
            }
            
            // if the labels should only show min and max
            if (_yAxis.isShowOnlyMinMaxEnabled)
            {
                _yAxis.entries = [Double]()
                _yAxis.entries.append(yMin)
                _yAxis.entries.append(yMax)
            }
            else
            {
                let rawCount = Double(yMin) / interval
                var first = rawCount < 0.0 ? floor(rawCount) * interval : ceil(rawCount) * interval;
                
                if (first < yMin && _yAxis.isStartAtZeroEnabled)
                { // Force the first label to be at the 0 (or smallest negative value)
                    first = yMin
                }
                
                if (first == 0.0)
                { // Fix for IEEE negative zero case (Where value == -0.0, and 0.0 == -0.0)
                    first = 0.0
                }
                
                let last = ChartUtils.nextUp(floor(Double(yMax) / interval) * interval)
                
                var f: Double
                var n = 0
                f = first
                while f <= last {
                    n += 1
                    f += interval
                }
                
                if (_yAxis.customAxisMax.isNaN)
                {
                    n += 1
                }
                
                if (_yAxis.entries.count < n)
                {
                    // Ensure stops contains at least numStops elements.
                    _yAxis.entries = [Double](repeating: 0.0, count: n)
                }
                f = first
                for i in 0 ..< n {
                    _yAxis.entries[i] = Double(f)
                    f += interval
                }
            }
        }
        
        if !_yAxis.isStartAtZeroEnabled && _yAxis.entries[0] < yMin
        {
            // If startAtZero is disabled, and the first label is lower that the axis minimum,
            // Then adjust the axis minimum
            _yAxis.axisMinimum = _yAxis.entries[0]
        }
        _yAxis.axisMaximum = _yAxis.entries[_yAxis.entryCount - 1]
        _yAxis.axisRange = abs(_yAxis.axisMaximum - _yAxis.axisMinimum)
    }
    
    open override func renderAxisLabels(context: CGContext)
    {
        if (!_yAxis.isEnabled || !_yAxis.isDrawLabelsEnabled)
        {
            return
        }
        
        let labelFont = _yAxis.labelFont
        let labelTextColor = _yAxis.labelTextColor
        
        let center = _chart.centerOffsets
        let factor = _chart.factor
        
        let labelCount = _yAxis.entryCount
        
        let labelLineHeight = _yAxis.labelFont.lineHeight
        
        for j in 0 ..< labelCount
        {
            if (j == labelCount - 1 && _yAxis.isDrawTopYLabelEntryEnabled == false)
            {
                break
            }
            
            let r = CGFloat(_yAxis.entries[j] - _yAxis.axisMinimum) * factor
            
            let p = ChartUtils.getPosition(center: center, dist: r, angle: _chart.rotationAngle)
            
            let label = _yAxis.getFormattedLabel(j)
            
            ChartUtils.drawText(context: context, text: label, point: CGPoint(x: p.x + 10.0, y: p.y - labelLineHeight), align: .left, attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): labelFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): labelTextColor])
        }
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        let limitLines = _yAxis.limitLines
        
        if (limitLines.count == 0)
        {
            return
        }
        
        context.saveGState()
        
        let sliceangle = _chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = _chart.factor
        
        let center = _chart.centerOffsets
        
        for l in limitLines
        {
            
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
            
            let r = CGFloat(l.limit - _chart.chartYMin) * factor
            
            context.beginPath()
            
            for j in 0 ..< _chart.data!.xValCount
            {
                let p = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(j) + _chart.rotationAngle)
                
                if (j == 0)
                {
                    context.move(to: CGPoint(x: p.x, y: p.y))
                }
                else
                {
                    context.addLine(to: CGPoint(x: p.x, y: p.y))
                }
            }
            
            context.closePath()
            
            context.strokePath()
        }
        
        context.restoreGState()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
