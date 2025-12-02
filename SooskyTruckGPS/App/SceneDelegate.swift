//
//  SceneDelegate.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 3/11/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowSence = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowSence)
    let navigationController = UINavigationController(rootViewController: SplashVC())
    navigationController.isNavigationBarHidden = true
    window.rootViewController = navigationController
    self.window = window
    window.makeKeyAndVisible()
  }

  func sceneDidDisconnect(_ scene: UIScene) {}

  func sceneDidBecomeActive(_ scene: UIScene) {
    showOpenAds()
  }

  func sceneWillResignActive(_ scene: UIScene) {}

  func sceneWillEnterForeground(_ scene: UIScene) {}

  func sceneDidEnterBackground(_ scene: UIScene) {}
  
  private func showOpenAds() {
    guard AppManager.shared.shouldShowOpenAds else {
      return
    }
    LogManager.show(AppManager.shared.shouldShowOpenAds)
    AdResumeManager.shared.resumeAdId = AdUnitID(rawValue: SampleAdUnitID.adFormatOpenAds[AdResumeManager.shared.countTierOpenAds])
    
    AdResumeManager.shared.loadAd { success in
      if success {
        if let vc = UIApplication.topViewController() {
          AdResumeManager.shared.showAdIfAvailable(viewController: vc)
        }
      }
    }
    
    AdResumeManager.shared.blockadDidDismissFullScreenContent = { [weak self] in
      guard let self else { return }
      LogManager.show("Open Ad ==> BlockadDidDismissFullScreenContent")
    }
  }
}
