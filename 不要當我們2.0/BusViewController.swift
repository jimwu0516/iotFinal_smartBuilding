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
    var accessToken: String?
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
    
    func fetchAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        
        let clientId = "11046084-7f421a9b-4f09-47eb"
        let clientSecret = "23bab60a-5e3a-4e0a-992a-bfb5d436fff0"
        let data = "grant_type=client_credentials&client_id=\(clientId)&client_secret=\(clientSecret)".data(using: .utf8)
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "com.example", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(noDataError))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let accessToken = json?["access_token"] as? String {
                    completion(.success(accessToken))
                } else {
                    let parsingError = NSError(domain: "com.example", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to parse access_token"])
                    completion(.failure(parsingError))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchData() {
        guard let accessToken = self.accessToken else {
            fetchAccessToken { result in
                switch result {
                case .success(let token):
                    self.accessToken = token
                    self.fetchData()
                    print("My token is------------------- \(token)")
                case .failure(let error):
                    print("Error fetching access token: \(error.localizedDescription)")
                }
            }
            return
        }
        
        guard let url = URL(string: "https://tdx.transportdata.tw/api/basic/v2/Bus/EstimatedTimeOfArrival/City/Taipei/262?%24top=100&%24format=JSON") else {
            return
        }
        
        var request = URLRequest(url: url)
        
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


