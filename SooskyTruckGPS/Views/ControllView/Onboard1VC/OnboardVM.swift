//
//  OnboardVm.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 1/12/25.
//

import Combine

class OnboardVM: BaseViewModel {
  enum Action {
    case next
    case iap
    case survey
    case onb2
  }
  
  let action = PassthroughSubject<Action, Never>()
  private let router = OnboardRouter()

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

extension OnboardVM {
  private func progressAction(_ action: Action) {
    switch action {
    case .next:
      router.route(to: .next)
    case .iap:
      router.route(to: .iap)
    case .survey:
      router.route(to: .survey)
    case .onb2:
      router.route(to: .onb2)
    }
  }
}
