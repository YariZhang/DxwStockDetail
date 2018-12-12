//
//  StockGetTimeFiveRequest.swift
//  quchaogu
//
//  Created by zhangyr on 15/7/19.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockGetTimeFiveRequest: BaseRequest {
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
        return "stock/multimin"
    }
    
    override func needRequestToast() -> Bool {
        return false
    }
}
