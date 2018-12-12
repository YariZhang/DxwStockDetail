//
//  KLineViewChart.swift
//  KLineView
//
//  Created by zhangyr on 15/9/14.
//  Copyright (c) 2015年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

@objc protocol KLineViewChartDelegate : NSObjectProtocol  {
    @objc optional func kLineViewMoreInfo(with data : KLineData)
}


class KLineViewChart: NSObject , ChartViewDelegate{

    weak var chartView         : CandleStickChartView!
    fileprivate var klineData : Array<KLineData> = Array()
    fileprivate var width     : CGFloat = 8
    fileprivate var maxWidth  : CGFloat = 20
    fileprivate var fromDate  : String  = ""
    fileprivate var isLoading : Bool    = false
    fileprivate var isOver    : Bool    = false
    fileprivate weak var delegate : KLineViewChartDelegate?
    fileprivate var isToday     : Bool {
        return !self.klineData.isEmpty && self.klineData.last!.date == UtilDate.convertFormatByDate("yyyyMMdd", date_time: self.currentDate, toFormat: "yyyy-MM-dd")
    }
    var currentDate       : String = ""
    var reqCode           : String  = "sh000001"
    var reqType           : String  = "D" {
        didSet {
            fromDate = ""
            klineData.removeAll(keepingCapacity: false)
            requestData()
        }
    }
    var pChange           : Float   = 0
    var todayPrice        : Float   = 0 {
        didSet {
            if !isToday {
                requestData()
            }
            guard isToday && reqType == "D" && chartView != nil else {
                return
            }
            if let d = klineData.last {
                d.p_change = NSNumber(value: pChange)
                d.close = NSNumber(value: todayPrice)
                if chartView.globeMatrix == .identity {
                    self.setKLineData(self.klineData)
                }else{
                    self.setKLineData(self.klineData ,isAppend: true, modify: true)
                }
            }
        }
    }
    var reqCount          : Int     = 300
    
    required init(chartView : CandleStickChartView , delegate : KLineViewChartDelegate? , reqCode : String , reqType : String , isFull : Bool , currentDate : String = "") {
        super.init()
        self.chartView = chartView
        self.chartView.backgroundColor = UIColor.lightGray
        self.currentDate = currentDate
        self.chartView.backgroundColor  = Color("#fff")
        self.reqCode   = reqCode
        self.reqType   = reqType
        self.delegate  = delegate
        
        chartView.delegate                  = self
        chartView.descriptionText           = ""
        chartView.noDataTextDescription     = "数据加载中···"
        
        chartView.maxVisibleValueCount      = 5
        chartView.pinchZoomEnabled          = isFull
        chartView.drawGridBackgroundEnabled = false
        chartView.doubleTapToZoomEnabled    = isFull
        chartView.scaleYEnabled             = false
        chartView.autoScaleMinMaxEnabled    = true
        chartView.drawBordersEnabled        = true
        chartView.dragEnabled               = isFull
        chartView.longPressEnabled          = isFull
        chartView.borderColor               = Color("#ddd")
        chartView.borderLineWidth           = 0.5
        
        let xAxis : ChartXAxis              = chartView.xAxis
        xAxis.labelPosition                 = ChartXAxis.XAxisLabelPosition.bottom
        xAxis.spaceBetweenLabels            = 20
        xAxis.drawGridLinesEnabled          = true
        xAxis.drawAxisLineEnabled           = false
        xAxis.avoidFirstLastClippingEnabled = true
        
        let leftAxis : ChartYAxis           = chartView.leftAxis;
        leftAxis.labelCount                 = 5
        leftAxis.drawGridLinesEnabled       = true
        leftAxis.drawAxisLineEnabled        = false
        leftAxis.startAtZeroEnabled         = false
        leftAxis.labelPosition              = .insideChart
        
        let rightAxis : ChartYAxis          = chartView.rightAxis
        rightAxis.enabled                   = false
        chartView.legend.enabled            = false
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { 
            self.requestData()
        }
    }
    
