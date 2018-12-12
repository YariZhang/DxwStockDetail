//
//  SelectedSegmentedBar.swift
//  quchaogu
//
//  Created by zhangyr on 15/6/23.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

@objc protocol SelectedSegmentedBarDelegate : NSObjectProtocol {
    
    func selectedItemForSegmentedBar(_ segmentedBar : SelectedSegmentedBar , selectedSegmentedIndex : Int)
    
}

class SelectedSegmentedBar: UIView {
    
    fileprivate weak var delegate : SelectedSegmentedBarDelegate!
    fileprivate var lastBtn       : UIButton!
    fileprivate var selectedLabel : UILabel!
    fileprivate var needCall      : Bool = true
    var index : Int {
        set {
            if index != newValue {
                if let btn = self.viewWithTag(newValue + 100) as? BaseButton {
                    needCall         = false
                    selectedItem(btn)
                }
                _index  = newValue
            }
        }
        
        get{
            return _index
        }
    }
    
    fileprivate var _index : Int = 0

    init(frame: CGRect , items : [Any] , delegate : SelectedSegmentedBarDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        self.backgroundColor = HexColor("#fafafa")
        let btnW = frame.size.width / CGFloat(items.count)
        let btnH = frame.size.height - 2
        for i in 0 ..< items.count {
            
            let btn = BaseButton(frame: CGRect(x: CGFloat(i) * btnW, y: 0, width: btnW, height: btnH))
            btn.tag = i + 100
            btn.setTitle(items[i] as? String, for: UIControl.State())
            btn.titleLabel?.font = UIFont.boldFontOfSize(16 , weight: 0.15)
            btn.setTitleColor(HexColor("#333333"), for: UIControl.State())
            if i == 0 {
                btn.setTitleColor(HexColor("#ff524f"), for: UIControl.State())
                lastBtn = btn
            }
            btn.addTarget(self, action: #selector(SelectedSegmentedBar.selectedItem(_:)), for: UIControl.Event.touchUpInside)
            self.addSubview(btn)
        }
        
        let line = UILabel(frame: CGRect(x: 0, y: btnH + 1.5, width: frame.size.width, height: 0.5))
        line.backgroundColor = HexColor("#dddddd")
        self.addSubview(line)
        
        selectedLabel = UILabel(frame: CGRect(x: 0, y: btnH, width: 32, height: 2))
        selectedLabel.backgroundColor = HexColor("#ff524f")
        self.addSubview(selectedLabel)
        selectedLabel.center    = CGPoint(x: lastBtn.center.x, y: selectedLabel.center.y)
    }
    
    func setIndexWithAction(for index : Int) {
        if index != _index {
            if let btn = self.viewWithTag(index + 100) as? BaseButton {
                needCall         = true
                selectedItem(btn)
            }
            _index  = index
        }
    }
    
    @objc func selectedItem(_ btn : UIButton) {
        
        if btn !== lastBtn {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.selectedLabel.center    = CGPoint(x: btn.center.x, y: self.selectedLabel.center.y)
                self._index                  = btn.tag - 100
                }, completion: { (Bool) -> Void in
                    btn.setTitleColor(HexColor("#ff524f"), for: UIControl.State())
                    self.lastBtn.setTitleColor(HexColor("#333333"), for: UIControl.State())
                    self.lastBtn = btn
                    if self.needCall {
                        self.delegate.selectedItemForSegmentedBar(self, selectedSegmentedIndex: btn.tag - 100)
                    }else{
                        self.needCall            = true
                    }
            }) 
        }
    }
    
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
