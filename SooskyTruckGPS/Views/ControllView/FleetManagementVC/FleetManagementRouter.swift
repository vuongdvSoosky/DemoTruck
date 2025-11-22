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
      break
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
}
