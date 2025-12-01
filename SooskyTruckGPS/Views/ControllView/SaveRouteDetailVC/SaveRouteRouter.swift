//
//  SaveRouteRouter.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 23/11/25.
//

import UIKit

class SaveRouteRouter: Router {
  typealias RouteType = Route
  
  enum Route: String {
    case viewlist
    case loadingVC
    case go
    case back
    case lockFeature
  }
}

extension SaveRouteRouter {
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
    case .lockFeature:
      switch AppManager.shared.displaySub {
      case 1:
        let vc = SubB1VC()
        context.push(to: vc, animated: true)
      case 2:
        let vc = SubB2VC()
        context.push(to: vc, animated: true)
      default:
       break
      }
    }
  }
}

extension SaveRouteRouter {
  private func showListLocation(_ parameters: [String: Any]? = nil) {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    guard let parameters = parameters,
          let handler = parameters["Handler"] as? Handler else {
      return
    }
    
    let listView = ListLocationView()
    listView.handlerActionDeleted = handler
    
    listView.showSlideView(view: topVC.view)
  }
}
