//
//  GoingViewModel.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 17/11/25.
//

import Foundation
import Combine

class GoingViewVM: BaseViewModel {
  enum Action {
    case getIndex(int: Int)
    case getTrackingState(state: TrackingState)
  }
  
  let action = PassthroughSubject<Action, Never>()
  let index = CurrentValueSubject<Int?, Never>(nil)
  var trackingState: TrackingState = .beginTracking
  
  override init() {
    super.init()
    
    action.sink(receiveValue: {[weak self] action in
      guard let self else {
        return
      }
      
      progressAction(action)
    }).store(in: &subscriptions)
  }
}


extension GoingViewVM {
  private func progressAction(_ action: Action) {
    switch action {
    case .getIndex(let index):
      self.index.send(index)
    case .getTrackingState(state: let state):
      trackingState = state
    }
  }
}

