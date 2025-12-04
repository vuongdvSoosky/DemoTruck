//
//  LagerType.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 4/12/25.
//

enum OwnerType: CaseIterable {
  case truckDriver
  case deliveryDriver
  case rvCamperDriver
  case longHaulDriver
  case fleetOwner
  case justExploring
  case other
  
  var title: String {
    switch self {
    case .truckDriver:
      return "Truck Driver"
    case .deliveryDriver:
      return "Delivery Driver"
    case .rvCamperDriver:
      return "RV / Camper Driver"
    case .longHaulDriver:
      return "Long-Haul Driver"
    case .fleetOwner:
      return "Fleet Owner"
    case .justExploring:
      return "Just Exploring"
    case .other:
      return "Other"
    }
  }
}
