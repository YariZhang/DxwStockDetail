//
//  ChartsInfoCell.swift
//  Lhb
//
//  Created by zhangyr on 16/7/24.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

protocol ChartsInfoCellDelegate : class {
    func chartsInfoCellSelected(_ cType : BaseViewController.Type? , indexPath : IndexPath? , param : Dictionary<String , AnyObject>!)
}

class ChartsInfoCell: UITableViewCell {
    
    var needFirstItemMutiLine   = false
    {
        didSet
        {
            if needFirstItemMutiLine != oldValue
            {
                if self.itArray.count > 0
                {
                    self.itArray[0].canV1MutiLine   = needFirstItemMutiLine
                }
            }
        }
    }

    ///两行头尾边距
    var topMargin   : CGFloat   = 1
    ///首尾间隔
    var offset      : CGFloat   = 12 {
        didSet {
            sepLine.snp.remakeConstraints { (maker) in
                maker.left.equalTo(self).offset(self.offset)
                maker.right.equalTo(self).offset(-self.offset)
                maker.bottom.equalTo(self)
                maker.height.equalTo(0.5)
            }
        }
    }
    ///比例 eg. "1:2:2:2"
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
    ///属性 eg. [["v1Font" : 16 , "v1Color" : "#333333" ,"v2Font" : 12 , "v2Color" : "#999999"],...]
    var attributes : Array<Dictionary<String , AnyObject>>!
    //数据源 eg. [["v1" : "平安银行" , "v2" : "000001" , "icons" : ["xxx.png",...]]]
    var cellData : AnyObject! {
        didSet{
            if cellData != nil {
                showData()
            }
        }
    }
    
    var controllerType   : BaseViewController.Type?
    var indexPath        : IndexPath?
    weak var delegate    : ChartsInfoCellDelegate? {
        didSet {
            if delegate == nil {
                button.isEnabled  = false
            }else{
                button.isEnabled  = true
            }
        }
    }
    
    var needSep          : Bool             = false {
        didSet {
            sepLine.isHidden                  = !needSep
        }
    }
    
    fileprivate var proArray : Array<CGFloat>   = Array()
    fileprivate var sepLine  : UIView!
    var button               : BaseButton!
    fileprivate var itArray  : Array<ChartsInfoItem>        = []
    var param            : Dictionary<String , AnyObject>!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle     = .none
//        self.backgroundColor    = Color("#fff")
        sepLine                 = UIView()
        sepLine.backgroundColor = Color("#ddd")
        sepLine.isHidden          = true
        self.addSubview(sepLine)
        
