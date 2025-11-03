//
//  UITextFieldExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 25/4/25.
//

import UIKit

extension UITextField {
  func setPlaceholder(_ text: String,
                      font: UIFont = AppFont.font(.regularText, size: 20),
                      color: UIColor = UIColor(rgb: 0xAEAAAA)) {
    
    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color
    ]
    
    self.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
  }
}
