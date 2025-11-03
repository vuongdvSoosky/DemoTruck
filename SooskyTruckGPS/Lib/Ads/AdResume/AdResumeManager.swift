//
//  AdResumeManager.swift
//  MobileAds
//
//  Created by ANH VU on 21/01/2022.
//

import GoogleMobileAds
import UIKit
import FirebaseAnalytics

protocol AdResumeManagerDelegate: AnyObject {
  func appOpenAdManagerAdDidComplete(_ appOpenAdManager: AdResumeManager)
}

open class AdResumeManager: NSObject {
  var backgroudView = UIView()
  public static let shared = AdResumeManager()
  
  public let timeoutInterval: TimeInterval = 4 * 3600
  public var isLoadingAd = false
  public var isShowingAd = false
  public var isRequestingPermission: Bool = false
  public var resumeAdId: AdUnitID?
  var appOpenAd: AppOpenAd?
  weak var appOpenAdManagerDelegate: AdResumeManagerDelegate?
  var loadTime: Date?
  public var adResumeLoadingString = "Welcome"
  
  private var showVC: UIViewController?
  public var blockadDidDismissFullScreenContent: VoidBlockAds?
  public var blockAdResumeClick                : VoidBlockAds?
  
  public var countTierOpenAds = 0
  
  private func wasLoadTimeLessThanNHoursAgo(timeoutInterval: TimeInterval) -> Bool {
    // Check if ad was loaded more than n hours ago.
    if let loadTime = loadTime {
      return Date().timeIntervalSince(loadTime) < timeoutInterval
    }
    return false
  }
  
  private func isAdAvailable() -> Bool {
    // Check if ad exists and can be shown.
    //    return appOpenAd != nil && wasLoadTimeLessThanNHoursAgo(timeoutInterval: timeoutInterval)
    return appOpenAd != nil
  }
  
  private func appOpenAdManagerAdDidComplete() {
    appOpenAdManagerDelegate?.appOpenAdManagerAdDidComplete(self)
  }
  
  public func loadAd(completion: ((Bool) -> Void)? = nil) {
    if isLoadingAd || isAdAvailable() {
      appOpenAd = nil
      return
    }
    isLoadingAd = true
    print("Open As ==> Count ID: \(self.countTierOpenAds)")
    print("Open Ad ==> Loading OpenAd ID:", self.resumeAdId?.rawValue ?? "")
    
    AppOpenAd.load(with: resumeAdId?.rawValue ?? "", request: Request()) { ad, error in
      self.isLoadingAd = false
      if let error = error {
        self.appOpenAd = nil
        self.loadTime = nil
        completion?(false)
        print("App open ad failed to load with error: \(error.localizedDescription).")
        return
      }
      
      self.appOpenAd = ad
      self.appOpenAd?.fullScreenContentDelegate = self
      self.loadTime = Date()
      completion?(true)
      print("App open ad loaded successfully.")
    }
  }
  
  public func showAdIfAvailable(viewController: UIViewController) {
    if !AppManager.shared.showAds {
      return
    }
    
    if AppManager.shared.hasSub {
      return
    }
    if isShowingAd || isRequestingPermission {
      print("App open ad is already showing.")
      return
    }
    if !isAdAvailable() {
      print("App open ad is not ready yet.")
      appOpenAdManagerAdDidComplete()
      loadAd()
      return
    }
    if let ad = appOpenAd {
      print("App open ad will be displayed.")
      isShowingAd = true
      showVC = viewController
//      if showVC?.navigationController != nil {
//        showVC = showVC?.navigationController
//        if showVC?.tabBarController != nil {
//          showVC = showVC?.tabBarController
//        }
//      }
      guard let showVC = showVC else { return }
      
      let loadingVC = AdFullScreenLoadingVC()
      loadingVC.needLoadAd = false
      loadingVC.isOpenAd = true
      loadingVC.modalPresentationStyle = .fullScreen
      UIApplication.keyWindow?.addSubview(loadingVC.view)
      showVC.view.endEditing(true)
      loadingVC.view.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        loadingVC.willMove(toParent: nil)
        loadingVC.view.removeFromSuperview()
        loadingVC.removeFromParent()
        self.addBackGroundViewWhenShowAd()
        if self.countTierOpenAds >= SampleAdUnitID.adFormatOpenAds.count - 1 {
          self.countTierOpenAds = 0
        } else {
          self.countTierOpenAds += 1
        }
        print("Open Ad ==> Present OpenAd ID:", self.resumeAdId?.rawValue ?? "")
        ad.present(from: showVC)
      }
    }
  }
  
  private func addBackGroundViewWhenShowAd() {
    backgroudView = UIView()
    backgroudView.backgroundColor = .white
    backgroudView.tag = 1000
    UIApplication.keyWindow?.addSubview(backgroudView)
    backgroudView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func removeBackGroundWhenDismissAd() {
    backgroudView.removeFromSuperview()
  }
}

extension AdResumeManager: FullScreenContentDelegate {
  public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    removeBackGroundWhenDismissAd()
    showVC = nil
    appOpenAd = nil
    isShowingAd = false
    print("App open ad was dismissed.")
    appOpenAdManagerAdDidComplete()
    //    loadAd()
    blockadDidDismissFullScreenContent?()
  }
  
  public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
    isShowingAd = true
    print("App open ad is presented.")
  }
  
  public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    appOpenAd = nil
    isShowingAd = false
    print("App open ad failed to present with error: \(error.localizedDescription).")
    appOpenAdManagerAdDidComplete()
    removeBackGroundWhenDismissAd()
    
    let windows = UIApplication
      .shared
      .connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
    windows.forEach { window in
      let bgView = window.viewWithTag(1000)
      bgView?.removeFromSuperview()
    }
    //    loadAd()
  }
  
  public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
    blockAdResumeClick?()
    if ad is AppOpenAd {
      AdMobManager.shared.logEvenClick(id: resumeAdId?.rawValue ?? "")
    }
  }
}

