//
//  GoingRouter.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 18/11/25.
//

import UIKit

class GoingRouter: Router {
  typealias RouteType = Route
  var countAdsToShow = 0
  
  enum Route: String {
    case arrievedView
    case finish
    case edit
    case tutorial
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
      showInterAds(didDismiss: {[weak self] in
        guard let self else {
          return
        }
        pushToTabbar(context)
      }, didFaild: {[weak self] in
        guard let self else {
          return
        }
        pushToTabbar(context)
      })
      
      UserDefaultsManager.shared.set(true, key: .showAdsReward)
    case .edit:
      gotoSaveRoute(context, parameters: parameters)
    case .tutorial:
      showTutorialView(parameters)
    }
  }
  
  private func showInterAds(didDismiss: @escaping() -> Void, didFaild: @escaping() -> Void) {
    AdMobManager.shared.countAdsToShowIntertitial(startAds: 1,
                                                  loopAds: 1, countFullAds: &countAdsToShow,
                                                  unitId: AdUnitID(rawValue: SampleAdUnitID.adFormatInterstitialID1),
                                                  isSplash: false,
                                                  blockWillDismiss: nil,
                                                  blockDidDismiss: didDismiss)
    AdMobManager.shared.blockFullScreenAdFaild = { error in
      didFaild()
    }
  }
  
  private func pushToTabbar(_ context: UINavigationController) {
    // Tìm TabbarVC cũ trong navigation stack
    if let existingTabbarVC = context.getController(ofClass: TabbarVC.self) {
      // Nếu tìm thấy TabbarVC cũ, pop về đó
      existingTabbarVC.setSelectIndex(navigate: .diary)
      existingTabbarVC.reloadFleetManagementVC()
      context.popToViewController(existingTabbarVC, animated: true)
      context.removeViewController(GoingVC.self)
    } else {
      // Nếu không tìm thấy, tạo mới như cũ
      let tabbarVC = TabbarVC()
      tabbarVC.setSelectIndex(navigate: .diary)
      tabbarVC.reloadFleetManagementVC()
      context.push(to: tabbarVC, animated: true)
      context.removeViewController(GoingVC.self)
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
    arrivedView.bindingData(place: itemPlace)
    arrivedView.showSlideView(view: topVC.view)
  }
  
  private func gotoSaveRoute(_ context: UINavigationController, parameters: [String: Any]? = nil) {
    let saveRouteVC = EditGoingVC()
    context.pushViewController(saveRouteVC, animated: true)
  }
  
  func showTutorialView(_ parameters: [String: Any]? = nil) {
    guard let parameters = parameters,
          let handler = parameters["Handler"] as? Handler else {
      return
    }
    
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    
    let view = TutorialArriedView()
    view.handlerAction = handler
    view.showSlideView(view: topVC.view)
  }
}
