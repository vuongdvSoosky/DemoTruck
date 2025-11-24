//
//  LoadingRouter.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 13/11/25.
//

import UIKit

class LoadingRouter: Router {
  typealias RouteType = Route
  
  enum Route: String {
    case back
    case iap
    case beforGoing
    case showError
  }
}

extension LoadingRouter {
  func route(to route: Route, parameters: [String: Any]? = nil) {
    guard let context = context() else {
      return
    }
    switch route {
    case .back:
      context.pop(animated: true)
    case .beforGoing:
      DispatchQueue.main.async { [weak self] in
        guard let self else {
          return
        }
        pushBefoGoingVC(context)
      }
    case .iap:
      switch AppManager.shared.displaySub {
      case 0:
        context.push(to: SubAVC(), animated: true)
      case 1:
        context.push(to: SubB1VC(), animated: true)
      case 2:
        context.push(to: SubB2VC(), animated: true)
      case 3:
        context.push(to: SubB3VC(), animated: true)
      default:
        break
      }
    case .showError:
      showErrorView(context)
    }
  }
}

extension LoadingRouter {
  private func pushBefoGoingVC(_ context: UINavigationController) {
    let beforGoing = BeforeGoingVC()
    context.push(to: beforGoing, animated: true)
    context.removeViewController(LoadingVC.self)
  }
  
  private func showErrorView(_ context: UINavigationController) {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    
    let view = ServerErrorView()
    view.handlerActionOkay = {[weak self] in
      guard let self else {
        return
      }
      context.pop(animated: true)
      view.dismissSlideView()
    }
    
    view.showSlideView(view: topVC.view)
  }
}
