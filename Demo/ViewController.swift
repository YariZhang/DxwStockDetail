//
//  ViewController.swift
//  Demo
//
//  Created by zhangyr on 2018/12/10.
//  Copyright © 2018 zhangyr. All rights reserved.
//

import UIKit
import StockDetail
import QCGURLRouter

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        
        tableView.frame = self.view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    private let titles = [["个股": ["code": "000001", "name": "平安银行"]],
                          ["行业": ["code": "HY340972", "name": "多元金融"]],
                          ["概念": ["code": "GN300319", "name": "深圳国改"]],
                          ["市场": ["code": "sh000001", "name": "上证指数"]]]

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titles[indexPath.row].keys.first
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let d = titles[indexPath.row]
        var vc: UIViewController!
        switch indexPath.row {
        case 0:
            QCGURLRouter.shareInstance.route(withUrl: URL(string: "/zixuan/0/gegu/detail")!, param: d[d.keys.first!])
            return
            //vc = StockSingleDetailController(parameters: d[d.keys.first + ""])
        case 1:
            vc = StockIndustryViewController(parameters: d[d.keys.first!])
        case 2:
            vc = StockConceptDetailController(parameters: d[d.keys.first!])
        case 3:
            vc = StockMarketViewController(parameters: d[d.keys.first!])
        default:
            break
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

