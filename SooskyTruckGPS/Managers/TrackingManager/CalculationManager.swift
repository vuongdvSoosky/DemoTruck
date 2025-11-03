//
//  CalculationManager.swift
//  SooskyTractorGPS
//
//  Created by VuongDv on 12/8/25.
//

import Foundation
import CoreLocation
import UIKit

class CalculationManager {
  
  // MARK: - Constants
  static let shared = CalculationManager()
  
  private init() {}
  
  func convertMetersToMiles(_ meters: Double) -> Double {
    return meters / 1609.344
  }
  
  /// Tính khoảng cách giữa hai điểm tọa độ
  func calculateDistance(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
    let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
    let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
    return startLocation.distance(from: endLocation)
  }
  
  /// Tính khoảng cách và format thành string
  func calculateDistanceString(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, inFeet: Bool = true) -> String {
    let distance = calculateDistance(from: start, to: end)
    
    if inFeet {
      let distanceInFeet = convertMetersToMiles(distance)
      return String(format: "%.2f ft", distanceInFeet)
    } else {
      return String(format: "%.2f m", distance)
    }
  }
}