    func requestData() {
        let key     = reqCode + "-" + reqType
        if let tempData = UtilTools.getUserDefaults(key), let dic = tempData as? Dictionary<String , Any> {
            
            if let timeout = dic["timeout"] as? Int {
                let now = UtilDate.getTimeInterval()
                if now > (timeout + 7 * 24 * 60 * 60) {
                    requestKlineData()
                    return
                }
            }else{
                UtilTools.removeUserDefaults(key)
                requestKlineData()
                return
            }
            if let d = self.klineData.last?.date , d != "错误时间" {
                let date = UtilDate.convertFormatByDate("yyyy-MM-dd", date_time: d, toFormat: "yyyyMMdd")
                if Int(date) < Int(currentDate) {
                    let td = UtilDate.getTimeIntervalByDateString("yyyy-MM-dd", dateStr: d) - 24 * 60 * 60
                    let pDate = UtilDate.formatTime("yyyyMMdd", time_interval: td)
                    requestKlineData(pDate , endDate: currentDate)
                }else if date == currentDate {
                    requestKlineData("", endDate: date, isCurrent: true)
                }else{
                    self.setKLineData(self.klineData)
                }
            }else{
                requestKlineData()
            }
        }else{
            requestKlineData()
        }
    }
    
    @objc private func refreshKline(_ timer: Timer) {
        if !glStockNeedRefresh || glStockNetRefreshPeriod < 0.5 {
            timer.invalidate()
        }else{
            self.requestData()
        }
    }
    
    func requestKlineData(_ startDate : String = "" , endDate : String = "" , isCurrent : Bool = false) {
        let eDate    = endDate.isEmpty ? fromDate : endDate
        let count    = isCurrent ? 1 : reqCount
        let key      = self.reqCode + "-" + self.reqType
        let version  = UtilTools.getUserDefaults(key + "-data_version") + ""
        let preStart = startDate.isEmpty ? startDate : UtilDate.formatTime("yyyyMMdd", time_interval: UtilDate.getTimeIntervalByDateString(dateStr: startDate))
        StockService.getStockKLineWithURL(["code" : reqCode ,
                                           "ktype" : reqType ,
                                           "start_date" : preStart ,
                                           "end_date" : eDate ,
                                           "count" : "\(count)" ,
                                           "data_version" : version],completion: { (kData) -> Void in
            if kData?.resultCode == 10000 {
                let kdata = kData as! KLineJsonData
                UtilTools.setUserDefaults(kdata.dataVersion, key: key + "-data_version")
                self.isLoading = false
                if kdata.klineList == nil || kdata.klineList!.isEmpty {
                    self.isLoading = true
                    self.isOver    = true
                }
                
                if kdata.needReset && kdata.klineList != nil {
                    self.klineData = kdata.klineList
                    self.setKLineData(self.klineData)
                }else{
                    if !startDate.isEmpty {
                        if self.klineData.isEmpty {
                            self.klineData  = kdata.klineList ?? []
                        }else{
                            if kdata.klineList != nil && self.klineData.last?.date == kdata.klineList.first?.date {
                                self.klineData.removeLast()
                            }
                            self.klineData  = self.klineData + (kdata.klineList ?? [])
                        }
                        self.setKLineData(self.klineData)
                    }else{
                        if isCurrent && kdata.klineList != nil {
                            if kdata.klineList.count == 1 {
                                let d = UtilDate.convertFormatByDate("yyyy-MM-dd", date_time: kdata.klineList[0].date, toFormat: "yyyyMMdd")
                                if d == endDate {
                                    self.klineData.removeLast()
                                    self.klineData.append(kdata.klineList[0])
                                    self.setKLineData(self.klineData)
                                }
                            }
                        }else{
                            if self.fromDate.isEmpty {
                                self.klineData = kdata.klineList ?? []
                                if self.klineData.count > 0 {
                                    self.setKLineData(self.klineData)
                                }
                            }else{
                                self.klineData = (kdata.klineList ?? []) + self.klineData
                                if kdata.klineList?.count > 0 {
                                    self.setKLineData(self.klineData , isAppend : true , count : kdata.klineList!.count)
                                }
                            }
                        }
                    }
                }
                
            }else{
                UtilTools.noticError(view: self.chartView, msg: kData!.errorMsg! , offset : 50)
                self.isLoading = false
            }
            
        }) { (error) -> Void in
            UtilTools.noticError(view: self.chartView, msg: error!.msg! , offset : 50)
            self.isLoading = false
            if self.fromDate.isEmpty {
                self.setKLineData(self.klineData)
            }
        }
    }
    
