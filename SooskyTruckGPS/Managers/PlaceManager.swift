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

  @Published var placeGroup: PlaceGroup = .init(nameRouter: "My Route", places: [])
  @Published var goingPlaceGroup: PlaceGroup = .init(nameRouter: "My Route", places: [])
  @Published var placesRouter: RouteResponse?
  @Published var currentPlace: Place?
  @Published private(set) var placeRouterID: String = ""
  @Published private(set) var isGoing: Bool = false

  private init() {}
}

extension PlaceManager {

  // MARK: - Add Place
  func addLocation(_ place: Place, toGoing: Bool = false) {
    var group = toGoing ? goingPlaceGroup : placeGroup

    if let index = group.places.firstIndex(of: place) {
      group.places.remove(at: index)
    } else {
      var newPlace = place
      normalizeType(&newPlace)
      group.places.append(newPlace)
      currentPlace = newPlace
    }

    if toGoing {
      goingPlaceGroup = group
    } else {
      placeGroup = group
      goingPlaceGroup = placeGroup
    }
  }

  // MARK: - Remove Place
  func remove(_ place: Place) {
    placeGroup.places.removeAll { $0.address == place.address }
    goingPlaceGroup.places.removeAll { $0.address == place.address }
  }

  // MARK: - Check exist
  func exists(_ place: Place) -> Bool {
    return placeGroup.places.contains(place)
  }

  func goingExists(_ place: Place) -> Bool {
    return goingPlaceGroup.places.contains(place)
  }

  // MARK: - Toggle State (nil, true, false)
  func changeState(for place: Place, isSuccess: Bool) {
    if let index = goingPlaceGroup.places.firstIndex(where: { $0.address == place.address }) {
      let current = goingPlaceGroup.places[index].state
      goingPlaceGroup.places[index].state = (current == isSuccess) ? nil : isSuccess
    }
    
    if let index = placeGroup.places.firstIndex(where: { $0.address == place.address }) {
      let current = placeGroup.places[index].state
      placeGroup.places[index].state = (current == isSuccess) ? nil : isSuccess
    }
  }

  // MARK: - Router
//  func updateRoute(_ response: RouteResponse) {
//    self.placesRouter = response
//  }
  func updateRoute(_ response: RouteResponse) {
      // Nếu đã có route rồi → chỉ update lại
      if let existing = placesRouter, existing.id == response.id {
          // cập nhật thông tin
          placesRouter = response
          return
      }
      
      // Nếu chưa có → tạo mới
      placesRouter = response
  }

  func setPlaceGroup(_ places: [Place], name: String) {
    placeGroup = .init(nameRouter: name, places: places)
    goingPlaceGroup = placeGroup
  }

  func renamePlaceGroup(_ name: String) {
    placeGroup.nameRouter = name
    goingPlaceGroup.nameRouter = name
  }
  
  func setPlaceRouterID(_ id: String) {
    placeRouterID = id
  }
  
  func createPlaceRouterID() {
    placeRouterID = UUID().uuidString
  }
  
  func setStateGoing(with state: Bool) {
    self.isGoing = state
  }

  // MARK: - Private
  private func normalizeType(_ place: inout Place) {
    let serviceTypes = ["Gas Station", "Bank", "Car Wash", "Pharmacy", "Fast Food"]
    if !(place.type.map { serviceTypes.contains($0) } ?? false) {
      place.type = "Location"
    }
  }
  
  func syncPlaceGroupFromGoing() {
      placeGroup = goingPlaceGroup
  }
  
  func syncGoingGroupFromPlace() {
    goingPlaceGroup = placeGroup
  }
}
