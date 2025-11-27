//
//  CustomRangeCalendarCVC.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 5/5/25.
//

import FSCalendar
import UIKit

class CustomRangeCalendarCVC: FSCalendarCell {
  
  private let backgroundRangeView = UIView()
  private var currentDate: Date?

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundRangeView.layer.cornerRadius = 20
    backgroundRangeView.isHidden = true
    contentView.insertSubview(backgroundRangeView, at: 0)
  }

  required init!(coder aDecoder: NSCoder!) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    backgroundRangeView.frame = CGRect(x: (contentView.bounds.width - 40) / 2,
                                       y: (contentView.bounds.height - 40) / 2,
                                       width: 40, height: 40)
    titleLabel.frame = contentView.bounds
  }

  /// Gọi từ `cellFor` để truyền dữ liệu range
  func configure(with date: Date, isInRange: Bool, isStart: Bool, isEnd: Bool) {
    self.currentDate = date
    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)
    titleLabel.text = "\(day)"
    
    if isStart || isEnd {
      backgroundRangeView.isHidden = false
      backgroundRangeView.backgroundColor = UIColor(rgb: 0xFFEFD3)
      backgroundRangeView.borderWidth = 1
      backgroundRangeView.borderColor = UIColor(rgb: 0xF26101)
    } else if isInRange {
      backgroundRangeView.isHidden = false
      backgroundRangeView.borderWidth = 0
      backgroundRangeView.backgroundColor = UIColor(rgb: 0xFFEFD3)
    } else {
      backgroundRangeView.isHidden = true
    }
  }

  override func configureAppearance() {
    super.configureAppearance()
    
    guard let date = currentDate else { return }
    let calendar = Calendar.current
    let today = Date()

    titleLabel.font = AppFont.font(.regularText, size: 20)

    if calendar.isDateInToday(date) {
      titleLabel.textColor = UIColor(rgb: 0xF26101)
      titleLabel.font = AppFont.font(.medium, size: 24)
      backgroundRangeView.backgroundColor = UIColor(rgb: 0xFFEFD3)
    } else if self.isSelected {
      titleLabel.textColor = UIColor(rgb: 0x2E1F88)
    } else if date > today {
      titleLabel.textColor = .lightGray
    } else {
      titleLabel.textColor = UIColor(rgb: 0x332644)
    }
  }
}
