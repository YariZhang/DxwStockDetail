//
//  StockReportTableViewCell.swift
//  Subject
//
//  Created by zhangyr on 2016/11/8.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockReportTableViewCell: UITableViewCell {
    
    var reportData      : StockReportData! {
        didSet {
            if reportData != nil {
                showData()
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = Color("#fff")
        let selectedView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 50))
        selectedView.alpha = 0.8
        selectedView.backgroundColor = Color("#edeff0")
        self.selectedBackgroundView = selectedView
        
        orgNameLabel                = UILabel()
        orgNameLabel.font           = UIFont.normalFontOfSize(16)
        orgNameLabel.textColor      = Color("#333")
        self.addSubview(orgNameLabel)
        orgNameLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self).offset(12)
            maker.centerY.equalTo(self)
        }
        
        levelLable                  = UILabel()
        levelLable.font             = UIFont.normalFontOfSize(16)
        levelLable.textAlignment    = .center
        self.addSubview(levelLable)
        levelLable.snp.makeConstraints { (maker) in
            maker.center.equalTo(self)
        }
        
        dateLabel                   = UILabel()
        dateLabel.font              = UIFont.normalFontOfSize(16)
        dateLabel.textColor         = Color("#333")
        dateLabel.textAlignment     = .right
        self.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (maker) in
            maker.right.equalTo(self).offset(-12)
            maker.centerY.equalTo(self)
        }
        
    }
    
    fileprivate func showData() {
        orgNameLabel.text           = reportData.insname
        levelLable.text             = reportData.ratingText
        dateLabel.text              = UtilDate.convertFormatByDate("yyyyMMdd", date_time: reportData.pubdate, toFormat: "yyyy-MM-dd")
        switch reportData.ratingText {
        case "增持":
            levelLable.textColor    = Color("#ff480f")
        case "减持":
            levelLable.textColor    = Color("#009688")
        case "买入":
            levelLable.textColor    = Color("#ff7e00")
        case "卖出":
            levelLable.textColor    = Color("#2196f3")
        default:
            levelLable.textColor    = Color("#7e57c2")
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if !highlighted {
            self.selectedBackgroundView?.backgroundColor    = UIColor.clear
        }else{
            self.selectedBackgroundView?.backgroundColor    = Color("#edeff0")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var orgNameLabel : UILabel!
    fileprivate var levelLable   : UILabel!
    fileprivate var dateLabel    : UILabel!

}
