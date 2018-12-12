//
//  KLineJsonData.swift
//  quchaogu
//
//  Created by zhangyr on 15/9/15.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class KLineJsonData: BaseModel {
    var dataVersion : String    = ""
    var needReset   : Bool      = false
    var klineList   : Array<KLineData>!
}
