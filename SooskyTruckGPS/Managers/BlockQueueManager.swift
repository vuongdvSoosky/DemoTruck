//
//  BlockQueueManager.swift
//  SooskyTractorGPS
//
//  Created by VuongDV on 24/8/25.
//

import Foundation
 
class BlockQueueManager {
  static let shared = BlockQueueManager()
  
  enum State {
    case startTracking
    case pauseTracking
    case continueTracking
    case endTracking
  }
  
  @Atomic private(set) var state: State = .endTracking
  
  func startFllow() {
    self.state = .startTracking
    CreditManager.shared.createCredit(for: .go)
  }
  
  func pauseFllow() {
    self.state = .pauseTracking
  }
  
  func continueFllow() {
    self.state = .continueTracking
  }
  
  func endFollow() {
    self.state = .endTracking
  }
}
