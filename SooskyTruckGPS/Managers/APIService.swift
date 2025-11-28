//
//  APIService.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 20/11/25.
//

import Foundation

final class APIService {
  static var shared = APIService()

  func fetchData(with point: [[Double]]) async throws -> RouteResponse {
    guard let url = URL(string: "https://truck-gps.loca.lt/calculate-route") else {
      throw APIError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = [
      "profile": TruckTypeManager.shared.truckTypes?.rawValue ?? "truck",
      "points": point,
      "points_encoded" : false,
      "snap_preventions": ["bridge"],
      "details": ["street_name", "time", "distance"]
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.unknown
    }

    if httpResponse.statusCode != 200 {
        if let errorResponse = try? JSONDecoder().decode(RouterError.self, from: data) {
            throw APIError.serverError(code: httpResponse.statusCode,
                                       message: errorResponse.message ?? "Unknown server error")
        }
        throw APIError.serverError(code: httpResponse.statusCode, message: "No message")
    }

    do {
        return try JSONDecoder().decode(RouteResponse.self, from: data)
    } catch {
        throw APIError.decodingError
    }
  }
}