        sepLine.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.bottom.equalTo(self)
            maker.height.equalTo(0.5)
        }
        
        button                  = BaseButton()
        button.addTarget(self, action: #selector(ChartsInfoCell.cellClick), for: UIControl.Event.touchUpInside)
        self.addSubview(button)
        
        button.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
        }
        
        button.addTarget(self, action: #selector(ChartsInfoCell.touchIn), for: UIControl.Event.touchDown)
        button.addTarget(self, action: #selector(ChartsInfoCell.touchIn), for: UIControl.Event.touchDragInside)
        button.addTarget(self, action: #selector(ChartsInfoCell.touchOut), for: UIControl.Event.touchCancel)
        button.addTarget(self, action: #selector(ChartsInfoCell.touchOut), for: UIControl.Event.touchDragOutside)
        button.addTarget(self, action: #selector(ChartsInfoCell.touchOut), for: UIControl.Event.touchDragExit)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func touchIn() {
//        self.backgroundColor    = Color("#f5f5f5")
    }
    
    @objc fileprivate func touchOut() {
        self.backgroundColor    = Color("#fff")
    }
    
    fileprivate func showData() {
        
        itArray.removeAll(keepingCapacity: false)
        
        var isArr       = false
        if cellData is Dictionary<String , AnyObject> {
            isArr       = false
        }else if cellData is Array<Dictionary<String , AnyObject>> {
            isArr       = true
        }else{
            return
        }
        
        for v in self.subviews {
            if v is ChartsInfoItem {
                v.removeFromSuperview()
            }
        }
        
        weak var masV   : UIView!
        var muti : CGFloat?
        
        let infoData        = (isArr ? (cellData as? Array<Dictionary<String , AnyObject>>) : cellData!["data"] as? Array<Dictionary<String , AnyObject>>) ?? Array()

        if let p = cellData["para"] as? Dictionary<String , AnyObject> , !isArr {
            param           = p
        }
        
        if proportion.isEmpty || proArray.count != infoData.count {
            muti            = 1 / CGFloat(infoData.count)
        }
        
        for i in 0 ..< infoData.count {
            let d           = infoData[i]
            var item : ChartsInfoItem?
            if i == 0 {
                item                    = ChartsInfoItem(data: d, offset: offset, topMargin: topMargin)
                item?.canV1MutiLine     = self.needFirstItemMutiLine
            }else if i == infoData.count - 1 {
                item                    = ChartsInfoItem(data: d, offset: -offset, topMargin: topMargin)
                item?.canV1MutiLine     = false
            }else{
                item                    = ChartsInfoItem(data: d, offset: 0, topMargin: topMargin)
                item?.canV1MutiLine     = false
            }
            
            self.addSubview(item!)
            itArray.append(item!)
            if attributes != nil &&  i < attributes.count {
                item?.setAttributes(attributes[i])
            }
            item?.snp.makeConstraints({ (maker) in
                maker.centerY.equalTo(self)
                maker.width.equalTo(SCREEN_WIDTH * (muti ?? self.proArray[i]))
                if masV != nil {
                    maker.left.equalTo(masV.snp.right)
                }else{
                    maker.left.equalTo(self)
                }
                maker.height.equalTo(32 + topMargin)
            })
            masV            = item
        }
        
        self.bringSubviewToFront(button)
        
    }
    
    @objc fileprivate func cellClick() {
//        self.backgroundColor    = Color("#fff")
        if param != nil && param!.count > 0 {
            delegate?.chartsInfoCellSelected(controllerType, indexPath: indexPath, param: param)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted && param != nil {
//            self.backgroundColor    = Color("#f5f5f5")
        }else{
        }
    }
}

class ChartsInfoItem : UIView {
    
    fileprivate var upLabel         : UILabel?
    fileprivate var downLabel       : UILabel?
    var canV1MutiLine   : Bool  = false
    {
        didSet
        {
            upLabel?.numberOfLines      = canV1MutiLine ? 2 : 1
        }
    }
    
    init(data: Dictionary<String , AnyObject> , offset : CGFloat = 0 , topMargin : CGFloat = 4) {
        super.init(frame: CGRect.zero)
        
        let v1      = data["v1"] as? String
        let v2      = data["v2"] as? String
        let icons   = data["icons"] as? Array<String>
        
        if v1 != nil {
            upLabel                 = UILabel()
            upLabel?.text           = v1
            upLabel?.numberOfLines  = 2
            upLabel?.textColor      = Color("#333")
            upLabel?.font           = UIFont.normalFontOfSize(16 , needScale: true)
            self.upLabel?.textAlignment = .right
            self.addSubview(upLabel!)
            
            upLabel?.snp.makeConstraints({ (maker) in
                if offset > 0 {
                    maker.left.equalTo(self).offset(offset)
                    maker.right.equalTo(self)
                    self.upLabel?.textAlignment = .left
                }else if offset < 0 {
                    maker.right.equalTo(self).offset(offset)
                    maker.left.equalTo(self)
                }else{
                    maker.left.equalTo(self)
                    maker.right.equalTo(self)
                }
                if v2 != nil {
                    maker.top.equalTo(self)
                }else{
                    maker.centerY.equalTo(self)
                }
                
//                maker.width.lessThanOrEqualTo()()
            })
        }
        
        if v2 != nil {
            downLabel       = UILabel()
            downLabel?.text = v2
            downLabel?.textColor  = Color("#333")
            downLabel?.font   = UIFont.normalFontOfSize(16 , needScale: true)
            self.downLabel?.textAlignment = .right
            self.addSubview(downLabel!)
            
            downLabel?.snp.makeConstraints({ (maker) in
                if offset > 0 {
                    maker.left.equalTo(self).offset(offset)
                    self.downLabel?.textAlignment = .left
                    self.downLabel?.textColor  = Color("#999")
                    self.downLabel?.font   = UIFont.normalFontOfSize(12 , needScale: true)
                }else if offset < 0 {
                    maker.right.equalTo(self).offset(offset)
                    maker.left.equalTo(self)
                }else{
                    maker.left.equalTo(self)
                    maker.right.equalTo(self)
                }
                maker.top.equalTo(self.upLabel!.snp.bottom).offset(topMargin)
            })
        }
        
        if icons != nil {
            weak var masV : UIView?     = downLabel ?? upLabel
            for icon in icons! {
                let imgV                = UIImageView()
                var width   : CGFloat   = 36
                var height  : CGFloat   = 11
                let scale   : CGFloat   = 3
                imgV.sd_setImage(with: URL(string: icon), completed: { (image, error, type, url) in
                    if image != nil
                    {
                        width               = (image?.size.width)! / scale
                        height              = (image?.size.height)! / scale
                        imgV.image          = image
                        imgV.snp.updateConstraints({ (maker) in
                            maker.width.equalTo(width)
                            maker.height.equalTo(height)
                        })
                    }else
                    {
                    }
                })
                self.addSubview(imgV)
                if masV === upLabel {
                    imgV.snp.makeConstraints({ (maker) in
                        maker.left.equalTo(masV!)
                        maker.top.equalTo(masV!.snp.bottom).offset(2)
                        maker.width.equalTo(width)
                        maker.height.equalTo(height)
                    })
                }else{
                    imgV.snp.makeConstraints({ (maker) in
                        maker.left.equalTo(masV!.snp.right).offset(2)
                        maker.centerY.equalTo(masV!)
                        maker.width.equalTo(width)
                        maker.height.equalTo(height)
                    })
                }
                masV                    = imgV
            }
        }
        
        
    }
    
    func setAttributes(_ data : Dictionary<String , AnyObject>) {
        
        var font  = data.getNumberForKey("v1font").doubleValue
        var color = data["v1color"] + ""
        var  relation    = ""
        if color == "-2" {
            relation     = "down"
            color        = ""
        }else{
            color        = getColor(color)
        }
        
        if font > 1 {
            upLabel?.font   = UIFont.normalFontOfSize(CGFloat(font), needScale: true)
        }
        if !color.isEmpty {
            if color == "-1" {
                upLabel?.textColor  = upLabel!.text!.hasPrefix("+") ? UtilColor.getRedTextColor() : upLabel!.text!.hasPrefix("-") ? UtilColor.getGreenColor() : upLabel!.text!.hasSuffix("%") ? Color("#333") : (upLabel!.text!.hasPrefix("--") || upLabel!.text!.hasPrefix("停牌")) ? Color("#999") : UtilColor.getRedTextColor()
            }else{
                upLabel?.textColor  = Color(color)
            }
        }
        
        font      = data.getNumberForKey("v2font").doubleValue
        color     = data["v2color"] + ""
        if color == "-2" {
            relation    = "up"
            color       = ""
        }else{
            color       = getColor(color)
        }
        if font > 1 {
            downLabel?.font   = UIFont.normalFontOfSize(CGFloat(font), needScale: true)
        }
        if !color.isEmpty {
            if color == "-1" {
                downLabel?.textColor  = downLabel!.text!.hasPrefix("+") ? UtilColor.getRedTextColor() : downLabel!.text!.hasPrefix("-") ? UtilColor.getGreenColor() : downLabel!.text!.hasSuffix("%") ? Color("#333") : downLabel!.text!.hasPrefix("--") ? Color("#999") : UtilColor.getRedTextColor()
            }else{
                downLabel?.textColor  = Color(color)
            }
        }
        
        if !relation.isEmpty {
            if relation == "up" {
                downLabel?.textColor    = upLabel?.textColor
            }else{
                upLabel?.textColor      = downLabel?.textColor
            }
        }
        
    }
    
    fileprivate func getColor(_ color : String) -> String {
        var nc      = color
        switch color {
        case "-1" , "-2" :
            break
        case "0":
            nc      = "#333"
        case "1":
            nc      = "#ff524f"
        case "2":
            nc      = "#15af3d"
        case "3":
            nc      = "#999"
        default:
            nc      = ""
        }
        return nc
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
