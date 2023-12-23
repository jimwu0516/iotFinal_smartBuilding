//
//  BikeViewController.swift
//  iotproject
//
//  Created by Jim Wu on 2023/12/10.
//

import UIKit
import Charts

struct YouBikeData: Codable {
    let sno: String
    let sbi: Int
    let bemp: Int
}


class BikeViewController: UIViewController {
    
    var pieChartView: PieChartView!
    @IBOutlet weak var bikeLabel: UILabel!
    @IBOutlet weak var dockLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        
        pieChartView = PieChartView()
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        pieChartView.frame = CGRect(
            x: (screenWidth - 400) / 2,
            y: (screenHeight - 400) / 2,
            width: 400,
            height: 400
        )
        view.addSubview(pieChartView)
        
        configurePieChart()
        
        self.updateData(forSNO: "500106044")
    }
    
    func configurePieChart() {
        pieChartView.usePercentValuesEnabled = true
        pieChartView.legend.enabled = false
        pieChartView.entryLabelColor = .clear
        pieChartView.entryLabelFont = .systemFont(ofSize: 12)
        pieChartView.noDataText = "Loading..."
    }
    
    @objc func updateData(forSNO sno: String) {
        if let url = URL(string: "https://tcgbusfs.blob.core.windows.net/dotapp/youbike/v2/youbike_immediate.json") {
            let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                guard let self = self, let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    let youbikeDataArray = try decoder.decode([YouBikeData].self, from: data)
                    
                    if let targetData = youbikeDataArray.first(where: { $0.sno == sno }) {
                        DispatchQueue.main.async {
                            self.bikeLabel.text = "\(targetData.sbi)"
                            self.dockLabel.text = "\(targetData.bemp)"
                            self.updatePieChartData(sbiValue: targetData.sbi, bempValue: targetData.bemp)
                            print(sno)
                        }
                    }
                } catch {
                    print("🤬ERROR：\(error)")
                }
            }
            task.resume()
        }
    }
    
    func updatePieChartData(sbiValue: Int, bempValue: Int) {
        let dataSet = PieChartDataSet(entries: [
            PieChartDataEntry(value: Double(sbiValue)),
            PieChartDataEntry(value: Double(bempValue))
        ])
        
        dataSet.sliceSpace = 3.0
        dataSet.colors = [NSUIColor.green, NSUIColor.red]
        dataSet.drawValuesEnabled = false
        
        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data
        
        DispatchQueue.main.async {
            self.pieChartView.notifyDataSetChanged()
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            updateData(forSNO: "500106044")
        case 1:
            updateData(forSNO: "500106110")
        default:
            break
        }
    }
    
    
    
    
}
