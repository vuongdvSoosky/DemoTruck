//
//  BeforeGoingRouter.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 20/11/25.
//

import UIKit

class BeforeGoingRouter: Router {
  typealias RouteType = Route
  
  enum Route: String {
    case back
    case go
    case save
  }
}

extension BeforeGoingRouter {
  func route(to route: Route, parameters: [String: Any]? = nil) {
    guard let context = context() else {
      return
    }
    switch route {
    case .back:
      context.pop(animated: true)
    case .go:
      let goingVC = GoingVC()
      context.push(to: goingVC, animated: true)
    case .save:
      let tabberVC = TabbarVC()
      tabberVC.setSelectIndex(navigate: .diary)
      tabberVC.reloadFleetManagementTabSaveVC()
      context.remake(maxLength: 0, to: tabberVC)
    }
  }
}
