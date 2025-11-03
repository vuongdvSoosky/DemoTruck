//
//  AdMobManager.swift
//  MobileAds
//
//  Created by macbook on 28/08/2021.
//

import Foundation
import UIKit
import GoogleMobileAds
import SkeletonView
import FirebaseAnalytics

public typealias VoidBlockAds = () -> Void
public typealias BoolBlockAds = (Bool) -> Void
public typealias StringBlockAds = (String) -> Void
public typealias IntBlockAds = (Int) -> Void

let screenWidthAds = UIScreen.main.bounds.width
let screenHeightAds = UIScreen.main.bounds.height

//    MARK: - Google-provided demo ad units
public struct SampleAdUnitID {
  //    MARK: - Ads giả
//  public static let adFormatFixedBannerID1       = "ca-app-pub-3940256099942544/2934735716"
//  public static let adFormatFixedBannerID2       = "ca-app-pub-3940256099942544/2934735716"
//  
//  public static let adFormatInterstitialID1      = "ca-app-pub-3940256099942544/1033173712"
//  
//  public static let adFormatNativeAdvanced1       = "ca-app-pub-3940256099942544/3986624511"
//  public static let adFormatNativeAdvanced2       = "ca-app-pub-3940256099942544/3986624511"
//  public static let adFormatNativeAdvanced3       = "ca-app-pub-3940256099942544/3986624511"
//  public static let adFormatNativeAdvanced4       = "ca-app-pub-3940256099942544/3986624511"
//  
//  public static let adFormatRewardedID1          = "ca-app-pub-3940256099942544/1712485313"
//  
//  public static let adFormatOpenAds             = [
//    "ca-app-pub-3940256099942544/5575463023",
//    "ca-app-pub-3940256099942544/5575463023",
//    "ca-app-pub-3940256099942544/5575463023",
//  ]
  // MARK: - Ads thật
  
    public static let adFormatFixedBannerID1       = "ca-app-pub-4608855745095547/5551430958"
    public static let adFormatFixedBannerID2       = "ca-app-pub-4608855745095547/5411830150"
  
    public static let adFormatInterstitialID1      = "ca-app-pub-4608855745095547/9366359364"
  
    public static let adFormatNativeAdvanced1      = "ca-app-pub-4608855745095547/1803757632"
    public static let adFormatNativeAdvanced2      = "ca-app-pub-4608855745095547/6775407936"
    public static let adFormatNativeAdvanced3      = "ca-app-pub-4608855745095547/9490675963"
    public static let adFormatNativeAdvanced4      = "ca-app-pub-4608855745095547/4805325497"
  
    public static let adFormatRewardedID1          = "ca-app-pub-4608855745095547/5108577826"
  
    public static let adFormatOpenAds             = [
      "ca-app-pub-4608855745095547/3116839306",
      "ca-app-pub-4608855745095547/6931767715",
      "ca-app-pub-4608855745095547/8720519770",
    ]

}

//    MARK: - Enum AdUnitID
public struct AdUnitID {
  public var rawValue: String = ""
  
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

//    MARK: - Enum Theme Style Ads
public enum ThemeStyleAds {
  case origin
  case custom(
    backgroundColor: UIColor,
    titleColor: UIColor,
    vertiserColor: UIColor,
    contentColor: UIColor,
    actionColor: UIColor,
    backgroundAction: [UIColor]
  )
  case setBackground(backgroundColor: UIColor)
  
  var colors: (
    backgroundColor: UIColor,
    titleColor: UIColor,
    vertiserColor: UIColor,
    contentColor: UIColor,
    actionColor: UIColor,
    backgroundAction: [UIColor]
  ) {
    switch self {
    case .origin:
      return (
        UIColor(hex: "FFFFFF"),
        UIColor(hex: "0303B3"),
        UIColor(hex: "001868"),
        UIColor(hex: "666666"),
        UIColor(hex: "FFFFFF"),
        [UIColor(hex: "007AFF")]
      )
    case .custom(
      let backgroundColor,
      let titleColor,
      let vertiserColor,
      let contentColor,
      let actionColor,
      let backgroundAction
    ):
      return (
        backgroundColor,
        titleColor,
        vertiserColor,
        contentColor,
        actionColor,
        backgroundAction
      )
    case .setBackground(let backgroundColor):
      return (
        backgroundColor,
        UIColor(hex: "0303B3"),
        UIColor(hex: "001868"),
        UIColor(hex: "666666"),
        UIColor(hex: "FFFFFF"),
        [UIColor(hex: "007AFF")]
      )
    }
  }
}

open class AdMobManager: NSObject {
  
  //    MARK: - Property
  public static let shared = AdMobManager()
  public var timeOut: Int = 30
  public var didEarnReward = false
  public var showAdRewardCount = 0
  public var listAd: NSMutableDictionary = NSMutableDictionary()
  public var listLoader: NSMutableDictionary = NSMutableDictionary()
  
  //    MARK: - Type Theme color
  public var adsNativeColor: ThemeStyleAds = .origin
  
  //    MARK: - UI Native
  public var adsNativeCornerRadiusButton:      CGFloat = 8
  public var adsNativeCornerRadius:            CGFloat = 4
  public var adsNativeBorderWidth:             CGFloat = 1
  public var adsNativeSmallWidthButton:        CGFloat = 80
  public var adsNativeMediumHeightButton:      CGFloat = 48
  
  public var adsNativeBorderColor:             UIColor = .clear
  public var adNativeAdsLabelColor:            UIColor = .white
  public var adNativeBackgroundAdsLabelColor: UIColor = UIColor(hex: "FDB812")
  
  public var nativeButtonCornerRadius: CGFloat = 16
  public var rewardErrorString: String         = "An error occurred"
  public var adFullScreenLoadingString: String = "Loading Ad"
  public var skeletonGradient = UIColor.clouds
  
  var isSplash = false
  var loadingRewardIds: [String] = []
  
  //    MARK: - Block Ads
  public var blockLoadFullScreenAdSuccess: StringBlockAds?
  public var blockFullScreenAdWillDismiss: VoidBlockAds?
  public var blockFullScreenAdDidDismiss : VoidBlockAds?
  public var blockFullScreenAdWillPresent: StringBlockAds?
  public var blockFullScreenAdDidPresent : StringBlockAds?
  public var blockFullScreenAdFaild      : StringBlockAds?
  public var blockFullScreenAdClick      : VoidBlockAds?
  public var blockCompletionHandeler     : BoolBlockAds?
  public var blockNativeFaild            : StringBlockAds?
  public var blockLoadNativeSuccess      : BoolBlockAds?
  public var blockBannerFaild            : StringBlockAds?
  public var blockLoadBannerSuccess      : BoolBlockAds?
  public var blockBannerClick            : StringBlockAds?
  public var blockRewardAdWillPresent    : VoidBlockAds?
  
  //    MARK: - Remove ID ads
  public func removeAd(unitId: String) {
    listAd.removeObject(forKey: unitId)
    listLoader.removeObject(forKey: unitId)
  }
  
  func logEvenClick(id: String) {
    Analytics.logEvent("user_click_ads", parameters: ["adunitid" : id])
  }
  
}
