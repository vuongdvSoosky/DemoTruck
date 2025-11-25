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
