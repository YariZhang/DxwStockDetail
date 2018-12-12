//
//  StockUtil.swift
//  StockDetail
//
//  Created by zhangyr on 2018/12/11.
//  Copyright © 2018 zhangyr. All rights reserved.
//

import UIKit
import BasicService

enum StockVolumeType : Int
{
    case volume
    case mainMoney
}


var stockVolumeType : StockVolumeType   = .volume
{
    didSet
    {
        if stockVolumeType != oldValue
        {
            NotificationCenter.default.post(name: NSNotification.Name("StockVolumeTypeChanded"), object: nil, userInfo: ["value" : stockVolumeType])
        }
    }
}

let tabSelectedBgColor                  = Color("#fff")
let tabUnselectedBgColor                = Color("#eef1f2")
let tabSelectedTitleColor               = Color("#333333")
let tabUnselectedTitleColor             = Color("#028fdc")

class StockUtil: NSObject {
    
    class func getRegisterIdForVc(_ vc: AnyClass) -> String {
        guard let plistPath = Bundle(for: self.classForCoder()).path(forResource: "StockVcRegisters", ofType: "plist"), let registers = NSDictionary(contentsOfFile: plistPath) else {
            return "-"
        }
        for (key, value) in registers {
            if (value + "").contains(NSStringFromClass(vc)) {
                return key + ""
            }
        }
        return "-"
    }
    
    class func addStock(code: String) {
        StockService.addZixuanByCode(code, completion: { (bsd) -> Void in
        }, failure: { (error) -> Void in
        })
        Behavior.eventReport("jiaru_zixuan")
        UtilTools.noticError(view: UtilTools.getAppDelegate()?.window ?? nil, msg: "添加成功")
    }
    
    class func deleteStock(code: String) {
        Behavior.eventReport("shanchu_zixuan")
        StockService.deleteZixuanByCode(code, completion: { (bsd) -> Void in
            if bsd!.resultCode! == 10000 {
            }
        }, failure: { (err) -> Void in
        })
        UtilTools.noticError(view: UtilTools.getAppDelegate()?.window ?? nil, msg: "删除成功")
    }
    
}

