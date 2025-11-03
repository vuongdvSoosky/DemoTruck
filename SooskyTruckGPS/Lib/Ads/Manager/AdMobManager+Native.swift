//
//  AdMobManager+Native.swift
//  MobileAds
//
//  Created by macbook on 29/08/2021.
//

import Foundation
import GoogleMobileAds
import SkeletonView
import FirebaseAnalytics

public enum OptionAdType {
  case option_1
  case option_2
}

protocol NativeAdProtocol {
  var adUnitID: String? {get set}
  
  func bindingData(nativeAd: NativeAd)
  func getGADView() -> NativeAdView
}

extension NativeAdProtocol {
  mutating func updateId(value: String) {
    adUnitID = value
  }
}

public enum NativeAdType {
  case small
  case medium
  case media
  case fullScreen
  
  var content: NativeAdProtocol {
    switch self {
    case .small:
      return SmallGGNativeAdView()
    case .medium:
      return MediumGGNativeAdView()
    case .media:
      return MediaGGNativeAdView()
    case .fullScreen:
      return FullScreenGGNativeAdView()
    }
  }
}

// MARK: - GADUnifiedNativeAdView
extension AdMobManager {
  
  private func getNativeAdLoader(unitId: AdUnitID) -> AdLoader? {
    return listLoader.object(forKey: unitId.rawValue) as? AdLoader
  }
  
  private func getAdNative(unitId: String) -> [NativeAdProtocol]? {
    if let adNativeView = listAd.object(forKey: unitId) as? [NativeAdProtocol] {
      return adNativeView
    }
    return nil
  }
  
  private func createAdNativeView(unitId: AdUnitID, type: NativeAdType = .small, views: [UIView]) {
    if let _ = getAdNative(unitId: unitId.rawValue) {
      return
    }
    
    var nativeViews: [NativeAdProtocol] = []
    views.forEach { view in
      
      let adNativeProtocol = type.content
      let adNativeView = adNativeProtocol.getGADView()
      view.tag = 0
      view.subviews.forEach { subView in
        subView.removeFromSuperview()
      }
      view.addSubview(adNativeView)
      adNativeView.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }
      adNativeView.layoutIfNeeded()
      
      nativeViews.append(adNativeProtocol)
    }
    
    listAd.setObject(nativeViews, forKey: unitId.rawValue as NSCopying)
  }
  
  private func reloadAdNative(unitId: AdUnitID) {
    if let loader = self.getNativeAdLoader(unitId: unitId) {
      loader.load(Request())
    }
  }
  
  public func addAdNative(unitId: AdUnitID, rootVC: UIViewController, views: [UIView], type: NativeAdType = .small, ratio: MediaAspectRatio = .portrait) {
    if !AppManager.shared.showAds {
      views.forEach { view in
        view.snp.makeConstraints { make in
          make.height.equalTo(0)
        }
        
        view.subviews.forEach { subview in
          subview.removeFromSuperview()
        }
      }
      
      return
    }
    
    if AppManager.shared.hasSub {
      views.forEach { view in
        view.snp.updateConstraints { make in
          make.height.equalTo(0)
        }
        
        view.subviews.forEach { subview in
          subview.removeFromSuperview()
        }
      }
      
      return
    } else {
      views.forEach { view in
        view.snp.updateConstraints { make in
          switch type {
          case .small:
            make.height.equalTo(SmallGGNativeAdView.height)
          case .medium:
            make.height.equalTo(MediumGGNativeAdView.height)
          case .media:
            make.height.equalTo(MediaGGNativeAdView.height)
          case .fullScreen:
            return
          }
        }
      }
    }
    
    removeAd(unitId: unitId.rawValue)
    createAdNativeView(unitId: unitId, type: type, views: views)
    loadAdNative(unitId: unitId, rootVC: rootVC, numberOfAds: views.count, ratio: ratio)
  }
  
  private func loadAdNative(unitId: AdUnitID, rootVC: UIViewController, numberOfAds: Int, ratio: MediaAspectRatio) {
    if let loader = getNativeAdLoader(unitId: unitId) {
      loader.load(Request())
      return
    }
    let multipleAdsOptions = MultipleAdsAdLoaderOptions()
    multipleAdsOptions.numberOfAds = numberOfAds
    let aspectRatioOption = NativeAdMediaAdLoaderOptions()
    aspectRatioOption.mediaAspectRatio = ratio
    let adLoader = AdLoader(adUnitID: unitId.rawValue,
                               rootViewController: rootVC,
                               adTypes: [ .native ],
                               options: [multipleAdsOptions, aspectRatioOption])
    listLoader.setObject(adLoader, forKey: unitId.rawValue as NSCopying)
    adLoader.delegate = self
    adLoader.load(Request())
  }
}

// MARK: - GADUnifiedNativeAdDelegate
extension AdMobManager: NativeAdDelegate {
  public func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
    print("ad==> nativeAdDidRecordClick ")
    logEventNative(nativeAd: nativeAd)
  }
  
  func logEventNative(nativeAd: NativeAd) {
    let adViews = listAd.allValues
    adViews.forEach { ad in
      if let nativeAdViews = ad as? [NativeAdProtocol] {
        if let ad = nativeAdViews.first(where: {$0.getGADView() == nativeAd}) {
          logEvenClick(id: ad.adUnitID ?? "")
        }
      }
    }
  }
}

// MARK: - GADAdLoaderDelegate
extension AdMobManager: AdLoaderDelegate {
  
  
  public func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
    print(String(describing: error))
    self.blockNativeFaild?(adLoader.adUnitID)
    self.removeAd(unitId: adLoader.adUnitID)
  }
  
  public func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
    listLoader.removeObject(forKey: adLoader.adUnitID)
    print("ad==> adLoaderDidFinishLoading \(adLoader)")
  }
}

// MARK: - GADUnifiedNativeAdLoaderDelegate
extension AdMobManager: NativeAdLoaderDelegate {
  public func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
    nativeAd.delegate = self
    
    guard var nativeAdView = self.getAdNative(unitId: adLoader.adUnitID)?.first(where: {$0.getGADView().tag == 0}) else {return}
    nativeAdView.getGADView().tag = 2
    nativeAd.mediaContent.videoController.delegate = self
    nativeAdView.updateId(value: adLoader.adUnitID)
    nativeAdView.getGADView().hideSkeleton()
    nativeAdView.bindingData(nativeAd: nativeAd)
    self.blockLoadNativeSuccess?(true)
  }
  
  public func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
    print("ad==> nativeAdDidRecordImpression")
  }
  
}

// MARK: - GADVideoControllerDelegate
extension AdMobManager: VideoControllerDelegate {
  
}
