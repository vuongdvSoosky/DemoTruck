//
//  IntExtension.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 22/11/25.
//

extension Int {
  /// Convert milliseconds to readable time string like "1h 59m", "05m 32s", "32s"
  var toTimeString: String {
    let totalSeconds = self / 1000
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    
    if hours > 0 {
      return "\(hours)h \(minutes)m"
    } else if minutes > 0 {
      return "\(minutes)m \(seconds)s"
    } else {
      return "\(seconds)s"
    }
  }
}
