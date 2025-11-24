//
//  TruckViewModel.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 6/11/25.
//

import Combine
import MapKit

class TruckViewModel: BaseViewModel {
  enum Action {
    case viewList
    case caculatorRoute
    case getIndex(int: Int)
    case truckProfile
  }
  
  let action = PassthroughSubject<Action, Never>()
  var Places: [PlaceGroup] = []
  var searchCompleter = MKLocalSearchCompleter()
  var searchSuggestions: [MKLocalSearchCompletion] = []
  let index = CurrentValueSubject<Int?, Never>(nil)
  let actionTutorialTruckProFile = PassthroughSubject<Void, Never>()
  
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
    case .getIndex(int: let int):
      self.index.send(int)
    case .truckProfile:
      let handler: Handler = { [weak self] in
        guard let self else {
          return
        }
        actionTutorialTruckProFile.send(())
      }
      router.route(to: .truckProFile, parameters: ["Handler": handler])
    }
  }
}
