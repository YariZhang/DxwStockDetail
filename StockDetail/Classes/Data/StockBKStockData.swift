//
//  StockBKStockData.swift
//  Subject
//
//  Created by zhangyr on 2016/12/1.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockBKStockData: BaseModel {
    var headList : Array<Dictionary<String,AnyObject>> = Array()
    var stockList : Array<Dictionary<String,AnyObject>> = Array()
    var bkInfo : Dictionary<String,AnyObject> = Dictionary()
}
