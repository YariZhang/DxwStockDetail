//
//  StockInfoTableViewCell.swift
//  quchaogu
//
//  Created by zhangyr on 15/8/11.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

class StockInfoTableViewCell: UITableViewCell {

    var stockInfo           : StockInfo!
    var showType            : Int = 0
    fileprivate var stockName   : UILabel!
    fileprivate var stockCode   : UILabel!
    fileprivate var stockPrice  : UILabel!
    fileprivate var stockDetail : UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = Color("#fff")
        let selectedView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 50))
        selectedView.alpha = 0.8
        selectedView.backgroundColor = Color("#edeff0")
        self.selectedBackgroundView = selectedView
        
        stockName = UILabel()
        stockName.textColor = Color("#333")
        stockName.font = UIFont.normalFontOfSize(16)
        self.addSubview(stockName)
        stockName.snp.makeConstraints { (maker) in
            maker.left.equalTo(self).offset(12)
            maker.top.equalTo(self).offset(12)
            maker.height.equalTo(16)
            maker.width.equalTo(100)
        }
        stockCode = UILabel()
        stockCode.textColor = Color("#999")
        stockCode.font = UIFont.normalFontOfSize(12)
        self.addSubview(stockCode)
        stockCode.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.stockName)
            maker.top.equalTo(self.stockName.snp.bottom).offset(4)
            maker.height.equalTo(12)
            maker.width.equalTo(100)
        }
        stockPrice = UILabel()
        stockPrice.textAlignment = NSTextAlignment.center
        stockPrice.text = "--"
        stockPrice.textColor = Color("#333")
        stockPrice.font = UIFont.boldFontOfSize(18)
        self.addSubview(stockPrice)
        stockPrice.snp.makeConstraints { (maker) in
            maker.center.equalTo(self)
            maker.width.equalTo(100)
        }
        stockDetail = UILabel()
        stockDetail.font = UIFont.boldFontOfSize(18)
        stockDetail.text = "--"
        stockDetail.textAlignment = NSTextAlignment.right
        self.addSubview(stockDetail)
        stockDetail.snp.makeConstraints { (maker) in
            maker.right.equalTo(self).offset(-12)
            maker.centerY.equalTo(self)
            maker.width.equalTo(100)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if stockInfo == nil {
            return
        }
        
        let name = stockInfo.stockName
        let code = stockInfo.stockCode
        let price = stockInfo.stockPrice
        
        stockName.text = name
        stockCode.text = code
        stockPrice.text = String(format: "%.2f", price)
        switch showType {
        case 0 :
            var sCh = ""
            if stockInfo.stockPriceChange > 0 {
                sCh = "+"
            }
            stockPrice.textColor  = stockInfo.stockColor
            stockDetail.text      = String(format: "%@%.2f%%", sCh , stockInfo.stockPriceRate)
            stockDetail.textColor = stockInfo.stockColor
            if stockInfo.stockIsStop {
                stockDetail.text = "停牌"
                stockDetail.textColor = Color("#333")
            }
        case 1 :
            stockPrice.textColor  = Color("#333")
            stockDetail.text      = String(format: "%.2f%%", stockInfo.stockChangeRate)
            stockDetail.textColor = Color("#333")
        default :
            stockPrice.textColor  = Color("#333")
            stockDetail.text      = String(format: "%.2f%%", stockInfo.stockZf)
            stockDetail.textColor = Color("#333")
            
        }
        
    }
}
