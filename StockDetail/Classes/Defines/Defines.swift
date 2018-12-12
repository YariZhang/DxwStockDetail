//
//  Defines.swift
//  StockDetail
//
//  Created by zhangyr on 2018/12/10.
//  Copyright © 2018 zhangyr. All rights reserved.
//

import UIKit
import BasicService

let COLOR_COMMON_RED = "#ff5243"
let COLOR_COMMON_GREEN = "#15af3d"

var IndexOfStockChart : Int!
var IndexOfMarketChart : Int!
var IndexOfPlateChart : Int!

var IndexOfStockInfo : Int!
var IndexOfMarketInfo : Int!
var IndexOfPlateInfo : Int!

func Color(_ color: String) -> UIColor {
    return HexColor(color)
}

var glStockNeedRefresh: Bool = false
var glStockNetRefreshPeriod: Double = 0

