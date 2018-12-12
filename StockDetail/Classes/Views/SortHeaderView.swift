//
//  SortHeaderView.swift
//  quchaogu
//
//  Created by zhangyr on 16/7/22.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

protocol SortHeaderViewDelegate : class {
    func sortHeaderViewFilter(_ key : String , options : Array<Dictionary<String , AnyObject>> , currentOrder : String, listTitle : String) -> String?
    func sortHeaderViewSorted(_ key : String , sortDirection : Int)
}

class SortHeaderView: UIView , SortHeaderItemDelegate {

    weak var delegate   : SortHeaderViewDelegate?
    var fontSize        : CGFloat           = 12
    var textColor       : UIColor!          = Color("#999")
    var offset          : CGFloat           = 12
    //显示比例 如2:1:1:1
    var proportion  : String                = "" {
        didSet {
            if !proportion.isEmpty {
                proArray.removeAll()
                let arr                     = proportion.components(separatedBy: ":")
                var total : CGFloat         = 0
                for s in arr {
                    total                  += CGFloat(Double(s)!)
                }
                for s in arr {
                    let num                 = CGFloat(Double(s)!)
                    let res                 = num / total
                    proArray.append(res)
                }
            }
        }
    }
    var attributes       : Array<Dictionary<String,AnyObject>>!
    fileprivate var proArray : Array<CGFloat>   = Array()
    
    func showHeader(_ arr : Array<Dictionary<String,AnyObject>>) {
        
        for v in self.subviews {
            v.removeFromSuperview()
        }
        
        var muti : CGFloat?
        if proportion.isEmpty {
            muti            = 1 / CGFloat(arr.count)
        }
        
        weak var masV   : UIView!
        for i in 0 ..< arr.count {
            let d           = arr[i]
            let key         = d["orderKey"] + ""
            let value       = d["orderValue"] + ""
            let order       = d["order"] + ""
            let current     = d.getNumberForKey("currentOrder").int32Value
            let option      = d["option"] as? Array<Dictionary<String , AnyObject>>
            let item        = SortHeaderItem(canSort: order == "3")
            item.delegate   = self
            item.text       = value
            item.key        = key
            item.options    = option
            item.fontSize   = fontSize
            item.textColor  = textColor
            item.currentFilter = value
            item.listTitle  = d["listTitle"] + ""
            item.tag        = 100 + i
            if i == 0 {
                item.offset = offset
                proportion  = d["ratio"] + ""
            }else if i == arr.count - 1 {
                item.offset = -offset
            }
            item.canTouch   = order == "1" || order == "4"
            item.currentOrder = Int(current)
            self.addSubview(item)
            if !proportion.isEmpty {
                muti            = nil
            }
            item.snp.makeConstraints({ (maker) in
                maker.top.equalTo(self)
                maker.bottom.equalTo(self)
                maker.width.equalTo(self).multipliedBy(muti ?? self.proArray[i])
                if masV != nil {
                    maker.left.equalTo(masV.snp.right)
                }else{
                    maker.left.equalTo(self)
                }
            })
            
            if attributes != nil && i < attributes.count {
                item.setAttributes(attributes[i])
            }
            
            masV            = item
        }
        
        let line                = UIView()
        line.backgroundColor    = Color("#ddd")
        self.addSubview(line)
        line.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.bottom.equalTo(self)
            maker.height.equalTo(0.5)
        }
    }
    
    func headerItemSorted(_ sortItem: SortHeaderItem, sortDirection: Int, key: String) {
        for v in self.subviews {
            if let tv = v as? SortHeaderItem , tv.tag != sortItem.tag {
                tv.setNormalState()
            }
        }
        delegate?.sortHeaderViewSorted(key, sortDirection: sortDirection)
    }
    
    func headerItemFilter(_ sortItem: SortHeaderItem , key : String , options : Array<Dictionary<String , AnyObject>> , currentFilter : String, listTitle : String) -> String? {
        return delegate?.sortHeaderViewFilter(key, options: options , currentOrder: currentFilter, listTitle: listTitle)
    }
    
}

