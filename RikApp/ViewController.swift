//
//  ViewController.swift
//  RikApp
//
//  Created by Данила Бондарь on 05.06.2025.
//

import UIKit
import PinLayout

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v = DoubleBarChart()
        view.addSubview(v)
        v.pin.horizontally(7%).aspectRatio(4).vCenter()
        v.backgroundColor = .secondarySystemFill
        v.item = DoubleBarChartItem(title: "18-25", firstItem: DoubleBarItem(title: "10%", color: .manStatistic, percentage: 0), secondItem: DoubleBarItem(title: "25%", color: .womanStatistics, percentage: 1))
    }
    
}

