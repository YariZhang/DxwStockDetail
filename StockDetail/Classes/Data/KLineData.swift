//
//  KLineData.swift
//  KLineView
//
//  Created by zhangyr on 15/8/28.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class KLineData: BaseModel {
    var open         : NSNumber  = 0.0
    var close        : NSNumber  = 0.0
    var high         : NSNumber  = 0.0
    var low          : NSNumber  = 0.0
    var date         : String    = "1970-01-01"
    var price_change : NSNumber  = 0.0
    var p_change     : NSNumber  = 0.0
    var volume       : NSNumber  = 0.0
    var ma5          : NSNumber  = 0.0
    var ma10         : NSNumber  = 0.0
    var ma20         : NSNumber  = 0.0
    var v_ma5        : NSNumber  = 0.0
    var v_ma10       : NSNumber  = 0.0
    var v_ma20       : NSNumber  = 0.0
    var turnover     : NSNumber  = 0.0
    var isFilled     : NSNumber  = false
    var main_amount  : NSNumber  = 0.0
    var main_percent : String    = "0.0%"
}
