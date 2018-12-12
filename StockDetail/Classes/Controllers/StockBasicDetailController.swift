//
//  StockBasicDetailController.swift
//  Subject
//
//  Created by zhangyr on 2016/11/28.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService
import MJRefresh

open class StockBasicDetailController: BaseViewController {
    
    //MARK: Life circle

    override open func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(StockBasicDetailController.showMoreInfoWithLongPress(_:)), name: NSNotification.Name(rawValue: "moveLine"), object: nil)
        
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
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
    }
    
    //MARK: Initialize views
    
    override open func initUI() {
        super.initUI()
        
        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.view)
            maker.right.equalTo(self.view)
            maker.top.equalTo(self.view)
            maker.height.equalTo(self.view)
        }
        
        var height : CGFloat = 319
        if isStock() {
            height += 154
        }
        
        tableHeaderView = UIView(frame: CGRect(x: 0,
                                               y: 0,
                                               width: self.view.bounds.width,
                                               height: height))
        tableHeaderView.backgroundColor = HexColor("#edeef0")
        tableView.tableHeaderView = tableHeaderView
        
        setupRefresh()
        initHeaderView()
        initZiXuanItem()
        initTop()
        initSegment()
        initCharts()
        initBottom()
    }
    
    fileprivate func initHeaderView() {
        let naviView = UIView(frame: CGRect(x: 80,
                                            y: 0,
                                            width: self.view.bounds.width - 160,
                                            height: self.navigationController!.navigationBar.bounds.height))
        titleLabel = UILabel(frame: CGRect(x: 0,
                                           y: 8,
                                           width: naviView.bounds.width,
                                           height: 17))
        naviView.addSubview(self.titleLabel)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textColor = HexColor("#fff")
        titleLabel.font = UIFont.normalFontOfSize(16)
        infoLabel = UILabel(frame: CGRect(x: 0,
                                          y: titleLabel.frame.maxY,
                                          width: titleLabel.bounds.width,
                                          height: naviView.bounds.height - 28))
        naviView.addSubview(infoLabel)
        infoLabel.textAlignment = NSTextAlignment.center
        infoLabel.textColor = HexColor(COLOR_COMMON_WHITE_80)
        infoLabel.font = UIFont.normalFontOfSize(10)
        self.navigationItem.titleView = naviView
    }
    
    fileprivate func initZiXuanItem() {
        
        var tagNum = 1
        let width : CGFloat = 60
        var titleStr = "+ 自选"
        var color = HexColor("#fff")
        
        if isZixuan {
            tagNum = 2
            titleStr = "删自选"
            color = HexColor(COLOR_COMMON_WHITE_80)
        }
        
        let rightView = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: width,
                                             height: 25))
        let refBtn = UIButton(frame: CGRect(x: 8,
                                            y: 0,
                                            width: width,
                                            height: 25))
        refBtn.tag = tagNum
        refBtn.contentMode = .right
        refBtn.layer.borderWidth = 0.5
        refBtn.layer.borderColor = color.cgColor
        refBtn.layer.cornerRadius = 3
        refBtn.addTarget(self,
                         action: #selector(StockBasicDetailController.addZixuan(_:)),
                         for: UIControl.Event.touchUpInside)
        refBtn.setTitle(titleStr, for: UIControl.State())
        refBtn.titleLabel?.font = UIFont.normalFontOfSize(12)
        refBtn.setTitleColor(color, for: UIControl.State())
        rightView.addSubview(refBtn)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightView)
    }
    
    fileprivate func initTop() {
        var topHeight : CGFloat = 60
        if isStock() {
            topView = StockHeaderInfoView(type: StockHeaderType.stock)
        }else{
            topView = StockHeaderInfoView(type: StockHeaderType.plate)
            topHeight = 46
        }
        tableHeaderView.addSubview(topView)
        topView.snp.makeConstraints { (maker) in
            maker.left.equalTo(tableHeaderView)
            maker.right.equalTo(tableHeaderView)
            maker.top.equalTo(tableHeaderView)
            maker.height.equalTo(topHeight)
        }
        
        let sep = UIView()
        sep.backgroundColor = HexColor("#ddd")
        tableHeaderView.addSubview(sep)
        sep.snp.makeConstraints { (maker) in
            maker.left.equalTo(topView)
            maker.right.equalTo(topView)
            maker.top.equalTo(topView.snp.bottom)
            maker.height.equalTo(0.5)
        }
    }
    
    fileprivate func initSegment() {
        topSegment = SelectedSegmentedBar(frame: CGRect(x: 0,
                                                        y: 0,
                                                        width: self.view.bounds.width,
                                                        height: 38),
                                          items: ["分时","五日","日K","周K","月K"],
                                          delegate: self)
        topSegment.tag = TOP_SEGMENT_TAG
        tableHeaderView.addSubview(topSegment)
        topSegment.snp.makeConstraints { (maker) in
            maker.left.equalTo(topView)
            maker.right.equalTo(topView)
            maker.top.equalTo(topView.snp.bottom).offset(0.5)
            maker.height.equalTo(38)
        }
    }
    
    fileprivate func initCharts() {
        
        chartsView = UIView()
        chartsView.backgroundColor = HexColor(COLOR_COMMON_WHITE)
        tableHeaderView.addSubview(chartsView)
        chartsView.snp.makeConstraints { (maker) in
            maker.left.equalTo(topSegment)
            maker.right.equalTo(topSegment)
            maker.top.equalTo(topSegment.snp.bottom)
            maker.height.equalTo(225)
        }
        
        initTimeView()
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(StockBasicDetailController.showLandscape(_:)))
        chartsView.addGestureRecognizer(tapGR)
        
    }
    
    fileprivate func initTimeView() {
        if isStock() {
            timeLineView = TimeLineView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: (self.view.bounds.width - 24 * SCALE_WIDTH_6) / 3 * 2,
                                                      height: timeChartsHeight),
                                        move: true,
                                        isFive: false,
                                        isMarket: false,
                                        isPortrait: true)
            timeLineView?.delegate = self
            chartsView.addSubview(timeLineView!)
            timeLineView?.snp.makeConstraints { (maker) in
                maker.left.equalTo(chartsView).offset(12 * SCALE_WIDTH_6)
                maker.top.equalTo(chartsView).offset(10)
                maker.width.equalTo((self.view.bounds.width - 24 * SCALE_WIDTH_6) / 3 * 2 )
                maker.height.equalTo(timeChartsHeight)
            }
            
            fiveView = UITableView()
            fiveView?.layer.borderWidth = 0.5
            fiveView?.layer.borderColor = HexColor("#dddddd").cgColor
            fiveView?.dataSource = self
            fiveView?.delegate = self
            fiveView?.separatorStyle = UITableViewCell.SeparatorStyle.none
            fiveView?.backgroundColor = HexColor("#fff")
            fiveView?.isScrollEnabled = false
            fiveView?.register(SoldViewCell.self, forCellReuseIdentifier: "fiveCell")
            chartsView.addSubview(fiveView!)
            fiveView?.snp.makeConstraints { (maker) in
                maker.left.equalTo(timeLineView!.snp.right).offset(5)
                maker.right.equalTo(chartsView).offset(-12 * SCALE_WIDTH_6)
                maker.top.equalTo(timeLineView!)
                maker.height.equalTo(timeLineView!).multipliedBy(1.5).offset(20)
            }
        }else{
            timeLineView = TimeLineView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: self.view.bounds.width - 24 * SCALE_WIDTH_6,
                                                      height: timeChartsHeight),
                                        move: true,
                                        isFive: false,
                                        isMarket: true,
                                        isPortrait: true)
            timeLineView?.delegate = self
            chartsView.addSubview(timeLineView!)
            timeLineView?.snp.makeConstraints { (maker) in
                maker.left.equalTo(chartsView).offset(12 * SCALE_WIDTH_6)
                maker.top.equalTo(chartsView).offset(10)
                maker.right.equalTo(chartsView).offset(-12 * SCALE_WIDTH_6)
                maker.height.equalTo(timeChartsHeight)
            }
        }
    }
    
    func initBottom() {
        
    }
    
    //MARK: Method
    
    fileprivate func setupRefresh() {
        weak var blockSelf = self
        self.tableView.mj_header = MJRefreshGifHeader(headerRefreshingBlock: {
            blockSelf?.page = 1
            Behavior.eventReport("xiala_zuixin")
            blockSelf?.refreshData()
        })
    }
    
    func setFooterRefresh(block: @escaping () -> Void) {
        self.tableView.mj_footer = MJRefreshBackGifFooter(footerRefreshingBlock: block)
    }
    
    func endRefresh() {
        self.tableView.mj_header?.endRefreshing()
        self.tableView.mj_footer?.endRefreshing()
    }
    
    func removeFooterRefresh() {
        self.tableView.mj_footer?.removeFromSuperview()
        self.tableView.mj_footer = nil
    }
    
    @objc override open func refreshData() {
        super.refreshData()
        
        StockService.getStockCurrentInfoWithCode(param?["code"] + "", completion: { (bsd) -> Void in
            self.tableView.mj_header.endRefreshing()
            if bsd!.resultCode! == 10000 {
                if let data = bsd!.resultData as? Dictionary<String,Any> {
                    self.parseJsonData(data)
                }
            }
        }) { (error) -> Void in
            self.tableView.mj_header.endRefreshing()
        }
        
        weak var weakSelf = self
        if glStockNeedRefresh && self.timer == nil && !isTp && isDealDay && glStockNetRefreshPeriod > 0.5{
            //println("开启数据刷新")
            self.timer = Timer.scheduledTimer(timeInterval: glStockNetRefreshPeriod, target: weakSelf!, selector: #selector(StockBasicDetailController.refreshData), userInfo: nil, repeats: true)
        }else{
            //println("开启数据刷新条件不足")
            if self.timer != nil && (UtilCheck.isDealTime() != 2 || isTp || !isDealDay ) {
                self.timer.invalidate()
                self.timer = nil
            }
        }
    }
    
    //未开盘 1
    //交易中 2
    //午间休市 3
    //已收盘 4
    /**
     解析股票数据
    */
    func parseJsonData(_ data : Dictionary<String,Any>) {
        guard let stockInfo = data["stock_info"] as? Dictionary<String,Any> else {
            return
        }
        currentDate    = stockInfo["date"] + ""
        let name = stockInfo["name"] + ""
        param?["name"]   = name as AnyObject?
        let code = stockInfo["code"] + ""
        self.titleLabel.text = name + "(\(code))"
        var stockMin  = Array<Any>()
        if let tmp = data["stock_min"] as? Array<Any> {
            stockMin = tmp
        }
        let isTrading = data.getNumberForKey("istradingday").intValue
        isDealDay = isTrading == 1
        showStockInfo(stockInfo)
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
        if isTp {
            isDeal = "停牌中"
        }
        if !isDealDay {
            isDeal = "休市中"
        }
        self.infoLabel.text = isDeal + " " + UtilDate.formatTime("MM-dd HH:mm:ss", time_interval: UtilDate.getTimeInterval())
        
        if !isTp {
            showTimeInfo(stockMin)
        }
        if fiveView != nil {
            fiveView?.reloadData()
        }
    }
    
    /**
     显示股票基本数据
     */
    func showStockInfo(_ stockInfo : Dictionary<String,Any>) {
        let tP = stockInfo.getNumberForKey("isTp").intValue
        isTp = tP == 1
        
        topView.infoData = stockInfo
        pChange = stockInfo.getNumberForKey("p_change").floatValue
        currentPrice = stockInfo.getNumberForKey("price").floatValue
        todayOpen = stockInfo.getNumberForKey("open").floatValue
        preClose = stockInfo.getNumberForKey("pre_close").floatValue
        currentVol = stockInfo.getNumberForKey("volume").floatValue / 100
        
        var arrB = Array<Any>()
        var tp = ""
        var tv = ""
        var tStr = ""
        for j in 0 ..< 5 {
            let i = 5 - j
            tp = stockInfo["a\(i)_p"] + ""
            let vol = stockInfo.getNumberForKey("a\(i)_v").floatValue / 100
            tv = vol >= 100_000 ? String(format: "%.0f万",vol / 10000) : String(format: "%.0f",vol)
            tStr = "卖\(i),\(tp),\(tv)"
            arrB.append(tStr)
        }
        tStr = String(format: "现价(元): %.2f", currentPrice)
        arrB.append(tStr)
        for i in 1 ... 5 {
            tp = stockInfo["b\(i)_p"] + ""
            let vol = stockInfo.getNumberForKey("b\(i)_v").floatValue / 100
            tv = vol >= 100_000 ? String(format: "%.0f万",vol / 10000) : String(format: "%.0f",vol)
            tStr = "买\(i),\(tp),\(tv)"
            arrB.append(tStr)
        }
        self.sbFive = arrB
    }
    
    /**
     显示分时数据
     */
    func showTimeInfo(_ stockMin : Array<Any>){
        var timePrice = Array<Any>()
        var timeVolume = Array<Any>()
        var timeAvg = Array<Any>()
        for i in 0 ..< stockMin.count {
            let d = stockMin[i]
            guard let dic = d as? Dictionary<String,Any> else {
                break
            }
            let bs = dic.getNumberForKey("bs").intValue
            let volume = dic["volume"] + ""
            if bs == 2 {
                timeVolume.append("-" + volume)
            }else{
                timeVolume.append(volume)
            }
            let price = dic["price"] + ""
            let min = dic.getNumberForKey("min").intValue
            let avgP = dic["average_price"] + ""
            if i == 0 {
                timePrice.append([String(format: "%.2f" , todayOpen), "\(min)"])
                timeAvg.append(String(format: "%.2f" , todayOpen))
            }else{
                timePrice.append([price , "\(min)"])
                timeAvg.append(avgP)
            }
        }
        self.datas = timePrice
        self.volDatas = timeVolume
        self.agvDatas = timeAvg
        
        fiveView?.reloadData()
        timeLineView?.open = preClose
        timeLineView?.toOpen = todayOpen
        timeLineView?.datas = self.datas as NSArray
        timeLineView?.volDatas = self.volDatas as NSArray
        timeLineView?.agvDatas = self.agvDatas as NSArray
        timeLineView?.sb_five = self.sbFive as NSArray
        timeLineView?.isDraw = self.datas == nil
        timeLineView?.setNeedsDisplay()
        
        if self.timeLine_full != nil {
            //println("全屏数据刷新")
            self.timeLine_full.open = preClose
            self.timeLine_full.toOpen = self.todayOpen
            self.timeLine_full.datas = self.datas as NSArray
            self.timeLine_full.volDatas = self.volDatas as NSArray
            self.timeLine_full.agvDatas = self.agvDatas as NSArray
            self.timeLine_full.sb_five = self.sbFive as NSArray
            self.timeLine_full.isDraw = self.datas == nil
            self.timeLine_full.setNeedsDisplay()
        }
        if self.fullView != nil {
            self.price_full.text = String(format: "%.2f", self.currentPrice)
            self.price_full.textColor = self.currentPrice > self.preClose ? Color(COLOR_COMMON_RED) : self.currentPrice < self.preClose ? Color(COLOR_COMMON_GREEN) : Color(COLOR_COMMON_BLACK_3)
            self.vol_full.text = UtilTools.formatTotalAmount(CGFloat(self.currentVol)) + "手"
        }
    }
    
    /**
     解析五日数据
     */
    func parseFiveDayData(_ dic : Dictionary<String,Any>) {
        
        var timePrice = Array<Any>()
        var timeVolume = Array<Any>()
        var timeAvg = Array<Any>()
        
        guard let minInfos = dic["min_data"] as? Dictionary<String,Any> else {
            return
        }
        fivePrePrice = dic.getNumberForKey("pre_close").floatValue
        let keys = minInfos.keys
        let nKeys = keys.sorted{ (Int($0) ?? 0) < (Int($1) ?? 0) }
        fiveDayDateArr = nKeys
        let arrCount = minInfos.count >= 5 ? 5 : minInfos.count
        for i in 0 ..< arrCount {
            guard let minArr = minInfos[nKeys[i]] as? Array<Any> else {
                break
            }
            for d in minArr {
                guard let dict = d as? Dictionary<String,Any> else {
                    break
                }
                let bs = dict.getNumberForKey("bs").intValue
                let volume = dict.getNumberForKey("volume").intValue
                if bs == 2 {
                    timeVolume.append("-" + "\(volume)")
                }else{
                    timeVolume.append("\(volume)")
                }
                let price = dict["price"] + ""
                let min = dict.getNumberForKey("min").intValue
                let avg_p = dict["average_price"] + ""
                timePrice.append([price,"\(min)"])
                timeAvg.append(avg_p)
            }
        }
        fiveDayDatas = timePrice
        fiveDayVolDatas = timeVolume
        fiveDayAvgDatas = timeAvg
        
        fiveTimeView?.open = fivePrePrice
        fiveTimeView?.datas = fiveDayDatas as NSArray
        fiveTimeView?.volDatas = fiveDayVolDatas as NSArray
        fiveTimeView?.agvDatas = fiveDayAvgDatas as NSArray
        fiveTimeView?.dateArr = fiveDayDateArr as NSArray
        fiveTimeView?.stock_code = self.param?["code"] + ""
        fiveTimeView?.isDraw = fiveDayDatas == nil
        fiveTimeView?.setNeedsDisplay()
        
        if fiveDayView_full != nil {
            fiveDayView_full?.open = fivePrePrice
            fiveDayView_full?.datas = fiveDayDatas as NSArray
            fiveDayView_full?.volDatas = fiveDayVolDatas as NSArray
            fiveDayView_full?.agvDatas = fiveDayAvgDatas as NSArray
            fiveDayView_full?.dateArr = fiveDayDateArr as NSArray
            fiveDayView_full?.stock_code = self.param?["code"] + ""
            fiveDayView_full?.isDraw = fiveDayDatas == nil
            fiveDayView_full?.setNeedsDisplay()
        }
    }
    
    /**
     个股true，行业false
    */
    func isStock() -> Bool {
        return true
    }
    
    /**
     全屏显示
    */
    
    
    /**
     添加及删除自选
    */
    @objc func addZixuan(_ btn : UIButton) {
        if btn.tag == 1 {
            btn.setTitle("删自选", for: UIControl.State())
            btn.setTitleColor(Color(COLOR_COMMON_WHITE_80), for: UIControl.State())
            btn.layer.borderColor = HexColor(COLOR_COMMON_WHITE_80).cgColor
            btn.tag = 2
            StockUtil.addStock(code: param?["code"] + "")
        }else{
            btn.setTitle("+ 自选", for: UIControl.State())
            btn.setTitleColor(Color("#fff"), for: UIControl.State())
            btn.layer.borderColor = HexColor("#fff").cgColor
            btn.tag = 1
            StockUtil.deleteStock(code: param?["code"] + "")
        }
    }
    
    /**
     显示五日数据
    */
    fileprivate func showFiveDayData() {
        StockService.getStockTimeFiveWithCode(self.param?["code"] + "", completion: { (bsd) -> Void in
            
            if bsd!.resultCode! == 10000 {
                if let data = bsd!.resultData as? Dictionary<String,Any> {
                    self.parseFiveDayData(data)
                }
            }else{
                UtilTools.noticError(view: self.fiveTimeView, msg: bsd!.errorMsg!, offset: 0)
            }
            
        }, failure: { (error) -> Void in
            UtilTools.noticError(view: self.fiveTimeView, msg: error!.msg!, offset: 0)
        })
    }
    
    /**
     显示K线图
    */
    fileprivate func showKLineView(reqType: String) {
        fiveTimeView?.removeFromSuperview()
        fiveTimeView = nil
        timeLineView?.removeFromSuperview()
        timeLineView = nil
        fiveView?.removeFromSuperview()
        fiveView = nil
        lineViewChart?.removeFromSuperview()
        lineViewChart = nil
        klineChart = nil
        
        lineViewChart = CandleStickChartView(frame: CGRect(x: 0,
                                                           y: 0,
                                                           width: self.view.bounds.width - 4 * SCALE_WIDTH_6,
                                                           height: 215))
        chartsView.addSubview(lineViewChart!)
        lineViewChart?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(chartsView).offset(2 * SCALE_WIDTH_6)
            maker.right.equalTo(chartsView).offset(-2 * SCALE_WIDTH_6)
            maker.top.equalTo(chartsView)
            maker.bottom.equalTo(chartsView).offset(-10)
        })
        klineChart = KLineViewChart(chartView: lineViewChart!, delegate: self, reqCode: self.param?["code"] + "", reqType: reqType, isFull: true , currentDate : currentDate)
    }
    
    /**
     长按显示数据
    */
    @objc func showMoreInfoWithLongPress(_ noti : Notification) {
        let userInfo = ((noti as NSNotification).userInfo! as NSDictionary).object(forKey: "isMove") as! Bool
        if fullView == nil {
            if moreInfoView == nil {
                moreInfoView    = StockMoreInfoView(frame: CGRect(x: topSegment.frame.minX, y: topSegment.frame.minY, width: topSegment.bounds.width, height: 48))
                tableHeaderView.addSubview(moreInfoView!)
            }
            moreInfoView?.isHidden   = !userInfo
        }else{
            self.segmented_full.isHidden = userInfo
        }
    }
    
    //MARK: 未处理的老代码
    
    @objc func showLandscape(_ gr : UITapGestureRecognizer) {
        Behavior.eventReport("dianji_tu")
        tableView.isUserInteractionEnabled = false
        hideStatusBar(true)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            if self.timeLineView != nil {
                self.timeLineView!.frame.origin.x -= self.timeLineView!.frame.size.width + 10
                if self.fiveView != nil {
                    self.fiveView!.frame.origin.x += self.fiveView!.frame.size.width + 10
                }
            }else if self.lineViewChart != nil {
                self.lineViewChart!.frame.origin.x -= self.chartsView.bounds.width
            }else{
                self.fiveTimeView!.frame.origin.x -= self.chartsView.bounds.width
            }
        }, completion: { (Bool) -> Void in
            self.navigationController?.isNavigationBarHidden = true
            self.fullView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: SCREEN_HEIGHT))
            self.fullView.backgroundColor = HexColor("#fff")
            self.view.addSubview(self.fullView)
            self.headerView_full = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_HEIGHT, height: 50))
            self.headerView_full.center = CGPoint(x: SCREEN_WIDTH - 25, y: SCREEN_HEIGHT / 2)
            let spW = (self.headerView_full.bounds.width - 80) / 4
            self.stockName_full = TextLabel(frame: CGRect(x: 0, y: 0, width: spW, height: 24), alignment: NSTextAlignment.center, toView: self.headerView_full ,fontSize : 16)
            self.stockName_full.textColor = UtilColor.getTextBlackColor()
            self.stockName_full.text = self.param?["name"] + ""
            self.price_full = TextLabel(frame: CGRect(x: self.stockName_full.frame.maxX, y: 0, width: spW, height: 24), alignment: NSTextAlignment.center, toView: self.headerView_full , fontSize : 14)
            self.price_full.text = String(format: "%.2f", self.currentPrice)
            self.price_full.textColor = self.currentPrice > self.preClose ? Color(COLOR_COMMON_RED) : self.currentPrice < self.preClose ? Color(COLOR_COMMON_GREEN) : Color(COLOR_COMMON_BLACK_3)
            let vl = HintLabel(frame: CGRect(x: self.price_full.frame.maxX, y: 0, width: 30, height: 24), alignment: NSTextAlignment.left, title: "成交", toView: self.headerView_full, fontSize : 14)
            self.vol_full = TextLabel(frame: CGRect(x: vl.frame.maxX, y: 0, width: spW, height: 24), alignment: NSTextAlignment.center, toView: self.headerView_full, fontSize : 14)
            self.vol_full.text = UtilTools.formatTotalAmount(CGFloat(self.currentVol)) + "手"
            let tl = HintLabel(frame: CGRect(x: self.vol_full.frame.maxX, y: 0, width: 30, height: 24), alignment: NSTextAlignment.left, title: "时间", toView: self.headerView_full, fontSize : 14)
            self.timeLabel_full = TextLabel(frame: CGRect(x: tl.frame.maxX, y: 0, width: spW, height: 24), alignment: NSTextAlignment.center, toView: self.headerView_full, fontSize : 14)
            self.timeLabel_full.text = UtilDate.formatTime("HH:mm", time_interval: UtilDate.getTimeInterval())
            let closeBtn = UIButton(frame: CGRect(x: self.timeLabel_full.frame.maxX - 15, y: 0, width: 30, height: 30))
            closeBtn.setImage(UIImage(named: "lhb_icon_cancel"), for: UIControl.State())
            closeBtn.addTarget(self, action: #selector(StockBasicDetailController.closeLandspace), for: UIControl.Event.touchUpInside)
            self.headerView_full.addSubview(closeBtn)
            self.segmented_full = SelectedSegmentedBar(frame: CGRect(x: 0, y: 24, width: self.headerView_full.bounds.width, height: 25), items: ["分时","五日","日K","周K","月K"], delegate: self)
            self.segmented_full.tag = FULL_SEGMENT_TAG
            self.headerView_full.addSubview(self.segmented_full)
            self.segmented_full.backgroundColor = HexColor("#fff")
            self.timeLine_full = TimeLineView(frame: CGRect(x:10, y:0, width: SCREEN_HEIGHT - 20, height: (SCREEN_WIDTH - 80) / 3 * 2) , move : true)
            let tmpX : CGFloat = self.fullView.bounds.width / 2 + (self.timeLine_full.bounds.height / 2) / 2 - 10
            let tmp = ((self.tableView.bounds.height - 20) / 4 + 10) / 2
            let tmpY : CGFloat = self.fullView.bounds.height / 2 - tmp
            self.timeLine_full.center = CGPoint(x: tmpX, y: tmpY)
            self.fullView.addSubview(self.timeLine_full)
            self.fullView.addSubview(self.headerView_full)
            self.timeLine_full.open = self.preClose
            self.timeLine_full.toOpen = self.todayOpen
            self.timeLine_full.datas = self.datas as NSArray
            self.timeLine_full.volDatas = self.volDatas as NSArray
            self.timeLine_full.agvDatas = self.agvDatas as NSArray
            self.timeLine_full.sb_five = self.sbFive as NSArray
            self.timeLine_full.stock_code = self.param?["code"] + ""
            self.timeLine_full.isDraw = self.datas == nil
            self.timeLine_full.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            self.headerView_full.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
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
            let panGr       = UIPanGestureRecognizer(target: nil, action: #selector(StockBasicDetailController.closeLandspace))
            panGr.delegate  = self
            self.fullView.addGestureRecognizer(panGr)
        })
    }
    
    @objc func closeLandspace() {
        tableView.isUserInteractionEnabled = true
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
                self.lineViewChartFull = nil
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
                if self.timeLineView != nil {
                    self.timeLineView!.frame.origin.x += self.timeLineView!.frame.size.width + 10
                    if self.fiveView != nil {
                        self.fiveView!.frame.origin.x -= self.fiveView!.frame.size.width + 10
                    }
                }else if self.lineViewChart != nil {
                    self.lineViewChart!.frame.origin.x += self.chartsView.bounds.width
                }else{
                    self.fiveTimeView!.frame.origin.x += self.chartsView.bounds.width
                }
            })
        })
        self.tableView.isScrollEnabled = true
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
        lineViewChartFull.center = CGPoint(x: SCREEN_WIDTH / 2 - 18, y: SCREEN_HEIGHT / 2)
        lineViewChartFull.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        klineChartFull = KLineViewChart(chartView: lineViewChartFull, delegate: nil, reqCode: self.param?["code"] + "", reqType: type, isFull: true , currentDate : currentDate)
        fullView.addSubview(lineViewChartFull)
        self.fullView.bringSubviewToFront(self.headerView_full)
    }
    
    override open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    fileprivate var timeLine_full :  TimeLineView!
    fileprivate var fiveDayView_full : TimeLineView!
    fileprivate var segmented_full : SelectedSegmentedBar!
    fileprivate var headerView_full : UIView!
    fileprivate var stockName_full : UILabel!
    fileprivate var price_full : UILabel!
    fileprivate var vol_full : UILabel!
    fileprivate var timeLabel_full : UILabel!
    fileprivate var lineViewChartFull : CandleStickChartView!
    fileprivate var klineChartFull    : KLineViewChart?

    //MARK: Properties
    var isZixuan: Bool = false {
        didSet {
            initZiXuanItem()
        }
    }
    var tableView : UITableView!
    var tableHeaderView : UIView!
    ///头部信息
    var topView : StockHeaderInfoView!
    ///头部segment
    var topSegment : SelectedSegmentedBar!
    ///图表view
    var chartsView : UIView!
    ///竖屏分时图
    var timeLineView : TimeLineView?
    ///竖屏五档信息
    var fiveView : UITableView?
    ///五日线
    var fiveTimeView : TimeLineView?
    ///K线图表
    var lineViewChart : CandleStickChartView?
    var klineChart    : KLineViewChart?
    ///底部的view
    var bottomView : UIView?
    ///长按展示更多数据
    var moreInfoView : StockMoreInfoView?
    ///全屏数据
    //FIXME: 全屏显示还是老代码
    var fullView : UIView!//StockLandscapeInfoView!
    
    var sbFive : Array<Any>!
    var preClose : Float = 0
    var page : Int = 1 {
        didSet {
            if page < 1 {
                page = 1
            }
        }
    }
    
    fileprivate var agvDatas : Array<Any>!
    fileprivate var datas : Array<Any>!
    fileprivate var volDatas : Array<Any>!
    fileprivate var fiveDayVolDatas : Array<Any>!
    fileprivate var fiveDayAvgDatas : Array<Any>!
    fileprivate var fiveDayDatas : Array<Any>!
    fileprivate var fiveDayDateArr : Array<Any>!
    fileprivate var titleLabel : UILabel!
    fileprivate var infoLabel : UILabel!
    fileprivate var fivePrePrice : Float = 0
    fileprivate var currentDate : String = UtilDate.formatTime("yyyyMMdd", time_interval: UtilDate.getTimeInterval()) {
        didSet {
            klineChart?.currentDate = currentDate
            klineChartFull?.currentDate = currentDate
        }
    }
    fileprivate var timer : Timer!
    fileprivate var isTp : Bool = false
    fileprivate var isDealDay : Bool = true
    fileprivate var pChange : Float = 0
    fileprivate var currentPrice : Float = 0 {
        didSet {
            klineChart?.pChange = pChange
            klineChartFull?.pChange = pChange
            klineChart?.todayPrice = currentPrice
            klineChartFull?.todayPrice = currentPrice
        }
    }
    fileprivate var todayOpen : Float = 0
    fileprivate var currentVol : Float = 0
    fileprivate var smallSegIndex : Int = 0
    
    fileprivate let timeChartsHeight : CGFloat = 122
}

