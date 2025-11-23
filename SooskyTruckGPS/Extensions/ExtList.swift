//
//  Untitled.swift
//  SooskyHorseTracking
//
//  Created by VuongDv on 17/10/25.
//

import RealmSwift
import MapKit

extension List where Element: PlaceRealm {
  func toPlaces() -> [Place] {
    self.map {
      Place(
        address: $0.address,
        fullAddres: $0.fullAddress,
        coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
        state: $0.state
      )
    }
  }
}
