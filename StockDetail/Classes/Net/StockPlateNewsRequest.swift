//
//  StockPlateNewsRequest.swift
//  Subject
//
//  Created by zhangyr on 16/9/12.
//  Copyright © 2016年 quchaogu. All rights reserved.
//  app/bankuai/news

import UIKit
import BasicService

class StockPlateNewsRequest: BaseRequest {
    
    fileprivate var isHY    : Bool  = false
    
    required init(code : String , page : Int)
    {
        super.init()
        isHY              = code.hasPrefix("HY")
        self.isPostMethod = false
        self.addReqParam(key: "code", value: code, isSign: false)
        self.addReqParam(key: "page", value: "\(page)", isSign: false)
        self.addReqParam(key: "pagecount", value: "10", isSign: false)
        self.addReqParam(key: "device_id", value: UtilTools.getUniqueDeviceId(), isSign: false)
    }
    
    override func getServerType() -> ServerType
    {
        return ServerType.base
    }
    
    override func getRelativeUrl() -> String?
    {
        return "app/bankuai/news"
    }
    
    override func getRequestVersion() -> String {
        if isHY {
            return "1.0"
        }
        return "1.2"
    }
    
    override func needRequestToast() -> Bool {
        return false
    }
    
    override func decodeJsonRequestData(responseDic: Dictionary<String, Any>?) -> BaseModel? {
        if isHY {
            return super.decodeJsonRequestData(responseDic: responseDic)
        }
        let newsData                                = StockPlateNewsData()
        newsData.resultCode                         = responseDic?["code"] as? NSNumber
        newsData.errorMsg                           = responseDic?["msg"] + ""
        let data                                    = responseDic?["data"]
        newsData.resultData                         = data as AnyObject
        
        if let list = data as? Array<Dictionary<String , Any>> {
            for l in list {
                let item                            = StockPlateNewsItemData()
                item.pubdate                        = l["pubdate"] + ""
                item.title                          = l["title"] + ""
                item.content                        = l["content"] + ""
                item.type                           = l["type"] + ""
                item.url                            = l["url"] + ""
                if let stocks = l["stocks"] as? Array<Dictionary<String,AnyObject>> {
                    for s in stocks {
                        let stockInfo       = MainStockCardData()
                        stockInfo.stockName = s["name"] + ""
                        stockInfo.stockCode = s["code"] + ""
                        stockInfo.rate      = s["rate"] + ""
                        item.stocks.append(stockInfo)
                    }
                }
                newsData.list.append(item)
            }
        }
        return newsData
    }
}
