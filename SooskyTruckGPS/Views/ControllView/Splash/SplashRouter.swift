//
//  SplashRouter.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 4/12/25.
//

import UIKit

class SplashRouter: Router {
  typealias RouteType = Route
  
  enum Route: String {
    case onboard
  }
}

extension SplashRouter {
  func route(to route: Route, parameters: [String: Any]? = nil) {
    guard let context = context() else {
      return
    }
    switch route {
    case .onboard:
      if UserDefaultsManager.shared.get(of: Bool.self, key: .showOnboard) {
        context.remake(maxLength: 0, to: TabbarVC())
      } else {
        context.remake(maxLength: 0, to: Onboard1VC())
      }
    }
  }
}
