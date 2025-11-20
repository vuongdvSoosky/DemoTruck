//
//  FleetManagementVM.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 20/11/25.
//

import Combine

class FleetManagementVM: BaseViewModel {
  enum Action {
    case chooseIem
    case getIndexToScroll(index: Int)
  }
  
  let action = PassthroughSubject<Action, Never>()
  let items = CurrentValueSubject<[RouteResponseRealm]?, Never>(nil)
  let itemHistory = CurrentValueSubject<[RouteResponseRealm]?, Never>(nil)
  let indexForMainScrollView = CurrentValueSubject<Int, Never>(0)
  
  override init() {
    super.init()
    
    action.sink(receiveValue: {[weak self] action in
      guard let self else {
        return
      }
      progressAction(action)
    }).store(in: &subscriptions)
    
    fetchData()
  }
  
  func fetchData() {
    let items = RealmService.shared.fetch(ofType: RouteResponseRealm.self)
    let itemHistory = items.filter { $0.history == true }
    let itemNormal = items.filter { $0.history == false }
    
    self.items.value = itemNormal
    self.itemHistory.value = itemHistory
    
    LogManager.show("items", itemNormal.count)
    LogManager.show("itemHistory", itemHistory.count)
  }
}

extension FleetManagementVM {
  private func progressAction(_ action: Action) {
    switch action {
    case .chooseIem:
      break
    case .getIndexToScroll(index: let index):
      indexForMainScrollView.value = index
    }
  }
}
