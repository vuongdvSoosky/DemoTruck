//
//  UILableExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit

@IBDesignable extension UILabel {
  @IBInspectable var localizeKey: String? {
    get {
      return self.text
    } set {
      DispatchQueue.main.async {
        self.text = newValue?.localized()
      }
    }
  }
}

extension UILabel {
  func setRequiredTitle(_ title: String,
                        font: UIFont = AppFont.font(.semiBoldText, size: 20),
                        titleColor: UIColor = UIColor(rgb: 0x111111),
                        asteriskColor: UIColor = UIColor(rgb: 0xEC3352)) {
    
    let attributedString = NSMutableAttributedString()
    
    let textAttributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: titleColor
    ]
    
    let asteriskAttributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: asteriskColor
    ]
    
    attributedString.append(NSAttributedString(string: title, attributes: textAttributes))
    attributedString.append(NSAttributedString(string: " *", attributes: asteriskAttributes))
    
    self.attributedText = attributedString
  }
  
  func setLineSpacing(lineSpacing: CGFloat = 6, alignment: NSTextAlignment? = .center) {
    guard let labelText = self.text else { return }
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.alignment = alignment ?? self.textAlignment
    
    let attributedString: NSMutableAttributedString
    if let currentAttrText = self.attributedText {
      attributedString = NSMutableAttributedString(attributedString: currentAttrText)
    } else {
      attributedString = NSMutableAttributedString(string: labelText)
    }
    
    attributedString.addAttributes([
      .paragraphStyle: paragraphStyle,
      .font: self.font as Any,
      .foregroundColor: self.textColor as Any
    ], range: NSMakeRange(0, attributedString.length))
    
    self.attributedText = attributedString
  }
  
  func setBulletedList(_ items: [String],
                       font: UIFont = .systemFont(ofSize: 16),
                       textColor: UIColor = .black,
                       lineSpacing: CGFloat = 4,
                       indent: CGFloat = 20) {
    
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineSpacing = lineSpacing
    paragraph.headIndent = indent
    paragraph.firstLineHeadIndent = 0
    paragraph.paragraphSpacing = 6
    
    let attributedString = NSMutableAttributedString()
    
    for (index, item) in items.enumerated() {
      let bullet = "• \(item)"
      let attr = NSAttributedString(
        string: bullet + (index == items.count - 1 ? "" : "\n"),
        attributes: [
          .font: font,
          .foregroundColor: textColor,
          .paragraphStyle: paragraph
        ]
      )
      attributedString.append(attr)
    }
    
    self.attributedText = attributedString
  }
  
  func setStepFormattedText(
    _ text: String,
    stepColor: UIColor = UIColor(rgb: 0x111111),
    stepFont: UIFont = AppFont.font(.mediumText, size: 17),
    normalFont: UIFont = AppFont.font(.regularText, size: 17),
    normalColor: UIColor = .label,
    lineSpacing: CGFloat = 6,
    sectionSpacing: CGFloat = 0
  ) {
    let attributed = NSMutableAttributedString()
    
    // Tách text thành từng đoạn bắt đầu bằng "Step"
    let sections = text.components(separatedBy: "\r\n\r\n")
    
    for (index, section) in sections.enumerated() {
      let sectionAttr = NSMutableAttributedString(string: section)
      
      // Định nghĩa paragraph style cho nội dung mô tả
      let paragraph = NSMutableParagraphStyle()
      paragraph.lineSpacing = lineSpacing
      paragraph.paragraphSpacing = sectionSpacing
      paragraph.alignment = self.textAlignment
      
      sectionAttr.addAttributes([
        .font: normalFont,
        .foregroundColor: normalColor,
        .paragraphStyle: paragraph
      ], range: NSRange(location: 0, length: sectionAttr.length))
      
      // Highlight dòng bắt đầu bằng "Step"
      let pattern = "^Step\\s*\\d*:[^\r\n]*"
      if let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) {
        for match in regex.matches(in: section, range: NSRange(section.startIndex..., in: section)) {
          sectionAttr.addAttributes([
            .font: stepFont,
            .foregroundColor: stepColor
          ], range: match.range)
        }
      }
      
      attributed.append(sectionAttr)
      
      // Thêm khoảng trắng nhỏ giữa các section (tránh cách xa quá)
      if index < sections.count - 1 {
        attributed.append(NSAttributedString(string: "\n"))
      }
    }
    
    self.numberOfLines = 0
    self.attributedText = attributed
  }
  
  func setKeywordHighlightTip(
    _ text: String,
    keywordFont: UIFont = AppFont.font(.mediumText, size: 17),
    keywordColor: UIColor = UIColor(rgb: 0x111111),
    normalFont: UIFont = AppFont.font(.regularText, size: 17),
    normalColor: UIColor = UIColor(rgb: 0x111111),
    lineSpacing: CGFloat = 6
  ) {
    let attributed = NSMutableAttributedString(string: text)
    
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineSpacing = lineSpacing
    paragraph.alignment = self.textAlignment
    
    attributed.addAttributes([
      .font: normalFont,
      .foregroundColor: normalColor,
      .paragraphStyle: paragraph
    ], range: NSRange(location: 0, length: attributed.length))
    
    let keywordPattern = "(?<=^|\\n|\\r|-)\\s*([^:;\\n\\r]+?)(?=\\s*[:;])"
    if let regex = try? NSRegularExpression(pattern: keywordPattern, options: []) {
      for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
        attributed.addAttributes([
          .font: keywordFont,
          .foregroundColor: keywordColor
        ], range: match.range)
      }
    }
    
    self.numberOfLines = 0
    self.attributedText = attributed
  }
}

extension UILabel {
  func setBoldText(prefix: String, value: String, fontSize: CGFloat = 17) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineSpacing = 2
    paragraph.paragraphSpacing = 2
    
    let normalFont = AppFont.font(.regularText, size: fontSize)
    let boldFont = AppFont.font(.boldText, size: fontSize)
    let color = UIColor(rgb: 0x111111)
    
    var cleanValue = value
    let pattern = #"\*\*(.*?)\*\*"#
    let regex = try? NSRegularExpression(pattern: pattern)
    let matches = regex?.matches(in: value, range: NSRange(value.startIndex..., in: value)) ?? []
    
    cleanValue = value.replacingOccurrences(of: "**", with: "")
    let fullText = "\(prefix) \(cleanValue)"
    
    let attributed = NSMutableAttributedString(
      string: fullText,
      attributes: [
        .font: normalFont,
        .foregroundColor: color,
        .paragraphStyle: paragraph
      ]
    )
    
    if let prefixRange = fullText.range(of: prefix) {
      let nsRange = NSRange(prefixRange, in: fullText)
      attributed.addAttributes([
        .font: boldFont
      ], range: nsRange)
    }
    
    for match in matches {
      if let range = Range(match.range(at: 1), in: value) {
        let boldText = String(value[range])
        if let rangeInFull = fullText.range(of: boldText) {
          let nsRange = NSRange(rangeInFull, in: fullText)
          attributed.addAttributes([
            .font: boldFont
          ], range: nsRange)
        }
      }
    }
    
    self.attributedText = attributed
  }
}
