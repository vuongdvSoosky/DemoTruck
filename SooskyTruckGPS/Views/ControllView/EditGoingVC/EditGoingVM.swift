//
//  EditGoingVM.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 23/11/25.
//

import Combine
import MapKit

class EditGoingVM: BaseViewModel {
  enum Action {
    case viewList
    case caculatorRoute
    case getIndex(int: Int)
    case actionEditLocation
    case caculateRoute
    case go
    case back
  }
  
  let action = PassthroughSubject<Action, Never>()
  var item = CurrentValueSubject<RouteResponseRealm?, Never>(nil)
  var searchCompleter = MKLocalSearchCompleter()
  var searchSuggestions: [MKLocalSearchCompletion] = []
  let index = CurrentValueSubject<Int?, Never>(nil)
  let actionEditLocation = PassthroughSubject<Void, Never>()
  var isEditLocation: Bool = false
  
  private let router = EditGoingRouter()
  
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

extension EditGoingVM {
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
      router.route(to: .viewlist, parameters: ["Handler": handler])
    case .caculatorRoute:
      router.route(to: .loadingVC)
    case .getIndex(int: let int):
      self.index.value = int
    case .actionEditLocation:
      actionEditLocation.send(())
      isEditLocation = true
    case .caculateRoute:
      
      
      router.route(to: .loadingVC)
    case .go:
      router.route(to: .go)
    case .back:
      router.route(to: .back)
    }
  }
}
