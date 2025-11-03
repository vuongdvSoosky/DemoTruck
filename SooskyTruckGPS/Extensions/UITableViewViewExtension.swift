//
//  UITableView.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit

extension UITableView {
  func scrollDownIfAtTop() {
    if self.contentOffset.y <= 0 {
      self.setContentOffset(CGPoint(x: 0, y: 2), animated: false)
    }
  }
}
