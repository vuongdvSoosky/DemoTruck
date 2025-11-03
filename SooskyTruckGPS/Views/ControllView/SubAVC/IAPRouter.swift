//
//  IAPRouter.swift
//  SooskyBabyTracker
//
//  Created by VuongDv on 8/8/25.
//

import UIKit

class IAPRouter: Router {
  typealias RouteType = Route
  
  enum Route: String {
    case back
    case tabbar
  }
}

extension IAPRouter {
  func route(to route: Route, parameters: [String: Any]? = nil) {
    guard let context = context() else {
      return
    }
    switch route {
    case .back:
      context.pop(animated: true)
    case .tabbar:
      context.push(to: TabbarVC(), animated: true)
    }
  }
}
