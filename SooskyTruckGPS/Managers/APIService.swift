//
//  APIService.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 20/11/25.
//

import Foundation

final class APIService {
  static var shared = APIService()
  
  func fetchData(with point: [[Double]]) async -> RouteResponse? {
    guard let url = URL(string: "https://truck-gps.loca.lt/calculate-route") else {
      return nil
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = [
      "profile": "truck",
      "points": point,
      "snap_preventions": [
        "bridge"
      ],
      "details": [
        "street_name",
        "time",
        "distance"
      ]
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      
      if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
        LogManager.show("[HTTP Error] Status code: \(httpResponse.statusCode)")
        if let errorResponse = try? JSONDecoder().decode(RouterError.self, from: data) {
          LogManager.show("[GraphHopper Error] \(errorResponse.message)")
          if let hints = errorResponse.hints {
            for hint in hints {
              LogManager.show("• Hint: \(hint.message)")
            }
          }
        }
        return nil
      }
      
      let decoder = JSONDecoder()
      let result = try decoder.decode(RouteResponse.self, from: data)
      return result
    } catch {
      LogManager.show("[Error] \(error)")
      return nil
    }
  }
}
