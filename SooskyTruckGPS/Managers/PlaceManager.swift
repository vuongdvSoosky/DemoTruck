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
  
  @Published var places: [Place] = []
  
  private init() {}
  
  func fakeData() {
    let place1 = Place(address: "410 ATLANTIC AVE, BROOKLYN", fullAddres: "410 ATLANTIC AVE, BROOKLYN",
                       coordinate: CLLocationCoordinate2D(latitude: 40.6865876, longitude: -73.9846596), nameRouter: "MyRoute", state: nil)
    let place2 = Place(address: "430 ATLANTIC AVE, BROOKLYN", fullAddres: "430 ATLANTIC AVE, BROOKLYN",
                       coordinate: CLLocationCoordinate2D(latitude: 40.6864227, longitude: -73.9840005), nameRouter: "MyRoute", state: true)
    let place3 = Place(address: "420 ATLANTIC AVE, BROOKLYN", fullAddres: "420 ATLANTIC AVE, BROOKLYN",
                       coordinate: CLLocationCoordinate2D(latitude: 40.6864693, longitude: -73.9843323), nameRouter: "MyRoute", state: false)
    places.append(place1)
    places.append(place2)
    places.append(place3)
  }
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
  
  func changStatePlace(with place: Place, isSuccess: Bool) {
    if let index = places.firstIndex(where: { $0.address == place.address }) {
      if places[index].state == isSuccess {
        places[index].state = nil
      } else {
        places[index].state = isSuccess
      }
    }
  }
}
