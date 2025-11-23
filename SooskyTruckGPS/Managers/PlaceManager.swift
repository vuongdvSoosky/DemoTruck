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
      var newPlace = place
      // Nếu không phải service type (Gas Station, Bank, etc.) thì set type = "Location"
      // Giữ nguyên type nếu là service type
      let serviceTypes = ["Gas Station", "Bank", "Car Wash", "Pharmacy", "Fast Food"]
      if let placeType = newPlace.type, serviceTypes.contains(placeType) {
        // Giữ nguyên type của service
      } else {
        // Location bình thường hoặc type không hợp lệ → set "Location"
      newPlace.type = "Location"
      }
      self.placeGroup.places.append(newPlace)
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
  
  func setPlaceGroup(_ places: [Place]) {
    self.placeGroup.places = places
  }
}
