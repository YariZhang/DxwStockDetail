//
//  StrategyDatePickerView.swift
//  quchaogu
//
//  Created by zhangyr on 16/1/26.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(rhs > lhs)
    }
}


protocol StrategyDatePickerViewDelegate : NSObjectProtocol {
    func strategyDatePickerPick(_ date : String)
    func strategyDatePickerError()
}

class StrategyDatePickerView: UIView , UIPickerViewDataSource , UIPickerViewDelegate {

    weak var delegate           : StrategyDatePickerViewDelegate?
    lazy var currentDate        : String    = ""
    lazy var earliestDate       : String    = "20100101"
    var latestDate              : String    = UtilDate.formatTime("yyyyMMdd", time_interval: UtilDate.getTimeInterval()) {
        didSet {
            if Int(latestDate) > Int(earliestDate) {
                pickerView.reloadAllComponents()
            }
        }
    }
    fileprivate var centerView      : UIView!
    fileprivate var titleLabel      : UILabel!
    fileprivate var bgImage         : UIImageView!
    fileprivate var pickerView      : UIPickerView!
    fileprivate var commitBtn       : BaseButton!
    fileprivate var cancelBtn       : BaseButton!
    
    fileprivate lazy var year       : String = ""
    fileprivate lazy var month      : String = ""
    fileprivate lazy var day        : String = ""
    
