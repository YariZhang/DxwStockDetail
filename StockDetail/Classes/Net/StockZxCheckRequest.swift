//
//  StockZxCheckRequest.swift
//  Dxw
//
//  Created by zhangyr on 2017/8/29.
//  Copyright © 2017年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockZxCheckRequest: BaseRequest {

    required init(code: String) {
        super.init()
        self.addReqParam(key: "code", value: code, isSign: false)
        self.addReqParam(key: "device_id", value: UtilTools.getUniqueDeviceId(), isSign: false)
    }
    
    override func getServerType() -> ServerType {
        return .base
    }
    
    override func getRelativeUrl() -> String? {
        return "dxwapp/zixuan/check"
    }
    
    override func needRequestToast() -> Bool {
        return false
    }
    
}
