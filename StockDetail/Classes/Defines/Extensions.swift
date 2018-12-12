//
//  Extensions.swift
//  StockDetail
//
//  Created by zhangyr on 2018/12/10.
//  Copyright © 2018 zhangyr. All rights reserved.
//

import UIKit
import BasicService
import MJRefresh
import Toast

extension UtilCheck {
    //检测当前是否是开盘时间
    //未开盘 1
    //交易中 2
    //午间休市 3
    //已收盘 4
    class func isDealTime() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.hour, .minute], from: date)
        let hour = components.hour
        let min = components.minute
        if hour! >= 9 && hour! <= 11 {
            if (hour! == 9 && min! < 30) || (hour! == 11 && min! > 30) {
                if hour! == 9 && min! < 30 {
                    return 1
                }else{
                    return 3
                }
            }
            return 2
        }else if hour! >= 13 && hour! <= 14 {
            return 2
        }else if hour! >= 0 && hour! < 9{
            return 1
        }else{
            return 4
        }
    }
}

extension UtilTools {
    
    //格式化数值信息
    class func formatTotalAmount(_ price : CGFloat) -> String {
        var newPrice : CGFloat = 0
        var moneyUnit = "万"
        if price > 10_000 {
            newPrice = price / 10_000
        }else{
            newPrice = price
            moneyUnit = ""
        }
        
        if price > 100_000_000 {
            newPrice = price / 100_000_000
            moneyUnit = "亿"
        }
        
        var newStr : NSString!
        if newPrice >= 1000 {
            newStr = NSString(format: "%.0f%@", newPrice , moneyUnit)
        }else if newPrice >= 100 {
            newStr = NSString(format: "%.1f%@", newPrice , moneyUnit)
        }else{
            newStr = NSString(format: "%.2f%@", newPrice , moneyUnit)
        }
        
        return newStr as String
    }
    
    //友好提示不合法操作 view为所要提醒显示试图 msg为提示内容,complete拖尾闭包可选,显示完信息之后做的事
    class func noticError (view : UIView! ,msg : String ,offset : CGFloat = 0, time : Double = 0.5, complete:@escaping () -> Void = {}) {
        guard view != nil else {
            return
        }
        view.makeToast(msg)
        complete()
    }
    
}

extension MJRefreshGifHeader {
    
    convenience init(headerRefreshingBlock: @escaping () -> Void) {
        self.init(refreshingBlock: headerRefreshingBlock)
        self.setImages(nil, for: .idle)
        //self.setImages([UIImage(named: "loding01")!, UIImage(named: "loding02")!, UIImage(named: "loding03")!], for: .refreshing)
        self.setImages(nil, for: .pulling)
        self.lastUpdatedTimeLabel.isHidden = true
        self.setTitle("下拉刷新", for: .idle)
        self.setTitle("松开刷新", for: .pulling)
        self.setTitle("刷新中···", for: .refreshing)
        self.stateLabel.font = UIFont.normalFontOfSize(12)
        self.stateLabel.textColor = HexColor(COLOR_COMMON_BLACK_3)
    }
    
}

extension MJRefreshBackGifFooter {
    
    convenience init(footerRefreshingBlock: @escaping () -> Void) {
        self.init(refreshingBlock: footerRefreshingBlock)
        self.setImages(nil, for: .idle)
        //self.setImages([UIImage(named: "loding01")!, UIImage(named: "loding02")!, UIImage(named: "loding03")!], for: .refreshing)
        self.setImages(nil, for: .pulling)
        self.setTitle("下拉刷新", for: .idle)
        self.setTitle("松开刷新", for: .pulling)
        self.setTitle("加载中···", for: .refreshing)
        self.stateLabel.font = UIFont.normalFontOfSize(12)
        self.stateLabel.textColor = HexColor(COLOR_COMMON_BLACK_3)
    }
    
}

class UtilColor: NSObject {
    