    fileprivate var _earlyYear      : Int {return Int((earliestDate as NSString).substring(to: 4))! }
    fileprivate var _earlyMonth     : Int {return Int((earliestDate as NSString).substring(with: NSRange(location: 4, length: 2)))! }
    fileprivate var _earlyDay       : Int {return Int((earliestDate as NSString).substring(from: earliestDate.count - 2))! }
    fileprivate var _lastYear       : Int {return Int((latestDate as NSString).substring(to: 4))! }
    fileprivate var _lastMonth      : Int {return Int((latestDate as NSString).substring(with: NSRange(location: 4, length: 2)))! }
    fileprivate var _lastDay        : Int {return Int((latestDate as NSString).substring(from: latestDate.count - 2))! }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor            = Color("#000").withAlphaComponent(0.2)
        self.frame                      = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        initUI()
    }
    
    fileprivate func initUI() {
        
        centerView                      = UIView()
        centerView.backgroundColor      = Color("#fff")
        centerView.layer.cornerRadius   = 3
        centerView.clipsToBounds        = false
        self.addSubview(centerView)
        centerView.snp.makeConstraints { (maker) -> Void in
            maker.center.equalTo(self)
            maker.width.equalTo(280)
            maker.height.equalTo(210)
        }
        
        bgImage                         = UIImageView()
        let image                       = UIImage(named: "main_image_toast_bg")
        let insets                      = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        let img                         = image?.resizableImage(withCapInsets: insets, resizingMode: UIImage.ResizingMode.stretch)
        bgImage.image                   = img
        centerView.addSubview(bgImage)
        bgImage.snp.makeConstraints { (maker) -> Void in
            maker.left.equalTo(self.centerView).offset(-5.5)
            maker.right.equalTo(self.centerView).offset(5.5)
            maker.top.equalTo(self.centerView).offset(-5.5)
            maker.bottom.equalTo(self.centerView).offset(5.5)
        }
        
        titleLabel                      = UILabel()
        titleLabel.font                 = UIFont.normalFontOfSize(18)
        titleLabel.textColor            = Color("#333")
        titleLabel.textAlignment        = .center
        titleLabel.text                 = "选择起始日期"
        
        let sepLine                     = UIView()
        sepLine.backgroundColor         = Color("#ddd")
        
        pickerView                      = UIPickerView()
        pickerView.dataSource           = self
        pickerView.delegate             = self
        
        let sepB                        = UIView()
        sepB.backgroundColor            = Color("#ddd")
        
        commitBtn                       = BaseButton()
        commitBtn.tag                   = 666
        commitBtn.titleLabel?.font      = UIFont.normalFontOfSize(18)
        commitBtn.setTitle("确定", for: UIControl.State())
        commitBtn.setTitleColor(Color(COLOR_COMMON_RED), for: UIControl.State())
        commitBtn.addTarget(self, action: #selector(StrategyDatePickerView.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        
        let sepC                        = UIView()
        sepC.backgroundColor            = Color("#ddd")
        
        cancelBtn                       = BaseButton()
        cancelBtn.tag                   = 888
        cancelBtn.titleLabel?.font      = UIFont.normalFontOfSize(18)
        cancelBtn.setTitle("取消", for: UIControl.State())
        cancelBtn.setTitleColor(Color("#333"), for: UIControl.State())
        cancelBtn.addTarget(self, action: #selector(StrategyDatePickerView.buttonAction(_:)), for: UIControl.Event.touchUpInside)
        
        centerView.addSubview(titleLabel)
        centerView.addSubview(sepLine)
        centerView.addSubview(pickerView)
        centerView.addSubview(sepB)
        centerView.addSubview(commitBtn)
        centerView.addSubview(sepC)
        centerView.addSubview(cancelBtn)
        
        titleLabel.snp.makeConstraints { (maker) -> Void in
            maker.top.equalTo(self.centerView).offset(17)
            maker.centerX.equalTo(self.centerView)
            maker.height.equalTo(16)
        }
        
        sepLine.snp.makeConstraints { (maker) -> Void in
            maker.left.equalTo(self.centerView)
            maker.right.equalTo(self.centerView)
            maker.top.equalTo(self.titleLabel.snp.bottom).offset(17)
            maker.height.equalTo(0.5)
        }
        
        cancelBtn.snp.makeConstraints { (maker) -> Void in
            maker.left.equalTo(self.centerView)
            maker.width.equalTo(self.centerView).multipliedBy(0.5)
            maker.bottom.equalTo(self.centerView)
            maker.height.equalTo(50)
        }
        
        commitBtn.snp.makeConstraints { (maker) -> Void in
            maker.right.equalTo(self.centerView)
            maker.width.equalTo(self.centerView).multipliedBy(0.5)
            maker.bottom.equalTo(self.centerView)
            maker.height.equalTo(50)
        }
        
        sepB.snp.makeConstraints { (maker) -> Void in
            maker.left.equalTo(self.centerView)
            maker.right.equalTo(self.centerView)
            maker.bottom.equalTo(self.commitBtn.snp.top)
            maker.height.equalTo(0.5)
        }
        
        sepC.snp.makeConstraints { (maker) -> Void in
            maker.top.equalTo(sepB.snp.bottom)
            maker.bottom.equalTo(self.centerView)
            maker.width.equalTo(0.5)
            maker.centerX.equalTo(self.centerView)
        }
        
        pickerView.snp.makeConstraints { (maker) -> Void in
            maker.left.equalTo(self.centerView).offset(27)
            maker.right.equalTo(self.centerView).offset(-27)
            maker.top.equalTo(sepLine.snp.bottom).offset(3)
            maker.bottom.equalTo(sepB.snp.top).offset(-3)
        }
        
    }
    
    func show() {
        
        if Int(latestDate) <= Int(earliestDate) {
            delegate?.strategyDatePickerError()
        }else{
            if !currentDate.isEmpty && Int(currentDate) >= Int(earliestDate) && Int(currentDate) <= Int(latestDate) {
                let y   = Int((currentDate as NSString).substring(to: 4))!
                let m   = Int((currentDate as NSString).substring(with: NSRange(location: 4, length: 2)))!
                let d   = Int((currentDate as NSString).substring(from: currentDate.count - 2))!
                pickerView.selectRow(y - _earlyYear, inComponent: 0, animated: true)
                if y == _earlyYear {
                    pickerView.selectRow(m - _earlyMonth, inComponent: 1, animated: true)
                    if m == _earlyMonth {
                        pickerView.selectRow(d - _earlyDay, inComponent: 2, animated: true)
                    }else{
                        pickerView.selectRow(d - 1, inComponent: 2, animated: true)
                    }
                }else{
                    pickerView.selectRow(m - 1, inComponent: 1, animated: true)
                    pickerView.selectRow(d - 1, inComponent: 2, animated: true)
                }
            }else{
                year  = String(_earlyYear)
                month = String(_earlyMonth)
                day   = String(_earlyDay)
            }
            UtilTools.getAppDelegate()?.window??.addSubview(self)
        }
    }
    
    @objc fileprivate func buttonAction(_ btn : UIButton) {
        if btn.tag == 666 {
            checkCurrent()
            delegate?.strategyDatePickerPick(year + month + day)
            print(year + month + day)
        }
        self.removeFromSuperview()
    }
    
    fileprivate func setAttr() {
        if year.isEmpty {
            year    = (currentDate as NSString).substring(to: 4)
        }
        if month.isEmpty {
            month   = (currentDate as NSString).substring(with: NSRange(location: 4, length: 2))
        }
        if day.isEmpty {
            day     = (currentDate as NSString).substring(from: currentDate.count - 2)
        }
    }
    
    fileprivate func checkCurrent() {
        let row0    = pickerView.selectedRow(inComponent: 0)
        let row1    = pickerView.selectedRow(inComponent: 1)
        let row2    = pickerView.selectedRow(inComponent: 2)
        
        year        = String(format: "%d", row0 + _earlyYear)
        if Int(year) == _earlyYear {
            month       = String(format: "%02d", _earlyMonth + row1)
            if Int(month) == _earlyMonth {
                day     = String(format: "%02d", row2 + _earlyDay)
            }else{
                day     = String(format: "%02d", row2 + 1)
            }
        }else{
            month       = String(format: "%02d", row1 + 1)
            day         = String(format: "%02d", row2 + 1)
        }
        //month       = String(format: "%02d", row1 + 1)
        //day         = String(format: "%02d", row2 + 1)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        setAttr()
        let y   = Int(year)!
        let m   = Int(month)!
        if component == 0 {
            return _lastYear - _earlyYear + 1
        }else if component == 1 {
            if y == _lastYear {
                if _lastYear == _earlyYear {
                    return _lastMonth - _earlyMonth + 1
                }
                return _lastMonth
            }else{
                return 12 - _earlyMonth + 1
            }
        }else{
            if y == _lastYear && m == _lastMonth {
                if y == _earlyYear && m == _earlyMonth {
                    return _lastDay - _earlyDay + 1
                }
                return _lastDay
            }
            if y == _earlyYear && m == _earlyMonth {
                return daysForMonth(y, monthIndex: m) - _earlyDay + 1
            }else{
                return daysForMonth(y, monthIndex: m)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label           = UILabel()
        label.font          = UIFont.normalFontOfSize(16)
        label.textColor     = Color("#333")
        label.textAlignment = .center
        if component == 0 {
            label.text      = String(format: "%d年", row + _earlyYear)
        }else if component == 1 {
            let cRow        = pickerView.selectedRow(inComponent: 0)
            let year        = _earlyYear + cRow
            if year == _earlyYear {
                label.text  = String(format: "%02d月", _earlyMonth + row)
            }else{
                label.text  = String(format: "%02d月", row + 1)
            }
        }else{
            let cRow        = pickerView.selectedRow(inComponent: 0)
            let year        = _earlyYear + cRow
            let mRow        = pickerView.selectedRow(inComponent: 1)
            let month       = _earlyMonth + mRow
            if year == _earlyYear && month == _earlyMonth {
                label.text  = String(format: "%02d日", _earlyDay + row)
            }else{
                label.text  = String(format: "%02d日", row + 1)
            }
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            year    = String(format: "%d", row + _earlyYear)
            pickerView.reloadComponent(1)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                self.month  = String(format: "%02d", pickerView.selectedRow(inComponent: 1) + 1)
                if Int(self.year) == self._earlyYear {
                    self.month = String(format: "%02d", self._earlyMonth + pickerView.selectedRow(inComponent: 1))
                }
                pickerView.reloadComponent(2)
            }
            
        }else if component == 1 {
            let cRow        = pickerView.selectedRow(inComponent: 0)
            let year        = _earlyYear + cRow
            if year == _earlyYear {
                month       = String(format: "%02d", _earlyMonth + row)
            }else{
                month       = String(format: "%02d", row + 1)
            }
            pickerView.reloadComponent(2)
        }else{
            let cRow        = pickerView.selectedRow(inComponent: 0)
            let year        = _earlyYear + cRow
            let mRow        = pickerView.selectedRow(inComponent: 1)
            let month       = _earlyMonth + mRow
            if year == _earlyYear && month == _earlyMonth {
                day         = String(format: "%02d", _earlyDay + row)
            }else{
                day         = String(format: "%02d", row + 1)
            }
        }
    }
    
    fileprivate func daysForMonth(_ yearIndex : Int , monthIndex : Int) -> Int{
        switch monthIndex {
        case 1,3,5,7,8,10,12 :
            return 31
        case 4,6,9,11:
            return 30
        default :
            if (yearIndex % 4 == 0 && yearIndex % 100 != 0) || yearIndex % 400 == 0 {
                return 29
            }else{
                return 28
            }
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
