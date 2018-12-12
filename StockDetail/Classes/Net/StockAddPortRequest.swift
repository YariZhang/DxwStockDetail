//
//  StockAddPortRequest.swift
//  quchaogu
//
//  Created by zhangyr on 15/7/19.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockAddPortRequest: BaseRequest {
   
    required init(code : String)
    {
        super.init()
        self.isPostMethod = true
        self.addReqParam(key: "code", value: code, isSign: false)
        self.addReqParam(key: "device_id", value: UtilTools.getUniqueDeviceId(), isSign: false)
    }
    
    override func getServerType() -> ServerType
    {
        return ServerType.base
    }
    
    override func getRelativeUrl() -> String?
    {
        return "app/zixuan/add"
    }
    
    override func getRequestVersion() -> String
    {
        return "2.0"
        
    }
    
    override func needRequestToast() -> Bool {
        return false
    }
    
}
