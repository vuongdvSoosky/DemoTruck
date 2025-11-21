//
//  ServiceType.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 17/11/25.
//
import UIKit


enum ServiceType: CaseIterable {
  case gas
  case bank
  case carwash
  case pharmacy
  case fastFood
  
  var icon: UIImage {
    switch self {
    case .gas:
      return .icGas
    case .bank:
      return .icBank
    case .carwash:
      return .icCarWash
    case .pharmacy:
      return .icPharmacy
    case .fastFood:
      return .icFastFood
    }
  }
  
  var iconSelected: UIImage {
    switch self {
    case .gas:
      return .icGasSeleted
    case .bank:
      return .icBankSelected
    case .carwash:
      return .icCarWashSelected
    case .pharmacy:
      return .icPharmacySelected
    case .fastFood:
      return .icFastFoodSelected
    }
  }
  
  var title: String {
    switch self {
    case .gas:
      return "Gas Station"
    case .bank:
      return "Bank"
    case .carwash:
      return "Car Wash"
    case .pharmacy:
      return "Pharmacy"
    case .fastFood:
      return "Fast Food"
    }
  }
  
  var name: String {
    switch self {
    case .gas:
      return "gas station"
    case .bank:
      return "bank"
    case .carwash:
      return "car wash"
    case .pharmacy:
      return "pharmacy"
    case .fastFood:
      return "fast food"
    }
  }
}