protocol SortHeaderItemDelegate : class {
    func headerItemFilter(_ sortItem : SortHeaderItem , key : String , options : Array<Dictionary<String , AnyObject>> , currentFilter : String, listTitle : String) -> String?
    func headerItemSorted(_ sortItem : SortHeaderItem , sortDirection : Int , key : String)
}

class SortHeaderItem: UIView {
    
    weak var delegate       : SortHeaderItemDelegate?
    
    var text                : String? {
        didSet {
            textLabel.text  = text
        }
    }
    
    var fontSize            : CGFloat = 12 {
        didSet {
            textLabel.font  = UIFont.normalFontOfSize(fontSize , needScale: true)
        }
    }
    
    var textColor           : UIColor! = Color("#999") {
        didSet {
            textLabel.textColor = textColor
        }
    }
    
    var offset              : CGFloat = 0 {
        didSet {
            if offset > 0 {
                textLabel.snp.remakeConstraints { (maker) in
                    maker.left.equalTo(self).offset(self.offset)
                    maker.centerY.equalTo(self)
                }
            }else if offset < 0 {
                if !canSort {
                    textLabel.snp.remakeConstraints { (maker) in
                        maker.right.equalTo(self).offset(self.offset)
                        maker.centerY.equalTo(self)
                    }
                }else{
                    optionImage?.snp.remakeConstraints({ (maker) in
                        maker.right.equalTo(self).offset(self.offset)
                        maker.centerY.equalTo(self)
                    })
                    
                    textLabel.snp.remakeConstraints { (maker) in
                        maker.right.equalTo(self.optionImage!.snp.left).offset(-3)
                        maker.centerY.equalTo(self)
                    }
                }
                
            }
        }
    }
    
