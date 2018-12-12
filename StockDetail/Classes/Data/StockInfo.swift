//
//  StockInfo.swift
//  quchaogu
//
//  Created by zhangyr on 15/8/11.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockInfo: BaseModel {
   
    var stockName        : String = ""
    var stockCode        : String = ""
    var stockPrice       : Float  = 0
    var stockPriceChange : Float  = 0
    var stockPriceRate   : Float  = 0
    var stockZf          : Float  = 0
    var stockChangeRate  : Float  = 0
    var stockIsStop      : Bool   = false
    var stockColor       : UIColor {
        get {
            if stockPriceChange > 0 || stockPriceRate > 0 {
                return UtilColor.getRedTextColor()
            }else if stockPriceChange < 0 || stockPriceRate < 0{
                return UtilColor.getGreenStockColor()
            }else{
                return Color("#333")
            }
        }
    }
}
