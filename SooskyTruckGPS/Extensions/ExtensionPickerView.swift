//
//  ExtensionPickerView.swift
//  SooskyHorseTracking
//
//  Created by VuongDv on 17/10/25.
//

import UIKit

extension UIPickerView {
  func removeSelectionLines() {
    subviews.forEach { view in
      if view.bounds.height < 1 {
        view.isHidden = true
      }
    }
  }
  
  func clearBackgroundHighlight() {
    subviews.forEach { subview in
      subview.backgroundColor = .clear
    }
  }
}