let TOP_SEGMENT_TAG = 10010
let BOTTOM_SEGMENT_TAG = 10086
let FULL_SEGMENT_TAG = 10000

extension StockBasicDetailController : UITableViewDataSource , UITableViewDelegate , SelectedSegmentedBarDelegate , KLineViewChartDelegate , TimeLineViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("numberOfRowsInSection has not been implemented")
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("cellForRowAt has not been implemented")
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        fatalError("heightForRowAt has not been implemented")
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        fatalError("heightForHeaderInSection has not been implemented")
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        fatalError("viewForHeaderInSection has not been implemented")
    }
    
    func selectedItemForSegmentedBar(_ segmentedBar: SelectedSegmentedBar, selectedSegmentedIndex: Int) {
        
        if segmentedBar.tag == TOP_SEGMENT_TAG {
            smallSegIndex = selectedSegmentedIndex
            if isStock() {
                IndexOfStockChart = selectedSegmentedIndex
            }else{
                IndexOfPlateChart = selectedSegmentedIndex
            }
            switch selectedSegmentedIndex {
            case 0: //分时
                Behavior.eventReport("fenshi")
                fiveTimeView?.removeFromSuperview()
                fiveTimeView = nil
                lineViewChart?.removeFromSuperview()
                lineViewChart = nil
                klineChart = nil
                initTimeView()
                refreshData()
                break
            case 1: //五日
                Behavior.eventReport("wuri")
                timeLineView?.removeFromSuperview()
                timeLineView = nil
                fiveView?.removeFromSuperview()
                fiveView = nil
                lineViewChart?.removeFromSuperview()
                lineViewChart = nil
                klineChart = nil
                fiveTimeView = TimeLineView(frame: CGRect(x: 0,
                                                          y: 0,
                                                          width: self.view.bounds.width - 24 * SCALE_WIDTH_6,
                                                          height: timeChartsHeight),
                                            move: true,
                                            isFive: true,
                                            isMarket: false,
                                            isPortrait: true)
                fiveTimeView?.delegate = self
                chartsView.addSubview(fiveTimeView!)
                fiveTimeView?.snp.makeConstraints({ (maker) in
                    maker.left.equalTo(chartsView).offset(12 * SCALE_WIDTH_6)
                    maker.right.equalTo(chartsView).offset(-12 * SCALE_WIDTH_6)
                    maker.top.equalTo(chartsView).offset(10)
                    maker.height.equalTo(timeChartsHeight)
                })
                showFiveDayData()
                break
            case 2: //日K
                Behavior.eventReport("rixian")
                showKLineView(reqType: "D")
                break
            case 3: //周K
                Behavior.eventReport("zhouxian")
                showKLineView(reqType: "W")
                break
            case 4: //月K
                Behavior.eventReport("yuexian")
                showKLineView(reqType: "M")
                break
            default:
                break
            }
            return
        }else if segmentedBar.tag == FULL_SEGMENT_TAG {
            switch selectedSegmentedIndex {
            case 0: //分时
                Behavior.eventReport("fenshi")
                if lineViewChartFull != nil {
                    lineViewChartFull.removeFromSuperview()
                }
                if fiveDayView_full != nil {
                    self.fiveDayView_full.removeFromSuperview()
                }
                
                if timeLine_full == nil {
                    self.timeLine_full = TimeLineView(frame: CGRect(x:10, y:0, width: SCREEN_HEIGHT - 20, height: (SCREEN_WIDTH - 80) / 3 * 2) , move : true)
                    let tmpX = self.fullView.bounds.width / 2 + (self.timeLine_full.bounds.height / 2) / 2 - 10
                    let tmp = ((self.tableView.bounds.height - 20) / 4 + 10) / 2
                    let tmpY = self.fullView.bounds.height / 2 - tmp
                    self.timeLine_full.center = CGPoint(x: tmpX, y: tmpY)
                    self.fullView.addSubview(self.timeLine_full)
                    self.fullView.bringSubviewToFront(self.headerView_full)
                    self.timeLine_full.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                }else{
                    self.fullView.addSubview(self.timeLine_full)
                    self.fullView.bringSubviewToFront(self.headerView_full)
                }
                refreshData()
            case 1: //五日
                Behavior.eventReport("wuri")
                if lineViewChartFull != nil {
                    lineViewChartFull.removeFromSuperview()
                }
                if timeLine_full != nil {
                    self.timeLine_full.removeFromSuperview()
                }
                if fiveDayView_full == nil {
                    fiveDayView_full = TimeLineView(frame: CGRect(x:20, y:10, width: SCREEN_HEIGHT - 20, height: (SCREEN_WIDTH - 80) / 3 * 2) , move : true , isFive :true)
                    self.fiveDayView_full.center = CGPoint(x: self.fullView.bounds.width / 2 + (self.fiveDayView_full.bounds.height / 2) / 2 - 10, y: self.fullView.center.y)
                    self.fiveDayView_full.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
                    self.fullView.addSubview(self.fiveDayView_full)
                    self.fullView.bringSubviewToFront(self.headerView_full)
                }else{
                    self.fullView.addSubview(self.fiveDayView_full)
                    self.fullView.bringSubviewToFront(self.headerView_full)
                }
                showFiveDayData()
                break
            case 2: //日K
                Behavior.eventReport("rixian")
                createKLineView("D")
                break
            case 3: //周K
                Behavior.eventReport("zhouxian")
                createKLineView("W")
                break
            case 4: //月K
                Behavior.eventReport("yuexian")
                createKLineView("M")
                break
            default:
                break
            }
            return
        }
    }
    
    func timeLineViewMoreInfo(with data: PointInfo) {
        moreInfoView?.show(with: data, isK: false)
    }
    
    func kLineViewMoreInfo(with data: KLineData) {
        moreInfoView?.show(with: data, isK: true)
    }
}
