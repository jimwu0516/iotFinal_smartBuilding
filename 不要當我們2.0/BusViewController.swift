//
//  BusViewController.swift
//  iotproject
//
//  Created by Jim Wu on 2023/12/10.
//

import UIKit
import Charts

class BusViewController: UIViewController {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarChart()
        fetchData()
    }
    
    func setupBarChart() {
        barChartView = BarChartView()
        barChartView.frame = CGRect(x: 16, y: 130, width: view.frame.size.width - 32, height: 520)
        view.addSubview(barChartView)
    }
    
    
    func fetchData() {
        guard let url = URL(string: "https://tdx.transportdata.tw/api/basic/v2/Bus/EstimatedTimeOfArrival/City/Taipei/262?%24top=100&%24format=JSON") else {
            return
        }
        
        var request = URLRequest(url: url)
        let accessToken = "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJER2lKNFE5bFg4WldFajlNNEE2amFVNm9JOGJVQ3RYWGV6OFdZVzh3ZkhrIn0.eyJleHAiOjE3MDMyMzU4MTUsImlhdCI6MTcwMzE0OTQxNSwianRpIjoiZjg5NjY3NmUtMDM0Mi00YzgwLWEwMzktODFlNWE4ZTI2ZDUyIiwiaXNzIjoiaHR0cHM6Ly90ZHgudHJhbnNwb3J0ZGF0YS50dy9hdXRoL3JlYWxtcy9URFhDb25uZWN0Iiwic3ViIjoiNzU3NGZkOGEtNDI2ZC00ZTZmLWFjZGQtYWY1Mzc2MjA2MDNiIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiMTEwNDYwODQtN2Y0MjFhOWItNGYwOS00N2ViIiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJzdGF0aXN0aWMiLCJwcmVtaXVtIiwicGFya2luZ0ZlZSIsIm1hYXMiLCJhZHZhbmNlZCIsInZhbGlkYXRvciIsImhpc3RvcmljYWwiLCJiYXNpYyJdfSwic2NvcGUiOiJwcm9maWxlIGVtYWlsIiwidXNlciI6Ijg2MDljNDY4In0.bQHNRoXoHkjhO6VjrHtzZlYDI0G66vWNk7bGRa65DPZ7G_QIsYjpEXcNcwE7PLUa3LpwiSFcx1QbhnP3oB5xV6qQ31_hWoXBEkW6Fvj1waLT0Nx1rNd3JvAIOATBD2aiGNcRaqHahSwo5ZcgWoUhK5PIeDZ4uCSKYW3nfZpoetp7FnjUZW2SxMGnQC3UiOdt5uXV6Z6d13Vle1hjDDcVWStoVK3YzwgQEYTz15B7BA3gl_0fmV3QgNO8tUoDHzI2Z1uOEXdy-Vt72aSRvEaZ4Q19GCT4TnVSKEGNYG1LTU8jtEeBBRtOoiF71JXA7flTf9IXnQdphNUcppdZi1daeQ"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
                
                var entries: [BarChartDataEntry] = []
                
                for item in json {
                    if let stopName = item["StopName"] as? [String: Any],
                       let zhTw = stopName["Zh_tw"] as? String,
                       zhTw == "捷運善導寺站",
                       let direction = item["Direction"] as? Int,
                       let estimateTime = item["EstimateTime"] as? Int {
                        
                        if direction == 0 {
                            
                            DispatchQueue.main.async {
                                let min = estimateTime / 60
                                let sec = estimateTime % 60
                                self.label1.text = "\(min)min \(sec)sec"
                                print("民生社區: \(min)min \(sec)sec")
                            }
                            
                        } else if direction == 1 {
                            DispatchQueue.main.async {
                                let min = estimateTime / 60
                                let sec = estimateTime % 60
                                self.label2.text = "\(min)min \(sec)sec"
                                print("宏國德霖科大\(min)min \(sec)sec")
                            }
                        }
                        
                        entries.append(BarChartDataEntry(x: Double(direction), y: Double(estimateTime)))
                    }
                }
                
                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.updateBarChart(entries: entries)
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
    func updateBarChart(entries: [BarChartDataEntry]) {
        let dataSet = BarChartDataSet(entries: entries, label: "")
        let data = BarChartData(dataSet: dataSet)
        dataSet.valueFont = UIFont.systemFont(ofSize: 17.0) // 設定資料數值的字體大小
        barChartView.data = data
        barChartView.noDataText = "Loading..."
        barChartView.legend.form = .none // 取消圖例
        barChartView.scaleXEnabled = false // 關閉 x 軸縮放
        barChartView.scaleYEnabled = false // 關閉 y 軸縮放
        barChartView.xAxis.drawGridLinesEnabled = false // 取消垂直網格線
        barChartView.leftAxis.drawGridLinesEnabled = false // 顯示水平網格線
        barChartView.rightAxis.enabled = false // 取消右側 y 軸座標
        barChartView.leftAxis.enabled = false // 取消右側 y 軸座標
        barChartView.xAxis.enabled = false // 取消x 軸座標
    }
}