    var key                 : String    = ""
    var options             : Array<Dictionary<String , AnyObject>>?
    var canTouch            : Bool      = false {
        didSet {
            if canTouch {
                optionImage             = UIImageView()
                optionImage?.image      = UIImage(named: "lhb_icon_filter")
                self.addSubview(optionImage!)
                
                optionImage?.snp.makeConstraints { (maker) in
                    
                    maker.left.equalTo(self.textLabel.snp.right).offset(3)
                    maker.bottom.equalTo(self.textLabel).offset(-2)
                }
                
                button                  = BaseButton()
                button.addTarget(self, action: #selector(SortHeaderItem.sortAction), for: UIControl.Event.touchUpInside)
                self.addSubview(button)
                
                button.snp.makeConstraints { (maker) in
                    maker.left.equalTo(self)
                    maker.right.equalTo(self)
                    maker.top.equalTo(self)
                    maker.bottom.equalTo(self)
                }
                
                if offset > 0 {
                    textLabel.snp.remakeConstraints { (maker) in
                        maker.left.equalTo(self).offset(self.offset)
                        maker.centerY.equalTo(self)
                    }
                }else if offset < 0 {
                    optionImage?.snp.remakeConstraints({ (maker) in
                        maker.right.equalTo(self).offset(self.offset)
                        maker.centerY.equalTo(self)
                    })
                    
                    textLabel.snp.remakeConstraints { (maker) in
                        maker.right.equalTo(self.optionImage!.snp.left).offset(-3)
                        maker.centerY.equalTo(self)
                    }
                }
            }
        }
    }
    var currentOrder        : Int   = 0 {
        didSet {
            if canSort {
                sortType                = currentOrder
                var imageName           = ""
                switch sortType {
                case 0:
                    imageName           = "ss_image_sort_default"
                case 1:
                    imageName           = "ss_image_sort_desc"
                case 2:
                    imageName           = "ss_image_sort_asc"
                default:
                    break
                }
                optionImage?.image      = UIImage(named: imageName)
            }
        }
    }
    
    var currentFilter       : String    = ""
    var listTitle           : String    = ""
    
    fileprivate var textLabel   : UILabel!
    fileprivate var optionImage : UIImageView?
    fileprivate var button      : BaseButton!
    fileprivate var sortType    : Int   = 0
    fileprivate var canSort     : Bool  = false
    
    init(canSort: Bool) {
        super.init(frame: CGRect.zero)
        self.canSort            = canSort
        
        textLabel               = UILabel()
        textLabel.font          = UIFont.normalFontOfSize(fontSize , needScale: true)
        textLabel.textColor     = textColor
        textLabel.textAlignment = .right
        textLabel.numberOfLines = 2
        self.addSubview(textLabel)
        
        textLabel.snp.makeConstraints { (maker) in
            maker.right.equalTo(self)
            maker.centerY.equalTo(self)
        }
        
        if canSort {
            optionImage             = UIImageView()
            optionImage?.image      = UIImage(named: "ss_image_sort_default")
            self.addSubview(optionImage!)
            
            optionImage?.snp.makeConstraints { (maker) in
                maker.right.equalTo(self)
                maker.centerY.equalTo(self.textLabel)
            }
            
            textLabel.snp.remakeConstraints { (maker) in
                maker.right.equalTo(self.optionImage!.snp.left).offset(-3)
                maker.centerY.equalTo(self)
            }
            
            button                  = BaseButton()
            button.addTarget(self, action: #selector(SortHeaderItem.sortAction), for: UIControl.Event.touchUpInside)
            self.addSubview(button)
            
            button.snp.makeConstraints { (maker) in
                maker.left.equalTo(self)
                maker.right.equalTo(self)
                maker.top.equalTo(self)
                maker.bottom.equalTo(self)
            }
        }
    }
    
    func setAttributes(_ data : Dictionary<String , AnyObject>) {
        
        let font  = data.getNumberForKey("font").doubleValue
        let color = data["color"] + ""
        let align = data["align"] + ""
        if font > 1 {
            textLabel?.font   = UIFont.normalFontOfSize(CGFloat(font), needScale: true)
        }
        if !color.isEmpty {
            textLabel?.textColor  = Color(color)
        }
        if !align.isEmpty {
            textLabel.snp.remakeConstraints({ (maker) in
                switch align {
                case "left":
                    maker.left.equalTo(self)
                    maker.centerY.equalTo(self)
                    self.textLabel?.textAlignment = .left
                case "right":
                    if self.optionImage != nil {
                        maker.right.equalTo(self.optionImage!.snp.left).offset(-3)
                        maker.centerY.equalTo(self)
                    }
                    self.textLabel?.textAlignment = .right
                default:
                    maker.center.equalTo(self)
                    self.textLabel?.textAlignment = .center
                }
            })
            
            optionImage?.snp.remakeConstraints({ (maker) in
                switch align {
                case "left":
                    maker.left.equalTo(self.textLabel.snp.right).offset(3)
                    maker.centerY.equalTo(self)
                case "right":
                    maker.right.equalTo(self)
                    maker.centerY.equalTo(self)
                default:
                    maker.left.equalTo(self.textLabel.snp.right).offset(3)
                    maker.centerY.equalTo(self)
                }
            })
        }
        
    }
    
    func setNormalState() {
        if canSort {
            optionImage?.image      = UIImage(named: "ss_image_sort_default")
            sortType                = 0
        }
    }
    
    @objc fileprivate func sortAction() {
        if canTouch && options != nil {
            if let str = delegate?.headerItemFilter(self, key: key, options: options! , currentFilter: currentFilter, listTitle : listTitle) {
                textLabel.text      = str
            }
        }else{
            sortType               += 1
            if sortType == 3 {
                sortType            = 0
            }
            var imageName           = ""
            switch sortType {
            case 0:
                imageName           = "ss_image_sort_default"
            case 1:
                imageName           = "ss_image_sort_desc"
            case 2:
                imageName           = "ss_image_sort_asc"
            default:
                break
            }
            optionImage?.image      = UIImage(named: imageName)
            delegate?.headerItemSorted(self, sortDirection: sortType , key: key)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
