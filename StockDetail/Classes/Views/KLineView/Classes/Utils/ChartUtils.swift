//
//  Utils.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit
import Darwin

internal class ChartUtils
{
    internal struct Math
    {
        internal static let FDEG2RAD = CGFloat(M_PI / 180.0)
        internal static let FRAD2DEG = CGFloat(180.0 / M_PI)
        internal static let DEG2RAD = M_PI / 180.0
        internal static let RAD2DEG = 180.0 / M_PI
    }
    
    internal class func roundToNextSignificant(number: Double) -> Double
    {
        if (number.isInfinite || number.isNaN || number == 0)
        {
            return number
        }
        
        let d = ceil(log10(number < 0.0 ? -number : number))
        let pw = 1 - Int(d)
        let magnitude = pow(Double(10.0), Double(pw))
        let shifted = round(number * magnitude)
        return shifted / magnitude
    }
    
    internal class func decimals(_ number: Double) -> Int
    {
        if (number == 0.0)
        {
            return 0
        }
        
        let i = roundToNextSignificant(number: Double(number))
        return Int(ceil(-log10(i))) + 2
    }
    
    internal class func nextUp(_ number: Double) -> Double
    {
        if (number.isInfinite || number.isNaN)
        {
            return number
        }
        else
        {
            return number + DBL_EPSILON
        }
    }

    /// Returns the index of the DataSet that contains the closest value on the y-axis. This will return -Integer.MAX_VALUE if failure.
    internal class func closestDataSetIndex(_ valsAtIndex: [ChartSelectionDetail], value: Double, axis: ChartYAxis.AxisDependency?) -> Int
    {
        var index = -Int.max
        var distance = DBL_MAX
        
        for i in 0 ..< valsAtIndex.count
        {
            let sel = valsAtIndex[i]
            
            if (axis == nil || sel.dataSet?.axisDependency == axis)
            {
                let cdistance = abs(sel.value - value)
                if (cdistance < distance)
                {
                    index = valsAtIndex[i].dataSetIndex
                    distance = cdistance
                }
            }
        }
        
        return index
    }
    
    /// Returns the minimum distance from a touch-y-value (in pixels) to the closest y-value (in pixels) that is displayed in the chart.
    internal class func getMinimumDistance(_ valsAtIndex: [ChartSelectionDetail], val: Double, axis: ChartYAxis.AxisDependency) -> Double
    {
        var distance = DBL_MAX
        
        for i in 0 ..< valsAtIndex.count
        {
            let sel = valsAtIndex[i]
            
            if (sel.dataSet!.axisDependency == axis)
            {
                let cdistance = abs(sel.value - val)
                if (cdistance < distance)
                {
                    distance = cdistance
                }
            }
        }
        
        return distance
    }
    
    /// Calculates the position around a center point, depending on the distance from the center, and the angle of the position around the center.
    internal class func getPosition(center: CGPoint, dist: CGFloat, angle: CGFloat) -> CGPoint
    {
        return CGPoint(
            x: center.x + dist * cos(angle * Math.FDEG2RAD),
            y: center.y + dist * sin(angle * Math.FDEG2RAD)
        )
    }
    
    internal class func drawText(context: CGContext, text: String, point: CGPoint, align: NSTextAlignment, attributes: [String : AnyObject]?)
    {
        var tmpPoint = point
        if (align == .center)
        {
            tmpPoint.x -= text.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attributes)).width / 2.0
        }
        else if (align == .right)
        {
            tmpPoint.x -= text.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attributes)).width
        }
        
        UIGraphicsPushContext(context)
        (text as NSString).draw(at: tmpPoint, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))
        UIGraphicsPopContext()
    }
    
    internal class func drawMultilineText(context: CGContext, text: String, knownTextSize: CGSize, point: CGPoint, align: NSTextAlignment, attributes: [String : AnyObject]?, constrainedToSize: CGSize)
    {
        var rect = CGRect(origin: CGPoint(), size: knownTextSize)
        rect.origin.x += point.x
        rect.origin.y += point.y
        
        if (align == .center)
        {
            rect.origin.x -= rect.size.width / 2.0
        }
        else if (align == .right)
        {
            rect.origin.x -= rect.size.width
        }
        
        UIGraphicsPushContext(context)
        (text as NSString).draw(with: rect, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes), context: nil)
        UIGraphicsPopContext()
    }
    
    internal class func drawMultilineText(context: CGContext, text: String, point: CGPoint, align: NSTextAlignment, attributes: [String : AnyObject]?, constrainedToSize: CGSize)
    {
        let rect = text.boundingRect(with: constrainedToSize, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes), context: nil)
        drawMultilineText(context: context, text: text, knownTextSize: rect.size, point: point, align: align, attributes: attributes, constrainedToSize: constrainedToSize)
    }
    
    /// returns an angle between 0.0 < 360.0 (not less than zero, less than 360)
    internal class func normalizedAngleFromAngle(_ angle: CGFloat) -> CGFloat
    {
        var tmpAngle = angle
        
        while (tmpAngle < 0.0)
        {
            tmpAngle += 360.0
        }
        
        return tmpAngle.truncatingRemainder(dividingBy: 360.0)
    }
    
    
    /// MARK: - Bridging functions
    
    internal class func bridgedObjCGetUIColorArray (swift array: [UIColor?]) -> [NSObject]
    {
        var newArray = [NSObject]()
        for val in array
        {
            if (val == nil)
            {
                newArray.append(NSNull())
            }
            else
            {
                newArray.append(val!)
            }
        }
        return newArray
    }
    
    internal class func bridgedObjCGetUIColorArray (objc array: [NSObject]) -> [UIColor?]
    {
        var newArray = [UIColor?]()
        for object in array
        {
            newArray.append(object as? UIColor)
        }
        return newArray
    }
    
    internal class func bridgedObjCGetStringArray (swift array: [String?]) -> [NSObject]
    {
        var newArray = [NSObject]()
        for val in array
        {
            if (val == nil)
            {
                newArray.append(NSNull())
            }
            else
            {
                newArray.append(val! as NSObject)
            }
        }
        return newArray
    }
    
    internal class func bridgedObjCGetStringArray (objc array: [NSObject]) -> [String?]
    {
        var newArray = [String?]()
        for object in array
        {
            newArray.append(object as? String)
        }
        return newArray
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
