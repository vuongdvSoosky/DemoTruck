//
//  Place.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 5/11/25.
//

import CoreLocation

struct PlaceGroup {
  var nameRouter: String
  var places: [Place]
}

struct Place: Equatable {
  var id: String?
  var address: String
  var fullAddres: String
  var coordinate: CLLocationCoordinate2D
  var date = Date()
  var state: Bool?
  var type: String?
  
  static func == (lhs: Place, rhs: Place) -> Bool {
    let epsilon = 1e-6
    return abs(lhs.coordinate.latitude - rhs.coordinate.latitude) < epsilon &&
    abs(lhs.coordinate.longitude - rhs.coordinate.longitude) < epsilon
  }
}
