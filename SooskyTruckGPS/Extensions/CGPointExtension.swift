//
//  CGPointExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import Foundation

extension CGPoint {
  // Trả về khoảng cách giữa 2 điểm.
  func distance(to second: CGPoint) -> Double {
    let first = self
    return sqrt((second.x - first.x).square() + (second.y - first.y).square())
  }
}
