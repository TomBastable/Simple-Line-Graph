//
//  ViewController.swift
//  Dribbble-Chart
//
//  Created by Tom Bastable on 05/04/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SimpleChartDelegate {

    @IBOutlet var simpleChart: SimpleChart!
    var stubData: [Double] = [50, 130, 70, 220, 90, 280, 220]
    var stubLabels = ["March 1", "March 12", "March 18", "March 20", "March 22", "March 25", "March 30"]
    @IBOutlet var chartLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        simpleChart.setupChartWith(labels: stubLabels, data: stubData)
        simpleChart.delegate = self
    }

    @IBAction func renewChart(_ sender: Any) {
        stubLabels = ["1", "12", "18", "20", "22", "25", "30", "105", "102", "105"]
        stubData = [11, 3, 13, 2, 8, 10, 4, 10, 1, 4]
        simpleChart.setupChartWith(labels: stubLabels, data: stubData)
    }

    func chartIndexChanged(index: Int) {
        chartLabel.text = "\(Int(stubData[index]))"
    }

}
