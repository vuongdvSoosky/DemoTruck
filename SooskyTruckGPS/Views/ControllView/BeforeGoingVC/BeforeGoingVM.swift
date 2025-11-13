//
//  BeforeGoingVM.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 13/11/25.
//

import Combine

class BeforeGoingVM: BaseViewModel {
  enum Action {
    case back
    case getIndexToScroll(index: Int)
  }
  
  let action = PassthroughSubject<Action, Never>()
  let indexForMainScrollView = CurrentValueSubject<Int, Never>(0)
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

extension BeforeGoingVM {
  private func progressAction(_ action: Action) {
    switch action {
    case .back:
      break
      
    case .getIndexToScroll(let index):
      indexForMainScrollView.value = index
    }
  }
}

extension BeforeGoingVM {
  private func showRewardView(with rpe: Int) {
    
  }
}
