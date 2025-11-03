//
//  CGFloatExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import Foundation

extension CGFloat {
  // Làm tròn phần thập phân.
  func roundToDecimals(decimals: Int = 9) -> CGFloat {
    let multiplier = pow(10, CGFloat(decimals))
    return ((self * multiplier).rounded() / multiplier)
  }
}
