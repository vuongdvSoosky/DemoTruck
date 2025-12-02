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
    case showAdsTracking
    case showReward
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
    case .showAdsTracking:
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
        guard let self else {
          return
        }
        showAdsTracking(parameters)
      }
    case .showReward:
      showPoupReward(context, parameters: parameters)
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
  
  private func showAdsTracking(_ parameters: [String: Any]? = nil) {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    
    guard let parameters = parameters ,
    let handler = parameters["Handler"] as? Handler else {
      return
    }
    
    let view = AdsTrackingView()
    view.handlerAction = handler
    view.showView(view: topVC.view)
  }
  
  private func showPoupReward(_ context: UINavigationController, parameters: [String: Any]? = nil) {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    
    guard let parameters = parameters,
          let didEarnReward = parameters["didEarnReward"] as? Handler else {
      return
    }
    
    
    let popup = RewardView()
    popup.handlerActionGetPremium = {[weak self] in
      guard let self else {
        return
      }
      switch AppManager.shared.displaySub {
      case 0:
        context.push(to: SubAVC(), animated: true)
        popup.removeFromSuperview()
      case 1:
        context.push(to: SubB1VC(), animated: true)
        popup.removeFromSuperview()
      case 2:
        context.push(to: SubB2VC(), animated: true)
        popup.removeFromSuperview()
        popup.removeFromSuperview()
      default:
        break
      }
    }
    
    popup.handlerActionWatchAds = {[weak self] in
      guard let self else {
        return
      }
      showReward(with: SampleAdUnitID.adFormatRewardedID1,
                 didReward: {[weak self] bool in
        guard let self else {
          return
        }
        if bool {
          popup.removeFromSuperview()
          didEarnReward()
        } else {
          popup.removeFromSuperview()
          didEarnReward()
        }
      })
    }
    popup.showView(view: topVC.view)
  }
  
  private func showReward(with idAds: String , didReward: @escaping (Bool) -> Void) {
    AdMobManager.shared.showRewarded(unitId: AdUnitID(rawValue: idAds), completion: didReward)
  }
}
