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
    return topViewController()?.tabBarController
  }
}

extension UIApplication {
  static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
    .compactMap({ $0 as? UIWindowScene })
    .flatMap({ $0.windows })
    .first(where: { $0.isKeyWindow })?.rootViewController) -> UIViewController? {
      
      if let nav = base as? UINavigationController {
        return topViewController(base: nav.visibleViewController)
      }
      
      if let tab = base as? UITabBarController {
        return topViewController(base: tab.selectedViewController)
      }
      
      if let presented = base?.presentedViewController {
        return topViewController(base: presented)
      }
      
      return base
    }
}
