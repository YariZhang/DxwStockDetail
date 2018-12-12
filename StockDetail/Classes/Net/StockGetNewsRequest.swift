//
//  StockGetNewsRequest.swift
//  quchaogu
//
//  Created by zhangyr on 15/7/19.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockGetNewsRequest: BaseRequest {
    //新闻类型： 0 新闻 1 公告 2 研报
    fileprivate var newsType : Int!
    
    required init(key : String , id : String , newsType : Int)
    {
        super.init()
        self.newsType = newsType
        self.isPostMethod = false
        self.addReqParam(key: key, value: id, isSign: false)
    }
    
    override func getServerType() -> ServerType
    {
        return ServerType.base
    }
    
    override func getRelativeUrl() -> String?
    {
        switch newsType {
        case 0 :
            return "stock/news/detail"
        case 1 :
            return "stock/announcement/detail"
        default :
            return "stock/report/detail"
        }
    }
    
}
