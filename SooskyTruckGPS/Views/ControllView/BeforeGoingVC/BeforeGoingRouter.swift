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
      // Tìm TabbarVC cũ trong navigation stack
      if let existingTabbarVC = context.getController(ofClass: TabbarVC.self) {
        // Nếu tìm thấy TabbarVC cũ, pop về đó
        existingTabbarVC.setSelectIndex(navigate: .diary)
        existingTabbarVC.reloadFleetManagementTabSaveVC()
        context.popToViewController(existingTabbarVC, animated: true)
      } else {
        // Nếu không tìm thấy, tạo mới như cũ
        let tabbarVC = TabbarVC()
        tabbarVC.setSelectIndex(navigate: .diary)
        tabbarVC.reloadFleetManagementTabSaveVC()
        context.push(to: tabbarVC, animated: true)
      }
    }
  }
}
