//
//  AppFonts.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit

class AppFont {
  enum FontName: String {
    case medium = "SFProDisplay-Medium"
    case semiBold = "SFProDisplay-Semibold"
    case regular = "SFProDisplay-Regular"
    case bold = "SFProDisplay-Bold"
    case light = "SFProDisplay-Light"
    case mediumText = "SFProText-Medium"
    case regularText = "SFProText-Regular"
    case semiBoldText = "SFProText-Semibold"
    case boldText = "SFProText-Bold"
    case lightText = "SFProText-Light"
    case heavy = "SFProText-Heavy"
    case pro = "SFPro"
    case regularTextItalic = "SFProText-RegularItalic"
    case semiboldItalic = "SFProText-SemiboldItalic"
  }
  
  class func font(_ name: FontName, size: CGFloat) -> UIFont {
    guard let font = UIFont(name: name.rawValue, size: size) else {
      return UIFont.systemFont(ofSize: size)
    }
    return font
  }
}
