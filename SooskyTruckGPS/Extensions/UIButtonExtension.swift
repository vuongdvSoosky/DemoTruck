//
//  UIButtonExtension.swift
//  SooskyBabyTracker
//
//   Created by VuongDV on 9/4/25.
//

import UIKit
import SnapKit

@IBDesignable extension UIButton {
  // Text sẽ được hiển thị theo ngôn ngữ với key này.
  @IBInspectable var localizeKey: String? {
    get {
      return self.titleLabel?.text
    } set {
      DispatchQueue.main.async {
        self.setTitle(newValue?.localized(), for: .normal)
      }
    }
  }
}

extension UIButton {
  func setLeftView(_ view: UIView?) {
    // Xóa các leftView cũ (nếu có)
    self.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
    
    guard let view = view else {
      // Reset titleEdgeInsets nếu không có view
      self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
      return
    }
    
    view.tag = 999 // Đánh dấu để dễ xóa sau
    self.addSubview(view)
    
    view.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(12)
      make.width.height.equalTo(20)
    }
    
    // Cập nhật title padding để tránh đè
    self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
  }
}
