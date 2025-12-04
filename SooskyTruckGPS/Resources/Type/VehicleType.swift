//
//  VehicleType.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 4/12/25.
//

enum VehicleType: CaseIterable {
  case semiTruck
  case heavyBox
  case largeMotorhome
  case cargoVan
  case smallBox
  case pickupTruck
  case campervan
  
  var title: String {
    switch self {
    case .semiTruck:
      return "Semi-Truck (Tractor & Trailer)"
    case .heavyBox:
      return "Heavy Box Truck (26 ft+)"
    case .largeMotorhome:
      return "Large Motorhome (RV Class A)"
    case .cargoVan:
      return "Cargo Van"
    case .smallBox:
      return "Small Box Truck (12–16 ft)"
    case .pickupTruck:
      return "Pickup Truck"
    case .campervan:
      return "Campervan (RV Class B)"
    }
  }
}
