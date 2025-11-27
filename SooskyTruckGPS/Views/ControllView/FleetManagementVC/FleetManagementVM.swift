//
//  FleetManagementVM.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 20/11/25.
//

import Combine
import Foundation

class FleetManagementVM: BaseViewModel {
  enum Action {
    case chooseIem
    case getIndexToScroll(index: Int)
    case getSaveRouteItem(index: Int)
    case getHistoryItem(index: Int)
    case removeItemHistory(item: RouteResponseRealm)
    case calendar
    case filterData(selectedDate: (Date, Date))
  }
  
  let action = PassthroughSubject<Action, Never>()
  let saveRouteItems = CurrentValueSubject<[RouteResponseRealm]?, Never>(nil)
  let itemHistory = CurrentValueSubject<[RouteResponseRealm]?, Never>(nil)
  let indexForMainScrollView = CurrentValueSubject<Int, Never>(0)
  
  let selectedDate = CurrentValueSubject<(Date, Date), Never>((Date(), Date()))
  let startDate = CurrentValueSubject<Date?, Never>(nil)
  let endDate = CurrentValueSubject<Date?, Never>(nil)
  
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
    case .calendar:
      let dateHandler: RangeDateHandler = { startDate, endDate in
        self.selectedDate.value.0 = startDate
        self.selectedDate.value.1 = endDate
        self.startDate.value = startDate
        self.endDate.value = endDate
        
      }
      router.route(to: .calendar, parameters: ["handlerDate": dateHandler as RangeDateHandler,
                                               "date": selectedDate.value])
    case .filterData(selectedDate: let selectedDate):
      filterItems(from: selectedDate.0, to: selectedDate.1)
    }
  }
}

extension FleetManagementVM {
  /// Filter cả saveRouteItems và itemHistory theo ngày
  func filterItems(from start: Date, to end: Date) {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: start)
    let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end
    
    // Lọc saveRouteItems (history == false)
    saveRouteItems.value = RealmService.shared
      .fetchResults(ofType: RouteResponseRealm.self)?
      .filter("history == false AND createDate >= %@ AND createDate <= %@", startOfDay, endOfDay)
      .sorted(byKeyPath: "createDate", ascending: false)
      .map { $0 } ?? []
    
    // Lọc itemHistory (history == true)
    itemHistory.value = RealmService.shared
      .fetchResults(ofType: RouteResponseRealm.self)?
      .filter("history == true AND createDate >= %@ AND createDate <= %@", startOfDay, endOfDay)
      .sorted(byKeyPath: "createDate", ascending: false)
      .map { $0 } ?? []
  }
}
