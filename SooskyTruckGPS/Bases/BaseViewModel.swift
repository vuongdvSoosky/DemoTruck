//
//  BaseViewModel.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import Foundation
import Combine

class BaseViewModel {
  var subscriptions = Set<AnyCancellable>()
  
  deinit {
    removeSubs()
  }
  
  func removeSubs() {
    subscriptions.forEach { $0.cancel() }
    subscriptions.removeAll()
  }
}
