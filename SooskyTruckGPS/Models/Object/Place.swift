//
//  Place.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 5/11/25.
//

import CoreLocation

struct Place: Equatable {
  let address: String
  let fullAddres: String
  let coordinate: CLLocationCoordinate2D
  
  static func == (lhs: Place, rhs: Place) -> Bool {
    let epsilon = 1e-6
    return abs(lhs.coordinate.latitude - rhs.coordinate.latitude) < epsilon &&
    abs(lhs.coordinate.longitude - rhs.coordinate.longitude) < epsilon
  }
}
