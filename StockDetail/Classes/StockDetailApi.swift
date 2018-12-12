//
//  StockDetailApi.swift
//  StockDetail
//
//  Created by zhangyr on 2018/12/12.
//  Copyright © 2018 zhangyr. All rights reserved.
//

import UIKit

open class StockDetailApi: NSObject {
    
    public class func stockVcRegister() -> String? {
        guard let plistPath = Bundle(for: self.classForCoder()).path(forResource: "StockVcRegisters", ofType: "plist") else {
            return nil
        }
        return plistPath
    }
    
    public class func setStockNeedRefresh(_ need: Bool) {
        glStockNeedRefresh = need
    }
    
    public class func setStockRefreshPeroid(_ peroid: Double) {
        glStockNetRefreshPeriod = peroid
    }
    
}
