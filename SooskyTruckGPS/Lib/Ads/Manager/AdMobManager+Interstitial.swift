//
//  AdMobManager+Interstitial.swift
//  MobileAds
//
//  Created by Quang Ly Hoang on 22/02/2022.
//

import Foundation
import GoogleMobileAds
//import FirebaseAnalytics

// MARK: - GADInterstitial
extension AdMobManager: FullScreenContentDelegate {
  
  /// khởi tạo id ads trước khi show
  public func createAdInterstitialIfNeed(unitId: AdUnitID, completion: BoolBlockAds? = nil) {
    if self.getAdInterstitial(unitId: unitId) != nil {
      completion?(true)
      return
    }
    
    let request = Request()
    InterstitialAd.load(with: unitId.rawValue,
                           request: request,
                           completionHandler: { [weak self] ad, error in
      guard let self = self else { return }
      if let error = error {
        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        AdResumeManager.shared.isShowingAd = false
        self.removeAd(unitId: unitId.rawValue)
        self.blockFullScreenAdFaild?(unitId.rawValue)
        self.blockCompletionHandeler?(false)
        completion?(false)
        return
      }
      
      guard let ad = ad else {
        AdResumeManager.shared.isShowingAd = false
        self.removeAd(unitId: unitId.rawValue)
        self.blockFullScreenAdFaild?(unitId.rawValue)
        self.blockCompletionHandeler?(false)
        completion?(false)
        return
      }
      ad.fullScreenContentDelegate = self
      
      self.listAd.setObject(ad, forKey: unitId.rawValue as NSCopying)
      self.blockLoadFullScreenAdSuccess?(unitId.rawValue)
      completion?(true)
    })
  }
  
  func getAdInterstitial(unitId: AdUnitID) -> InterstitialAd? {
    if let interstitial = listAd.object(forKey: unitId.rawValue) as? InterstitialAd {
      return interstitial
    }
    return nil
  }
  
  /// show ads Interstitial
  func presentAdInterstitial(unitId: AdUnitID) {
    self.createAdInterstitialIfNeed(unitId: unitId)
    let interstitial = self.getAdInterstitial(unitId: unitId)
    if let topVC =  UIApplication.topViewController() {
      interstitial?.present(from: topVC)
      AdResumeManager.shared.isShowingAd = true // kiểm tra nếu show inter thì ko show resume
    }
  }
  
  public func countAdsToShowIntertitial(
    startAds : Int, loopAds : Int, countFullAds : inout Int,
    unitId: AdUnitID, isSplash: Bool = false, blockWillDismiss: VoidBlockAds? = nil, blockDidDismiss: VoidBlockAds? = nil
  ) {
    if !AppManager.shared.showAds {
      blockDidDismiss?()
      return
    }
    
    if !Reachability.isConnectedToNetwork() {
      blockDidDismiss?()
      return
    }
    
    if AppManager.shared.hasSub {
      blockDidDismiss?()
      return
    }
    
    countFullAds += 1
    var isShowAds = false
    if countFullAds < startAds {
      isShowAds = false
    } else if countFullAds == startAds {
      isShowAds = true
    } else {
      if (countFullAds - startAds) % loopAds == 0 {
        isShowAds = true
      }  else {
        isShowAds = false
      }
    }
    
    if isShowAds {
      showIntertitial(unitId: unitId, isSplash: isSplash, blockWillDismiss: blockWillDismiss, blockDidDismiss: blockDidDismiss)
    } else {
      blockDidDismiss?()
    }
  }
  
  public func showIntertitial(unitId: AdUnitID, isSplash: Bool = false, blockWillDismiss: VoidBlockAds? = nil, blockDidDismiss: VoidBlockAds? = nil) {
    if !AppManager.shared.showAds {
      blockDidDismiss?()
      return
    }
    
    if AppManager.shared.hasSub {
      blockDidDismiss?()
      return
    }
    
    if isSplash {
      AdResumeManager.shared.isShowingAd = true // kiểm tra nếu show inter thì ko show resume
      createAdInterstitialIfNeed(unitId: unitId) { [weak self] result in
        if result {
          self?.isSplash = true
          self?.showIntertitial(unitId: unitId, blockWillDismiss: blockWillDismiss, blockDidDismiss: blockDidDismiss)
        } else {
          blockWillDismiss?()
          blockDidDismiss?()
        }
      }
      return
    }
    
    if AdMobManager.shared.getAdInterstitial(unitId: unitId) != nil {
      AdResumeManager.shared.isShowingAd = true // kiểm tra nếu show inter thì ko show resume
      var rootVC = UIApplication.topViewController()
      if rootVC?.navigationController != nil {
        rootVC = rootVC?.navigationController
        if rootVC?.tabBarController != nil {
          rootVC = rootVC?.tabBarController
        }
      }
      guard let rootVC = rootVC else { return }
      
      let loadingVC = AdFullScreenLoadingVC.createViewController(unitId: unitId, adType: .interstitial(id: unitId))
      rootVC.addChild(loadingVC)
      rootVC.view.addSubview(loadingVC.view)
      loadingVC.blockDidDismiss = { [weak loadingVC] in
        loadingVC?.willMove(toParent: nil)
        loadingVC?.view.removeFromSuperview()
        loadingVC?.removeFromParent()
        self.isSplash = false
        blockDidDismiss?()
      }
      loadingVC.blockWillDismiss = blockWillDismiss
      loadingVC.view.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }
    } else {
      createAdInterstitialIfNeed(unitId: unitId)
      blockWillDismiss?()
      blockDidDismiss?()
    }
  }
  
  // MARK: - GADInterstitialDelegate
  
  //  public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
  //    self.blockFullScreenAdWillDismiss?()
  //  }
  
  /// Tells the delegate that the ad failed to present full screen content.
  public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    print("Ad did fail to present full screen content.")
    UIApplication.shared.isStatusBarHidden = false
    self.blockFullScreenAdFaild?("")
    AdResumeManager.shared.isShowingAd = false
  }
  
  /// Tells the delegate that the ad presented full screen content.
  public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("Ad did present full screen content.")
    blockCompletionHandeler?(true)
    blockRewardAdWillPresent?()
  }
  
  /// Tells the delegate that the ad dismissed full screen content.
  public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    UIApplication.shared.isStatusBarHidden = false
    blockFullScreenAdDidDismiss?()
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      AdResumeManager.shared.isShowingAd = false
    }
    print("Ad did dismiss full screen content.")
  }
  
  public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
    blockFullScreenAdClick?()
    if let ad = ad as? InterstitialAd {
      logEvenClick(id: ad.adUnitID)
    } else if let ad = ad as? RewardedAd {
      logEvenClick(id: ad.adUnitID)
    }
  }
}
