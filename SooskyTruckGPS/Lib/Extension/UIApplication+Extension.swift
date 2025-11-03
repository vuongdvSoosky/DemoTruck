//
//  UIApplication+Extension.swift
//  BaseSubscription
//
//  Created by Việt Nguyễn on 13/1/25.
//

import UIKit

extension UIApplication {
  
  static var release: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String? ?? "x.x"
  }
  
  static var build: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String? ?? "x"
  }
  
  static var versionApp: String {
    return "\(release)(\(build))"
  }
  
  static var keyWindow: UIWindow? {
    self
      .shared
      .connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow })
  }
  
  static func getRootViewController() -> UIViewController? {
    keyWindow?.rootViewController
  }
  
  static func topViewController(controller: UIViewController? = keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
      return topViewController(controller: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
      if let selected = tabController.selectedViewController {
        return topViewController(controller: selected)
      }
    }
    if let presented = controller?.presentedViewController {
      return topViewController(controller: presented)
    }
    if let child = controller?.children.first {
      return topViewController(controller: child)
    }
    return controller
  }
  
  static var topSafeAreaInset: CGFloat  {
    return keyWindow?.safeAreaInsets.top ?? 0
  }
  
}