    //蓝色字体颜色
    class func getBlueColor() -> UIColor {
        return Color("#049de4")
    }
    //灰色字体颜色
    class func getHintLabelColor() -> UIColor {
        return Color("#999999")
    }
    //股票红色
    class func getRedStockColor() -> UIColor {
        return Color("#ff524f")
    }
    //股票绿色
    class func getGreenStockColor() -> UIColor {
        return Color("#15af3d")
    }
    //深绿色，股票跌时背景色
    class func getGreenColor() -> UIColor {
        return Color("#15af3d")
    }
    //黑色字体颜色
    class func getTextBlackColor() -> UIColor {
        return Color("#333")
    }
    //cell选中色
    class func getSeletedCellColor() -> UIColor {
        return Color("#f9f9f9")
    }
    //navigationBar的颜色
    class func getNaviBarColor() -> UIColor {
        return Color("#2e303f")
    }
    //股票K线图的边框色
    class func getKLineMainBordColor() -> UIColor {
        return Color("#ebebeb")
    }
    //股票K线标签颜色
    class func getKLineLabelColor() -> UIColor {
        return Color("#333333")
    }
    //股票MA10颜色
    class func getKLineMA10Color() -> UIColor {
        return Color("#FF9900")
    }
    //股票MA20颜色
    class func getKLineMA20Color() -> UIColor {
        return Color("#FF00FF")
    }
    //分时图下方阴影
    class func getTimeLineShadowColor() -> UIColor {
        return UIColor.clear
    }
    //view的背景灰色
    class func getTableBackgroundColor() -> UIColor {
        return Color("#2e303f")
    }
    
    
    //-------1.0搬过来的代码中用到的一些color-----
    //view controller 背景色
    class func getVcBackgroundColor() -> UIColor {
        return Color("#eeeeee")
    }
    
    class func getCellButtonColor() ->UIColor {
        return Color("#757575")
    }
    
    //按钮未选中颜色
    class func getButtonNoSelected() -> UIColor {
        return Color("#f5f5f5")
    }
    
    //蓝色
    class func getBlueTextColor() -> UIColor {
        return Color("#049de4")
    }
    
    //红色
    class func getRedTextColor() -> UIColor {
        return Color("#ff524f")
    }
    
    
    //红色button的颜色
    class func getButtonRedColor() -> UIColor {
        return Color("#ff524f")
    }
    
    
    //借款背景色
    class func getPeiziBackgroundColor() -> UIColor {
        return UIColor.white
    }
    
    //警告框字体颜色
    class func getAlertTextColor() -> UIColor {
        return Color("#ee7621")
    }
    
    //借款边框
    class func getPeiziBorderColor() -> UIColor {
        return Color("#fdc48d")
    }
    
    /// 头部背景渐变色的from
    class func getTableHeadBgFromColor()  -> UIColor
    {
        return Color("#ed6631")
    }
    /// 头部背景渐变色的to
    class func getTableHeadBgToColor()  -> UIColor
    {
        return Color("#db4848")
    }
    
}

//Any转String
func +(left : Any?, right : String) -> String {
    return left == nil ? "" : "\(left!)" + right
}

public extension UINavigationController {
    
    func pushStockDetailController(_ stockInfo : Dictionary<String , AnyObject> , animated : Bool) {
        let code = stockInfo["code"] + ""
        if code.isEmpty {
            return
        }
        var desVc : UIViewController!
        if let _ = Int(code) {
            let stockDetail = StockSingleDetailController(parameters: stockInfo)
            desVc = stockDetail
        }else if code.hasPrefix("HY") || code.hasPrefix("GN") || code.hasPrefix("bk") {
            if code.hasPrefix("HY") {
                let industryVc  = StockIndustryViewController(parameters: stockInfo)
                desVc           = industryVc
            }else{
                let plateDetail = StockConceptDetailController(parameters: stockInfo)
                desVc = plateDetail
            }
        }else{
            let marketDetail = StockMarketViewController(parameters: stockInfo)
            desVc = marketDetail
        }
        self.pushViewController(desVc, animated: animated)
    }
}

enum ParseNumberType : Int {
    case int = 1
    case float
}

extension NSDictionary {
    
    func parseNumber(_ key : String , numberType : ParseNumberType) -> AnyObject {
        let obj: AnyObject? = self.object(forKey: key) as AnyObject?
        var val : AnyObject = 0 as AnyObject
        if obj is NSString {
            if numberType == ParseNumberType.int {
                val = (obj as! NSString).integerValue as AnyObject
            }else if numberType == ParseNumberType.float {
                val = (obj as! NSString).floatValue as AnyObject
            }
        }else if obj is NSNumber {
            if numberType == ParseNumberType.int {
                val = (obj as! NSNumber).intValue as AnyObject
            }else if numberType == ParseNumberType.float {
                val = (obj as! NSNumber).floatValue as AnyObject
            }
        }else if obj is Int {
            val = obj!
        }else if obj is Float {
            val = obj!
        }else{
            
            val = NSNumber(value: 0)
            //println(obj)
        }
        return val
    }
}
