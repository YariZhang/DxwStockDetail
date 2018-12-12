//
//  StockDetailSegmentedControl.swift
//  Portfilio
//
//  Created by zhangyr on 15/5/7.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//
//  股票详情页的segmented
//

import Foundation
import UIKit

@objc protocol StockDetailSegmentedDelegate : NSObjectProtocol {
    
    @objc optional func stockSegmentedSelectedItem(_ seg : StockDetailSegmentedControl , selectedItemIndex : Int , selectedItemTitle : String?)
}

class StockDetailSegmentedControl: UISegmentedControl {
    
    fileprivate weak var delegate : StockDetailSegmentedDelegate?
   
    init(frame : CGRect , items : [AnyObject] , delegate : StockDetailSegmentedDelegate?) {
        super.init(items: items)
        self.frame = frame
        self.delegate = delegate
        self.tintColor = Color(COLOR_COMMON_RED)
        self.setTitleTextAttributes([NSAttributedString.Key(rawValue: convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)) : Color("#333") , NSAttributedString.Key(rawValue: convertFromNSAttributedStringKey(NSAttributedString.Key.font)) : UIFont.normalFontOfSize(14)], for: UIControl.State())
        self.setTitleTextAttributes([NSAttributedString.Key(rawValue: convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)) : UIColor.white , NSAttributedString.Key(rawValue: convertFromNSAttributedStringKey(NSAttributedString.Key.font)) : UIFont.normalFontOfSize(14)], for: UIControl.State.selected)
        self.addTarget(self, action: #selector(StockDetailSegmentedControl.segmentSelected(_:)), for: UIControl.Event.valueChanged)
        self.selectedSegmentIndex = 0
    }
    
    @objc func segmentSelected(_ seg : UISegmentedControl) {
        
        self.delegate?.stockSegmentedSelectedItem!(self, selectedItemIndex: self.selectedSegmentIndex, selectedItemTitle: self.titleForSegment(at: self.selectedSegmentIndex))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
