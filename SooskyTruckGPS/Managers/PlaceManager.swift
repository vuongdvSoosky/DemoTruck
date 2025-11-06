//
//  ListLocationManager.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 6/11/25.
//

import Combine

class PlaceManager {
  static let shared = PlaceManager()
  
  @Published var places: [Place] = []
  
  private init() {}
}

extension PlaceManager {
  func addLocationToArray(_ place: Place) {
    if !self.places.contains(place) {
      self.places.append(place)
    } else {
      self.places.removeAll(where: {$0.address == place.address})
    }
  }
  
  func isExistLocation(_ place: Place) -> Bool {
    return self.places.contains(place)
  }
  
  func removePlace(_ place: Place) {
    self.places.removeAll(where: {$0.address == place.address})
  }
}
