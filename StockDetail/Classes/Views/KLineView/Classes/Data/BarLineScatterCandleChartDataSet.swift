//
//  BarLineScatterCandleChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit

open class BarLineScatterCandleChartDataSet: ChartDataSet
{
    open var highlightColor = Color("#90a4ae")
    open var highlightLineWidth = CGFloat(0.5)
    open var highlightLineDashPhase = CGFloat(0.0)
    open var highlightLineDashLengths: [CGFloat]?
    
    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! BarLineScatterCandleChartDataSet
        copy.highlightColor = highlightColor
        copy.highlightLineWidth = highlightLineWidth
        copy.highlightLineDashPhase = highlightLineDashPhase
        copy.highlightLineDashLengths = highlightLineDashLengths
        return copy
    }
}
