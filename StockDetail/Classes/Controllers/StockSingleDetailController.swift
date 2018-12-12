//
//  StockSingleDetailController.swift
//  Subject
//
//  Created by zhangyr on 2016/11/29.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

open class StockSingleDetailController: StockBasicDetailController ,PlateCellDelegate {

    override func isStock() -> Bool {
        return true
    }
    
    override open func initUI() {
        super.initUI()
        tableView.register(StockNewsCell.self, forCellReuseIdentifier: "newsCell")
        tableView.register(StockReportTableViewCell.self, forCellReuseIdentifier: "reportCell")
        if let index = IndexOfStockChart {
            topSegment.setIndexWithAction(for: index)
        }
        
        if let index = IndexOfStockInfo {
            selectedIndex = index
        }
        requestList()
    }
    
    override open func refreshData() {
        super.refreshData()
        requestRelationPlateData()
    }
    
    override func initBottom() {
        
        bottomView = UIView()
        bottomView?.backgroundColor = Color(COLOR_COMMON_WHITE)
        tableHeaderView.addSubview(bottomView!)
        bottomView?.snp.makeConstraints({ (maker) in
            maker.left.equalTo(chartsView)
            maker.right.equalTo(chartsView)
            maker.top.equalTo(chartsView.snp.bottom).offset(10)
            maker.height.equalTo(130)
        })
        
        hintLabel = UILabel()
        hintLabel.font = UIFont.normalFontOfSize(12)
        hintLabel.backgroundColor = Color(COLOR_COMMON_WHITE)
        hintLabel.textColor = Color(COLOR_COMMON_BLACK_9)
        hintLabel.textAlignment = .center
        hintLabel.text = "相关板块"

        let line = UIView()
        line.backgroundColor = Color("#ddd")
        
        bottomView?.addSubview(line)
        bottomView?.addSubview(hintLabel)
        
        hintLabel.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(bottomView!)
            maker.top.equalTo(bottomView!)
            maker.width.equalTo(70)
            maker.height.equalTo(30)
        }
        
