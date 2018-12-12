//
//  StockPlateStockRequest.swift
//  TapeMaster
//
//  Created by zhangyr on 16/9/5.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockPlateStockRequest: BaseRequest {

    required init(conceptCode : String , page : Int , sort : Int)
    {
        super.init()
        self.addReqParam(key: "concept_code", value: conceptCode, isSign: false)
        self.addReqParam(key: "sort", value: "\(sort)", isSign: false)
        self.addReqParam(key: "page", value: "\(page)", isSign: false)
        self.addReqParam(key: "pagecount", value: "20", isSign: false)

    }
    
    override func getServerType() -> ServerType
    {
        return ServerType.base
    }
    
    override func getRelativeUrl() -> String?
    {
        return "stock/quotation/conceptstock"
    }
    
    override func needRequestToast() -> Bool {
        return false
    }
}
