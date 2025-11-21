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
    case finish
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
    case .finish:
      let tabbarVC = TabbarVC()
      tabbarVC.setSelectIndex(navigate: .diary)
      tabbarVC.reloadFleetManagementVC()
      context.push(to: tabbarVC, animated: true)
    }
  }
}

extension GoingRouter {
  private func showArrivedView(parameters: [String: Any]? = nil) {
    guard let parameters = parameters,
          let itemPlace = parameters["Place"] as? Place else {
      return
    }
    
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    
    let arrivedView = ArrivedView()
    arrivedView.bindingData(Place: itemPlace)
    arrivedView.showSlideView(view: topVC.view)
  }
}
