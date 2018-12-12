//
//  CandleStickChartView.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics
import BasicService

/// Financial chart type that draws candle-sticks.
open class CandleStickChartView: BarLineChartViewBase, CandleStickChartRendererDelegate
{
    
    open  var volumeLabel : UILabel!
    fileprivate var maView      : UIView!
    fileprivate var ma5Label    : UILabel!
    fileprivate var ma5Text     : UILabel!
    fileprivate var ma10Label   : UILabel!
    fileprivate var ma10Text    : UILabel!
    fileprivate var ma20Label   : UILabel!
    fileprivate var ma20Text    : UILabel!
    fileprivate var dateLabel   : UILabel!
    fileprivate var highPrice   : UILabel!
    fileprivate var openPrice   : UILabel!
    fileprivate var lowPrice    : UILabel!
    fileprivate var closePrice  : UILabel!
    fileprivate var floatRate   : UILabel!
    open var currentVol         : UILabel!
    open var tabBtn1            : BaseButton!
    open var tabBtn2            : BaseButton!
    fileprivate var tapBtn      : BaseButton!
    fileprivate var showView    : UIView!
    fileprivate var loadingHint : UIView!
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    internal override func initialize()
    {
        super.initialize()
        NotificationCenter.default.addObserver(self, selector: #selector(CandleStickChartView.stockVolumeChanded(noti:)), name: NSNotification.Name("StockVolumeTypeChanded"), object: nil)
        volumeLabel               = UILabel()
        self.addSubview(volumeLabel)

        volumeLabel.frame         = CGRect(x: 0, y: 250, width: 20, height: 12)
        volumeLabel.font          = UIFont.normalFontOfSize(10)
        volumeLabel.textColor     = UtilColor.getTextBlackColor()
        volumeLabel.textAlignment = NSTextAlignment.right
        
        let screenWidth = UIScreen.main.bounds.width
        
        if self.bounds.size.width > screenWidth {
            maView                        = UIView()
            ma5Label                      = UILabel()
            ma5Text                       = UILabel()
            ma10Label                     = UILabel()
            ma10Text                      = UILabel()
            ma20Label                     = UILabel()
            ma20Text                      = UILabel()
            

            ma5Label.layer.cornerRadius   = 2.5
            ma5Label.layer.masksToBounds  = true
            ma10Label.layer.cornerRadius  = 2.5
            ma10Label.layer.masksToBounds = true
            ma20Label.layer.cornerRadius  = 2.5
            ma20Label.layer.masksToBounds = true
            ma5Text.font                  = UIFont.normalFontOfSize(10)
            ma5Text.textColor             = UtilColor.getTextBlackColor()
            ma10Text.font                 = UIFont.normalFontOfSize(10)
            ma10Text.textColor            = UtilColor.getTextBlackColor()
            ma20Text.font                 = UIFont.normalFontOfSize(10)
            ma20Text.textColor            = UtilColor.getTextBlackColor()
            
            
            self.addSubview(maView)
            maView.addSubview(ma5Label)
            maView.addSubview(ma5Text)
            maView.addSubview(ma10Label)
            maView.addSubview(ma10Text)
            maView.addSubview(ma20Label)
            maView.addSubview(ma20Text)
            
            
            
            let w : CGFloat          = 15
            let width                = (self.bounds.size.width - 100 - w * 5) / 5
            let height : CGFloat     = 20
            let fSize : CGFloat      = 12

            showView                 = UIView(frame: CGRect(x: 0, y: -15, width: self.bounds.size.height, height: height))
            showView.isHidden          = true
            dateLabel                = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: height))
            dateLabel.textAlignment  = .center
            dateLabel.textColor      = UtilColor.getTextBlackColor()
            dateLabel.font           = UIFont.normalFontOfSize(fSize)

            let high                 = UILabel(frame: CGRect(x: dateLabel.frame.maxX, y: dateLabel.frame.minY, width: w, height: height))
            high.textAlignment       = .center
            high.textColor           = UtilColor.getHintLabelColor()
            high.font                = UIFont.normalFontOfSize(fSize)
            high.text                = "高"

            highPrice                = UILabel(frame: CGRect(x: high.frame.maxX, y: high.frame.minY, width: width, height: height))
            highPrice.textAlignment  = .center
            highPrice.textColor      = UtilColor.getTextBlackColor()
            highPrice.font           = UIFont.normalFontOfSize(fSize)

            let open                 = UILabel(frame: CGRect(x: highPrice.frame.maxX, y: dateLabel.frame.minY, width: w, height: height))
            open.textAlignment       = .center
            open.textColor           = UtilColor.getHintLabelColor()
            open.font                = UIFont.normalFontOfSize(fSize)
            open.text                = "开"

            openPrice                = UILabel(frame: CGRect(x: open.frame.maxX, y: high.frame.minY, width: width, height: height))
            openPrice.textAlignment  = .center
            openPrice.textColor      = UtilColor.getTextBlackColor()
            openPrice.font           = UIFont.normalFontOfSize(fSize)

            let low                  = UILabel(frame: CGRect(x: openPrice.frame.maxX, y: dateLabel.frame.minY, width: w, height: height))
            low.textAlignment        = .center
            low.textColor            = UtilColor.getHintLabelColor()
            low.font                 = UIFont.normalFontOfSize(fSize)
            low.text                 = "低"

            lowPrice                 = UILabel(frame: CGRect(x: low.frame.maxX, y: high.frame.minY, width: width, height: height))
            lowPrice.textAlignment   = .center
            lowPrice.textColor       = UtilColor.getTextBlackColor()
            lowPrice.font            = UIFont.normalFontOfSize(fSize)

            let close                = UILabel(frame: CGRect(x: lowPrice.frame.maxX, y: dateLabel.frame.minY, width: w, height: height))
            close.textAlignment      = .center
            close.textColor          = UtilColor.getHintLabelColor()
            close.font               = UIFont.normalFontOfSize(fSize)
            close.text               = "收"

            closePrice               = UILabel(frame: CGRect(x: close.frame.maxX, y: high.frame.minY, width: width, height: height))
            closePrice.textAlignment = .center
            closePrice.textColor     = UtilColor.getTextBlackColor()
            closePrice.font          = UIFont.normalFontOfSize(fSize)

            let fR                   = UILabel(frame: CGRect(x: closePrice.frame.maxX, y: dateLabel.frame.minY, width: w * 2, height: height))
            fR.textAlignment         = .center
            fR.textColor             = UtilColor.getHintLabelColor()
            fR.font                  = UIFont.normalFontOfSize(fSize)
            fR.text                  = "涨跌"

            floatRate                = UILabel(frame: CGRect(x: fR.frame.maxX, y: high.frame.minY, width: width, height: height))
            floatRate.textAlignment  = .center
            floatRate.textColor      = UtilColor.getTextBlackColor()
            floatRate.font           = UIFont.normalFontOfSize(fSize)
            
            self.addSubview(showView)
            showView.addSubview(dateLabel)
            showView.addSubview(high)
            showView.addSubview(highPrice)
            showView.addSubview(open)
            showView.addSubview(openPrice)
            showView.addSubview(low)
            showView.addSubview(lowPrice)
            showView.addSubview(close)
            showView.addSubview(closePrice)
            showView.addSubview(fR)
            showView.addSubview(floatRate)
            
            loadingHint          = UIView(frame: CGRect.zero)
            let hint             = UILabel()
            hint.textColor       = Color("#999999")
            hint.font            = UIFont.normalFontOfSize(12)
            hint.text            = "数据加载中···"
            hint.backgroundColor = UIColor.clear
            self.addSubview(loadingHint)
            loadingHint.addSubview(hint)
            
            hint.snp.makeConstraints({ (maker) -> Void in
                maker.left.equalTo(self.loadingHint)
                maker.top.equalTo(self.loadingHint)
                maker.width.equalTo(self.loadingHint)
                maker.height.equalTo(self.loadingHint)
            })
        }
        
