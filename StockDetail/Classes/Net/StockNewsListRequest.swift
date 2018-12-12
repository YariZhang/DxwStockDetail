//
//  StockNewsListRequest.swift
//  quchaogu
//
//  Created by zhangyr on 15/7/19.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockNewsListRequest: BaseRequest {
   
    fileprivate var newsType : Int!
    
    required init(params : Dictionary<String , String> , newsType : Int)
    {
        super.init()
        self.newsType     = newsType
        self.isPostMethod = false
        self.addReqParam(params, isSign: false)
        self.addReqParam(key: "device_id", value: UtilTools.getUniqueDeviceId(), isSign: false)
        self.addReqParam(key: "pagecount", value: "10", isSign: false)
    }
    
    override func getServerType() -> ServerType
    {
        return ServerType.base
    }
    
    override func getRelativeUrl() -> String?
    {
        switch newsType {
        case 0 :
            return "stock/news/list"
        case 1 :
            return "stock/announcement/list"
        default :
            return "stock/report/listv2"
        }
    }
    
    override func getRequestVersion() -> String {
        return "1.2"
    }

    override func needRequestToast() -> Bool {
        return false
    }
    
    override func decodeJsonRequestData(responseDic: Dictionary<String, Any>?) -> BaseModel? {
        if newsType == 2 {
            let tmp                            = BaseModel()
            tmp.resultCode                     = responseDic?["code"] as? NSNumber
            tmp.errorMsg                       = responseDic?["msg"] as? String
            if let data = responseDic?["data"] as? Dictionary<String ,Any> {
                if let list = data["report_list"] as? Array<Any> {
                    tmp.resultData             = list as AnyObject
                }
            }
            return tmp
        }else{
            return super.decodeJsonRequestData(responseDic: responseDic)
        }
    }
    
}
