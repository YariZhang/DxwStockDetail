//
//  StockPlateNewsData.swift
//  Subject
//
//  Created by zhangyr on 2016/11/9.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import BasicService
import TYAttributedLabel

class StockPlateNewsData: BaseModel {
    var list        : Array<StockPlateNewsItemData> = Array()
}

class StockPlateNewsItemData : BaseModel {
    
    var pubdate     : String = ""
    var title       : String = ""
    var content     : String = ""
    var type        : String = ""
    var url         : String = ""
    var stocks      : Array<MainStockCardData> = Array()
    
    var titleHeight : CGFloat {
        if title.isEmpty {
            return 0
        }
        let paragraph           = NSMutableParagraphStyle()
        paragraph.lineSpacing   = 5
        let rect    = (title as NSString).boundingRect(with: CGSize(width: SCREEN_WIDTH - 48 ,height : 999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.boldFontOfSize(16), convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle) : paragraph]), context: nil)
        if rect.height > 32 {
            return 48
        }else{
            return rect.height
        }
    }
    
    var contentHeight  : CGFloat {
        if content.isEmpty {
            return 0
        }
        let tmpStr              = content
        let tmpLabel            = TYAttributedLabel()
        tmpLabel.linesSpacing   = 6
        tmpLabel.font           = UIFont.normalFontOfSize(15)
        tmpLabel.text           = tmpStr
        if type == "2" {
            tmpLabel.numberOfLines = 2
        }
        let height              = CGFloat(tmpLabel.getHeightWithWidth(SCREEN_WIDTH - 48))
        return height
    }
    
    var cellHeight     : CGFloat {
        return 58 + titleHeight + contentHeight - (content.isEmpty ? 12 : 0) - (title.isEmpty ? 12 : 0) + (stocks.isEmpty ? 0 : 15) + (type == "2" ? 5 : 0)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
