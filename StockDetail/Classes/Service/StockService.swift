//
//  StockService.swift
//  quchaogu
//
//  Created by zhangyr on 15/7/3.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockService {
    
    class func doRequest(_ request : BaseRequest!, completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void)) {
        request.completionBlock = completion
        request.failureBlock = failure
        request.doRequest()
    }
    
    class func getMutiStockInfo(_ code : String , completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void)){
        let request = StockMutiInfoRequest(code : code)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func deleteZixuanByCode(_ code : String , completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void)){
        let request = StockDeletePortRequest(code: code)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func addZixuanByCode(_ code : String , completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void)){
        let request = StockAddPortRequest(code: code)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func getStockCurrentInfoWithCode(_ code : String , completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void)) {
        let request = StockGetCurrentInfoRequest(code: code)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func getStockTimeFiveWithCode(_ code : String , completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void)) {
        let request = StockGetTimeFiveRequest(code: code)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func getStockNewsWithId(_ key : String , id : String , newsType : Int , completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void)) {
        let request = StockGetNewsRequest(key: key, id: id, newsType: newsType)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func getNewsListWithParams(_ params : Dictionary<String ,String> , newsType : Int , completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void)) {
        let request = StockNewsListRequest(params: params, newsType: newsType)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func getStockTimeDetailWithCode(_ code : String , completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void)) {
        let request = StockTimeDetailRequest(code: code)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func getStockKLineWithURL(_ params : Dictionary<String , String> , completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void)) {
        let request = StockKLineRequest(params: params)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func getPlateStockList(_ conceptCode : String , page : Int , sort : Int , completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void))
    {
        let request = StockPlateStockRequest(conceptCode: conceptCode, page: page, sort: sort)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func getPlatesNewsWithId(_ code : String , page : Int = 1 , completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void)) {
        let request = StockPlateNewsRequest(code: code , page : page)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func getRelationPlateData(_ code: String, completion : @escaping ((BaseModel?) -> Void), failure : @escaping ((BaseError?) -> Void)) {
        let request = StockRelationPlateRequest(code: code)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func getConceptStockData(_ para: Dictionary<String,String>, completion : @escaping ((BaseModel?) -> Void), failure : @escaping ((BaseError?) -> Void)) {
        let request = StockBKStcokRequest(params: para)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func getStockTopInfo(_ type : String , indexCode : String? = nil , pageCount : Int = 100, completion : @escaping ((BaseModel?) -> Void),failure : @escaping ((BaseError?) -> Void)) {
        let request = StockTopRequest(type: type , indexCode : indexCode , pageCount : pageCount)
        self.doRequest(request, completion: completion, failure: failure)
    }
    
    class func checkStockZxStatus(code: String, completion : @escaping ((BaseModel?) -> Void), failure : @escaping ((BaseError?) -> Void))
    {
        let request = StockZxCheckRequest(code: code)
        self.doRequest(request, completion: completion, failure: failure)
    }
}
