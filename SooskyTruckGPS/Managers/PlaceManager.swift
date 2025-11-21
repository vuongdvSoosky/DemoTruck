//
//  ListLocationManager.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 6/11/25.
//

import Combine
import MapKit

class PlaceManager {
  static let shared = PlaceManager()
  
  @Published var placeGroup: PlaceGroup = .init(nameRouter: "", places: [])
  @Published var placesRouter: RouteResponse?
  
  private init() {}
}

extension PlaceManager {
  func addLocationToArray(_ place: Place) {
    if !self.placeGroup.places.contains(place) {
      self.placeGroup.places.append(place)
    } else {
      self.placeGroup.places.removeAll(where: {$0.address == place.address})
    }
  }
  
  func isExistLocation(_ place: Place) -> Bool {
    return self.placeGroup.places.contains(place)
  }
  
  func removePlace(_ place: Place) {
    self.placeGroup.places.removeAll(where: {$0.address == place.address})
  }
  
  func changStatePlace(with place: Place, isSuccess: Bool) {
    if let index = self.placeGroup.places.firstIndex(where: { $0.address == place.address }) {
      if self.placeGroup.places[index].state == isSuccess {
        self.placeGroup.places[index].state = nil
      } else {
        self.placeGroup.places[index].state = isSuccess
      }
    }
  }
  
  func getRouterPlace(_ placesRouter: RouteResponse) {
    self.placesRouter = placesRouter
  }
}
