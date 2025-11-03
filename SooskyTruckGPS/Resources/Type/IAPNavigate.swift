//
//  Navigate.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 10/8/25.
//


import Foundation
import Combine

enum IAPNavigateType {
  case onboard
  case other
}

class IAPNavigate {
  
  @Published var navigate: IAPNavigateType = .other
  
}

extension IAPNavigate {
  func setNavigate(with type: IAPNavigateType) {
    self.navigate = type
  }
}
