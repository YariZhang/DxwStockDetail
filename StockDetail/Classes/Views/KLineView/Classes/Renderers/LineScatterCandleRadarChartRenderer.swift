//
//  LineScatterCandleRadarChartRenderer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 29/7/15.
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

open class LineScatterCandleRadarChartRenderer: ChartDataRendererBase
{
    public override init(animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
    }
    
    /// Draws vertical & horizontal highlight-lines if enabled.
    /// - parameter context:
    /// - parameter points:
    /// - parameter horizontal:
    /// - parameter vertical:
    open func drawHighlightLines(context: CGContext, points: [CGPoint], horizontal: Bool, vertical: Bool)
    {
        // draw vertical highlight lines
        if vertical
        {
            //6
            context.strokeLineSegments(between: points)
        }
        
        // draw horizontal highlight lines
        if horizontal
        {
            //2,2
            context.strokeLineSegments(between: points)
        }
    }
}
