//
//  StockKLineRequest.swift
//  quchaogu
//
//  Created by zhangyr on 15/7/19.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockKLineRequest: BaseRequest {
    
    required init(params : Dictionary<String , String>)
    {
        super.init()
        self.isPostMethod = false
        self.self.addReqParam(params, isSign: false)
    }
    
    override func getServerType() -> ServerType
    {
        return ServerType.base
    }
    
    override func getRelativeUrl() -> String?
    {
        return "stock/kline"
    }
    
    override func getRequestVersion() -> String {
        return "1.3"
    }
    
    override func needRequestToast() -> Bool {
        return false
    }
    
    override func decodeJsonRequestData(responseDic: Dictionary<String, Any>?) -> BaseModel? {
        let klineData : KLineJsonData           = KLineJsonData()
        klineData.resultCode                    = responseDic?["code"] as? NSNumber
        klineData.errorMsg                      = responseDic?["msg"] as? String
        klineData.resultData                    = responseDic?["data"] as AnyObject
        
        if let sData = klineData.resultData as? Dictionary<String, AnyObject>
        {
            klineData.dataVersion = sData["data_version"] + ""
            klineData.needReset = sData["need_reset"] + "" == "1"
            if let data = sData["list"] as? Array<Dictionary<String, AnyObject>> {
                var klines = Array<KLineData>()
                if data.count > 0
                {
                    for temp in data {
                        let line          = KLineData()
                        line.high         = NSNumber(value: Double(((temp["high"] + "") as NSString).floatValue))
                        line.low          = NSNumber(value: Double(((temp["low"] + "") as NSString).floatValue))
                        line.open         = NSNumber(value: Double(((temp["open"] + "") as NSString).floatValue))
                        line.close        = NSNumber(value: Double(((temp["close"] + "") as NSString).floatValue))
                        let date          = temp["date"] + ""
                        line.date         = UtilDate.convertFormatByDate("yyyyMMdd", date_time: date, toFormat: "yyyy-MM-dd")
                        line.price_change = NSNumber(value: Double(((temp["price_change"] + "") as NSString).floatValue))
                        line.p_change     = NSNumber(value: Double(((temp["p_change"] + "") as NSString).floatValue))
                        line.volume       = NSNumber(value: Double(((temp["volume"] + "") as NSString).floatValue))
                        line.turnover     = NSNumber(value: Double(((temp["turnover"] + "") as NSString).floatValue))
                        line.ma5          = NSNumber(value: Double(((temp["ma5"] + "") as NSString).floatValue))
                        line.ma10         = NSNumber(value: Double(((temp["ma10"] + "") as NSString).floatValue))
                        line.ma20         = NSNumber(value: Double(((temp["ma20"] + "") as NSString).floatValue))
                        line.v_ma5        = NSNumber(value: Double(((temp["v_ma5"] + "") as NSString).floatValue))
                        line.v_ma10       = NSNumber(value: Double(((temp["v_ma10"] + "") as NSString).floatValue))
                        line.v_ma20       = NSNumber(value: Double(((temp["v_ma20"] + "") as NSString).floatValue))
                        line.main_amount  = NSNumber(value: Double(((temp["main_net_amount"] + "") as NSString).floatValue))
                        line.main_percent = temp["main_net_percent"] + ""
                        klines.append(line)
                    }
                    klineData.klineList = klines
                }
            }
        }
        
        return klineData
    }
}
