//
//  StockBKStcokRequest.swift
//  Subject
//
//  Created by zhangyr on 2016/12/1.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockBKStcokRequest: BaseRequest {

    required init(params: Dictionary<String,String>) {
        super.init()
        self.addReqParam(params, isSign: false)
    }
    
    override func getServerType() -> ServerType {
        return .base
    }
    
    override func getRelativeUrl() -> String {
        return "app/bankuai/stock"
    }
    
    override func getRequestVersion() -> String {
        return "1.3"
    }
    
    override func needRequestToast() -> Bool {
        return false
    }
    
    override func decodeJsonRequestData(responseDic: Dictionary<String, Any>?) -> BaseModel? {
        let stockData                                   = StockBKStockData()
        stockData.resultCode                            = responseDic?["code"] as? NSNumber
        stockData.errorMsg                              = responseDic?["msg"] + ""
        let data                                        = responseDic?["data"]
        stockData.resultData                            = data as AnyObject
        
        if let tmpData = data as? Dictionary<String,Any> {
            
            if let hl = tmpData["headList"] as? Array<Dictionary<String,AnyObject>> {
                stockData.headList = hl
            }
            if let sl = tmpData["stock_list"] as? Array<Dictionary<String,AnyObject>> {
                stockData.stockList = sl
            }
            if let bk = tmpData["bk_info"] as? Dictionary<String,AnyObject> {
                stockData.bkInfo = bk
            }
        }
        return stockData
    }
    
}
