//
//  GoingRouter.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 18/11/25.
//

import UIKit

class GoingRouter: Router {
  typealias RouteType = Route
  
  enum Route: String {
    case arrievedView
  }
}

extension GoingRouter {
  func route(to route: Route, parameters: [String: Any]? = nil) {
    guard let context = context() else {
      return
    }
    switch route {
    case .arrievedView:
      showArrivedView(parameters: parameters)
    }
  }
}

extension GoingRouter {
  private func showArrivedView(parameters: [String: Any]? = nil) {
    guard let parameters = parameters,
    let itemPlace = parameters["Place"] as? Place    else {
      return
    }
    
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    
    let arrivedView = ArrivedView()
    arrivedView.bindingData(place: itemPlace)
    arrivedView.showSlideView(view: topVC.view)
  }
}
