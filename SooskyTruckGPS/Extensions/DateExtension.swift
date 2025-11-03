//
//  DateExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit

extension Date {
  // Chuyển kiểu ngày thành chuỗi.
  func asString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    return dateFormatter.string(from: self)
  }
  
  func asString(format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: self)
  }
  
  func formattedTime() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    formatter.amSymbol = "am"
    formatter.pmSymbol = "pm"
    return formatter.string(from: self)
  }
  
  static func durationString(from start: Date, to end: Date) -> String {
    let calendar = Calendar.current
    
    // Làm tròn thời điểm về phút (bỏ phần giây)
    guard let cleanStart = calendar.date(bySetting: .second, value: 0, of: start),
          let cleanEnd = calendar.date(bySetting: .second, value: 0, of: end) else {
      return "0 min"
    }
    
    let interval = cleanEnd.timeIntervalSince(cleanStart)
    guard interval >= 0 else { return "0 min" }
    
    let totalMinutes = Int(interval / 60) // giờ đã chính xác theo từng phút
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    
    if hours > 0 {
      return "\(hours)h \(minutes)m"
    } else {
      return "\(minutes) min"
    }
  }
}

extension Date {
  func strippedTime(calendar: Calendar = .current) -> Date {
    let components = calendar.dateComponents([.year, .month, .day], from: self)
    return calendar.date(from: components)!
  }
}

extension Calendar {
  func endOfDay(for date: Date) -> Date {
    let start = self.startOfDay(for: date)
    return self.date(byAdding: DateComponents(day: 1, second: -1), to: start)!
  }
}

extension Date {
  func daysBeforeEndOfDay(_ days: Int) -> Date {
    let calendar = Calendar.current
    guard let dateBefore = calendar.date(byAdding: .day, value: -days, to: self) else {
      return self
    }
    
    var components = calendar.dateComponents([.year, .month, .day], from: dateBefore)
    components.hour = 23
    components.minute = 59
    components.second = 59
    components.timeZone = TimeZone(secondsFromGMT: 0)
    
    return calendar.date(from: components) ?? self
  }
  
  func toISO8601UTCString() -> String {
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.formatOptions = [.withInternetDateTime]
    return formatter.string(from: self)
  }
  
  var startOfDayUTC: Date {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let components = calendar.dateComponents([.year, .month, .day], from: self)
    return calendar.date(from: components)!
  }
  
  func endOfDayUTC() -> Date {
          let calendar = Calendar(identifier: .gregorian)
          var components = calendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: self)
          components.hour = 23
          components.minute = 59
          components.second = 59
          return calendar.date(from: components)!
      }
}
