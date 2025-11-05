//
//  StringExt.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 16/4/25.
//

import Foundation
import UIKit

extension String {
  /// Tính khoảng cách thời gian giữa hai chuỗi thời gian định dạng "HH:mm", trả về kiểu "03 Hours"
  func timeDifferenceInHours(to endTime: String) -> String? {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    guard let startDate = formatter.date(from: self),
          let endDate = formatter.date(from: endTime) else {
      return nil
    }
    
    let duration = endDate.timeIntervalSince(startDate)
    let hours = Int(duration) / 3600
    return String(format: "%02d Hours", hours)
  }
}

extension String {
  func asAlarmAttributedText() -> NSAttributedString {
    let attributed = NSMutableAttributedString(string: self)
    
    if let timeRange = self.range(of: #"^\d{2}:\d{2}"#, options: .regularExpression) {
      let nsRange = NSRange(timeRange, in: self)
      attributed.addAttribute(.font, value: AppFont.font(.bold, size: 28.0), range: nsRange)
      attributed.addAttribute(.foregroundColor, value: UIColor(rgb: 0x2E1F88), range: nsRange)
    }
    
    if let ampmRange = self.range(of: "am") ?? self.range(of: "pm") {
      let nsRange = NSRange(ampmRange, in: self)
      attributed.addAttribute(.font, value: AppFont.font(.regular, size: 16.0), range: nsRange)
      attributed.addAttribute(.foregroundColor, value: UIColor(rgb: 0x2E1F88), range: nsRange)
    }
    
    return attributed
  }
}

extension String {
  func cleanedFormat(suffix: String) -> String {
    let cleaned = self.replacingOccurrences(of: suffix, with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return "\(cleaned) \(suffix)"
  }
  
  var trimmed: String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  func boldMarkdown(fontSize: CGFloat = 16) -> NSAttributedString {
    let attributed = NSMutableAttributedString(string: self)
    let regex = try! NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*")
    let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.count))
    
    for match in matches.reversed() {
      let boldRange = match.range(at: 1) // phần text bên trong **
      let fullRange = match.range(at: 0) // cả đoạn **...**
      let boldText = (self as NSString).substring(with: boldRange)
      
      let boldAttr = NSAttributedString(
        string: boldText,
        attributes: [.font: UIFont.boldSystemFont(ofSize: fontSize)]
      )
      attributed.replaceCharacters(in: fullRange, with: boldAttr)
    }
    return attributed
  }
}

extension String {
  func fromISO8601Date() -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter.date(from: self)
  }
}

extension String {
  /// Lấy phần địa chỉ trước dấu phẩy đầu tiên
  var shortAddress: String {
    return self.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? self
  }
}
