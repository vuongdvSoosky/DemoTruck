//
//  FleetManagementRouter.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 22/11/25.
//

import UIKit

class FleetManagementRouter: Router {
  typealias RouteType = Route
  
  enum Route: String {
    case saveRouterVC
    case historyVC
    case calendar
  }
}

extension FleetManagementRouter {
  func route(to route: Route, parameters: [String: Any]? = nil) {
    guard let context = context() else {
      return
    }
    switch route {
    case .saveRouterVC:
      gotoSaveRoute(context, parameters: parameters)
    case .historyVC:
      goToHistory(context, parameters: parameters)
    case .calendar:
      showPopupCalendar(parameters: parameters)
    }
  }
}

extension FleetManagementRouter {
  private func gotoSaveRoute(_ context: UINavigationController, parameters: [String: Any]? = nil) {
    guard let parameters = parameters,
          let itemRoute = parameters["RouteResponseRealm"] as? RouteResponseRealm else {
      return
    }
    let saveRouteVC = SaveRouteDetailVC()
    saveRouteVC.setViewModel(SaveRouteDetailVM(with: itemRoute))
    context.pushViewController(saveRouteVC, animated: true)
  }
  
  private func goToHistory(_ context: UINavigationController, parameters: [String: Any]? = nil) {
    guard let parameters = parameters,
          let itemRoute = parameters["HistoryResponseRealm"] as? RouteResponseRealm else {
      return
    }
    let saveRouteVC = HistoryDetailVC()
    saveRouteVC.setViewModel(HistoryDetailVM(with: itemRoute))
    context.pushViewController(saveRouteVC, animated: true)
  }
  
  private func showPopupCalendar(parameters: [String: Any]? = nil) {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    
    guard let parameters = parameters,
          let handler = parameters["handlerDate"] as? RangeDateHandler,
          let date = parameters["date"] as? (Date, Date) else {
      return
    }
    
    guard let context = context() else {
      return
    }
    
    let popup = RangeCalendarView()
    popup.setRangeDate(date.0, endDate: date.1)
    popup.handlerDateRange = handler
    popup.setStateSelectionMode(with: .range)
    popup.showSlideView(view: topVC.view)
  }
}
