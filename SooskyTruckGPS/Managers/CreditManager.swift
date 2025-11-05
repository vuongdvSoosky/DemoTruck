//
//  CreditManager.swift
//  SooskyTractorGPS
//
//  Created by VuongDv on 9/9/25.
//

import Combine

class CreditManager {
  static let shared = CreditManager()
  private var creditType: CreditType = .go
  
  @Published var goTurn: Int = 0
  @Published var sessionTurn: Int = 0
  
  private init() {}
}

extension CreditManager {
  func fetchNumOfTurn() {
//    goTurn = UserDefaultsManager.shared.get(of: Int.self, key: .lockGo)
//    sessionTurn = UserDefaultsManager.shared.get(of: Int.self, key: .lockSession)
  }
}

extension CreditManager {
  func createCredit(for type: CreditType) {
//    switch type {
//    case .go:
//      goTurn += 1
//      UserDefaultsManager.shared.set(goTurn, key: .lockGo)
//   
//    case .session:
//      sessionTurn += 1
//      UserDefaultsManager.shared.set(sessionTurn, key: .lockSession)
//    }
  }
  
  // MARK: - Check limit
  func isCreditExceeded(for type: CreditType) -> Bool {
    switch type {
    case .go:
      return goTurn > 7
    case .session:
      return sessionTurn > 5
    }
  }
}
