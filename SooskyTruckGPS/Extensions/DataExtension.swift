//
//  DataExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import Foundation

extension Data {
  // Chuyển đổi chuỗi thành dữ liệu, dùng để thêm body khi đẩy data lên server.
  mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}

extension Date {
  func isSameDay(as otherDate: Date) -> Bool {
    let calendar = Calendar.current
    return calendar.isDate(self, inSameDayAs: otherDate)
  }
  
  func formattedSectionTitle() -> String {
    let calendar = Calendar.current
    if calendar.isDateInToday(self) {
      return "Today"
    } else if calendar.isDateInYesterday(self) {
      return "Yesterday"
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = "EEEE, MMM d" // Ví dụ: "Monday, Feb 5"
      return formatter.string(from: self)
    }
  }
}
