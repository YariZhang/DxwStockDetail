//
//  ChartRendererBase.swift
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

open class ChartRendererBase: NSObject
{
    /// the component that handles the drawing area of the chart and it's offsets
    open var viewPortHandler: ChartViewPortHandler!
    
    /// max volume
    
    open var maxVolume : Double = 0
    
    open var maxMainVolume  : Double    = 0
    open var maxMainPercent : String    = "0.00%"
    open var minMainVolume  : Double    = 0
    
    /// the minimum value on the x-axis that should be plotted
    open var minX: Int {
        get {
            return _minX
        }
        set {
            _minX = newValue
        }
    }
    
    /// the maximum value on the x-axis that should be plotted
    open var maxX: Int {
        get {
            return _maxX
        }
        set {
            _maxX = newValue
        }
    }
    
    /// the minimum value on the x-axis that should be plotted
    internal var _minX: Int = 0
    
    /// the maximum value on the x-axis that should be plotted
    internal var _maxX: Int = 0
    
    public override init()
    {
        super.init()
    }
    
    public init(viewPortHandler: ChartViewPortHandler)
    {
        super.init()
        self.viewPortHandler = viewPortHandler
    }

    /// Returns true if the specified value fits in between the provided min and max bounds, false if not.
    internal func fitsBounds(_ val: Double, min: Double, max: Double) -> Bool
    {
        if (val < min || val > max)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    /// Calculates the minimum and maximum x-value the chart can currently display (with the given zoom level).
    open func calcXBounds(chart: BarLineChartViewBase, xAxisModulus: Int)
    {
        let low = chart.lowestVisibleXIndex
        let high = chart.highestVisibleXIndex
        
        let subLow = (low % xAxisModulus == 0) ? xAxisModulus : 0
        
        _minX = max((low / xAxisModulus) * (xAxisModulus) - subLow, 0)
        _maxX = min((high / xAxisModulus) * (xAxisModulus) + xAxisModulus, Int(chart.chartXMax))
    }
}
        
