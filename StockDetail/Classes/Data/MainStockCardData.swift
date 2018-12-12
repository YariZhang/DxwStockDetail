//
//  MainStockCardData.swift
//  Subject
//
//  Created by zhangyr on 16/9/7.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class MainStockCardData: BaseModel {

    var stockName   : String    = ""
    var stockCode   : String    = ""
    var rate        : String    = ""
    var color       : UIColor {
        return rate.hasPrefix("+") ? HexColor(COLOR_COMMON_RED) : rate.hasPrefix("-") ? HexColor(COLOR_COMMON_GREEN) : HexColor(COLOR_COMMON_BLACK_9)
    }
}
