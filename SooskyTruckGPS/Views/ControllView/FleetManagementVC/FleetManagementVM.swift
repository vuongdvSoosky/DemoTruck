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
    case getSaveRouteItem(index: Int)
    case getHistoryItem(index: Int)
    case removeItemHistory(item: RouteResponseRealm)
  }
  
  let action = PassthroughSubject<Action, Never>()
  let saveRouteItems = CurrentValueSubject<[RouteResponseRealm]?, Never>(nil)
  let itemHistory = CurrentValueSubject<[RouteResponseRealm]?, Never>(nil)
  let indexForMainScrollView = CurrentValueSubject<Int, Never>(0)
  
  private let router = FleetManagementRouter()
  
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
    
    self.saveRouteItems.value = itemNormal.reversed()
    self.itemHistory.value = itemHistory.reversed()
    
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
    case .getSaveRouteItem(index: let index):
      router.route(to: .saveRouterVC, parameters: ["RouteResponseRealm": saveRouteItems.value?[index] as Any])
    case .getHistoryItem(index: let index):
      router.route(to: .historyVC, parameters: ["HistoryResponseRealm": itemHistory.value?[index] as Any])
    case .removeItemHistory(item: let item):
      guard let object = RealmService.shared.getById(ofType: RouteResponseRealm.self, id: item.id) else {
        return
      }
      
      RealmService.shared.delete(object)
      fetchData()
    }
  }
}
