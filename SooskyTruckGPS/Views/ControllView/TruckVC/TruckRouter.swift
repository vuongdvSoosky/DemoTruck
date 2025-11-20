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
  }
}

extension TruckRouter {
  func route(to route: Route, parameters: [String: Any]? = nil) {
    guard let context = context() else {
      return
    }
    switch route {
    case .viewlist:
      showListLocation()
    case .loadingVC:
      let loadingVC = LoadingVC()
      context.push(to: loadingVC, animated: true)
    }
  }
}

extension TruckRouter {
  private func showListLocation() {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    
    let listView = ListLocationView()
    
    listView.showSlideView(view: topVC.view)
  }
}
