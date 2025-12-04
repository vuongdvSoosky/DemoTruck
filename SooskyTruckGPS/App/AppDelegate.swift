//
//  AppDelegate.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 3/11/25.
//

import UIKit
import FirebaseCore
import GoogleMobileAds
import FirebaseStorage

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    FirebaseApp.configure()
    MobileAds.shared.start(completionHandler: nil)
    CreditManager.shared.fetchNumOfTurn()
    verifi()
    
    FireBaseFirestore.sharedInstance.getConfigApp { [weak self] showAds in
      guard let self else {
        return
      }
      if showAds {
        setupAds()
      }
    }
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
  
  private func setupAds() {
    AdMobManager.shared.createAdInterstitialIfNeed(unitId: AdUnitID(rawValue: SampleAdUnitID.adFormatInterstitialID1))
    AdMobManager.shared.createAdRewardedIfNeed(unitId: AdUnitID(rawValue: SampleAdUnitID.adFormatRewardedID1))
  }
}

extension AppDelegate {
  private func verifi() {
    Task {
      _ = try await StoreManager.share.fetchProducts()
      await StoreManager.share.updatePurchasedProducts()
    }
  }
}
