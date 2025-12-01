//
//  CreditManager.swift
//  SooskyTractorGPS
//
//  Created by VuongDv on 9/9/25.
//

import Combine

class CreditManager {
  static let shared = CreditManager()
  private var creditType: CreditType = .finish
  
  @Published var goTurn: Int = 0
  
  private init() {}
}

extension CreditManager {
  func fetchNumOfTurn() {
    goTurn = UserDefaultsManager.shared.get(of: Int.self, key: .lockFeature)
  }
}

extension CreditManager {
  func createCredit(for type: CreditType) {
    switch type {
    case .finish:
      goTurn += 1
      UserDefaultsManager.shared.set(goTurn, key: .lockFeature)
    }
  }
  
  // MARK: - Check limit
  func isCreditExceeded(for type: CreditType) -> Bool {
    switch type {
    case .finish:
      return goTurn > 100
    }
  }
}
