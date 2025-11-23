//
//  EditGoingRouter.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 23/11/25.
//

import UIKit

class EditGoingRouter: Router {
  typealias RouteType = Route
  
  enum Route: String {
    case viewlist
    case loadingVC
    case go
    case back
  }
}

extension EditGoingRouter {
  func route(to route: Route, parameters: [String: Any]? = nil) {
    guard let context = context() else {
      return
    }
    switch route {
    case .viewlist:
      showListLocation(parameters)
    case .loadingVC:
      let loadingVC = LoadingVC()
      // Pass filtered places nếu có trong parameters
      if let parameters = parameters,
         let filteredPlaces = parameters["filteredPlaces"] as? [Place] {
        loadingVC.filteredPlaces = filteredPlaces
      }
      context.push(to: loadingVC, animated: true)
    case .go:
      let goingVC = GoingVC()
      context.push(to: goingVC, animated: true)
    case .back:
      context.pop(animated: true)
    }
  }
}

extension EditGoingRouter {
  private func showListLocation(_ parameters: [String: Any]? = nil) {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    guard let parameters = parameters,
          let handler = parameters["Handler"] as? Handler else {
      return
    }
    
    let listView = ListDetailLocationView()
    listView.handlerActionDeleted = handler
    
    listView.showSlideView(view: topVC.view)
  }
}
