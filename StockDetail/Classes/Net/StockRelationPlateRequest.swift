//
//  StockRelationPlateRequest.swift
//  Subject
//
//  Created by zhangyr on 2016/11/29.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockRelationPlateRequest: BaseRequest {
    
    required init(code : String)
    {
        super.init()
        self.isPostMethod = false
        self.addReqParam(key: "code", value: code, isSign: false)
    }
    
    override func getServerType() -> ServerType
    {
        return ServerType.base
    }
    
    override func getRelativeUrl() -> String?
    {
        return "app/subject/bankuai"
    }
    
    override func getRequestVersion() -> String {
        return "1.0"
    }
    
    override func needRequestToast() -> Bool {
        return false
    }
    
    override func decodeJsonRequestData(responseDic: Dictionary<String, Any>?) -> BaseModel? {
        let relationData                                = StockRelationPlateData()
        relationData.resultCode                         = responseDic?["code"] as? NSNumber
        relationData.errorMsg                           = responseDic?["msg"] + ""
        let data                                        = responseDic?["data"]
        relationData.resultData                         = data as AnyObject
        
        if let tmp = data as? Dictionary<String,Any> {
            relationData.text = tmp["text"] + ""
            
            if let list = tmp["bk_list"] as? Array<Dictionary<String,AnyObject>> {
                relationData.list = list
            }
        }
        return relationData
    }
    
}
