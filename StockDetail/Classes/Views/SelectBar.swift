//
//  PlateTopView.swift
//  Subject
//
//  Created by focus on 2016/11/22.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

enum SelectBarType : Int
{
    case Today = 0
    case Week
    case Month
    case ThreeMonth
    case HalfYear
    case Calendar
}

protocol SelectBarDelegate : NSObjectProtocol
{
    func selectBarItemClicked(index : Int)
}

class SelectBar: BaseView
{
    
    var title : String      = "自日期"
    {
        didSet
        {
            focusView?.isHidden = true
            if currentTag != 10 && type != 0 {
                if let btn = self.viewWithTag(currentTag + 100) as? UIButton {
                    btn.setTitleColor(HexColor(unSelectedColor), for: UIControl.State.normal)
                }
            }
            if title != oldValue
            {
                currentTag = 10
                dateBtn.setTitle(title, for: UIControl.State.normal)
            }
        }
    }
    
    weak var delegate : SelectBarDelegate?
    
    required init(type: Int = 0) {
        self.type = type
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initUI() {
        super.initUI()
        
        focusView                   = UIView()
        focusView?.backgroundColor  = HexColor(COLOR_COMMON_WHITE)
        self.addSubview(focusView!)
        selectedBgColor             = "#00000000"
        unSelectedBgColor           = "#00000000"
        
        self.backgroundColor        = HexColor("#edeef0")
        if self.type != 0 {
            self.backgroundColor        = HexColor(COLOR_COMMON_WHITE)
            focusView?.backgroundColor  = HexColor(COLOR_COMMON_RED)
            selectedColor               = COLOR_COMMON_WHITE
            unSelectedColor             = COLOR_COMMON_BLACK_3
            focusView?.layer.cornerRadius   = 11  * SCALE_WIDTH_6
            focusView?.layer.masksToBounds  = true
        }
        
        let width                   = 56 * SCALE_WIDTH_6
        let dateWidth               = 94 * SCALE_WIDTH_6
        
        for i in 0 ..< 5
        {
            let btn         = BaseButton()
            btn.tag         = 100 + i
            btn.addTarget(self, action: #selector(SelectBar.btnclicked(sender:)), for: UIControl.Event.touchUpInside)
            self.addSubview(btn)
            self.periodBtns.append(btn)
            
            btn.snp.makeConstraints({ (maker) in
                maker.top.equalTo(self)
                maker.left.equalTo(self).offset(CGFloat(i) * width)
                maker.height.equalTo(self)
                maker.width.equalTo(width)
            })
            
            btn.titleLabel?.font        = type == 0 ? UIFont.boldFontOfSize(16) : UIFont.normalFontOfSize(16)
            if i == 0
            {
                btn.backgroundColor     = HexColor(selectedBgColor)
                btn.setTitleColor(HexColor(selectedColor), for: UIControl.State.normal)
                focusView?.snp.remakeConstraints({ (maker) in
                    maker.center.equalTo(btn)
                    maker.width.equalTo(focusWidth)
                    maker.height.equalTo(focusHeight)
                })
            }else
            {
                btn.backgroundColor     = HexColor(unSelectedBgColor)
                btn.setTitleColor(HexColor(unSelectedColor), for: UIControl.State.normal)
            }
            
            switch i {
            case 0:
                btn.setTitle("今日", for: UIControl.State.normal)
            case 1:
                btn.setTitle("周", for: UIControl.State.normal)
            case 2:
                btn.setTitle("月", for: UIControl.State.normal)
            case 3:
                btn.setTitle("三月", for: UIControl.State.normal)
            default:
                btn.setTitle("半年", for: UIControl.State.normal)
            }
        }
        
        let tmpView                 = UIView()
        tmpView.backgroundColor     = HexColor(unSelectedBgColor)
        self.addSubview(tmpView)
        
        tmpView.snp.makeConstraints { (maker) in
            maker.right.equalTo(self)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
            maker.width.equalTo(dateWidth)
        }
        
        dateBtn                     = BaseButton()
        if self.type != 0 {
            let scale = UIScreen.main.scale
            let w     = scale > 0.0 ? 1 / scale : 1
            dateBtn.layer.borderColor = HexColor(COLOR_COMMON_BLACK_9).cgColor
            dateBtn.layer.borderWidth = w
        }
        dateBtn.backgroundColor     = HexColor(COLOR_COMMON_WHITE)
        dateBtn.titleLabel?.font    = UIFont.normalFontOfSize(14)
        dateBtn.setTitleColor(HexColor(unSelectedColor), for: UIControl.State.normal)
        dateBtn.setTitle("自日期", for: UIControl.State.normal)
        dateBtn.tag                 = 110
        dateBtn.addTarget(self, action: #selector(SelectBar.btnclicked(sender:)), for: UIControl.Event.touchUpInside)
        tmpView.addSubview(dateBtn)
        dateBtn.snp.makeConstraints { (maker) in
            maker.center.equalTo(tmpView)
            maker.width.equalTo(80 * SCALE_WIDTH_6)
            maker.height.equalTo(25 * SCALE_WIDTH_6)
        }
        
        let img                     = UIImageView(image: UIImage(named: "ic_hot_date_more"))
        dateBtn.addSubview(img)
        img.snp.makeConstraints { (maker) in
            maker.right.equalTo(dateBtn).offset(-2)
            maker.bottom.equalTo(dateBtn).offset(-2)
        }
        
    }
    
    @objc func btnclicked(sender : BaseButton)
    {
        let tag     = sender.tag - 100
        
        if tag  == 10
        {
            self.delegate?.selectBarItemClicked(index: tag)
            return
        }
        
        if tag != currentTag
        {
            currentTag  = tag
            focusView?.isHidden = false
            dateBtn.setTitle("自日期", for: UIControl.State.normal)
            for btn in self.periodBtns
            {
                if btn.tag == currentTag + 100
                {
                    if focusView != nil {
                        UIView.animate(withDuration: 0.15, animations: {
                            self.focusView?.snp.remakeConstraints({ (maker) in
                                maker.center.equalTo(btn)
                                maker.width.equalTo(self.focusWidth)
                                maker.height.equalTo(self.focusHeight)
                            })
                            self.layoutIfNeeded()
                        }, completion: { (Bool) in
                            btn.backgroundColor     = HexColor(self.selectedBgColor)
                            btn.setTitleColor(HexColor(self.selectedColor), for: UIControl.State.normal)
                        })
                    }else{
                        btn.backgroundColor     = HexColor(selectedBgColor)
                        btn.setTitleColor(HexColor(selectedColor), for: UIControl.State.normal)
                    }
                }else
                {
                    btn.backgroundColor     = HexColor(unSelectedBgColor)
                    btn.setTitleColor(HexColor(unSelectedColor), for: UIControl.State.normal)
                }
            }
            self.delegate?.selectBarItemClicked(index: currentTag)
        }
        
    }
    
    func resetStatus(tag : Int)
    {
        for btn in self.periodBtns
        {
            if btn.tag == tag + 100
            {
                btn.backgroundColor     = HexColor(selectedBgColor)
                btn.setTitleColor(HexColor(selectedColor), for: UIControl.State.normal)
                self.dateBtn.setTitle("自日期", for: UIControl.State.normal)
                focusView?.snp.remakeConstraints({ (maker) in
                    maker.center.equalTo(btn)
                    maker.width.equalTo(focusWidth)
                    maker.height.equalTo(focusHeight)
                })
            }else
            {
                btn.backgroundColor     = HexColor(unSelectedBgColor)
                btn.setTitleColor(HexColor(unSelectedColor), for: UIControl.State.normal)
            }
        }
    }
    
    fileprivate var periodBtns  : Array<BaseButton>      = Array<BaseButton>()
    fileprivate var dateBtn     : BaseButton!
    fileprivate var currentTag  : Int                   = 0
    fileprivate var type        : Int
    fileprivate var selectedColor : String              = "#e84640"
    fileprivate var unSelectedColor : String            = COLOR_COMMON_BLACK_3
    fileprivate var selectedBgColor : String            = COLOR_COMMON_WHITE
    fileprivate var unSelectedBgColor : String          = "#edeef0"
    fileprivate var focusView : UIView?
    
    fileprivate var focusWidth : CGFloat {
        return type == 0 ? (56 * SCALE_WIDTH_6) : (48 * SCALE_WIDTH_6)
    }
    fileprivate var focusHeight : CGFloat {
        return type == 0 ? self.bounds.height : (22 * SCALE_WIDTH_6)
    }
}
