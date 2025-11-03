//
//  UITabBarControllerExt.swift
//  SooskyTractorGPS
//
//  Created by VuongDv on 18/9/25.
//

import UIKit

extension UITabBarController {
  func findViewController<T: UIViewController>(ofType type: T.Type) -> T? {
    guard let viewControllers = self.viewControllers else { return nil }
    
    for vc in viewControllers {
      if let nav = vc as? UINavigationController {
        // Lấy root
        if let first = nav.viewControllers.first as? T {
          return first
        }
        // Hoặc duyệt hết stack
        for child in nav.viewControllers {
          if let match = child as? T {
            return match
          }
        }
      } else if let match = vc as? T {
        return match
      }
    }
    return nil
  }
}
