//
//  HistoryDetailVM.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 23/11/25.
//

import Combine
import MapKit

class HistoryDetailVM: BaseViewModel {
  
  enum Action {
    case viewList
    case back
  }
  
  let action = PassthroughSubject<Action, Never>()
  var item = CurrentValueSubject<RouteResponseRealm?, Never>(nil)
  var searchCompleter = MKLocalSearchCompleter()
  var searchSuggestions: [MKLocalSearchCompletion] = []
  let index = CurrentValueSubject<Int?, Never>(nil)
  let actionEditLocation = PassthroughSubject<Void, Never>()
  var isEditLocation: Bool = false
  
  private let router = HistoryDetailRouter()
  
  init(with item: RouteResponseRealm) {
    self.item.value = item
    PlaceManager.shared.setPlaceGroup(item.places.toPlaces(), nameGroup: item.nameRouter ?? "My Route")
    PlaceManager.shared.getRouterPlace(item.toModel())
    super.init()
    action.sink(receiveValue: {[weak self] action in
      guard let self else {
        return
      }
      progressAction(action)
    }).store(in: &subscriptions)
  }
}

extension HistoryDetailVM {
  private func progressAction(_ action: Action) {
    switch action {
    case .viewList:
      let handler: Handler = {[weak self] in
        guard let self else {
          return
        }
        actionEditLocation.send(())
        isEditLocation = true
      }
      router.route(to: .viewlist, parameters: ["Handler": handler,
                                               "RouteResponseRealm": item.value as Any])
    case .back:
      router.route(to: .back)
    }
  }
}
