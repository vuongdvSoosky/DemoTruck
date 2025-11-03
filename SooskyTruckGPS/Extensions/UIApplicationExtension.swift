//
//  UIApplicationExtension.swift
//  SooskyBabyTracker
//
//   Created by VuongDV on 9/4/25.
//

import UIKit

extension UIApplication {
  class func context() -> UINavigationController? {
    return UIApplication.shared.windows.first?.rootViewController as? UINavigationController
  }
  
  class func topViewController() -> UIViewController? {
    return context()?.topViewController
  }
  
  static func topTabBarController() -> UITabBarController? {
    guard let root = keyWindow?.rootViewController else { return nil }
    if let nav = root as? UINavigationController {
      return nav.viewControllers.first(where: { $0 is UITabBarController }) as? UITabBarController
    } else if let tab = root as? UITabBarController {
      return tab
    }
    return nil
  }
}
