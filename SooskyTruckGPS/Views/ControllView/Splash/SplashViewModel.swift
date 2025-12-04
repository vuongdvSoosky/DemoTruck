//
//  SplashViewModel.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 4/12/25.
//

import Combine
import Foundation

class SplashViewModel: BaseViewModel {
  
  enum Action {
    case end
  }
  
  let action = PassthroughSubject<Action, Never>()
  private let router = SplashRouter()
  
  override init() {
    super.init()
    action.sink(receiveValue: {[weak self] action in
      guard let self else { return }
      progressAction(action)
    }).store(in: &subscriptions)
  }
}
  

extension SplashViewModel {
  private func progressAction(_ action: Action) {
    switch action {
    case .end:
      router.route(to: .onboard)
    }
  }
}
