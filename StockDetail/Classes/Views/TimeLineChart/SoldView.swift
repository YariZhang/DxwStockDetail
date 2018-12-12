//
//  SoldView.swift
//  Portfilio
//
//  Created by zhangyr on 15/5/15.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

var SOLD_VIEW_WIDTH : CGFloat! = 0
var SOLD_VIEW_HEIGHT : CGFloat! = 0

protocol SoldViewDelegate : NSObjectProtocol {
    func soldViewTapAction()
}

class SoldView: UITableView,UITableViewDataSource,UITableViewDelegate {
    
    var open : Float!
    var datas : NSArray!
    var isLand : Bool = false
    var dataType : Int! = 1
    fileprivate weak var tapDelegate : SoldViewDelegate!
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }

    init(frame: CGRect , tapDelegate : SoldViewDelegate) {
        super.init(frame: frame, style: UITableView.Style.plain)
        self.tapDelegate                  = tapDelegate
        SOLD_VIEW_WIDTH                   = frame.size.width
        SOLD_VIEW_HEIGHT                  = frame.height / 11
        self.dataSource                   = self
        self.delegate                     = self
        self.backgroundColor              = Color("#fff")
        self.showsVerticalScrollIndicator = false
        self.separatorStyle               = UITableViewCell.SeparatorStyle.none
        self.register(SoldViewCell.self, forCellReuseIdentifier: "sellCell")
        let tapGr                         = UITapGestureRecognizer(target: self, action: #selector(SoldView.tapAction))
        self.addGestureRecognizer(tapGr)
    }
    
    override func numberOfRows(inSection section: Int) -> Int {
        SOLD_VIEW_WIDTH  = frame.size.width
        SOLD_VIEW_HEIGHT = frame.height / 11
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataType == 1 {
            self.isScrollEnabled = false
        }else{
            self.isScrollEnabled = true
        }
        return datas == nil ? 0 : datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sellCell", for: indexPath) as! SoldViewCell
        switch dataType {
        case 1 :
            let tempStr : AnyObject? = datas.object(at: (indexPath as NSIndexPath).row) as AnyObject?
            cell.dataStr  = NSString(string : tempStr + "")
            cell.open     = open
        case 2 :
            let dic       = datas[(indexPath as NSIndexPath).row] as! NSDictionary
            let min       = dic.object(forKey: "time") + ""
            let price     = dic.object(forKey: "price") + ""
            let bs_volume = dic.object(forKey: "volume") + ""
            let type      = dic.object(forKey: "type") + ""
            let tmpS      = min + "," + price + "," + bs_volume + "," + type
            cell.dataStr  = NSString(string: tmpS)
        default :
            logPrint("")
        }
        
        cell.infoType = dataType
        cell.isLand = isLand
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.dataType == 2 {
            return tableView.bounds.height / 11
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.dataType == 2 {
            let v             = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height  / 11))
            v.backgroundColor = Color("#f9f9f9")
            let tl            = HintLabel(frame: CGRect(x: 0, y: 0, width: v.bounds.width / 3, height: v.bounds.height), alignment: NSTextAlignment.center, title: "时间", toView: v)
            let vpl           = HintLabel(frame: CGRect(x: tl.frame.maxX, y: 0, width: v.bounds.width / 3, height: v.bounds.height), alignment: NSTextAlignment.center, title: "成交价", toView: v)
            let _            = HintLabel(frame: CGRect(x: vpl.frame.maxX, y: 0, width: v.bounds.width / 3, height: v.bounds.height), alignment: NSTextAlignment.right, title: "成交量", toView: v)
            return v
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height  / 11
    }
    
    @objc func tapAction() {
        tapDelegate.soldViewTapAction()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SoldViewCell : UITableViewCell {
    fileprivate var leftInfo : UILabel!
    fileprivate var midInfo : UILabel!
    fileprivate var rightInfo : UILabel!
    var infoType : Int          = 1
    var isLand : Bool           = false
    var open : Float            = 0.0
    var dataStr : NSString!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.backgroundColor = Color("#fff")
        
        leftInfo = UILabel(frame: CGRect(x: 5, y: 0, width: SOLD_VIEW_WIDTH, height: SOLD_VIEW_HEIGHT))
        leftInfo.textAlignment = NSTextAlignment.left
        midInfo = UILabel(frame: CGRect(x: 0, y: 0, width: SOLD_VIEW_WIDTH, height: SOLD_VIEW_HEIGHT))
        midInfo.textAlignment = NSTextAlignment.center
        rightInfo = UILabel(frame: CGRect(x: 0, y: 0, width: SOLD_VIEW_WIDTH - 5, height: SOLD_VIEW_HEIGHT))
        rightInfo.textAlignment = NSTextAlignment.right
        
        self.addSubview(leftInfo)
        self.addSubview(midInfo)
        self.addSubview(rightInfo)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if dataStr == nil {
            return
        }
        
        var size : CGFloat!
        if isLand {
            size = 12
        }else{
            size = 10
        }
        leftInfo.font = UIFont.normalFontOfSize(size)
        midInfo.font = UIFont.normalFontOfSize(size)
        rightInfo.font = UIFont.normalFontOfSize(size)
        leftInfo.textColor = UtilColor.getHintLabelColor()
        midInfo.textColor = UtilColor.getTextBlackColor()
        rightInfo.textColor = UtilColor.getTextBlackColor()
        let arr = dataStr.components(separatedBy: ",")
        switch infoType {
        case 1:
            if arr.count == 3 {
                self.backgroundColor = Color(COLOR_COMMON_WHITE)
                leftInfo.text = arr[0] as String
                midInfo.text = arr[1] as String
                rightInfo.text = arr[2] as String
                if NSString(string: midInfo.text!).floatValue < 1 {
                    midInfo.text = "--"
                    rightInfo.text = "--"
                }else if NSString(string: midInfo.text!).floatValue > open {
                    midInfo.textColor = UtilColor.getRedTextColor()
                }else if NSString(string: midInfo.text!).floatValue == open {
                    midInfo.textColor = UtilColor.getTextBlackColor()
                }else{
                    midInfo.textColor = UtilColor.getGreenColor()
                }
            }else{
                self.backgroundColor = Color("#fafafa")
                leftInfo.text = ""
                midInfo.text = dataStr as String
                rightInfo.text = ""
            }
        case 2:
            //println("明细")
            var minTime = arr[0] 
            if minTime.count == 5 {
                minTime = "0" + minTime
            }
            leftInfo.text = UtilDate.convertFormatByDate("HHmmss", date_time: minTime, toFormat: "HH:mm")
            midInfo.text = arr[1] as String
            let count = Int((arr[2] ))! / 100
            if count >= 100_000 {
                rightInfo.text = "\(count / 10000)万"
            }else{
                rightInfo.text = "\(count)"
            }
            
            let type = Int((arr[3] ))!
            if type == 2 {
                rightInfo.textColor = UtilColor.getGreenColor()
            }else if type == 1 {
                rightInfo.textColor = UtilColor.getRedTextColor()
            }else{
                rightInfo.textColor = UtilColor.getTextBlackColor()
            }
        default:
            logPrint("分价")
        }
    }
    
    
    
    
    
}
