//
//  StockMarketViewController.swift
//  quchaogu
//
//  Created by zhangyr on 15/8/11.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService
import MJRefresh

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


open class StockMarketViewController: BaseViewController ,SelectedSegmentedBarDelegate , UITableViewDataSource , UITableViewDelegate , KLineViewChartDelegate ,TimeLineViewDelegate {

    fileprivate var tableView   : UITableView!
    
    //-----------------------------------
    //大显示区域高度
    fileprivate let BIG_AREA : CGFloat = 65
    fileprivate let K_LINE_HEIGHT : CGFloat = 225
    //-----------------------------------
    //当前价格
    fileprivate var currentPrice : UILabel!
    //升值信息
    fileprivate var appreciateInfo : UILabel!
    //今开价格
    fileprivate var todayOpen : UILabel!
    //昨收价格
    fileprivate var yesterdayClose : UILabel!
    //成交量
    fileprivate var dealVol : UILabel!
    //最高价格
    fileprivate var highPrice : UILabel!
    //最低价格
    fileprivate var lowPrice : UILabel!
    //振幅
    fileprivate var priceRate : UILabel!
    //成交额
    fileprivate var dealAmount : UILabel!
    //涨家数
    fileprivate var raiseCount : UILabel!
    //平家数
    fileprivate var normalCount : UILabel!
    //跌家数
    fileprivate var fallCount : UILabel!
    //-----------------------------------
    fileprivate var topSegment : SelectedSegmentedBar!
    fileprivate var backLabel : UILabel!
    fileprivate var kLineView : UIView!
    fileprivate var downView : UIView!
    fileprivate var headerView : UIView!
    fileprivate var timeView : TimeLineView! {
        didSet {
            if timeView != nil {
                timeView.delegate   = self
            }
        }
    }
    fileprivate var fiveDayView : TimeLineView! {
        didSet {
            if fiveDayView != nil {
                fiveDayView.delegate   = self
            }
        }
    }
    fileprivate var fullView : UIView!
    fileprivate var timeLine_full :  TimeLineView!
    fileprivate var fiveDayView_full : TimeLineView!
    fileprivate var segmented_full : SelectedSegmentedBar!
    fileprivate var headerView_full : UIView!
    fileprivate var stockName_full : UILabel!
    fileprivate var price_full : UILabel!
    fileprivate var vol_full : UILabel!
    fileprivate var timeLabel_full : UILabel!
    fileprivate var moreInfoView : StockMoreInfoView?
    //----------------------------------
    fileprivate var stocksInfo : Array<StockInfo>!
    fileprivate var agvDatas : NSArray!
    fileprivate var datas : NSArray!
    fileprivate var volDatas : NSArray!
    fileprivate var fiveDay_volDatas : NSArray!
    fileprivate var fiveDay_agvDatas : NSArray!
    fileprivate var fiveDay_datas : NSArray!
    fileprivate var fiveDay_dateArr : NSArray!
    //private var count : Int!
    fileprivate var timer : Timer!
    fileprivate var topType : String = "涨幅榜"
    //-----------------------------------
    
    fileprivate var infoLabel : UILabel!
    fileprivate var titleLabel : UILabel!
    fileprivate var openPrice : Float = 0
    fileprivate var prePrice : Float = 0 //五日数据前一天收盘价
    //private var is_tp : Bool = false
    fileprivate var is_dealDay : Bool = true
    fileprivate var smallSegIndex : Int = 0
    fileprivate var isFirst : Bool = true
    fileprivate var lineViewChart : CandleStickChartView!
    fileprivate var klineChart    : KLineViewChart?
    fileprivate var lineViewChartFull : CandleStickChartView!
    fileprivate var klineChartFull    : KLineViewChart?
    fileprivate var isZixuan: Bool = false {
        didSet {
            initZixuanItem()
        }
    }
    
