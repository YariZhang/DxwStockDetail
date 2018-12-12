//
//  StockConceptDetailController.swift
//  Subject
//
//  Created by zhangyr on 2016/11/29.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

open class StockConceptDetailController: StockBasicDetailController , StockPlateNewsCellDelegate , SelectBarDelegate , SortHeaderViewDelegate , StrategyDatePickerViewDelegate , ChartsInfoCellDelegate{
    
    override open func initUI() {
        super.initUI()
        self.tableView.register(StockPlateNewsCell.self, forCellReuseIdentifier: "plateNewsCell")
        self.tableView.register(ChartsInfoCell.self, forCellReuseIdentifier: "chartsStockCell")
        if let index = IndexOfPlateChart {
            self.topSegment.setIndexWithAction(for: index)
        }
        
        if let index = IndexOfPlateInfo {
            selectedIndex = index
            if index != 0 {
                requestList()
            }
        }
    }

    override func isStock() -> Bool {
        return false
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.fiveView {
            return sbFive == nil ? 0 : sbFive.count
        }
        switch selectedIndex {
        case 0: //个股
            return stocksInfo == nil ? 0 : stocksInfo.stockList.count
        case 1: //新闻
            return (newsInfos == nil ? 0 : newsInfos.list.count) + 1
        default:
            break
        }
        return 0
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === fiveView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "fiveCell", for: indexPath) as! SoldViewCell
            cell.dataStr = self.sbFive[indexPath.row] as? NSString
            cell.open = preClose
            cell.infoType = 1
            return cell
        }
        switch selectedIndex {
        case 0: //个股
            let cell = tableView.dequeueReusableCell(withIdentifier: "chartsStockCell", for: indexPath) as! ChartsInfoCell
            if stocksInfo != nil && stocksInfo.stockList.count > indexPath.row {
                let tmp = stocksInfo.stockList[indexPath.row]
                if indexPath.row == 0 {
                    ratio = tmp["ratio"] + ""
                    if let attr = tmp["style"] as? Array<Dictionary<String,AnyObject>> {
                        cellAttri = attr
                    }
                }
                cell.proportion = ratio
                cell.attributes = cellAttri
                cell.cellData = tmp as AnyObject
                cell.needSep = true
                cell.delegate = self
            }
            return cell
        case 1: //新闻
            if indexPath.row == 0 {
                let cell  = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
                cell.selectionStyle = .none
                cell.backgroundColor = Color(COLOR_COMMON_WHITE)
                let label = UILabel()
                label.font = UIFont.normalFontOfSize(12)
                label.textColor = Color(COLOR_COMMON_BLACK_9)
                label.textAlignment = .center
                cell.addSubview(label)
                label.snp.makeConstraints({ (maker) in
                    maker.height.equalTo(20)
                    maker.bottom.equalTo(cell)
                    maker.left.equalTo(cell).offset(24)
                    maker.right.equalTo(cell).offset(-24)
                })
                label.text = "暂无题材数据"
                if newsInfos != nil && newsInfos.list.count != 0 {
                    label.text = "以下均为题材发现后追踪至T+2涨跌幅"
                    label.backgroundColor = Color("#fafafa")
                }
                return cell
            }
            let cell      = tableView.dequeueReusableCell(withIdentifier: "plateNewsCell", for: indexPath) as! StockPlateNewsCell
            cell.newsData = self.newsInfos.list[indexPath.row - 1]
            cell.needSep  = indexPath.row != newsInfos.list.count
            cell.delegate = self
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
    @objc override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === fiveView {
            SOLD_VIEW_WIDTH = fiveView!.bounds.width
            SOLD_VIEW_HEIGHT = fiveView!.bounds.height / 11
            return fiveView!.bounds.height / 11
        }
        switch selectedIndex {
        case 0: //个股
            return 50
        case 1: //新闻
            if indexPath.row == 0 {
                return 32
            }
            return (newsInfos == nil || newsInfos.list.count < indexPath.row) ? 0 : newsInfos.list[indexPath.row - 1].cellHeight
        default:
            break
        }
        return 0
    }
    
    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView === fiveView {
            return 0
        }
        if selectedIndex == 0 {
            return 118 + 45
        }
        return 38
    }
    
    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView === fiveView {
            return nil
        }
        
        let hv = UIView(frame: CGRect(x: 0,
                                      y: 0,
                                      width: self.view.bounds.width,
                                      height: selectedIndex == 0 ? (118 + 45) : 38))
        hv.backgroundColor = Color(COLOR_COMMON_WHITE)
        if bottomSegment == nil {
            bottomSegment = SelectedSegmentedBar(frame: CGRect(x: 0,
                                                               y: 0,
                                                               width: self.view.bounds.width,
                                                               height: 38),
                                                 items: ["个股"],
                                                 delegate: self)
            bottomSegment?.tag = BOTTOM_SEGMENT_TAG
        }
        bottomSegment?.index = selectedIndex
        hv.addSubview(bottomSegment!)
        if selectedIndex == 0 {
            if selectedBar == nil {
                selectedBar = SelectBar(type: 1)
                selectedBar.delegate = self
            }
            selectedBar.frame = CGRect(x: 0, y: bottomSegment!.frame.maxY, width: hv.bounds.width, height: 50)
            hv .addSubview(selectedBar)
            if headerList == nil {
                headerList = SortHeaderView()
                headerList.delegate = self
            }
            headerList.frame = CGRect(x: 0, y: selectedBar.frame.maxY, width: hv.bounds.width, height: 30)
            hv.addSubview(headerList)
            if plateCell == nil {
                plateCell = ChartsInfoCell()
                plateCell.backgroundColor = Color("#fafdff")
                plateCell.needSep = true
            }
            plateCell.frame = CGRect(x: 0, y: headerList.frame.maxY, width: hv.bounds.width, height: 45)
            hv.addSubview(plateCell)
        }
        
        return hv
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === fiveView {
            return
        }
        
        if selectedIndex == 0 {
            if let stock_info = stocksInfo.stockList[indexPath.row]["para"] as? Dictionary<String,AnyObject> {
                self.navigationController?.pushStockDetailController(stock_info, animated: true)
            }
        }else{
            if indexPath.row == 0 {
                return
            }
            if newsInfos.list[indexPath.row - 1].type != "2" {
                if let tmpCell = tableView.cellForRow(at: indexPath) as? StockPlateNewsCell {
                    if let snapView = tmpCell.snapshotView(afterScreenUpdates: true) {
                        let rect = tableView.convert(tmpCell.frame, to: UtilTools.getAppDelegate()?.window ?? self.view)
                        if rect.origin.y < 64 {
                            return
                        }
                        snapView.frame = rect
                        snapView.backgroundColor = Color("#fff")
                        UtilTools.getAppDelegate()?.window??.addSubview(snapView)
                        animation(times: 4, snapView: snapView)
                    }
                }
            }else{
                let url                 = newsInfos.list[indexPath.row - 1].url
                let newsDetail          = BaseWebViewController()
                newsDetail.relativeUrl  = url
                self.navigationController?.pushViewController(newsDetail, animated: true)
            }
        }
    }
    
    private func animation(times: Int ,snapView: UIView) {
        self.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.02, animations: {
            snapView.frame.origin.x -= 3
        }, completion: { (Bool) in
            UIView.animate(withDuration: 0.02, animations: {
                snapView.frame.origin.x += 3
            }, completion: { (Bool) in
                UIView.animate(withDuration: 0.02, animations: {
                    snapView.frame.origin.x += 3
                }, completion: { (Bool) in
                    UIView.animate(withDuration: 0.02, animations: {
                        snapView.frame.origin.x -= 3
                    }, completion: { (Bool) in
                        let time = times - 1
                        if time < 0 {
                            snapView.removeFromSuperview()
                            self.view.isUserInteractionEnabled = true
                        }else{
                            self.animation(times: time, snapView: snapView)
                        }
                    })
                })
            })
        })
    }
    
    override func selectedItemForSegmentedBar(_ segmentedBar: SelectedSegmentedBar, selectedSegmentedIndex: Int) {
        super.selectedItemForSegmentedBar(segmentedBar, selectedSegmentedIndex: selectedSegmentedIndex)
        if segmentedBar.tag == BOTTOM_SEGMENT_TAG {
            selectedIndex = selectedSegmentedIndex
            IndexOfPlateInfo = selectedSegmentedIndex
            let str = selectedSegmentedIndex == 0 ? "gegu" : "xinwen"
            Behavior.eventReport(str)
            page = 1
            if selectedIndex == 1 {
                tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
            }
            requestList()
        }
    }
    
    func stockPlateNewsCellCheck(with url: String) {
        let newsDetail          = BaseWebViewController()
        newsDetail.relativeUrl  = url
        self.navigationController?.pushViewController(newsDetail, animated: true)
    }
    
    func stockPlateNewsCellCheckStcok(with data: MainStockCardData) {
        self.navigationController?.pushStockDetailController(["name" : data.stockName as AnyObject , "code" : data.stockCode as AnyObject], animated: true)
    }
    
    private func showStockData() {
        tableView.reloadData()
        if selectedBar == nil {
            selectedBar = SelectBar(type: 1)
            selectedBar.delegate = self
        }
        if headerList == nil {
            headerList = SortHeaderView()
            headerList.delegate = self
        }
        if plateCell == nil {
            plateCell = ChartsInfoCell()
            plateCell.backgroundColor = Color("#fafdff")
            plateCell.needSep = true
        }
        headerList.showHeader(stocksInfo.headList)
        plateCell.proportion = stocksInfo.bkInfo["ratio"] + ""
        plateCell.attributes = stocksInfo.bkInfo["style"] as? Array<Dictionary<String,AnyObject>>
        plateCell.cellData = stocksInfo.bkInfo as AnyObject
    }
    
    override open func refreshData() {
        super.refreshData()
        if selectedIndex == 0 {
            requestList(true)
        }
    }
    
    func requestList(_ auto: Bool = false) {
        weak var weakSelf = self
        setFooterRefresh {
            weakSelf?.page += 1
            weakSelf?.requestList()
        }
        if selectedIndex == 0 {
            
            var tmpPage  = page
            var tmpCount = 10
            if page != 1 && auto {
                tmpPage  = 1
                tmpCount = page * 10
            }
            var param : Dictionary<String,String> = ["page" : "\(tmpPage)",
                                                     "code" : self.param?["code"] + "",
                                                     "filterType" : "\(barIndex)",
                                                     "date" : date,
                                                     "pagecount" : "\(tmpCount)"]
            for (key , value) in para {
                param[key] = value
            }
            StockService.getConceptStockData(param, completion: { (stockData) in
                weakSelf?.endRefresh()
                if stockData?.resultCode == 10000 {
                    let tmp = stockData as! StockBKStockData
                    if tmpPage == 1 {
                        weakSelf?.stocksInfo = tmp
                    }else{
                        if weakSelf?.stocksInfo == nil {
                            weakSelf?.stocksInfo    = tmp
                        }else{
                            weakSelf?.stocksInfo.headList = tmp.headList
                            weakSelf?.stocksInfo.bkInfo = tmp.bkInfo
                            weakSelf?.stocksInfo.stockList += tmp.stockList
                        }
                    }
                    weakSelf?.showStockData()
                    if tmp.stockList.count < tmpCount {
                        weakSelf?.removeFooterRefresh()
                    }
                }else{
                    weakSelf?.page -= 1
                    UtilTools.noticError(view: self.view, msg: stockData!.errorMsg!)
                }
            }, failure: { (error) in
                weakSelf?.endRefresh()
                weakSelf?.page -= 1
                UtilTools.noticError(view: self.view, msg: error!.msg!)
            })
        }else{
            StockService.getPlatesNewsWithId(param?["code"] + "" , page: page , completion: { (newsData) in
                weakSelf?.endRefresh()
                if newsData!.resultCode! == 10000 {
                    let tmp                     = newsData as! StockPlateNewsData
                    if self.page == 1 {
                        self.newsInfos          = tmp
                    }else{
                        self.newsInfos.list    += tmp.list
                    }
                    if tmp.list.count < 10 {
                        self.tableView.mj_footer?.removeFromSuperview()
                        self.tableView.mj_footer = nil
                    }
                    self.tableView.reloadData()
                }else{
                    weakSelf?.page -= 1
                }
            }, failure: { (error) in
                weakSelf?.endRefresh()
                weakSelf?.page -= 1
            })
        }
    }
    
    func selectBarItemClicked(index: Int) {
        var ev = ""
        switch index {
        case 0:
            ev = "ri"
        case 1:
            ev = "zhou"
        case 2:
            ev = "yue"
        case 3:
            ev = "sanyue"
        case 4:
            ev = "bannian"
        default:
            ev = "riqi_chaxun"
        }
        Behavior.eventReport(ev)
        if index == 10 {
            let calendar                = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
            let adcomps                 = NSDateComponents()
            adcomps.year                = 0
            adcomps.month               = -3
            adcomps.day                 = 0
            if let oldDate = calendar?.date(byAdding: adcomps as DateComponents, to: Date(), options: NSCalendar.Options(rawValue: 0))
            {
                
                let picker                  = StrategyDatePickerView()
                picker.delegate             = self
                let str                     = UtilDate.formatTime("yyyyMMdd", time_interval: Int(oldDate.timeIntervalSince1970))
                picker.earliestDate         = str
                picker.latestDate           = lastDate
                picker.currentDate          = self.date
                picker.show()
            }
        }else{
            self.barIndex = index
            page = 1
            requestList()
        }
    }
    func strategyDatePickerError() {
        print("错误日期")
    }
    
    func strategyDatePickerPick(_ date : String)
    {
        let str                     = UtilDate.convertFormatByDate("yyyyMMdd", date_time: date, toFormat: "MM-dd")
        selectedBar.title           = str
        self.date                   = date
        self.barIndex               = SelectBarType.Calendar.rawValue
        page                        = 1
        requestList()
    }
    
    func chartsInfoCellSelected(_ cType: BaseViewController.Type?, indexPath: IndexPath?, param: Dictionary<String, AnyObject>!) {
        self.navigationController?.pushStockDetailController(param, animated: true)
    }
    
    func sortHeaderViewSorted(_ key: String, sortDirection: Int) {
        var ev = ""
        if key == "percent" {
            ev = "anzhangdie"
        }else if key == "main_percent" {
            ev = "anzijin"
        }
        if !ev.isEmpty {
            Behavior.eventReport(ev)
        }
        para = ["orderKey" : key , "orderValue" : "\(sortDirection)"]
        page = 1
        requestList()
    }
    
    func sortHeaderViewFilter(_ key: String, options: Array<Dictionary<String, AnyObject>>, currentOrder: String, listTitle: String) -> String? {
        return nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === tableView && selectedIndex == 0 {
            let sectionHeaderHeight : CGFloat = 88
            if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
            {
                scrollView.contentInset = UIEdgeInsets.init(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
            }
            else if (scrollView.contentOffset.y >= sectionHeaderHeight)
            {
                scrollView.contentInset = UIEdgeInsets.init(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    open override func getVcId() -> String {
        return StockUtil.getRegisterIdForVc(type(of: self))
    }
    
    var selectedIndex : Int = 0
    var bottomSegment : SelectedSegmentedBar!
    private var stocksInfo : StockBKStockData!
    private var selectedBar : SelectBar!
    private var newsInfos : StockPlateNewsData!
    private var headerList : SortHeaderView!
    private var plateCell : ChartsInfoCell!
    private var ratio : String = "1:1:1:1"
    private var cellAttri : Array<Dictionary<String,AnyObject>> = Array()
    private var para : Dictionary<String,String> = Dictionary()
    private var barIndex : Int = 0
    private lazy var date : String = UtilDate.formatTime("yyyyMMdd", time_interval: UtilDate.getTimeInterval())
    private lazy var lastDate : String = UtilDate.formatTime("yyyyMMdd", time_interval: UtilDate.getTimeInterval())
}
