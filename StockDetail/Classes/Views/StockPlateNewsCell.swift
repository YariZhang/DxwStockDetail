//
//  StockPlateNewsCell.swift
//  Subject
//
//  Created by zhangyr on 2016/11/9.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService
import TYAttributedLabel

protocol StockPlateNewsCellDelegate : NSObjectProtocol {
    func stockPlateNewsCellCheck(with url : String)
    func stockPlateNewsCellCheckStcok(with data: MainStockCardData)
}

class StockPlateNewsCell: UITableViewCell , TYAttributedLabelDelegate , SubjectCellStockViewDelegate {
    
    weak var delegate  : StockPlateNewsCellDelegate?
    
    var newsData        : StockPlateNewsItemData! {
        didSet {
            if newsData != nil {
                if newsData.type != "2" {
                    newsData.title  = ""
                }
                showData()
            }
        }
    }
    
    var needSep         : Bool = true {
        didSet {
            sepLine.isHidden    = !needSep
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle         = .none
        
        dateLabel                   = UILabel()
        dateLabel.font              = UIFont.normalFontOfSize(14)
        dateLabel.textColor         = Color("#999")
        self.addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self).offset(24)
            maker.top.equalTo(self).offset(15)
            maker.height.equalTo(17)
        }
        
        titleLabel                  = TYAttributedLabel()
        titleLabel.numberOfLines    = 2
        titleLabel.font             = UIFont.boldFontOfSize(16)
        titleLabel.textColor        = Color("#333")
        titleLabel.linesSpacing     = 5
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.dateLabel)
            maker.top.equalTo(self.dateLabel.snp.bottom).offset(1)
            maker.right.equalTo(self).offset(-24)
            maker.height.equalTo(0)
        }
        
        stocksView                  = UIView()
        stocksView.isHidden         = true
        self.addSubview(stocksView)
        stocksView.snp.makeConstraints { (maker) in
            maker.left.equalTo(titleLabel)
            maker.right.equalTo(titleLabel)
            maker.bottom.equalTo(self).offset(-15)
            maker.height.equalTo(0)
        }
        
        card1                       = SubjectCellStockView()
        card1.delegate              = self
        stocksView.addSubview(card1)
        card1.snp.makeConstraints { (maker) in
            maker.left.equalTo(stocksView)
            maker.top.equalTo(stocksView)
            maker.width.equalTo(140)
            maker.bottom.equalTo(stocksView)
        }
        
        card2                       = SubjectCellStockView()
        card2.delegate              = self
        stocksView.addSubview(card2)
        card2.snp.makeConstraints { (maker) in
            maker.left.equalTo(card1.snp.right)
            maker.top.equalTo(stocksView)
            maker.width.equalTo(140)
            maker.bottom.equalTo(stocksView)
        }
        
        descLabel                   = TYAttributedLabel()
        descLabel.delegate          = self
        descLabel.font              = UIFont.normalFontOfSize(15)
        descLabel.textColor         = Color("#333")
        descLabel.linesSpacing      = 6
        self.addSubview(descLabel)
        descLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.titleLabel)
            maker.right.equalTo(self.titleLabel)
            maker.bottom.equalTo(stocksView.snp.top).offset(-12)
            maker.height.equalTo(0)
        }
        
        sepLine                     = UIView()
        sepLine.backgroundColor     = Color("#ddd")
        self.addSubview(sepLine)
        
        sepLine.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.bottom.equalTo(self)
            maker.height.equalTo(0.5)
        }
        
    }
    
    fileprivate func showData() {
        
        dateLabel.text              = UtilDate.convertFormatByDate(date_time: newsData.pubdate, toFormat: "MM-dd")
        titleLabel.text             = newsData.title
        titleLabel.isHidden         = newsData.title.isEmpty
        descLabel.isHidden          = newsData.content.isEmpty
        if newsData.type == "2" {
            descLabel.numberOfLines = 2
            descLabel.lineBreakMode = .byTruncatingTail
            descLabel.text          = newsData.content
            descLabel.snp.remakeConstraints { (maker) in
                maker.left.equalTo(self.titleLabel)
                maker.right.equalTo(self.titleLabel)
                maker.bottom.equalTo(stocksView.snp.top).offset(-12)
                maker.height.equalTo(CGFloat(self.descLabel.getHeightWithWidth(SCREEN_WIDTH - 48)))
            }
            
        }else{
            descLabel.numberOfLines = 0
            descLabel.text          = newsData.content
            descLabel.snp.remakeConstraints { (maker) in
                maker.left.equalTo(self.titleLabel)
                maker.right.equalTo(self.titleLabel)
                maker.bottom.equalTo(self).offset(-15)
                maker.height.equalTo(CGFloat(self.descLabel.getHeightWithWidth(SCREEN_WIDTH - 48)))
            }
        }
        
        titleLabel.snp.updateConstraints { (maker) in
            maker.height.equalTo(newsData.titleHeight)
        }
        
        if newsData.stocks.isEmpty {
            stocksView.snp.updateConstraints({ (maker) in
                maker.height.equalTo(0)
            })
            stocksView.isHidden = true
        }else{
            stocksView.snp.updateConstraints({ (maker) in
                maker.height.equalTo(13)
            })
            stocksView.isHidden = false
            card1.data          = newsData.stocks[0]
            if newsData.stocks.count > 1 {
                card2.isHidden  = false
                card2.data      = newsData.stocks[1]
            }else{
                card2.isHidden  = true
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attributedLabel(_ attributedLabel: TYAttributedLabel!, textStorageClicked textStorage: TYTextStorageProtocol!, at point: CGPoint) {
        delegate?.stockPlateNewsCellCheck(with: newsData.url)
    }
    
    func subjectCellStockViewSelected(with data: MainStockCardData) {
        delegate?.stockPlateNewsCellCheckStcok(with: data)
    }
    
    fileprivate var dateLabel   : UILabel!
    fileprivate var titleLabel  : TYAttributedLabel!
    fileprivate var descLabel   : TYAttributedLabel!
    fileprivate var stocksView  : UIView!
    fileprivate var sepLine     : UIView!
    fileprivate var card1       : SubjectCellStockView!
    fileprivate var card2       : SubjectCellStockView!
}

protocol SubjectCellStockViewDelegate : class {
    func subjectCellStockViewSelected(with data : MainStockCardData)
}

class SubjectCellStockView : BaseView {
    
    weak var delegate       : SubjectCellStockViewDelegate?
    
    var data : MainStockCardData! {
        didSet{
            if data != nil {
                showData()
            }
        }
    }
    
    override func initUI() {
        super.initUI()
        
        stockName               = UILabel()
        stockName.font          = UIFont.boldFontOfSize(13 , needScale: true)
        stockName.textColor     = Color("#5c97d2")
        self.addSubview(stockName)
        stockName.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
        }
        
        stockRate               = UILabel()
        stockRate.font          = UIFont.boldFontOfSize(12 , needScale: true)
        stockRate.textAlignment = .right
        self.addSubview(stockRate)
        stockRate.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.stockName.snp.right).offset(4)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
        }
        
        button                  = BaseButton()
        button.addTarget(self, action: #selector(SubjectCellStockView.buttonClick), for: UIControl.Event.touchUpInside)
        self.addSubview(button)
        button.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
        }
        
    }
    
    fileprivate func showData() {
        stockName.text          = data.stockName
        stockRate.text          = data.rate
        stockRate.textColor     = data.color
    }
    
    @objc fileprivate func buttonClick() {
        delegate?.subjectCellStockViewSelected(with: data)
    }
    
    fileprivate var stockName : UILabel!
    fileprivate var stockRate : UILabel!
    fileprivate var button    : BaseButton!
}
