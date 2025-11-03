//
//  Router.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit
import Toast

protocol Router {
  associatedtype RouteType: RawRepresentable where RouteType.RawValue: StringProtocol
  
  func route(to route: RouteType, parameters: [String: Any]?)
}

extension Router {
  func context() -> UINavigationController? {
    return UIApplication.shared.windows.first?.rootViewController as? UINavigationController
  }
}

extension Router {
  func toast(_ mes: String) {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    topVC.view.makeToast(mes)
  }
}
