//
//  StockNewsCell.swift
//  quchaogu
//
//  Created by zhangyr on 16/6/6.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService
import SnapKit
import TYAttributedLabel

class StockNewsCell: UITableViewCell {

    var newsInfo : NSDictionary! {
        didSet {
            showData()
        }
    }
    fileprivate var titleLabel : TYAttributedLabel!
    fileprivate var timeLabel : UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = Color("#fff")
        self.selectionStyle = .none
        
        titleLabel = TYAttributedLabel()
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UtilColor.getTextBlackColor()
        titleLabel.font = UIFont.normalFontOfSize(14)
        titleLabel.numberOfLines = 2
        titleLabel.contentMode = .topLeft
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self).offset(12)
            maker.right.equalTo(self).offset(-40)
            maker.top.equalTo(self).offset(10)
            maker.height.equalTo(0)
        }
        timeLabel = HintLabel(frame: CGRect.zero, alignment: NSTextAlignment.right, title: "--", toView: self)
        timeLabel.snp.makeConstraints { (maker) in
            maker.right.equalTo(self).offset(-12)
            maker.bottom.equalTo(self).offset(-12)
            maker.height.equalTo(12)
        }
        let line = UILabel()
        line.backgroundColor = Color("#ddd")
        self.addSubview(line)
        line.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.bottom.equalTo(self)
            maker.height.equalTo(0.5)
        }
    }
    
    fileprivate func showData() {
        if newsInfo == nil {
            return
        }
        titleLabel.text = newsInfo["title"] + ""
        if let _ = newsInfo["para"] as? Dictionary<String , Any> {
            titleLabel.add(UIImage(named : "stock_plate_subject"), range: NSMakeRange(0, 0), size: CGSize(width: 30, height: 15))
        }
        titleLabel.snp.updateConstraints { (maker) in
            maker.height.equalTo(CGFloat(self.titleLabel.getHeightWithWidth(SCREEN_WIDTH - 24)))
        }
        let timeStr = UtilDate.convertFormatByDate("yyyyMMdd", date_time: newsInfo["pubdate"] + "", toFormat: "MM-dd")
        if timeStr == "错误时间" {
            timeLabel.text = UtilDate.formatTime("MM-dd", time_interval: Int(newsInfo["pubdate"] + "") ?? 0)
        }else{
            timeLabel.text = timeStr
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor    = UtilColor.getSeletedCellColor()
        }else{
            self.backgroundColor    = Color("#fff")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
