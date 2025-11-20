//
//  TruckViewModel.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 6/11/25.
//

import Combine

class TruckViewModel: BaseViewModel {
  enum Action {
    case viewList
    case caculatorRoute
  }
  
  let action = PassthroughSubject<Action, Never>()
  var places: [Place] = []
  private let router = TruckRouter()
  
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

extension TruckViewModel {
  private func progressAction(_ action: Action) {
    switch action {
    case .viewList:
      router.route(to: .viewlist)
    case .caculatorRoute:
      router.route(to: .loadingVC)
    }
  }
}
