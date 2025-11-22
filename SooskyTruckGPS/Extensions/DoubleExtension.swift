//
//  DoubleExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import Foundation

extension Double {
  // Làm tròn phần thập phân.
  func roundToDecimals(decimals: Int = 9) -> Double {
    let multiplier = pow(10, Double(decimals))
    return ((self * multiplier).rounded() / multiplier)
  }
  
  // Trả về giá trị bình phương.
  func square() -> Double {
    return self * self
  }
  
  func kelvinToCelsius() -> Double {
    return self - 273.15
  }
}

extension Double {
  /// Chuyển đổi giờ (Double) sang "xh ym"
  func toHoursMinutesSecondsString() -> String {
    let hours = Int(self)
    let totalMinutes = (self - Double(hours)) * 60
    let minutes = Int(totalMinutes)
    let seconds = Int((totalMinutes - Double(minutes)) * 60)
    return "\(hours)h \(minutes)m \(seconds)s"
  }
  
  /// Chuyển đổi giờ (Double) sang "hh:mm:ss"
  func toHHMMSSString() -> String {
    let totalSeconds = Int(self)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
  }
  
  func getFormattedOperationTime() -> String {
    let totalSeconds = Int(self)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
  }
}

extension Double {
  
  /// Sai số mặc định khi so sánh Double
  private static let defaultEpsilon: Double = 0.00001
  
  /// Kiểm tra xem số hiện tại có lớn hơn số khác với epsilon
  func isGreater(than other: Double, epsilon: Double = Double.defaultEpsilon) -> Bool {
    return self > other + epsilon
  }
  
  /// Kiểm tra xem số hiện tại có nhỏ hơn số khác với epsilon
  func isLess(than other: Double, epsilon: Double = Double.defaultEpsilon) -> Bool {
    return self < other - epsilon
  }
  
  /// Kiểm tra xem số hiện tại có gần bằng số khác với epsilon
  func isAlmostEqual(to other: Double, epsilon: Double = Double.defaultEpsilon) -> Bool {
    return abs(self - other) < epsilon
  }
}

extension Double {
  var toMiles: Double {
    return self / 1609.344
  }
  
  var milesString: String {
    return String(format: "%.2f mi", self.toMiles)
  }
}

