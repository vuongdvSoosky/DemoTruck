//
//  HistoryDetailRouter.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 23/11/25.
//

import UIKit

class HistoryDetailRouter: Router {
  typealias RouteType = Route
  
  enum Route: String {
    case viewlist
    case loadingVC
    case go
    case back
    case iap
  }
}

extension HistoryDetailRouter {
  func route(to route: Route, parameters: [String: Any]? = nil) {
    guard let context = context() else {
      return
    }
    switch route {
    case .viewlist:
      showListLocation(parameters)
    case .loadingVC:
      let loadingVC = LoadingVC()
      context.push(to: loadingVC, animated: true)
    case .go:
      let goingVC = GoingVC()
      context.push(to: goingVC, animated: true)
    case .back:
      context.pop(animated: true)
    case .iap:
      switch AppManager.shared.displaySub {
      case 0:
        context.push(to: SubAVC(), animated: true)
      default:
        context.push(to: SubB0VC(), animated: true)
      }
    }
  }
}

extension HistoryDetailRouter {
  private func showListLocation(_ parameters: [String: Any]? = nil) {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    guard let parameters = parameters,
          let handler = parameters["Handler"] as? Handler,
          let itemRoute = parameters["RouteResponseRealm"] as? RouteResponseRealm else {
      return
    }
    
    let listView = ListDetailLocationView()
    listView.handlerActionDeleted = handler
    listView.setItem(itemRoute)
    listView.showSlideView(view: topVC.view)
  }
}
