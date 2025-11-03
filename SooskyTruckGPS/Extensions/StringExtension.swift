//
//  StringExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit

extension String {
  // Chuyển kiểu chuỗi thành ngày.
  func asDate() -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.date(from: self)
  }
  
  func asDate(format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: self)
  }
  
  // Tính toán chiều cao cần thiết để hiển thị text.
  func heightText(width: CGFloat, font: UIFont) -> CGFloat {
    let maxSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
    let text: String = self
    return text.boundingRect(with: maxSize,
                             options: .usesLineFragmentOrigin,
                             attributes: [.font: font],
                             context: nil).height + 1
  }
  
  // Tính toán chiều rộng cần thiết để hiển thị text.
  func widthText(height: CGFloat, font: UIFont) -> CGFloat {
    let maxSize = CGSize(width: CGFloat(MAXFLOAT), height: height)
    let text: String = self
    return text.boundingRect(with: maxSize,
                             options: .usesLineFragmentOrigin,
                             attributes: [.font: font],
                             context: nil).width + 1
  }
  
  // Chuyển đổi chuỗi thành URL sau khi loại bỏ các ký tự không hợp lệ.
  func getCleanedURL() -> URL? {
    guard !self.isEmpty else {
      return nil
    }
    if let url = URL(string: self) {
      return url
    } else if let urlEscapedString = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
              let escapedURL = URL(string: urlEscapedString) {
      return escapedURL
    }
    return nil
  }
  
  // Xoá các khoảng trắng và xuống dòng.
  func trimmingSpacesOnly(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
    return components(separatedBy: characterSet).joined()
  }
  
  func trimmingSpacesOnly() -> String {
    trimmingCharacters(in: .whitespaces)
  }
  
  // Trả về text bản địa hoá với key này.
  func localized() -> String {
    return ""
  }
}

extension String {
  // Viết hoa chữ cái đầu của string
  func capitalizingFirstLetter() -> String {
    return prefix(1).uppercased() + dropFirst()
  }
  
  func lowercasingFirstLetter() -> String {
      return prefix(1).lowercased() + dropFirst()
    }
  
  // splitBeforeUppercase -> split Before Uppercase
  func splitBeforeUppercase() -> [String] {
    return self.unicodeScalars.reduce(into: [""]) { result, scalar in
      if CharacterSet.uppercaseLetters.contains(scalar), !result.last!.isEmpty {
        result.append("") // Bắt đầu một từ mới khi gặp chữ in hoa
      }
      result[result.count - 1].append(Character(scalar))
    }
  }
  
  func extractNumbers() -> [Int] {
    let numbers = self.split { !$0.isNumber }
      .compactMap { Int($0) } 
    return numbers
  }
}

extension String {
  func toDouble() -> Double? {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.numberStyle = .decimal
    return formatter.number(from: self)?.doubleValue
  }
}
