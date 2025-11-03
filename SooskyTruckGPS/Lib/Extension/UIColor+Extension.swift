//
//  UIColor+Extension.swift
//  BaseSubscription
//
//  Created by Việt Nguyễn on 13/1/25.
//

import UIKit

extension UIColor {
  
  convenience init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt64()
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
      case 3: // RGB (12-bit)
        (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
      case 6: // RGB (24-bit)
        (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
      case 8: // ARGB (32-bit)
        (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
      default:
        (a, r, g, b) = (255, 0, 0, 0)
    }
    self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }
  
  func gradientColor(bounds: CGRect, colorStart: UIColor = .white, colorEnd: UIColor = .white, isHorizontalMode: Bool = true) -> UIColor? {
      let getGradientLayer = getGradientLayer(bounds: bounds, colorStart: colorStart, colorEnd: colorEnd, isHorizontalMode: isHorizontalMode)
      UIGraphicsBeginImageContext(getGradientLayer.bounds.size)
      guard (UIGraphicsGetCurrentContext() != nil) else {return UIColor(hex: "FD5900")}
      getGradientLayer.render(in: UIGraphicsGetCurrentContext()!)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return UIColor(patternImage: image!)
  }
  
  func getGradientLayer(bounds : CGRect, colorStart: UIColor = .white, colorEnd: UIColor = .white, isHorizontalMode: Bool) -> CAGradientLayer{
      let gradient = CAGradientLayer()
      gradient.frame = bounds
      gradient.colors = [colorStart.cgColor ,colorEnd.cgColor]
      gradient.startPoint = isHorizontalMode ? CGPoint(x: 0.0, y: 0.5) : CGPoint(x: 0.5, y: 0)
      gradient.endPoint = isHorizontalMode ? CGPoint(x: 1.0, y: 0.5) : CGPoint(x: 0.5, y: 1)
      return gradient
  }
}
