//
//  OnboardRouter.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 1/12/25.
//

import UIKit

class OnboardRouter: Router {
  typealias RouteType = Route
  
  enum Route: String {
    case next
    case rating
    case iap
    case survey
  }
}

extension OnboardRouter {
  func route(to route: Route, parameters: [String: Any]? = nil) {
    guard let context = context() else {
      return
    }
    switch route {
    case .next:
      let ob2VC = Onboard2VC()
      context.push(to: ob2VC, animated: true)
    case .rating:
      let ratingVC = RatingVC()
      context.push(to: ratingVC, animated: true)
    case .iap:
      if AppManager.shared.hasSub {
        context.push(to: TabbarVC(), animated: true)
      } else {
        goToIAPVC(context: context, navi: .onboard)
      }
    case .survey:
      let surveyVC = SurveyVC()
      context.push(to: surveyVC, animated: true)
    }
  }
  
  private func goToIAPVC(context: UINavigationController, navi: IAPNavigateType) {
    switch AppManager.shared.displaySub {
    case 0:
      context.remake(maxLength: 0, to: TabbarVC())
    case 1:
      let vc = SubB1VC()
      vc.setNavi(with: .onboard)
      context.push(to: vc, animated: true)
    case 2:
      let vc = SubB2VC()
      vc.setNavi(with: .onboard)
      context.push(to: vc, animated: true)
    default:
     break
    }
  }
}
