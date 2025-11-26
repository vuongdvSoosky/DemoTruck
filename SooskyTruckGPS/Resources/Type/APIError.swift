//
//  APIError.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 26/11/25.
//

enum APIError: Error {
    case invalidURL
    case serverError(code: Int, message: String)
    case decodingError
    case unknown
}