    fileprivate var currentDate       : String = UtilDate.formatTime("yyyyMMdd", time_interval: UtilDate.getTimeInterval()) {
        didSet {
            klineChart?.currentDate = currentDate
            klineChartFull?.currentDate = currentDate
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "moveLine"), object: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView                       = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 64))
        self.view.addSubview(tableView)
        tableView.dataSource            = self
        tableView.delegate              = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.register(StockNewsCell.self, forCellReuseIdentifier: "newsCell")
        self.tableView.register(StockInfoTableViewCell.self, forCellReuseIdentifier: "stockCell")
        //self.sb_five = NSArray()
        initNaviBar()
        layoutHeaderView()
        NotificationCenter.default.addObserver(self, selector: #selector(StockMarketViewController.hideSegmented(_:)), name: NSNotification.Name(rawValue: "moveLine"), object: nil)
        if let index = IndexOfMarketChart {
            self.topSegment.setIndexWithAction(for: index)
        }
        
        if let index = IndexOfMarketInfo {
            if index == 0 {
                topType = "涨幅榜"
            }else if index == 1 {
                topType = "跌幅榜"
            }else{
                topType = "换手率榜"
            }
        }
        requestList()
        
        StockService.checkStockZxStatus(code: param?["code"] + "", completion: { (res) in
            if res?.resultCode == 10000 {
                self.isZixuan = res?.resultData + "" == "1"
            }else{
                self.isZixuan = false
            }
        }) { (error) in
            self.isZixuan = false
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    func initNaviBar() {
        
        autoreleasepool { () -> () in
            let naviView = UIView(frame: CGRect(x: 80, y: 0, width: self.tableView.bounds.width - 160, height: self.navigationController!.navigationBar.bounds.height))
            self.titleLabel = UILabel(frame: CGRect(x: 0, y: 4, width: naviView.bounds.width, height: 20))
            naviView.addSubview(self.titleLabel)
            self.titleLabel.textAlignment = NSTextAlignment.center
            self.titleLabel.textColor = Color("#fff")
            self.titleLabel.font = UIFont.normalFontOfSize(16)
            self.infoLabel = UILabel(frame: CGRect(x: 0, y: self.titleLabel.frame.maxY, width: self.titleLabel.bounds.width, height: naviView.bounds.height - 24))
            naviView.addSubview(self.infoLabel)
            self.infoLabel.textAlignment = NSTextAlignment.center
            self.infoLabel.textColor = Color(COLOR_COMMON_WHITE_80)
            self.infoLabel.font = UIFont.normalFontOfSize(10)
            self.navigationItem.titleView = naviView
            
            initZixuanItem()
        }
        showData()
    }
    
    func initZixuanItem() {
        var tagNum = 1
        var width : CGFloat = 60
        var titleStr = "+ 自选"
        var color = Color("#fff")
        
        if isZixuan {
            tagNum = 2
            width = 60
            titleStr = "删自选"
            color = Color(COLOR_COMMON_WHITE_80)
        }
        
        let rightView       = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 25))
        let refBtn          = UIButton(frame: CGRect(x: 8, y: 0, width: width, height: 25))
        refBtn.tag          = tagNum
        refBtn.contentMode  = .right
        refBtn.layer.borderWidth    = 0.5
        refBtn.layer.borderColor    = color.cgColor
        refBtn.layer.cornerRadius   = 3
        refBtn.addTarget(self, action: #selector(StockMarketViewController.addZixuan(_:)), for: UIControl.Event.touchUpInside)
        refBtn.setTitle(titleStr, for: UIControl.State())
        refBtn.titleLabel?.font = UIFont.normalFontOfSize(12)
        refBtn.setTitleColor(color, for: UIControl.State())
        rightView.addSubview(refBtn)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightView)
    }
    
    // MARK: 初始化头布局
    func layoutHeaderView() {
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 0))
        let topView = UIView(frame: CGRect(x: 0, y: -self.tableView.bounds.height, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
        topView.backgroundColor = Color("#fff")
        headerView.addSubview(topView)
        headerView.backgroundColor = Color("#fff")
        var heightCount : CGFloat = 0
        
        //左上当前价格显示区域
        let showBigArea = UIView(frame: CGRect(x: 0, y: 0, width: headerView.bounds.width / 2, height: BIG_AREA))
        headerView.addSubview(showBigArea)
        self.currentPrice = TextLabel(frame: CGRect(x: 5, y: 2, width: showBigArea.bounds.width - 10, height: (showBigArea.bounds.height - 4) / 4 * 3), alignment: NSTextAlignment.center , toView : showBigArea)
        self.currentPrice.font = UIFont.normalFontOfSize(40)
        self.currentPrice.text = "0.00"
        self.currentPrice.textColor = UtilColor.getTextBlackColor()
        self.backLabel = UILabel(frame: self.currentPrice.frame)
        self.backLabel.backgroundColor = UtilColor.getGreenStockColor()
        self.backLabel.alpha = 0
        showBigArea.addSubview(self.backLabel)
        showBigArea.bringSubviewToFront(self.currentPrice)
        
        self.appreciateInfo = TextLabel(frame: CGRect(x: 0, y: self.currentPrice.frame.maxY, width: showBigArea.bounds.width, height: self.currentPrice.bounds.height / 3), alignment: NSTextAlignment.center , toView : showBigArea)
        self.appreciateInfo.font = UIFont.normalFontOfSize(14)
        self.appreciateInfo.text = "0.00  0.00%"
        self.appreciateInfo.textColor = UtilColor.getTextBlackColor()
        
        //右上信息显示区域
        let rightTop = UIView(frame: CGRect(x: showBigArea.frame.maxX, y: 0, width: showBigArea.bounds.width, height: BIG_AREA))
        headerView.addSubview(rightTop)
        let to = HintLabel(frame: CGRect(x: 0, y: 5, width: rightTop.bounds.width / 3 * 2, height: (rightTop.bounds.height - 10) / 4), alignment: NSTextAlignment.left , title : "今开" , toView : rightTop)
        let yc = HintLabel(frame: CGRect(x: to.frame.maxX, y: 5, width: to.bounds.width / 2, height: to.bounds.height), alignment: NSTextAlignment.left , title : "昨收" , toView : rightTop)
        self.todayOpen = TextLabel(frame: CGRect(x: 0, y: to.frame.maxY, width: to.bounds.width, height: to.bounds.height), alignment: NSTextAlignment.left, toView: rightTop)
        self.todayOpen.text = "0.00"
        self.yesterdayClose = TextLabel(frame: CGRect(x: yc.frame.minX, y: yc.frame.maxY, width: yc.bounds.width, height: yc.bounds.height), alignment: NSTextAlignment.left, toView: rightTop)
        self.yesterdayClose.text = "0.00"
        let vol = HintLabel(frame: CGRect(x: 0, y: self.todayOpen.frame.maxY + 2, width: self.todayOpen.bounds.width, height: self.todayOpen.bounds.height), alignment: NSTextAlignment.left, title: "成交量", toView: rightTop)
        let ex = HintLabel(frame: CGRect(x: vol.frame.maxX, y: vol.frame.minY, width: self.yesterdayClose.bounds.width, height: self.yesterdayClose.bounds.height), alignment: NSTextAlignment.left, title: "振幅", toView: rightTop)
        self.dealVol = TextLabel(frame: CGRect(x: 0, y: vol.frame.maxY, width: vol.bounds.width, height: vol.bounds.height), alignment: NSTextAlignment.left, toView: rightTop)
        self.dealVol.text = "0手"
        self.priceRate = TextLabel(frame: CGRect(x: ex.frame.minX, y: ex.frame.maxY, width: ex.bounds.width, height: ex.bounds.height), alignment: NSTextAlignment.left, toView: rightTop)
        self.priceRate.text = "0.00%"
        //下方信息显示
        downView = UIView(frame: CGRect(x: 0, y: showBigArea.frame.maxY, width: headerView.bounds.width, height: BIG_AREA))
        headerView.addSubview(downView)
        
        let labelWidth = downView.bounds.width / 7.5
        let labelHeight = (downView.bounds.height - 10) / 3
        let hp = HintLabel(frame: CGRect(x: 0, y: 5, width: labelWidth, height: labelHeight), alignment: NSTextAlignment.center, title: "最  高", toView: downView)
        self.highPrice = TextLabel(frame: CGRect(x: hp.frame.maxX, y: hp.frame.minY, width: labelWidth * 1.5 , height: labelHeight), alignment: NSTextAlignment.right, toView: downView)
        self.highPrice.text = "0.00"
        let lp = HintLabel(frame: CGRect(x: self.highPrice.frame.maxX, y: hp.frame.minY, width: labelWidth, height: labelHeight), alignment: NSTextAlignment.center, title: "最  低", toView: downView)
        self.lowPrice = TextLabel(frame: CGRect(x: lp.frame.maxX, y: lp.frame.minY, width: labelWidth * 1.5, height: labelHeight), alignment: NSTextAlignment.right, toView: downView)
        self.lowPrice.text = "0.00"
        let da = HintLabel(frame: CGRect(x: self.lowPrice.frame.maxX + 4, y: lp.frame.minY, width: labelWidth - 6, height: labelHeight), alignment: NSTextAlignment.center, title: "成交额", toView: downView)
        self.dealAmount = TextLabel(frame: CGRect(x: da.frame.maxX, y: lp.frame.minY, width: labelWidth * 1.5 - 3, height: labelHeight), alignment: NSTextAlignment.right, toView: downView)
        self.dealAmount.text = "0"
        
        let ip = HintLabel(frame: CGRect(x: 0, y: hp.frame.maxY, width: labelWidth, height: labelHeight), alignment: NSTextAlignment.center, title: "涨家数", toView: downView)
        self.raiseCount = TextLabel(frame: CGRect(x: ip.frame.maxX, y: ip.frame.minY, width: labelWidth * 1.5 , height: labelHeight), alignment: NSTextAlignment.right, toView: downView)
        self.raiseCount.text = "0"
        let op = HintLabel(frame: CGRect(x: self.raiseCount.frame.maxX, y: ip.frame.minY, width: labelWidth, height: labelHeight), alignment: NSTextAlignment.center, title: "平家数", toView: downView)
        self.normalCount = TextLabel(frame: CGRect(x: op.frame.maxX, y: ip.frame.minY, width: labelWidth * 1.5, height: labelHeight), alignment: NSTextAlignment.right, toView: downView)
        self.normalCount.text = "0"
        let tw = HintLabel(frame: CGRect(x: self.normalCount.frame.maxX + 4, y: ip.frame.minY, width: labelWidth - 6, height: labelHeight), alignment: NSTextAlignment.center, title: "跌家数", toView: downView)
        self.fallCount = TextLabel(frame: CGRect(x: tw.frame.maxX, y: ip.frame.minY, width: labelWidth * 1.5 - 3, height: labelHeight), alignment: NSTextAlignment.right, toView: downView)
        self.fallCount.text = "0"
        
        downView.frame.size.height = fallCount.frame.maxY + 5
        
        heightCount += BIG_AREA + downView.bounds.height
        
        let sep1 = UIView(frame: CGRect(x: 0, y: downView.bounds.size.height - 0.5, width: headerView.bounds.width, height: 0.5))
        sep1.backgroundColor = Color("#ddd")
        downView.addSubview(sep1)
        
        kLineView = UIView(frame: CGRect(x: 0, y: downView.frame.maxY, width: headerView.bounds.width, height: K_LINE_HEIGHT + 46))
        kLineView.backgroundColor = Color("#fff")
        headerView.addSubview(kLineView)
        
        topSegment = SelectedSegmentedBar(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 38), items: ["分时" as AnyObject,"五日" as AnyObject,"日K" as AnyObject,"周K" as AnyObject , "月K" as AnyObject], delegate: self)
        topSegment.tag = 10
        
        timeView = TimeLineView(frame: CGRect(x: 10, y: 48, width: kLineView.bounds.width - 20, height: (kLineView.bounds.height - 76) / 3 * 2), move : true , isMarket : true , isPortrait : true)
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(StockMarketViewController.usingFullScreen(_:)))
        kLineView.addGestureRecognizer(tapGR)
        timeView.open = openPrice
        kLineView.addSubview(timeView)
        kLineView.addSubview(topSegment)
        
        heightCount += K_LINE_HEIGHT + 46
        
        headerView.frame.size.height = heightCount
        self.tableView.tableHeaderView = headerView
        
        self.setupRefresh()
    }
    
    @objc func addZixuan(_ btn : UIButton) {
        if btn.tag == 1 {
            btn.setTitle("删自选", for: UIControl.State())
            btn.setTitleColor(Color(COLOR_COMMON_WHITE_80), for: UIControl.State())
            btn.layer.borderColor = Color(COLOR_COMMON_WHITE_80).cgColor
            btn.tag = 2
            StockUtil.addStock(code: param?["code"] + "")
        }else{
            btn.setTitle("+ 自选", for: UIControl.State())
            btn.setTitleColor(Color("#fff"), for: UIControl.State())
            btn.layer.borderColor = Color("#fff").cgColor
            btn.tag = 1
            StockUtil.deleteStock(code: param?["code"] + "")
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshAction()
    }
    
    
    //MARK: 全屏显示
    @objc func usingFullScreen(_ tap : UITapGestureRecognizer) {
        Behavior.eventReport("dianji_tu")
        hideStatusBar(true)
        tap.isEnabled             = false
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            if self.timeView != nil {
                self.timeView.frame.origin.x -= self.timeView.frame.size.width + 10
            }else if self.lineViewChart != nil {
                self.lineViewChart.frame.origin.x -= self.kLineView.bounds.width
            }else{
                self.fiveDayView.frame.origin.x -= self.kLineView.bounds.width
            }
            }, completion: { (Bool) -> Void in
                tap.isEnabled     = true
                self.navigationController?.isNavigationBarHidden = true
                self.fullView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: SCREEN_HEIGHT))
                self.fullView.backgroundColor = Color("#fff")
                self.view.addSubview(self.fullView)
                self.tableView.isScrollEnabled = false
                self.headerView_full = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_HEIGHT, height: 50))
                self.headerView_full.center = CGPoint(x: SCREEN_WIDTH - 25, y: SCREEN_HEIGHT / 2)
                let spW = (self.headerView_full.bounds.width - 80) / 4
                self.stockName_full = TextLabel(frame: CGRect(x: 0, y: 0, width: spW, height: 24), alignment: NSTextAlignment.center, toView: self.headerView_full ,fontSize : 16)
                self.stockName_full.textColor = UtilColor.getTextBlackColor()
                self.stockName_full.text = self.param?["name"] + ""
                self.price_full = TextLabel(frame: CGRect(x: self.stockName_full.frame.maxX, y: 0, width: spW, height: 24), alignment: NSTextAlignment.center, toView: self.headerView_full , fontSize : 14)
                self.price_full.text = self.currentPrice.text
                self.price_full.textColor = self.currentPrice.textColor
                let vl = HintLabel(frame: CGRect(x: self.price_full.frame.maxX, y: 0, width: 30, height: 24), alignment: NSTextAlignment.left, title: "成交", toView: self.headerView_full, fontSize : 14)
                self.vol_full = TextLabel(frame: CGRect(x: vl.frame.maxX, y: 0, width: spW, height: 24), alignment: NSTextAlignment.center, toView: self.headerView_full, fontSize : 14)
                self.vol_full.text = self.dealVol.text
                let tl = HintLabel(frame: CGRect(x: self.vol_full.frame.maxX, y: 0, width: 30, height: 24), alignment: NSTextAlignment.left, title: "时间", toView: self.headerView_full, fontSize : 14)
                self.timeLabel_full = TextLabel(frame: CGRect(x: tl.frame.maxX, y: 0, width: spW, height: 24), alignment: NSTextAlignment.center, toView: self.headerView_full, fontSize : 14)
                self.timeLabel_full.text = UtilDate.formatTime("HH:mm", time_interval: UtilDate.getTimeInterval())
                let closeBtn = UIButton(frame: CGRect(x: self.timeLabel_full.frame.maxX - 15, y: 0, width: 30, height: 30))
                closeBtn.setImage(UIImage(named: "stock_cancel"), for: UIControl.State())
                closeBtn.addTarget(self, action: #selector(StockMarketViewController.closeFullView), for: UIControl.Event.touchUpInside)
                self.headerView_full.addSubview(closeBtn)
                self.segmented_full = SelectedSegmentedBar(frame: CGRect(x: 0, y: 24, width: self.headerView_full.bounds.width, height: 25), items: ["分时" as AnyObject,"五日" as AnyObject,"日K" as AnyObject,"周K" as AnyObject,"月K" as AnyObject], delegate: self)
                self.segmented_full.tag = 20
                self.headerView_full.addSubview(self.segmented_full)
                self.segmented_full.backgroundColor = Color("#fff")
                self.timeLine_full = TimeLineView(frame: CGRect(x:10, y:0, width: SCREEN_HEIGHT - 20, height: (SCREEN_WIDTH - 80) / 3 * 2) , move : true , isMarket : true)
                self.timeLine_full.center = CGPoint(x: self.fullView.bounds.width / 2 + (self.timeLine_full.bounds.height / 2) / 2 - 10, y: self.fullView.center.y)
                //self.timeLine_full.center = CGPointMake(self.fullView.bounds.width / 2 + (self.timeLine_full.bounds.height / 2) / 2 - 10, self.fullView.bounds.height / 2 - ((SCREEN_HEIGHT - 20) / 4 + 10) / 2)
                self.fullView.addSubview(self.timeLine_full)
                self.fullView.addSubview(self.headerView_full)
                self.timeLine_full.open = self.openPrice
                self.timeLine_full.toOpen = (self.todayOpen.text! as NSString).floatValue
                self.timeLine_full.datas = self.datas
                self.timeLine_full.volDatas = self.volDatas
                self.timeLine_full.agvDatas = self.agvDatas
                //self.timeLine_full.sb_five = self.sb_five
                self.timeLine_full.stock_code = self.param?["code"] + ""
                self.timeLine_full.isDraw = self.datas == nil
                self.timeLine_full.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                self.headerView_full.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                if self.smallSegIndex != 0 {
                    self.selectedItemForSegmentedBar(self.segmented_full, selectedSegmentedIndex: self.smallSegIndex)
                    self.segmented_full.index = self.smallSegIndex
                }else{
                    
                    self.timeLine_full.transform = self.timeLine_full.transform.translatedBy(x: 0, y: self.fullView.bounds.height)
                    self.headerView_full.transform = self.headerView_full.transform.translatedBy(x: -self.headerView_full.bounds.height, y: 0)
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.timeLine_full.transform = self.timeLine_full.transform.translatedBy(x: 0, y: -self.fullView.bounds.height)
                        self.headerView_full.transform = self.headerView_full.transform.translatedBy(x: self.headerView_full.bounds.height, y: 0)
                    })
                    
                }
                let panGr       = UIPanGestureRecognizer(target: nil, action: #selector(StockMarketViewController.closeFullView))
                panGr.delegate  = self
                self.fullView.addGestureRecognizer(panGr)
        })
    }
    
    @objc func hideSegmented(_ noti : Notification) {
        let userInfo = ((noti as NSNotification).userInfo! as NSDictionary).object(forKey: "isMove") as! Bool
        if segmented_full == nil {
            if moreInfoView == nil {
                moreInfoView    = StockMoreInfoView(frame: CGRect(x: topSegment.frame.minX, y: topSegment.frame.minY, width: topSegment.bounds.width, height: 48))
                kLineView.addSubview(moreInfoView!)
            }
            kLineView.bringSubviewToFront(moreInfoView!)
            moreInfoView?.isHidden   = !userInfo
        }else{
            self.segmented_full.isHidden = userInfo
        }
    }
    
    @objc func closeFullView() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            var rect = CGRect.zero
            if self.timeLine_full != nil {
                rect = self.timeLine_full.frame
                rect.origin.y = -self.fullView.bounds.height
                self.timeLine_full.frame = rect
            }
            if self.lineViewChartFull != nil {
                rect = self.lineViewChartFull.frame
                rect.origin.y = -self.fullView.bounds.height
                self.lineViewChartFull.frame = rect
            }
            if self.fiveDayView_full != nil {
                rect = self.fiveDayView_full.frame
                rect.origin.y = -self.fullView.bounds.height
                self.fiveDayView_full.frame = rect
            }
            self.headerView_full.frame.origin.x += self.headerView_full.frame.size.width
            }, completion: { (Bool) -> Void in
                if self.timeLine_full != nil {
                    self.timeLine_full.removeFromSuperview()
                    self.timeLine_full = nil
                }
                if self.lineViewChartFull != nil {
                    self.lineViewChartFull.removeFromSuperview()
                }
                if self.fiveDayView_full != nil {
                    self.fiveDayView_full.removeFromSuperview()
                    self.fiveDayView_full = nil
                }
                self.segmented_full.removeFromSuperview()
                self.segmented_full  = nil
                self.headerView_full.removeFromSuperview()
                self.headerView_full = nil
                self.fullView.removeFromSuperview()
                self.fullView = nil
                self.navigationController?.isNavigationBarHidden = false
                self.hideStatusBar(false)
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    if self.timeView != nil {
                        self.timeView.frame.origin.x += self.timeView.frame.size.width + 10
                    }else if self.lineViewChart != nil {
                        self.lineViewChart.frame.origin.x += self.kLineView.bounds.width
                    }else{
                        self.fiveDayView.frame.origin.x += self.kLineView.bounds.width
                    }
                })
        }) 
        self.tableView.isScrollEnabled = true
    }
    
    //MARK: 刷新数据
    @objc func refreshAction() {
        //println("刷新")
        UserDefaults.standard.set(Date(), forKey: "RefreshHeaderView")
        UserDefaults.standard.synchronize()
        StockService.getStockCurrentInfoWithCode(param?["code"] + "", completion: { (bsd) -> Void in
            if bsd!.resultCode! == 10000 {
                if let data = bsd!.resultData as? NSDictionary {
                    self.parseJsonData(data)
                }
                self.tableView.mj_footer?.endRefreshing()
            }else{
                self.tableView.mj_footer?.endRefreshing()
            }
            }) { (error) -> Void in
                self.tableView.mj_footer?.endRefreshing()
        }
        
        requestList()
        
        if UtilCheck.isDealTime() == 2 && self.timer == nil && is_dealDay && glStockNetRefreshPeriod > 0.5 {
            //println("开启数据刷新")
            weak var weakSelf = self
            self.timer = Timer.scheduledTimer(timeInterval: glStockNetRefreshPeriod, target: weakSelf!, selector: #selector(StockMarketViewController.refreshAction), userInfo: nil, repeats: true)
        }else{
            //println("开启数据刷新条件不足")
            if self.timer != nil && (UtilCheck.isDealTime() != 2 || !is_dealDay ) {
                self.timer.invalidate()
                self.timer = nil
            }
        }
    }
    
    //未开盘 1
    //交易中 2
    //午间休市 3
    //已收盘 4
    func parseJsonData(_ data : NSDictionary) {
        //println(data)
        let stock_info = data["stock_info"] as! NSDictionary
        currentDate    = stock_info["date"] + ""
        var stock_min  = NSArray()
        if let tmp_min = data["stock_min"] as? NSArray {
            stock_min = tmp_min
        }
        let name = stock_info["name"] + ""
        _ = param?.updateValue(name as AnyObject, forKey: "name")
        let code = stock_info["code"] + ""
        self.titleLabel.text = name + "(\(code))"
        let isTrading = data.parseNumber("istradingday", numberType: ParseNumberType.int) as! Int
        is_dealDay = isTrading == 1
        showStockInfo(stock_info)
        
        var isDeal = ""
        switch UtilCheck.isDealTime() {
        case 1:
            isDeal = "未开盘"
        case 2:
            isDeal = "交易中"
        case 3:
            isDeal = "午间休市"
        default:
            isDeal = "已收盘"
        }
        if !is_dealDay {
            isDeal = "休市中"
        }
        self.infoLabel.text = isDeal + " " + UtilDate.formatTime("MM-dd HH:mm:ss", time_interval: UtilDate.getTimeInterval())
        
        showTimeInfo(stock_min)
        
    }
    
    func showStockInfo(_ stock_info : NSDictionary) {
        //println(stock_info)
        
        self.yesterdayClose.text = stock_info["pre_close"] + ""
        let price = stock_info.parseNumber("price", numberType: ParseNumberType.float) as! Float
        let preP = (self.currentPrice.text! as NSString).floatValue
        self.openPrice = stock_info.parseNumber("pre_close", numberType: ParseNumberType.float) as! Float
        let p_change = stock_info["p_change"] + ""
        let price_change = stock_info["price_change"] + ""
        klineChart?.pChange = Float(p_change) ?? 0
        klineChartFull?.pChange = Float(p_change) ?? 0
        klineChart?.todayPrice = price
        klineChartFull?.todayPrice = price
        
        if price > self.openPrice {
            self.currentPrice.textColor = UtilColor.getRedTextColor()
            self.appreciateInfo.textColor = UtilColor.getRedTextColor()
        }else if price == self.openPrice {
            self.currentPrice.textColor = UtilColor.getTextBlackColor()
            self.appreciateInfo.textColor = UtilColor.getTextBlackColor()
        }else{
            self.currentPrice.textColor = UtilColor.getGreenColor()
            self.appreciateInfo.textColor = UtilColor.getGreenColor()
        }
        var symbol = ""
        if Double(price_change) > 0.001 {
            symbol = "+"
        }
        if preP != 0 && price != preP {
            if preP > price {
                self.backLabel.backgroundColor = UtilColor.getGreenStockColor()
            }else{
                self.backLabel.backgroundColor = UtilColor.getRedStockColor()
            }
            UIView.animateKeyframes(withDuration: 0.5, delay: 0.5, options: UIView.KeyframeAnimationOptions.overrideInheritedDuration, animations: { () -> Void in
                self.backLabel.alpha = 1
                }) { (Bool) -> Void in
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.backLabel.alpha = 0
                        }, completion: { (Bool) -> Void in
                            self.currentPrice.text   = stock_info["price"] as? String
                            if price >= 10000 {
                                self.currentPrice.font   = UIFont.normalFontOfSize(32)
                            }else{
                                self.currentPrice.font   = UIFont.normalFontOfSize(36)
                            }
                            self.appreciateInfo.text = "\(symbol + price_change)  \(symbol + p_change)%"
                    })
            }
        }else{
            self.currentPrice.text = stock_info["price"] as? String
            if price >= 10000 {
                self.currentPrice.font = UIFont.normalFontOfSize(32)
            }else{
                self.currentPrice.font = UIFont.normalFontOfSize(36)
            }
            self.appreciateInfo.text = "\(symbol + price_change)  \(symbol + p_change)%"
        }
        self.todayOpen.text = stock_info["open"] + ""
        self.highPrice.text = stock_info["high"] + ""
        self.lowPrice.text = stock_info["low"] + ""
        self.dealVol.text = UtilTools.formatTotalAmount(CGFloat(stock_info.parseNumber("volume", numberType: ParseNumberType.float) as! Float / 100)) + "手"
        self.dealAmount.text = UtilTools.formatTotalAmount(CGFloat(stock_info.parseNumber("amount", numberType: ParseNumberType.float) as! Float))
        let zf = stock_info.parseNumber("zf", numberType: ParseNumberType.float) as! Float
        self.priceRate.text = String(format: "%.2f%%", zf)
        
        let raise = stock_info.parseNumber("rise_count", numberType: ParseNumberType.int) as! Int
        self.raiseCount.text = "\(raise)"
        let normal = stock_info.parseNumber("flat_count", numberType: ParseNumberType.int) as! Int
        self.normalCount.text = "\(normal)"
        let fall = stock_info.parseNumber("fall_count", numberType: ParseNumberType.int) as! Int
        self.fallCount.text = "\(fall)"
        
    }
    
    func showTimeInfo(_ stock_min : NSArray){
        let timePrice = NSMutableArray()
        let timeVolume = NSMutableArray()
        let timeAvg = NSMutableArray()
        for d in stock_min {
            let dic = d as! NSDictionary
            let bs = dic.parseNumber("bs", numberType: ParseNumberType.int) as! Int
            let volume = dic["volume"] + ""
            if bs == 2 {
                timeVolume.add("-" + volume)
            }else{
                timeVolume.add(volume)
            }
            let price = dic["price"] + ""
            let min = dic.parseNumber("min", numberType: ParseNumberType.int) as! Int
            let avg_p = dic["average_price"] + ""
            if stock_min.index(of: d) == 0 {
                timePrice.add([self.todayOpen.text! , "\(min)"])
                if Int(self.todayOpen.text!) > 0 {
                    timeAvg.add(self.todayOpen.text!)
                }else{
                    timeAvg.add(avg_p)
                }
            }else{
                timePrice.add([price , "\(min)"])
                timeAvg.add(avg_p)
            }
        }
        self.datas = timePrice
        self.volDatas = timeVolume
        self.agvDatas = timeAvg
        
        if timeView != nil {
            self.timeView.open = self.openPrice
            self.timeView.toOpen = (self.todayOpen.text! as NSString).floatValue
            self.timeView.datas = self.datas
            self.timeView.volDatas = self.volDatas
            self.timeView.agvDatas = self.agvDatas
            //self.timeView.sb_five = self.sb_five
            self.timeView.isDraw = self.datas == nil
            self.timeView.setNeedsDisplay()
        }
        if self.timeLine_full != nil {
            //println("全屏数据刷新")
            self.timeLine_full.open = self.openPrice
            self.timeLine_full.toOpen = (self.todayOpen.text! as NSString).floatValue
            self.timeLine_full.datas = self.datas
            self.timeLine_full.volDatas = self.volDatas
            self.timeLine_full.agvDatas = self.agvDatas
            //self.timeLine_full.sb_five = self.sb_five
            self.timeLine_full.isDraw = self.datas == nil
            self.timeLine_full.setNeedsDisplay()
        }
        if self.fullView != nil {
            self.price_full.text = self.currentPrice.text
            self.price_full.textColor = self.currentPrice.textColor
            self.vol_full.text = self.dealVol.text
        }
    }
    
    func showData() {
        let name = param?["name"] + ""
        let code = param?["code"] + ""
        
        self.titleLabel.text = name + "(\(code))"
        self.infoLabel.text = "------"
    }
    // MARK: - Table view data source
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stocksInfo == nil {
            return 0
        }
        return stocksInfo.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell", for: indexPath) as! StockInfoTableViewCell
        cell.backgroundColor = Color("#fff")
        cell.stockInfo = stocksInfo[(indexPath as NSIndexPath).row]
        cell.showType  = 0
        if topType == "换手率榜" {
            cell.showType = 1
        }
        return cell
        
    }
    
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let hv = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 48))
        hv.backgroundColor = Color("#edeef0")
        let sep1 = UIView(frame: CGRect(x: 0, y: 9.5, width: hv.bounds.width, height: 0.5))
        sep1.backgroundColor = Color("#ddd")
        hv.addSubview(sep1)
        var seg : SelectedSegmentedBar!
        seg = SelectedSegmentedBar(frame: CGRect(x: 0, y: 10, width: hv.bounds.width, height: 38), items: ["涨幅榜" as AnyObject,"跌幅榜" as AnyObject,"换手率榜" as AnyObject], delegate: self)
        seg.tag = 30
        switch topType {
        case "涨幅榜" :
            seg.index = 0
        case "跌幅榜" :
            seg.index = 1
        case "换手率榜" :
            seg.index = 2
        default :
            logPrint("其他")
        }
        hv.addSubview(seg)
        return hv
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stock_info = stocksInfo[(indexPath as NSIndexPath).row]
        let info = ["name" : stock_info.stockName , "code" : stock_info.stockCode]
        self.navigationController?.pushStockDetailController(info as Dictionary<String, AnyObject>, animated: true)
    }
    
    func timeLineViewMoreInfo(with data: PointInfo) {
        moreInfoView?.show(with: data, isK: false)
    }
    
    func kLineViewMoreInfo(with data: KLineData) {
        moreInfoView?.show(with: data, isK: true)
    }
    
    // MARK: - refreshControl
    
    func setupRefresh() {
        weak var blockSelf = self
        self.tableView.mj_header = MJRefreshGifHeader(headerRefreshingBlock: {
            Behavior.eventReport("xiala_zuixin")
            blockSelf?.refreshData()
        })
    }
    
    // MARK: - Segment Delegate
    
    func selectedItemForSegmentedBar(_ segmentedBar: SelectedSegmentedBar, selectedSegmentedIndex: Int) {
        
        if segmentedBar.tag == 10 || segmentedBar.tag == 20 {
            if segmentedBar.tag == 10 {
                IndexOfMarketChart = selectedSegmentedIndex
            }
            switch selectedSegmentedIndex {
            case 0:
                //println("分时")
                Behavior.eventReport("fenshi")
                if segmentedBar !== self.segmented_full {
                    self.smallSegIndex = selectedSegmentedIndex
                    if lineViewChart != nil {
                        lineViewChart.removeFromSuperview()
                    }
                    if fiveDayView != nil {
                        fiveDayView.removeFromSuperview()
                    }
                    if timeView == nil {
                        timeView = TimeLineView(frame: CGRect(x: 10, y: 48, width:kLineView.bounds.width - 20, height: (kLineView.bounds.height - 76) / 3 * 2), move : true , isMarket : true , isPortrait : true)
                        timeView.open = openPrice
                        kLineView.addSubview(timeView)
                    }else{
                        kLineView.addSubview(timeView)
                    }
                    kLineView.bringSubviewToFront(topSegment)
                    
                    refreshAction()
                }
                if segmentedBar === self.segmented_full {
                    //println("执行全屏分时")
                    if lineViewChartFull != nil {
                        lineViewChartFull.removeFromSuperview()
                    }
                    if fiveDayView_full != nil {
                        self.fiveDayView_full.removeFromSuperview()
                    }
                    
                    if timeLine_full == nil {
                        self.timeLine_full = TimeLineView(frame: CGRect(x:20, y:0, width: SCREEN_HEIGHT - 20, height: (SCREEN_WIDTH - 80) / 3 * 2) , move : true , isMarket : true)
                        self.timeLine_full.center = CGPoint(x: self.fullView.bounds.width / 2 + (self.timeLine_full.bounds.height / 2) / 2 - 10, y: self.fullView.center.y)
                        self.fullView.addSubview(self.timeLine_full)
                        self.fullView.bringSubviewToFront(self.headerView_full)
                        self.timeLine_full.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                    }else{
                        self.fullView.addSubview(self.timeLine_full)
                        self.fullView.bringSubviewToFront(self.headerView_full)
                    }
                    self.timeLine_full.open = self.openPrice
                    self.timeLine_full.toOpen = (self.todayOpen.text! as NSString).floatValue
                    self.timeLine_full.datas = self.datas
                    self.timeLine_full.volDatas = self.volDatas
                    self.timeLine_full.agvDatas = self.agvDatas
                    //self.timeLine_full.sb_five = self.sb_five
                    self.timeLine_full.stock_code = param?["code"] + ""
                    self.timeLine_full.isDraw = self.datas == nil
                    refreshAction()
                }
            case 1:
                //println("五日")
                Behavior.eventReport("wuri")
                var v : UIView!
                
                if segmentedBar !== self.segmented_full {
                    self.smallSegIndex = selectedSegmentedIndex
                    if lineViewChart != nil {
                        lineViewChart.removeFromSuperview()
                    }
                    if timeView != nil {
                        timeView.removeFromSuperview()
                    }
                    
                    if fiveDayView == nil {
                        fiveDayView = TimeLineView(frame: CGRect(x: 10, y: 48, width: kLineView.bounds.width - 20, height: (kLineView.bounds.height - 76) / 3 * 2), move : true ,isFive : true , isPortrait : true)
                        kLineView.addSubview(fiveDayView)
                    }else{
                        kLineView.addSubview(fiveDayView)
                    }
                    kLineView.bringSubviewToFront(topSegment)
                    
                    self.fiveDayView.open = self.prePrice
                    self.fiveDayView.toOpen = (self.todayOpen.text! as NSString).floatValue
                    self.fiveDayView.datas = self.fiveDay_datas
                    self.fiveDayView.volDatas = self.fiveDay_volDatas
                    self.fiveDayView.agvDatas = self.fiveDay_agvDatas
                    self.fiveDayView.dateArr = self.fiveDay_dateArr
                    self.fiveDayView.stock_code = param?["code"] + ""
                    self.fiveDayView.isDraw = self.fiveDay_datas == nil
                    v = fiveDayView
                }
                if segmentedBar === self.segmented_full {
                    //println("执行全屏五日")
                    if lineViewChartFull != nil {
                        lineViewChartFull.removeFromSuperview()
                    }
                    if timeLine_full != nil {
                        self.timeLine_full.removeFromSuperview()
                    }
                    if fiveDayView_full == nil {
                        fiveDayView_full = TimeLineView(frame: CGRect(x:20, y:10, width: SCREEN_HEIGHT - 20, height: (SCREEN_WIDTH - 80) / 3 * 2) , move : true , isFive :true)
                        self.fiveDayView_full.center = CGPoint(x: self.fullView.bounds.width / 2 + (self.fiveDayView_full.bounds.height / 2) / 2 - 10, y: self.fullView.center.y)
                        self.fullView.addSubview(self.fiveDayView_full)
                        self.fullView.bringSubviewToFront(self.headerView_full)
                        self.fiveDayView_full.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                    }else{
                        self.fullView.addSubview(self.fiveDayView_full)
                        self.fullView.bringSubviewToFront(self.headerView_full)
                    }
                    self.fiveDayView_full.open = self.prePrice
                    self.fiveDayView_full.toOpen = (self.todayOpen.text! as NSString).floatValue
                    self.fiveDayView_full.datas = self.fiveDay_datas
                    self.fiveDayView_full.volDatas = self.fiveDay_volDatas
                    self.fiveDayView_full.agvDatas = self.fiveDay_agvDatas
                    self.fiveDayView_full.dateArr = self.fiveDay_dateArr
                    self.fiveDayView_full.stock_code = self.param?["code"] + ""
                    self.fiveDayView_full.isDraw = self.fiveDay_datas == nil
                    v = fiveDayView_full
                }
                if fiveDay_datas == nil || fiveDay_datas.count < 61 * 5 {
                    StockService.getStockTimeFiveWithCode(param?["code"] + "", completion: { (bsd) -> Void in
                        
                        if bsd!.resultCode! == 10000 {
                            if let data = bsd!.resultData as? NSDictionary {
                                self.parseFiveDayData(data)
                            }
                        }else{
                            UtilTools.noticError(view: v, msg: bsd!.errorMsg!, offset: 0)
                        }
                        
                        }, failure: { (error) -> Void in
                            UtilTools.noticError(view: v, msg: error!.msg!, offset: 0)
                    })
                }
            case 2:
                Behavior.eventReport("rixian")
                if segmentedBar !== self.segmented_full {
                    self.smallSegIndex = selectedSegmentedIndex
                    if timeView != nil {
                        timeView.removeFromSuperview()
                    }
                    if fiveDayView != nil {
                        fiveDayView.removeFromSuperview()
                    }
                    
                    if lineViewChart != nil {
                        lineViewChart.removeFromSuperview()
                        lineViewChart = nil
                    }
                    
                    lineViewChart = CandleStickChartView(frame: CGRect(x: 0, y: 40, width: kLineView.bounds.width, height: kLineView.bounds.height - 50))
                    kLineView.addSubview(lineViewChart)
                    klineChart = KLineViewChart(chartView: lineViewChart, delegate: self, reqCode: self.param?["code"] + "", reqType: "D", isFull: true , currentDate : currentDate)
                
                }else{
                    //println("执行全屏K线")
                    createKLineView("D")
                }
            case 3:
                Behavior.eventReport("zhouxian")
                if segmentedBar !== self.segmented_full {
                    self.smallSegIndex = selectedSegmentedIndex
                    if timeView != nil {
                        timeView.removeFromSuperview()
                    }
                    if fiveDayView != nil {
                        fiveDayView.removeFromSuperview()
                    }
                    
                    if lineViewChart != nil {
                        lineViewChart.removeFromSuperview()
                        lineViewChart = nil
                    }
                    lineViewChart = CandleStickChartView(frame: CGRect(x: 0, y: 40, width: kLineView.bounds.width, height: kLineView.bounds.height - 50))
                    kLineView.addSubview(lineViewChart)
                    klineChart = KLineViewChart(chartView: lineViewChart, delegate: self, reqCode: self.param?["code"] + "", reqType: "W", isFull: true , currentDate : currentDate)
                    
                }else{
                    createKLineView("W")
                }
            case 4:
                Behavior.eventReport("yuexian")
                if segmentedBar !== self.segmented_full {
                    self.smallSegIndex = selectedSegmentedIndex
                    if timeView != nil {
                        timeView.removeFromSuperview()
                    }
                    if fiveDayView != nil {
                        fiveDayView.removeFromSuperview()
                    }
                    
                    if lineViewChart != nil {
                        lineViewChart.removeFromSuperview()
                        lineViewChart = nil
                    }
                    lineViewChart = CandleStickChartView(frame: CGRect(x: 0, y: 40, width: kLineView.bounds.width, height: kLineView.bounds.height - 50))
                    kLineView.addSubview(lineViewChart)
                    klineChart = KLineViewChart(chartView: lineViewChart, delegate: self, reqCode: self.param?["code"] + "", reqType: "M", isFull: true,currentDate : currentDate)
                    
                }else{
                    createKLineView("M")
                }
            default :
                logPrint("")
            }
        }else if segmentedBar.tag == 30 {
            IndexOfMarketInfo = selectedSegmentedIndex
            switch selectedSegmentedIndex {
            case 0 :
                Behavior.eventReport("zhangfubang")
                self.topType = "涨幅榜"
            case 1 :
                Behavior.eventReport("diefubang")
                self.topType = "跌幅榜"
            default :
                Behavior.eventReport("huanshoulvbang")
                self.topType = "换手率榜"
            }
            requestList()
        }else{
            logPrint("其他")
        }
        
    }
    
    func parseFiveDayData(_ dic : NSDictionary) {
        
        let timePrice = NSMutableArray()
        let timeVolume = NSMutableArray()
        let timeAvg = NSMutableArray()
        
        let minInfos = dic["min_data"] as! NSDictionary
        prePrice = dic.parseNumber("pre_close", numberType: ParseNumberType.float) as! Float
        
        var keys = minInfos.allKeys
        keys.sort{ Int(($0 as! String)) < Int(($1 as! String)) }
        self.fiveDay_dateArr = keys as NSArray
        let arrCount = minInfos.count >= 5 ? 5 : minInfos.count
        for i in 0 ..< arrCount {
            let minArr = minInfos[keys[i] as! String] as! NSArray
            for d in minArr {
                let dict = d as! NSDictionary
                let bs = dict.parseNumber("bs", numberType: ParseNumberType.int) as! Int
                let volume = dict.parseNumber("volume", numberType: ParseNumberType.int) as! Int
                if bs == 2 {
                    timeVolume.add("-" + "\(volume)")
                }else{
                    timeVolume.add("\(volume)")
                }
                let price = dict["price"] as! String
                let min = dict.parseNumber("min", numberType: ParseNumberType.int) as! Int
                let avg_p = dict["average_price"] + ""
                timePrice.add([price , "\(min)"])
                timeAvg.add(avg_p)
            }
        }
        self.fiveDay_datas = timePrice
        self.fiveDay_volDatas = timeVolume
        self.fiveDay_agvDatas = timeAvg
        
        var five : TimeLineView!
        if fiveDayView != nil {
            five = fiveDayView
        }else if fiveDayView_full != nil {
            five = fiveDayView_full
        }
        if five != nil {
            five.open = self.prePrice
            five.datas = self.fiveDay_datas
            five.volDatas = self.fiveDay_volDatas
            five.agvDatas = self.fiveDay_agvDatas
            five.dateArr = self.fiveDay_dateArr
            five.stock_code = self.param?["code"] + ""
            five.isDraw = self.fiveDay_datas == nil
            five.setNeedsDisplay()
        }
    }
    
    func createKLineView(_ type : String) {
        if timeLine_full != nil {
            timeLine_full.removeFromSuperview()
        }
        if fiveDayView_full != nil {
            fiveDayView_full.removeFromSuperview()
        }
        
        if lineViewChartFull != nil {
            lineViewChartFull.removeFromSuperview()
            lineViewChartFull = nil
        }
        
        lineViewChartFull = CandleStickChartView(frame: CGRect(x: 0, y: 50, width: SCREEN_HEIGHT - 10, height: SCREEN_WIDTH - 50))
        fullView.addSubview(lineViewChartFull)
        lineViewChartFull.center = CGPoint(x: SCREEN_WIDTH / 2 - 18, y: SCREEN_HEIGHT / 2)
        lineViewChartFull.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        klineChartFull = KLineViewChart(chartView: lineViewChartFull, delegate: nil, reqCode: self.param?["code"] + "", reqType: type, isFull: true , currentDate : currentDate)
        self.fullView.bringSubviewToFront(self.headerView_full)
    }
    
    func requestList() {
        var type = "rise"
        switch topType {
        case "涨幅榜" :
            type = "rise"
        case "跌幅榜" :
            type = "fall"
        case "换手率榜" :
            type = "turnover"
        default :
            logPrint("其他")
        }
        
        StockService.getStockTopInfo(type, indexCode: param?["code"] + "", pageCount : 10 ,completion: { (bsd) -> Void in
            
            if bsd!.resultCode == 10000 {
                if let data = bsd!.resultData as? Array<Dictionary<String , AnyObject>> {
                    var stocks = Array<StockInfo>()
                    for dic in data {
                        let dict : NSDictionary    = dic as NSDictionary
                        let stockInfo              = StockInfo()
                        stockInfo.stockName        = dic["name"] + ""
                        stockInfo.stockCode        = dic["code"] + ""
                        stockInfo.stockPrice       = dict.parseNumber("price", numberType: ParseNumberType.float) as! Float
                        stockInfo.stockPriceChange = dict.parseNumber("price_change", numberType: ParseNumberType.float) as! Float
                        stockInfo.stockPriceRate   = dict.parseNumber("p_change", numberType: ParseNumberType.float) as! Float
                        stockInfo.stockChangeRate  = dict.parseNumber("turnover", numberType: ParseNumberType.float) as! Float
                        stockInfo.stockZf          = dict.parseNumber("zf", numberType: ParseNumberType.float) as! Float
                        stockInfo.stockIsStop      = dict.parseNumber("is_tp", numberType: ParseNumberType.int) as! Int == 1
                        stocks.append(stockInfo)
                    }
                    self.stocksInfo                = stocks
                }
                self.tableView.reloadData()
            }else{
                UtilTools.noticError(view: self.view, msg: bsd!.errorMsg!)
            }
            
        }) { (error) -> Void in
            UtilTools.noticError(view: self.view, msg: error!.msg!)
        }
    }
    
    override open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    open override func getVcId() -> String {
        return StockUtil.getRegisterIdForVc(type(of: self))
    }

}