    func setKLineData(_ data : Array<KLineData>? , isAppend : Bool = false , count : Int = 0 ,modify: Bool = false) {
        
        var xVals = Array<String>()
        var yVals = Array<CandleChartDataEntry>()
        
        if data != nil && data!.count > 0 && chartView != nil {
            var counts = Int(chartView._viewPortHandler.contentRect.width / (width + 0.1))
            if counts <= data?.count {
                counts = data!.count
                let countOfCandles = Int(chartView.bounds.width / (maxWidth + 0.1))
                let scaleX = countOfCandles == 0 ? 1.0 : CGFloat(data!.count) / CGFloat(countOfCandles)
                chartView._viewPortHandler.maxScaleX = scaleX
                chartView.isFilled = false
            }else{
                chartView._viewPortHandler.maxScaleX = CGFloat(counts) / CGFloat(data!.count)
                chartView.dragEnabled = false
                chartView.isFilled = true
            }
            var min : Double = Double(CGFloat.greatestFiniteMagnitude)
            for i in 0 ..< counts {
                if i < data?.count {
                    let kData = data![i]
                    if kData.low.doubleValue < min {
                        min = kData.low.doubleValue
                    }
                    xVals.append(kData.date)
                    let candleEntry = CandleChartDataEntry(xIndex: i, shadowH: kData.high.doubleValue, shadowL: kData.low.doubleValue, open: kData.open.doubleValue, close: kData.close.doubleValue, data: kData)
                    yVals.append(candleEntry)
                }else{
                    xVals.append("")
                    let line = KLineData()
                    line.high         = NSNumber(value: min)
                    line.low          = NSNumber(value: min)
                    line.open         = NSNumber(value: min)
                    line.close        = NSNumber(value: min)
                    line.isFilled     = true
                    yVals.append(CandleChartDataEntry(xIndex: i, shadowH: line.high.doubleValue, shadowL: line.low.doubleValue, open: line.open.doubleValue, close: line.close.doubleValue, data: line))
                }
            }
            let set                     = CandleChartDataSet(yVals: yVals, label: "KLine")
            set.axisDependency          = ChartYAxis.AxisDependency.left
            set.setColor(UIColor(white: 80/255, alpha: 1.0))
            set.shadowColor             = UtilColor.getRedStockColor()
            set.shadowWidth             = 1.0
            set.drawValuesEnabled       = true
            set.shadowColorSameAsCandle = true
            set.decreasingColor         = UtilColor.getGreenColor()
            set.decreasingFilled        = true
            set.increasingColor         = UtilColor.getRedStockColor()
            set.increasingFilled        = true
            set.averageFive             = UtilColor.getBlueTextColor()
            set.averageTen              = UtilColor.getKLineMA10Color()
            set.averageTwenty           = UtilColor.getKLineMA20Color()
            let candleData              = CandleChartData(xVals: xVals, dataSet: set)
            chartView.data              = candleData
            chartView.widthOfCandle = Double(self.width)
            if self.chartView._countOfCandles >= data!.count {
                self.isOver = true
            }
            if isAppend {
                chartView.moveViewTo(xIndex: count, yValue: 0, axis: .right, modify: modify)
            }
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let kLine        = entry.data as! KLineData
        
        if kLine.isFilled.boolValue {
            self.chartView.dragEnabled = false
        }
        let counts = Int(chartView._viewPortHandler.contentRect.width / (width + 0.1))
        //println("entry.xIndex : \(entry.xIndex) , counts : \(counts)")
        if entry.xIndex <= counts * 3 / 2 && !isLoading && self.klineData.count >= 150 {
            let sets = chartView.data!.dataSets[dataSetIndex] as ChartDataSet
            if let e = sets.entryForXIndex(0)?.data as? KLineData {
                let timeInterval = UtilDate.getTimeIntervalByDateString("yyyy-MM-dd", dateStr: e.date)
                self.fromDate = UtilDate.formatTime("yyyyMMdd", time_interval: timeInterval - 24 * 60 * 60)
                isLoading = true
                requestKlineData()
            }
        }
        
        let min = chartView.renderer!.minX
        let max = chartView.renderer!.maxX
        
        var loadingStatus = false
        
        if min == 0 && self.isLoading && !isOver{
            loadingStatus = true
        }
        
        if entry.xIndex < (min + max) / 2 {
            self.chartView.showMaData(kLine, alignment: .right , isShowLoading : loadingStatus , isPressing : self.chartView.isPressing)
        }else{
            self.chartView.showMaData(kLine, alignment: self.chartView.isPressing ? .left : .right , isShowLoading : loadingStatus , isPressing : self.chartView.isPressing)
        }
        delegate?.kLineViewMoreInfo?(with: kLine)
    }
    
}

