//
//  Untitled.swift
//  SooskyHorseTracking
//
//  Created by VuongDv on 17/10/25.
//

import RealmSwift
import MapKit

extension List where Element == LocationModel {
  convenience init(coordinates: [CLLocationCoordinate2D]) {
    self.init()
    append(objectsIn: coordinates.map { LocationModel(latitude: $0.latitude, longitude: $0.longitude) })
  }
  
  func toCoordinates() -> [CLLocationCoordinate2D] {
    map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
  }
}

// Extension for List<LocationGroupModel>
extension List where Element == LocationGroupModel {
  convenience init(nestedCoordinates: [[CLLocationCoordinate2D]]) {
    self.init()
    for coordinateArray in nestedCoordinates {
      let locationGroup = LocationGroupModel(coordinates: coordinateArray)
      append(locationGroup)
    }
  }
  
  func toNestedCoordinates() -> [[CLLocationCoordinate2D]] {
    map { $0.toCoordinates() }
  }
}

extension List {
  var toArray: [Element] {
    return self.map { $0 }
  }
}