        line.snp.makeConstraints { (maker) in
            maker.center.equalTo(hintLabel)
            maker.width.equalTo(hintLabel).offset(110)
            maker.height.equalTo(0.5)
        }
        
    }
    
    private func requestRelationPlateData() {
        
        if bottomView == nil {
            return
        }
        
        StockService.getRelationPlateData(param?["code"] + "", completion: {(relation) in
            if relation?.resultCode == 10000 {
                self.relationPlate = relation as? StockRelationPlateData
            }
            self.resetRelationPlate()
        }, failure: { (error) in
            self.resetRelationPlate()
        })
        
    }
    
    private func requestList() {
        
        weak var weakSelf = self
        StockService.getNewsListWithParams(["code" : param?["code"] + "" , "page" : "\(page)"], newsType: selectedIndex, completion: { (bsd) -> Void in
            weakSelf?.tableView.mj_footer?.endRefreshing()
            if bsd!.resultCode == 10000 {
                if let arr = bsd!.resultData as? Array<Any> {
                    if self.page == 1 {
                        weakSelf?.setFooterRefresh {
                            weakSelf?.page += 1
                            weakSelf?.requestList()
                        }
                        self.newsInfos = arr
                    }else{
                        self.newsInfos.append(contentsOf: arr)
                    }
                    
                    if arr.count < 10 {
                        weakSelf?.removeFooterRefresh()
                    }
                    self.tableView.reloadData()
                }else{
                    weakSelf?.removeFooterRefresh()
                    weakSelf?.page -= 1
                    self.newsInfos = []
                    self.tableView.reloadData()
                }
            }else{
                weakSelf?.page -= 1
            }
            
        }) { (error) -> Void in
            weakSelf?.tableView.mj_footer?.endRefreshing()
            weakSelf?.page -= 1
        }
    }
    
    private func resetRelationPlate() {
        
        if relationPlate == nil || relationPlate.list.isEmpty {
            bottomView?.removeFromSuperview()
            bottomView = nil
            tableHeaderView.frame.size.height = 473 - 140
            tableView.tableHeaderView = tableHeaderView
        }else{
            
            if relationPlateView == nil {
                let column = SCREEN_WIDTH < 350 ? 3 : 4
                relationPlateView = PlateCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil, columNumber: column)
                relationPlateView.delegate = self
                bottomView?.addSubview(relationPlateView)
                if bottomView != nil {
                    relationPlateView.snp.makeConstraints({ (maker) in
                        maker.left.equalTo(bottomView!)
                        maker.right.equalTo(bottomView!)
                        maker.top.equalTo(hintLabel.snp.bottom)
                        maker.bottom.equalTo(bottomView!).offset(-12)
                    })
                }
            }
            
            relationPlateView.data = relationPlate.list
            
        }
        
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.fiveView {
            return sbFive == nil ? 0 : sbFive.count
        }
        switch selectedIndex {
        case 0: //新闻
            fallthrough
        case 1: //公告
            return (newsInfos == nil || newsInfos.count == 0) ? 1 : newsInfos.count
        case 2: //研报
            return (newsInfos == nil || newsInfos.count == 0) ? 1 : newsInfos.count + 1
        case 3: //简况
            return introData == nil ? 0 : 1
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
        case 0: //新闻
            fallthrough
        case 1: //公告
            fallthrough
        case 2: //研报
            let str = (selectedIndex == 1) ? "公告" : (selectedIndex == 0) ? "新闻" : "研报"
            if newsInfos == nil || newsInfos.count == 0 {
                let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
                cell.selectionStyle = .none
                cell.backgroundColor = Color(COLOR_COMMON_WHITE)
                
                let hint = UILabel()
                hint.textColor = Color(COLOR_COMMON_BLACK_9)
                hint.font = UIFont.normalFontOfSize(14)
                hint.textAlignment = .center
                hint.text = "暂无\(str)数据"
                cell.addSubview(hint)
                hint.snp.makeConstraints({ (maker) in
                    maker.center.equalTo(cell)
                })
                return cell
            }else{
                if selectedIndex != 2 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! StockNewsCell
                    cell.newsInfo = newsInfos[indexPath.row] as? NSDictionary
                    return cell
                }else{
                    if indexPath.row == 0 {
                        let cell            = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)
                        cell.selectionStyle = .none
                        cell.isUserInteractionEnabled = false
                        let nameHint        = UILabel()
                        nameHint.font       = UIFont.normalFontOfSize(14)
                        nameHint.textColor  = Color("#999")
                        nameHint.text       = "机构名称"
                        cell.addSubview(nameHint)
                        nameHint.snp.makeConstraints({ (maker) in
                            maker.left.equalTo(cell).offset(12)
                            maker.bottom.equalTo(cell).offset(-5)
                        })
                        
                        let levHint         = UILabel()
                        levHint.font        = UIFont.normalFontOfSize(14)
                        levHint.textColor   = Color("#999")
                        levHint.text        = "评级"
                        levHint.textAlignment = .center
                        cell.addSubview(levHint)
                        levHint.snp.makeConstraints({ (maker) in
                            maker.centerX.equalTo(cell)
                            maker.bottom.equalTo(cell).offset(-5)
                        })
                        
                        let dateHint        = UILabel()
                        dateHint.font       = UIFont.normalFontOfSize(14)
                        dateHint.textColor  = Color("#999")
                        dateHint.text       = "日期"
                        dateHint.textAlignment = .right
                        cell.addSubview(dateHint)
                        dateHint.snp.makeConstraints({ (maker) in
                            maker.right.equalTo(cell).offset(-12)
                            maker.bottom.equalTo(cell).offset(-5)
                        })
                        
                        let line            = UIView()
                        line.backgroundColor    = Color("#ddd")
                        cell.addSubview(line)
                        line.snp.makeConstraints({ (maker) in
                            maker.left.equalTo(cell).offset(12)
                            maker.right.equalTo(cell).offset(-12)
                            maker.bottom.equalTo(cell)
                            maker.height.equalTo(0.5)
                        })
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath) as! StockReportTableViewCell
                        if let dic = newsInfos[indexPath.row - 1] as? Dictionary<String , Any> {
                            let rData           = StockReportData()
                            rData.insname       = dic["insname"] + ""
                            rData.ratingText    = dic["rating_text"] + ""
                            rData.pubdate       = dic["pubdate"] + ""
                            cell.reportData     = rData
                        }
                        return cell
                    }
                }
            }
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
        case 0: //新闻
            fallthrough
        case 1: //公告
            return 60
        case 2: //研报
            return 40
        case 3: //简况
            return introData == nil ? 0 : 760
        default:
            break
        }
        return 0
    }
    
    @objc override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView === fiveView {
            return 0
        }
        return 38
    }
    
    @objc override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView === fiveView {
            return nil
        }
        if bottomSegment == nil {
            bottomSegment = SelectedSegmentedBar(frame: CGRect(x: 0,
                                                               y: 0,
                                                               width: self.view.bounds.width,
                                                               height: 38),
                                                 items: ["新闻","公告","研报"],
                                                 delegate: self)
            bottomSegment?.tag = BOTTOM_SEGMENT_TAG
        }
        bottomSegment?.index = selectedIndex
        return bottomSegment
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !(tableView.cellForRow(at: indexPath) is StockNewsCell) && !(tableView.cellForRow(at: indexPath) is StockReportTableViewCell) {
            return
        }
        
        guard (indexPath.row - (selectedIndex == 2 ? 1 : 0)) >= 0, let dic = newsInfos[indexPath.row - (selectedIndex == 2 ? 1 : 0)] as? NSDictionary else {
            return
        }
        var url    = ""
        var key_id = ""
        let name    = self.param?["name"] + ""
        let newsType = (selectedIndex == 1) ? "公告" : (selectedIndex == 0) ? "新闻" : "研报"
        let navi_title = name.count > 0 ? name + "-" + newsType : newsType
        if let _ = dic["para"] as? Dictionary<String,AnyObject> , let tUrl = dic["url"] as? String {
            let subjectDetail = BaseWebViewController()
            subjectDetail.relativeUrl    = tUrl
            self.navigationController?.pushViewController(subjectDetail, animated: true)
            return
        }
        switch newsType {
        case "新闻" :
            key_id = "newsid"
            url = "\(ServerType.base.rawValue)stock/news/detail?newsid=%@&res_type=html5"
        case "公告" :
            key_id = "id"
            url = "\(ServerType.base.rawValue)stock/announcement/detail?res_type=html5&aid=%@"
        default :
            break
        }
        let newsDetail = BaseWebViewController()
        newsDetail.title = navi_title
        let nid = dic[key_id] + ""
        if newsType == "研报" {
            newsDetail.relativeUrl = dic["detail_url"] + ""
        }else{
            newsDetail.url = String(format: url, nid)
        }
        self.navigationController?.pushViewController(newsDetail, animated: true)
    }
    
    override func selectedItemForSegmentedBar(_ segmentedBar: SelectedSegmentedBar, selectedSegmentedIndex: Int) {
        super.selectedItemForSegmentedBar(segmentedBar, selectedSegmentedIndex: selectedSegmentedIndex)
        if segmentedBar.tag == BOTTOM_SEGMENT_TAG {
            selectedIndex = selectedSegmentedIndex
            IndexOfStockInfo = selectedSegmentedIndex
            var ev = ""
            switch selectedSegmentedIndex {
            case 0: //新闻
                fallthrough
            case 1: //公告
                fallthrough
            case 2: //研报
                if selectedSegmentedIndex == 1 {
                    ev = "gonggao"
                }else if selectedSegmentedIndex == 0 {
                    ev = "xinwen"
                }else{
                    ev = "yanbao"
                }
                page = 1
                weak var weakSelf = self
                setFooterRefresh {
                    weakSelf?.page += 1
                    weakSelf?.requestList()
                }
                requestList()
                break
            case 3: //简况
                break
            default:
                break
            }
            Behavior.eventReport(ev)
        }
    }
    
    
    func itemClicked(index: IndexPath?, data: Dictionary<String, AnyObject>?) {
        let stockVc = StockConceptDetailController(parameters: data)
        self.navigationController?.pushViewController(stockVc, animated: true)
    }
    
    open override func getVcId() -> String {
        return StockUtil.getRegisterIdForVc(type(of: self))
    }
    
    private var relationPlate : StockRelationPlateData!
    private var relationPlateView : PlateCell!
    private var hintLabel : UILabel!
    private var selectedIndex : Int = 0
    private var bottomSegment : SelectedSegmentedBar?
    private var introData : Dictionary<String,AnyObject>!
    private var holderData : Array<Dictionary<String,AnyObject>>!
    private var newsInfos : Array<Any>!
}
