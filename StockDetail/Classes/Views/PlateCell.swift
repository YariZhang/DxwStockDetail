//
//  PlateCell.swift
//  Subject
//
//  Created by focus on 2016/11/22.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService

protocol PlateCellDelegate : NSObjectProtocol
{
    func itemClicked(index : IndexPath?, data : Dictionary<String, AnyObject>?)
}

class PlateCell: UITableViewCell, PlateViewDelegate
{
    
    weak var delegate   : PlateCellDelegate?
    var index      : IndexPath?
    
    var data : Array<Dictionary<String, AnyObject>>?
    {
        didSet
        {
            if data != nil
            {
                self.reload(data: data!)
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, columNumber : Int = 4) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        self.columns        = columNumber
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func initUI()
    {
        self.backgroundColor        = UIColor.white
        self.selectionStyle         = .none
        let width                   = (SCREEN_WIDTH - 24) / CGFloat(columns)
        for i in 0 ..< columns
        {
            let plate               = PlateView()
            plate.needRightSep      = (i != columns - 1)
            plate.delegate          = self
            self.addSubview(plate)
            self.plates.append(plate)
            
            plate.snp.makeConstraints({ (maker) in
                maker.top.equalTo(self)
                maker.left.equalTo(self).offset(CGFloat(12 + CGFloat(i) * width))
                maker.height.equalTo(89)
                maker.width.equalTo(width)
            })
        }
    }
    
    private func reload(data : Array<Dictionary<String, AnyObject>>)
    {
        if data.count < columns //不满的情况
        {
            let offset  = columns == self.plates.count ? (columns - data.count) : (self.plates.count - data.count)
            if offset < 0
            {
                for v in self.plates
                {
                    v.removeConstraints(v.constraints)
                    v.removeFromSuperview()
                }
                self.plates.removeAll(keepingCapacity: false)
                
                let width                   = (SCREEN_WIDTH - 24) / CGFloat(columns)
                
                for i in 0 ..< self.plates.count
                {
                    let plate       = PlateView()
                    plate.delegate  = self
                    self.addSubview(plate)
                    self.plates.append(plate)
                    
                    plate.snp.makeConstraints({ (maker) in
                        maker.top.equalTo(self)
                        maker.left.equalTo(self).offset(CGFloat(12 + CGFloat(i) * width))
                        maker.height.equalTo(89)
                        maker.width.equalTo(width)
                    })
                }
                return
            }else if offset == 0
            {
            }else
            {
                for i in data.count ..< plates.count
                {
                    let v   = plates[i]
                    v.removeConstraints(v.constraints)
                    v.removeFromSuperview()
                }
                self.plates.removeLast(offset)
            }
        }else
        {
            if self.plates.count != data.count //有短缺，被移除过，复位一下。
            {
                for v in self.plates
                {
                    v.removeConstraints(v.constraints)
                    v.removeFromSuperview()
                }
                self.plates.removeAll(keepingCapacity: false)
                
                let width                   = (SCREEN_WIDTH - 24) / CGFloat(columns)
                
                for i in 0 ..< columns
                {
                    let plate       = PlateView()
                    plate.delegate  = self
                    self.addSubview(plate)
                    self.plates.append(plate)
                    
                    plate.snp.makeConstraints({ (maker) in
                        maker.top.equalTo(self)
                        maker.left.equalTo(self).offset(CGFloat(12 + CGFloat(i) * width))
                        maker.height.equalTo(89)
                        maker.width.equalTo(width)
                    })
                }
            }
        }
        
        for i in 0 ..< data.count
        {
            let dic     = data[i]
            guard i < plates.count else {
                return
            }
            let v       = plates[i]
            v.data      = dic
        }
    }
    
    func itemClicked(data : Dictionary<String, AnyObject>?)
    {
        if let d = data
        {
            if let para = d["para"] as? Dictionary<String, AnyObject>
            {
                self.delegate?.itemClicked(index: self.index, data: para)
            }
        }
    }
    
    
    fileprivate var plates  : Array<PlateView>      = [PlateView]()
    fileprivate var columns : Int                   = 4
}


protocol PlateViewDelegate : NSObjectProtocol
{
    func itemClicked(data : Dictionary<String, AnyObject>?)
}

class PlateView : BaseView
{
    weak var delegate : PlateViewDelegate?
    
    var needRightSep    : Bool  = true
    {
        didSet
        {
            self.sepRight.isHidden      = !needRightSep
        }
    }
    
    var needBottomSep   : Bool  = true
    {
        didSet
        {
            self.sepBottom.isHidden     = !needBottomSep
        }
            
    }
    
    var data        : Dictionary<String, AnyObject>?
    {
        didSet
        {
            if data != nil
            {
                self.reload()
            }
        }
    }
    
    
    fileprivate var firstLabel      : UILabel!
    fileprivate var secondLabel     : UILabel!
    fileprivate var thirdLabel      : UILabel!
    fileprivate var sepBottom       : BaseView!
    fileprivate var sepRight        : BaseView!
    fileprivate var icon            : UIImageView?
    fileprivate var btn             : BaseButton!
    
    override func initUI() {
        super.initUI()
        firstLabel          = UILabel()
        secondLabel         = UILabel()
        thirdLabel          = UILabel()
        sepBottom           = BaseView()
        sepRight            = BaseView()
        btn                 = BaseButton()
        
        
        btn.addTarget(self, action: #selector(PlateView.btnClicked(sender:)), for: UIControl.Event.touchUpInside)
        
        sepBottom.backgroundColor       = Color(COLOR_COMMON_WHITE)
        sepRight.backgroundColor        = Color(COLOR_COMMON_WHITE)
        
        firstLabel.textAlignment        = .center
        secondLabel.textAlignment       = .center
        thirdLabel.textAlignment        = .center
        
        firstLabel.font                 = UIFont.boldFontOfSize(13)
        secondLabel.font                = UIFont.boldFontOfSize(15)
        thirdLabel.font                 = UIFont.boldFontOfSize(10)
        firstLabel.textColor            = Color(COLOR_COMMON_WHITE)
        secondLabel.textColor           = Color(COLOR_COMMON_WHITE)
        thirdLabel.textColor            = Color(COLOR_COMMON_WHITE)
        
        self.addSubview(firstLabel)
        self.addSubview(secondLabel)
        self.addSubview(thirdLabel)
        self.addSubview(sepBottom)
        self.addSubview(sepRight)
        self.addSubview(btn)
        
        firstLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(self).offset(25)
            maker.width.equalTo(self)
            maker.height.equalTo(13)
            maker.left.equalTo(self)
        }
        
        secondLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.firstLabel.snp.bottom).offset(5)
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.height.equalTo(13)
        }
        
        thirdLabel.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self).offset(-7)
            maker.height.equalTo(10)
            maker.left.equalTo(self)
            maker.right.equalTo(self)
        }
        
        sepBottom.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self)
            maker.height.equalTo(1.5)
            maker.left.equalTo(self)
            maker.right.equalTo(self)
        }
        
        sepRight.snp.makeConstraints { (maker) in
            maker.right.equalTo(self)
            maker.width.equalTo(1.5)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
        }
        
        btn.snp.makeConstraints { (maker) in
            maker.left.equalTo(self)
            maker.right.equalTo(self)
            maker.top.equalTo(self)
            maker.bottom.equalTo(self)
        }
    }
    
    
    private func reload()
    {
        if let dd = self.data
        {
            if let color = dd["color"] as? String
            {
                firstLabel.textColor    = Color(color)
                secondLabel.textColor   = Color(color)
                thirdLabel.textColor    = Color(color)
            }
            if let bgcolor = dd["bgcolor"] as? String
            {
                self.backgroundColor    = Color(bgcolor)
            }
            
            firstLabel.text             = dd["name"] + ""
            secondLabel.text            = dd["percent"] + ""
            thirdLabel.text             = dd["text"] + ""
            
            if self.icon != nil
            {
                self.icon!.removeConstraints(self.icon!.constraints)
                self.icon!.removeFromSuperview()
            }
            self.icon                   = self.getImageView(data: dd)
            if self.icon != nil
            {
                self.addSubview(self.icon!)
                self.icon?.snp.makeConstraints({ (maker) in
                    maker.top.equalTo(self)
                    maker.left.equalTo(self).offset(10)
                })
            }
        }
    }
    
    
    @objc func btnClicked(sender : BaseButton)
    {
        self.delegate?.itemClicked(data: self.data)
    }
    
    
    private func getImageView(data : Dictionary<String, AnyObject>) -> UIImageView?
    {
        if let img = data["subjectIcon"] as? String
        {
            if img == "-1"
            {
                return nil
            }
            if let x = Int(img)
            {
                return UIImageView(image : UIImage(named: "plate_icon_subject_\(x)"))
            }
            
        }
        
        return nil
    }
}