        currentVol                    = UILabel()
        tabBtn1                       = BaseButton()
        tabBtn2                       = BaseButton()
        currentVol.font               = UIFont.boldFontOfSize(11)
        currentVol.textColor          = UtilColor.getTextBlackColor()
        currentVol.backgroundColor    = UIColor.clear
        
        
        tabBtn1.setTitle("成交量", for: UIControl.State.normal)
        tabBtn2.setTitle("主力资金", for: UIControl.State.normal)
        tabBtn1.titleLabel?.font        = UIFont.normalFontOfSize(13)
        tabBtn2.titleLabel?.font        = UIFont.normalFontOfSize(13)
        tabBtn1.tag                     = 1001
        tabBtn2.tag                     = 1002
        
        tabBtn1.layer.borderWidth       = 0.5
        tabBtn1.layer.cornerRadius      = 0.5
        tabBtn1.layer.borderColor       = Color("#e0e0e0").cgColor
        tabBtn2.layer.borderWidth       = 0.5
        tabBtn2.layer.cornerRadius      = 0.5
        tabBtn2.layer.borderColor       = Color("#e0e0e0").cgColor
        tabBtn1.layer.masksToBounds     = true
        tabBtn2.layer.masksToBounds     = true
        
        tabBtn1.addTarget(self, action: #selector(CandleStickChartView.btnClicked(sender:)), for: UIControl.Event.touchUpInside)
        tabBtn2.addTarget(self, action: #selector(CandleStickChartView.btnClicked(sender:)), for: UIControl.Event.touchUpInside)
        if stockVolumeType == .volume
        {
            tabBtn1.backgroundColor       = tabSelectedBgColor
            tabBtn2.backgroundColor       = tabUnselectedBgColor
            tabBtn1.setTitleColor(tabSelectedTitleColor, for: UIControl.State.normal)
            tabBtn2.setTitleColor(tabUnselectedTitleColor, for: UIControl.State.normal)
        }else
        {
            tabBtn1.backgroundColor       = tabUnselectedBgColor
            tabBtn2.backgroundColor       = tabSelectedBgColor
            tabBtn1.setTitleColor(tabUnselectedTitleColor, for: UIControl.State.normal)
            tabBtn2.setTitleColor(tabSelectedTitleColor, for: UIControl.State.normal)
        }
        
        tapBtn                      = BaseButton()
        tapBtn.addTarget(self, action: #selector(CandleStickChartView.switchVolume), for: UIControl.Event.touchUpInside)
        
        self.addSubview(currentVol)
        self.addSubview(tapBtn)
        self.addSubview(tabBtn1)
        self.addSubview(tabBtn2)
        
        tapBtn.snp.makeConstraints { (maker) in
            maker.left.equalTo(self).offset(self._viewPortHandler.contentLeft)
            maker.top.equalTo(self).offset(self._viewPortHandler.contentTopVolume)
            maker.width.equalTo(self._viewPortHandler.contentWidthVolume)
            maker.height.equalTo(self._viewPortHandler.contentHeightVolume)
        }
        
        renderer = CandleStickChartRenderer(delegate: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _chartXMin = -0.5
    }
    
    @objc private func switchVolume() {
        if stockVolumeType == .mainMoney {
            stockVolumeType = .volume
        }else{
            stockVolumeType = .mainMoney
        }
    }

    func showMaData(_ kline : KLineData , alignment : NSTextAlignment , isShowLoading : Bool , isPressing : Bool) {
        
        if maView != nil
        {
            maView.snp.remakeConstraints({ (maker) -> Void in
                maker.left.equalTo(self._viewPortHandler.contentLeft)
                maker.width.equalTo(self._viewPortHandler.contentWidth)
                maker.top.equalTo(self._viewPortHandler.contentTop)
                maker.height.equalTo(16)
            })
            if alignment == .left {
                
                ma5Label.snp.remakeConstraints({ (maker) -> Void in
                    maker.left.equalTo(self.maView).offset(4)
                    maker.centerY.equalTo(self.maView)
                    maker.width.equalTo(5)
                    maker.height.equalTo(5)
                })
                
                ma5Text.snp.remakeConstraints({ (maker) -> Void in
                    maker.left.equalTo(self.ma5Label.snp.right).offset(4)
                    maker.centerY.equalTo(self.maView)
                    maker.width.greaterThanOrEqualTo(15)
                    maker.height.equalTo(12)
                })
                
                ma10Label.snp.remakeConstraints({ (maker) -> Void in
                    maker.left.equalTo(self.ma5Text.snp.right).offset(4)
                    maker.centerY.equalTo(self.maView)
                    maker.width.equalTo(5)
                    maker.height.equalTo(5)
                })
                
                ma10Text.snp.remakeConstraints({ (maker) -> Void in
                    maker.left.equalTo(self.ma10Label.snp.right).offset(4)
                    maker.centerY.equalTo(self.maView)
                    maker.width.greaterThanOrEqualTo(15)
                    maker.height.equalTo(12)
                })
                
                ma20Label.snp.remakeConstraints({ (maker) -> Void in
                    maker.left.equalTo(self.ma10Text.snp.right).offset(4)
                    maker.centerY.equalTo(self.maView)
                    maker.width.equalTo(5)
                    maker.height.equalTo(5)
                })
                
                ma20Text.snp.remakeConstraints({ (maker) -> Void in
                    maker.left.equalTo(self.ma20Label.snp.right).offset(4)
                    maker.centerY.equalTo(self.maView)
                    maker.width.greaterThanOrEqualTo(15)
                    maker.height.equalTo(12)
                })
                
            }else{
                
                ma20Text.snp.remakeConstraints({ (maker) -> Void in
                    maker.right.equalTo(self.maView).offset(-4)
                    maker.centerY.equalTo(self.maView)
                    maker.width.greaterThanOrEqualTo(15)
                    maker.height.equalTo(12)
                })
                
                ma20Label.snp.remakeConstraints({ (maker) -> Void in
                    maker.right.equalTo(self.ma20Text.snp.left).offset(-4)
                    maker.centerY.equalTo(self.maView)
                    maker.width.equalTo(5)
                    maker.height.equalTo(5)
                })
                
                ma10Text.snp.remakeConstraints({ (maker) -> Void in
                    maker.right.equalTo(self.ma20Label.snp.left).offset(-4)
                    maker.centerY.equalTo(self.maView)
                    maker.width.greaterThanOrEqualTo(15)
                    maker.height.equalTo(12)
                })
                
                ma10Label.snp.remakeConstraints({ (maker) -> Void in
                    maker.right.equalTo(self.ma10Text.snp.left).offset(-4)
                    maker.centerY.equalTo(self.maView)
                    maker.width.equalTo(5)
                    maker.height.equalTo(5)
                })
                
                ma5Text.snp.remakeConstraints({ (maker) -> Void in
                    maker.right.equalTo(self.ma10Label.snp.left).offset(-4)
                    maker.centerY.equalTo(self.maView)
                    maker.width.greaterThanOrEqualTo(15)
                    maker.height.equalTo(12)
                })
                
                ma5Label.snp.remakeConstraints({ (maker) -> Void in
                    maker.right.equalTo(self.ma5Text.snp.left).offset(-4)
                    maker.centerY.equalTo(self.maView)
                    maker.width.equalTo(5)
                    maker.height.equalTo(5)
                })
                
            }
            
            let dataSet               = self.data?.dataSets[0] as! CandleChartDataSet
            
            ma5Label.backgroundColor  = dataSet.averageFive
            ma5Text.text              = String(format: "MA5 %.2f", kline.ma5.doubleValue)
            ma10Label.backgroundColor = dataSet.averageTen
            ma10Text.text             = String(format: "MA10 %.2f", kline.ma10.doubleValue)
            ma20Label.backgroundColor = dataSet.averageTwenty
            ma20Text.text             = String(format: "MA20 %.2f", kline.ma20.doubleValue)
            
            showView.isHidden         = false
            dateLabel.text            = kline.date
            highPrice.text            = String(format: "%.2f", kline.high.doubleValue)
            highPrice.textColor       = colorForInfo(kline.high.doubleValue, kline: kline)
            openPrice.text            = String(format: "%.2f", kline.open.doubleValue)
            openPrice.textColor       = colorForInfo(kline.open.doubleValue, kline: kline)
            lowPrice.text             = String(format: "%.2f", kline.low.doubleValue)
            lowPrice.textColor        = colorForInfo(kline.low.doubleValue, kline: kline)
            closePrice.text           = String(format: "%.2f", kline.close.doubleValue)
            closePrice.textColor      = colorForInfo(kline.close.doubleValue, kline: kline)
            if kline.price_change.doubleValue > 0 {
                floatRate.text        = String(format: "+%.2f%%", kline.p_change.doubleValue)
            }else{
                floatRate.text        = String(format: "%.2f%%", kline.p_change.doubleValue)
            }
            floatRate.textColor       = colorForInfo(kline.close.doubleValue, kline: kline)
            
            if isShowLoading {
                loadingHint.snp.remakeConstraints({ (maker) -> Void in
                    maker.left.equalTo(self._viewPortHandler.contentLeft)
                    maker.width.equalTo(100)
                    maker.top.equalTo(self._viewPortHandler.contentTop).offset(self.viewPortHandler.contentHeight / 2)
                    maker.height.equalTo(20)
                })
                loadingHint.isHidden    = false
            }else{
                loadingHint.isHidden    = true
            }

        }
        
        self.tabBtn1.isHidden   = isPressing
        self.tabBtn2.isHidden   = isPressing
        
        currentVol.snp.remakeConstraints({ (maker) -> Void in
            maker.left.equalTo(self).offset(self._viewPortHandler.contentLeft + 4)
            maker.top.equalTo(self).offset(self._viewPortHandler.contentTopVolume + 4)
            maker.width.equalTo(self._viewPortHandler.contentWidth - 8)
            maker.height.equalTo(14)
        })
        
        tabBtn1.snp.remakeConstraints { (maker) in
            maker.left.equalTo(self).offset(self._viewPortHandler.contentLeft + 4)
            maker.top.equalTo(self).offset(self._viewPortHandler.contentTopVolume + 4)
            maker.width.equalTo(47)
            maker.height.equalTo(18)
        }
        
        tabBtn2.snp.remakeConstraints { (maker) in
            maker.left.equalTo(self.tabBtn1.snp.right).offset(-0.5)
            maker.top.equalTo(self.tabBtn1)
            maker.width.equalTo(60)
            maker.height.equalTo(18)
        }
        
        currentVol.textAlignment = alignment
        
        
        if stockVolumeType == StockVolumeType.volume
        {
            let volume                = isPressing ? kline.volume.doubleValue : 0
            if !isPressing
            {
                currentVol.text         = ""
                return
            }
            if self.renderer!.maxVolume >= 100_000_000 {
                currentVol.text = String(format: "%.2f亿手", volume / 100_000_000)
            }else if self.renderer!.maxVolume >= 10_000_000 {
                currentVol.text = String(format: "%.2f千万手", volume / 10_000_000)
            }else if self.renderer!.maxVolume >= 10000 {
                currentVol.text = String(format: "%.2f万手", volume / 10000)
            }else{
                currentVol.text = String(format: "%.0f手", volume)
            }
            currentVol.textColor          = UtilColor.getTextBlackColor()
        }else
        {
            let mainMoney               = isPressing ? kline.main_amount.doubleValue : 0
            let percent                 = isPressing ? kline.main_percent : ""
            if !isPressing
            {
                currentVol.text         = ""
                return
            }
            if self.renderer!.maxVolume >= 100_000_000 {
                currentVol.text = "净: " + String(format: "%.2f亿", mainMoney / 100_000_000) + "  占: " + percent
            }else if self.renderer!.maxVolume >= 10_000_000 {
                currentVol.text = "净: " + String(format: "%.2f千万", mainMoney / 10_000_000) + "  占: " + percent
            }else if self.renderer!.maxVolume >= 10000 {
                currentVol.text = "净: " + String(format: "%.2f万", mainMoney / 10000) + "  占: " + percent
            }else{
                currentVol.text = "净: " + String(format: "%.0f", mainMoney) + "  占: " + percent
            }
            
            currentVol.textColor        = Color(COLOR_COMMON_BLACK_3)
        }
        
    }
    
    @objc func btnClicked(sender : BaseButton)
    {
        if sender.tag == 1001
        {
            Behavior.eventReport("rixian_zitu_chengjiao")
            tabBtn1.backgroundColor         = tabSelectedBgColor
            tabBtn2.backgroundColor         = tabUnselectedBgColor
            tabBtn1.setTitleColor(tabSelectedTitleColor, for: UIControl.State.normal)
            tabBtn2.setTitleColor(tabUnselectedTitleColor, for: UIControl.State.normal)
            stockVolumeType                 = .volume
        }else
        {
            Behavior.eventReport("rixian_zitu_zijin")
            tabBtn1.backgroundColor         = tabUnselectedBgColor
            tabBtn2.backgroundColor         = tabSelectedBgColor
            tabBtn1.setTitleColor(tabUnselectedTitleColor, for: UIControl.State.normal)
            tabBtn2.setTitleColor(tabSelectedTitleColor, for: UIControl.State.normal)
            stockVolumeType                 = .mainMoney
        }
    }
    
    @objc func stockVolumeChanded(noti : NSNotification)
    {
        if noti.name.rawValue == "StockVolumeTypeChanded"
        {
            if let info = noti.userInfo
            {
                if let v = info["value"] as? StockVolumeType
                {
                    self.setNeedsDisplay()
                    if v == .volume
                    {
                        tabBtn1.backgroundColor         = tabSelectedBgColor
                        tabBtn2.backgroundColor         = tabUnselectedBgColor
                        tabBtn1.setTitleColor(tabSelectedTitleColor, for: UIControl.State.normal)
                        tabBtn2.setTitleColor(tabUnselectedTitleColor, for: UIControl.State.normal)
                    }else
                    {
                        tabBtn1.backgroundColor         = tabUnselectedBgColor
                        tabBtn2.backgroundColor         = tabSelectedBgColor
                        tabBtn1.setTitleColor(tabUnselectedTitleColor, for: UIControl.State.normal)
                        tabBtn2.setTitleColor(tabSelectedTitleColor, for: UIControl.State.normal)
                    }
                }
            }
        }
    }
    
    fileprivate func colorForInfo(_ cp : Double , kline : KLineData) -> UIColor {
        
        let preClose = kline.close.doubleValue - kline.price_change.doubleValue
        
        if cp > preClose {
            return UtilColor.getRedTextColor()
        }else if cp < preClose {
            return UtilColor.getGreenStockColor()
        }else{
            return UtilColor.getTextBlackColor()
        }
    }

    internal override func calcMinMax()
    {
        super.calcMinMax()

        _chartXMax += 0.5
        _deltaX = CGFloat(abs(_chartXMax - _chartXMin))
    }
    
    // MARK: - CandleStickChartRendererDelegate
    
    open func candleStickChartRendererCandleData(_ renderer: CandleStickChartRenderer) -> CandleChartData!
    {
        return _data as! CandleChartData!
    }
    
    open func candleStickChartRenderer(_ renderer: CandleStickChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return self.getTransformer(which)
    }
    
    open func candleStickChartDefaultRendererValueFormatter(_ renderer: CandleStickChartRenderer) -> NumberFormatter!
    {
        return self.valueFormatter
    }
    
    open func candleStickChartRendererChartYMax(_ renderer: CandleStickChartRenderer) -> Double
    {
        return self.chartYMax
    }
    
    open func candleStickChartRendererChartYMin(_ renderer: CandleStickChartRenderer) -> Double
    {
        return self.chartYMin
    }
    
    open func candleStickChartRendererChartXMax(_ renderer: CandleStickChartRenderer) -> Double
    {
        return self.chartXMax
    }
    
    open func candleStickChartRendererChartXMin(_ renderer: CandleStickChartRenderer) -> Double
    {
        return self.chartXMin
    }
    
    open func candleStickChartRendererMaxVisibleValueCount(_ renderer: CandleStickChartRenderer) -> Int
    {
        return self.maxVisibleValueCount
    }
}
