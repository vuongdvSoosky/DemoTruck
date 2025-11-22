//
//  SaveRouteDetailVM.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 21/11/25.
//

import Combine
import MapKit

class SaveRouteDetailVM: BaseViewModel {
  enum Action {
    case viewList
    case caculatorRoute
  }
  
  let action = PassthroughSubject<Action, Never>()
  var item: RouteResponseRealm?
  var searchCompleter = MKLocalSearchCompleter()
  var searchSuggestions: [MKLocalSearchCompletion] = []
  
  private let router = TruckRouter()
  
  init(with item: RouteResponseRealm) {
    self.item = item
    super.init()
    action.sink(receiveValue: {[weak self] action in
      guard let self else {
        return
      }
      progressAction(action)
    }).store(in: &subscriptions)
  }
}

extension SaveRouteDetailVM {
  private func progressAction(_ action: Action) {
    switch action {
    case .viewList:
      router.route(to: .viewlist)
    case .caculatorRoute:
      router.route(to: .loadingVC)
    }
  }
}
