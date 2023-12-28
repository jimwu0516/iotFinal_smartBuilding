//
//  MapViewController.swift
//  不要當我們2.0
//
//  Created by Jim Wu on 2023/12/28.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    struct BusData: Codable {
        let BusPosition: BusPosition
    }
    
    struct BusPosition: Codable {
        let PositionLon: Double
        let PositionLat: Double
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData { result in
            switch result {
            case .success(let coordinates):
                
                DispatchQueue.main.async {
                    self.markBusLocations(coordinates)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func markBusLocations(_ coordinates: [CLLocationCoordinate2D]) {
        mapView.addAnnotations(coordinates.map { coordinate in
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            return annotation
        })
        
        if let firstCoordinate = coordinates.first {
            let region = MKCoordinateRegion(center: firstCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func fetchData(completion: @escaping (Result<[CLLocationCoordinate2D], Error>) -> Void) {
        fetchAccessToken { result in
            switch result {
            case .success(let accessToken):
                // Step 2: Make request to bus data API with access token
                let url = URL(string: "https://tdx.transportdata.tw/api/basic/v2/Bus/RealTimeByFrequency/City/Taipei/262?%24top=30&%24format=JSON")!
                var request = URLRequest(url: url)
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
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
                        // Step 3: Parse JSON response
                        let decoder = JSONDecoder()
                        let busData = try decoder.decode([BusData].self, from: data)
                        
                        // Step 4: Extract PositionLon and PositionLat values
                        let coordinates = busData.map { CLLocationCoordinate2D(latitude: $0.BusPosition.PositionLat, longitude: $0.BusPosition.PositionLon) }
                        
                        completion(.success(coordinates))
                    } catch {
                        completion(.failure(error))
                    }
                }
                
                task.resume()
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func fetchAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
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
}


