//
//  UIViewControllerExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit

extension UIViewController {
  class func loadFromNib() -> Self {
    func loadFromNib<T: UIViewController>(_ type: T.Type) -> T {
      return T.init(nibName: String(describing: T.self), bundle: nil)
    }
    return loadFromNib(self)
  }
}
