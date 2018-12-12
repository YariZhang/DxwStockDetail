//
//  ChartXAxisRendererRadarChart.swift
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

open class ChartXAxisRendererRadarChart: ChartXAxisRenderer
{
    fileprivate weak var _chart: RadarChartView!
    
    public init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, chart: RadarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: nil)
        
        _chart = chart
    }
    
    open override func renderAxisLabels(context: CGContext)
    {
        if (!_xAxis.isEnabled || !_xAxis.isDrawLabelsEnabled)
        {
            return
        }
        
        let labelFont = _xAxis.labelFont
        let labelTextColor = _xAxis.labelTextColor
        
        let sliceangle = _chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = _chart.factor
        
        let center = _chart.centerOffsets
        
        for i in 0 ..< _xAxis.values.count
        {
            let text = _xAxis.values[i]
            
            if (text == nil)
            {
                continue
            }
            
            let angle = (sliceangle * CGFloat(i) + _chart.rotationAngle).truncatingRemainder(dividingBy: 360.0)
            
            let p = ChartUtils.getPosition(center: center, dist: CGFloat(_chart.yRange) * factor + _xAxis.labelWidth / 2.0, angle: angle)
            
            ChartUtils.drawText(context: context, text: text!, point: CGPoint(x: p.x, y: p.y - _xAxis.labelHeight / 2.0), align: .center, attributes: [convertFromNSAttributedStringKey(NSAttributedString.Key.font): labelFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): labelTextColor])
        }
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        /// XAxis LimitLines on RadarChart not yet supported.
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
