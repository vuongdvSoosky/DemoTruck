//
//  TruckRouter.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 6/11/25.
//

import UIKit

class TruckRouter: Router {
  typealias RouteType = Route
  
  enum Route: String {
    case viewlist
    case loadingVC
    case truckProFile
    case iap
    case lockFeature
  }
}

extension TruckRouter {
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
    case .truckProFile:
      showTruckProfileView(parameters)
    case .iap:
      switch AppManager.shared.displaySub {
      case 0:
        context.push(to: SubAVC(), animated: true)
      default:
        context.push(to: SubB0VC(), animated: true)
      }
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

extension TruckRouter {
  private func showListLocation(_ parameters: [String: Any]? = nil) {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    
    guard let parameters = parameters,
          let handler = parameters["Hander"] as? Handler else {
      return
    }
    
    let listView = ListLocationView()
    listView.handlerActionClose = handler
    listView.showSlideView(view: topVC.view)
  }
  
  private func showTruckProfileView(_ parameters: [String: Any]? = nil) {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    guard let parameters = parameters,
          let handler = parameters["Handler"] as? Handler else {
      return
    }
    
    let listView = TruckProfileView()
    listView.handler = handler
    listView.showSlideView(view: topVC.view)
  }
}
