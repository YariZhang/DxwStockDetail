//
//  StockTopRequest.swift
//  quchaogu
//
//  Created by zhangyr on 15/8/14.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockTopRequest: BaseRequest {
   
    required init(type : String , indexCode : String? , pageCount : Int)
    {
        super.init()
        self.isPostMethod = false
        self.addReqParam(key: "type", value: type, isSign: false)
        self.addReqParam(key: "page", value: "\(1)", isSign: false)
        self.addReqParam(key: "pagecount", value: "\(pageCount)", isSign: false)
        if indexCode != nil {
            self.addReqParam(key: "indexcode", value: indexCode!, isSign: false)
        }
    }
    
    override func getServerType() -> ServerType
    {
        return ServerType.base
    }
    
    override func getRelativeUrl() -> String?
    {
        return "stock/quotation/ranklist"
    }
    
    override func needRequestToast() -> Bool {
        return false
    }

}
