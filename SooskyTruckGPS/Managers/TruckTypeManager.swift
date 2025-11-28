//
//  TruckTypeManager.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 28/11/25.
//

import Combine

class TruckTypeManager {
  static let shared = TruckTypeManager()
  
  private init() {}
  
  @Published private(set) var truckTypes: TruckType?
}

extension TruckTypeManager {
  func setType(_ type: TruckType) {
    self.truckTypes = type
  }
}
