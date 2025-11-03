//
//  AdMobManager+Banner.swift
//  MobileAds
//
//  Created by Quang Ly Hoang on 22/02/2022.
//

import Foundation
import GoogleMobileAds
import SkeletonView
import FirebaseAnalytics

// MARK: - GADBannerView
extension AdMobManager: BannerViewDelegate {
  
  fileprivate func getAdBannerView(unitId: AdUnitID) -> BannerView? {
    if let bannerView = listAd.object(forKey: unitId.rawValue) as? BannerView  {
      return bannerView
    }
    return nil
  }
  
  public func createAdBannerIfNeed(unitId: AdUnitID) -> BannerView {
    if let adBannerView = self.getAdBannerView(unitId: unitId) {
      return adBannerView
    }
    let adBannerView = BannerView()
    adBannerView.adUnitID = unitId.rawValue
    listAd.setObject(adBannerView, forKey: unitId.rawValue as NSCopying)
    return adBannerView
  }
  
  // quảng cáo xác định kích thước
  public func addAdBanner(unitId: AdUnitID, rootVC: UIViewController, view: UIView, height: CGFloat = 50) {
    if !AppManager.shared.showAds {
      view.snp.updateConstraints { make in
        make.height.equalTo(0)
      }
      return
    }
    
    if AppManager.shared.hasSub {
      view.snp.updateConstraints { make in
        make.height.equalTo(0)
      }
      return
    } else {
      view.snp.updateConstraints { make in
        make.height.equalTo(height)
      }
    }
    
    let adBannerView = self.createAdBannerIfNeed(unitId: unitId)
    adBannerView.rootViewController = rootVC
    view.addSubview(adBannerView)
    view.layer.borderWidth = 0.5
    view.layer.borderColor = UIColor.gray.cgColor
    adBannerView.delegate = self
    adBannerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    adBannerView.showLoading()
    
    let request = Request()
    adBannerView.load(request)
  }
  
  // Quảng cáo Collapsible đặt ở bottom, lần đầu sẽ mở rộng
  public func addAdCollapsibleBannerAdaptive(unitId: AdUnitID, rootVC: UIViewController, view: UIView, height: CGFloat, isCollapsibleBanner: Bool = false) {
    if !AppManager.shared.showAds {
      view.snp.updateConstraints { make in
        make.height.equalTo(0)
      }
      return
    }
    
    if AppManager.shared.hasSub {
      view.snp.updateConstraints { make in
        make.height.equalTo(0)
      }
      return
    } else {
      view.snp.updateConstraints { make in
        make.height.equalTo(height)
      }
    }
    
    let adBannerView = self.createAdBannerIfNeed(unitId: unitId)
    adBannerView.rootViewController = rootVC
    view.addSubview(adBannerView)
    view.layer.borderWidth = 0.5
    view.layer.borderColor = UIColor.gray.cgColor
    adBannerView.delegate = self
    
    adBannerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    adBannerView.adSize =  currentOrientationAnchoredAdaptiveBanner(width: screenWidthAds)
    let request = Request()
    let gadExtras = Extras()
    gadExtras.additionalParameters = ["collapsible": "bottom"]
    request.register(gadExtras)
    adBannerView.showLoading()
    adBannerView.load(request)
  }
  
  
  // quảng có thích ứng với chiều cao không cố định
  public func addAdBannerAdaptive(unitId: AdUnitID, rootVC: UIViewController, view: UIView) {
    if !AppManager.shared.showAds {
      view.snp.updateConstraints { make in
        make.height.equalTo(0)
      }
      return
    }
    
    if AppManager.shared.hasSub {
      view.snp.updateConstraints { make in
        make.height.equalTo(0)
      }
      return
    }
    
    let adBannerView = self.createAdBannerIfNeed(unitId: unitId)
    adBannerView.rootViewController = rootVC
    view.addSubview(adBannerView)
    view.layer.borderWidth = 0.5
    view.layer.borderColor = UIColor.gray.cgColor
    adBannerView.delegate = self
    
    adBannerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    adBannerView.showLoading()
    
    adBannerView.adSize =  currentOrientationAnchoredAdaptiveBanner(width: screenWidthAds)
    let request = Request()
    adBannerView.load(request)
  }
  
  // MARK: - GADBanner delegate
  public func bannerViewDidReceiveAd(_ bannerView: BannerView) {
    print("ad==> bannerView did load \(bannerView.adUnitID ?? "")")
    bannerView.hideLoading()
  }
  
  public func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
    print("ad==> bannerView faild \(error.localizedDescription)")
    bannerView.delegate = nil
    if let unitId = bannerView.adUnitID {
      self.removeAd(unitId: unitId)
      self.blockBannerFaild?(unitId)
    }
  }
  
  public func bannerViewWillDismissScreen(_ bannerView: BannerView) {
    print("ad ==> bannerViewWillDismissScreen")
  }
  
  public func bannerViewDidDismissScreen(_ bannerView: BannerView) {
    print("ad ==> bannerViewDidDismissScreen")
  }
  
  public func bannerViewDidRecordClick(_ bannerView: BannerView) {
    print("ad ==> bannerViewDidRecordClick")
  }
  
  public func bannerViewWillPresentScreen(_ bannerView: BannerView) {
    print("ad ==> bannerViewWillPresentScreen")
  }
  
  public func bannerViewDidRecordImpression(_ bannerView: BannerView) {
    print("ad ==> adViewDidRecordImpression bannerView\(bannerView.adUnitID ?? "")")
    bannerView.hideLoading()
    bannerView.delegate = nil
    blockLoadBannerSuccess?(true)
  }
  
  
//  public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
//    print("ad==> bannerViewWillDismissScreen")
//    if let adUnitID = bannerView.adUnitID {
//      self.removeAd(unitId: adUnitID)
//    }
//  }
  
//  public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
//    print("ad==> adViewDidRecordImpression bannerView\(bannerView.adUnitID ?? "")")
////    bannerView.hideLoading()
////    bannerView.delegate = nil
//    blockLoadBannerSuccess?(true)
//  }
  
//  public func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
//    blockBannerClick?(bannerView.adUnitID ?? "")
//    AdMobManager.shared.logEvenClick(id: bannerView.adUnitID ?? "")
//  }
  
}
