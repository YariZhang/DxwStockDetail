//
//  PointInfo.swift
//  TimeChart
//
//  Created by zhangyr on 15/5/12.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit

class PointInfo: NSObject {
    
    //涨跌幅
    var p_change : Float!
    //开盘价
    var openPrice : Float!
    //当前价格
    var currentPrice : Float!
    //成交量(手)
    var dealVol : Float!
    //颜色
    var volColor : UIColor?
    var volStr : String?
    //成交量(金额)
    var dealAmount : CGFloat!
    //起始点
    var startPoint : CGPoint!
    //结束点
    var endPoint : CGPoint!
    //分钟数据
    var min : String = "" {
        
        didSet {
            if min.count >= 3 {
                min.insert(":", at: min.characters.index(min.startIndex, offsetBy: min.count - 2))
            }
        }
    }
   
}
